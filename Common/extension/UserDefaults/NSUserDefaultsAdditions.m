//
//  NSUserDefaultsAdditions.m
//  Base
//
//  Created by Tu Jianfeng on 6/14/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "NSUserDefaultsAdditions.h"

@implementation NSUserDefaults (SSCategory)

+ (NSString *)standardStringForKey:(NSString *)defaultName
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults stringForKey:defaultName];
	return value == nil ? @"" : value;
}

+ (BOOL)boolForKey:(NSString *)key
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:key];
}

+ (void)saveBoolForKey:(NSString *)key boolValue:(BOOL)value
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:value forKey:key];
	[defaults synchronize];
}

+ (BOOL)firstTimeRunByType:(firstTimeType)type
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    
    NSString *key = nil;
    switch (type) {
        case firstTimeTypeAppDelegate:
            key = @"__first_time_key_app_delegate__";
            break;
        case firstTimeTypeHomePage:
            key = @"__first_time_key_home_page__";
            break;
        case firstTimeTypeDetailPage:
            key = @"__first_time_key_detail_page__";
            break;
        default:
            break;
    }
    
    NSString *keyWithVersion = [NSString stringWithFormat:@"%@_%@", key, [SSCommon versionName]];
    
    NSInteger firstTime = [defaluts integerForKey:keyWithVersion];
    if (firstTime == 0) {
        [defaluts setInteger:1 forKey:keyWithVersion];
        [defaluts synchronize];
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)firstTimeRunByKey:(NSString *)defaultKey
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSString *key = [[defaultKey copy] autorelease];
    
    NSInteger firstTime = [defaluts integerForKey:key];
    if (firstTime == 0) {
        return YES;
    }
    
    return NO;
}

+ (void)setNotFirstTimeRunByKey:(NSString *)defaultKey
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSString *key = [[defaultKey copy] autorelease];
    [defaluts setInteger:1 forKey:key];
    [defaluts synchronize];
}

+ (void)resetEveryTimeRunDefaults
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    [defaluts setInteger:0 forKey:@"__every_time_key_app_delegate__"];
    [defaluts setInteger:0 forKey:@"__every_time_key_home_page__"];
    [defaluts setInteger:0 forKey:@"__every_time_key_detail_page__"];
    [defaluts synchronize];
}

+ (BOOL)everyTimeRunByType:(everyTimeRunType)type
{
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    
    NSString *key = nil;
    switch (type) {
        case everyTimeRunTypeAppDelegate:
            key = @"__every_time_key_app_delegate__";
            break;
        case everyTimeRunTypeHomePage:
            key = @"__every_time_key_home_page__";
            break;
        case everyTimeRunTypeDetailPage:
            key = @"__every_time_key_detail_page__";
            break;
        default:
            break;
    }
    
    NSInteger firstTime = [defaluts integerForKey:key];
    if (firstTime == 0) {
        [defaluts setInteger:1 forKey:key];
        [defaluts synchronize];
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)firstTimeRun
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSInteger fistTime = [defaults integerForKey:@"__first_time_key__"];
    if (fistTime == 0) {
        [defaults setInteger:1 forKey:@"__first_time_key__"];
        [defaults synchronize];
        return YES;
    }
    return NO;
}
@end
