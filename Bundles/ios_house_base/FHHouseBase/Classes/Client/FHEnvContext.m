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
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "ToastManager.h"
#import "TTArticleCategoryManager.h"
#import <objc/runtime.h>
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "FHMessageManager.h"
#import "FHHouseBridgeManager.h"
#import "FHMessageManager.h"
#import <HMDTTMonitor.h>
#import "FHIESGeckoManager.h"
#import <TTDeviceHelper.h>
#import <BDALog/BDAgileLog.h>

static NSInteger kGetLightRequestRetryCount = 3;

@interface FHEnvContext ()
@property (nonatomic, strong) TTReachability *reachability;
@property (nonatomic, strong) FHClientHomeParamsModel *commonPageModel;
@property (nonatomic, strong) NSMutableDictionary *commonRequestParam;

@end

@implementation FHEnvContext

+ (instancetype)sharedInstance
{
    static FHEnvContext * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.configDataReplay = [RACReplaySubject subject];
        manager.isRefreshFromAlertCitySwitch = NO;
    });
    
    return manager;
}

+ (void)openSwitchCityURL:(NSString *)urlString completion:(void(^)(BOOL isSuccess))completion
{
    NSInteger cityId = 0;
    
    if (![FHEnvContext isNetworkConnected])
    {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
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
        
        __block NSInteger retryGetLightCount = kGetLightRequestRetryCount;
        
        [[ToastManager manager] showCustomLoading:@"正在切换城市" isUserInteraction:YES];
        [FHEnvContext sharedInstance].isRefreshFromCitySwitch = YES;
        [[FHLocManager sharedInstance] requestConfigByCityId:cityId completion:^(BOOL isSuccess,FHConfigModel * _Nullable model) {
            
            NSMutableDictionary *paramsExtra = [NSMutableDictionary new];
            
            [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
            
            if (isSuccess) {
                [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = YES;
                FHConfigDataModel *configModel = model.data;
                [[FHLocManager sharedInstance] updateAllConfig:model isNeedDiff:NO];
                
                [[TTArticleCategoryManager sharedManager] startGetCategoryWithCompleticon:^(BOOL isSuccessed) {
                    //首次请求频道无论成功失败都跳转
                    if (retryGetLightCount == kGetLightRequestRetryCount) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFHSwitchGetLightFinishedNotification object:nil];
                        
                        if(completion)
                        {
                            completion(YES);
                        }
                        [[ToastManager manager] dismissCustomLoading];
                        [[TTRoute sharedRoute] openURL:[NSURL URLWithString:urlString] userInfo:nil objHandler:^(TTRouteObject *routeObj) {
                            
                        }];
                    }
                    //重试3次请求频道
                    if (!isSuccessed && (retryGetLightCount > 0)) {
                        retryGetLightCount--;
                        [[TTArticleCategoryManager sharedManager] startGetCategory];
                    }
                    if ([[paramsExtra description] isKindOfClass:[NSString class]]) {
                        BDALOG_WARN_TAG(@"get_light_error_reason", [paramsExtra description]);
                    }
                }];
                
                [[HMDTTMonitor defaultManager] hmdTrackService:@"home_switch_config_error" status:0 extra:paramsExtra];
                
            }else
            {
                if(completion)
                {
                    completion(NO);
                }
                [[ToastManager manager] dismissCustomLoading];
                [[ToastManager manager] showToast:@"切换城市失败"];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"desc":@"切换城市失败",@"reason":@"请求config接口失败"}];
                
                [[HMDTTMonitor defaultManager] hmdTrackService:@"home_switch_config_error" status:1 extra:paramsExtra];
                
                if ([[paramsExtra description] isKindOfClass:[NSString class]]) {
                    BDALOG_WARN_TAG(@"config_error_reason", [paramsExtra description]);
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryHasChangeNotification object:nil];
        }];
    }else
    {
        if (!cityId) {
            [[HMDTTMonitor defaultManager] hmdTrackService:@"home_city_id_error" attributes:@{@"desc":@"上报切换城市id不合法,",@"reason":@"city_id为0或者其他"}];
        }
    }
}

