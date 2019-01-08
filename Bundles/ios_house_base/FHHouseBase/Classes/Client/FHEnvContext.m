//
//  FHEnvContext.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHEnvContext.h"
#import "TTTrackerWrapper.h"
#import "FHUtils.h"
#import "TTReachability.h"
#import "YYCache.h"
#import "FHLocManager.h"
#import "TTInstallIDManager.h"
#import "BDAccountConfiguration.h"
#import "BDAccount+Configuration.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "ToastManager.h"
#import "TTArticleCategoryManager.h"

@interface FHEnvContext ()
@property (nonatomic, strong) TTReachability *reachability;
@property (nonatomic, strong) FHClientHomeParamsModel *commonPageModel;
@property (nonatomic, strong) NSMutableDictionary *commonRequestParam;
@property(nonatomic , strong) NSDictionary *currentConfigDictionary;

@end

@implementation FHEnvContext

+ (instancetype)sharedInstance
{
    static FHEnvContext * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.configDataReplay = [RACReplaySubject subject];
    });
    
    return manager;
}

+ (void)openSwitchCityURL:(NSString *)urlString completion:(void(^)(BOOL isSuccess))completion
{
    NSInteger cityId = 0;
    
    if ([urlString containsString:@"city_id"]) {
        NSArray *paramsArrary = [urlString componentsSeparatedByString:@"?"];
        NSString *paramsStr = [paramsArrary lastObject];
        
        for (NSString *paramStr in [paramsStr componentsSeparatedByString:@"&"]) {
            NSArray *elts = [paramStr componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            if ([elts.lastObject respondsToSelector:@selector(integerValue)]) {
                cityId = [elts.lastObject integerValue];
            }
        }
            
        [[ToastManager manager] showCustomLoading:@"正在切换城市" isUserInteraction:YES];

        [[FHLocManager sharedInstance] requestConfigByCityId:cityId completion:^(BOOL isSuccess) {
            [[ToastManager manager] dismissCustomLoading];
            if (isSuccess) {
                FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
                if (configModel.cityAvailability.enable) {
                    [[TTArticleCategoryManager sharedManager] startGetCategoryWithCompleticon:^(BOOL isSuccess) {
                        if (isSuccess) {
                            if(completion)
                            {
                                completion(YES);
                            }
                            [[TTRoute sharedRoute] openURL:[NSURL URLWithString:urlString] userInfo:nil objHandler:^(TTRouteObject *routeObj) {
                                
                            }];
                        }else
                        {
                            if(completion)
                            {
                                completion(NO);
                            }
                            [[ToastManager manager] showToast:@"切换城市失败"];
                        }
                    }];
                }else
                {
                    if(completion)
                    {
                        completion(YES);
                    }
                    [[TTRoute sharedRoute] openURL:[NSURL URLWithString:urlString] userInfo:nil objHandler:^(TTRouteObject *routeObj) {
                        
                    }];
                }
            }else
            {
                if(completion)
                {
                    completion(NO);
                }
                [[ToastManager manager] showToast:@"切换城市失败"];
            }
        }];
    }
}

/*
 判断找房当前城市是否开通
 */
+ (BOOL)isCurrentCityNormalOpen
{
    return [[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable;
}

/*
 判断用户选择城市和当前城市是否是同一个
 */
+ (BOOL)isSameLocCityToUserSelect
{
    return [[FHEnvContext sharedInstance] getConfigFromCache].citySwitch.enable;
}

+ (void)recordEvent:(NSDictionary *)params andEventKey:(NSString *)traceKey
{
    if (kIsNSString(traceKey) && kIsNSDictionary(params)) {
        NSMutableDictionary *pramsDict = [[NSMutableDictionary alloc] initWithDictionary:params];
        pramsDict[@"event_type"] = kTracerEventType;
        [TTTrackerWrapper eventV3:traceKey params:pramsDict];
    }
}

- (FHGeneralBizConfig *)generalBizConfig
{
    if (!_generalBizConfig) {
        _generalBizConfig = [FHGeneralBizConfig new];
    }
    return _generalBizConfig;
}

+ (BOOL)isNetworkConnected
{
    return [TTReachability isNetworkConnected];
}

- (void)setTraceValue:(NSString *)value forKey:(NSString *)key
{
    
}

- (void)saveGeneralConfig:(FHConfigModel *)model
{
    [self.generalBizConfig saveCurrentConfigCache:model];
}

- (void)updateRequestCommonParams
{
    //初始化公共请求参数
    NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] initWithDictionary:self.commonRequestParam];
    
    
    requestParam[@"app_id"] = @"1370";
    requestParam[@"aid"] = @"1370";
    
    requestParam[@"channel"] = [[NSBundle mainBundle] infoDictionary][@"CHANNEL_NAME"];
    requestParam[@"app_name"] = @"f100";
    requestParam[@"source"] = @"app";
    
    //获取city_id
    if ([[FHEnvContext getCurrentSelectCityIdFromLocal] respondsToSelector:@selector(integerValue)]) {
        NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
        if (cityId > 0) {
            [requestParam setValue:@(cityId) forKey:@"city_id"];
        }
    }
    
    double longitude = [FHLocManager sharedInstance].currentLocaton.coordinate.longitude;
    double latitude = [FHLocManager sharedInstance].currentLocaton.coordinate.latitude;
    NSString *gCityId = [FHLocManager sharedInstance].currentReGeocode.citycode;
    NSString *gCityName = [FHLocManager sharedInstance].currentReGeocode.city;

    
    if (longitude != 0 && longitude != 0) {
        requestParam[@"gaode_lng"] = @(longitude);
        requestParam[@"gaode_lat"] = @(latitude);
    }
    
    if (longitude != 0 && longitude != 0) {
        requestParam[@"longitude"] = @(longitude);
        requestParam[@"latitude"] = @(latitude);
    }
    
    if ([gCityId isKindOfClass:[NSString class]]) {
        requestParam[@"gaode_city_id"] = gCityId;
    }
    
    if ([gCityName isKindOfClass:[NSString class]]){
        requestParam[@"city_name"] = gCityName;
        requestParam[@"city"] = gCityName;
    }else
    {
        requestParam[@"city_name"] = nil;
    }
    
    self.commonRequestParam = requestParam;
}

- (NSDictionary *)getRequestCommonParams
{
    if (!_commonRequestParam) {
        [self updateRequestCommonParams];
    }
    return _commonRequestParam;
}

- (void)onStartApp
{
    //开始网络监听通知
    [self.reachability startNotifier];
    
    //开始生成config缓存
    [self.generalBizConfig onStartAppGeneralCache];
    
    //更新公共参数
    [self updateRequestCommonParams];
    
    //开始定位
    [self startLocation];
    
    [[TTInstallIDManager sharedInstance] startWithAppID:@"1370" channel:@"local_test" finishBlock:^(NSString *deviceID, NSString *installID) {
        
        BDAccountConfiguration *conf = [BDAccountConfiguration defaultConfiguration];
        conf.domain = [FHURLSettings baseURL];
        conf.getDeviceIdBlock = ^NSString * _Nonnull{
            return deviceID;
        };
        
        conf.getInstallIdBlock = ^NSString * _Nonnull{
            return installID;
        };
        
        conf.SSAppId = @"1370";
        
        conf.networkParamsHandler = ^NSDictionary * _Nonnull{
            return [NSDictionary new];
        };
        
        [BDAccount sharedAccount].accountConf = conf;

    }];
}

- (void)acceptConfigDictionary:(NSDictionary *)configDict
{
    if (configDict && [configDict isKindOfClass:[NSDictionary class]]) {
        FHConfigDataModel *dataModel = [[FHConfigDataModel alloc] initWithDictionary:configDict error:nil];
        self.generalBizConfig.configCache = dataModel;
        [FHEnvContext saveCurrentUserCityId:dataModel.currentCityId];
        [self.generalBizConfig saveCurrentConfigDataCache:dataModel];
        [self.configDataReplay sendNext:dataModel];
    }
}

- (void)acceptConfigDataModel:(FHConfigDataModel *)configModel
{
    if (configModel && [configModel isKindOfClass:[FHConfigDataModel class]]) {
        self.generalBizConfig.configCache = configModel;
        [FHEnvContext saveCurrentUserCityId:configModel.currentCityId];
        [self.generalBizConfig saveCurrentConfigDataCache:configModel];
        if (![configModel.toDictionary isEqualToDictionary:self.currentConfigDictionary]) {
            self.currentConfigDictionary = configModel.toDictionary;
            [self.configDataReplay sendNext:configModel];
        }
    }
}

- (void)startLocation
{
    [[FHLocManager sharedInstance] setUpLocManagerLocalInfo];
    
    [[FHLocManager sharedInstance] requestCurrentLocation:NO andShowSwitch:YES];
}

- (FHConfigDataModel *)getConfigFromCache
{
    if (self.generalBizConfig.configCache) {
        return self.generalBizConfig.configCache;
    }else
    {
        return [self readConfigFromLocal];
    }
}

- (FHConfigDataModel *)readConfigFromLocal
{
    return [self.generalBizConfig getGeneralConfigFromLocal];
}

//获取当前保存的城市名称
+ (NSString *)getCurrentUserDeaultCityNameFromLocal
{
    if (kIsNSString([FHUtils contentForKey:kUserDefaultCityName]))
    {
        return [FHUtils contentForKey:kUserDefaultCityName];
    }
    return @"深圳"; //无网默认
}

//保存当前城市名称
+ (void)saveCurrentUserDeaultCityName:(NSString *)cityName
{
    [FHUtils setContent:cityName forKey:kUserDefaultCityName];
}

//获取当前选中城市cityid
+ (NSString *)getCurrentSelectCityIdFromLocal
{
    if (kIsNSString([FHUtils contentForKey:kUserDefaultCityId])) {
        return [FHUtils contentForKey:kUserDefaultCityId];
    }
    return nil;
}

//保存当前城市id
+ (void)saveCurrentUserCityId:(NSString *)cityId
{
    [FHUtils setContent:cityId forKey:kUserDefaultCityId];
}

- (TTReachability *)reachability
{
    if (!_reachability) {
        _reachability = [TTReachability new];
    }
    return _reachability;
}

- (FHClientHomeParamsModel *)commonPageModel
{
    if (!_commonPageModel) {
        _commonPageModel = [FHClientHomeParamsModel new];
    }
    return _commonPageModel;
}

- (FHClientHomeParamsModel *)getCommonParams
{
    return self.commonPageModel;
}

- (void)updateOriginFrom:(NSString *)originFrom originSearchId:(NSString *)originSearchid
{
    if (kIsNSString(originFrom)) {
        self.commonPageModel.originFrom = originFrom;
    }
    
    if (kIsNSString(originSearchid)) {
        self.commonPageModel.originSearchId = originSearchid;
    }
}

@end
