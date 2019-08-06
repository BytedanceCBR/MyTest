//
//  FHGeneralBizConfig.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHGeneralBizConfig.h"
#import <YYCache.h>
#import "FHUtils.h"
#import "FHEnvContext.h"
#import "FHLazyLoadModel.h"
#import <YYModel/YYModel.h>
#import "FHUGCConfigModel.h"


static NSString *const kGeneralCacheName = @"general_config";
static NSString *const kGeneralKey = @"config";
static NSString *const kUGCConfigKey = @"ugcConfig";
static NSString *const kUserDefaultSelectKey = @"userdefaultselect";
static NSString *const kUserDefaultCityNamePre05_Key = @"currentcitytext"; // 0.5版本之前保存的当前城市名称
NSString *const kFHPhoneNumberCacheKey = @"phonenumber";
NSString *const kFHPLoginhoneNumberCacheKey = @"loginPhoneNumber";
static NSString *const kFHSubscribeHouseCacheKey = @"subscribeHouse";
static NSString *const kFHDetailFeedbackCacheKey = @"detailFeedback";


@interface FHGeneralBizConfig ()
@property (nonatomic, strong) YYCache *generalConfigCache;
@property (nonatomic, strong) YYCache *searchConfigCache;
@property (nonatomic, strong) YYCache *userSelectCache;
@property (nonatomic, strong) YYCache *userDefaultSelectCityCache;
@property(nonatomic , strong) YYCache *sendPhoneNumberCache;
@property(nonatomic , strong) YYCache *subscribeHouseCache;
@property(nonatomic , strong) YYCache *detailFeedbackCache;

@end

@implementation FHGeneralBizConfig

- (YYCache *)generalConfigCache
{
    if (!_generalConfigCache) {
        _generalConfigCache = [YYCache cacheWithName:kGeneralCacheName];
    }
    return _generalConfigCache;
}

- (YYCache *)searchConfigCache
{
    if (!_searchConfigCache) {
        _searchConfigCache = [YYCache cacheWithName:kGeneralKey];
    }
    return _searchConfigCache;
}

- (YYCache *)userDefaultSelectCityCache
{
    if (!_userDefaultSelectCityCache) {
        _userDefaultSelectCityCache = [YYCache cacheWithName:kUserDefaultCityNamePre05_Key];
    }
    return _userDefaultSelectCityCache;
}


- (YYCache *)userSelectCache
{
    if (!_userSelectCache) {
        _userSelectCache = [YYCache cacheWithName:kUserDefaultSelectKey];
    }
    return _userSelectCache;
}

