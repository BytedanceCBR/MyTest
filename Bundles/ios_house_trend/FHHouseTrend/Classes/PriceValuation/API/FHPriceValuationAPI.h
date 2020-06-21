//
//  FHPriceValuationAPI.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FHURLSettings.h"
#import "FHMainApi.h"
#import <FHHouseBase/FHHouseType.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationAPI : NSObject

+ (NSString *)host;
//评估历史
+ (TTHttpTask *)requestHistoryListWithCompletion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;
//立即评估
+ (TTHttpTask *)requestEvaluateWithParams:(NSDictionary *)params completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion;
//用户评价
+ (TTHttpTask *)requestEvaluateEstimateWithParams:(NSDictionary *)params completion:(void(^_Nullable)(BOOL success, NSError *error))completion;
//提交手机号
+ (TTHttpTask *)requestSubmitPhoneWithEstimateId:(NSString *)estimateId houseType:(FHHouseType)houseType phone:(NSString *)phone params:(NSDictionary *)postParams completion:(void (^)(BOOL, NSError * _Nonnull))completion;
//立即评估同时获取小区详情
+ (void)requestEvaluateResultWithParams:(NSDictionary *)params neighborhoodId:(NSString *)neighborhoodId completion:(void(^_Nullable)(NSDictionary *response , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
