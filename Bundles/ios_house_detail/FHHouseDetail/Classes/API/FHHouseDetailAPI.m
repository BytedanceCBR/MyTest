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
#import "BDAgileLog.h"
#import <FHHouseBase/FHMainApi.h>
#import <TTInstallService/TTInstallIDManager.h>
#import "TTBaseMacro.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import "FHBuildingDetailModel.h"

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000


@implementation FHHouseDetailAPI

+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                         logPB:(NSDictionary *)logPB
                           ridcode:(NSString *)ridcode
                         realtorId:(NSString *)realtorId
                         extraInfo:(NSDictionary *)extraInfo
                    completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion
{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/court/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (logPB) {
        [paramDic addEntriesFromDictionary:logPB];
    }
    if (ridcode.length > 0) {
        paramDic[@"ridcode"] = ridcode;
    }
    if (realtorId.length > 0) {
        paramDic[@"realtor_id"] = realtorId;
    }
    paramDic[@"court_id"] = houseId ?: @"";
    paramDic[@"house_type"] = @(FHHouseTypeNewHouse);
    if (extraInfo) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:extraInfo options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data && string) {
            paramDic[kFHClueExtraInfo] = string;
        }
    }
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailNewModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailNewModel *)model,error);
        }
    }];
}

+(TTHttpTask*)requestOldDetail:(NSString *)houseId
                         ridcode:(NSString *)ridcode
                       realtorId:(NSString *)realtorId
                    bizTrace:(NSString *)bizTrace
                         logPB:(NSDictionary *)logPB
                     extraInfo:(NSDictionary *)extraInfo
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
    if ([bizTrace isKindOfClass:[NSString class]] && bizTrace.length > 0) {
        paramDic[@"biz_trace"] = bizTrace;
    }
    if (extraInfo) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:extraInfo options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data && string) {
            paramDic[kFHClueExtraInfo] = string;
        }
    }
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailOldModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailOldModel *)model,error);
        }
    }];
}

+(TTHttpTask*)requestNeighborhoodDetail:(NSString*)neighborhoodId
   ridcode:(NSString *)ridcode
 realtorId:(NSString *)realtorId
     logPB:(NSDictionary *)logPB
     query:(NSString*)query
 extraInfo:(NSDictionary *)extraInfo
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
    if (ridcode.length > 0) {
        paramDic[@"ridcode"] = ridcode;
    }
    if (realtorId.length > 0) {
        paramDic[@"realtor_id"] = realtorId;
    }
    if (extraInfo) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:extraInfo options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data && string) {
            paramDic[kFHClueExtraInfo] = string;
        }
    }
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailNeighborhoodModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailNeighborhoodModel *)model,error);
        }
    }];
}

// 租房详情页请求
+(TTHttpTask*)requestRentDetail:(NSString*)rentCode
                      extraInfo:(NSDictionary *)extraInfo
                     completion:(void(^)(FHRentDetailResponseModel *model , NSError *error))completion {
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/rental/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (rentCode.length > 0) {
        paramDic[@"rental_f_code"] = rentCode;
    }
    if (extraInfo) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:extraInfo options:0 error:nil];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data && string) {
            paramDic[kFHClueExtraInfo] = string;
        }
    }
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHRentDetailResponseModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHRentDetailResponseModel *)model,error);
        }
    }];
}

// 租房-周边房源
+ (TTHttpTask*)requestHouseRentRelated:(NSString*)rentId class:(Class)cls
                            completion:(void(^)(FHListResultHouseModel *model, NSError *error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/related_rent"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (rentId.length > 0) {
        paramDic[@"rent_id"] = rentId;
    }
    paramDic[@"count"] = @(5);
    paramDic[CHANNEL_ID] = CHANNEL_ID_RELATED_RENT;
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:cls completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
//        FHHouseRentRelatedResponseModel* model = (FHHouseRentRelatedResponseModel*)m;
        if (completion) {
            completion((FHListResultHouseModel *)model,error);
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
    paramDic[CHANNEL_ID] = CHANNEL_ID_SAME_NEIGHBORHOOD_RENT;
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHRentSameNeighborhoodResponseModel class] completion:^(JSONModel * _Nullable m, NSError * _Nullable error) {
        FHRentSameNeighborhoodResponseModel* model = (FHRentSameNeighborhoodResponseModel*)m ;
        if (completion) {
            completion(model,error);
        }
    }];
    
}

// 二手房-周边房源
+(TTHttpTask*)requestRelatedHouseSearch:(NSString*)houseId
                                 searchId:(NSString *)searchId
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
    paramDic[@"search_id"] = searchId ?: @"";
    paramDic[CHANNEL_ID] = CHANNEL_ID_RELATED_HOUSE;
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailRelatedHouseResponseModel class] completion:^(JSONModel * _Nullable m, NSError * _Nullable error) {
        FHDetailRelatedHouseResponseModel *model = (FHDetailRelatedHouseResponseModel *)m;
        if (completion) {
            completion(model,error);
        }
    }];
    
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
    paramDic[CHANNEL_ID] = CHANNEL_ID_RELATED_NEIGHBORHOOD;
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailRelatedNeighborhoodResponseModel class] completion:^(JSONModel * _Nullable m, NSError * _Nullable error) {
        FHDetailRelatedNeighborhoodResponseModel *model = (FHDetailRelatedNeighborhoodResponseModel *)m;
        if (completion) {
            completion(model,error);
        }
    }];
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
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHTransactionHistoryModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHTransactionHistoryModel *)model,error);
        }
    }];
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
    paramDic[CHANNEL_ID] = CHANNEL_ID_SAME_NEIGHBORHOOD_HOUSE;
