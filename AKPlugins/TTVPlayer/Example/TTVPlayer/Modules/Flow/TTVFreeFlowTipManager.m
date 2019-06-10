//
//  TTFreeFlowTipManager.m
//  Article
//
//  Created by wangdi on 2017/7/7.
//
//

#import "TTVFreeFlowTipManager.h"
#import "TTThemedAlertController.h"
#import "TTVFlowStatisticsManager.h"
#import <NetworkUtilities.h>
#import "TTModuleBridge.h"
#import <XGUIWidget/SSAppPageManager.h>
#import <TTURLUtils.h>

static NSString * const kFreeFlowExcessKey = @"freeFlowExcessKey";
static NSString * const kFreeFlowExcessCriticalValueKey = @"freeFlowExcessCriticalValueKey";

@implementation TTVFreeFlowTipManager
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
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTFreeFlowTipManager.shouldShowPullRefreshTip" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        return @([[TTVFreeFlowTipManager sharedInstance] shouldShowPullRefreshTip]);
    }];
}

- (void)showHomeFlowAlert
{
    NSInteger critivalValue = [[TTVFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] > 0 ? [[TTVFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] : 300 * 1024;
    if([self shouldShowExcessCriticalValueAlert]) {
        [self showAlertViewWithTitle:[NSString stringWithFormat:@"本月免流量套餐已不足%zdMB，超过限制后将消耗正常流量",critivalValue / 1024] isCriticalValue:YES];
        [TTVTracker eventV3:@"data_package_running_out_show" params:nil];
        return;
    }
    if([self shouldShowExcessAlert]) {
        [self showAlertViewWithTitle:@"本月免流量已超上限，后续将消耗正常流量" isCriticalValue:NO];
        [TTVTracker eventV3:@"data_package_useout_show" params:nil];
    }
}


- (BOOL)shouldShowPullRefreshTip
{
    BOOL isOpen = [[TTVFlowStatisticsManager sharedInstance] isOpenFreeFlow];
    BOOL isSupport = [[TTVFlowStatisticsManager sharedInstance] isSupportFreeFlow];
    BOOL isEnable = [[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable];
    BOOL isExcess = [[TTVFlowStatisticsManager sharedInstance] isExcessFlow];
    BOOL isConnection = TTNetworkConnected();
    BOOL isWifi = TTNetworkWifiConnected();
    return isOpen && isSupport && isEnable && !isExcess && isConnection && !isWifi;
}


- (BOOL)shouldShowExcessCriticalValueAlert
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kFreeFlowExcessCriticalValueKey]];
    if(!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    NSString *dateStr = [self dateStrWithDate: [[TTVFlowStatisticsManager sharedInstance] recentUpdateDataTime]];
    BOOL hasShow = [[dict valueForKey:dateStr] integerValue];
    if(hasShow) return NO;
    BOOL isEnable = [[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable];
    BOOL isSupport = [[TTVFlowStatisticsManager sharedInstance] isSupportFreeFlow];
    BOOL isOpen = [[TTVFlowStatisticsManager sharedInstance] isOpenFreeFlow];
    NSInteger critivalValue = [[TTVFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] > 0 ? [[TTVFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] : 300 * 1024;
    BOOL isExcessCriticalValue = [[TTVFlowStatisticsManager sharedInstance] isExcessCriticalValueFlow:critivalValue];
    BOOL isConnection = TTNetworkConnected();
    BOOL isWifi = TTNetworkWifiConnected();
    BOOL isExcess = [[TTVFlowStatisticsManager sharedInstance] isExcessFlow];
    BOOL shouldShow = isEnable && isExcessCriticalValue && isSupport && isOpen && isConnection && !isWifi && !isExcess;
    if(shouldShow) {
        [dict removeAllObjects];
        [dict setValue:@(YES) forKey:dateStr];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kFreeFlowExcessCriticalValueKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return shouldShow;
}

- (BOOL)shouldShowExcessAlert
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kFreeFlowExcessKey]];
    if(!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    NSString *dateStr = [self dateStrWithDate: [[TTVFlowStatisticsManager sharedInstance] recentUpdateDataTime]];
    BOOL hasShow = [[dict valueForKey:dateStr] integerValue];
    if(hasShow) return NO;
    BOOL isEnable = [[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable];
    BOOL isSupport = [[TTVFlowStatisticsManager sharedInstance] isSupportFreeFlow];
    BOOL isOpen = [[TTVFlowStatisticsManager sharedInstance] isOpenFreeFlow];
    BOOL isExcess = [[TTVFlowStatisticsManager sharedInstance] isExcessFlow];
    BOOL isConnection = TTNetworkConnected();
    BOOL isWifi = TTNetworkWifiConnected();
    BOOL shouldShow =  isEnable && isExcess && isSupport && isOpen && isConnection && !isWifi;
    if(shouldShow) {
        [dict removeAllObjects];
        [dict setValue:@(YES) forKey:dateStr];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kFreeFlowExcessKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return shouldShow;
}

- (NSString *)dateStrWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM";
    return [dateFormatter stringFromDate:date];
}

- (void)showAlertViewWithTitle:(NSString *)title isCriticalValue:(BOOL)isCritivalValue
{
    TTThemedAlertController *alert = nil;
    if(isCritivalValue) {
        alert = [[TTThemedAlertController alloc] initWithTitle:@"免流量套餐余量提醒" message:title preferredType:TTThemedAlertControllerTypeAlert];
    } else {
        alert = [[TTThemedAlertController alloc] initWithTitle:title message:nil preferredType:TTThemedAlertControllerTypeAlert];
    }
    [alert addActionWithTitle:@"关闭" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        if(isCritivalValue) {
            [TTVTracker eventV3:@"data_package_running_out_close" params:nil];
        } else {
            [TTVTracker eventV3:@"data_package_useout_close" params:nil];
        }
    }];
    [alert addActionWithTitle:@"查看详情" actionType:TTThemedAlertActionTypeNormal  actionBlock:^{
        NSURL *url = [NSURL URLWithString:[[TTVFlowStatisticsManager sharedInstance] freeFlowEntranceURL]];
        typedef NSDictionary* (^JSCallHandler)(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback);
        JSCallHandler handler = ^NSDictionary *(NSString * callbackId, NSDictionary* result, NSString *JSSDKVersion, BOOL * executeCallback) {
            [[TTVFlowStatisticsManager sharedInstance] setFlowData:result];
            *executeCallback = NO;
            return nil;
        };
        // 跳转
        [[SSAppPageManager sharedManager] openURL:url baseCondition:@{@"JSCallHandler": @{@"TTRFlowStatistics.flowStatistics": [handler copy]}}];
        if(isCritivalValue) {
            [TTVTracker eventV3:@"data_package_running_out_view" params:nil];
        } else {
            [TTVTracker eventV3:@"data_package_useout_view" params:nil];
        }
    }];
    UINavigationController *nav = [[self class] topNavigationControllerFromRoot:[UIApplication sharedApplication].keyWindow.rootViewController];
    [alert showFrom:nav animated:YES];

}

// 找到最上层的 navi controller
+ (UINavigationController *)topNavigationControllerFromRoot:(UIViewController *)rootVC {
    if ([rootVC presentedViewController]) {
        
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        return [[self class] topNavigationControllerFromRoot:rootVC];
    }
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)rootVC;
    }
    
    return nil;
}



+ (BOOL)ttv_getCommonState {
    
    return (
            [[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [[TTVFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
            [[TTVFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
            ![[TTVFlowStatisticsManager sharedInstance] isExcessFlow] &&
            TTNetworkConnected() &&
            !TTNetworkWifiConnected());
}

+ (BOOL)shouldShowFreeFlowSubscribeTip {
    return (
            [[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [[TTVFlowStatisticsManager sharedInstance] flowOrderEntranceEnable] &&
            [[TTVFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
            ![[TTVFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
            TTNetworkConnected() &&
            !TTNetworkWifiConnected());
}

+ (BOOL)shouldShowWillOverFlowTip:(CGFloat)videoSize
{
    return ([self ttv_getCommonState] &&
            [[TTVFlowStatisticsManager sharedInstance] isExcessFlowWithSize:videoSize]);
}

+ (BOOL)shouldShowFreeFlowToastTip:(CGFloat)videoSize {
    
    return ([self ttv_getCommonState] &&
            ![[TTVFlowStatisticsManager sharedInstance] isExcessFlowWithSize:videoSize]);
}

+ (BOOL)shouldShowFreeFlowLoadingTip {
    return ([self ttv_getCommonState]);
}

//+ (BOOL)shouldSwithToHDForFreeFlow {
//    
//    return ([self ttv_getCommonState] &&
//            ![TTVResolutionStore sharedInstance].userSelected);
//}

+ (BOOL)shouldShowDidOverFlowTip {
    return (
            [[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [[TTVFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
            [[TTVFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
            [[TTVFlowStatisticsManager sharedInstance] isExcessFlow] &&
            TTNetworkConnected() &&
            !TTNetworkWifiConnected());
}

+ (NSString *)getSubscribeTitleTextWithVideoSize:(CGFloat)videoSize {
    
    NSString *text = [[TTVFlowStatisticsManager sharedInstance] flowReminderTitle];
    
    if (isEmptyString(text)) {
        text = [NSString stringWithFormat:@"播放将消耗%.2fMB流量\n如何免流量看视频？订购「专属流量包」", videoSize];
    } else {
        text = [text stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%.2f", videoSize]];
    }
    
    return text;
}

+ (NSString *)getSubcribeButtonText {
    
    NSString *text = [[TTVFlowStatisticsManager sharedInstance] orderButtonTitle];
    
    return (isEmptyString(text)) ? @"我要订购": text;
}

@end
