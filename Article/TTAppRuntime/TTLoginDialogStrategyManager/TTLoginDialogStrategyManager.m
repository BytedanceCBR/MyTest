//
//  TTLoginDialogStrategyManager.m
//  Article
//
//  Created by wangdi on 2017/6/16.
//
//

#import "TTLoginDialogStrategyManager.h"
#import "NewsBaseDelegate.h"
#import <TTAccountBusiness.h>
#import "TTModuleBridge.h"

static NSString * const kLoginDialogBootKey = @"loginDialogBootKey";
static NSString * const kLoginDialogDislikeKey = @"loginDialogDislikeKey";
static NSString * const kLoginDialogPushHistoryKey = @"loginDialogHistoryKey";
static NSString * const kLoginDialogMyFavorKey = @"loginDialogMyFavoryKey";

@implementation TTLoginDialogModel

@end

@interface TTLoginDialogStrategyManager ()
<
TTAccountMulticastProtocol
>

@property (nonatomic, assign) BOOL isShowingLoginDialog;

@end

@implementation TTLoginDialogStrategyManager

static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTLoginDialogStrategyManager.setFeedDislikeTime" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        [[TTLoginDialogStrategyManager sharedInstance] setFeedDislikeTime];
        return @"setFeedDislikeTime,done";
    }];
}

- (instancetype)init
{
    if(self = [super init]) {
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)setBootDataWithDictionary:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLoginDialogBootKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    TTLoginDialogModel *bootModel = [self bootModel];
    if([TTAccountManager isLogin] || ![SSCommonLogic appBootEnable] || bootModel.action_tick.count <= 0) return;
    NSInteger bootTime = [self bootTime];
    [self setBootTime:++bootTime];
    NSInteger currentBootTime = [self bootTime];
    for(NSNumber *time in bootModel.action_tick) {
        if(currentBootTime == time.integerValue && bootModel.action_type.integerValue == 2 && [self bootTotalTime] < bootModel.action_total.integerValue) {
            //弹出登录框
            [self showLoginDialogWithIsBoot:YES];
            break;
        }
    }
}

- (void)setDislikeDataWithDictionary:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLoginDialogDislikeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)setMyFavorDataWithDictionary:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLoginDialogMyFavorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)setPushHistoryDataWithDictionary:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kLoginDialogPushHistoryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (TTLoginDialogModel *)bootModel
{
    NSError *error = nil;
    NSDictionary *bootDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginDialogBootKey];
    TTLoginDialogModel *boot = [[TTLoginDialogModel alloc] initWithDictionary:bootDict error:&error];
    return error ? nil : boot;
}

- (TTLoginDialogModel *)disLikeModel
{
    NSError *error = nil;
    NSDictionary *dislikeDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginDialogDislikeKey];
    TTLoginDialogModel *dislike = [[TTLoginDialogModel alloc] initWithDictionary:dislikeDict error:&error];
    return error ? nil : dislike;
}

- (TTLoginDialogModel *)myFavorModel
{
    NSError *error = nil;
    NSDictionary *myFavorDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginDialogMyFavorKey];
    TTLoginDialogModel *myFavor = [[TTLoginDialogModel alloc] initWithDictionary:myFavorDict error:&error];
    return error ? nil : myFavor;
}

- (TTLoginDialogModel *)pushHistoryModel
{
    NSError *error = nil;
    NSDictionary *pushHistoryDict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginDialogPushHistoryKey];
    TTLoginDialogModel *pushHistory = [[TTLoginDialogModel alloc] initWithDictionary:pushHistoryDict error:&error];
    return error ? nil : pushHistory;
}

- (void)setLoginDialogData:(NSDictionary *)loginDialogStrategyDict
{
    NSDictionary *bootDict = [[loginDialogStrategyDict tt_dictionaryValueForKey:@"boot"] tt_dictionaryValueForKey:@"default"];
    [self setBootDataWithDictionary:bootDict];
    
    NSDictionary *dislikeDict = [[loginDialogStrategyDict tt_dictionaryValueForKey:@"dislike"] tt_dictionaryValueForKey:@"default"];
    [self setDislikeDataWithDictionary:dislikeDict];
    
    NSDictionary *myfavorDict = [[loginDialogStrategyDict tt_dictionaryValueForKey:@"enter_list"] tt_dictionaryValueForKey:@"my_favor"];
    [self setMyFavorDataWithDictionary:myfavorDict];
    
    NSDictionary *pushHistoryDict = [[loginDialogStrategyDict tt_dictionaryValueForKey:@"enter_list"] tt_dictionaryValueForKey:@"push_history"];
    [self setPushHistoryDataWithDictionary:pushHistoryDict];

}

