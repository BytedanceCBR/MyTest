//
//  FHHouseListAPI.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/12.
//

#import "FHHouseListAPI.h"

@implementation FHHouseListAPI

+ (TTHttpTask *)requestHouseInSameNeighborhoodQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/same_neighborhood_house";
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"neighborhood_id"] = neighborhoodId ?: @"";
    paramDic[@"house_id"] = houseId ?: @"";
    paramDic[@"search_id"] = searchId ?: @"";
    paramDic[@"offset"] = @(offset);
    paramDic[@"count"] = @(count);
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestRentInSameNeighborhoodQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/same_neighborhood_rent";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    paramDic[@"exclude_id[]"] = houseId ?: @"";
    paramDic[@"neighborhood_id"] = neighborhoodId ?: @"";
    paramDic[@"house_type"] = @(FHHouseTypeRentHouse);
    paramDic[@"search_id"] = searchId ?: @"";
    paramDic[@"offset"] = @(offset);
    paramDic[@"count"] = @(count);
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestRelatedHouseSearchWithQuery:(NSString *)query houseId:(NSString *)houseId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/related_house";
    queryPath = [NSString stringWithFormat:@"%@?house_id%@&offset=%ld",queryPath, houseId ?: @"",offset];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_id"] = houseId ?: @"";
    paramDic[@"offset"] = @(offset);
    paramDic[@"count"] = @(count);
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestRentHouseSearchWithQuery:(NSString *)query neighborhoodId:(NSString *)neighborhoodId houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/related_rent";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    paramDic[@"exclude_id[]"] = houseId ?: @"";
    paramDic[@"rent_id"] = houseId ?: @"";
    paramDic[@"house_type"] = @(FHHouseTypeRentHouse);
    paramDic[@"search_id"] = searchId ?: @"";
    paramDic[@"offset"] = @(offset);
    paramDic[@"count"] = @(count);
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

/*
 *  二手房列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params 已废弃
 */
+(TTHttpTask *)searchErshouHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/search";

    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    if (param) {
        [qparam addEntriesFromDictionary:param];
    }
    qparam[@"offset"] = @(offset);
    qparam[@"search_id"] = searchId?:@"";
    if (sugParam) {
        qparam[@"suggestion_params"] = sugParam;
    }
    
    return [FHMainApi queryData:queryPath params:qparam class:cls completion:completion];
    
}

/*
 *  二手房猜你想找列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params 已废弃
 */
+(TTHttpTask *)recommendErshouHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/recommend_search";
    
    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    if (param) {
        [qparam addEntriesFromDictionary:param];
    }
    qparam[@"offset"] = @(offset);
    qparam[@"search_id"] = searchId?:@"";
    if (sugParam) {
        qparam[@"suggestion_params"] = sugParam;
    }
    
    return [FHMainApi queryData:queryPath params:qparam class:cls completion:completion];
    
}

/*
 *  新房列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNewHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;
{
    NSString *queryPath = @"/f100/api/search_court";

    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    if (param) {
        [qparam addEntriesFromDictionary:param];
    }
    qparam[@"offset"] = @(offset);
    qparam[@"search_id"] = searchId?:@"";
    if (sugParam) {
        qparam[@"suggestion_params"] = sugParam;
    }
    
    return [FHMainApi queryData:queryPath params:qparam class:cls completion:completion];

}

/*
 *  小区列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNeighborhoodList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion;
{
    NSString *queryPath = @"/f100/api/search_neighborhood?";

    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    if (param) {
        [qparam addEntriesFromDictionary:param];
    }
    qparam[@"offset"] = @(offset);
    qparam[@"search_id"] = searchId?:@"";
    if (sugParam) {
        qparam[@"suggestion_params"] = sugParam;
    }
    
    return [FHMainApi queryData:queryPath params:qparam class:cls completion:completion];

}

+ (TTHttpTask *)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/guess_you_want_search";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"city_id"] = @(cityId);
    paramDic[@"house_type"] = @(houseType);
    paramDic[@"source"] = @"app";
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestSearchHistoryByHouseType:(NSString *)houseType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/v2/get_history?";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = houseType;
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestDeleteSearchHistoryByHouseType:(NSString *)houseType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/clear_history?";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = houseType;
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestSuggestionCityId:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/get_suggestion";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"city_id"] = @(cityId);
    paramDic[@"house_type"] = @(houseType);
    paramDic[@"source"] = @"app";
    if (query.length > 0) {
        paramDic[@"query"] = query;
    }
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}


+ (TTHttpTask *)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType subscribe_type:(NSInteger)type subscribe_count:(NSInteger)count  class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/get_subscribe_list";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"city_id"] = @(cityId);
    paramDic[@"house_type"] = @(houseType);
    paramDic[@"subscribe_list_type"] = @(type);
    paramDic[@"subscribe_list_count"] = @(count);
    paramDic[@"source"] = @"app";
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

@end
