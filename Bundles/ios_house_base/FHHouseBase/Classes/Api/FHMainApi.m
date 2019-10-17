//
//  FHMainApi.m
//  FHBMain
//
//  Created by 谷春晖 on 2018/11/14.
//

#import "FHMainApi.h"
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHHouseType.h"
#import "FHCommonDefines.h"
#import <TTSandBoxHelper.h>
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import "FHJSONHTTPRequestSerializer.h"
#import "FHEnvContext.h"
#import <YYModel/YYModel.h>
#import <FHHouseBase/FHSearchChannelTypes.h>
#import <Heimdallr/HMDTTMonitor.h>

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define API_NO_DATA     10001
#define API_WRONG_DATA  10002


#define QURL(QPATH) [[self host] stringByAppendingString:QPATH]

@implementation FHMainApi

+(NSString *)host
{
    return [FHURLSettings baseURL];
}

/*
 city_id, gaode_city_id, gaode_lng, gaode_lat, gaode_city_name
 */

+(TTHttpTask *)getConfig:(NSInteger )cityId gaodeLocation:(CLLocationCoordinate2D)location gaodeCityId:(NSString *)gCityId gaodeCityName:(NSString *)gCityName completion:(void(^)(FHConfigModel* model , NSError *error))completion
{
    NSString *url = QURL(@"/f100/v2/api/config");
    
    NSDictionary *commonParams = [TTNetworkManager shareInstance].commonParamsblock();
    
    NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] initWithDictionary:commonParams];
    
    if (cityId > 0) {
        [requestParam setValue:@(cityId) forKey:@"city_id"];
    }else
    {
        [requestParam setValue:nil forKey:@"city_id"];
        [requestParam setValue:nil forKey:@"f_city_id"];
    }
    
    if ([gCityName isKindOfClass:[NSString class]]){
        requestParam[@"city_name"] = gCityName;
    }

    if ([TTSandBoxHelper isAPPFirstLaunchForAd]) {
        requestParam[@"app_first_start"] = @(1);
    }else
    {
        requestParam[@"app_first_start"] = @(0);
    }
    
    NSString *lastCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if ([lastCityId isKindOfClass:[NSString class]]) {
        requestParam[@"last_city_id"] = lastCityId;
    }else
    {
        requestParam[@"last_city_id"] = @"";
    }
    
    if ([FHEnvContext sharedInstance].refreshConfigRequestType) {
        requestParam[@"request_type"] = [FHEnvContext sharedInstance].refreshConfigRequestType;
    }

    double longitude = location.longitude;
    double latitude = location.latitude;

    if (longitude != 0 && longitude != 0) {
        requestParam[@"gaode_lng"] = @(longitude);
        requestParam[@"gaode_lat"] = @(latitude);
        requestParam[@"longitude"] = @(longitude);
        requestParam[@"latitude"] = @(latitude);
    }
    
    if ([gCityId isKindOfClass:[NSString class]]) {
        requestParam[@"gaode_city_id"] = gCityId;
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:requestParam method:GET needCommonParams:false callback:^(NSError *error, id obj) {
        __block NSError *backError = error;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            FHConfigModel *model = [self generateModel:obj class:[FHConfigModel class] error:&backError useYYModel:YES];

            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
    }];
    
}


/*
 *  租房请求
 *  @param: query 筛选等请求
 *  @param: param 其他请求参数
 *  @param: offset 偏移
 *  @param: searchId 请求id
 *  @param: sugParam  suggestion params
 */
+(TTHttpTask *)searchRent:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam completion:(void(^_Nullable)(FHHouseRentModel *model , NSError *error))completion
{
    NSString *url = QURL(@"/f100/api/search_rent?");
    
    NSMutableDictionary *qparam = [NSMutableDictionary new];
    if (query.length > 0) {
        url = [url stringByAppendingString:query];
    }
    if (param) {
        [qparam addEntriesFromDictionary:param];
    }
    qparam[@"offset"] = @(offset);
    qparam[@"search_id"] = searchId?:@"";
    if (sugParam) {
        qparam[@"suggestion_params"] = sugParam;
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:qparam method:GET needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        FHHouseRentModel *model = (FHHouseRentModel *)[self generateModel:obj class:[FHHouseRentModel class] error:&error];
        
        if (response.statusCode == 200 && [model isKindOfClass:[FHHouseRentModel class]]) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    NSMutableDictionary *extraDict = @{}.mutableCopy;
                    extraDict[@"request_url"] = response.URL.absoluteString;
                    extraDict[@"response_headers"] = response.allHeaderFields;
                    extraDict[@"error"] = error.domain;
                    [self addServerFailerLog:model.status extraDict:extraDict];
                }
            }
        }
        if (completion) {
            completion(model,error);
        }
    }];
}

