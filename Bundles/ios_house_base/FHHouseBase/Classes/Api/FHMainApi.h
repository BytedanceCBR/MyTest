//
//  FHMainApi.h
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import <Foundation/Foundation.h>
#import "FHSearchConfigModel.h"
#import "FHConfigModel.h"
#import <CoreLocation/CoreLocation.h>
#import "FHHouseRentModel.h"
#import "FHSearchHouseModel.h"
#import "FHHomeRollModel.h"
#import "FHHomeHouseModel.h"

@class TTHttpTask;

NS_ASSUME_NONNULL_BEGIN

@interface FHMainApi : NSObject

/*
 * search config 废弃，接口合并
 
 +(TTHttpTask *_Nullable)getSearchConfig:(NSDictionary *)param completion:(void(^)(FHSearchConfigModel *_Nullable model , NSError *_Nullable error))completion;
 */

/*
 city_id, gaode_city_id, gaode_lng, gaode_lat, gaode_city_name
 */

+(TTHttpTask *_Nullable )getConfig:(NSInteger )cityId gaodeLocation:(CLLocationCoordinate2D)location gaodeCityId:(NSString *)gCityId gaodeCityName:(NSString *)gCityName completion:(void(^)(FHConfigModel* _Nullable model , NSError *_Nullable  error))completion;


/*
 *  租房请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchRent:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam completion:(void(^_Nullable)(FHHouseRentModel *model , NSError *error))completion;


/**
 * 同小区租房信息  /f100/api/same_neighborhood_rent
 * query need:
 *   exclude_id[]
 *   exclude_id[]
 *   neighborhood_id[]
 *   neighborhood_id[]
 * param need:
 *   house_type
 */
+(TTHttpTask *_Nullable)sameNeighborhoodRentSearchWithQuery:(NSString *_Nullable)query param:(NSDictionary * _Nonnull)queryParam searchId:(NSString *_Nullable)searchId offset:(NSInteger)offset needCommonParams:(BOOL)needCommonParams completion:(void(^_Nullable )(NSError *_Nullable error , FHHouseRentModel *_Nullable model))completion;


/**
 通用请求
 @param queryPath 请求路径
 @param param 其他请求参数
 @param cls 返回model Class
 @param completion 回调
 @return TTHttpTask
 */
+(TTHttpTask *)queryData:(NSString *_Nullable)queryPath params:(NSDictionary *_Nullable)param class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;


/*
 * 基础GET 方法
 * @param: path 请求的path
 * @param: param 参数
 * @param: clazz 返回的json的类型
 * @completion: 完成回调
 */
+(TTHttpTask *_Nullable)getRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param jsonClass:(Class _Nonnull)clazz completion:(void(^_Nullable)(JSONModel *_Nullable model , NSError *_Nullable error))completion;

/*
 * 基础POST 方法
 * @param: path 请求的path
 * @param: param 参数
 * @param: clazz 返回的json的类型
 * @completion: 完成回调
 */
+(TTHttpTask *)postRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param jsonClass:(Class _Nonnull)clazz completion:(void(^_Nullable)(JSONModel *_Nullable model , NSError *_Nullable error))completion;

/*
 * 基础GET 方法
 * @param: path 请求的path
 * @param: param 参数
 * @completion: 完成回调
 */
+(TTHttpTask *_Nullable)getRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param  completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion;

/*
 * 基础POST 方法 请求的参数作为json放置于body里面
 * @param: path 请求的path
 * @param: param 参数
 * @completion: 完成回调
 */
+(TTHttpTask *_Nullable)postJsonRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion;

#pragma mark 找房频道首页相关 =================
/**
 首页搜索框轮播
 */
+(TTHttpTask *)requestHomeSearchRoll:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeRollModel *model, NSError *error))completion;


/**
 首页推荐房源接口
 */
+(TTHttpTask *)requestHomeRecommend:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion;

/**
 频道消息红点
 */
+(TTHttpTask *)requestHomeCategoryMessage:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
