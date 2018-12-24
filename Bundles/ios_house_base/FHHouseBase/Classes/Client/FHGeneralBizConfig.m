//
//  FHGeneralBizConfig.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHGeneralBizConfig.h"
#import <YYCache.h>
#import "FHUtils.h"

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

- (FHConfigDataModel *)getGeneralConfigFromLocal
{
    NSString *configJsonStr = [self.generalConfigCache objectForKey:@"config"];
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

@end
