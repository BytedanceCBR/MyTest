//
//  ArticleMomentShouldAutoReloadManager.m
//  Article
//
//  Created by 徐霜晴 on 16/12/4.
//
//

#import "ArticleMomentShouldAutoReloadManager.h"

static NSString * const kUserDefaultsLastReloadWeitoutiaoTimeKey = @"kUserDefaultsLastReloadWeitoutiaoTimeKey";
static const NSTimeInterval kShouldAutoReloadWeitoutiaoTimeInterval = 6 * 60 * 60; //6小时自动刷新一次

@implementation ArticleMomentShouldAutoReloadManager

+ (BOOL)shouldAutoReloadWeitoutiao {
    NSTimeInterval lastReloadTime = [self lastReloadWeitoutiaoTime];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - lastReloadTime >= kShouldAutoReloadWeitoutiaoTimeInterval) {
        return YES;
    }
    return NO;
}

+ (NSTimeInterval)lastReloadWeitoutiaoTime {
    NSNumber * num = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLastReloadWeitoutiaoTimeKey];
    return [num doubleValue];
}


@end
