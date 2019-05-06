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
#import <TTNetworkManager.h>
#import "FHPostDataHTTPRequestSerializer.h"
#import "FHFillFormAgencyListItemModel.h"

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000

@implementation FHMainApi (Contact)


// 详情页线索提交表单
+ (TTHttpTask*)requestSendPhoneNumbserByHouseId:(NSString*)houseId
                                          phone:(NSString*)phone
                                           from:(NSString*)from
                                     agencyList:(NSArray<FHFillFormAgencyListItemModel *> *)agencyList
                                     completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion {
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
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id jsonObj) {
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
        
        NSError *jerror = nil;
        FHDetailVirtualNumResponseModel *model = [[FHDetailVirtualNumResponseModel alloc] initWithDictionary:jsonObj error:&jerror];
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


@end
