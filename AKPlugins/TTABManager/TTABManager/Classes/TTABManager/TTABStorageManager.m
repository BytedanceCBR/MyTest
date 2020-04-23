//
//  TTABStorageManager.m
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/24.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTABStorageManager.h"
#import "TTABDefine.h"
#import "TTABManagerUtil.h"

@interface TTABStorageManager()

@property(nonatomic, strong)NSMutableDictionary * fetureDicts;

@end

@implementation TTABStorageManager

- (id)init
{
    self = [super init];
    if (self) {
        self.fetureDicts = [NSMutableDictionary dictionaryWithDictionary:[TTABStorageManager fetureKeyDicts]];
        
        //更新app数据
        [TTABStorageManager saveAPPVersionInfosIfNeed];
    }
    return self;
}

#pragma mark -- Feature Key
#pragma mark -- logic

- (NSString *)valueForFeatureKey:(NSString *)key
{
    NSString * result = [_fetureDicts objectForKey:key];
    return result;
}

- (void)setValue:(NSString *)value forFeatureKey:(NSString *)key
{
    [self _setValue:value forFeatureKey:key synchronizeToDisk:YES];
}

- (void)_setValue:(NSString *)value forFeatureKey:(NSString *)key synchronizeToDisk:(BOOL)synchronize
{
    
    if (isEmptyString_forABManager(value) || isEmptyString_forABManager(key)) {
        NSLog(@"TTABStorageManager 不能设置空key/value");
        return;
    }
    self.dirtyData = YES;
    [_fetureDicts setValue:value forKey:key];
    
    if (synchronize) {
        [TTABStorageManager saveFetureToDisk:_fetureDicts];
    }
}

- (void)batchSetKeyValues:(NSDictionary *)keyValues
{
    if (![keyValues isKindOfClass:[NSDictionary class]] || [keyValues count] == 0) {
        return;
    }
    
    [keyValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self _setValue:obj forFeatureKey:key synchronizeToDisk:NO];
    }];
    [TTABStorageManager saveFetureToDisk:_fetureDicts];
}

#pragma mark -- persistence store

#define kTTABStorageManagerFeatureUserDefaultKey @"kTTABStorageManagerFeatureUserDefaultKey"

+ (void)saveFetureToDisk:(NSDictionary *)fetureDicts
{
    if (![fetureDicts isKindOfClass:[NSDictionary class]] || [fetureDicts count] == 0) {
        return;
    }
    NSDictionary * dict = [NSDictionary dictionaryWithDictionary:fetureDicts];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kTTABStorageManagerFeatureUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary *)fetureKeyDicts
{
    NSDictionary * result = nil;
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTABStorageManagerFeatureUserDefaultKey];
    if (data) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    return nil;
}


#pragma mark -- ABGroups

#define kTTABTestSavedABGroupsPrefix @"_ABGroups_"

/**
 *  返回当前版本分配过的ABGroups，注意如果所有实验都没有命中， 返回值是可能会nil的
 *
 *  @return 返回当前版本分配过的ABGroups
 */
+ (NSString *)currentSavedABGroups
{
    NSString * str = [[NSUserDefaults standardUserDefaults] objectForKey:[self _currentVersionABGroupsUserDefaultkeyKey]];
    if ([str hasPrefix:kTTABTestSavedABGroupsPrefix]) {
        str = [str substringFromIndex:[kTTABTestSavedABGroupsPrefix length]];
    }
    if (isEmptyString_forABManager(str)) {
        return nil;
    }
    return str;
}

/**
 *  检查当前版本是否已经进行过分组
 *
 *  @return YES:进行过, NO:未进行过
 */
+ (BOOL)isABGroupAllocationed
{
    NSString * str = [[NSUserDefaults standardUserDefaults] objectForKey:[self _currentVersionABGroupsUserDefaultkeyKey]];
    if ([str isKindOfClass:[NSString class]] && [str length] > 0) {
        return YES;
    }
    return NO;
}

/**
 *  保存已经分配的key
 *
 *  @param abGroupsKey key 不包含prefix
 */
+ (void)saveCurrentVersionABGroups:(NSString *)abGroups
{
    if ([abGroups length] == 0) {
        abGroups = @"";
    }
    NSString * savedKey = [NSString stringWithFormat:@"%@%@", kTTABTestSavedABGroupsPrefix, abGroups];
    [[NSUserDefaults standardUserDefaults] setValue:savedKey forKey:[self _currentVersionABGroupsUserDefaultkeyKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)_currentVersionABGroupsUserDefaultkeyKey
{
    NSString * version = [TTABManagerUtil appVersion];
    
    NSString * key = [NSString stringWithFormat:@"TTABTestManagersavedABGroupsForCurrentVersion_%@", version];
    return key;
}

#pragma mark -- Random Number

#define kTTABTestRandomNumbersKey @"kTTABTestRandomNumbersKey"

+ (NSDictionary *)randomNumber
{
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTABTestRandomNumbersKey];
    if (data) {
        NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            return dict;
        }
    }
    return nil;
}

+ (void)saveRandomNumberDicts:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]] ||
        [dict count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTABTestRandomNumbersKey];
    }
    else {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dict];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:kTTABTestRandomNumbersKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- ABVersion

#define kTTABManagerABVersionUserDefaultKey @"kTTABManagerABVersionUserDefaultKey"

+ (void)saveABVersion:(NSString *)ABVersion
{
    if (isEmptyString_forABManager(ABVersion)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:ABVersion forKey:kTTABManagerABVersionUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)ABVersion
{
    NSString * result = [[NSUserDefaults standardUserDefaults] objectForKey:kTTABManagerABVersionUserDefaultKey];
    if (isEmptyString_forABManager(result)) {
        return nil;
    }
    return result;
}

#pragma mark -- app version

#define kTTABManagerFirstInstallVersionUDKey @"kTTABManagerFirstInstallVersionUDKey"

+ (void)saveAPPVersionInfosIfNeed
{
    BOOL needSync = NO;
    NSString * fistInstallVersion = [self firstInstallVersionStr];
    if (isEmptyString_forABManager(fistInstallVersion)) {
        NSString * appVersion = [TTABManagerUtil appVersion];
        if (!isEmptyString_forABManager(appVersion)) {
            [[NSUserDefaults standardUserDefaults] setValue:appVersion forKey:kTTABManagerFirstInstallVersionUDKey];
            needSync = YES;
        }
    }
    
    if (needSync) {
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)firstInstallVersionStr
{
    NSString * version = [[NSUserDefaults standardUserDefaults] objectForKey:kTTABManagerFirstInstallVersionUDKey];
    if (isEmptyString_forABManager(version)) {
        return nil;
    }
    return version;
}

#pragma mark -- executed experiment group names

#define kTTABStorageManagerexecutedExperimentGroupNamesUDK @"kTTABStorageManagerexecutedExperimentGroupNamesUDK"

+ (void)saveExecutedExperimentGroupNames:(NSDictionary *)groupNames
{
    if (![groupNames isKindOfClass:[NSDictionary class]] ||
        [groupNames count] == 0) {
        return;
    }
    NSDictionary * dict = [NSDictionary dictionaryWithDictionary:groupNames];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kTTABStorageManagerexecutedExperimentGroupNamesUDK];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary *)executedExperimentGroupNames
{
    NSDictionary * result = nil;
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kTTABStorageManagerexecutedExperimentGroupNamesUDK];
    if (data) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    return nil;
}

- (NSString *)debugDescription
{
    return [_fetureDicts description];;
}

@end
