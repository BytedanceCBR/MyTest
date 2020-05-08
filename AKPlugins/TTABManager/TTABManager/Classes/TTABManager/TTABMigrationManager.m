//
//  TTABMigrationManager.m
//  Article
//
//  Created by ZhangLeonardo on 16/1/27.
//
//

#import "TTABMigrationManager.h"
#import "TTABHelper.h"
#import <TTBaseMacro.h>

@implementation TTABMigrationManager

- (void)migrationIfNeed
{
    [self migration1];
}

- (void)migration1
{
    NSString * version = @"v1";
    if (![TTABMigrationManager _currentVersionNeedMigration:version]) {
        return;
    }
    
    //迁移ab version
    NSString * abVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSCommonLogicSettingABVersionKey"];
    if (!isEmptyString(abVersion)) {
        [[TTABHelper sharedInstance_tt] saveABVersion:abVersion];
    }
    
    
    
    [TTABMigrationManager _setHasMigrationedForVersion:version];
}

#pragma mark -- helper

#define kTTABMigrationManagerCurrentVersionHasMigrationedUDK @"kTTABMigrationManagerCurrentVersionHasMigrationedUDK"

+ (NSString *)_currentVersionHasMigrationUserDefaultskey:(NSString *)migrationVersion
{
    if (isEmptyString(migrationVersion)) {
        return nil;
    }
    NSString * str = [NSString stringWithFormat:@"kTTABMigrationManagerCurrentVersionHasMigrationedUDK_%@", migrationVersion];
    return str;
}

+ (BOOL)_currentVersionNeedMigration:(NSString *)migrationVersion
{
    NSString * userDefaultKey = [self _currentVersionHasMigrationUserDefaultskey:migrationVersion];
    if (isEmptyString(userDefaultKey)) {
        NSLog(@"迁移的userdefault key不能为nil !!!!!!!!");
        return NO;
    }
    BOOL hasMigration = [[[NSUserDefaults standardUserDefaults] objectForKey:userDefaultKey] boolValue];
    return !hasMigration;
}


+ (void)_setHasMigrationedForVersion:(NSString *)migrationVersion
{
    NSString * userDefaultKey = [self _currentVersionHasMigrationUserDefaultskey:migrationVersion];
    if (isEmptyString(userDefaultKey)) {
        NSLog(@"迁移的userdefault key不能为nil !!!!!!!!");
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:userDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
