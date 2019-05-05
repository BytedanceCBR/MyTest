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
#import "FHDetailRelatedCourtModel.h"
#import "FHPostDataHTTPRequestSerializer.h"
#import "FHDetailNewCoreDetailModel.h"
#import "FHDetailFloorPanDetailInfoModel.h"
#import "FHTransactionHistoryModel.h"
#import <Heimdallr/HMDTTMonitor.h>

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000


@implementation FHHouseDetailAPI

+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                         logPB:(NSDictionary *)logPB
                    completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion
{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/court/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (logPB) {
        [paramDic addEntriesFromDictionary:logPB];
    }
    paramDic[@"court_id"] = houseId ?: @"";
    paramDic[@"house_type"] = @(FHHouseTypeNewHouse);
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailNewModel *model = nil;
        model = [[FHDetailNewModel alloc] initWithDictionary:jsonObj error:&error];
        if (model && !error) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

+(TTHttpTask*)requestOldDetail:(NSString *)houseId
                         ridcode:(NSString *)ridcode
                       realtorId:(NSString *)realtorId
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
    if (ridcode.length > 0) {
        paramDic[@"ridcode"] = ridcode;
    }
    if (realtorId.length > 0) {
        paramDic[@"realtor_id"] = realtorId;
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {

        FHDetailOldModel *model = nil;
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            model = [[FHDetailOldModel alloc] initWithDictionary:jsonObj error:&error];
        }
        if (model && !error) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
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
    if ([logPB isKindOfClass:[NSDictionary class]]) {
        [paramDic addEntriesFromDictionary:logPB];
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailNeighborhoodModel *model = nil;
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            model = [[FHDetailNeighborhoodModel alloc] initWithDictionary:jsonObj error:&error];
        }
        if (!error && model) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
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
    if (rentCode.length > 0) {
        paramDic[@"rental_f_code"] = rentCode;
    }
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHRentDetailResponseModel *model = nil;
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            model = [[FHRentDetailResponseModel alloc] initWithDictionary:jsonObj error:&error];
        }
        if (!error && model) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
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
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (rentId.length > 0) {
        paramDic[@"rent_id"] = rentId;
    }
    paramDic[@"count"] = @(5);
    __weak typeof(self)wself = self;
    return [[TTNetworkManager shareInstance]
            requestForBinaryWithURL:url
            params:paramDic
            method:@"GET"
            needCommonParams:YES
            callback:^(NSError *error, id obj) {
                FHHouseRentRelatedResponseModel* model = nil;
                if (!error) {
                    model = [[FHHouseRentRelatedResponseModel alloc] initWithData:obj error:nil];
                }
                if (!error && model) {
                    if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                        error = nil;
                    }else {
                        error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                        [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_rent" houseId:rentId status:model.status message:model.message userInfo:nil];
                    }
                }else if(model != nil) {
                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                    [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_rent" houseId:rentId status:model.status message:model.message userInfo:nil];
                }else {
                    [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_rent" houseId:rentId status:[NSString stringWithFormat:@"%ld",error.code] message:error.localizedDescription userInfo:error.userInfo];
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
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (rentId.length > 0) {
        paramDic[@"rent_id"] = rentId;
    }
    if (neighborhoodId.length > 0) {
        paramDic[@"neighborhood_id"] = neighborhoodId;
    }
    paramDic[@"count"] = @(5);
    __weak typeof(self)wself = self;
    return [[TTNetworkManager shareInstance]
            requestForBinaryWithURL:url
            params:paramDic
            method:@"GET"
            needCommonParams:YES
            callback:^(NSError *error, id obj) {
                FHRentSameNeighborhoodResponseModel* model = nil;
                if (!error) {
                    model = [[FHRentSameNeighborhoodResponseModel alloc] initWithData:obj error:nil];
                }
                if (!error && model) {
                    if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                        error = nil;
                    }else {
                        error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                        [wself addDetailRelatedRequestFailedLog:@"/f100/api/same_neighborhood_rent" houseId:rentId status:model.status message:model.message userInfo:nil];
                    }
                }else if(model != nil) {
                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                    [wself addDetailRelatedRequestFailedLog:@"/f100/api/same_neighborhood_rent" houseId:rentId status:model.status message:model.message userInfo:nil];
                }else {
                    [wself addDetailRelatedRequestFailedLog:@"/f100/api/same_neighborhood_rent" houseId:rentId status:[NSString stringWithFormat:@"%ld",error.code] message:error.localizedDescription userInfo:error.userInfo];
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
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_house?house_id=%@&offset=%@",houseId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    if (![url containsString:@"count"]) {
        paramDic[@"count"] = @(count);
    }
    __weak typeof(self)wself = self;
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailRelatedHouseResponseModel *model = nil;
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            model = [[FHDetailRelatedHouseResponseModel alloc] initWithDictionary:jsonObj error:nil];
        }
        if (!error && model) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_house" houseId:houseId status:model.status message:model.message userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_house" houseId:houseId status:model.status message:model.message userInfo:nil];
        }else {
            [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_house" houseId:houseId status:[NSString stringWithFormat:@"%ld",error.code] message:error.localizedDescription userInfo:error.userInfo];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 二手房(小区详情)周边小区
+(TTHttpTask*)requestRelatedNeighborhoodSearchByNeighborhoodId:(NSString*)neighborhoodId
                                                      searchId:(NSString*)searchId
                                                        offset:(NSString *)offset
                                                         query:(NSString*)query
                                                         count:(NSInteger)count
                                                    completion:(void(^)(FHDetailRelatedNeighborhoodResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_neighborhood?neighborhood_id=%@&offset=%@",neighborhoodId,offset];
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
    __weak typeof(self)wself = self;
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailRelatedNeighborhoodResponseModel *model = nil;
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]]) {
            model = [[FHDetailRelatedNeighborhoodResponseModel alloc] initWithDictionary:jsonObj error:&error];
        }
        if (!error && model) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_neighborhood" houseId:neighborhoodId status:model.status message:model.message userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_neighborhood" houseId:neighborhoodId status:model.status message:model.message userInfo:nil];
        }else {
            [wself addDetailRelatedRequestFailedLog:@"/f100/api/related_neighborhood" houseId:neighborhoodId status:[NSString stringWithFormat:@"%ld",error.code] message:error.localizedDescription userInfo:error.userInfo];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 二手房（小区）-小区成交历史
+(TTHttpTask*)requestNeighborhoodTransactionHistoryByNeighborhoodId:(NSString*)neighborhoodId
                                                           searchId:(NSString*)searchId
                                                               page:(NSInteger)page
                                                              count:(NSInteger)count
                                                              query:(NSString *)query
                                                         completion:(void(^)(FHTransactionHistoryModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/neighborhood/sale?neighborhood_id=%@",neighborhoodId];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"page"] = @(page);
    if (![url containsString:@"count"]) {
        paramDic[@"count"] = @(count);
    }
    if (searchId.length > 0) {
        paramDic[@"search_id"] = searchId;
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHTransactionHistoryModel *model = nil;
        if (!error) {
            model = [[FHTransactionHistoryModel alloc] initWithDictionary:jsonObj error:&error];
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

// 二手房（小区）-同小区房源
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
    if (offset.length > 0) {
        paramDic[@"offset"] = offset;
    } else {
        paramDic[@"offset"] = @"0";
    }
    __weak typeof(self)wself = self;
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailSameNeighborhoodHouseResponseModel *model = [[FHDetailSameNeighborhoodHouseResponseModel alloc] initWithDictionary:jsonObj error:&error];
        if (!error && model) {
            if ([model.status isEqualToString:@"0"] && [model.message isEqualToString:@"success"]) {
                error = nil;
            }else {
                error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
                [wself addDetailRelatedRequestFailedLog:@"/f100/api/same_neighborhood_house" houseId:neighborhoodId status:model.status message:model.message userInfo:nil];
            }
        }else if(model != nil) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:[model.status integerValue] userInfo:nil];
            [wself addDetailRelatedRequestFailedLog:@"/f100/api/same_neighborhood_house" houseId:neighborhoodId status:model.status message:model.message userInfo:nil];
        }else {
            [wself addDetailRelatedRequestFailedLog:@"/f100/api/same_neighborhood_house" houseId:neighborhoodId status:[NSString stringWithFormat:@"%ld",error.code] message:error.localizedDescription userInfo:error.userInfo];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    } callbackInMainThread:NO];
}

// 新房-周边新盘
+(TTHttpTask*)requestRelatedFloorSearch:(NSString*)houseId
                                 offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHDetailRelatedCourtModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_court?court_id=%@&offset=%@",houseId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }

    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailRelatedCourtModel *model = nil;
        if (!error) {
            model = [[FHDetailRelatedCourtModel alloc] initWithDictionary:jsonObj error:&error];
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

// 新房-楼盘动态
+(TTHttpTask*)requestFloorTimeLineSearch:(NSString*)houseId
                                  query:(NSString*)query
                             completion:(void(^)(FHDetailNewTimeLineResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:[NSString stringWithFormat:@"/f100/api/court/timeline?%@",query]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailNewTimeLineResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailNewTimeLineResponseModel alloc] initWithDictionary:jsonObj error:&error];
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

+(TTHttpTask*)requestFloorCoreInfoSearch:(NSString*)courtId
                              completion:(void(^)(FHDetailNewCoreDetailModel * _Nullable model , NSError * _Nullable error))completion
{
    
    if (![courtId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:[NSString stringWithFormat:@"/f100/api/court/detail?court_id=%@",courtId]];
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailNewCoreDetailModel *model = nil;
        if (!error) {
            model = [[FHDetailNewCoreDetailModel alloc] initWithDictionary:jsonObj error:&error];
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

+(TTHttpTask*)requestFloorPanDetailCoreInfoSearch:(NSString*)floorPanId
                                       completion:(void(^)(FHDetailFloorPanDetailInfoModel * _Nullable model , NSError * _Nullable error))completion
{
    if (![floorPanId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:[NSString stringWithFormat:@"/f100/api/floorplan/info?floorplan_id=%@",floorPanId]];
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailFloorPanDetailInfoModel *model = nil;
        if (!error) {
            model = [[FHDetailFloorPanDetailInfoModel alloc] initWithDictionary:jsonObj error:&error];
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

+(TTHttpTask*)requestFloorPanListSearch:(NSString*)courtId
                             completion:(void(^)(FHDetailFloorPanListResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    if (![courtId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:[NSString stringWithFormat:@"/f100/api/court/floorplan?court_id=%@",courtId]];
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailFloorPanListResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailFloorPanListResponseModel alloc] initWithDictionary:jsonObj error:&error];
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


+ (void)addDetailRelatedRequestFailedLog:(NSString *)urlStr houseId:(NSString *)houseId status:(NSString *)status message:(NSString *)message userInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    attr[@"message"] = message;
    attr[@"house_id"] = houseId;
    attr[@"url"] = urlStr;
    attr[@"user_info"] = userInfo;
    [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_request_related_failed" status:status.integerValue extra:attr];
}

@end
