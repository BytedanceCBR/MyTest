//
//  FHRNBridgePlugin.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/27.
//

#import "FHRNBridgePlugin.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <FHEnvContext.h>
#import "NSDictionary+TTAdditions.h"
#import "FHRNHTTPRequestSerializer.h"
#import "TTBridgeRegister.h"
#import "TTBridgeDefines.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import <FHRNBaseViewController.h>
#import <UIViewController+Refresh_ErrorHandler.h>
#import <FHEnvContext.h>
#import "NSDictionary+TTAdditions.h"
#import "FHUtils.h"
#import <HMDTTMonitor.h>
#import "UIViewController+NavigationBarStyle.h"
#import "FHHousePhoneCallUtils.h"
#import "FHHouseFollowUpHelper.h"
#import "TTSandBoxHelper.h"
#import "NetworkUtilities.h"
#import "TTInstallIDManager.h"
#import "TTAccount.h"
#import <ToastManager.h>

@interface FHRNBridgePlugin ()
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, assign) BOOL canOpenJump;
@end

@implementation FHRNBridgePlugin

+ (TTBridgeInstanceType)instanceType {
    return TTBridgeInstanceTypeAssociated;
}

+ (void)load {
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, appInfo), @"app.appInfo");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, log_v3), @"app.log_v3");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, close), @"app.close");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, load_finish), @"app.load_finish");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, enable_swipe), @"app.enable_swipe");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, disable_swipe), @"app.disable_swipe");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, monitor_common_log), @"monitor_common_log");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, monitor_duration), @"monitor_duration");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, call_phone), @"app.call_phone");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, open), @"app.open");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, alertTest), @"app.alertTest");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, toast), @"app.toast");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, fetch), @"app.fetch");
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, fetch), @"app.map");
}

- (void)toastWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    NSString *title = [param tt_stringValueForKey:@"title"];
    
    if ([title isKindOfClass:[NSString class]] && title.length > 0) {
        [[ToastManager manager] showToast:title];
    }
}

- (void)mapWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    
}

- (void)appInfoWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    NSString *appName = [TTSandBoxHelper appName]?:@"f101";
    [data setValue:appName forKey:@"appName"];
    [data setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"] forKey:@"innerAppName"];
    [data setValue:[TTSandBoxHelper versionName] forKey:@"appVersion"];
    [data setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    NSString *netType = nil;
    if(TTNetworkWifiConnected()) {
        netType = @"WIFI";
    } else if(TTNetwork4GConnected()) {
        netType = @"4G";
    } else if(TTNetwork4GConnected()) {
        netType = @"3G";
    } else if(TTNetworkConnected()) {
        netType = @"MOBILE";
    }
    
    //无网判断
    NSString *netAvailable = TTNetworkConnected() ? @"1" : @"0";
    [data setValue:netAvailable forKey:@"netAvailable"];
    
    [data setValue:netType forKey:@"netType"];
    
    NSString *deviceID  = [[TTInstallIDManager sharedInstance] deviceID];
    if(!isEmptyString(deviceID)) {
        [data setValue:deviceID forKey:@"device_id"];
    }
    
    NSString *uid = [[TTAccount sharedAccount] userIdString];
    if (uid) {
        [data setValue:uid forKey:@"user_id"];
    }
    
    BOOL isLogin = [[TTAccount sharedAccount] isLogin];
    [data setValue:isLogin ? @(1) : @(0) forKey:@"is_login"];
    
    
    NSString *idfaString = [TTDeviceHelper idfaString];
    [data setValue:idfaString forKey:@"idfa"];
    
    if (callback) {
        callback(TTBridgeMsgSuccess, data,nil);
    }
}

- (void)call_phoneWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    
    NSString *houseType = [param tt_stringValueForKey:@"houseType"];
    NSString *realtorId = [param tt_stringValueForKey:@"realtorId"];

    //    NSString *reportParams = [param tt_stringValueForKey:@"report_params"];
    NSString *reportParamsStr = [param tt_stringValueForKey:@"report_params"];
    NSMutableString *processString = [NSMutableString stringWithString:reportParamsStr];
    NSString *character = nil;
    for (int i = 0; i < processString.length; i ++) {
        character = [processString substringWithRange:NSMakeRange(i, 1)];
        
        if ([character isEqualToString:@"\\"])
            [processString deleteCharactersInRange:NSMakeRange(i, 1)];
    }
    
    NSDictionary *reportParamsDict = [FHUtils dictionaryWithJsonString:processString];
    NSMutableDictionary *callParams = [NSMutableDictionary new];
    
    if ([param isKindOfClass:[NSDictionary class]]) {
        [callParams addEntriesFromDictionary:param];
    }
    
    if ([reportParamsDict isKindOfClass:[NSDictionary class]]) {
        [callParams addEntriesFromDictionary:reportParamsDict];
    }
    if (realtorId) {
        [callParams setValue:realtorId forKey:@"realtor_id"];
    }
    if (houseType) {
        [callParams setValue:houseType forKey:@"house_type"];
    }
    
//    if([callParams[@"group_id"] isKindOfClass:[NSString class]])
//    {
//        if (![callParams[@"group_id"] isEqualToString:@"be_null"]) {
//            callParams[@"follow_id"] = callParams[@"group_id"];
//        }
//    }
    
//    if([callParams[@"group_id"] isKindOfClass:[NSString class]])
//    {
//        if (![callParams[@"group_id"] isEqualToString:@"be_null"]) {
//            callParams[@"house_id"] = callParams[@"group_id"];
//        }
//    }
//
    
    if ([callParams[@"log_pb"] isKindOfClass:[NSString class]]) {
        callParams[@"log_pb"] = [FHUtils dictionaryWithJsonString:callParams[@"log_pb"]];
    }
    callParams[@"from"] = @"app_realtor_mainpage";
    [FHHousePhoneCallUtils callWithConfig:callParams completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
        if (callback) {
            callback(TTBridgeMsgSuccess, nil,nil);
        }
    }];
    
    if (callParams[@"follow_id"]) {
        callParams[@"hide_toast"] = @(YES);
        [FHHouseFollowUpHelper silentFollowHouseWithConfig:callParams];
    }
    
}

