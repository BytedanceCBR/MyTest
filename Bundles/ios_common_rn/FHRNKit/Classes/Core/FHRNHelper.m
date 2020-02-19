//
//  FHRNCacheManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/19.
//

#import "FHRNHelper.h"
#import "FHUtils.h"
#import "TTRoute.h"
#import "NSDictionary+TTAdditions.h"

static NSString *const kFHSettingsKey = @"kFHSettingsKey";

@interface FHRNHelper()
@end

@implementation FHRNHelper

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)addObjectCountforChannel:(NSString *)channel
{
    if ([channel isKindOfClass:[NSString class]]) {
        if (!_channelCache) {
            _channelCache = [NSMutableDictionary new];
        }
        NSNumber *countNum = _channelCache[channel];
        if ([countNum isKindOfClass:[NSNumber class]]) {
            NSInteger count = [countNum integerValue];
            count ++;
            [_channelCache setValue:@(count) forKey:channel];
        }else
        {
            [_channelCache setValue:@(1) forKey:channel];
        }
    }
    
}

- (void)removeCountChannel:(NSString *)channel
{
    if ([channel isKindOfClass:[NSString class]]) {
        if (!_channelCache) {
            _channelCache = [NSMutableDictionary new];
        }
        NSNumber *countNum = _channelCache[channel];
        if ([countNum isKindOfClass:[NSNumber class]]) {
            NSInteger count = [countNum integerValue];
            count --;
            if (count < 0) {
                count = 0;
            }
            [_channelCache setValue:@(count) forKey:channel];
        }else
        {
            [_channelCache setValue:@(0) forKey:channel];
        }
    }
}

- (BOOL)isNeedCleanCacheForChannel:(NSString *)channel
{
    NSNumber *countNum = _channelCache[channel];
    if ([countNum isKindOfClass:[NSNumber class]]) {
        return countNum.integerValue <= 0;
    }
    return YES;
}

+ (void)openRealtorModule:(NSString *)realtorId andReportParams:(NSDictionary *)reportParams andImPrams:(NSDictionary *)imParams
{
    NSURL *openUrlRn = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://react?module_name=FHRNAgentDetailModule_home&realtorId=%@&can_multi_preload=%d&channelName=f_realtor_detail&debug=0&report_params=%@&im_params=%@",realtorId,0,[FHUtils getJsonStrFrom:reportParams],[FHUtils getJsonStrFrom:imParams]]];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"title"] = @"经纪人主页";
    info[@"realtor_id"] = realtorId;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
    [[TTRoute sharedRoute] openURLByViewController:openUrlRn userInfo:userInfo];
}

+ (NSArray *)fhGeckoChannels
{
    NSDictionary *fhSettings = [self fhSettings];
    NSArray * f_gecko_channels = [fhSettings tt_arrayValueForKey:@"f_gecko_channels"];
    if ([f_gecko_channels isKindOfClass:[NSArray class]]) {
        return f_gecko_channels;
    }
    return @[];
}

+ (NSArray *)fhRNPreLoadChannels
{
    NSDictionary *fhSettings = [self fhSettings];
    NSArray * f_rn_preload_channels = [fhSettings tt_arrayValueForKey:@"f_rn_preload_channels"];
    if ([f_rn_preload_channels isKindOfClass:[NSArray class]]) {
        return f_rn_preload_channels;
    }
    return @[];
}

+ (NSArray *)fhRNEnableChannels
{
    NSDictionary *fhSettings = [self fhSettings];
    NSArray * f_rn_enable = [fhSettings tt_arrayValueForKey:@"f_rn_enable"];
    if ([f_rn_enable isKindOfClass:[NSArray class]]) {
        return f_rn_enable;
    }
    return @[];
}

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFHSettingsKey]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kFHSettingsKey];
    } else {
        return nil;
    }
}

//开始缓存RN view
- (void)addCacheViewOpenUrl:(NSString *)url andCacheKey:(NSInteger)cacheKey
{
    if (![url isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (!cacheKey) {
        return;
    }
    
    if (!_rnPreloadCache) {
        _rnPreloadCache = [NSMutableDictionary new];
    }
    
    NSURL *openUrlRn = [NSURL URLWithString:url];
    TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:openUrlRn userInfo:nil];
    
    [self.rnPreloadCache setValue:routeObj forKey:[NSString stringWithFormat:@"%ld",cacheKey]];
}

//增加缓存
- (void)addCacheViewOpenUrl:(NSString *)url andUserInfo:(TTRouteUserInfo *)userInfo andCacheKey:(NSInteger)cacheKey
{
    if (![url isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (!cacheKey) {
        return;
    }
    
    if (!_rnPreloadCache) {
        _rnPreloadCache = [NSMutableDictionary new];
    }
    
    NSURL *openUrlRn = [NSURL URLWithString:url];
    TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:openUrlRn userInfo:userInfo];
    
    [self.rnPreloadCache setValue:routeObj forKey:[NSString stringWithFormat:@"%ld",cacheKey]];
}

//获取缓存
- (TTRouteObject *)getRNCacheForCacheKey:(NSInteger)cacheKey
{
    if (!cacheKey) {
        return nil;
    }
    
   TTRouteObject * routeObj = [self.rnPreloadCache objectForKey:[NSString stringWithFormat:@"%ld",cacheKey]];
    if ([routeObj isKindOfClass:[TTRouteObject class]]) {
        return routeObj;
    }else
    {
        return nil;
    }
}

//清理缓存
- (void)clearCacheForCacheKey:(NSInteger)cacheKey
{
    if (!cacheKey) {
        return;
    }
    
    TTRouteObject * routeObj = [self.rnPreloadCache objectForKey:[NSString stringWithFormat:@"%ld",cacheKey]];
    if (routeObj) {
        [self.rnPreloadCache removeObjectForKey:[NSString stringWithFormat:@"%ld",cacheKey]];
    }
    
    if ([routeObj isKindOfClass:[TTRouteObject class]]) {
        if ([routeObj.instance respondsToSelector:@selector(destroyRNView)]) {
            [routeObj.instance performSelector:@selector(destroyRNView)];
        }
    }
}

@end
