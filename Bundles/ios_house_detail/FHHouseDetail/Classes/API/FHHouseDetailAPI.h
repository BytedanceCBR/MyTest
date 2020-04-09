//
//  FHHouseDetailAPI.h
//  FHHouseDetailAPI
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FHURLSettings.h"
#import "FHHouseType.h"
#import "FHMainApi.h"
#import "FHHouseContactDefines.h"
#import "FHHouseListBaseItemModel.h"

@class TTHttpTask,FHDetailNewModel,FHDetailNeighborhoodModel,FHDetailOldModel,FHRentDetailResponseModel,FHDetailFloorPanDetailInfoModel,FHDetailFloorPanListResponseModel;
@class FHDetailRelatedHouseResponseModel,FHDetailRelatedNeighborhoodResponseModel,FHDetailSameNeighborhoodHouseResponseModel,FHDetailRelatedCourtModel,FHDetailNewTimeLineResponseModel,FHDetailNewCoreDetailModel;
@class FHHouseRentRelatedResponseModel,FHRentSameNeighborhoodResponseModel;
@class FHDetailResponseModel,FHDetailVirtualNumResponseModel,FHDetailUserFollowResponseModel;
@class FHTransactionHistoryModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailAPI : NSObject

// 新房详情页请求
+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                         logPB:(NSDictionary *)logPB
                     extraInfo:(NSDictionary *)extraInfo
                     completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion;

// 二手房详情页请求
+(TTHttpTask*)requestOldDetail:(NSString *)houseId
     ridcode:(NSString *)ridcode
   realtorId:(NSString *)realtorId
     logPB:(NSDictionary *)logPB
 extraInfo:(NSDictionary *)extraInfo
completion:(void(^)(FHDetailOldModel * _Nullable model , NSError * _Nullable error))completion;

// 小区详情页请求
+(TTHttpTask*)requestNeighborhoodDetail:(NSString*)neighborhoodId
                                  logPB:(NSDictionary *)logPB
                                  query:(NSString*)query
                              extraInfo:(NSDictionary *)extraInfo
                    completion:(void(^)(FHDetailNeighborhoodModel * _Nullable model , NSError * _Nullable error))completion;

// 租房详情页请求
+(TTHttpTask*)requestRentDetail:(NSString*)rentCode
                      extraInfo:(NSDictionary *)extraInfo
                     completion:(void(^)(FHRentDetailResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 租房-周边房源
//+ (TTHttpTask*)requestHouseRentRelated:(NSString*)rentId
//                            completion:(void(^)(FHHouseRentRelatedResponseModel* model , NSError *error))completion;

+ (TTHttpTask*)requestHouseRentRelated:(NSString*)rentId class:(Class)cls
completion:(void(^)(id<FHBaseModelProtocol> _Nullable model , NSError *error))completion;

// 租房-同小区房源
+ (TTHttpTask*)requestHouseRentSameNeighborhood:(NSString*)rentId
                             withNeighborhoodId:(NSString*)neighborhoodId
                                     completion:(void(^)(FHRentSameNeighborhoodResponseModel* model , NSError *error))completion;

// 二手房-周边房源
+(TTHttpTask*)requestRelatedHouseSearch:(NSString*)houseId
                               searchId:(NSString *)searchId
                                  offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHDetailRelatedHouseResponseModel * _Nullable model , NSError * _Nullable error))completion;
// 二手房（小区）-周边小区
+(TTHttpTask*)requestRelatedNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                        searchId:(NSString*)searchId
                                                        offset:(NSString *)offset
                                                         query:(NSString*)query
                                                         count:(NSInteger)count
                                                    completion:(void(^)(FHDetailRelatedNeighborhoodResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 二手房（小区）-小区成交历史
+(TTHttpTask*)requestNeighborhoodTransactionHistoryByNeighborhoodId:(NSString*)neighborhoodId
                                                      searchId:(NSString*)searchId
                                                        page:(NSInteger)page
                                                         count:(NSInteger)count
                                                         query:(NSString *)query
                                                    completion:(void(^)(FHTransactionHistoryModel * _Nullable model , NSError * _Nullable error))completion;

// 二手房（小区）-同小区房源
+(TTHttpTask*)requestHouseInSameNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                           houseId:(NSString*)houseId
                                                          searchId:(NSString*)searchId
                                                            offset:(NSString *)offset
                                                             query:(NSString*)query
                                                             count:(NSInteger)count
                                                        completion:(void(^)(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model , NSError * _Nullable error))completion;
// 新房-周边新盘
+(TTHttpTask*)requestRelatedFloorSearch:(NSString*)houseId
                                 offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHListResultHouseModel * _Nullable model , NSError * _Nullable error))completion;

// 新房-楼盘动态
+(TTHttpTask*)requestFloorTimeLineSearch:(NSString*)houseId
                                  query:(NSString*)query
                             completion:(void(^)(FHDetailNewTimeLineResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 新房-楼盘信息
+(TTHttpTask*)requestFloorCoreInfoSearch:(NSString*)courtId
                              completion:(void(^)(FHDetailNewCoreDetailModel * _Nullable model , NSError * _Nullable error))completion;

// 新房-楼盘户型详情信息
+(TTHttpTask*)requestFloorPanDetailCoreInfoSearch:(NSString*)floorPanId
                              completion:(void(^)(FHDetailFloorPanDetailInfoModel * _Nullable model , NSError * _Nullable error))completion;

// 新房-楼盘户型列表信息
+(TTHttpTask*)requestFloorPanListSearch:(NSString*)courtId
                             completion:(void(^)(FHDetailFloorPanListResponseModel * _Nullable model , NSError * _Nullable error))completion;

/*
 * 用户反馈该内容是否有帮助
 * @feedType: 0表示空，1表示是，2表示否
 * @source: （幸福天眼: detective，安全贴士: safety_tips）
 */
+(TTHttpTask *)requstQualityFeedback:(NSString *)houseId houseType:(FHHouseType)houseType source:(NSString *)source feedBack:(NSInteger)feedType agencyId:(NSString *)agencyId completion:(void (^)(bool succss , NSError *error))completion;

/*
 * 拨打电话后用户反馈
 * @score: 1不专业，2一般，3专业
 */
+(TTHttpTask *)requestPhoneFeedback:(NSString *)houseId houseType:(FHHouseType)houseType realtorId:(NSString *)realtorId imprId:(NSString *)imprId searchId:(NSString *)searchId score:(NSInteger)score requestId:(NSString*) requestId completion:(void (^)(bool succss , NSError *error))completion;

+ (TTHttpTask *)requestRealtorEvaluationFeedback:(NSString *)targetId targetType:(NSInteger)targetType evaluationType:(NSInteger)evaluationType realtorId:(NSString *)realtorId content:(NSString *)content score:(NSInteger)score tags: (NSArray*)tags completion:(void (^)(bool, NSError * _Nullable))completion;

@end



NS_ASSUME_NONNULL_END
