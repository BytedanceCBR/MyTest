//
//  FHGeneralBizConfig.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHGeneralBizConfig.h"
#import <YYCache.h>
#import "FHUtils.h"
#import "FHHomeConfigManager.h"

static NSString *const kGeneralCacheName = @"general_config";
static NSString *const kGeneralKey = @"config";
static NSString *const kUserDefaultSelectKey = @"userdefaultselect";

@interface FHGeneralBizConfig ()
@property (nonatomic, strong) YYCache *generalConfigCache;
@property (nonatomic, strong) YYCache *searchConfigCache;
@property (nonatomic, strong) YYCache *userSelectCache;

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
}

- (void)updataCurrentConfigCache
{
    if ([FHHomeConfigManager sharedInstance].currentDataModel) {
        self.configCache = [FHHomeConfigManager sharedInstance].currentDataModel;
    }
}

- (void)saveCurrentConfigCache:(FHConfigModel *)configValue
{
    self.configCache = configValue;
    
    if([configValue.data isKindOfClass:[FHConfigDataModel class]])
    {
        NSString *configJsonStr = configValue.data.toJSONString;
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

//临时方案,弃用
//- (FHSearchConfigModel *)getSearchConfigFromLocal
//{
//    NSString *configJsonStr = [self.searchConfigCache objectForKey:@"search_config"];
//    NSDictionary *configDict = [FHUtils dictionaryWithJsonString:configJsonStr];
//
//    if ([configDict isKindOfClass:[NSDictionary class]]) {
//        FHSearchConfigModel *configModel = [[FHSearchConfigModel alloc] initWithDictionary:configDict error:nil];
//        if ([configModel isKindOfClass:[FHSearchConfigModel class]]) {
//            self.configCache.filter = configModel;
//            return configModel;
//        }else
//        {
//            return nil;
//        }
//    }else
//    {
//        return nil;
//    }
//}

@end
