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
                    completion:(void(^)(FHDetailOldModel * _Nullable model , NSError * _Nullable error))completion
{

    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/house/info"];
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
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
//
//+(TTHttpTask*)requestNeighborhoodDetail:(NSString*)houseId
//                             completion:(void(^)(FHDetailNeighborhoodModel * _Nullable model , NSError * _Nullable error))completion
//{
//
//    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
//    NSString* url = [host stringByAppendingString:@"/f100/api/rental/info"];
//    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url
//                                                              params:@{@"rental_f_code": rentCode}
//                                                              method:@"GET"
//                                                    needCommonParams:YES
//                                                            callback:^(NSError *error, id obj) {
//                                                                FHRentDetailResponseModel *model = nil;
//                                                                if (!error) {
//                                                                    model = [[FHRentDetailResponseModel alloc] initWithData:obj error:&error];
//                                                                }
//
//                                                                if (![model.status isEqualToString:@"0"]) {
//                                                                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
//                                                                }
//
//                                                                if (completion) {
//                                                                    completion(model,error);
//                                                                }
//                                                            }];
//}
@end
