//
//  FHPriceValuationAPI.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationAPI.h"


#define QURL(QPATH) [[self host] stringByAppendingString:QPATH]
#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define API_NO_DATA     10001
#define API_WRONG_DATA  10002

@implementation FHPriceValuationAPI

+ (NSString *)host
{
    return [FHURLSettings baseURL];
}

+ (TTHttpTask *)requestHistoryListWithCompletion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/get_history_estimate";
    
    Class cls = NSClassFromString(@"FHPriceValuationHistoryModel");
    
    return [FHMainApi queryData:queryPath params:nil class:cls completion:completion];
}

+ (TTHttpTask *)requestEvaluateWithParams:(NSDictionary *)params completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/api/estimate_house_price";
    
    Class cls = NSClassFromString(@"FHPriceValuationEvaluateModel");
    
    return [FHMainApi queryData:queryPath params:params class:cls completion:completion];
}

+ (TTHttpTask *)requestChartTrendWithNeiborhoodId:(NSString *)neiborhoodId completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion {
    NSString *queryPath = @"/f100/api/estimate_house_price";
    
    Class cls = NSClassFromString(@"FHPriceValuationEvaluateModel");
    
    return [FHMainApi queryData:queryPath params:nil class:cls completion:completion];
}

+ (TTHttpTask *)requestEvaluateEstimateWithParams:(NSDictionary *)params completion:(void(^_Nullable)(BOOL success, NSError *error))completion {
    NSString *queryPath = @"/f100/api/evaluate_estimate";
    
    NSString *url = QURL(queryPath);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:GET needCommonParams:YES headerField:nil enableHttpCache:NO requestSerializer:nil responseSerializer:nil progress:nil callback:^(NSError *error, id obj, TTHttpResponse *response) {
        BOOL success = NO;
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        @try{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
            success = ([json[@"status"] integerValue] == 0);
        }
        @catch(NSException *e){
            error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
        }
        
        if (completion) {
            completion(success,error);
        }
    } callbackInMainThread:YES];
}

+ (TTHttpTask *)requestSubmitPhoneWithParams:(NSDictionary *)params completion:(void (^)(BOOL, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/api/submit_phone";
    
    NSString *url = QURL(queryPath);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:GET needCommonParams:YES headerField:nil enableHttpCache:NO requestSerializer:nil responseSerializer:nil progress:nil callback:^(NSError *error, id obj, TTHttpResponse *response) {
        BOOL success = NO;
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        @try{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
            success = ([json[@"status"] integerValue] == 0);
        }
        @catch(NSException *e){
            error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
        }
        
        if (completion) {
            completion(success,error);
        }
    } callbackInMainThread:YES];
}

@end