+ (void)openLogoutSuccessURL:(NSString *)urlString completion:(void(^)(BOOL isSuccess))completion
{
    NSInteger cityId = 0;
    
    if (![FHEnvContext isNetworkConnected])
    {
        [[ToastManager manager] showToast:@"网络错误"];
        return;
    }
    
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
        
        __block NSInteger retryGetLightCount = kGetLightRequestRetryCount;
        
        [FHEnvContext sharedInstance].isRefreshFromCitySwitch = YES;
        [[FHLocManager sharedInstance] requestConfigByCityId:cityId completion:^(BOOL isSuccess,FHConfigModel * _Nullable model) {
            if (isSuccess) {
                [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = YES;
                FHConfigDataModel *configModel = model.data;
                [[FHLocManager sharedInstance] updateAllConfig:model isNeedDiff:NO];
                
                [[TTArticleCategoryManager sharedManager] startGetCategoryWithCompleticon:^(BOOL isSuccessed) {
                    //首次请求频道无论成功失败都跳转
                    if (retryGetLightCount == kGetLightRequestRetryCount) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFHSwitchGetLightFinishedNotification object:nil];
                        
                        if(completion)
                        {
                            completion(YES);
                        }
                        [[TTRoute sharedRoute] openURL:[NSURL URLWithString:urlString] userInfo:nil objHandler:^(TTRouteObject *routeObj) {
                            
                        }];
                    }
                    //重试3次请求频道
                    if (!isSuccessed && (retryGetLightCount > 0)) {
                        retryGetLightCount--;
                        [[TTArticleCategoryManager sharedManager] startGetCategory];
                    }
                }];
            }else
            {
                if(completion)
                {
                    completion(NO);
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryHasChangeNotification object:nil];
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
    return ![[FHEnvContext sharedInstance] getConfigFromCache].citySwitch.enable.boolValue;
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

- (FHMessageManager *)messageManager
{
    if (!_messageManager) {
        _messageManager = [[FHMessageManager alloc] init];
    }
    return _messageManager;
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
    NSDictionary *param = [TTNetworkUtilities commonURLParameters];
    
    //初始化公共请求参数
    NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] initWithDictionary:self.commonRequestParam];
    if (param) {
        [requestParam addEntriesFromDictionary:param];
    }
    
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
    
    
    CGFloat f_density = [UIScreen mainScreen].scale;
    CGFloat f_memory = [TTDeviceHelper getTotalCacheSpace];

    if (f_density) {
        requestParam[@"f_density"] = @(f_density);
    }
    
    if (f_memory) {
        requestParam[@"f_memory"] = @(f_memory);
    }
    
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
    //城市列表页未选择时hook页面跳转判断方法
    [self checkExchangeCanOpenURLMethod];
    
    //开始网络监听通知
    [self.reachability startNotifier];

    //开始生成config缓存
    [self.generalBizConfig onStartAppGeneralCache];


    //开始定位
    [self startLocation];
    
    //检测是否需要打开城市列表
    [self check2CityList];

    //更新公共参数
    [self updateRequestCommonParams];

    NSString *startFeedCatgegory = [[[FHHouseBridgeManager sharedInstance] envContextBridge] getFeedStartCategoryName];

    if (![startFeedCatgegory isEqualToString:@"f_house_news"] && startFeedCatgegory != nil) {
        //轮询红点
        [[FHLocManager sharedInstance] startCategoryRedDotRefresh];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.messageManager startSyncMessage];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [FHIESGeckoManager configGeckoInfo];
        [FHIESGeckoManager configIESWebFalcon];
    });

}

- (void)acceptConfigDictionary:(NSDictionary *)configDict
{
    if (configDict && [configDict isKindOfClass:[NSDictionary class]]) {
        FHConfigDataModel *dataModel = [[FHConfigDataModel alloc] initWithDictionary:configDict error:nil];
//        self.generalBizConfig.configCache = dataModel;
        [FHEnvContext saveCurrentUserCityId:dataModel.currentCityId];
//        [self.generalBizConfig saveCurrentConfigDataCache:dataModel];
        [self.configDataReplay sendNext:dataModel];
    }
}

- (void)acceptConfigDataModel:(FHConfigDataModel *)configModel
{
    if (configModel && [configModel isKindOfClass:[FHConfigDataModel class]]) {
//        self.generalBizConfig.configCache = configModel;
        [FHEnvContext saveCurrentUserCityId:configModel.currentCityId];
//        [self.generalBizConfig saveCurrentConfigDataCache:configModel];
        [self.configDataReplay sendNext:configModel];
    }
}

- (void)startLocation
{
    [[FHLocManager sharedInstance] setUpLocManagerLocalInfo];
    
    [[FHLocManager sharedInstance] requestCurrentLocation:NO andShowSwitch:YES];
}

