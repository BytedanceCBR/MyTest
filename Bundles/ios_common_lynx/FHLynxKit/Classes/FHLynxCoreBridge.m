//
//  FHLynxCoreBridge.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxCoreBridge.h"
#import <CoreGraphics/CGBase.h>
#import "TTRoute.h"
#import "NSString+BTDAdditions.h"
#import "FHEnvContext.h"
#import "TTKitchen.h"
#import "ToastManager.h"
#import "TTSettingsManager.h"
#import "NSDictionary+BTDAdditions.h"
#import "NetworkUtilities.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNetworkManager.h"
#import "FHRNHTTPRequestSerializer.h"
#import "FHUtils.h"

#define FHLynxBridgeMsgSuccess @(1)
#define FHLynxBridgeMsgFailed @(0)

typedef void(^FHLynxBridgeCallback)(NSString *response);


@implementation FHLynxCoreBridge

+ (NSString *)name {
    return @"FLynxBridge";
}

//note 此类已经废弃，暂时保留作为备份，添加方法请移步TTLynxBridgeEngine (TTLynxExtension)
+ (NSDictionary<NSString *,NSString *> *)methodLookup {
    return @{
        @"openSchema" : NSStringFromSelector(@selector(openSchema:)),
        @"jumpSchema" : NSStringFromSelector(@selector(jumpSchema:)),
        @"onEventV3" : NSStringFromSelector(@selector(onEventV3:params:)),
        @"onEvent" : NSStringFromSelector(@selector(onEvent:label:value:source:extraDicString:)),
        @"getIntSetting" : NSStringFromSelector(@selector(getIntSetting:)),
        @"getBoolSetting" : NSStringFromSelector(@selector(getBoolSetting:)),
        @"getStringSetting" : NSStringFromSelector(@selector(getStringSetting:)),
        @"showToast" : NSStringFromSelector(@selector(showToast:)),
        @"log" : NSStringFromSelector(@selector(log:logInfo:)),
        @"fetch" : NSStringFromSelector(@selector(fetchWithParam:callback:)),
//        @"dispatchEvent": NSStringFromSelector(@selector(dispatchEvent:label:params:)),
    };
}

- (void)dispatchEvent:(NSString *)identifier
                label:(NSString *)label
               params:(NSString *)paramsString {
//    void (^invokBlock)(void) = ^() {
//        if ([identifier isEqualToString:@"identifier_survey_panel"]) {
//            if ([label isEqualToString:@"label_close"]) {
//                id<TTSurveyPannelPopupSeviceProtocol> service = [BDContextGet() findServiceByName:TTSurveyPannelPopupSeviceProtocolServiceName];
//                [service closeCurrentPopupPanel];
//            }
//        } else {
//            [[TTLynxEventDispatcher sharedInstance] dispatchEvent:identifier label:label extraParams:paramsString];
//        }
//    };
//
//    if ([NSThread isMainThread]) {
//        invokBlock();
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), invokBlock);
//    }
}

- (void)openSchema:(NSString *)schema {
    void (^invokBlock)(void) = ^() {
        NSURL *schemaUrl = [NSURL URLWithString:schema];
        [[TTRoute sharedRoute] openURLByPushViewController:schemaUrl];
    };
    if ([NSThread isMainThread]) {
        invokBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), invokBlock);
    }
}

- (void)jumpSchema:(NSString *)schema {
    [self openSchema:schema];
}

- (void)onEvent:(NSString *)customkey label:(NSString *)label value:(NSString *)value source:(NSString *)source extraDicString:(NSString *)extraDicString {
    NSDictionary *params = [extraDicString btd_jsonDictionary];
    
//    [BDTrackerProtocol trackEventWithCustomKeys:customkey label:label value:value source:source extraDic:params];
}

- (void)onEventV3:(NSString *)eventName params:(NSString *)paramsString {
    NSDictionary *params = [paramsString btd_jsonDictionary];
    if (params) {
        [FHEnvContext recordEvent:params andEventKey:eventName];
    }
}

- (void)showToast:(NSString *)toast{
    if ([toast isKindOfClass:[NSString class]] && toast.length > 0) {
        [[ToastManager manager] showToast:toast];
    }
}

- (void)log:(NSString *)logKey logInfo:(NSString *)logInfo{
    NSLog(@"[FHLynx] %@:%@",logKey,logInfo);
}

- (NSString *)getStringSetting:(NSString *)key {
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    NSString *getSettingStr = [fhSettings btd_stringValueForKey:key] ? : @"";
    return getSettingStr;
}

- (NSInteger)getIntSetting:(NSString *)key {
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    NSInteger getSettingStr = [fhSettings btd_intValueForKey:key];
    return getSettingStr;
}


- (void)fetchWithParam:(NSString *)paramStr callback:(FHLynxBridgeCallback)callback
{
    if (!TTNetworkConnected()) {
         NSString *stringRes = @"\{\"message\": \"failed\"\}";
         callback(stringRes);
        return;
    }
    
    NSDictionary *param = nil;
    
    if ([paramStr isKindOfClass:[NSString class]]) {
        NSString *stringJson = (NSString *)paramStr;
        //json字符串
        NSData *jsonData = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(!err){
            param = dic;
        }
    }
    
    if (!param) {
        NSString *stringRes = @"\{\"message\": \"failed\"\}";
        callback(stringRes);
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
        NSString *stringRes = @"\{\"message\": \"failed\"\}";
        callback(stringRes);
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

//            NSMutableDictionary *resultDict = [NSMutableDictionary new];
//            [resultDict setValue:(response.allHeaderFields ? response.allHeaderFields : @"") forKey:@"headers"];
//            [resultDict setValue:result forKey:@"response"];
//            [resultDict setValue:@(response.statusCode) forKey:@"status"];
//            [resultDict setValue:error?@(0): @(1) forKey:@"code"];
//            [resultDict setValue:startTime forKey:@"beginReqNetTime"];

            if (callback) {
                callback(result);
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

//                NSMutableDictionary *resultDict = [NSMutableDictionary new];
//                [resultDict setValue:(response.allHeaderFields ? response.allHeaderFields : @"") forKey:@"headers"];
//                [resultDict setValue:result forKey:@"response"];
//                [resultDict setValue:@(response.statusCode) forKey:@"status"];
//                [resultDict setValue:error?@(0): @(1) forKey:@"code"];
//                [resultDict setValue:startTime forKey:@"beginReqNetTime"];

                callback(result);
            }
        }];
    }
}


//+ (NSDictionary<NSString *,NSString *> *)methodLookup {
//    return @{
//        @"jumpSchema" : NSStringFromSelector(@selector(openSchema:)),
//    };
//}
//
//- (void)openSchema:(NSString *)schema {
//
//    void (^invokBlock)(void) = ^() {
//        NSURL *openUrl =  [NSURL URLWithString:schema];
//          if(openUrl)
//          {
//              [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:nil];
//          }
////        [BDLUtils openSchema:schema];
//    };
//    if ([NSThread isMainThread]) {
//        invokBlock();
//    } else {
//        dispatch_sync(dispatch_get_main_queue(), invokBlock);
//    }
//}

@end
