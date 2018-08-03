//
//  TTVersionHelper.m
//  Article
//
//  Created by xushuangqing on 2017/5/21.
//
//

#import "TTVersionHelper.h"

static NSString * currentVersion = nil;
static NSString * lastLaunchVersion = nil;
static double lastUpdateDate = 0;
static NSString * lastUpdateVersion = nil;

static NSString * const kUserDefaultsLastUpdateVersionKey = @"kUserDefaultsLastUpdateVersionKey";
static NSString * const kUserDefaultsLaunchVersionkey = @"kUserDefaultsLaunchVersionkey";
static NSString * const kUserDefaultsUpdateDateKey = @"kUserDefaultsUpdateDateKey";

@implementation TTVersionHelper

+ (void)load {
    [self initializeVersionHelper];
}

+ (void)initializeVersionHelper {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    currentVersion = version;
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsLaunchVersionkey];
    if (![lastVersion isKindOfClass:[NSString class]] ||
        lastVersion == nil || lastVersion.length == 0) {
        lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"kTTDBCenterAppVersion"];
    }
    lastLaunchVersion = lastVersion;
    
    if ([self isFirstLaunchAfterUpdate]) {
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kUserDefaultsUpdateDateKey];
        [[NSUserDefaults standardUserDefaults] setObject:lastLaunchVersion forKey:kUserDefaultsLastUpdateVersionKey];
    }
    lastUpdateDate = [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsUpdateDateKey];
    lastUpdateVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsLastUpdateVersionKey];
    
    [[NSUserDefaults standardUserDefaults] setValue:currentVersion forKey:kUserDefaultsLaunchVersionkey];
}

+ (BOOL)isFirstLaunchAfterUpdate {
    if ([currentVersion isEqualToString:lastLaunchVersion]) {
        return NO;
    }
    return YES;
}

+ (NSString *)currentVersion {
    return currentVersion;
}

+ (NSString *)lastLaunchVersion {
    return lastLaunchVersion;
}

+ (double)lastUpdateTimestamp {
    return lastUpdateDate;
}

+ (NSString *)lastUpdateVersion {
    return lastUpdateVersion;
}

@end