//    __weak typeof(self)wself = self;
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailSameNeighborhoodHouseResponseModel class] completion:^(JSONModel * _Nullable m, NSError * _Nullable error) {
        FHDetailSameNeighborhoodHouseResponseModel *model = (FHDetailSameNeighborhoodHouseResponseModel *)m;

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,error);
            });
        }
    }];
    
}

// 二手房-推荐新盘
+(TTHttpTask*)requestOldHouseRecommendedCourtSearch:(NSString*)houseId
                                 offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHListResultHouseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_court?house_id=%@&offset=%@",houseId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    paramDic[CHANNEL_ID] = CHANNEL_ID_RECOMMEND_COURT_OLD;
    paramDic[@"count"] = @(count);
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHListResultHouseModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHListResultHouseModel *)model,error);
        }
    }];
}

// 新房-周边新盘
+(TTHttpTask*)requestRelatedFloorSearch:(NSString*)houseId
                                 offset:(NSString *)offset
                                  query:(NSString*)query
                                  count:(NSInteger)count
                             completion:(void(^)(FHListResultHouseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/related_court?court_id=%@&offset=%@",houseId,offset];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [NSString stringWithFormat:@"%@&%@",url,query];
    }
    paramDic[CHANNEL_ID] = CHANNEL_ID_RELATED_COURT;
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHListResultHouseModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHListResultHouseModel *)model,error);
        }
    }];
}

// 新房-楼盘动态
+(TTHttpTask*)requestFloorTimeLineSearch:(NSString*)houseId
                                  query:(NSString*)query
                             completion:(void(^)(FHDetailNewTimeLineResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/court/timeline?%@",query];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    
    return [FHMainApi getRequest:url query:nil params:paramDic jsonClass:[FHDetailNewTimeLineResponseModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailNewTimeLineResponseModel *)model,error);
        }
    }];
    
//    return [[TTNetworkManager shareInstance]requestForJSONWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
//
//        FHDetailNewTimeLineResponseModel *model = nil;
//        if (!error) {
//            model = [[FHDetailNewTimeLineResponseModel alloc] initWithDictionary:jsonObj error:&error];
//        }
//
//        if (![model.status isEqualToString:@"0"]) {
//            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
//        }
//
//        if (completion) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                completion(model,error);
//            });
//        }
//    } callbackInMainThread:NO];
}

+(TTHttpTask*)requestFloorCoreInfoSearch:(NSString*)courtId
                              completion:(void(^)(FHDetailNewCoreDetailModel * _Nullable model , NSError * _Nullable error))completion
{
    
    if (![courtId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/court/detail?court_id=%@",courtId];
    
    return [FHMainApi getRequest:url query:nil params:nil jsonClass:[FHDetailNewCoreDetailModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailNewCoreDetailModel *)model,error);
        }
    }];
}

+(TTHttpTask*)requestFloorPanDetailCoreInfoSearch:(NSString*)floorPanId
                                       completion:(void(^)(FHDetailFloorPanDetailInfoModel * _Nullable model , NSError * _Nullable error))completion
{
    if (![floorPanId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/floorplan/info?floorplan_id=%@",floorPanId];
    
    return [FHMainApi getRequest:url query:nil params:nil jsonClass:[FHDetailFloorPanDetailInfoModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailFloorPanDetailInfoModel *)model,error);
        }
    }];
    
}

+(TTHttpTask*)requestFloorPanListSearch:(NSString*)courtId
                             completion:(void(^)(FHDetailFloorPanListResponseModel * _Nullable model , NSError * _Nullable error))completion
{
    if (![courtId isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/court/floorplan?court_id=%@",courtId];
    return [FHMainApi getRequest:url query:nil params:nil jsonClass:[FHDetailFloorPanListResponseModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHDetailFloorPanListResponseModel *)model,error);
        }
    }];    
}

/*
 - target_id 类型int64，房源id
 - target_type 类型int，房源的类型 1 新房，2 二手房，3 租房，4 小区
 - type 类型int，反馈类型（推荐该公司房源：1）
 source 类型string，反馈来源（官方直验收：official）
 - device_id 类型int64，设备的id
 - agency_id 类型int64，经纪公司的id
 - feed_back 类型int，反馈的结果：0表示空，1表示是，2表示否
 */

