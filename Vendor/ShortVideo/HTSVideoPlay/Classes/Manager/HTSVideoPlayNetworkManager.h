//
//  HTSVideoPlayNetworkManager.h
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <Mantle/Mantle.h>

@interface HTSVideoPlayNetworkManager : NSObject

+ (instancetype)sharedInstance;

- (TTHttpTask *)requestJSONFromURL:(NSString *)url params:(id)params method:(NSString *)method needCommonParams:(BOOL)commonParams callback:(TTNetworkJSONFinishBlock)callback;

- (TTHttpTask *)requestJSONFromURL:(NSString *)url params:(id)params method:(NSString *)method needCommonParams:(BOOL)commonParams model:(Class<MTLModel>)modelClass callback:(void(^)(NSError *error, id<MTLModel> model))callback;

@end
