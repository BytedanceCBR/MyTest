//
//  FHHouseListAPI.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/12.
//

#import "FHHouseListAPI.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import <YYModel/YYModel.h>
#import "FHSearchHouseModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <FHHouseBase/FHHouseNeighborModel.h>

#define QURL(QPATH) [[FHMainApi host] stringByAppendingString:QPATH]
#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define API_NO_DATA     10001
#define API_WRONG_DATA  10002



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
    paramDic[CHANNEL_ID] = CHANNEL_ID_SAME_NEIGHBORHOOD_HOUSE;
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
    paramDic[CHANNEL_ID] = CHANNEL_ID_SAME_NEIGHBORHOOD_RENT;

    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestRelatedHouseSearchWithQuery:(NSString *)query houseId:(NSString *)houseId searchId:(NSString *)searchId offset:(NSInteger)offset count:(NSInteger)count class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/related_house";
    queryPath = [NSString stringWithFormat:@"%@?house_id=%@&offset=%ld",queryPath, houseId ?: @"",offset];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@%@",queryPath,query];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_id"] = houseId ?: @"";
    paramDic[@"search_id"] = searchId ?: @"";
    paramDic[@"offset"] = @(offset);
    paramDic[@"count"] = @(count);
    paramDic[CHANNEL_ID] = CHANNEL_ID_RELATED_HOUSE;

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
    paramDic[CHANNEL_ID] = CHANNEL_ID_RELATED_RENT;

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
    
    if ([NSStringFromClass(cls) isEqualToString:NSStringFromClass([FHListSearchHouseModel class])]) {
        return [FHHouseListAPI querySearchData:queryPath uploadLog:YES params:qparam class:cls logPath:@"search_second" completion:completion];
    }
    return [FHMainApi queryData:queryPath uploadLog:YES params:qparam class:cls logPath:@"search_second" completion:completion];
    
}

#pragma mark - model 特殊处理
+(TTHttpTask *)querySearchData:(NSString *_Nullable)queryPath uploadLog:(BOOL)uploadLog params:(NSDictionary *_Nullable)param class:(Class)cls logPath:(NSString *)logPath completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *url = QURL(queryPath);
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSDate *backDate = [NSDate date];
        
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            FHListSearchHouseModel *model = (FHListSearchHouseModel *)[self generateModel:obj class:cls error:&backError];
            NSDate *serDate = [NSDate date];
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            
            BOOL success = NO;
            if (response.statusCode == 200 ) {
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil) {
                        if (uploadLog) {
                            extraDict = @{}.mutableCopy;
                            extraDict[@"request_url"] = response.URL.absoluteString;
                            extraDict[@"response_headers"] = response.allHeaderFields;
                            extraDict[@"error"] = error.domain;
                        }
                        code = [status integerValue];
                        resultType = status.integerValue;
                        errMsg = error.domain;
                    }
                }
            }else{
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
            }
            [FHMainApi addRequestLog:logPath?:response.URL.path startDate:startDate backDate:backDate serializeDate:serDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
        
    }];
}

+(JSONModel *)generateModel:(NSData *)jsonData class:(Class)class error:(NSError *__autoreleasing *)error
{
    if (*error) {
        //there is error
        return nil;
    }
    
    if (!jsonData) {
        *error = [NSError errorWithDomain:@"未请求到数据" code:API_NO_DATA userInfo:nil];
        return nil;
    }
    
    NSError *jerror = nil;
    JSONModel *model = nil;

    model = [[class alloc]initWithData:jsonData error:&jerror];
    if ([model isKindOfClass:[FHListSearchHouseModel class]]) {
        
        FHListSearchHouseModel *responseModel = (FHListSearchHouseModel *)model;
        if (responseModel.data.items.count > 0) {
            
            NSMutableArray *searchItems = @[].mutableCopy;
            NSArray *itemsArray = responseModel.data.items;
            [itemsArray enumerateObjectsUsingBlock:^(id  _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([itemDict isKindOfClass:[NSDictionary class]]) {
                    id theItemModel = [self searchItemModelByDict:itemDict];
                    if (theItemModel) {
                        [searchItems addObject:theItemModel];
                    }
                }
            }];
            responseModel.data.searchItems = searchItems;
            model = responseModel;
        }
    }else if ([class isKindOfClass:[FHNewHouseListResponseModel class]]) {
//        model = [[class alloc]initWithData:jsonData error:&jerror];

    } else if ([class isKindOfClass:[FHHouseRentModel class]]) {
        
        FHListSearchHouseModel *responseModel = (FHListSearchHouseModel *)model;
        if (responseModel.data.items.count > 0) {
            
            NSMutableArray *searchItems = @[].mutableCopy;
            NSArray *itemsArray = responseModel.data.items;
            [itemsArray enumerateObjectsUsingBlock:^(id  _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([itemDict isKindOfClass:[NSDictionary class]]) {
                    id theItemModel = [self searchItemModelByDict:itemDict];
                    if (theItemModel) {
                        [searchItems addObject:theItemModel];
                    }
                }
            }];
            responseModel.data.searchItems = searchItems;
            model = responseModel;
        }
    } else if ([class isKindOfClass:[FHHouseNeighborModel class]]) {
//        model = [[class alloc]initWithData:jsonData error:&jerror];
    }
        
    if (jerror) {
#if DEBUG
        NSLog(@" %s %ld API [%@] make json failed",__FILE__,__LINE__,NSStringFromClass(class));
#endif
        *error = [NSError errorWithDomain:@"数据异常" code:API_WRONG_DATA userInfo:nil];
        return nil;
    }
    
    if ([model respondsToSelector:@selector(status)]) {
        NSString *status = [model performSelector:@selector(status)];
        if (![@"0" isEqualToString:status]) {
            NSString *message = nil;
            if ([model respondsToSelector:@selector(message)]) {
                message = [model performSelector:@selector(message)];
            }
            *error = [NSError errorWithDomain:message?:DEFULT_ERROR code:[status integerValue] userInfo:nil];
        }
    }
    return model;
}

