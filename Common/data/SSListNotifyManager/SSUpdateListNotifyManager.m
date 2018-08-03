//
//  SSUpdateListNotifyManager.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-8.
//
//

#import "SSUpdateListNotifyManager.h"
#import "NetworkUtilities.h"
#import "CommonURLSetting.h"
#import <TTAccountBusiness.h>
#import "SSCommonLogic.h"
#import "TTProjectLogicManager.h"
#import "NSDictionary+TTAdditions.h"
#import <TTNetworkManager/TTNetworkManager.h>

#define kUDUpdateNOTagKey @"kUDUpdateNOTagKey"
#define kUDStartGetUpdateCount @"kUDStartGetUpdateCount"

#define kUDUserUpdateNOTagKey @"kUDUserUpdateNOTagKey"
#define kUDStartGetUserUpdateCount @"kUDStartGetUserUpdateCount"

#define kUDUserUpdateDefaultMinCreateTimeKey @"kUDUserUpdateDefaultMinCreateTimeKey"

#define fetchUpdateCountTimeInterval 180


static NSString *const kArticleUpdateBadgeRefreshIntervalStorageKey =   @"kArticleUpdateBadgeRefreshIntervalStorageKey";
static NSTimeInterval const kArticleUPdateBadgeDefaultRefreshInterval = 3 * 60;

typedef enum SSUpdateListNotifyType{
    SSUpdateListNotifyTypeGetUpdate = 1,
    SSUpdateListNotifyTypeGetUserUpdate
}SSUpdateListNotifyType;

@interface SSUpdateListNotifyManager()
<
TTAccountMulticastProtocol
>

@property (nonatomic, strong) NSTimer *notificationCountFetcheTimer;
@end

@implementation SSUpdateListNotifyManager

@synthesize notificationCountFetcheTimer = _notificationCountFetcheTimer;

- (void)dealloc
{
    [_notificationCountFetcheTimer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [TTAccount removeMulticastDelegate:self];
}

+ (SSUpdateListNotifyManager *)shareInstance
{
    static dispatch_once_t onceToken;
    static SSUpdateListNotifyManager * shareManager;
    dispatch_once(&onceToken, ^{
        shareManager = [[SSUpdateListNotifyManager alloc] init];
    });
    return shareManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}


- (void)startGetUpdateCount:(NSDictionary *)conditions
{
    if (!TTNetworkConnected() || ![TTAccountManager isLogin]) {
        return;
    }
    
    NSDictionary * paramCondition = [self getUpdateCountCondition:conditions];
    
//    if ([[[paramCondition objectForKey:@"getParameter"] objectForKey:@"min_create_time"] longValue] == 0) {//时间戳为0的时候， 不请求
//        return;
//    }
    
    NSDictionary * getParameter = [NSDictionary dictionaryWithDictionary:[paramCondition objectForKey:@"getParameter"]];
    NSString * url = [NSString stringWithString:[paramCondition objectForKey:@"url"]];
    
    NSDictionary * userInfoDict = [NSDictionary dictionaryWithDictionary:conditions];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:getParameter method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error == nil) {
            int totalCount = [jsonObj tt_intValueForKey:@"total_count"];
            NSString * key = [userInfoDict objectForKey:kStartGetUpdateCountTag];
            if ([key length] == 0) {
                key = kUDUpdateNOTagKey;
            }
            
            [SSUpdateListNotifyManager setUpdateCount:totalCount byTag:key];
        }
    }];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogout
{
    [SSUpdateListNotifyManager resetUpdateCount:nil];
}

- (NSDictionary *)getUpdateCountCondition:(NSDictionary *)conditions
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString * url = [CommonURLSetting updateCountURLString];
    [result setObject:url forKey:@"url"];
    
    NSMutableDictionary * getParameter = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if ([[conditions objectForKey:kStartGetUpdateCountMinCreateTime] longValue] > 0) {
        [getParameter setObject:[conditions objectForKey:kStartGetUpdateCountMinCreateTime] forKey:@"min_create_time"];
    }

    if ([[conditions objectForKey:kStartGetUpdateCountTag] length] > 0) {
        [getParameter setObject:[conditions objectForKey:kStartGetUpdateCountTag] forKey:@"tag"];
    }
    [getParameter setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [getParameter setObject:[TTSandBoxHelper appName] forKey:@"app_name"];
    
    [result setObject:getParameter forKey:@"getParameter"];
    
    return result;
}

#pragma mark -- update list

+ (void)resetUpdateCount:(NSString *)tag
{
    if (tag == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUpdateCountUserDefaultKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [self setUpdateCount:0 byTag:tag];
    }
}

+ (void)setUpdateCount:(NSUInteger)count byTag:(NSString *)tag
{
    if (tag == nil) {
        SSLog(@"setUpdateCount can`t user nil as tag");
        return;
    }
    
    NSDictionary * updateCountAndTagDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUpdateCountUserDefaultKey"];
    
    NSMutableDictionary * mutableCountTagDict = nil;
    
    if (updateCountAndTagDict == nil) {
        mutableCountTagDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    else {
        mutableCountTagDict = [NSMutableDictionary dictionaryWithDictionary:updateCountAndTagDict];
    }
    
    [mutableCountTagDict setObject:[NSNumber numberWithInteger:count] forKey:tag];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:mutableCountTagDict] forKey:@"kUpdateCountUserDefaultKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCountFetchedNotification object:nil];
}

+ (NSInteger)getUpdateCount:(NSString *)tag
{
    if (tag == nil) {
        SSLog(@"getUpdateCount can`t user nil as tag");
        return 0;
    }
    return [[[[NSUserDefaults standardUserDefaults] objectForKey:@"kUpdateCountUserDefaultKey"] objectForKey:tag] intValue];
}

+ (void)saveAutoRefreshUpdateListTimeinterval:(NSTimeInterval)interval
{
    if (interval <= 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:@"SSUpdateListNotifyManagerAutoRefreshTimeIntervalKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)refreshUpdateListTimeinterval
{
    NSTimeInterval time = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SSUpdateListNotifyManagerAutoRefreshTimeIntervalKey"] doubleValue];
    if (time <= 0) {
        time = 60 * 60 * 8;
    }
    return time;
}


#pragma mark -- user update notification

+ (long)getUserUpdateNotificationFirstItemMinCreateTime
{
    long result = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUpdateNotificationFirstItemMinCreateTime"] longValue];
    if (result == 0) {
        result = (long)[[NSDate date] timeIntervalSince1970];
        [self setUserUpdateNotificationFirstItemMinCreateTime:result];
    }
    
    return result;
}

+ (void)setUserUpdateNotificationFirstItemMinCreateTime:(long)minCreteTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:minCreteTime] forKey:@"UserUpdateNotificationFirstItemMinCreateTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - fetch notification count timer
+ (void)setUpdateBadgeRefreshInterval:(NSTimeInterval)interval
{
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kArticleUpdateBadgeRefreshIntervalStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)updateBadgeRefreshInterval
{
    NSTimeInterval result = kArticleUPdateBadgeDefaultRefreshInterval;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:kArticleUpdateBadgeRefreshIntervalStorageKey] doubleValue] > 0)
    {
        result = MAX([[[NSUserDefaults standardUserDefaults] objectForKey:kArticleUpdateBadgeRefreshIntervalStorageKey] doubleValue], 60.f);
    }
    return result;
}

@end
