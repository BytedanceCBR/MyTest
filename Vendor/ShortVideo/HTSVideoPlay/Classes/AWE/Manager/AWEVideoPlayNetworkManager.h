//
//  AWEVideoPlayNetworkManager.h
//  Pods
//
//  Created by 01 on 17/5/8.
//
//
#import <Foundation/Foundation.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTHTTPRequestSerializerProtocol.h"
#import "TTHTTPResponseSerializerProtocol.h"
#import <Mantle/Mantle.h>

@interface AWEVideoPlayNetworkManager : NSObject

+ (instancetype)sharedInstance;

- (TTHttpTask *)requestJSONFromURL:(NSString *)url
                                 params:(id)params
                                 method:(NSString *)method
                       needCommonParams:(BOOL)commonParams
                               callback:(TTNetworkJSONFinishBlock)callback;

- (TTHttpTask *)requestJSONFromURL:(NSString *)url
                                 params:(id)params
                                 method:(NSString *)method
                       needCommonParams:(BOOL)commonParams
                                  model:(Class<MTLModel>)modelClass
                               callback:(void(^)(NSError *error, id<MTLModel> model))callback;

- (TTHttpTask *)requestJSONWithURL:(NSString *)url
                                 params:(id)params
                                 method:(NSString *)method
                       needCommonParams:(BOOL)commonParams
                               callback:(void(^)(NSError *error, id<MTLModel> model))callback;
@end