+ (id)searchItemModelByDict:(NSDictionary *)itemDict
{
    NSInteger cardType = -1;
    if (itemDict[@"card_type"]) {
        cardType = [itemDict tt_integerValueForKey:@"card_type"];
    }else if (itemDict[@"house_type"]) {
        cardType = [itemDict tt_integerValueForKey:@"house_type"];
    }
    id itemModel = nil;
    NSError *jerror = nil;
    
    switch (cardType) {
        case FHSearchCardTypeSecondHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNewHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeRentHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNeighborhood:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeSubscribe:
            itemModel = [[FHSugSubscribeDataDataSubscribeInfoModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNeighborExpert:
            itemModel = [[FHHouseNeighborAgencyModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeAgencyInfo:
            itemModel = [[FHSearchRealHouseAgencyInfo alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeFilterHouseTip:
            itemModel = [[FHSugListRealHouseTopInfoModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeGuessYouWantTip:
            itemModel = [[FHSearchGuessYouWantTipsModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeGuessYouWantContent:
            itemModel = [[FHSearchGuessYouWantContentModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        default:
            break;
    }
    return itemModel;
}

/*
 *  虚假房源列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params 已废弃
 */
+(TTHttpTask *)searchFakeHouseList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/search_fake_house";
    
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
    qparam[CHANNEL_ID] = CHANNEL_ID_RECOMMEND_SEARCH;
    if ([NSStringFromClass(cls) isEqualToString:NSStringFromClass([FHListSearchHouseModel class])]) {
        return [FHHouseListAPI querySearchData:queryPath uploadLog:YES params:qparam class:cls logPath:nil completion:completion];
    }
    return [FHMainApi queryData:queryPath uploadLog:YES params:qparam class:cls completion:completion];
    
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
    qparam[CHANNEL_ID] = CHANNEL_ID_SEARCH_COURT;
    if ([NSStringFromClass(cls) isEqualToString:NSStringFromClass([FHListSearchHouseModel class])]) {
        return [FHHouseListAPI querySearchData:queryPath uploadLog:YES params:qparam class:cls logPath:nil completion:completion];
    }
    return [FHMainApi queryData:queryPath uploadLog:YES params:qparam class:cls completion:completion];

}

/*
 *  小区列表请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNeighborhoodList:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/search_neighborhood";

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
    qparam[CHANNEL_ID] = CHANNEL_ID_SEARCH_NEIGHBORHOOD;
    if ([NSStringFromClass(cls) isEqualToString:NSStringFromClass([FHListSearchHouseModel class])]) {
        return [FHHouseListAPI querySearchData:queryPath uploadLog:YES params:qparam class:cls logPath:nil completion:completion];
    }
    return [FHMainApi queryData:queryPath uploadLog:YES params:qparam class:cls completion:completion];

}

/*
 *  租房请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchRent:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/search_rent";
    
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
    

    if ([NSStringFromClass(cls) isEqualToString:NSStringFromClass([FHListSearchHouseModel class])]) {
        return [FHHouseListAPI querySearchData:queryPath uploadLog:YES params:qparam class:cls logPath:nil completion:completion];
    }
    return [FHMainApi queryData:queryPath uploadLog:YES params:qparam class:cls completion:completion];
}

/*
 *  查成交请求
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchNeighborhoodDealList:(NSString *_Nullable)query searchType:(NSString *)searchType offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/search_neighborhood_deal";
    
    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        queryPath = [NSString stringWithFormat:@"%@?%@",queryPath,query];
    }
    qparam[@"offset"] = @(offset);
    qparam[@"search_id"] = searchId?:@"";
    if (searchType.length > 0) {
        qparam[@"search_type"] = searchType;
    }
    qparam[CHANNEL_ID] = CHANNEL_ID_SEARCH_NEIGHBORHOOD_DEAL;
    if ([NSStringFromClass(cls) isEqualToString:NSStringFromClass([FHListSearchHouseModel class])]) {
        return [FHHouseListAPI querySearchData:queryPath uploadLog:YES params:qparam class:cls logPath:nil completion:completion];
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



+(TTHttpTask *)requestAddSugSubscribe:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
{
    NSString *queryPath = @"/f100/api/add_subscribe";
    
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

+ (TTHttpTask *)requestDeleteSugSubscribe:(NSString *)subscribeId class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/delete_subscribe";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"subscribe_id"] = subscribeId;
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+(TTHttpTask *)requestCommute:(NSInteger)cityId query:(NSString *_Nullable)query location:(CLLocationCoordinate2D)location houseType:(FHHouseType)houseType duration:(CGFloat)duration type:(FHCommuteType)type param:(NSDictionary *_Nonnull)param offset:(NSInteger)offset completion:(void(^_Nullable)(FHListSearchHouseModel* _Nullable model , NSError * _Nullable error))completion
{
    //10.224.5.226:6789/f100/api/commuting?city_id=122&aim_longitude=116.307512&aim_latitude=39.982717&duration=900&commutingway=2&house_type=3'
    NSString *path = @"/f100/api/commuting";
    NSMutableDictionary *mparam = [NSMutableDictionary new];
    mparam[@"city_id"] = @(cityId);
    mparam[@"aim_longitude"] = @(location.longitude);
    mparam[@"aim_latitude"] = @(location.latitude);
    mparam[@"duration_sec"] = @(duration);
    mparam[@"house_type"] = @(houseType);
    mparam[@"commuting_way"] = @(type+1);
    mparam[@"offset"] = @(offset);
    mparam[@"count"] = @"20";
    if (param) {
        [mparam addEntriesFromDictionary:param];
    }
    if (query.length > 0) {
        path = [NSString stringWithFormat:@"%@?%@",path,query];
    }

    return [FHHouseListAPI querySearchData:path uploadLog:YES params:mparam class:[FHListSearchHouseModel class] logPath:nil completion:completion];
//    return [FHMainApi queryData:path params:mparam class:[FHHouseRentModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
//        if (completion) {
//            completion(model , error);
//        }
//    }];
}

+ (TTHttpTask *)requestSuggestionOnlyNeiborhoodCityId:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/get_suggestion";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"city_id"] = @(cityId);
    paramDic[@"house_type"] = @(houseType);
    paramDic[@"source"] = @"app";
    paramDic[@"only_neighborhood"] = @"1";
    if (query.length > 0) {
        paramDic[@"query"] = query;
    }
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];

}

// 查成交小区搜索
+ (TTHttpTask *)requestDealSuggestionCityId:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query searchType:(NSString *)searchType class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/get_suggestion";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"city_id"] = @(cityId);
    paramDic[@"house_type"] = @(houseType);
    paramDic[@"source"] = @"app";
    paramDic[@"search_type"] = searchType;

    if (query.length > 0) {
        paramDic[@"query"] = query;
    }
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (FHSearchHouseModel *)generateSearchModel:(NSData *)jsonData error:(NSError *__autoreleasing *)error
{
    if (*error) {
        //there is error
        return nil;
    }
    
    if (!jsonData) {
        *error = [NSError errorWithDomain:@"未请求到数据" code:API_NO_DATA userInfo:nil];
        return nil;
    }
    
    NSError *jerror = nil;
    FHSearchHouseModel *model = nil;
    model = [[FHSearchHouseModel alloc]initWithData:jsonData error:&jerror];
    if (jerror) {
#if DEBUG
        NSLog(@" %s %ld API [%@] make json failed",__FILE__,__LINE__,NSStringFromClass([FHSearchHouseModel class]));
#endif
        *error = [NSError errorWithDomain:@"数据异常" code:API_WRONG_DATA userInfo:nil];
        return nil;
    }
    
    if ([model respondsToSelector:@selector(status)]) {
        NSString *status = [model performSelector:@selector(status)];
        if (![@"0" isEqualToString:status]) {
            NSString *message = nil;
            if ([model respondsToSelector:@selector(message)]) {
                message = [model performSelector:@selector(message)];
            }
            *error = [NSError errorWithDomain:message?:DEFULT_ERROR code:[status integerValue] userInfo:nil];
        }
    }
    return model;
}


@end
