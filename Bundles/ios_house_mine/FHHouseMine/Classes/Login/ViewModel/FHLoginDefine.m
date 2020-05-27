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
NSString *const FHLoginTrackLoginSuggestMethodKey = @"FHLoginTrackLoginSuggestMethodKey";

@implementation FHLoginTrackHelper

+ (void)loginShow:(NSDictionary *)dict{
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    if (!trackDict[@"trigger"]) {
        trackDict[@"trigger"] = @"user";
    }
    if (!trackDict[@"enter_method"] && trackDict[@"enter_type"]) {
        trackDict[@"enter_method"] = trackDict[@"enter_type"];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginMethod = [userDefaults stringForKey:FHLoginTrackLastLoginMethodKey];
    if (lastLoginMethod) {
        trackDict[@"last_login_method"] = lastLoginMethod;
    }
    NSString *suggestLoginMethod = [userDefaults stringForKey:FHLoginTrackLoginSuggestMethodKey];
    if (suggestLoginMethod) {
        trackDict[@"login_suggest_method"] = suggestLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_notify", trackDict.copy);
}

+ (void)loginSubmit:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    if (!trackDict[@"trigger"]) {
        trackDict[@"trigger"] = @"user";
    }
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
    if (!trackDict[@"trigger"]) {
        trackDict[@"trigger"] = @"user";
    }
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
    NSString *suggestLoginMethod = [userDefaults stringForKey:FHLoginTrackLoginSuggestMethodKey];
    if (suggestLoginMethod) {
        trackDict[@"login_suggest_method"] = suggestLoginMethod;
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
    NSString *suggestLoginMethod = [userDefaults stringForKey:FHLoginTrackLoginSuggestMethodKey];
    if (suggestLoginMethod) {
        trackDict[@"login_suggest_method"] = suggestLoginMethod;
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_exit", trackDict.copy);
}

+ (void)loginPopup:(NSDictionary *)dict error:(NSError *)error{
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";

    if (error) {
        trackDict[@"error_code"] = [@(error.code) stringValue];
        trackDict[@"fail_info"] = error.localizedDescription;
    }
    trackDict[@"popup_type"] = @"抖音带手机号绑定冲突";
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_popup", trackDict.copy);
}

+ (void)loginPopupClick:(NSDictionary *)dict error:(NSError *)error{
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";

    if (error) {
        trackDict[@"error_code"] = [@(error.code) stringValue];
        trackDict[@"fail_info"] = error.localizedDescription;
    }
    trackDict[@"popup_type"] = @"抖音带手机号绑定冲突";
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_login_popup_click", trackDict.copy);
}

+ (void)bindShow:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_bind_notify", trackDict.copy);
}

+ (void)bindSubmit:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    trackDict[@"trigger"] = @"user";
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_bind_submit", trackDict.copy);
}

+ (void)bindResult:(NSDictionary *)dict error:(NSError *)error {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    
    if (error) {
        trackDict[@"status"] = @"fail";
        trackDict[@"error_code"] = [@(error.code) stringValue];
        trackDict[@"fail_info"] = error.localizedDescription;
    } else {
        trackDict[@"status"] = @"success";
    }
    trackDict[@"trigger"] = @"user";
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_bind_result", trackDict.copy);
}

+ (void)bindExit:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];

    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_bind_click_exit", trackDict.copy);
}

+ (void)bindSendSMS:(NSDictionary *)dict error:(NSError *)error {
    if (!dict) {
        return;
    }
    NSMutableDictionary *trackDict = [dict mutableCopy];
    if (error) {
        trackDict[@"status"] = @"fail";
        trackDict[@"error_code"] = [@(error.code) stringValue];
        trackDict[@"fail_info"] = error.localizedDescription;
    } else {
        trackDict[@"status"] = @"success";
    }
    trackDict[@"params_for_special"] = @"uc_login";
    TRACK_EVENT(@"uc_send_sms", trackDict.copy);
}

@end
