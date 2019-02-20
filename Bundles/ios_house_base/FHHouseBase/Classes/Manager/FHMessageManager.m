//
//  FHMessageManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/2/18.
//

#import "FHMessageManager.h"
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHHouseBridgeManager.h"
#import "IMChatMessageUnreadCountObserver.h"
#import "IMManager.h"
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
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initNotification {
    [IMManager shareInstance].chatMessageUnreadCountObv = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSyncMessage) name:@"kFHLogInAccountStatusChangedNotification" object:nil];
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
    [self getNewNumberWithCompletion:^(NSInteger number, NSError * _Nonnull error) {
        if(!error){
            wself.unreadSystemMsgCount = number;
//            [wself setBadgeNumber:number];
            [self refreshBadgeNumber];
        }
    }];
}

- (void)setBadgeNumber:(NSInteger)number {
    id<FHHouseEnvContextBridge> envContextBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    [envContextBridge setMessageTabBadgeNumber:number];
}

-(void)refreshBadgeNumber {
    [self setBadgeNumber:_unreadChatMsgCount + _unreadSystemMsgCount];
}

- (void)getNewNumberWithCompletion:(void(^)(NSInteger number , NSError *error))completion {
    
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
            completion(count,error);
        }
    }];
}

#pragma -- IMChatMessageUnreadCountObserver --
- (void)onMessageUnreadCountChanged:(NSInteger)unreadCount {
    if (unreadCount < 0) {
        return;
    }
    self.unreadChatMsgCount = unreadCount;
    [self refreshBadgeNumber];
}

-(void)reduceSystemMessageTabBarBadgeNumber:(NSInteger)reduce {
    self.unreadSystemMsgCount = self.unreadSystemMsgCount - reduce;
    if (self.unreadSystemMsgCount < 0) {
        self.unreadSystemMsgCount = 0;
    }
    [self refreshBadgeNumber];
}

@end
