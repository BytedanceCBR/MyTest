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
#import <TTReachability/TTReachability.h>
#import <Heimdallr/HMDUserExceptionTracker.h>

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
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:requestParam method:GET needCommonParams:false callback:^(NSError *error, id obj, TTHttpResponse *response) {
        __block NSError *backError = error;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDate *backDate = [NSDate date];
            NSInteger code = 0;
            NSString *errMsg = nil;
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            
            FHConfigModel *model = [self generateModel:obj class:[FHConfigModel class] error:&backError];
            
            NSDate *serializeDate = [NSDate date];
            NSMutableDictionary *extraDict = nil;
            
            if (response.statusCode != 200) {
                resultType = FHNetworkMonitorTypeNetFailed;
            }else if (backError){
                resultType = FHNetworkMonitorTypeBizFailed;
                code = backError.code;
                errMsg = backError.domain;
                
                extraDict = @{}.mutableCopy;
                extraDict[@"request_url"] = response.URL.absoluteString;
                extraDict[@"response_headers"] = response.allHeaderFields;
                extraDict[@"error"] = error.domain;
                extraDict[@"status"] = model.status;
            }
            [self addRequestLog:@"config" startDate:startDate backDate:backDate serializeDate:serializeDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
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
+(TTHttpTask *)searchRent:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> _Nullable model , NSError * _Nullable error))completion
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
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:qparam method:GET needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSDate *backDate = [NSDate date];
        id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:cls error:&error];
        NSDate *serDate = [NSDate date];
        FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
        NSInteger code = 0;
        NSString *errMsg = nil;
        NSMutableDictionary *extraDict = nil;
        if (error) {
            if (response.statusCode != 200) {
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
            }
        }
        
        if (response.statusCode == 200 && [model isKindOfClass:[FHHouseRentModel class]]) {
            if ([model respondsToSelector:@selector(status)]) {
                NSString *status = [model performSelector:@selector(status)];
                if (status.integerValue != 0 || error != nil) {
                    extraDict = @{}.mutableCopy;
                    extraDict[@"request_url"] = response.URL.absoluteString;
                    extraDict[@"response_headers"] = response.allHeaderFields;
                    extraDict[@"error"] = error.domain;
                    extraDict[@"status"] = model.status;
                    
                    code = [status integerValue];
                    errMsg = error.domain;
                    resultType = status.integerValue;
                }
            }
        }
        
        [self addRequestLog:response.URL.path startDate:startDate backDate:backDate serializeDate:serDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
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
    
    return [self getRequest:host query:nil params:param jsonClass:[FHHouseRentModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (!completion) {
            return ;
        }
        if (completion) {
            completion(model,error);
        }
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
    
    return [self getRequest:url query:nil params:param jsonClass:cls completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

+(TTHttpTask *)queryData:(NSString *_Nullable)queryPath uploadLog:(BOOL)uploadLog params:(NSDictionary *_Nullable)param class:(Class)cls completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    return [self queryData:queryPath uploadLog:uploadLog params:param class:cls logPath:nil completion:completion];
}
+(TTHttpTask *)queryData:(NSString *_Nullable)queryPath uploadLog:(BOOL)uploadLog params:(NSDictionary *_Nullable)param class:(Class)cls logPath:(NSString *)logPath completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion
{
    NSString *url = QURL(queryPath);
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSDate *backDate = [NSDate date];
        
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:cls error:&backError];
            NSDate *serDate = [NSDate date];
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            
            BOOL success = NO;
            if (response.statusCode == 200 ) {
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil) {
                        if (uploadLog) {
                            extraDict = @{}.mutableCopy;
                            extraDict[@"request_url"] = response.URL.absoluteString;
                            extraDict[@"response_headers"] = response.allHeaderFields;
                            extraDict[@"error"] = error.domain;
                        }
                        code = [status integerValue];
                        resultType = status.integerValue;
                        errMsg = error.domain;
                    }
                }
            }else{
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
            }
            
            [self addRequestLog:logPath?:response.URL.path startDate:startDate backDate:backDate serializeDate:serDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
            
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
    return [self getRequest:url query:nil params:param jsonClass:[FHHomeRollModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

+(TTHttpTask *)requestHomeRecommend:(NSDictionary *_Nullable)param completion:(void(^_Nullable)(FHHomeHouseModel *model, NSError *error))completion
{
    NSString *url = QURL(@"/f100/api/v2/recommend?");
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (!completion) {
            return ;
        }
        NSDate *backDate = [NSDate date];
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            FHHomeHouseModel *model = (FHHomeHouseModel *)[self generateModel:obj class:[FHHomeHouseModel class] error:&backError];
            NSDate *serDate = [NSDate date];
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            NSDictionary *exceptionDict = nil;
            
            if (response.statusCode == 200  && [model isKindOfClass:[FHHomeHouseModel class]]) {
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil || model.data.items.count == 0) {
                        extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        
                        code = [status integerValue];
                        errMsg = error.domain;
                        
                        NSInteger houseType = [[param valueForKey:@"house_type"] integerValue];
                        resultType = FHNetworkMonitorTypeBizFailed+houseType;
                        exceptionDict = @{@"data_type":(param[@"house_type"]?:@"-1")};
                    }
                }
            }else{
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
            }
            [self addRequestLog:response.URL.path startDate:startDate backDate:backDate serializeDate:serDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict exceptionDict:exceptionDict];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(model,backError);
            });
        });
    }];
}


