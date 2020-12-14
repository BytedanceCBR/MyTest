//
#import <BDTrackerProtocol/BDTrackerProtocol.h>
//  APNsManager.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "APNsManager.h"
#import "AppAlertManager.h"
#import "TTRoute.h"
#import "TTTrackerSessionHandler.h"
#import "TTStringHelper.h"
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "TTUserSettings/TTUserSettingsManager+Notification.h"
#import "TTUserSettings/TTUserSettingsHeader.h"
#import "TTUserSettings/TTUserSettingsReporter.h"
#import "TTNetworkManager.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHLocManager.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "FHEnvContext.h"
#import "JSONAdditions.h"
#import "FHBaseViewController.h"
#import "UIViewController+TTMovieUtil.h"
#import "FHIntroduceManager.h"
#import "TTPushServiceDelegate.h"
#import <BDALog/BDAgileLog.h>
#import "FHCHousePushUtils.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "HMDTTMonitor.h"
#import <ios_house_im/UIView+Utils.h>
#import <ByteDanceKit.h>
#import <objc/message.h>
#import "SSCommonLogic.h"
#import <ReactiveObjC.h>

extern NSString * const TTArticleTabBarControllerChangeSelectedIndexNotification;

@interface APNsManager ()
@end


@implementation APNsManager

static APNsManager *_sharedManager = nil;
+ (APNsManager *)sharedManager
{
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [[APNsManager alloc] init];
        }
    }
    
    return _sharedManager;
}

- (void)dealloc
{
}

#pragma mark - extended

- (void)trackWithPageName:(NSString *)pageName params:(NSDictionary *)params
{
    // could be extended
    NSString *value = nil;
    if ([params.allKeys containsObject:@"groupid"]) {
        value = [params objectForKey:@"groupid"];
    }
    [self sendTrackEvent:@"apn" lable:pageName value:value];
}

- (void)dealWithOpenURL:(NSString **)openURL
{
    // could be extended
    // removed by zjing
//    [[TSVPushLaunchManager sharedManager] launchIntoTSVTabIfNeedWithURL:*openURL];
}

- (BOOL)tryForOldAPNsLogical:(NSDictionary *)userInfo
{
    // could be extended
    return NO;
}

#pragma mark - public

