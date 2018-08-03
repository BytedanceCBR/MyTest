//
//  AWEVideoPlayNetworkManager.m
//  Pods
//
//  Created by 01 on 17/5/8.
//
//

#import "AWEVideoPlayNetworkManager.h"
#import "HTSVideoPlayJSONResponseSerializer.h"
#import "AWEPostDataHttpRequestSerializer.h"

@implementation AWEVideoPlayNetworkManager

+ (instancetype)sharedInstance
{
    static AWEVideoPlayNetworkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AWEVideoPlayNetworkManager alloc] init];
    });
    return instance;
}

- (TTHttpTask *)requestJSONFromURL:(NSString *)url
                                 params:(id)params
                                 method:(NSString *)method
                       needCommonParams:(BOOL)commonParams
                               callback:(TTNetworkJSONFinishBlock)callback
{
    TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:method needCommonParams:commonParams requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:callback];
    return task;
}

- (TTHttpTask *)requestJSONFromURL:(NSString *)url
                                 params:(id)params
                                 method:(NSString *)method
                       needCommonParams:(BOOL)commonParams
                                  model:(Class<MTLModel>)modelClass
                               callback:(void(^)(NSError *error, id<MTLModel> model))callback
{
    TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:method needCommonParams:commonParams requestSerializer:nil responseSerializer:[HTSVideoPlayJSONResponseSerializer class] autoResume:YES callback:^(NSError *error, id jsonObj) {
        if (!modelClass) {
            !callback ? : callback(error, jsonObj);
            return;
        }
        
        if (error) {
            !callback ? : callback(error, nil);
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *mappingError = nil;
            MTLModel *model = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:jsonObj error:&mappingError];
            dispatch_async(dispatch_get_main_queue(), ^{
                !callback ? : callback(mappingError, model);
            });
        });
    }];
    return task;
}

- (TTHttpTask *)requestJSONWithURL:(NSString *)url
                                  params:(id)params
                                  method:(NSString *)method
                        needCommonParams:(BOOL)commonParams
                                callback:(void(^)(NSError *error, id<MTLModel> model))callback
{
   TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:method needCommonParams:commonParams requestSerializer:[AWEPostDataHttpRequestSerializer class] responseSerializer:nil autoResume:YES callback:callback];
   return task;
}

@end
