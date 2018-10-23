//
//  TFManager.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFManager.h"
#import "TFAppInfosModel.h"

#define kTestFlightAccountEmailKey @"kTestFlightAccountEmailKey"
#define kTestFlightAccountIdentifierKey @"kTestFlightAccountIdentifierKey"
#define kTestFlightAccountIsUserAvailableKey @"kTestFlightAccountIsUserAvailableKey"

#define kTFAppInfosModelsKey @"kTFAppInfosModelsKey"

@interface TFManager()

@end

@implementation TFManager

#pragma mark -- kTFAppInfosModelsKey

+ (void)saveTFAppInfosModels:(NSMutableArray *)ary
{
    if ([ary count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTFAppInfosModelsKey];
    }
    else {
        NSMutableArray * tempResult = [NSMutableArray arrayWithCapacity:100];
        for (TFAppInfosModel * model in ary) {
            id arch = [NSKeyedArchiver archivedDataWithRootObject:model];
            if (arch != nil) {
                [tempResult addObject:arch];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tempResult] forKey:kTFAppInfosModelsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)tfAppInfosModels
{
    NSArray * savedAry = [[NSUserDefaults standardUserDefaults] objectForKey:kTFAppInfosModelsKey];
    NSMutableArray * tempResults = [NSMutableArray arrayWithCapacity:100];
    for (id temp in savedAry) {
        id model = [NSKeyedUnarchiver unarchiveObjectWithData:temp];
        if (model != nil) {
            [tempResults addObject:model];
        }
    }
    return [NSArray arrayWithArray:tempResults];
}

#pragma mark -- NSUserDefaults

//email
+ (void)saveTestFlightAccountEmail:(NSString *)email
{
    [self saveObj:email forKey:kTestFlightAccountEmailKey];
}

+ (NSString *)testFlightAccountEmail
{
    return [self fetchObjByKey:kTestFlightAccountEmailKey];
}

//identifier
+ (void)saveTestFlightAccountIdentifier:(NSString *)identifier
{
    [self saveObj:identifier forKey:kTestFlightAccountIdentifierKey];
}

+ (NSString *)testFlightAccountIdentifier
{
    return [self fetchObjByKey:kTestFlightAccountIdentifierKey];
}

//user available
+ (void)saveIsUserAvailable:(BOOL)userAvailable
{
    [self saveObj:[NSNumber numberWithBool:userAvailable] forKey:kTestFlightAccountIsUserAvailableKey];
}

+ (BOOL)testFlightIsAccountUserAvailable
{
    return [[self fetchObjByKey:kTestFlightAccountIsUserAvailableKey] boolValue];
}


//base
+ (void)saveObj:(NSObject *)valueObj forKey:(NSString *)keyStr
{
    if (valueObj == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyStr];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:valueObj forKey:keyStr];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)fetchObjByKey:(NSString *)keyStr
{
    if (isEmptyString(keyStr)) {
        return nil;
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyStr];
}

@end
