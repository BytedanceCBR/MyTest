//
//  FHMainApi+Contact.m
//  FHHouseBase
//
//  Created by 张静 on 2019/4/25.
//

#import "FHMainApi+Contact.h"
#import <TTAccountSDK/TTAccount.h>
#import <TTInstallService/TTInstallIDManager.h>
#import <TTAccountSDK/TTAccountUserEntity.h>
#import "FHURLSettings.h"
#import "TTNetworkManager.h"
#import "FHPostDataHTTPRequestSerializer.h"
#import "FHFillFormAgencyListItemModel.h"
#import "FHEnvContext.h"
#import <Heimdallr/HMDTTMonitor.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/FHHouseContactDefines.h>
#import <JSONModel/JSONModel.h>

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000


@implementation FHMainApi (Contact)


//快速问答 表单
+ (TTHttpTask*)requestQuickQuestionByHouseId:(NSString*)houseId
                                          phone:(NSString*)phone
                                           from:(NSString*)from
                                           type:(NSNumber*)type
                                     completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/call_report/v2"];
    NSString *userName = [TTAccount sharedAccount].user.name ? : [TTInstallIDManager sharedInstance].deviceID; //如果没有名字，则取did
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (houseId.length > 0) {
        paramDic[@"house_id"] = houseId;
    }
    if (userName.length > 0) {
        paramDic[@"user_name"] = userName;
    }
    if (phone.length > 0) {
        paramDic[@"user_phone"] = phone;
    }
    if (from.length > 0) {
        paramDic[@"from"] = from;
    }
    
    if (type > 0) {
        paramDic[@"target_type"] = type;
    }
    paramDic[@"city_id"] = [FHEnvContext getCurrentSelectCityIdFromLocal];

    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        FHDetailResponseModel *model = nil;
        NSError *jerror = nil;
        if (!error) {
            model = [[FHDetailResponseModel alloc]initWithData:jsonObj error:&jerror];
        }
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
        }
        if (response.statusCode == 200) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    if (status) {
                        extraDict[@"error_code"] = status;
                    }
                    extraDict[@"message"] = model.message ? : error.domain;
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                }
            }
        }else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
        }
        [self addClueFormErrorRateLog:categoryDict extraDict:extraDict];
        if (completion) {
            completion(model,error);
        }
    }];
}
// 详情页线索提交表单
+ (TTHttpTask*)requestSendPhoneNumbserByHouseId:(NSString*)houseId
                                          phone:(NSString*)phone
                                           from:(NSString*)from
                                     agencyList:(NSArray<FHFillFormAgencyListItemModel *> *)agencyList
                                     completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    [self requestSendPhoneNumbserByHouseId:houseId phone:phone from:from cluePage:nil clueEndpoint:nil targetType:nil agencyList:agencyList completion:completion];
}
// 详情页线索提交表单
+ (TTHttpTask*)requestSendPhoneNumbserByHouseId:(NSString*)houseId
                                          phone:(NSString*)phone
                                           from:(NSString*)from
                                       cluePage:(NSNumber*)cluePage
                                   clueEndpoint:(NSNumber*)clueEndpoint
                                     targetType:(NSNumber *)targetType
                                     agencyList:(NSArray<FHFillFormAgencyListItemModel *> *)agencyList
                                     completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/call_report"];
    NSString *userName = [TTAccount sharedAccount].user.name ? : [TTInstallIDManager sharedInstance].deviceID; //如果没有名字，则取did
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (houseId.length > 0) {
        paramDic[@"house_id"] = houseId;
    }
    if (userName.length > 0) {
        paramDic[@"user_name"] = userName;
    }
    if (phone.length > 0) {
        paramDic[@"user_phone"] = phone;
    }
    if (targetType) {
        paramDic[@"target_type"] = targetType;
    }
    if (cluePage) {
        paramDic[@"page"] = cluePage;
        paramDic[@"endpoint"] = clueEndpoint ? clueEndpoint : @(FHClueEndPointTypeC);
    }else if (from.length > 0) {
        paramDic[@"from"] = from;
    }
    if (agencyList.count > 0) {
        NSMutableArray *array = @[].mutableCopy;
        for (FHFillFormAgencyListItemModel *item in agencyList) {
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"agency_id"] = item.agencyId;
            dict[@"checked"] = [NSNumber numberWithInt:item.checked];
            if (dict.count > 0) {
                [array addObject:dict];
            }
        }
        paramDic[@"choose_agency_list"] = array;
    }
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:paramDic method:POST needCommonParams:YES requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        FHDetailResponseModel *model = nil;
        NSError *jerror = nil;
        if (!error) {
            model = [[FHDetailResponseModel alloc]initWithData:jsonObj error:&jerror];
        }
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
        }
        if (response.statusCode == 200) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    if (status) {
                        extraDict[@"error_code"] = status;
                    }
                    extraDict[@"message"] = model.message ? : error.domain;
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                }
            }
        }else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
        }
        [self addClueFormErrorRateLog:categoryDict extraDict:extraDict];
        if (completion) {
            completion(model,error);
        }
    }];
}