- (void)monitor_durationWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    
}

- (void)monitor_common_logWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    NSString *logService = [param tt_stringValueForKey:@"name"];
    if (logService) {
        [[HMDTTMonitor defaultManager] hmdTrackService:logService status:0 extra:param];
    }
}

- (void)disable_swipeWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    UINavigationController *topVC = [TTUIResponderHelper correctTopNavigationControllerFor:controller];
    UIViewController *currentVC = nil;
    if ([[topVC.viewControllers lastObject] isKindOfClass:[FHRNBaseViewController class]]) {
        currentVC = [topVC.viewControllers lastObject];
        currentVC.ttDisableDragBack = YES;
    }
}

- (void)enable_swipeWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    UINavigationController *topVC = [TTUIResponderHelper correctTopNavigationControllerFor:controller];
    UIViewController *currentVC = nil;
    if ([[topVC.viewControllers lastObject] isKindOfClass:[FHRNBaseViewController class]]) {
        currentVC = [topVC.viewControllers lastObject];
        currentVC.ttDisableDragBack = NO;
    }
}

- (void)load_finishWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    UINavigationController *topVC = [TTUIResponderHelper correctTopNavigationControllerFor:controller];
    UIViewController *currentVC = nil;
    if ([[topVC.viewControllers lastObject] isKindOfClass:[FHRNBaseViewController class]]) {
        currentVC = [topVC.viewControllers lastObject];
        ((FHRNBaseViewController *)currentVC).isLoadFinish = YES;
        [currentVC tt_endUpdataData];
    }
    
    if ([[topVC.viewControllers lastObject] respondsToSelector:@selector(updateLoadFinish)]) {
        [[topVC.viewControllers lastObject] performSelector:@selector(updateLoadFinish) withObject:nil];
    }
}

- (void)log_v3WithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSString *paramsEvent = [param tt_stringValueForKey:@"event"];
        if (paramsEvent) {
            NSString *paramsTrace = param[@"params"];
            if ([paramsTrace isKindOfClass:[NSDictionary class]]) {
                [FHEnvContext recordEvent:paramsTrace andEventKey:paramsEvent];
            }else if ([paramsTrace isKindOfClass:[NSString class]]) {
                NSDictionary *dictTrace =  [FHUtils dictionaryWithJsonString:paramsTrace];
                if (dictTrace) {
                    [FHEnvContext recordEvent:dictTrace andEventKey:paramsEvent];
                }
            }
        }
    }
}

- (void)closeWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    
}

