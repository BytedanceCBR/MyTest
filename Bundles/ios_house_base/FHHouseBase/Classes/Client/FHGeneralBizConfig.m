//
//  FHGeneralBizConfig.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHGeneralBizConfig.h"
#import <YYCache.h>

static NSString *const kGeneralCacheName = @"general_config";
static NSString *const kGeneralKey = @"config";

@interface FHGeneralBizConfig ()
@property (nonatomic, strong) YYCache *generalConfigCache;
@end

@implementation FHGeneralBizConfig

- (YYCache *)generalConfigCache
{
    if (!_generalConfigCache) {
        _generalConfigCache = [YYCache cacheWithName:kGeneralCacheName];
    }
    return _generalConfigCache;
}

@end
