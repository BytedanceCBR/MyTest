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
#import "TTPhotoScrollViewController.h"
#import "FHImageModel.h"
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
        @"previewImage" : NSStringFromSelector(@selector(previewImageInfo:)),
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

- (void)previewImageInfo:(NSString *)imageInfo{
    NSLog(@"[FHLynx] %@ thrad = %d",imageInfo,[NSThread isMainThread]);

        void (^invokBlock)(void) = ^() {
              if (!isEmptyString(imageInfo)) {
                   NSDictionary *imageInfoDict = [FHUtils dictionaryWithJsonString:imageInfo];
                   NSInteger index = [imageInfoDict[@"index"] integerValue];
                   NSArray * imagesArray = imageInfoDict[@"images"];
                   
                   TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
                   vc.dragToCloseDisabled = YES;
                   vc.mode = PhotosScrollViewSupportDownloadMode;
                   vc.startWithIndex = index;
                   
                   NSMutableArray *models = [NSMutableArray arrayWithCapacity:imagesArray.count];
                   for (NSString *imageUrlStr in imagesArray) {
                       if ([imageUrlStr isKindOfClass:[NSString class]]) {
                           FHImageModel *image = [[FHImageModel alloc] init];
                           
                           NSMutableDictionary *dict = [NSMutableDictionary new];
                           [dict setValue:imageUrlStr forKey:kTTImageURIKey];
                           [dict setValue:imageUrlStr forKey:TTImageInfosModelURL];
//                           [dict setValue:@([UIScreen mainScreen].bounds.size.width) forKey:kTTImageWidthKey];
//                           [dict setValue:@([UIScreen mainScreen].bounds.size.height) forKey:kTTImageHeightKey];
                           NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:0];
                           if (!isEmptyString(imageUrlStr)) {
                               [urlList addObject:@{TTImageInfosModelURL : imageUrlStr}];
                           }
                           [dict setValue:urlList forKey:kTTImageURLListKey];
                           TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
                           model.imageType = TTImageTypeLarge;
                           [models addObject:model];
                       }
                   }
                   vc.imageInfosModels = models;
                   [vc setStartWithIndex:index];
                   UIImage *placeholder = [UIImage imageNamed:@"default_image"];
                   NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:imagesArray.count];
                   for (NSInteger i = 0 ; i < imagesArray.count; i++) {
                       [placeholders addObject:placeholder];
                   }
                   vc.placeholders = placeholders;
                   [vc presentPhotoScrollView];
                   
               }
        };
        if ([NSThread isMainThread]) {
            invokBlock();
        } else {
            dispatch_sync(dispatch_get_main_queue(), invokBlock);
        }
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
    NSString *stringRes = [self getFetchDefaultString];
    if (!TTNetworkConnected()) {
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
                result = [self getFetchDefaultString];;
            }

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
                    result = [self getFetchDefaultString];;
                }
                callback(result);
            }
        }];
    }
}

- (NSString *)getFetchDefaultString{
    return  @"\{\"message\": \"failed\",\"status\": \"1\"\}";
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
