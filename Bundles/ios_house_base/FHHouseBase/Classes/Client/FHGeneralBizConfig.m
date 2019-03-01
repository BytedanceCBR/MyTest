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

static NSString *const kGeneralCacheName = @"general_config";
static NSString *const kGeneralKey = @"config";
static NSString *const kUserDefaultSelectKey = @"userdefaultselect";
static NSString *const kUserDefaultCityNamePre05_Key = @"currentcitytext"; // 0.5版本之前保存的当前城市名称
NSString *const kFHPhoneNumberCacheKey = @"phonenumber";


@interface FHGeneralBizConfig ()
@property (nonatomic, strong) YYCache *generalConfigCache;
@property (nonatomic, strong) YYCache *searchConfigCache;
@property (nonatomic, strong) YYCache *userSelectCache;
@property (nonatomic, strong) YYCache *userDefaultSelectCityCache;
@property(nonatomic , strong) YYCache *sendPhoneNumberCache;

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
    self.configCache = [self getGeneralConfigFromLocal];
    if (self.configCache) {
        [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = NO;
        [[FHEnvContext sharedInstance] acceptConfigDataModel:self.configCache];
    }
}

- (void)updataCurrentConfigCache
{
    
}

- (void)saveCurrentConfigCache:(FHConfigModel *)configValue
{
    self.configCache = configValue.data;
    
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
    self.configCache = configValue;
    
    if([configValue isKindOfClass:[FHConfigDataModel class]])
    {
        NSString *configJsonStr = configValue.toJSONString;
        if ([configJsonStr isKindOfClass:[NSString class]]) {
            [self.generalConfigCache setObject:configJsonStr forKey:kGeneralKey];
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
        FHConfigDataModel *configModel = [[FHConfigDataModel alloc] initWithDictionary:configDict error:nil];
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

@end
