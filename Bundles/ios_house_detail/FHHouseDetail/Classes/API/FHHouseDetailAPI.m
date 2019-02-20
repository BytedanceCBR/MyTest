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
#import "TTAccount.h"
#import "TTInstallIDManager.h"
#import "TTAccountUserEntity.h"
#import "FHDetailRelatedCourtModel.h"
#import "FHPostDataHTTPRequestSerializer.h"
#import "FHDetailNewCoreDetailModel.h"
#import "FHDetailFloorPanDetailInfoModel.h"
#import "FHTransactionHistoryModel.h"

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000


@implementation FHHouseDetailAPI

+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                         logPB:(NSDictionary *)logPB
                    completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion
{
    // FIXME: 是否要改成requestForJSONWithURL，线程区别
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
        if (!error) {
            model = [[FHDetailNewModel alloc] initWithDictionary:jsonObj error:&error];
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
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_house?house_id=%@&offset=%@",houseId,offset];
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

// 二手房（小区）-小区成交历史
+(TTHttpTask*)requestNeighborhoodTransactionHistoryByNeighborhoodId:(NSString*)neighborhoodId
                                                           searchId:(NSString*)searchId
                                                             offset:(NSString *)offset
                                                              count:(NSInteger)count
                                                         completion:(void(^)(FHTransactionHistoryModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/neighborhood/sale?neighborhood_id=%@&offset=%@",neighborhoodId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
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

// 详情页线索提交表单
+ (TTHttpTask*)requestSendPhoneNumbserByHouseId:(NSString*)houseId
                                         phone:(NSString*)phone
                                          from:(NSString*)from
                                    completion:(void(^)(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/call_report"];
    NSString *userName = [TTAccount sharedAccount].user.name ? : [TTInstallIDManager sharedInstance].deviceID; //如果没有名字，则取did
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (houseId.length > 0) {
        paramDic[@"a"] = houseId;
    }
    if (userName.length > 0) {
        paramDic[@"b"] = userName;
    }
    if (phone.length > 0) {
        paramDic[@"c"] = phone;
    }
    if (from.length > 0) {
        paramDic[@"d"] = from;
    }
//    - (TTHttpTask *)requestForBinaryWithURL:(NSString *)URL
//params:(id)params
//method:(NSString *)method
//needCommonParams:(BOOL)commonParams
//requestSerializer:(Class<TTHTTPRequestSerializerProtocol>)requestSerializer
//responseSerializer:(Class<TTBinaryResponseSerializerProtocol>)responseSerializer
//autoResume:(BOOL)autoResume
//callback:(TTNetworkObjectFinishBlock)callback
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id jsonObj) {

//    return [[TTNetworkManager shareInstance]requestForJSONWithResponse:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
//
//    }];
//    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {

        FHDetailResponseModel *model = nil;
        NSError *jerror = nil;
        if (!error) {
            model = [[FHDetailResponseModel alloc]initWithData:jsonObj error:&jerror];
        }
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        
        if (completion) {
            completion(model,error);
        }
    }];
}

// 中介转接电话
+ (TTHttpTask*)requestVirtualNumber:(NSString*)realtorId
                            houseId:(NSString*)houseId
                            houseType:(FHHouseType)houseType
                          searchId:(NSString*)searchId
                          imprId:(NSString*)imprId
                         completion:(void(^)(FHDetailVirtualNumResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/virtual_number"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (realtorId.length > 0) {
        paramDic[@"realtor_id"] = realtorId;
    }
    if (houseId.length > 0) {
        paramDic[@"house_id"] = houseId;
    }
    paramDic[@"house_type"] = @(houseType);
    if (searchId.length > 0) {
        paramDic[@"search_id"] = searchId;
    }
    if (imprId.length > 0) {
        paramDic[@"impr_id"] = imprId;
    }
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:GET needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailVirtualNumResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailVirtualNumResponseModel alloc] initWithDictionary:jsonObj error:&error];
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

// 房源关注
+ (TTHttpTask*)requestFollow:(NSString*)followId
                          houseType:(FHHouseType)houseType
                           actionType:(FHFollowActionType)actionType
                         completion:(void(^)(FHDetailUserFollowResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:[NSString stringWithFormat:@"/f100/api/user_follow?house_type=%ld",houseType]];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (followId.length > 0) {
        paramDic[@"follow_id"] = followId;
    }
    paramDic[@"action_type"] = @(actionType);

    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:POST needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailUserFollowResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailUserFollowResponseModel alloc] initWithDictionary:jsonObj error:&error];
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

// 房源取消关注
+ (TTHttpTask*)requestCancelFollow:(NSString*)followId
                   houseType:(FHHouseType)houseType
                  actionType:(FHFollowActionType)actionType
                  completion:(void(^)(FHDetailUserFollowResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:[NSString stringWithFormat:@"/f100/api/cancel_user_follow?house_type=%ld",houseType]];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (followId.length > 0) {
        paramDic[@"follow_id"] = followId;
    }
    paramDic[@"action_type"] = @(actionType);
    
    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:POST needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        FHDetailUserFollowResponseModel *model = nil;
        if (!error) {
            model = [[FHDetailUserFollowResponseModel alloc] initWithDictionary:jsonObj error:&error];
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

@end
