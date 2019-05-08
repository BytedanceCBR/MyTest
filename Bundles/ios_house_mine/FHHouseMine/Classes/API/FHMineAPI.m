//
//  FHMineAPI.m
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/13.
//

#import "FHMineAPI.h"
#import "FHHouseType.h"
#import "TTAccountManager+AccountInterfaceTask.h"

#define QURL(QPATH) [[self host] stringByAppendingString:QPATH]
#define GET @"GET"
#define API_ERROR_CODE  10000

@implementation FHMineAPI

+ (NSString *)host
{
    return [FHURLSettings baseURL];
}

+ (void)requestFocusInfoWithCompletion:(void(^_Nullable)(NSDictionary *response , NSError *error))completion
{
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务
        NSArray *typeArray = @[@(FHHouseTypeNewHouse),@(FHHouseTypeSecondHandHouse),@(FHHouseTypeRentHouse),@(FHHouseTypeNeighborhood)];
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        __block NSError *errorTotal = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        for (NSInteger i = 0; i < typeArray.count; i++) {
            NSInteger type = [typeArray[i] integerValue];
            [self requestFocusInfoWithType:type completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
                if(error){
                    errorTotal = error;
                }else{
                    [resultDic addEntriesFromDictionary:response];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
        }
        
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            if(completion){
                completion(resultDic,errorTotal);
            }
        });
    });
}


+ (TTHttpTask *)requestFocusInfoWithType:(NSInteger)type completion:(void(^_Nullable)(NSDictionary *response , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/get_user_follow";
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"house_type"] = @(type);
    
    NSString *url = QURL(queryPath);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES headerField:nil enableHttpCache:NO requestSerializer:nil responseSerializer:nil progress:nil callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        @try{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
            BOOL success = ([json[@"status"] integerValue] == 0);
            if(success){
                NSInteger count = [json[@"data"][@"total_count"] integerValue];
                [result setObject:@(count) forKey:@(type)];
            }
        }
        @catch(NSException *e){
            error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
        }
        
        if (completion) {
            completion(result, error);
        }
    } callbackInMainThread:NO];
}

+ (TTHttpTask *)requestFocusDetailInfoWithType:(NSInteger)type completion:(void(^_Nullable)(NSDictionary *response , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/get_user_follow";
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"house_type"] = @(type);
    
    NSString *url = QURL(queryPath);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES headerField:nil enableHttpCache:NO requestSerializer:nil responseSerializer:nil progress:nil callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        @try{
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
            BOOL success = ([json[@"status"] integerValue] == 0);
            if(success){
                NSInteger count = [json[@"data"][@"total_count"] integerValue];
                [result setObject:@(count) forKey:@(type)];
            }
        }
        @catch(NSException *e){
            error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
        }
        
        if (completion) {
            completion(result, error);
        }
    } callbackInMainThread:NO];
}

+ (TTHttpTask *)requestFocusDetailInfoWithType:(NSInteger)type offset:(NSInteger)offset searchId:(nullable NSString *)searchId limit:(NSInteger)limit className:(NSString *)className completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *queryPath = @"/f100/api/get_user_follow";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = @(type);
    paramDic[@"limit"] = @(limit);
    paramDic[@"offset"] = @(offset);
    if(searchId){
        paramDic[@"search_id"] = searchId;
    }
    
    Class cls = NSClassFromString(className);
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (void)requestSendVerifyCode:(NSString *)phoneNumber completion:(void(^_Nullable)(NSNumber *retryTime, UIImage *captchaImage, NSError *error))completion {
    [TTAccountManager startSendCodeWithPhoneNumber:phoneNumber captcha:nil type:TTASMSCodeScenarioQuickLogin unbindExist:NO completion:completion];
}

+ (void)requestQuickLogin:(NSString *)phoneNumber smsCode:(NSString *)smsCode completion:(void(^_Nullable)(UIImage *captchaImage, NSNumber *newUser, NSError *error))completion {
    [TTAccountManager startQuickLoginWithPhoneNumber:phoneNumber code:smsCode captcha:nil completion:completion];
}

+ (NSString *)errorMessageByErrorCode:(NSError *)error {
    switch (error.code) {
        case -106:
            return @"网络异常";
            break;
            
        default:
            return error.localizedDescription;
            break;
    }
}

@end
