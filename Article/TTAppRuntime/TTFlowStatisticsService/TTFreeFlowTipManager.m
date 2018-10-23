//
//  TTFreeFlowTipManager.m
//  Article
//
//  Created by wangdi on 2017/7/7.
//
//

#import "TTFreeFlowTipManager.h"
#import "TTThemedAlertController.h"
#import "NewsBaseDelegate.h"
#import "TTRouteService.h"
#import "TTFlowStatisticsManager.h"
#import <NetworkUtilities.h>
#import "TTModuleBridge.h"

static NSString * const kFreeFlowExcessKey = @"freeFlowExcessKey";
static NSString * const kFreeFlowExcessCriticalValueKey = @"freeFlowExcessCriticalValueKey";

@implementation TTFreeFlowTipManager
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
        return @([[TTFreeFlowTipManager sharedInstance] shouldShowPullRefreshTip]);
    }];
}

- (void)showHomeFlowAlert
{
    NSInteger critivalValue = [[TTFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] > 0 ? [[TTFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] : 300 * 1024;
    if([self shouldShowExcessCriticalValueAlert]) {
        [self showAlertViewWithTitle:[NSString stringWithFormat:@"本月免流量套餐已不足%zdMB，超过限制后将消耗正常流量",critivalValue / 1024] isCriticalValue:YES];
        [TTTrackerWrapper eventV3:@"data_package_running_out_show" params:nil];
        return;
    }
    if([self shouldShowExcessAlert]) {
        [self showAlertViewWithTitle:@"本月免流量已超上限，后续将消耗正常流量" isCriticalValue:NO];
        [TTTrackerWrapper eventV3:@"data_package_useout_show" params:nil];
    }
}


- (BOOL)shouldShowPullRefreshTip
{
    BOOL isOpen = [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow];
    BOOL isSupport = [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow];
    BOOL isEnable = [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable];
    BOOL isExcess = [[TTFlowStatisticsManager sharedInstance] isExcessFlow];
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
    NSString *dateStr = [self dateStrWithDate: [[TTFlowStatisticsManager sharedInstance] recentUpdateDataTime]];
    BOOL hasShow = [[dict valueForKey:dateStr] integerValue];
    if(hasShow) return NO;
    BOOL isEnable = [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable];
    BOOL isSupport = [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow];
    BOOL isOpen = [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow];
    NSInteger critivalValue = [[TTFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] > 0 ? [[TTFlowStatisticsManager sharedInstance] flowStatisticsRemainTipValue] : 300 * 1024;
    BOOL isExcessCriticalValue = [[TTFlowStatisticsManager sharedInstance] isExcessCriticalValueFlow:critivalValue];
    BOOL isConnection = TTNetworkConnected();
    BOOL isWifi = TTNetworkWifiConnected();
    BOOL isExcess = [[TTFlowStatisticsManager sharedInstance] isExcessFlow];
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
    NSString *dateStr = [self dateStrWithDate: [[TTFlowStatisticsManager sharedInstance] recentUpdateDataTime]];
    BOOL hasShow = [[dict valueForKey:dateStr] integerValue];
    if(hasShow) return NO;
    BOOL isEnable = [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable];
    BOOL isSupport = [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow];
    BOOL isOpen = [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow];
    BOOL isExcess = [[TTFlowStatisticsManager sharedInstance] isExcessFlow];
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
            [TTTrackerWrapper eventV3:@"data_package_running_out_close" params:nil];
        } else {
            [TTTrackerWrapper eventV3:@"data_package_useout_close" params:nil];
        }
    }];
     [alert addActionWithTitle:@"查看详情" actionType:TTThemedAlertActionTypeNormal  actionBlock:^{
         NSURL *url = [NSURL URLWithString:[[TTFlowStatisticsManager sharedInstance] freeFlowEntranceURL]];
         [[TTRoute sharedRoute] openURLByPushViewController:url];
         if(isCritivalValue) {
             [TTTrackerWrapper eventV3:@"data_package_running_out_view" params:nil];
         } else {
             [TTTrackerWrapper eventV3:@"data_package_useout_view" params:nil];
         }
     }];
    UINavigationController *nav = [((NewsBaseDelegate *)[[UIApplication sharedApplication] delegate]) appTopNavigationController];
     [alert showFrom:nav animated:YES];

}
@end
