//
//  TTAccountTestSettings.m
//  Article
//
//  Created by liuzuopeng on 02/08/2017.
//
//

#import "TTAccountTestSettings.h"



@implementation TTAccountTestSettings

+ (void)parseAccountConfFromSettings:(NSDictionary *)settings
{
    if (![settings isKindOfClass:[NSDictionary class]]) return;
    
    /** account settings */
    NSDictionary *accountSettings = settings[@"tt_account_settings"];
    
    if ([accountSettings isKindOfClass:[NSDictionary class]]) {
        /** test request userInfo */
        NSDictionary *userInfoTestDict = accountSettings[@"tt_user_info_test"];
        if ([userInfoTestDict isKindOfClass:[NSDictionary class]]) {
            NSInteger requestCond  = [userInfoTestDict[@"request_user_info_condition"] integerValue];
            NSInteger requestDelay = [userInfoTestDict[@"request_user_info_delay"] integerValue];
            
            s_reqUserInfoCondition = requestCond;
            s_delayTimeInterval    = requestDelay;
        }
        
        NSNumber *threadSafeNumber = accountSettings[@"account_thread_safe_supported"];
        [[NSUserDefaults standardUserDefaults] setObject:threadSafeNumber forKey:kTTAccountThreadSafeOperationSupportedKey];
        
        NSNumber *httpRespNumber = accountSettings[@"account_http_response_serializer_enabled"];
        [[NSUserDefaults standardUserDefaults] setObject:httpRespNumber forKey:kTTAccountHandleHttpResponseSerializerEnabledKey];
        
        NSNumber *filterHttpErrorNumber = accountSettings[@"account_filter_normal_http_error_enabled"];
        [[NSUserDefaults standardUserDefaults] setObject:filterHttpErrorNumber forKey:kTTAccountFilterNormalHTTPServerRespErrorEnabledKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


static NSString *kTTAccountThreadSafeOperationSupportedKey = @"kTTAccountThreadSafeOperationSupportedKey";

+ (BOOL)threadSafeSupported
{
    NSNumber *aNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAccountThreadSafeOperationSupportedKey];
    if ([aNumber respondsToSelector:@selector(boolValue)]) {
        return [aNumber boolValue];
    }
    return NO;
}


static NSString *kTTAccountHandleHttpResponseSerializerEnabledKey = @"kTTAccountHandleHttpResponseSerializerEnabledKey";

+ (BOOL)httpResponseSerializerHandleAccountMsgEnabled
{
    NSNumber *aNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAccountHandleHttpResponseSerializerEnabledKey];
    if ([aNumber respondsToSelector:@selector(boolValue)]) {
        return [aNumber boolValue];
    }
    return NO;
}


#pragma mark - Test Request UserInfo

static TTAccountReqUserInfo s_reqUserInfoCondition = TTAccountReqUserInfoWillEnterForeground;

+ (TTAccountReqUserInfo)reqUserInfoCond
{
    return s_reqUserInfoCondition;
}

static NSTimeInterval s_delayTimeInterval = 0.f;

+ (NSTimeInterval)delayTimeInterval
{
    return s_delayTimeInterval;
}


static NSString *kTTAccountFilterNormalHTTPServerRespErrorEnabledKey = @"kTTAccountFilterNormalHTTPServerRespErrorEnabledKey";

+ (BOOL)filterNormalHTTPServerRespErrorEnabled
{
    NSNumber *aNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAccountFilterNormalHTTPServerRespErrorEnabledKey];
    if (aNumber && [aNumber respondsToSelector:@selector(boolValue)]) {
        return [aNumber boolValue];
    }
    return YES;
}

@end
