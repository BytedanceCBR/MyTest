//
//  FHHomeRequestAPI.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import "FHHomeRequestAPI.h"
#import "FHMainApi.h"
#import <FHHomeHouseModel.h>
#import <TTNetworkManager.h>

#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define QURL(QPATH) [[self host] stringByAppendingString:QPATH]

@implementation FHHomeRequestAPI

+ (NSString *)host {
    return [FHURLSettings baseURL];
}

+ (TTHttpTask *)requestRecommendFirstTime:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion
{
   return [FHMainApi requestHomeRecommend:param completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        if (!completion) {
            return ;
        }
        completion(model,error);
    }];
}

+ (TTHttpTask *)requestRecommendForLoadMore:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion
{
   return  [FHMainApi requestHomeRecommend:param completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        if (!completion) {
            return ;
        }
        completion(model,error);
    }];
}

+ (TTHttpTask *)requestCitySearchByQuery:(NSString *)query class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/city_search";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query.length > 0) {
        paramDic[@"full_text"] = query;
    } else {
        paramDic[@"full_text"] = @"";
    }
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestHomeHouseDislike:(NSString *)houseId houseType:(FHHouseType)houseType dislikeInfo:(NSArray *)dislikeInfo completion:(void(^)(bool success , NSError *error))completion {
    NSString *queryPath = @"/f100/api/set_dislike_info";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(houseId){
        paramDic[@"house_id"] = @([houseId longLongValue]);
    }
    if(houseType){
        paramDic[@"house_type"] = @(houseType);
    }
    if(dislikeInfo){
        paramDic[@"dislike_info"] = dislikeInfo;
    }
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
            }
        }
        if (completion) {
            completion(success,error);
        }
    }];
}

@end