- (void)fetchWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    
    if (!TTNetworkConnected()) {
        NSString *stringRes = @"\{\"message\": \"failed\"\}";
        callback(TTBridgeMsgSuccess, @{ @"response": stringRes, @"status": @(0),
                                        @"code":@(0)},nil);
        return;
    }
    
    NSString *url = [param tt_stringValueForKey:@"url"];
    NSString *method = [param stringValueForKey:@"method" defaultValue:@"GET"];
    method = [method.uppercaseString isEqualToString:@"POST"]? @"POST": @"GET";
    
    NSDictionary *header = [param tt_dictionaryValueForKey:@"header"];
    NSString *stringKey = [method isEqualToString:@"GET"] ? @"params" : @"data";
    
    NSDictionary *params = [param tt_objectForKey:stringKey];
    
    BOOL needCommonParams = [param tt_boolValueForKey:@"needCommonParams"];
    
    if (!url.length) {
        TTBRIDGE_CALLBACK_WITH_MSG(TTBridgeMsgFailed, @"url不能为空");
        return;
    }
    
    if (![params isKindOfClass:[NSDictionary class]]) {
        if ([params isKindOfClass:[NSString class]]) {
            NSString *stringJson = (NSString *)params;
            //json字符串
            NSData *jsonData = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(!err){
                params = dic;
            }
        }else
        {
            return;
        }
    }
    
    NSString *startTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    if ([method isEqualToString:@"GET"]) {
        [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:method needCommonParams:needCommonParams callback:^(NSError *error, id obj, TTHttpResponse *response) {
            NSString *result = @"";
            
            if([obj isKindOfClass:[NSData class]]){
                result = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            }
            
            if (!result || error) {
                result = @"\{\"message\": \"failed\"\}";
            }
            
            NSMutableDictionary *resultDict = [NSMutableDictionary new];
            [resultDict setValue:(response.allHeaderFields ? response.allHeaderFields : @"") forKey:@"headers"];
            [resultDict setValue:result forKey:@"response"];
            [resultDict setValue:@(response.statusCode) forKey:@"status"];
            [resultDict setValue:error?@(0): @(1) forKey:@"code"];
            [resultDict setValue:startTime forKey:@"beginReqNetTime"];
            
            if (callback) {
                callback(TTBridgeMsgSuccess, resultDict,nil);
            }
        }];
    }else
    {
        [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:method needCommonParams:needCommonParams requestSerializer:[FHRNHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
            if (callback) {
                NSString *result = @"";
                if([obj isKindOfClass:[NSData class]]){
                    result = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                }
                
                if (!result || error) {
                    result = @"\{\"message\": \"failed\"\}";
                }
                
                NSMutableDictionary *resultDict = [NSMutableDictionary new];
                [resultDict setValue:(response.allHeaderFields ? response.allHeaderFields : @"") forKey:@"headers"];
                [resultDict setValue:result forKey:@"response"];
                [resultDict setValue:@(response.statusCode) forKey:@"status"];
                [resultDict setValue:error?@(0): @(1) forKey:@"code"];
                [resultDict setValue:startTime forKey:@"beginReqNetTime"];
                
                callback(TTBridgeMsgSuccess, resultDict,nil);
            }
        }];
    }
}

- (void)openWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    UINavigationController *topVC = [TTUIResponderHelper correctTopNavigationControllerFor:controller];
    UIViewController *currentVC = nil;
    if ([[topVC.viewControllers lastObject] isKindOfClass:[FHRNBaseViewController class]]) {
        currentVC = [topVC.viewControllers lastObject];
    }
    
    NSMutableString * openURL = param[@"url"];
    NSString * type = [param objectForKey:@"type"];
    if([type isEqualToString:@"webview"]) {
        NSString * urlStr = openURL;
        if (!isEmptyString(urlStr)) {
            openURL = [NSMutableString stringWithFormat:@"sslocal://webview?url=%@", urlStr];
            BOOL rotate = [[[param objectForKey:@"args"] objectForKey:@"rotate"] boolValue];
            if (rotate) {
                [openURL appendString:@"&supportRotate=1"];
            }
        }
    }
    
    if (self.currentVC == currentVC && !self.canOpenJump) {
        return;
    }
    
    self.currentVC = currentVC;
    self.canOpenJump = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.canOpenJump = YES;
        });
    });
    
    if (!isEmptyString(openURL)) {
        NSURL *openUrlResultUTF8 =  [NSURL URLWithString:[openURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if(openUrlResultUTF8)
        {
            [[TTRoute sharedRoute] openURLByViewController:openUrlResultUTF8 userInfo:nil];
        }
        callback(TTBridgeMsgSuccess, @{@"code": @0},nil);
        return;
    }
    
}

- (void)alertTestWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"test" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertTest show];
}

@end