+(TTHttpTask *)requstQualityFeedback:(NSString *)houseId houseType:(FHHouseType)houseType source:(NSString *)source feedBack:(NSInteger)feedType agencyId:(NSString *)agencyId completion:(void (^)(bool succss , NSError *error))completion
{
    NSString *path = @"/f100/user/quality_feedback";
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    if ([source isEqualToString:@"official"]) {
        path =  @"/f100/user/agency_feedback";
        param[@"agency_id"] = @(agencyId.longLongValue);
    }
    
    param[@"target_id"] = @(houseId.longLongValue);
    param[@"target_type"] = @(houseType);
    param[@"source"] = source;
    param[@"device_id"] = @([[[TTInstallIDManager sharedInstance] deviceID] longLongValue]);
    param[@"feed_back"] = @(feedType);
    
    return [FHMainApi postJsonRequest:path query:nil params:param completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        BOOL success = NO;
        if (result) {
            success = (result[@"status"] && [result[@"status"] integerValue] == 0);
            if (!success) {
                error = [NSError errorWithDomain:result[@"message"]?:@"请求失败" code:-1 userInfo:nil];
            }
        }
        if (completion) {
            completion(success , error);
        }
    }];
}

+ (TTHttpTask *)requestPhoneFeedback:(NSString *)houseId houseType:(FHHouseType)houseType realtorId:(NSString *)realtorId imprId:(NSString *)imprId searchId:(NSString *)searchId score:(NSInteger)score requestId:(NSString*) requestId completion:(void (^)(bool, NSError * _Nonnull))completion {
    NSString *path = @"/f100/api/phone/feedback";
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[@"target_id"] = @(houseId.longLongValue);
    param[@"target_type"] = @(houseType);
    param[@"feedback_score"] = @(score);
    if(houseType == FHHouseTypeSecondHandHouse){
        param[@"enterfrom"] = @"app_oldhouse";
    }
    if(!isEmptyString(imprId)){
        param[@"impr_id"] = imprId;
    }
    if(!isEmptyString(searchId)){
        param[@"search_id"] = searchId;
    }
    if(!isEmptyString(realtorId)){
        param[@"realtor_id"] = @(realtorId.longLongValue);;
    }
    
    if(!isEmptyString(requestId)) {
        param[@"request_id"] = requestId;
    }
    
    return [FHMainApi postJsonRequest:path query:nil params:param completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        BOOL success = NO;
        if (result) {
            success = (result[@"status"] && [result[@"status"] integerValue] == 0);
            if (!success) {
                error = [NSError errorWithDomain:result[@"message"]?:@"请求失败" code:-1 userInfo:nil];
            }
        }
        if (completion) {
            completion(success , error);
        }
    }];
}


+ (TTHttpTask *)requestRealtorEvaluationFeedback:(NSString *)targetId targetType:(NSInteger)targetType evaluationType:(NSInteger)evaluationType realtorId:(NSString *)realtorId content:(NSString *)content score:(NSInteger)score tags: (NSArray*)tags completion:(void (^)(bool, NSError * _Nullable))completion {
    return [self requestRealtorEvaluationFeedback:targetId targetType:targetType evaluationType:evaluationType realtorId:realtorId content:content score:score tags:tags from:nil completion:completion];
}
+ (TTHttpTask *)requestRealtorEvaluationFeedback:(NSString *)targetId targetType:(NSInteger)targetType evaluationType:(NSInteger)evaluationType realtorId:(NSString *)realtorId content:(NSString *)content score:(NSInteger)score tags: (NSArray*)tags from:(NSString * _Nullable)from completion:(void (^)(bool, NSError * _Nullable))completion {

    NSString *path = @"/f100/api/associate/realtor_evaluation/assign";
    NSMutableDictionary *param = [NSMutableDictionary new];
    if(!isEmptyString(realtorId)){
        param[@"realtor_id"] = @(realtorId.longLongValue);;
    }
    // evaluationType[int]:反馈类型 0:电话后反馈 1:IM反馈
    if (evaluationType == 1) {
        param[@"target_id"] = @(targetId.longLongValue);
        param[@"target_type"] = @(targetType);
    }else {
        param[@"house_id"] = @(targetId.longLongValue);
    }
    param[@"type"] = @(evaluationType);
    param[@"score"] = @(score);
    if(!isEmptyString(content)) {
        param[@"content"] = content;
    }
    param[@"tag_ids"] = tags;
    if (from) {
        param[@"element_from"] = from;
    }
    
    return [FHMainApi postJsonRequest:path query:nil params:param completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        BOOL success = NO;
        if (result) {
            success = (result[@"status"] && [result[@"status"] integerValue] == 0);
            if (!success) {
                error = [NSError errorWithDomain:result[@"message"]?:@"请求失败" code:-1 userInfo:nil];
            }
        }
        if (completion) {
            completion(success , error);
        }
    }];
}

//1.0.2 楼栋详情
+(TTHttpTask*)requestBuildingDetail:(NSString*)courtId
                         completion:(void(^)(FHBuildingDetailModel * _Nullable model , NSError * _Nullable error))completion {
    if (!courtId.length) {
        return nil;
    }
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingFormat:@"/f100/api/building/info"];
    return [FHMainApi getRequest:url query:nil params:@{@"court_id": courtId?:@""} jsonClass:[FHBuildingDetailModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion((FHBuildingDetailModel *)model, error);
        }
    }];
}

@end