- (void)writeLaunchLogEvent:(id)extGrowth badgeNumber:(NSInteger)badgeNumber
{
    NSString* launchType = @"click_news_notify";
    NSMutableDictionary *params = @{@"gd_label": launchType,
                                    @"tips": @(badgeNumber),
                                    @"event_type": @"house_app2c_v2"}.mutableCopy;
    if (extGrowth) {
        params[@"ext_growth"] = extGrowth;
    }
    [BDTrackerProtocol eventV3:@"launch_log" params:params];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    [[TTTrackerSessionHandler sharedHandler] setLaunchFrom:BDTrackerLaunchFromRemotePush];

    if (![[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        //正在展示隐私弹窗
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"reason"] = @"permission_popup_displaying";
        [[HMDTTMonitor defaultManager] hmdTrackService:@"f_apns_manager_push_vc_error"
                                                metric:nil
                                              category:nil
                                                 extra:params.copy];
        return;
    }
    //当push进来引导页已经在显示了，则关闭
    if([FHIntroduceManager sharedInstance].isShowing){
        [[FHIntroduceManager sharedInstance] hideIntroduceView];
    }
    //news_notification_view埋点，用户在后台点击推送时上报，如果有rid则上报rid
    NSString *rid = [userInfo btd_stringValueForKey:@"rid"];
    NSString *postBack = [userInfo btd_stringValueForKey:@"post_back"];
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [BDTrackerProtocol trackEventWithCustomKeys:@"apn" label:@"news_notification_view" value:rid source:nil extraDic:nil];
    }
 
    if ([self tryForOldAPNsLogical:userInfo]) {
        return;
    }
    
    if ([userInfo.allKeys containsObject:@"o_url"]) {
        NSString* openURL = [userInfo objectForKey:@"o_url"];
        NSURL *theUrl = [NSURL URLWithString:openURL];
        if (theUrl == nil) {
            theUrl = [NSURL btd_URLWithString:openURL];
        }

        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:theUrl];
        
        //对齐安卓逻辑
//        NSString *extGrowth = [paramObj.allParams valueForKey:@"ext_growth"] ?:@"be_null";
        NSDictionary *apsDict = [userInfo btd_dictionaryValueForKey:@"aps"];
        NSInteger badgeNumber = [apsDict[@"badge"]integerValue];
        [self writeLaunchLogEvent:[paramObj.allParams valueForKey:@"ext_growth"] badgeNumber:badgeNumber];
        
        if (!isEmptyString(paramObj.host)) {
            [self trackWithPageName:paramObj.host params:paramObj.queryParams];
        }

        //V3埋点
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:rid  == nil ? @"be_null" : rid forKey:@"rule_id"];
        [param setValue:@"notify" forKey:@"click_position"];
        [param setValue:postBack == nil ? @"be_null" : postBack forKey:@"post_back"];
        if ([paramObj.queryParams.allKeys containsObject:@"groupid"]) {
            NSString* value = [paramObj.queryParams objectForKey:@"groupid"];
            if (value != nil) {
                [param setValue:value forKey:@"group_id"];
            } else {
                [param setValue:@"be_null" forKey:@"group_id"];
            }
        }
        if ([paramObj.queryParams.allKeys containsObject:@"group_id"]) {
            NSString* value = [paramObj.queryParams objectForKey:@"group_id"];
            if (value != nil) {
                [param setValue:value forKey:@"group_id"];
            } else {
                [param setValue:@"be_null" forKey:@"group_id"];
            }
        }

        if ([[self class] f100ContentHasGroupId:paramObj.allParams]) {
            [param setValue:[[self class] f100ContentGroupId:paramObj.allParams] forKey:@"group_id"];
        }
        
        NSString *titleId = [NSString stringWithFormat:@"%@",paramObj.allParams[@"title_id"]];
        param[@"title_id"] = @([titleId longLongValue]);
        param[@"event_type"] = @"house_app2c_v2";

        [FHLocManager sharedInstance].isShowHomeViewController = NO;
        
        UIViewController *topVC = [UIViewController ttmu_currentViewController];
        if ([topVC isKindOfClass:[UIViewController class]]) {
            [topVC.view endEditing:YES];
        }
        
        //push进入设置这个值
        [FHEnvContext sharedInstance].enterChannel = @"push";

        NSString *appURL = paramObj.scheme;
        if (isEmptyString(appURL) || [TTRoute conformsToRouteWithScheme:appURL]) {
            
            [self dealWithOpenURL:&openURL];

            NSURL *handledOpenURL = [NSURL btd_URLWithString:openURL];
            
        [FHEnvContext sharedInstance].refreshConfigRequestType = @"link_launch";
        TTRouteUserInfo *userInfo = [FHCHousePushUtils getPushUserInfo:paramObj];
            if ([[handledOpenURL host] isEqualToString:@"main"]) {
                NSString * str = [openURL stringByAppendingString:@"&needToRoot=0"];
                handledOpenURL = [NSURL btd_URLWithString:str];
                [[TTRoute sharedRoute] openURL:handledOpenURL userInfo:userInfo objHandler:nil];
//                TTRouteParamObj* obj = [[TTRoute sharedRoute] routeParamObjWithURL:handledOpenURL];
//                NSDictionary* params = [obj queryParams];
//                if (params != nil) {
//                    NSString* target = params[@"select_tab"];
//                    if (target != nil && target.length > 0) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:@{@"tag": target}];
//                    } else {
//                        NSAssert(false, @"推送消息的tag为空");
//                    }
//                    
            } else {
                // Push同一种页面处理
                /* 需求未明确 先注释吧
                UIViewController *topVC = [UIViewController ttmu_currentViewController];
                if ([topVC isKindOfClass:[FHBaseViewController class]]) {
                    BOOL retFlag = [(FHBaseViewController *)topVC isSamePageAndParams:handledOpenURL];
                    if (retFlag) {
                        return;
                    }
                }
                 */
                
                id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
                [envBridge setTraceValue:@"push" forKey:@"origin_from"];
                [envBridge setTraceValue:@"be_null" forKey:@"origin_search_id"];
                

                float fSystemVersion = [[UIDevice currentDevice].systemVersion floatValue];
                if (fSystemVersion >= 10.0 && fSystemVersion < 11.0) { // 10.0
                    userInfo.animated = @(0);
                }
                
                BOOL ret = [[TTRoute sharedRoute] openURLByPushViewController:handledOpenURL userInfo:userInfo];
                
                // 如果没有跳转成功，添加监控
                BOOL isMonitorEnable = ![SSCommonLogic isDisableMonitorPushJumpError];
                if(isMonitorEnable && !ret) {
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    
                    // 检查是否URL可以跳转
                    BOOL canOpenUrl = [[TTRoute sharedRoute] canOpenURL:handledOpenURL];
                    params[@"canOpenUrl"] = @(canOpenUrl);
                    
                    // 检查跳转目标是否有效
                    TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:handledOpenURL userInfo:userInfo];
                    if(routeObj) {
                        params[@"routeObj"] = routeObj.instance ? NSStringFromClass(routeObj.instance.class) : @"routeObj.instance is empty";
                        params[@"allParams"] = routeObj.paramObj.allParams;
                    }
                    else {
                        params[@"routeObj"] = @"empty object";
                    }

                    // 检查导航控制器是否存在
                    TTRoute *route = [TTRoute sharedRoute];
                    UINavigationController * navVC = ((UINavigationController* (*)(id, SEL))objc_msgSend)(route, NSSelectorFromString(@"_navigationControllerForRoute"));
                    params[@"navVC"] = navVC ? NSStringFromClass(navVC.class) : @"be_null";
                    
                    if(!navVC) {
                        // 业务提供的导航控制器是否为空
                        UINavigationController *designatedNavVC = [route.designatedNavDatasource designatedRouteNavigationController];
                        params[@"designatedNavDatasource"] = route.designatedNavDatasource ? NSStringFromClass(route.designatedNavDatasource.class) : @"be_null";
                        params[@"desinatedRouteNavVC"] = designatedNavVC ? NSStringFromClass(designatedNavVC.class) : @"be_null";
                        
                        // 初始化默认导航控制器是否为空
                        UINavigationController *initialRouteNavigationController = route.initialRouteNavigationController;
                        params[@"initialRouteNavigationController"] = initialRouteNavigationController ? NSStringFromClass(initialRouteNavigationController.class) : @"be_null";
                        
                        // 通知响应链获取的顶部导航控制器是否为空
                        UINavigationController *topMostNavVC = ((UINavigationController* (*)(id, SEL))objc_msgSend)(route, NSSelectorFromString(@"_topMostNavigationController"));
                        params[@"topMostNavVC"] = topMostNavVC ? NSStringFromClass(topMostNavVC.class) : @"be_null";
                        
                        // 兜底逻辑，如果是由于导航控制器没有找到，则重试一次
                        [[[RACObserve(route, designatedNavDatasource) distinctUntilChanged] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
                            [[TTRoute sharedRoute] openURLByPushViewController:handledOpenURL userInfo:userInfo];
                        }];
                    }

                    // 上报收集的信息
                    params[@"handledOpenUrl"] = handledOpenURL.absoluteString;
                    params[@"push_user_info"] = userInfo.allInfo;
                    [[HMDTTMonitor defaultManager] hmdTrackService:@"f_apns_manager_push_vc_error"
                                                            metric:nil
                                                          category:nil
                                                             extra:params.copy];
                }
            }
        }
        else {
            NSURL *pushURL = [NSURL btd_URLWithString:openURL];
            if (pushURL) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:pushURL options:@{} completionHandler:^(BOOL success) {
                        if (!success) {
                            BDALOG_INFO(@"can't open %@, 第三方APP没有注册URL Scheme", openURL);
                        }
                    }];
                }else {
                    if ([[UIApplication sharedApplication] canOpenURL:pushURL]) {
                        [[UIApplication sharedApplication] openURL:pushURL];
                    }
                }
            }
        }
    }
    else if ([userInfo.allKeys containsObject:@"action"]) {
        [[AppAlertManager alertManager] startAlertWithLocalResult:userInfo];
        [self sendTrackEvent:@"apn" lable:@"download" value:[userInfo objectForKey:@"action"]];
    }
    else {
        [self sendTrackEvent:@"apn" lable:@"recall" value:nil];
    }
}