+(void)addRequestLog:(NSString *)path startDate:(NSDate *)startData backDate:(NSDate *)backDate serializeDate:(NSDate *)serializeDate resultType:(FHNetworkMonitorType)type errorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg extra:(NSDictionary *)extraDict
{
    [self addRequestLog:path startDate:startData backDate:backDate serializeDate:serializeDate resultType:type errorCode:errorCode errorMsg:errorMsg extra:extraDict exceptionDict:nil];
}

+(void)addRequestLog:(NSString *)path startDate:(NSDate *)startData backDate:(NSDate *)backDate serializeDate:(NSDate *)serializeDate resultType:(FHNetworkMonitorType)type errorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg extra:(NSDictionary *)extraDict exceptionDict:(NSDictionary *)exceptionDict
{
    NSString *sPath = path;
    path = [path stringByReplacingOccurrencesOfString:@"f100/api" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"f100" withString:@""];
    
    NSArray *components = [path componentsSeparatedByString:@"/"];
    NSMutableArray *items = [NSMutableArray new];
    [components enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.length > 0) {
            [items addObject:obj];
        }
    }];
    
    NSString *key = [@"f_api_performance_" stringByAppendingString:[items componentsJoinedByString:@"_"]];
    
    NSMutableDictionary *extra = [NSMutableDictionary new];
    if (extraDict) {
        [extra addEntriesFromDictionary:extraDict];
    }
    NSMutableDictionary *metricDict = [NSMutableDictionary new];
    if (startData && backDate) {
        metricDict[@"api_duration_network"] = @([backDate timeIntervalSinceDate:startData]*1000);
    }
    
    if (startData && serializeDate) {
        metricDict[@"api_duration_business"] = @([serializeDate timeIntervalSinceDate:startData]*1000);
    }
    
    if (type != FHNetworkMonitorTypeSuccess) {
        extra[@"error_code"] = @(errorCode);
        extra[@"error_message"] = errorMsg;
        
        NSString *ntType = @"UNKNOWN";
        /*
         NotReachable = 0,
         ReachableViaWiFi,
         ReachableViaWWAN
         */
        switch([[FHEnvContext  sharedInstance].reachability currentReachabilityStatus]){
            case ReachableViaWiFi:
                ntType = @"WIFI";
                break;
            case ReachableViaWWAN:
                ntType = @"MOBILE";
                break;
            case NotReachable:
                ntType = @"NONE";
        }
        extra[@"network_status"] = ntType;
    }
    
    NSDictionary *cat = @{@"status":@(type)};
    [[HMDTTMonitor defaultManager] hmdTrackService:key metric:metricDict category:cat extra:extra];
    
    if (type != FHNetworkMonitorTypeSuccess && type != FHNetworkMonitorTypeNetFailed) {
        NSMutableDictionary *filterDict = [NSMutableDictionary new];
        filterDict[@"path"] = key;
        NSMutableDictionary *customDict = [NSMutableDictionary new];
        customDict[@"status"] = @(errorCode);
        NSDictionary *headerDict = extra[@"response_headers"];
        if ([headerDict isKindOfClass:[NSDictionary class]]) {
            customDict[@"log_id"] = headerDict[@"x-tt-logid"];
        }
        NSStream *cityName = [FHEnvContext getCurrentSelectCityIdFromLocal];
        customDict[@"city"] = cityName?:@"";
        if ([exceptionDict isKindOfClass:[NSDictionary class]]) {
            [customDict addEntriesFromDictionary:exceptionDict];
        }
        [[HMDUserExceptionTracker sharedTracker] trackUserExceptionWithExceptionType:@"NetworkError" title:@"api_error" subTitle:sPath?:@"" customParams:customDict filters:filterDict callback:nil];
    }
    
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
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSDate *requestDoneDate = [NSDate date];
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id rmodel = [self  generateModel:obj class:clazz error:&backError];
            NSDate *serializeDate = [NSDate date];
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            if (error) {
                code = response.statusCode;
                errMsg = [error description];
                resultType = FHNetworkMonitorTypeNetFailed;
            }else if(backError){
                
                NSInteger status = backError.code;
                extraDict = @{}.mutableCopy;
                extraDict[@"request_url"] = response.URL.absoluteString;
                extraDict[@"response_headers"] = response.allHeaderFields;
                extraDict[@"error"] = error.domain;
                extraDict[@"status"] = @(status);
                
                code = backError.code;
                errMsg = [backError description];
                resultType = status;
            }
            
            [self addRequestLog:response.URL.path startDate:startDate backDate:requestDoneDate serializeDate:serializeDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
            
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
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        NSDate *backDate = [NSDate date];
        
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[self generateModel:obj class:clazz error:&backError];
            NSDate *serializeDate = [NSDate date];
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            
            if (response.statusCode == 200 ) {
                
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || error != nil) {
                        if(uploadLog) {
                            extraDict = @{}.mutableCopy;
                            extraDict[@"request_url"] = response.URL.absoluteString;
                            extraDict[@"response_headers"] = response.allHeaderFields;
                            extraDict[@"error"] = error.domain;
                            extraDict[@"status"] = status;
                        }
                        code = [status integerValue];
                        errMsg = error.domain;
                        resultType = status.integerValue;
                    }
                }
            }else{
                resultType = FHNetworkMonitorTypeNetFailed;
                code = response.statusCode;
                errMsg = error.domain;
            }
            [self addRequestLog:response.URL.path startDate:startDate backDate:backDate serializeDate:serializeDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
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
    
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:GET needCommonParams:YES callback:^(NSError *error, id obj , TTHttpResponse *response) {
        if (completion) {
            NSDictionary *json = nil;
            NSDate *backDate = [NSDate date];
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                    resultType = FHNetworkMonitorTypeBizFailed;
                    errMsg = e.reason;
                    code = API_ERROR_CODE;
                }
            }else{
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
                errMsg = error.domain;
                if ([json isKindOfClass:[NSDictionary class]] && json[@"status"]) {
                    NSInteger status = [json[@"status"] integerValue];
                    if (status != 0) {
                        extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        extraDict[@"status"] = @(status);
                        resultType = status;
                    }
                }
            }
            [self addRequestLog:response.URL.path startDate:startDate backDate:backDate serializeDate:nil resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
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
    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES callback:^(NSError *error, id obj , TTHttpResponse *response) {
        if (completion) {
            NSDictionary *json = nil;
            NSDate *backDate = [NSDate date];
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                    resultType = FHNetworkMonitorTypeBizFailed;
                    errMsg = e.reason;
                    code = API_ERROR_CODE;
                }
            }else{
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
                errMsg = error.domain;
                if ([json isKindOfClass:[NSDictionary class]] && json[@"status"]) {
                    NSInteger status = [json[@"status"] integerValue];
                    if (status != 0) {
                        extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        extraDict[@"status"] = @(status);
                        resultType = status;
                    }
                }
            }
             [self addRequestLog:response.URL.path startDate:startDate backDate:backDate serializeDate:nil resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
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

    NSDate *startDate = [NSDate date];
    return [[TTNetworkManager shareInstance]requestForBinaryWithResponse:url params:param method:POST needCommonParams:YES requestSerializer:[FHJSONHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (completion) {
            NSDictionary *json = nil;
            NSDate *backDate = [NSDate date];
            NSInteger code = 0;
            NSString *errMsg = nil;
            NSMutableDictionary *extraDict = nil;
            FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
            
            if (!error) {
                @try{
                    json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                }
                @catch(NSException *e){
                    error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
                    resultType = FHNetworkMonitorTypeBizFailed;
                    errMsg = e.reason;
                    code = API_ERROR_CODE;
                }
            }else{
                code = response.statusCode;
                resultType = FHNetworkMonitorTypeNetFailed;
                errMsg = error.domain;
                if ([json isKindOfClass:[NSDictionary class]] && json[@"status"]) {
                    NSInteger status = [json[@"status"] integerValue];
                    if (status != 0) {
                        extraDict = @{}.mutableCopy;
                        extraDict[@"request_url"] = response.URL.absoluteString;
                        extraDict[@"response_headers"] = response.allHeaderFields;
                        extraDict[@"error"] = error.domain;
                        extraDict[@"status"] = @(status);
                        resultType = status;
                    }
                }
            }
            [self addRequestLog:response.URL.path startDate:startDate backDate:backDate serializeDate:nil resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict];
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


@end

