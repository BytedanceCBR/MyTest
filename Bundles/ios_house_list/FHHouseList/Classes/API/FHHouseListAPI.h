//
//  FHHouseListAPI.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/12.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import <FHHouseBase/FHURLSettings.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHMainApi.h>
#import "FHCommuteType.h"
#import "FHHouseListBaseItemModel.h"

@class TTHttpTask;


NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListAPI : NSObject

// 同小区房源、在售房源（二手房）
+ (TTHttpTask *)requestHouseInSameNeighborhoodQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 同小区房源、在租房源（租房）
+ (TTHttpTask *)requestRentInSameNeighborhoodQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 周边房源（二手房）
+ (TTHttpTask *)requestRelatedHouseSearchWithQuery:(NSString *)query houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 周边房源（租房）
+ (TTHttpTask *)requestRentHouseSearchWithQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 二手房-推荐新盘列表页
+(TTHttpTask*)requestOldHouseRecommendedCourtSearchList:(NSString*)houseId
                                           searchId:(NSString*)searchId
                                             cityId:(NSInteger)cityId
                                             offset:(NSString*)offset
                                              query:(NSString*)query
                                              count:(NSInteger)count
                                         completion:(void(^)(FHListResultHouseModel * _Nullable model , NSError * _Nullable error))completion;

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
 *  虚假房源列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchFakeHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

/*
 *  二手房相似房源请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)recommendErshouHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

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
 *  帮我找房新房列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNewHouseListForFindHouse:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

/*
 *  小区列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNeighborhoodList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

+(TTHttpTask *)searchRent:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;


/*
 *  查成交请求
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNeighborhoodDealList:(NSString *_Nullable)query searchType:(NSString *)searchType offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

// 搜索列表页网络请求
// 猜你想搜
+ (TTHttpTask *)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 获取历史记录
+ (TTHttpTask *)requestSearchHistoryByHouseType:(NSString *)houseType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 删除历史记录
+ (TTHttpTask *)requestDeleteSearchHistoryByHouseType:(NSString *)houseType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 搜索sug建议
+ (TTHttpTask *)requestSuggestionCityId:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 搜索订阅信息
+ (TTHttpTask *)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType subscribe_type:(NSInteger)type subscribe_count:(NSInteger)count  class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// add订阅信息
+(TTHttpTask *)requestAddSugSubscribe:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;

// delete订阅信息
+ (TTHttpTask *)requestDeleteSugSubscribe:(NSString *)subscribeId class:(Class _Nullable)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

//通勤找房
+(TTHttpTask *)requestCommute:(NSInteger)cityId query:(NSString *_Nullable)query location:(CLLocationCoordinate2D)location houseType:(FHHouseType)houseType duration:(CGFloat)duration type:(FHCommuteType)type param:(NSDictionary *_Nonnull)param offset:(NSInteger)offset completion:(void(^_Nullable)(FHListSearchHouseModel* _Nullable model , NSError * _Nullable error))completion;

//仅仅给小区使用的sug建议
+ (TTHttpTask *)requestSuggestionOnlyNeiborhoodCityId:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

// 查成交小区搜索
+ (TTHttpTask *)requestDealSuggestionCityId:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query searchType:(NSString *)searchType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

//上报跳转详情页信息到浏览历史
+ (TTHttpTask *)requestAddHistory:(NSDictionary *)params completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