+(BOOL)f100ContentHasGroupId:(NSDictionary*)userInfo {
    NSArray* allKeys = [userInfo allKeys];
    return [allKeys containsObject:@"neighborhood_id"] ||
        [allKeys containsObject:@"court_id"] ||
        [allKeys containsObject:@"house_id"];
}

+(NSString*)f100ContentGroupId:(NSDictionary*)userInfo {
    NSArray* allKeys = [userInfo allKeys];
    if ([allKeys containsObject:@"neighborhood_id"]) {
        return userInfo[@"neighborhood_id"];
    } else if ([allKeys containsObject:@"court_id"]) {
        return userInfo[@"court_id"];
    } else if ([allKeys containsObject:@"house_id"]) {
        return userInfo[@"house_id"];
    }
    return @"be_null";
}

- (void)sendAppNoticeStatus
{
    // 注意：根据 app_notice_status api 的定义，close 发送 1，open 发送 0
    // 这个是早期的api，根据server数据库的定义，0为有效值
    [BDUGPushService uploadNotificationStatus:[NSString stringWithFormat:@"%d",[TTUserSettingsManager apnsNewAlertClosed]]];

    // 注意：根据 collect_setting api 的定义，close 发送 0，open 发送 1，和 app_notice_status 相反
    NSNumber *apnNotifyValue = @1;
    if ([TTUserSettingsManager apnsNewAlertClosed]) apnNotifyValue = @0;
    
    [[TTUserSettingsReporter sharedInstance] addConfigurationValue:apnNotifyValue key:kConfigAPNNotify];
}

- (void)sendTrackEvent:(NSString *)event lable:(NSString *)label value:(NSString *)valueString
{
    if (isEmptyString(event)) {
        return;
    }
    
    if (!isEmptyString(label) && !isEmptyString(valueString)) {
        [TTTrackerWrapper eventData:@{
         @"category" : @"umeng",
         @"tag" : event,
         @"label" : label,
         @"value" : valueString}];
    }
    else {
        [BDTrackerProtocol event:event label:label];
    }
}

@end
