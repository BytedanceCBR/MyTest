//
//  FHHouseListAPI.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/12.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHHouseType.h"
#import "FHMainApi.h"

@class TTHttpTask;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListAPI : NSObject

// 同小区房源、在售房源（二手房）
+ (TTHttpTask *)requestHouseInSameNeighborhoodQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 同小区房源、在租房源（租房）
+ (TTHttpTask *)requestRentInSameNeighborhoodQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 周边房源（二手房）
+ (TTHttpTask *)requestRelatedHouseSearchWithQuery:(NSString *)query houseId:(NSString *)houseId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 周边房源（租房）
+ (TTHttpTask *)requestRentHouseSearchWithQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;


/*
 *  二手房列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchErshouHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

/*
 *  新房列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNewHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

/*
 *  小区列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNeighborhoodList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
