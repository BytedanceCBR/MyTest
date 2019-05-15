//
//  TTVideoResolutionService.m
//  Article
//
//  Created by liuty on 2017/1/11.
//
//

#import "TTVideoResolutionService.h"
//#import "SSCommonLogic.h"

static NSString *const kDefaultResolutionTypeKey = @"kDefaultResolutionTypeKey";
static NSString *const kProgressWhenResolutionChangedKey = @"kProgressWhenResolutionChangedKey";
static NSString *const kAutoModeEnableKey = @"kAutoModeEnableKey";

@implementation TTVideoResolutionService

+ (TTVideoEngineResolutionType)defaultResolutionType {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDefaultResolutionTypeKey]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kDefaultResolutionTypeKey] integerValue];
    }
    return TTVideoEngineResolutionTypeAuto;
}

+ (void)setDefaultResolutionType:(TTVideoEngineResolutionType)type {
    if (type == TTVideoEngineResolutionTypeUnknown) return;
    [[NSUserDefaults standardUserDefaults] setObject:@(type) forKey:kDefaultResolutionTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)stringForType:(TTVideoEngineResolutionType)type {
    NSString *str = @"auto";
    if (type == TTVideoEngineResolutionTypeSD) {
        str = @"360p";
    } else if (type == TTVideoEngineResolutionTypeHD) {
        str = @"480p";
    } else if (type == TTVideoEngineResolutionTypeFullHD) {
        str = @"720p";
    } else if (type == TTVideoEngineResolutionType1080P) {
        str = @"1080p";
    } else if (type == TTVideoEngineResolutionTypeUnknown) {
        str = @"unknown";
    }
    return str;
}

+ (CGFloat)progressWhenResolutionChanged {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kProgressWhenResolutionChangedKey]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kProgressWhenResolutionChangedKey] floatValue];
    }
    return 0;
}

+ (void)saveProgressWhenResolutionChanged:(CGFloat)progress {
    [[NSUserDefaults standardUserDefaults] setObject:@(progress) forKey:kProgressWhenResolutionChangedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)autoModeEnable {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoModeEnableKey]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kAutoModeEnableKey] boolValue];
    }
    return YES;
}

+ (void)setAutoModeEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:kAutoModeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