- (void)setMyFavorEnable:(NSNumber *)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable.integerValue forKey:@"login_myFavor_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)myFavorEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"login_myFavor_enable"];
}

- (void)setPushHistoryEnable:(NSNumber *)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable.integerValue forKey:@"login_pushHistory_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)pushHistoryEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"login_pushHistory_enable"];
}

- (void)setMyFavorEnterTime:(NSInteger)time
{
    TTLoginDialogModel *myFavorModel = [self myFavorModel];
    if(myFavorModel.action_tick.count <= 0) return;
    [[NSUserDefaults standardUserDefaults] setInteger:time forKey:@"login_favor_enter_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)myFavorEnterTime
{
    NSInteger time = [[NSUserDefaults standardUserDefaults] integerForKey:@"login_favor_enter_time"];
    return time;
}

- (void)setPushHistoryEnterTime:(NSInteger)time
{
    TTLoginDialogModel *pushHistoryModel = [self pushHistoryModel];
    if(pushHistoryModel.action_tick.count <= 0) return;
    [[NSUserDefaults standardUserDefaults] setInteger:time forKey:@"login_push_history_enter_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)pushHistoryEnterTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"login_push_history_enter_time"];
}

- (void)setBootTime:(NSInteger)time
{
    TTLoginDialogModel *bootModel = [self bootModel];
    if(bootModel.action_tick.count <= 0) return;
    NSMutableDictionary *bootDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"login_boot_dict"]];
    if(!bootDict) {
        bootDict = [NSMutableDictionary dictionary];
    }
    NSString *currentBootDateKey = [self bootDateKey];
    [bootDict setValue:@(time) forKey:currentBootDateKey];
    [[NSUserDefaults standardUserDefaults] setObject:bootDict forKey:@"login_boot_dict"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)bootTime
{
    NSMutableDictionary *bootDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"login_boot_dict"]];
    if(!bootDict) {
        return 0;
    }
    NSString *currentBootDateKey = [self bootDateKey];
    BOOL contains = NO;
    NSArray *allKeys = bootDict.allKeys;
    for(NSString *bootDateKey in allKeys) {
        if([bootDateKey isEqualToString:currentBootDateKey]) {
            contains = YES;
            break;
        }
    }
    
    if(!contains) {  //不是当天了
        [bootDict removeAllObjects];
        [bootDict setValue:@(0) forKey:currentBootDateKey];
    }
    [[NSUserDefaults standardUserDefaults] setObject:bootDict forKey:@"login_boot_dict"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return ((NSNumber *)[bootDict objectForKey:currentBootDateKey]).integerValue;
}

- (void)setBootTotalTime:(NSInteger)bootTotalTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:bootTotalTime forKey:@"login_boot_total_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)bootTotalTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"login_boot_total_time"];
}

- (void)setDislikeTime:(NSInteger)time
{
    TTLoginDialogModel *dislikeModel = [self disLikeModel];
    if(dislikeModel.action_tick.count <= 0) return;
    [[NSUserDefaults standardUserDefaults] setInteger:time forKey:@"login_dislike_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)dislikeTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"login_dislike_time"];
}

- (void)setDislikeTotalTime:(NSInteger)dislikeTotalTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:dislikeTotalTime forKey:@"login_dislike_total_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)dislikeTotalTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"login_dislike_total_time"];
}

- (void)setMyFavorTotalTime:(NSInteger)myFavorTotalTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:myFavorTotalTime forKey:@"login_favor_total_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)myFavorTotalTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"login_favor_total_time"];
}

- (void)setPushHistoryTotalTime:(NSInteger)pushHistoryTotalTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:pushHistoryTotalTime forKey:@"login_push_history_total_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)pushHistoryTotalTime
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"login_push_history_total_time"];
}


