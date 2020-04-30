//
//  FHLoginDefine.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHLoginDefine.h"
#import "FHUserTracker.h"
#import "TTTracker.h"

NSString *const FHLoginTrackLastLoginMethodKey = @"FHLoginTrackLastLoginMethodKey";

@implementation FHLoginTrackHelper

+ (void)loginShow:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }

    
    TRACK_EVENT(@"uc_login_notify", dict);
}

@end
