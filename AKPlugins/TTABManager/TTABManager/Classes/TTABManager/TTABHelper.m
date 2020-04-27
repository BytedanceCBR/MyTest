//
//  TTABHelper.m
//  Article
//
//  Created by ZhangLeonardo on 16/1/27.
//
//

#import "TTABHelper.h"
#import "TTABManager.h"
#import "TTABMigrationManager.h"
#import <TTBaseMacro.h>

@interface TTABHelper()
@property(nonatomic, strong)TTABManager * ABManager;
@property(nonatomic, strong)TTABMigrationManager * ABMigrationManager;

@end

@implementation TTABHelper

- (id)init
{
    self = [super init];
    if (self) {
        self.ABManager = [[TTABManager alloc] init];
        self.ABMigrationManager = [[TTABMigrationManager alloc] init];
    }
    return self;
}

/**
 *  如果需要，开始执行迁移
 */
- (void)migrationIfNeed
{
    [_ABMigrationManager migrationIfNeed];
}

- (void)distributionIfNeed
{
    [_ABManager didFinishLaunch];
}

- (NSString *)ABGroup
{
    return [_ABManager ABGroup];
}

- (NSString *)ABFeature
{
    return [_ABManager ABFeature];
}

- (NSString *)ABVersion
{
    return [_ABManager ABVersion];
}

- (void)saveABVersion:(NSString *)abVersion
{
    [_ABManager saveABVersion:abVersion];
}

- (void)saveServerSettings:(NSDictionary *)dict
{
    [_ABManager saveServerSettings:dict];
}

#pragma mark -- feature key

- (NSString *)valueForFeatureKey:(NSString *)featureKey
{
    return [_ABManager valueForFeatureKey:featureKey];
}

#pragma mark -- 业务

+ (TTClearCacheLiteraryType)clearCacheLiteraryType
{
    NSString * clearLiterary =  [[TTABHelper sharedInstance_tt] valueForFeatureKey:@"clear_literary_type"];
    if (isEmptyString(clearLiterary) ||
        [clearLiterary isEqualToString:@"clear"]) {
        return TTClearCacheLiteraryTypeClear;
    }
    return TTClearCacheLiteraryTypeClean;
}

@end
