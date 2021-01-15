//
//  FHMessageManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/2/18.
//

#import "FHMessageManager.h"
#import "TTNetworkManager.h"
#import "FHURLSettings.h"
#import "FHHouseBridgeManager.h"
#import "IMChatMessageUnreadCountObserver.h"
#import "IMManager.h"
#import "FHMessageNotificationManager.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHEnvContext.h"

#define API_ERROR_CODE  1000
#define GET @"GET"

@interface FHMessageManager()<IMChatMessageUnreadCountObserver>

@property(nonatomic , weak) TTHttpTask *requestTask;
@property(nonatomic , strong) NSTimer *timer;
@property(atomic, assign) NSInteger unreadSystemMsgCount;
@property(atomic, assign) NSInteger unreadChatMsgCount;
@end

@implementation FHMessageManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initNotification];
        self.unreadSystemMsgCount = 0;
        self.unreadChatMsgCount = 0;
        
        // 更新微聊消息未读数，最小间隔2秒
        [[[[self rac_signalForSelector:@selector(onMessageUnreadCountChanged:)] deliverOnMainThread] throttle:2] subscribeNext:^(RACTuple * _Nullable x) {
            RACTuple *unreadNumberTuple = [[IMManager shareInstance] unreadNumberTupleForConversations];
            RACTupleUnpack(NSNumber *totalUnmuteUnreadNumber, NSNumber *totalMuteUnreadNumber) = unreadNumberTuple;
            NSLog(@"%@",totalMuteUnreadNumber);
            NSInteger chatNumber = totalUnmuteUnreadNumber.unsignedIntegerValue;
            [[FHEnvContext sharedInstance].messageManager writeUnreadChatMsgCount:chatNumber];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initNotification {
    [IMManager shareInstance].chatMessageUnreadCountObv = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSyncMessage) name:@"kFHLogInAccountStatusChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUgcMessageUnreadCountChanged) name:@"kTTMessageNotificationTipsChangeNotification" object:nil];
}

- (void)startSyncMessage {
    [self startTimer];
}

- (void)stopSyncMessage {
    [self stopTimer];
}

- (void)startTimer {
    if(_timer){
        [self stopTimer];
    }
    [self.timer fire];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (NSTimer *)timer {
    if(!_timer){
        _timer  =  [NSTimer timerWithTimeInterval:1800 target:self selector:@selector(getNewNumberForTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)getNewNumberForTimer {
    __weak typeof(self) wself = self;
    [self getNewNumberWithCompletion:^(NSInteger number,id obj ,NSError * _Nonnull error) {
        if(!error){
            [wself writeUnreadSystemMsgCount:number];
        }
    }];
}

- (void)setBadgeNumber:(NSInteger)number {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<FHHouseEnvContextBridge> envContextBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
        [envContextBridge setMessageTabBadgeNumber:number];
    });
}

-(void)refreshBadgeNumber {
    [self setBadgeNumber:[self getTotalUnreadMessageCount]];
}

- (void)getNewNumberWithCompletion:(void(^)(NSInteger number ,id obj ,NSError *error))completion {
    
    NSString *url = [[FHURLSettings baseURL] stringByAppendingString:@"/f100/api/msg/unread"];
    
    self.requestTask = [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:nil method:GET needCommonParams:YES callback:^(NSError *error, id obj) {
        
        NSInteger count = 0;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                BOOL success = ([json[@"status"] integerValue] == 0);
                if(success){
                    NSArray *items = json[@"data"][@"unread"];
                    for (NSDictionary *item in items) {
                        NSInteger unread = [item[@"unread"] integerValue];
                        count += unread;
                    }
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        if (completion) {
            completion(count,obj,error);
        }
    }];
}

- (NSInteger)getTotalUnreadMessageCount {
    return self.unreadSystemMsgCount + self.unreadChatMsgCount + [[FHMessageNotificationTipsManager sharedManager] unreadNumber];
}

- (NSInteger)systemMsgUnreadNumber {
    return  self.unreadSystemMsgCount;
}
- (NSInteger)ugcMsgUnreadNumber {
    return [[FHMessageNotificationTipsManager sharedManager] unreadNumber];
}
- (NSInteger)chatMsgUnreadNumber {
    return self.unreadChatMsgCount;
}

#pragma ugc
-(void)onUgcMessageUnreadCountChanged{
    [self postMessageUnreadChanged];
    [self refreshBadgeNumber];
}

-(void)writeUnreadSystemMsgCount:(NSUInteger) count {
    BOOL isNeedSendNotification = self.unreadSystemMsgCount != count;
    self.unreadSystemMsgCount = count;
    if(isNeedSendNotification) {
        [self postMessageUnreadChanged];
    }
    [self refreshBadgeNumber];
}

- (void)writeUnreadChatMsgCount:(NSUInteger)unreadCount {
    if (unreadCount < 0) {
        return;
    }
    BOOL isNeedSendNotification = self.unreadChatMsgCount != unreadCount;
    self.unreadChatMsgCount = unreadCount;
    if(isNeedSendNotification) {
        [self postChatMessageUnreadChangedNotification];
    }
    [self refreshBadgeNumber];
}
#pragma -- IMChatMessageUnreadCountObserver --
- (void)onMessageUnreadCountChanged:(NSInteger)unreadCount {
    // 不使用SDK发过来的未读数,这个未读数据源有机率和所有会话未读数总和不一致，所有微聊未读数以所有会话未读数总和为准
    // 等SDK修复后，再使用，对接人 屈永播<quyongbo@bytedance.com>
    // [self writeUnreadSystemMsgCount:unreadCount];
    // 触发RAC监听信号，更新微聊消息未读数
}

// 发送通知消息未读数变化
- (void)postMessageUnreadChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHMessageUnreadChangedNotification" object:nil];
}

// 发送微聊消息未读数变化通知
- (void)postChatMessageUnreadChangedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHChatMessageUnreadChangedNotification" object:nil];
}

- (void)clearAllMessageUnreadCount {
    [self writeUnreadChatMsgCount:0];
}

-(void)reduceSystemMessageTabBarBadgeNumber:(NSInteger)reduce {
    [self writeUnreadSystemMsgCount:MAX(0, self.unreadSystemMsgCount - reduce)];
}

@end
