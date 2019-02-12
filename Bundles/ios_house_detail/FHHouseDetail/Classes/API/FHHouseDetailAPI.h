//
//  FHHouseDetailAPI.h
//  FHHouseDetailAPI
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHHouseType.h"
#import "FHMainApi.h"

@class TTHttpTask,FHDetailNewModel,FHDetailNeighborhoodModel,FHDetailOldModel;
@class FHDetailRelatedHouseResponseModel,FHDetailRelatedNeighborhoodResponseModel,FHDetailSameNeighborhoodHouseResponseModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailAPI : NSObject

// 新房详情页请求
+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                     completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion;

// 二手房详情页请求
+(TTHttpTask*)requestOldDetail:(NSString*)houseId
                         logPB:(NSDictionary *)logPB
                    completion:(void(^)(FHDetailOldModel * _Nullable model , NSError * _Nullable error))completion;

// 小区详情页请求
+(TTHttpTask*)requestNeighborhoodDetail:(NSString*)houseId
                    completion:(void(^)(FHDetailNeighborhoodModel * _Nullable model , NSError * _Nullable error))completion;

// 租房详情页请求

// 二手房-周边房源
+(TTHttpTask*)requestRelatedHouseSearch:(NSString*)houseId
                                  offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHDetailRelatedHouseResponseModel * _Nullable model , NSError * _Nullable error))completion;
// 二手房-周边小区
+(TTHttpTask*)requestRelatedNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                        searchId:(NSString*)searchId
                                                        offset:(NSString *)offset
                                                         query:(NSString*)query
                                                         count:(NSInteger)count
                                                    completion:(void(^)(FHDetailRelatedNeighborhoodResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 二手房-同小区房源
+(TTHttpTask*)requestHouseInSameNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                           houseId:(NSString*)houseId
                                                          searchId:(NSString*)searchId
                                                            offset:(NSString *)offset
                                                             query:(NSString*)query
                                                             count:(NSInteger)count
                                                        completion:(void(^)(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model , NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
