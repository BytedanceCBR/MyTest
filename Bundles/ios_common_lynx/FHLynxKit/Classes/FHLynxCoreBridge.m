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