- (void)setFeedDislikeTime
{
    if([TTAccountManager isLogin] || ![SSCommonLogic dislikeEnable]) return;
    NSInteger dislikeTime = [self dislikeTime];
    [self setDislikeTime:++dislikeTime];
    TTLoginDialogModel *disLike = [self disLikeModel];
    NSInteger currentDislikeTime = [self dislikeTime];
    for(NSNumber *time in disLike.action_tick) {
        if(currentDislikeTime == time.integerValue && disLike.action_type.integerValue == 2 && [self dislikeTotalTime] < disLike.action_total.integerValue) {
            [self showLoginDialogWithIsBoot:NO];
            break;
        }
    }

}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self loginStateChange];
}

- (void)showLoginDialogWithIsBoot:(BOOL)isBoot
{
    if(self.isShowingLoginDialog) return;
    self.isShowingLoginDialog = YES;
    TTAccountLoginAlertTitleType alertType = isBoot ? TTAccountLoginAlertTitleTypeBoot : TTAccountLoginAlertTitleTypeDislike;
    NSString *source = isBoot ? @"splash" : @"dislike";
    if(isBoot) {
        NSInteger bootTotalTime = [self bootTotalTime];
        [self setBootTotalTime:++bootTotalTime];
    } else {
        NSInteger dislikeTotalTime = [self dislikeTotalTime];
        [self setDislikeTotalTime:++dislikeTotalTime];
    }
    
    [TTAccountManager showLoginAlertWithType:alertType source:source completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if(type == TTAccountAlertCompletionEventTypeCancel || type == TTAccountAlertCompletionEventTypeDone) {
            self.isShowingLoginDialog = NO;
        } else if(type == TTAccountAlertCompletionEventTypeTip) {
            UINavigationController *nav = [((NewsBaseDelegate *)[[UIApplication sharedApplication] delegate]) appTopNavigationController];
            [TTAccountManager presentQuickLoginFromVC:nav type:TTAccountLoginDialogTitleTypeDefault source:source completion:nil];
        }
        
    }];
}

- (BOOL)myFavorShouldShowDialogIfNeeded
{
    if([TTAccountManager isLogin] || ![self myFavorEnable]) return NO;
    NSInteger myFavorTime = [self myFavorEnterTime];
    [self setMyFavorEnterTime:++myFavorTime];
    TTLoginDialogModel *myFavorModel = [self myFavorModel];
    if(self.isShowingLoginDialog) return NO;
    if([self myFavorTotalTime] < myFavorModel.action_total.integerValue && myFavorModel.action_type.integerValue == 2) {
        NSInteger currentMyFavorTime = [self myFavorEnterTime];
        for(NSNumber *time in myFavorModel.action_tick) {
            if(time.integerValue == currentMyFavorTime) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)pushHistoryShouldShowDialogIfNeeded
{
    if([TTAccountManager isLogin] || ![self pushHistoryEnable]) return NO;
    NSInteger pushHistoryTime = [self pushHistoryEnterTime];
    [self setPushHistoryEnterTime:++pushHistoryTime];
    TTLoginDialogModel *pushHistoryModel = [self pushHistoryModel];
    if(self.isShowingLoginDialog) return NO;
    if([self pushHistoryTotalTime] < pushHistoryModel.action_total.integerValue && pushHistoryModel.action_type.integerValue == 2) {
        NSInteger currentPushHistoryTime = [self pushHistoryEnterTime];
        for(NSNumber *time in pushHistoryModel.action_tick) {
            if(time.integerValue == currentPushHistoryTime) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)clearAllTimes
{
    [self setBootTime:0];
    [self setBootTotalTime:0];
    [self setDislikeTime:0];
    [self setDislikeTotalTime:0];
    [self setPushHistoryEnterTime:0];
    [self setPushHistoryTotalTime:0];
    [self setMyFavorEnterTime:0];
    [self setMyFavorTotalTime:0];
}

- (void)loginStateChange
{
    [self clearAllTimes];
}

- (NSString *)bootDateKey
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [dateFormatter stringFromDate:currentDate];
    return dateStr;
}

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self];
}


@end