/**
 * 同小区租房信息  /f100/api/same_neighborhood_rent
 * query need:
 *   exclude_id[]
 *   exclude_id[]
 *   neighborhood_id[]
 *   neighborhood_id[]
 * param need:
 *   house_type
 */
+(TTHttpTask *_Nullable)sameNeighborhoodRentSearchWithQuery:(NSString *_Nullable)query param:(NSDictionary * _Nonnull)queryParam searchId:(NSString *_Nullable)searchId offset:(NSInteger)offset needCommonParams:(BOOL)needCommonParams completion:(void(^_Nullable )(NSError *_Nullable error , FHHouseRentModel *_Nullable model))completion
{
    NSString *host = QURL(@"/f100/api/same_neighborhood_rent?");
    if (query.length > 0) {
        host = [host stringByAppendingString:query];
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"offset"] = @(offset);
    if (searchId) {
        param[@"searchId"] = searchId;
    }
    param[CHANNEL_ID] = CHANNEL_ID_SAME_NEIGHBORHOOD_RENT;

    if (![query containsString:@"house_type"] && !queryParam[@"house_type"]) {
        param[@"house_type"] = @(FHHouseTypeRentHouse);
    }
    
    [param addEntriesFromDictionary:queryParam];
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:host params:param method:@"GET" needCommonParams:needCommonParams callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (!completion) {
            return ;
        }
        FHHouseRentModel *model = (FHHouseRentModel *)[self generateModel:obj class:[FHHouseRentModel class] error:&error];
        if (completion) {
            completion(model,error);
        }
        completion(error ,nil);
    }];
}

+(JSONModel *)generateModel:(NSData *)jsonData class:(Class)class error:(NSError *__autoreleasing *)error
{
    return [self generateModel:jsonData class:class error:error useYYModel:NO];
}

+(JSONModel *)generateModel:(NSData *)jsonData class:(Class)class error:(NSError *__autoreleasing *)error useYYModel:(BOOL)useYYModel
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
    JSONModel *model = nil;
    if(useYYModel){
        model = [class yy_modelWithJSON:jsonData];
    }else{
        model = [[class alloc]initWithData:jsonData error:&jerror];
    }
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

+(TTHttpTask *)queryData:(NSString *_Nullable)queryPath params:(NSDictionary *_Nullable)param class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *url = QURL(queryPath);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:cls error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
        
    }];
}

+(TTHttpTask *)queryData:(NSString *_Nullable)queryPath uploadLog:(BOOL)uploadLog params:(NSDictionary *_Nullable)param class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *url = QURL(queryPath);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:cls error:&backError];
            if (response.statusCode == 200 && uploadLog) {
                
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil) {
                        NSMutableDictionary *extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        [self addServerFailerLog:model.status extraDict:extraDict];
                    }
                }
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
        
    }];
}

#pragma mark 找房频道首页相关
+(TTHttpTask *)requestHomeSearchRoll:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeRollModel *model, NSError *error))completion
{
    NSString *url = QURL(@"/f100/api/v2/home_page_roll_screen?");
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (!completion) {
            return ;
        }
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            FHHomeRollModel *model = (FHHomeRollModel *)[self generateModel:obj class:[FHHomeRollModel class] error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
    }];
}

+(TTHttpTask *)requestHomeRecommend:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion
{
    NSString *url = QURL(@"/f100/api/v2/recommend?");
 
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (!completion) {
            return ;
        }
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            FHHomeHouseModel *model = (FHHomeHouseModel *)[self generateModel:obj class:[FHHomeHouseModel class] error:&backError];
            if (response.statusCode == 200  && [model isKindOfClass:[FHHomeHouseModel class]]) {
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil || model.data.items.count == 0) {
                        NSMutableDictionary *extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        [self addServerFailerLog:model.status extraDict:extraDict];
                    }
                }
            }            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,backError);
            });
        });
    }];
}

