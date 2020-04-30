//
//  FHPriceValuationAPI.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationAPI.h"
#import "FHHouseDetailAPI.h"
#import "FHPostDataHTTPRequestSerializer.h"

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

//+ (TTHttpTask *)requestEvaluateWithParams:(NSDictionary *)params completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
//    NSString *queryPath = @"/f100/api/estimate_house_price";
//
//    Class cls = NSClassFromString(@"FHPriceValuationEvaluateModel");
//
//    return [FHMainApi queryData:queryPath params:params class:cls completion:completion];
//}

+ (TTHttpTask *)requestEvaluateWithParams:(NSDictionary *)params completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/api/estimate_house_price";
    NSString *url = QURL(queryPath);
    Class cls = NSClassFromString(@"FHPriceValuationEvaluateModel");
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:params method:GET needCommonParams:YES headerField:nil enableHttpCache:NO requestSerializer:nil responseSerializer:nil progress:nil callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSError *backError = error;
        id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:cls error:&backError];
        if (completion) {
            completion(model,backError);
        }
    } callbackInMainThread:NO];
    
    return [FHMainApi queryData:queryPath params:params class:cls completion:completion];
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

+ (TTHttpTask *)requestSubmitPhoneWithEstimateId:(NSString *)estimateId houseType:(FHHouseType)houseType phone:(NSString *)phone params:(NSDictionary *)params completion:(void (^)(BOOL, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/api/submit_phone";
    
    NSMutableString *url = QURL(queryPath).mutableCopy;
    [url appendString:[NSString stringWithFormat:@"?house_type=%ld",houseType]];
    if (phone.length > 0) {
        [url appendString:[NSString stringWithFormat:@"&phone=%@",phone]];
    }
    if (estimateId.length > 0) {
        [url appendString:[NSString stringWithFormat:@"&estimate_id=%@",estimateId]];
    }
    NSDictionary *postParams = params.count > 0 ? params : nil;
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:postParams method:POST needCommonParams:YES headerField:nil enableHttpCache:NO requestSerializer:[FHPostDataHTTPRequestSerializer class] responseSerializer:nil progress:nil callback:^(NSError *error, id obj, TTHttpResponse *response) {
        BOOL success = NO;
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        if (obj) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        
        if (completion) {
            completion(success,error);
        }
    } callbackInMainThread:YES];
}

+ (void)requestEvaluateResultWithParams:(NSDictionary *)params neighborhoodId:(NSString *)neighborhoodId completion:(void(^_Nullable)(NSDictionary *response , NSError *error))completion
{
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        __block NSError *errorTotal = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [FHHouseDetailAPI requestNeighborhoodDetail:neighborhoodId logPB:nil query:nil extraInfo:nil completion:^(FHDetailNeighborhoodModel * _Nullable model, NSError * _Nullable error) {
            if (model && !error) {
                resultDic[@"chartData"] = model;
            }else{
                errorTotal = error;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
        
        [FHPriceValuationAPI requestEvaluateWithParams:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
            if(!error){
                resultDic[@"evaluateData"] = model;
            }else{
                errorTotal = error;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            if(completion){
                completion(resultDic,errorTotal);
            }
        });
    });
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
    JSONModel *model = [[class alloc]initWithData:jsonData error:&jerror];
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

@end
