//
//  TTRNCommonABTest.m
//  Article
//
//  Created by liuzuopeng on 9/18/16.
//
//

#import "TTRNCommonABTest.h"

static NSString *const kRNCommonABTestEnabledKey = @"kRNCommonABTestEnabledKey";

@implementation TTRNCommonABTest

+ (void)setRNEnabledOfPage:(TTRNPageEnabledType)pageType forValue:(BOOL)supported {
    NSUInteger rnValue = [[NSUserDefaults standardUserDefaults] integerForKey:kRNCommonABTestEnabledKey];
    if (supported) {
        rnValue = rnValue | pageType;
    } else {
        rnValue = rnValue & ~pageType;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:rnValue forKey:kRNCommonABTestEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)RNEnabledOfPage:(TTRNPageEnabledType)pageType {
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        return NO;
    }
    NSUInteger rnValue = [[NSUserDefaults standardUserDefaults] integerForKey:kRNCommonABTestEnabledKey];
    return rnValue & pageType;
}

+ (BOOL)RNEnabledDefault {
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        return NO;
    }
    NSUInteger rnValue = [[NSUserDefaults standardUserDefaults] integerForKey:kRNCommonABTestEnabledKey];
    return rnValue & kTTRNPageEnabledTypeAll;
}

@end