+ (void)addServerFailerLog:(NSString *)status extraDict:(NSDictionary *)extraDict
{
    NSMutableDictionary *categoryDict = @{}.mutableCopy;
    if (status) {
        categoryDict[@"status"] = status;
    }
    [[HMDTTMonitor defaultManager]hmdTrackService:@"server_api_request_failure" metric:nil category:categoryDict extra:extraDict];
}


#pragma Mark - base request
+(TTHttpTask *_Nullable)getRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param jsonClass:(Class _Nonnull)clazz completion:(void(^_Nullable)(JSONModel *_Nullable model , NSError *_Nullable error))completion
{
    
    NSString *url = nil;
    if (![[path lowercaseString] hasPrefix:@"http"]) {
        url = QURL(path);
    }else{
        url = path;
    }
    
    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id rmodel = [self  generateModel:obj class:clazz error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(rmodel,backError);
                });
            }
        });
        
    }];
}


+(TTHttpTask *)postRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param jsonClass:(Class _Nonnull)clazz completion:(void(^_Nullable)(JSONModel *_Nullable model , NSError *_Nullable error))completion
{
    NSString *url = QURL(path);
    
    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:param method:POST needCommonParams:YES callback:^(NSError *error, id obj) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id rmodel = [self  generateModel:obj class:clazz error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(rmodel,error);
                });
            }
        });
    }];
    
}

+(TTHttpTask *)postRequest:(NSString *_Nonnull)path uploadLog:(BOOL)uploadLog query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param jsonClass:(Class _Nonnull)clazz completion:(void(^_Nullable)(JSONModel *_Nullable model , NSError *_Nullable error))completion
{
    NSString *url = QURL(path);
    
    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }

    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:clazz error:&backError];
            if (response.statusCode == 200 && uploadLog) {
                
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil) {
                        NSMutableDictionary *extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        [self addServerFailerLog:model.status extraDict:extraDict];
                    }
                }
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,error);
                });
            }
        });
    }];
    
}


+(TTHttpTask *_Nullable)getRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param  completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion
{
    NSString *url = nil;
    if (![[path lowercaseString] hasPrefix:@"http"]) {
        url = QURL(path);
    }else{
        url = path;
    }
    
    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj) {
        if (completion) {
            NSDictionary *json = nil;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                }
            }
            completion(json,error);
        }
    }];
}

+(TTHttpTask *_Nullable)postRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion
{
    NSString *url = QURL(path);
    
    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:url params:param method:POST needCommonParams:YES callback:^(NSError *error, id obj) {
        if (completion) {
            NSDictionary *json = nil;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                }
            }
            completion(json,error);
        }
    }];
}

+(TTHttpTask *_Nullable)postJsonRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion
{
    NSString *url = QURL(path);

    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }

    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES requestSerializer:[FHJSONHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (completion) {
            NSDictionary *json = nil;

            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                }
            }
            completion(json,error);
        }
    }];
}

+(TTHttpTask *)postJsonRequest:(NSString *_Nonnull)path query:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param jsonClass:(Class _Nonnull)clazz completion:(void(^_Nullable)(JSONModel *_Nullable model , NSError *_Nullable error))completion
{
    NSString *url = QURL(path);
    
    if (!IS_EMPTY_STRING(query)) {
        url = [url stringByAppendingFormat:@"?%@",query];
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES requestSerializer:[FHJSONHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id rmodel = [self  generateModel:obj class:clazz error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(rmodel,error);
                });
            }
        });
    }];
}

/**
 UGC推广 增加植入种子
 */

+(TTHttpTask *_Nullable)uploadUGCPostPromotionparams:(NSDictionary *_Nullable)param  completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion
{
    NSString *url = QURL(@"/f100/ugc/promotion/upload");
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES requestSerializer:[FHJSONHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (completion) {
            NSDictionary *json = nil;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                }
            }
            completion(json,error);
        }
    }];
}


/**
 UGC推广 获取种子
 */

+(TTHttpTask *_Nullable)checkUGCPostPromotionparams:(NSDictionary *_Nullable)param  completion:(void(^_Nullable)(NSDictionary *_Nullable result , NSError *_Nullable error))completion
{
    NSString *url = QURL(@"/f100/ugc/promotion/check");
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES requestSerializer:[FHJSONHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (completion) {
            NSDictionary *json = nil;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                }
            }
            completion(json,error);
        }
    }];
}


@end

