//
//  FHPriceValuationAPI.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHMainApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationAPI : NSObject

+ (NSString *)host;

+ (TTHttpTask *)requestHistoryListWithCompletion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

+ (TTHttpTask *)requestEvaluateWithParams:(NSDictionary *)params completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion;

+ (TTHttpTask *)requestChartTrendWithNeiborhoodId:(NSString *)neiborhoodId completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

+ (TTHttpTask *)requestEvaluateEstimateWithParams:(NSDictionary *)params completion:(void(^_Nullable)(BOOL success, NSError *error))completion;

+ (TTHttpTask *)requestSubmitPhoneWithParams:(NSDictionary *)params completion:(void(^_Nullable)(BOOL success, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
