//
//  FHHomeRequestAPI.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import <Foundation/Foundation.h>
#import "FHHomeRollModel.h"
#import "FHMainApi.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHomeHouseModel;

@interface FHHomeRequestAPI : NSObject

+ (TTHttpTask *)requestRecommendFirstTime:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion;


+ (void)requestRecommendForLoadMore:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion;

+ (TTHttpTask *)requestCitySearchByQuery:(NSString *)query class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
