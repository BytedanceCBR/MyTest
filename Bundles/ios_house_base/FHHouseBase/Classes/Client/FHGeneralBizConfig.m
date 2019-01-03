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
    self.configCache.filter = [self getSearchConfigFromLocal];
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
    
    NSLog(@"dict = %@",configValue.toDictionary);
//    self.searchConfigCache = [FHSearchConfigModel new];
//    self.searchConfigCache.filter = configValue.data.filter;
//    self.searchConfigCache.searchTabNeighborhoodFilter = configValue.data.searchTabNeighborhoodFilter;
//    self.searchConfigCache.rentFilterOrder = configValue.data.rentFilterOrder;
//    self.searchConfigCache.searchTabCourtFilter = configValue.data.searchTabCourtFilter;
//    self.searchConfigCache.neighborhoodFilter = configValue.data.neighborhoodFilter;
//    self.searchConfigCache.searchTabRentFilter = configValue.data.searchTabRentFilter;
//    self.searchConfigCache.searchTabFilter = configValue.data.searchTabFilter;
//    self.searchConfigCache.courtFilter = configValue.data.courtFilter;
//    self.searchConfigCache.houseFilterOrder = configValue.data.houseFilterOrder;
//    self.searchConfigCache.rentFilter = configValue.data.rentFilter;
//    self.searchConfigCache.neighborhoodFilterOrder = configValue.data.neighborhoodFilterOrder;
//    self.searchConfigCache.saleHistoryFilter = configValue.data.saleHistoryFilter;
//    self.searchConfigCache.courtFilterOrder = configValue.data.courtFilterOrder;

//    NSLog(@"search_config = %@",configValue.data.filter.toJSONString);
//
//    if ([configValue.data.filter.toJSONString isEqualToString:[NSString class]]) {
//        [self.generalConfigCache setObject:configValue.data.filter.toJSONString forKey:@"search_config"];
//    }
//
//    NSLog(@"config = %@",configValue.data.filter.toJSONString);
//
//    if ([configValue.data.toJSONString isEqualToString:[NSString class]]) {
//        [self.generalConfigCache setObject:configValue.data.toJSONString forKey:@"config"];
//    }
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
    NSString *configJsonStr = [self.generalConfigCache objectForKey:@"config"];
    NSDictionary *configDict = [FHUtils dictionaryWithJsonString:configJsonStr];
    
    if ([configDict isKindOfClass:[NSDictionary class]]) {
        FHConfigDataModel *configModel = [[FHConfigDataModel alloc] initWithDictionary:configDict error:nil];
        if ([configModel isKindOfClass:[FHConfigDataModel class]]) {
            configModel.filter = [self getSearchConfigFromLocal];
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
//临时方案
- (FHSearchConfigModel *)getSearchConfigFromLocal
{
    NSString *configJsonStr = [self.searchConfigCache objectForKey:@"search_config"];
    NSDictionary *configDict = [FHUtils dictionaryWithJsonString:configJsonStr];
    
    if ([configDict isKindOfClass:[NSDictionary class]]) {
        FHSearchConfigModel *configModel = [[FHSearchConfigModel alloc] initWithDictionary:configDict error:nil];
        if ([configModel isKindOfClass:[FHSearchConfigModel class]]) {
            self.configCache.filter = configModel;
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

@end
