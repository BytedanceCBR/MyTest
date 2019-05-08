//
//  ArticleMessageManager.m
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import "ArticleMessageManager.h"
#import "ArticleURLSetting.h"
#import "SSUserModel.h"
#import <TTAccountBusiness.h>
#import "SSUpdateListNotifyManager.h"
#import "NSDictionary+TTAdditions.h"
#import "ArticleBadgeManager.h"
#import "TTNetworkManager.h"

NSString *const kGetFollowNumberFinishNofication            =   @"kGetFollowNumberFinishNofication";
NSString *const kGetFollowNumberKey                         =   @"kGetFollowNumberKey";
NSString *const kIsForceGetFollowNumberKey                  =   @"kIsForceGetFollowNumberKey";

static NSString *const kFollowNumUpdateTimeKey              =   @"kFollowNumUpdateTimeKey";
static NSString *const kFollowNumUpdateVersionKey           =   @"kFollowNumUpdateVersionKey";


@interface ArticleMessageManager()
<
TTAccountMulticastProtocol
>

@property(nonatomic, retain) NSTimer *refreshFollowNumTimer;

@end

@implementation ArticleMessageManager

static ArticleMessageManager * _messageManager;
+ (instancetype) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _messageManager = [[self alloc] init];
    });
    return _messageManager;
}

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self];
    
    [_refreshFollowNumTimer invalidate];
    self.refreshFollowNumTimer = nil;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [TTAccount addMulticastDelegate:self];
    }
    
    return self;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self updateGetParameterWithUpdateTime:@(0) updateVersion:@""];
}

- (void)updateGetParameterWithUpdateTime:(NSNumber *)time updateVersion:(NSString *)version
{
    //https://wiki.bytedance.com/pages/viewpage.action?pageId=55123618
    //update_time 上次请求服务端返回，第一次传0即可
    //update_version 上次请求服务端返回，第一次传空即可
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:time forKey:kFollowNumUpdateTimeKey];
    [userDefaults setValue:version forKey:kFollowNumUpdateVersionKey];
    [userDefaults synchronize];
}

+ (void)invalidate
{
    [[[ArticleMessageManager sharedManager] refreshFollowNumTimer] invalidate];
}

+ (void)startPeriodicalGetFollowNumber
{
    [[[ArticleMessageManager sharedManager] refreshFollowNumTimer] invalidate];
    [[ArticleMessageManager sharedManager] setRefreshFollowNumTimer:[NSTimer scheduledTimerWithTimeInterval:[SSUpdateListNotifyManager updateBadgeRefreshInterval]
                                                                                                     target:[ArticleMessageManager sharedManager]
                                                                                                   selector:@selector(refreshFollowNumTimer:)
                                                                                                   userInfo:nil
                                                                                                    repeats:YES]];
    [[[ArticleMessageManager sharedManager] refreshFollowNumTimer] fire];
}

+ (void)forceRefreshFollowNum {
    [[ArticleMessageManager sharedManager] refreshFollowNumTimer:nil];
}

- (void)refreshFollowNumTimer:(NSTimer*)timer
{
    [[ArticleMessageManager sharedManager] startGetFollowNumberfinishBlock:^(int isUpdate, int count, NSError *error) {
        if(!error)
        {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            if (isUpdate == 0) {//无更新
                [userInfo setValue:@(0) forKey:kGetFollowNumberKey];
            }
            else if(isUpdate == 1 && count > 0){//有更新 且更新数大于0
                [userInfo setValue:@(count) forKey:kGetFollowNumberKey];
            }
            else{//有更新 但是更新数不用管是多少，显示红点，不显示数
                [userInfo setValue:@(-1000) forKey:kGetFollowNumberKey];
            }
            
            [userInfo setValue:@(timer == nil?1:0) forKey:kIsForceGetFollowNumberKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetFollowNumberFinishNofication
                                                                object:[ArticleMessageManager sharedManager]
                                                              userInfo:userInfo];
        }
    }];
}

- (void)startGetFollowNumberfinishBlock:(void(^)(int isUpdated, int count , NSError *error))block
{
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *updateTime = [userDefaults valueForKey:kFollowNumUpdateTimeKey];
    NSString *updateVersion = [userDefaults stringForKey:kFollowNumUpdateVersionKey];
    
    if (updateTime == nil){
        updateTime = @0;
    }
    if (updateVersion == nil){
        updateVersion = @"";
    }
    [dict setValue:updateTime forKey:@"update_time"];
    [dict setValue:updateVersion forKey:@"update_version"];
    
//    __weak typeof(self) weakSelf = self;

    // 关注频道服务，暂时不需要
//    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting followGetUpdateNumberURLString]
//                                                     params:dict
//                                                     method:@"GET"
//                                           needCommonParams:YES
//                                                   callback:^(NSError *error, id jsonObj) {
//                                                       int isUpdated = 0;
//                                                       int count = 0;
//                                                       if(!error)
//                                                       {
//                                                           NSDictionary * resultDict = jsonObj;
//                                                           NSDictionary * data = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
//                                                           count = [data intValueForKey:@"update_count" defaultValue:0];
//                                                           isUpdated = [data intValueForKey:@"isupdated" defaultValue:0];
//                                                           [weakSelf updateGetParameterWithUpdateTime:@([data intValueForKey:@"update_time" defaultValue:0]) updateVersion:[data stringValueForKey:@"update_version" defaultValue:@""]];
//                                                       }
//
//                                                       block(isUpdated, count, error);
//                                                   }];
}

@end
