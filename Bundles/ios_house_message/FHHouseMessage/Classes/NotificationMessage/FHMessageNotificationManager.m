//
//  FHMessageNotificationManager.m
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "FHMessageNotificationManager.h"

#import "TTAccountBusiness.h"
#import "TTNetworkManager.h"

#import "FHUnreadMsgModel.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHMessageAPI.h"
#import "FHEnvContext.h"

#define kMessageNotificationFetchUnreadMessageDefaultTimeInterval 30
#define kMessageNotificationFetchUnreadMessageMinTimeInterval 15

static NSString *const kNewMessageNotificationCheckIntervalKey = @"kNewMessageNotificationCheckIntervalKey";

@interface FHMessageNotificationManager () <TTAccountMulticastProtocol>

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) NSTimeInterval lastInterval;

@end

@implementation FHMessageNotificationManager

+ (instancetype)sharedManager {
    static FHMessageNotificationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHMessageNotificationManager alloc] init];
    });

    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [TTAccount addMulticastDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiverMessageUpdateWithPush:) name:@"kTTUGCMessageUpdateMessage" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

#pragma mark - 定时轮询拉取未读消息提示

- (void)startPeriodicalFetchUnreadMessageNumberWithChannel:(NSString *)channel {
    [self stopPeriodicalFetchUnreadMessageNumber];
    //未登录启动时调用一次后，再登录，不会调用此方法，因此第一次需要构造timer
    if(![TTAccountManager isLogin] || ![FHEnvContext isUGCOpen]){
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[self fetchUnreadTimeInterval] target:self selector:@selector(periodicalFetchUnreadMessage:) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)receiverMessageUpdateWithPush:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self fetchUnreadMessageWithChannel:nil callback:nil];
        }
    });
}

- (NSTimeInterval)fetchUnreadTimeInterval {
    NSTimeInterval timeInterval = [self newMessageNotificationCheckInterval];
    if (!timeInterval) {
        timeInterval = kMessageNotificationFetchUnreadMessageDefaultTimeInterval;
    }
    if (timeInterval < kMessageNotificationFetchUnreadMessageMinTimeInterval) {
        timeInterval = kMessageNotificationFetchUnreadMessageDefaultTimeInterval;
    }

    self.lastInterval = timeInterval;

    return timeInterval;
}

- (void)stopPeriodicalFetchUnreadMessageNumber {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)periodicalFetchUnreadMessage:(NSTimer *)timer {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeriodicalFetchUnreadMessage object:nil];
    [self fetchUnreadMessageWithChannel:nil callback:nil];
}

#pragma mark - 手动拉取未读消息提示

- (void)fetchUnreadMessageWithChannel:(NSString *)channel callback:(void (^)(FHUnreadMsgDataUnreadModel *))callback; {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (!isEmptyString(channel)) {
        params[@"from"] = channel;
    }
    
    if(![TTAccountManager isLogin] || ![FHEnvContext isUGCOpen]){
        if (callback) {
            callback(nil);
        }
        return;
    }
    
    [FHMessageAPI requestUgcUnreadMessageWithChannel:channel completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        if (error || ![model isKindOfClass:[FHUGCUnreadMsgModel class]] || [model.status integerValue] != 0) {
            if (callback) {
                callback(nil);
            }
            return;
        }
        FHUGCUnreadMsgModel *unreadMsgModel = (FHUGCUnreadMsgModel *) model;
        FHUnreadMsgDataUnreadModel *tipsModel = unreadMsgModel.data;

        if (callback) {
            callback(tipsModel);
        }
        if (tipsModel && tipsModel.hasHistoryMsg) {
            [[FHMessageNotificationTipsManager sharedManager] updateTipsWithModel:tipsModel];
            if ([tipsModel.interval doubleValue] != self.lastInterval) {
                [self setNewMessageNotificationCheckInterval:[tipsModel.interval doubleValue]];

                [self stopPeriodicalFetchUnreadMessageNumber];

                self.timer = [NSTimer scheduledTimerWithTimeInterval:[self fetchUnreadTimeInterval] target:self selector:@selector(periodicalFetchUnreadMessage:) userInfo:nil repeats:YES];
            }
        }
    }];

}

#pragma mark - 拉取消息通知列表

- (void)fetchMessageListWithChannel:(NSString *)channel cursor:(NSNumber *)cursor completionBlock:(void (^)(NSError *, TTMessageNotificationResponseModel *))completionBlock {
    [FHMessageAPI requestUgcMessageList:cursor channel:channel completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        if (!model || error || ![model isKindOfClass:TTMessageNotificationRespModel.class]) {
            if (completionBlock) {
                completionBlock(error, nil);
            }
        }
        TTMessageNotificationRespModel *respModel = (TTMessageNotificationRespModel *) model;
        if (completionBlock) {
            completionBlock(nil, respModel.data);
        }
    }];
}

#pragma mark - 设置轮询间隔

// 轮询间隔由本接口下发
- (void)setNewMessageNotificationCheckInterval:(NSTimeInterval)interval {
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kNewMessageNotificationCheckIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)newMessageNotificationCheckInterval {
    NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:kNewMessageNotificationCheckIntervalKey];
    return interval;
}

- (void)onAccountLogin {
    [self startPeriodicalFetchUnreadMessageNumberWithChannel:nil];
}

- (void)onAccountLogout {
    [self stopPeriodicalFetchUnreadMessageNumber];
}

@end
