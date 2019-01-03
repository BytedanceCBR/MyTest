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

@interface FHEnvContext ()
@property (nonatomic, strong) TTReachability *reachability;
@property (nonatomic, strong) FHClientHomeParamsModel *commonPageModel;
@property (nonatomic, strong)NSMutableDictionary *commonRequestParam;
@end

@implementation FHEnvContext

+ (instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
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
    
    if ([gCityId isKindOfClass:[NSString class]]) {
        requestParam[@"gaode_city_id"] = gCityId;
    }
    
    if ([gCityName isKindOfClass:[NSString class]]){
        requestParam[@"city_name"] = gCityName;
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
        conf.domain = [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance baseUrl];
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

- (void)startLocation
{
    [[FHLocManager sharedInstance] setUpLocManagerLocalInfo];
    
    [[FHLocManager sharedInstance] requestCurrentLocation:YES];
}

- (void)updateConfigCache
{
    [self.generalBizConfig updataCurrentConfigCache];
}

- (FHConfigDataModel *)saveGeneralConfig
{
    
}

- (FHConfigDataModel *)getConfigFromCache
{
    return self.generalBizConfig.configCache;
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
    return @"122";
}

//保存当前城市id
+ (void)saveCurrentUserCityId:(NSString *)cityId
{
    [FHUtils setContent:cityId forKey:kUserDefaultCityId];
}

- (FHClient *)_client
{
    if (!_client) {
        _client = [FHClient new];
    }
    return _client;
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
