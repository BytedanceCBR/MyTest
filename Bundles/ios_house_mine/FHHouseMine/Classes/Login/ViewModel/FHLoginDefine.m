//
//  FHLoginDefine.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHLoginDefine.h"
#import "FHUserTracker.h"
#import "TTTracker.h"
#import <TTAccountSDK/TTAccount.h>

NSString *const FHLoginTrackLastLoginMethodKey = @"FHLoginTrackLastLoginMethodKey";

@implementation FHLoginTrackHelper

+ (void)loginShow:(NSDictionary *)dict{
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_notify", trackDict.copy);
}

+ (void)loginSubmit:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_submit", trackDict.copy);
}

+ (void)loginResult:(NSDictionary *)dict error:(NSError *)error{
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    if (error) {
        trackDict[@"error_code"] = [@(error.code) stringValue];
        trackDict[@"fail_info"] = error.localizedDescription;
    }
    if (![trackDict objectForKey:@"status"]) {
        if ([TTAccount sharedAccount].isLogin) {
            trackDict[@"status"] = @"success";
        } else {
            trackDict[@"status"] = @"fail";
        }
    }
    TRACK_EVENT(@"uc_login_result", trackDict.copy);
}

+ (void)loginMore:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_more", trackDict.copy);
}

+ (void)loginExit:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_exit", trackDict.copy);
}

@end
