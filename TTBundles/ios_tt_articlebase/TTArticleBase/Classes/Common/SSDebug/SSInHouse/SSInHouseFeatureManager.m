//
//  SSInHouseFeatureManager.m
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#import "SSInHouseFeatureManager.h"

static NSString *const kTTSSCommonLogicInHouseSettingsServerKey = @"kTTSSCommonLogicInHouseSettingsServer";
static NSString *const kTTSSCommonLogicInHouseSettingsUserKey = @"kTTSSCommonLogicInHouseSettingsKeyUser";

@interface SSInHouseFeatureManager ()

@property (nonatomic, strong) SSInHouseFeature *feature;
@property (nonatomic, strong) SSInHouseFeature *remoteFeature;

@end

static SSInHouseFeatureManager *_instance;
@implementation SSInHouseFeatureManager

+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SSInHouseFeatureManager alloc] init];
    });
    return _instance;
}

+ (SSInHouseFeature *)feature
{
    return [SSInHouseFeatureManager defaultManager].feature.copy;
}

+ (SSInHouseFeature *)localFeature
{
    SSInHouseFeature *fe;
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:kTTSSCommonLogicInHouseSettingsUserKey];
    if (settings && [settings isKindOfClass:[NSDictionary class]]) {
        fe = [[SSInHouseFeature alloc] initWithDictionary:settings];
    } else {
        fe = SSInHouseFeature.defaultLocalFeatureWithEnable;
    }
    return fe;
}

+ (SSInHouseFeature *)remoteFeature
{
    return [SSInHouseFeatureManager defaultManager].remoteFeature.copy;
}

- (SSInHouseFeature *)remoteFeature
{
    if (!_remoteFeature) {
        NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:kTTSSCommonLogicInHouseSettingsServerKey];
        if (settings && [settings isKindOfClass:[NSDictionary class]]) {
            _remoteFeature = [[SSInHouseFeature alloc] initWithDictionary:settings];
        } else {
            _remoteFeature = SSInHouseFeature.defaultFeatureWithDisable;
        }
    }
    return _remoteFeature;
}

- (SSInHouseFeature *)feature
{
    if (!_feature) {
        _feature = [SSInHouseFeatureManager.localFeature join:SSInHouseFeatureManager.remoteFeature];
    }
    return _feature;
}

- (void)resetDiskCacheWithSettings:(NSDictionary *)settings forKey:(NSString *)key
{
#if INHOUSE
    if (settings) {
        [[NSUserDefaults standardUserDefaults] setObject:settings forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
#endif
}

- (void)resetServerDiskCacheWithSettings:(NSDictionary *)settings
{
    return [self resetDiskCacheWithSettings:settings forKey:kTTSSCommonLogicInHouseSettingsServerKey];
}

- (void)resetUserDiskCacheWithFeature:(SSInHouseFeature *)feature
{
    return [self resetDiskCacheWithSettings:feature.dictionaryRepresentation forKey:kTTSSCommonLogicInHouseSettingsUserKey];
}

@end
