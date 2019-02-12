//
//  FHHouseDetailAPI.m
//  FHHouseDetailAPI
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseDetailAPI.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailNewModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseType.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHDetailRentModel.h"
#import "FHHouseRentRelatedResponse.h"
#import "FHRentSameNeighborhoodResponse.h"

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000


@implementation FHHouseDetailAPI

+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                    completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion
{
    // FIXME: 是否要改成requestForJSONWithURL，线程区别
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/court/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"court_id"] = houseId ?: @"";
    paramDic[@"house_type"] = @(FHHouseTypeNewHouse);
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailNewModel *model = nil;
        if (!error) {
            model = [[FHDetailNewModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            completion(model,error);
        }
    } callbackInMainThread:YES];
}

+(TTHttpTask*)requestOldDetail:(NSString*)houseId
                         logPB:(NSDictionary *)logPB
                    completion:(void(^)(FHDetailOldModel * _Nullable model , NSError * _Nullable error))completion
{

    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/house/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (logPB) {
        [paramDic addEntriesFromDictionary:logPB];
    }
    paramDic[@"house_id"] = houseId ?: @"";
    paramDic[@"house_type"] = @(FHHouseTypeSecondHandHouse);
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailOldModel *model = nil;
        if (!error) {
            model = [[FHDetailOldModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

+(TTHttpTask*)requestNeighborhoodDetail:(NSString*)neighborhoodId
                                  logPB:(NSDictionary *)logPB
                                  query:(NSString*)query
                             completion:(void(^)(FHDetailNeighborhoodModel * _Nullable model , NSError * _Nullable error))completion
{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/neighborhood/info?neighborhood_id=%@",neighborhoodId];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (logPB) {
        [paramDic addEntriesFromDictionary:logPB];
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailNeighborhoodModel *model = nil;
        if (!error) {
            model = [[FHDetailNeighborhoodModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 租房详情页请求
+(TTHttpTask*)requestRentDetail:(NSString*)rentCode
                     completion:(void(^)(FHRentDetailResponseModel *model , NSError *error))completion {
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/rental/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"rental_f_code"] = rentCode;
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHRentDetailResponseModel *model = nil;
        if (!error) {
            model = [[FHRentDetailResponseModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 租房-周边房源
+ (TTHttpTask*)requestHouseRentRelated:(NSString*)rentId
                            completion:(void(^)(FHHouseRentRelatedResponseModel* model , NSError *error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/related_rent"];
    return [[TTNetworkManager shareInstance]
            requestForBinaryWithURL:url
            params:@{@"rent_id": rentId, @"count": @(5)}
            method:@"GET"
            needCommonParams:YES
            callback:^(NSError *error, id obj) {
                FHHouseRentRelatedResponseModel* model = nil;
                if (!error) {
                    model = [[FHHouseRentRelatedResponseModel alloc] initWithData:obj error:&error];
                }
                if (![model.status isEqualToString:@"0"]) {
                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }
                
                if (completion) {
                    completion(model,error);
                }
            }];
}

// 租房-同小区房源
+ (TTHttpTask*)requestHouseRentSameNeighborhood:(NSString*)rentId
                             withNeighborhoodId:(NSString*)neighborhoodId
                                     completion:(void(^)(FHRentSameNeighborhoodResponseModel* model , NSError *error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/same_neighborhood_rent"];
    return [[TTNetworkManager shareInstance]
            requestForBinaryWithURL:url
            params:@{@"rent_id": rentId,
                     @"neighborhood_id": neighborhoodId,
                     @"count": @(5),
                     }
            method:@"GET"
            needCommonParams:YES
            callback:^(NSError *error, id obj) {
                FHRentSameNeighborhoodResponseModel* model = nil;
                if (!error) {
                    model = [[FHRentSameNeighborhoodResponseModel alloc] initWithData:obj error:&error];
                }
                if (![model.status isEqualToString:@"0"]) {
                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }
                
                if (completion) {
                    completion(model,error);
                }
            }];
}

// 二手房-周边房源
+(TTHttpTask*)requestRelatedHouseSearch:(NSString*)houseId
                                 offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHDetailRelatedHouseResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_house?house_id=%@&offset=%ld",houseId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    if (![url containsString:@"count"]) {
        paramDic[@"count"] = @(count);
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailRelatedHouseResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailRelatedHouseResponseModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 二手房周边小区
+(TTHttpTask*)requestRelatedNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                      searchId:(NSString*)searchId
                                                        offset:(NSString *)offset
                                                         query:(NSString*)query
                                                         count:(NSInteger)count
                                                    completion:(void(^)(FHDetailRelatedNeighborhoodResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_neighborhood?neighborhood_id=%@&offset=%ld",neighborhoodId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    if (![url containsString:@"count"]) {
        paramDic[@"count"] = @(count);
    }
    if (searchId.length > 0) {
        paramDic[@"search_id"] = searchId;
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailRelatedNeighborhoodResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailRelatedNeighborhoodResponseModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 二手房-同小区房源
+(TTHttpTask*)requestHouseInSameNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                           houseId:(NSString*)houseId
                                                          searchId:(NSString*)searchId
                                                            offset:(NSString *)offset
                                                             query:(NSString*)query
                                                             count:(NSInteger)count
                                                        completion:(void(^)(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/same_neighborhood_house"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@?%@",url,query];
    }
    if (neighborhoodId.length > 0) {
        paramDic[@"neighborhood_id"] = neighborhoodId;
    }
    if (houseId.length > 0) {
        paramDic[@"house_id"] = houseId;
    }
    if (searchId.length > 0) {
        paramDic[@"search_id"] = searchId;
    }
    paramDic[@"count"] = @(count);
    paramDic[@"offset"] = offset;
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailSameNeighborhoodHouseResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailSameNeighborhoodHouseResponseModel alloc] initWithDictionary:jsonObj error:&error];
        }
        
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

@end