- (void)check2CityList {
    // 城市是否选择，未选择直接跳转城市列表页面
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
    if (!hasSelectedCity) {
        NSDictionary* info = @{@"animated":@(NO),
                               @"disablePanGes":@(YES)};
        TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        NSURL *url = [[NSURL alloc] initWithString:@"sslocal://city_list"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

// 检查是否需要swizze route方法的canopenurl逻辑，之所以在这个地方处理是因为push（2个场景）和外部链接可以打开App，但是城市列表如果未选择，不能进行跳转
- (void)checkExchangeCanOpenURLMethod {
    //判断是否展示过城市
    BOOL isSavedSearchConfig = [[FHEnvContext sharedInstance].generalBizConfig isSavedSearchConfig];
    if([(id)[FHUtils contentForKey:@"config_key_select_city_id"] integerValue] > 0 || isSavedSearchConfig) {
        // 旧版本选择过城市
        [FHUtils setContent:@(YES) forKey:kUserHasSelectedCityKey];
    }
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
    if (!hasSelectedCity) {
        // 交换方法
        Class cls = [TTRoute class];
        SEL originalSel = @selector(canOpenURL:);
        SEL swizzeledSel = @selector(toSwizzled_canOpenURL:);
        
        Method originalMethod = class_getInstanceMethod(cls, originalSel);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzeledSel);
        
        BOOL success = class_addMethod(cls, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(cls, swizzeledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

- (nullable FHConfigDataModel *)getConfigFromCache
{
    if (self.generalBizConfig.configCache) {
        return self.generalBizConfig.configCache;
    }else
    {
        self.generalBizConfig.configCache = [self readConfigFromLocal];
        return self.generalBizConfig.configCache;
    }
}

- (FHConfigDataModel *)readConfigFromLocal
{
    return [self.generalBizConfig getGeneralConfigFromLocal];
}

//获取当前保存的城市名称
+ (NSString *)getCurrentUserDeaultCityNameFromLocal
{
    //>=0.5版本存储cityname
    if (kIsNSString([FHUtils contentForKey:kUserDefaultCityName]))
    {
        return [FHUtils contentForKey:kUserDefaultCityName];
    }
    
    //0.4版本以及之前保存cityname
    NSString *cityNameStr = [[[FHEnvContext sharedInstance] generalBizConfig] readLocalDefaultCityNamePreviousVersion];
    if ([cityNameStr isKindOfClass:[NSString class]])
    {
        return cityNameStr;
    }
    
    return @"深圳";
}


//获取当前三位版本号
+ (NSString *)getToutiaoVersionCode
{
    NSString * buildVersionRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
    NSString * buildVersionNew = [buildVersionRaw stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSString * versionFirst = @"6";
    NSString * versionMiddle = @"6";
    NSString * versionEnd = @"6";
    
    if ([buildVersionNew isKindOfClass:[NSString class]] && buildVersionNew.length > 3) {
        versionFirst = [buildVersionNew substringWithRange:NSMakeRange(0, 1)];
        versionMiddle = [buildVersionNew substringWithRange:NSMakeRange(1, 1)];
        versionEnd = [buildVersionNew substringWithRange:NSMakeRange(2, 1)];
        
    }
    NSString *stringVersion = [NSString stringWithFormat:@"%@.%@.%@",versionFirst,versionMiddle,versionEnd];
    return stringVersion;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHSwitchGetLightFinishedNotification object:nil];
}

/*
 判断在房屋估价结果页中是否显示查看城市行情的按钮
 */
+ (BOOL)isPriceValuationShowHouseTrend
{
    return [[FHEnvContext sharedInstance] getConfigFromCache].entranceSwitch.isPriceValuationShowHouseTrend;
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

- (NSDictionary *)getGetOriginFromAndOriginId
{
    NSMutableDictionary *homePageCommonMap = [NSMutableDictionary new];
    [homePageCommonMap setValue:self.commonPageModel.originFrom forKey:@"origin_from"];
    [homePageCommonMap setValue:self.commonPageModel.originSearchId forKey:@"origin_search_id"];
    return homePageCommonMap;
}

@end

// 升级TTRoute后需要验当前场景
@implementation TTRoute (fhCityList)

- (BOOL)toSwizzled_canOpenURL:(NSURL *)url {
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
    BOOL isCityListUrl = [url.absoluteString containsString:@"sslocal://city_list"];
    if (hasSelectedCity || isCityListUrl) {
        return [self toSwizzled_canOpenURL:url];
    }
    // 当前城市未选择，不能进行页面跳转
    return NO;
}

@end