- (void)onStartAppGeneralCache
{
    if (self.configCache) {
        [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = NO;
        [[FHEnvContext sharedInstance] acceptConfigDataModel:self.configCache];
    }
}

- (FHConfigDataModel *)configCache {
    if (_configCache == nil) {
        self.configCache = [self getGeneralConfigFromLocal];
    }
    return _configCache;
}

- (void)updataCurrentConfigCache
{
    
}

- (void)saveCurrentConfigCache:(FHConfigModel *)configValue
{
    //    self.configCache = configValuedata;
    
    if([configValue.data isKindOfClass:[FHConfigDataModel class]])
    {
        NSString *configJsonStr = configValue.data.toJSONString;
        if ([configJsonStr isKindOfClass:[NSString class]]) {
            [self.generalConfigCache setObject:configJsonStr forKey:kGeneralKey];
        }
    }
}

- (void)saveCurrentConfigDataCache:(FHConfigDataModel *)configValue
{
    //    self.configCache = configValue;
    
    if([configValue isKindOfClass:[FHConfigDataModel class]])
    {
        NSString *configJsonStr = configValue.toJSONString;
        if ([configJsonStr isKindOfClass:[NSString class]]) {
            [self.generalConfigCache setObject:configJsonStr forKey:kGeneralKey];
        }
    }
}

- (void)saveUGCConfigCache:(FHUGCConfigModel *)configValue
{
    if([configValue.data isKindOfClass:[FHUGCConfigModel class]])
    {
        NSString *configJsonStr = configValue.data.toJSONString;
        if ([configJsonStr isKindOfClass:[NSString class]]) {
            [self.generalConfigCache setObject:configJsonStr forKey:kUGCConfigKey];
        }
    }
}

- (void)updateUserSelectDiskCacheIndex:(NSNumber *)indexNum
{
    if ([indexNum isKindOfClass:[NSNumber class]]) {
        [self.userSelectCache setObject:indexNum forKey:kUserDefaultSelectKey];
    }
}

- (NSNumber *)getUserSelectTypeDiskCache
{
    NSObject *objectIndex = [self.userSelectCache objectForKey:kUserDefaultSelectKey];
    if ([objectIndex isKindOfClass:[NSNumber class]]) {
        return  objectIndex;
    }
    return  @(0);
}


- (FHConfigDataModel *)getGeneralConfigFromLocal
{
    NSString *configJsonStr = [self.generalConfigCache objectForKey:kGeneralKey];
    NSDictionary *configDict = [FHUtils dictionaryWithJsonString:configJsonStr];
    
    if ([configDict isKindOfClass:[NSDictionary class]]) {
        FHConfigDataModel *configModel = [self lazyInitConfig:configDict];
        self.configCache = configModel;
        if ([configModel isKindOfClass:[FHConfigDataModel class]]) {
            return configModel;
        }else
        {
            return nil;
        }
    }else
    {
        return nil;
    }
}

-(FHConfigDataModel*)lazyInitConfig:(NSDictionary*)config {
    NSMutableDictionary* theConfig = [config mutableCopy];
    NSDictionary* cityList = theConfig[@"city_list"];
    theConfig[@"city_list"] = nil;
    
    NSMutableDictionary* cache = [[NSMutableDictionary alloc] init];
    NSString* configKey = @"filter";
    cache[configKey] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"filter_order";
    cache[@"filterOrder"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"court_filter";
    cache[@"courtFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    
    configKey = @"rent_filter";
    cache[@"rentFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"rent_filter_order";
    cache[@"rentFilterOrder"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"neighborhood_filter";
    cache[@"neighborhoodFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"neighborhood_filter_order";
    cache[@"neighborhoodFilterOrder"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"search_tab_neighborhood_filter";
    cache[@"searchTabNeighborhoodFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"search_tab_court_filter";
    cache[@"searchTabCourtFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"search_tab_rent_filter";
    cache[@"searchTabRentFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"search_tab_filter";
    cache[@"searchTabFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;
    
    configKey = @"sale_history_filter";
    cache[@"saleHistoryFilter"] = theConfig[configKey];
    theConfig[configKey] = nil;

    FHConfigDataModel *configModel = [FHConfigDataModel yy_modelWithJSON:theConfig];//[[FHConfigDataModel alloc] initWithDictionary:theConfig error:nil];

    [cache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id model = [self modelWithClass:@"FHSearchFilterConfigItem" withData:obj];
        [configModel setValue:model forKey:key];
    }];
    configModel.cityList = [self modelWithClass:@"FHConfigDataCityListModel" withData:cityList];
    return configModel;
}

-(FHLazyLoadModel*)modelWithClass:(NSString*)className withData:(NSArray*)data {
    return [FHLazyLoadModel proxyWithClass:className withData:data];
}

- (BOOL)isSavedSearchConfig
{
    NSString *configJsonStr = [self.searchConfigCache objectForKey:@"search_config"];
    if (kIsNSString(configJsonStr)) {
        return YES;
    }
    return NO;
}

- (NSString *)readLocalDefaultCityNamePreviousVersion
{
    NSString *configJsonStr = [self.userDefaultSelectCityCache objectForKey:@"usercurrentcity"];
    if (kIsNSString(configJsonStr)) {
        return configJsonStr;
    }
    return nil;
}


- (YYCache *)sendPhoneNumberCache
{
    if (!_sendPhoneNumberCache) {
        _sendPhoneNumberCache = [YYCache cacheWithName:kFHPhoneNumberCacheKey];
    }
    return _sendPhoneNumberCache;
}

- (YYCache *)subscribeHouseCache
{
    if (!_subscribeHouseCache) {
        _subscribeHouseCache = [YYCache cacheWithName:kFHSubscribeHouseCacheKey];
    }
    return _subscribeHouseCache;
}

- (YYCache *)detailFeedbackCache
{
    if (!_detailFeedbackCache) {
        _detailFeedbackCache = [YYCache cacheWithName:kFHDetailFeedbackCacheKey];
    }
    return _detailFeedbackCache;
}

@end
