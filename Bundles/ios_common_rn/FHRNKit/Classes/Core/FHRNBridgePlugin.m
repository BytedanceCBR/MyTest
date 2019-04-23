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
#import <NSDictionary+TTAdditions.h>
#import "FHRNHTTPRequestSerializer.h"
#import "TTBridgeRegister.h"
#import "TTBridgeDefines.h"
#import <TTRoute.h>
#import <TTStringHelper.h>
#import "TTDeviceHelper.h"
#import <TTUIResponderHelper.h>
#import <FHRNBaseViewController.h>
#import <UIViewController+Refresh_ErrorHandler.h>
#import <FHEnvContext.h>
#import <NSDictionary+TTAdditions.h>
#import <FHUtils.h>
#import <HMDTTMonitor.h>
#import <UIViewController+NavigationBarStyle.h>
#import "FHHousePhoneCallUtils.h"
#import "FHHouseFollowUpHelper.h"

@interface FHRNBridgePlugin ()
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@end

@implementation FHRNBridgePlugin

+ (TTBridgeInstanceType)instanceType {
    return TTBridgeInstanceTypeAssociated;
}

+ (void)load {
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
    TTRegisterRNBridge(TTClassBridgeMethod(FHRNBridgePlugin, fetch), TTAppFetchBridgeName);
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
    if ([reportParamsDict isKindOfClass:[NSDictionary class]]) {
        [callParams addEntriesFromDictionary:reportParamsDict];
    }
    if (realtorId) {
        [callParams setValue:realtorId forKey:@"realtor_id"];
    }
    if (houseType) {
        [callParams setValue:houseType forKey:@"house_type"];
    }
    
    if(callParams[@"group_id"])
    {
        callParams[@"follow_id"] = callParams[@"group_id"];
    }
    
    if(callParams[@"group_id"])
    {
        callParams[@"house_id"] = callParams[@"group_id"];
    }
    
//    //二手房打电话
//    [callParams setValue:@(2) forKey:@"action_type"];
//
    [FHHousePhoneCallUtils callWithConfig:callParams];
    if (callParams[@"follow_id"]) {
        [FHHouseFollowUpHelper silentFollowHouseWithConfig:callParams];
    }
    if (callback) {
        callback(TTBridgeMsgSuccess, nil);
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
        [currentVC tt_endUpdataData];
    }
}

- (void)log_v3WithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
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

- (void)closeWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    
}

- (void)fetchWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
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
            
//            callback(TTBridgeMsgSuccess,nil);
            if (callback) {
                callback(error? -1: TTBridgeMsgSuccess, @{@"headers" : (response.allHeaderFields ? response.allHeaderFields : @""), @"response": result,
                                                          @"status": @(response.statusCode),
                                                          @"code": error?@(0): @(1),
                                                          @"beginReqNetTime": startTime
                                                          });
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
                callback(error? -1: TTBridgeMsgSuccess, @{@"headers" : (response.allHeaderFields ? response.allHeaderFields : @""),
                                                          @"response": result,
                                                          @"status": @(response.statusCode),
                                                          @"code": error?@(0): @(1),
                                                          @"beginReqNetTime":startTime
                                                          });
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

    if (!isEmptyString(openURL)) {
//        NSURL *openUrlResultUTF8 =  [NSURL URLWithString:[openURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *openUrlResultUTF8 =  [NSURL URLWithString:[openURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:openUrlResultUTF8 userInfo:nil];
//        [currentVC.navigationController pushViewController:routeObj.instance animated:YES];
//
        if(openUrlResultUTF8)
        {
            [[TTRoute sharedRoute] openURLByViewController:openUrlResultUTF8 userInfo:nil];
        }
        return;
    }
    
    callback(TTBridgeMsgSuccess, @{@"code": @0});
}

- (void)alertTestWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller
{
    UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"test" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertTest show];
}

@end