+ (TTHttpTask*)requestVirtualNumber:(NSString*)realtorId
                            houseId:(NSString*)houseId
                          houseType:(FHHouseType)houseType
                           searchId:(NSString*)searchId
                             imprId:(NSString*)imprId
                               from:(NSString*)fromStr
                         completion:(void(^)(FHDetailVirtualNumResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    [self requestVirtualNumber:realtorId houseId:houseId houseType:houseType searchId:searchId imprId:imprId from:fromStr cluePage:nil clueEndpoint:nil completion:completion];
}

// 中介转接电话
+ (TTHttpTask*)requestVirtualNumber:(NSString*)realtorId
                            houseId:(NSString*)houseId
                          houseType:(FHHouseType)houseType
                           searchId:(NSString*)searchId
                             imprId:(NSString*)imprId
                             from:(NSString*)fromStr
                               cluePage:(NSNumber*)cluePage
                               clueEndpoint:(NSNumber*)clueEndpoint
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

    if (cluePage) {
        paramDic[@"page"] = cluePage;
        paramDic[@"endpoint"] = clueEndpoint ? clueEndpoint : @(FHClueEndPointTypeC);
    }else if (fromStr.length > 0) {
        paramDic[@"enterfrom"] = fromStr;
    }

    return [[TTNetworkManager shareInstance]requestForJSONWithResponse:url params:paramDic method:GET needCommonParams:YES callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        
        NSError *jerror = error;
        FHDetailVirtualNumResponseModel *model = [[FHDetailVirtualNumResponseModel alloc] initWithDictionary:jsonObj error:&jerror];
        if (![model.status isEqualToString:@"0"]) {
            jerror = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
        }
        if (response.statusCode == 200) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    if (status) {
                        extraDict[@"error_code"] = status;
                    }
                    extraDict[@"message"] = model.message ? : error.domain;
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                    extraDict[@"request_url"] = response.URL.absoluteString;
                    extraDict[@"response_headers"] = response.allHeaderFields;
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                }
            }
        }else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
        }
        [self addClueCallErrorRateLog:categoryDict extraDict:extraDict];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,jerror);
            });
        }
    }];
}

+ (TTHttpTask*)requestVirtualNumber:(NSDictionary*)phoneAssociate
                          realtorId:(NSString*)realtorId
                           houseId:(NSString*)houseId
                         houseType:(FHHouseType)houseType
                          searchId:(NSString*)searchId
                            imprId:(NSString*)imprId
                         completion:(void(^)(FHDetailVirtualNumResponseModel * _Nullable model , NSError * _Nullable error))completion
{
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
    if (phoneAssociate) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:phoneAssociate options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data && string) {
            paramDic[@"phone_associate"] = string;
        }
    }

    return [[TTNetworkManager shareInstance]requestForJSONWithResponse:url params:paramDic method:GET needCommonParams:YES callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        
        NSError *jerror = error;
        FHDetailVirtualNumResponseModel *model = [[FHDetailVirtualNumResponseModel alloc] initWithDictionary:jsonObj error:&jerror];
        if (![model.status isEqualToString:@"0"]) {
            jerror = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
        }
        if (response.statusCode == 200) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    if (status) {
                        extraDict[@"error_code"] = status;
                    }
                    extraDict[@"message"] = model.message ? : error.domain;
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                    extraDict[@"request_url"] = response.URL.absoluteString;
                    extraDict[@"response_headers"] = response.allHeaderFields;
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                }
            }
        }else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
        }
        [self addClueCallErrorRateLog:categoryDict extraDict:extraDict];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,jerror);
            });
        }
    }];
}

+ (TTHttpTask*)requestCallReport:(NSDictionary*)reportAssociate
agencyList:(NSArray<FHFillFormAgencyListItemModel *> *)agencyList
completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/call_report"];
    NSString *userName = [TTAccount sharedAccount].user.name ? : [TTInstallIDManager sharedInstance].deviceID; //如果没有名字，则取did
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (agencyList.count > 0) {
        NSMutableArray *array = @[].mutableCopy;
        for (FHFillFormAgencyListItemModel *item in agencyList) {
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"agency_id"] = item.agencyId;
            dict[@"checked"] = [NSNumber numberWithInt:item.checked];
            if (dict.count > 0) {
                [array addObject:dict];
            }
        }
        paramDic[@"choose_agency_list"] = array;
    }
    paramDic[kFHAssociateInfo] = reportAssociate;

    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:paramDic method:POST needCommonParams:YES requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id jsonObj, TTHttpResponse *response) {
        FHDetailResponseModel *model = nil;
        NSError *jerror = nil;
        if (!error) {
            model = [[FHDetailResponseModel alloc]initWithData:jsonObj error:&jerror];
        }
        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
        }
        if (response.statusCode == 200) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    if (status) {
                        extraDict[@"error_code"] = status;
                    }
                    extraDict[@"message"] = model.message ? : error.domain;
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                }
            }
        }else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
        }
        [self addClueFormErrorRateLog:categoryDict extraDict:extraDict];
        if (completion) {
            completion(model,error);
        }
    }];
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

+ (void)addClueFormErrorRateLog:categoryDict extraDict:(NSDictionary *)extraDict
{
    [[HMDTTMonitor defaultManager]hmdTrackService:@"clue_form_error_rate" metric:nil category:categoryDict extra:extraDict];
}

+ (void)addClueCallErrorRateLog:categoryDict extraDict:(NSDictionary *)extraDict
{
    [[HMDTTMonitor defaultManager]hmdTrackService:@"clue_call_error_rate" metric:nil category:categoryDict extra:extraDict];
}


@end
