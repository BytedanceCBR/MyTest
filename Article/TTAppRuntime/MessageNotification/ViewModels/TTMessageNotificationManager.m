//
//  TTMessageNotificationManager.m
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "TTMessageNotificationManager.h"
#import "TTMessageNotificationTipsManager.h"
#import "TTMessageNotificationTipsModel.h"
#import "TTMessageNotificationModel.h"

#import <TTAccountBusiness.h>
#import "TTNetworkManager.h"

#import "SDWebImageCompat.h"

#define kMessageNotificationFetchUnreadMessageDefaultTimeInterval 180
#define kMessageNotificationFetchUnreadMessageMinTimeInterval 60

static NSString * const kNewMessageNotificationCheckIntervalKey = @"kNewMessageNotificationCheckIntervalKey";

@interface TTMessageNotificationManager ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval lastInterval;

@end

@implementation TTMessageNotificationManager

+ (instancetype)sharedManager
{
    static TTMessageNotificationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTMessageNotificationManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiverMessageUpdateWithPush:) name:@"kTTUGCMessageUpdateMessage" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 定时轮询拉取未读消息提示
- (void)startPeriodicalFetchUnreadMessageNumberWithChannel:(NSString *)channel
{
    [self stopPeriodicalFetchUnreadMessageNumber];
    //未登录启动时调用一次后，再登录，不会调用此方法，因此第一次需要构造timer
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[self fetchUnreadTimeInterval] target:self selector:@selector(periodicalFetchUnreadMessage:) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)receiverMessageUpdateWithPush:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self fetchUnreadMessageWithChannel:nil];
        }
    });
}

- (NSTimeInterval)fetchUnreadTimeInterval
{
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

- (void)stopPeriodicalFetchUnreadMessageNumber
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)periodicalFetchUnreadMessage:(NSTimer *)timer
{
    [self fetchUnreadMessageWithChannel:nil];
}

#pragma mark - 手动拉取未读消息提示
- (void)fetchUnreadMessageWithChannel:(NSString *)channel
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (!isEmptyString(channel)) {
        params[@"from"] = channel;
    }
    
//    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting messageNotificationUnreadURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
//        if (error || ![jsonObj isKindOfClass:[NSDictionary class]] || [jsonObj tt_intValueForKey:@"error_code"] != 0) {
//            return;
//        }
//        NSDictionary *response = [(NSDictionary *)jsonObj tt_objectForKey:@"data"];
//        TTMessageNotificationTipsModel *tipsModel = [[TTMessageNotificationTipsModel alloc] initWithDictionary:response error:nil];
//        if (tipsModel) {
//            LOGD(@"%@", tipsModel);
//            dispatch_main_async_safe(^{
//                [[TTMessageNotificationTipsManager sharedManager] updateTipsWithModel:tipsModel];
//                if([tipsModel.interval doubleValue] != self.lastInterval){
//                    [self setNewMessageNotificationCheckInterval:[tipsModel.interval doubleValue]];
//
//                    [self stopPeriodicalFetchUnreadMessageNumber];
//
//                    self.timer = [NSTimer scheduledTimerWithTimeInterval:[self fetchUnreadTimeInterval] target:self selector:@selector(periodicalFetchUnreadMessage:) userInfo:nil repeats:YES];
//                }
//            });
//        }
//    }];
}

#pragma mark - 拉取消息通知列表
- (void)fetchMessageListWithChannel:(NSString *)channel cursor:(NSNumber *)cursor completionBlock:(void (^)(NSError *, TTMessageNotificationResponseModel *))completionBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (!isEmptyString(channel)) {
        params[@"from"] = channel;
    }
    
    if (cursor) {
        params[@"cursor"] = cursor;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting messageNotificationListURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error || ![jsonObj isKindOfClass:[NSDictionary class]] || [jsonObj tt_intValueForKey:@"error_code"] != 0) {
            if (!error) {
                error = [NSError errorWithDomain:kTTMessageNotificationErrorDomain code:-1 userInfo:nil];
            }
            if (completionBlock) {
                dispatch_main_async_safe(^{
                    completionBlock(error, nil);
                });
            }
            return;
        }
        NSDictionary *response = [(NSDictionary *)jsonObj tt_objectForKey:@"data"];
        TTMessageNotificationResponseModel *responseModel = [[TTMessageNotificationResponseModel alloc] initWithDictionary:response error:&error];
        LOGD(@"%@", responseModel.msgList);
        if (completionBlock) {
            dispatch_main_async_safe(^{
                completionBlock(nil, responseModel);
            });
        }
    }];
}

- (BOOL)isReachUnreadWithCursor:(NSNumber *)cursor readCursor:(NSNumber *)readCursor
{
    //服务端的cursor拉链是由小到大排列，比分界线cursor小则为旧的已读数据，大则为新的未读数据
    return cursor.longLongValue <= readCursor.longLongValue;
}


#pragma mark - 设置轮询间隔
// 轮询间隔由本接口下发
- (void)setNewMessageNotificationCheckInterval:(NSTimeInterval)interval
{
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kNewMessageNotificationCheckIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)newMessageNotificationCheckInterval
{
    NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:kNewMessageNotificationCheckIntervalKey];
    return interval;
}

@end
