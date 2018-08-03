//
//  APNsManager.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "APNsManager.h"
#import "AppAlertManager.h"
#import "TTRoute.h"
#import "TTInstallIDManager.h"
#import "CommonURLSetting.h"
#import "TTTrackerSessionHandler.h"
#import "TTStringHelper.h"
#import "TTSingleResponseModel.h"
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "TTUserSettings/TTUserSettingsManager+Notification.h"
#import "TTUserSettings/TTUserSettingsHeader.h"
#import "TTUserSettings/TTUserSettingsReporter.h"

#import "TTNetworkManager.h"
#import "TouTiaoPushSDK.h"
//#import "TTSFShareManager.h"

#import "TSVPushLaunchManager.h"

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
    [[TSVPushLaunchManager sharedManager] launchIntoTSVTabIfNeedWithURL:*openURL];
}

- (BOOL)tryForOldAPNsLogical:(NSDictionary *)userInfo
{
    // could be extended
    return NO;
}

#pragma mark - public

- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    
    //news_notification_view埋点，用户在后台点击推送时上报，如果有rid则上报rid
    NSString *rid = [userInfo tt_stringValueForKey:@"rid"];
    NSString *postBack = [userInfo tt_stringValueForKey:@"post_back"];
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEventWithCustomKeys(@"apn", @"news_notification_view", rid, nil, nil);
    }
    
    //V3埋点
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
//    [params setValue:rid forKey:@"rule_id"];
//    [params setValue:@"notify" forKey:@"click_position"];
//    [TTTrackerWrapper eventV3:@"push_click" params:[params copy] isDoubleSending:YES];
    
    [TouTiaoPushSDK trackerWithRuleId:rid clickPosition:@"notify" postBack:postBack];
    
    [[TTTrackerSessionHandler sharedHandler] setLaunchFrom:TTTrackerLaunchFromRemotePush];
    
    if ([self tryForOldAPNsLogical:userInfo]) {
        return;
    }
    
    if ([userInfo.allKeys containsObject:@"o_url"]) {
        NSString *openURL = [userInfo objectForKey:@"o_url"];
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:openURL]];
        if (!isEmptyString(paramObj.host)) {
            [self trackWithPageName:paramObj.host params:paramObj.queryParams];
        }
        
        NSString *appURL = paramObj.scheme;
        if (isEmptyString(appURL) || [TTRoute conformsToRouteWithScheme:appURL]) {
            
            [self dealWithOpenURL:&openURL];
            
            NSURL *handledOpenURL = [TTStringHelper URLWithURLString:openURL];
            [[TTRoute sharedRoute] openURLByPushViewController:handledOpenURL];
        }
        else {
            if ([[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:openURL]]) {
                [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:openURL]];
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

- (void)sendAppNoticeStatus
{
    // 注意：根据 app_notice_status api 的定义，close 发送 1，open 发送 0
    // 这个是早期的api，根据server数据库的定义，0为有效值
    
    if(![SSCommonLogic pushSDKEnable]) {
        NSMutableString *tURL = [NSMutableString stringWithFormat:@"%@?notice=%d", [CommonURLSetting appNoticeStatusURLString], [TTUserSettingsManager apnsNewAlertClosed]];
        if(!isEmptyString([[TTInstallIDManager sharedInstance] deviceID])) {
            [tURL appendFormat:@"&device_id=%@", [[TTInstallIDManager sharedInstance] deviceID]];
        }
        
        [[TTNetworkManager shareInstance] requestForJSONWithURL:tURL params:nil method:@"GET" needCommonParams:YES callback:NULL];

    } else {
        TTUploadSwitchRequestParam *param = [TTUploadSwitchRequestParam requestParam];
        param.notice = [NSString stringWithFormat:@"%d",[TTUserSettingsManager apnsNewAlertClosed]];
        [TouTiaoPushSDK sendRequestWithParam:param completionHandler:nil];
    }
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
        wrapperTrackEvent(event, label);
    }
}

@end
