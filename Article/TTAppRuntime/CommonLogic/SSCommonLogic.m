//
//  SSCommonLogic.m
//  Article
//
//  Created by Dianwei on 12-11-19.
//
//

#import "SSCommonLogic.h"
#import "NetworkUtilities.h"
#import "TTNetworkDefine.h"

#import "SSUpdateListNotifyManager.h"
#import "TTArticleCategoryManager.h"

#import "TTDeviceHelper.h"
#import "TTNavigationController.h"
#import "TTInstallIDManager.h"
//#import "TTPLManager.h"
#import "TTNetworkToutiaoDefine.h"
#import "TTArticleSearchManager.h"
#import "TTCookieManager.h"
//#import "TTIMManager.h"
//#import "TTSettingMineTabManager.h"

#import <TTAccountBusiness.h>
#import <TTAccountMulticastDispatcher.h>
#import "TTAccountTestSettings.h"
#import "TTJSBAuthManager.h"

#import "SSInHouseFeatureManager.h"
#import "TTVSettingsConfiguration.h"
#import <TTSettingsManager.h>

#define kErrorDescriptionAPIKey @"description"

#define kShareTemplatesKey @"kShareTemplatesKey"
#define KInterceptURLsKey @"KInterceptURLsKey"//拦截跳转

#define kCommentInputViewPlaceHolder @"kCommentInputViewPlaceHolder"    // 评论/转发/回复时，如果输入框内容为空，出一条提示，此提示由服务端控制

#define kInstallAppsIntervalKey @"kInstallAppsIntervalKey"
#define kRecentAppsIntervalKey @"kRecentAppsIntervalKey"

NSString * const kIntroductionViewControllerRemovedNotification = @"kIntroductionViewControllerRemovedNotification";
NSString * const kFeedRefreshButtonSettingEnabledNotification = @"kFeedRefreshButtonSettingEnabledNotification";
NSString * const kFirstRefreshTipsSettingEnabledNotification = @"kFirstRefreshTipsSettingEnabledNotification";

static NSMutableDictionary * timeDict;

static NSUInteger const kMiniAlertTime = 7200; //两个alert相隔最少的时间
static NSUInteger const kMinimumLocationUploadTimeInterval = 600;

NSError *ttcommonlogic_handleError(NSError *error, NSDictionary *result, NSString **exceptionInfo) {
    return [SSCommonLogic handleError:error responseResult:result exceptionInfo:exceptionInfo];
}

BOOL ttsettings_showRefreshButton(void) {
    return [SSCommonLogic showRefreshButton];
}
BOOL ttsettings_shouldShowLastReadForCategoryID(NSString *categoryID) {
    return [SSCommonLogic shouldShowLastReadForCategoryID:categoryID];
}
BOOL ttsettings_getAutoRefreshIntervalForCategoryID(NSString *categoryID) {
    return [SSCommonLogic getAutoRefreshIntervalForCategoryID:categoryID];
}

NSInteger ttsettings_favorDetailActionType(void) {
    return [SSCommonLogic favorDetailActionType];
}

NSArray *ttsettings_favorDetailActionTick(void) {
    return [SSCommonLogic favorDetailActionTick];
}

NSInteger ttuserdefaults_favorCount(void) {
    return [SSCommonLogic favorCount];
}

void ttuserdefaults_setFavorCount(NSInteger favorCount) {
    [SSCommonLogic setFavorCount:favorCount];
}

BOOL ttsettings_articleNavBarShowFansNumEnable(void) {
    return [SSCommonLogic articleNavBarShowFansNumEnable];
}

NSInteger ttsettings_navBarShowFansMinNum(void) {
    return [SSCommonLogic navBarShowFansMinNum];
}

void ttuserdefaults_setSubscribeCount(NSInteger count) {
    [SSCommonLogic  setSubscribeCount:count];
}

static SSCommonLogic * s_manager;


@implementation SSCommonLogic

#ifndef SS_TODAY_EXTENSTION

- (void)setSsIPhoneSupportRotate:(BOOL)ssIPhoneSupportRotate
{
    _ssIPhoneSupportRotate = ssIPhoneSupportRotate;
}

+ (SSCommonLogic *)shareCommonLogic
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[SSCommonLogic alloc] init];
    });
    return s_manager;
}

+ (void)setObject:(id)value forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

+ (NSString *)stringForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (BOOL)boolForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (float)floatForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}

+ (NSMutableDictionary *)shareTimeDict
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeDict = [[NSMutableDictionary alloc] init];
    });
    return timeDict;
}

+ (void)updateRequestTimeForKey:(SSCommonLogicTimeDictKey)key
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval data = [[NSDate date] timeIntervalSince1970];
        NSString * keyStr = [NSString stringWithFormat:@"%i", key];
        [[self shareTimeDict] setValue:@(data) forKey:keyStr];
    });
}

+ (BOOL)couldRequestForKey:(SSCommonLogicTimeDictKey)key
{
    NSString * keyStr = [NSString stringWithFormat:@"%i", key];
    NSTimeInterval time = 0;
    
    if ([[[self shareTimeDict]allKeys] containsObject:keyStr]) {
        time = [[[self shareTimeDict] objectForKey:keyStr] doubleValue];
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval detla = 0;
    switch (key) {
        case SSCommonLogicTimeDictRequestGetDomainKey:
        {
            detla = 60 * 60 * 3; //fetch get domains every 3 hours
        }
            break;
        case SSCommonLogicTimeDictRequestFeedbackKey:
        {
            detla = 60 * 30;
        }
            break;
        case SSCommonLogicTimeDictRequestAppAlertKey:
        {
            detla = 60 * 3;
        }
            break;
        case SSCommonLogicTimeDictRequestCategoryKey:
        {
            if ([TTArticleCategoryManager hasGotRemoteData]) {
                detla = 60 * 60;
            }
            else {
                detla = 20;
            }
        }
            break;
        case SSCommonLogicTimeDictRequestCheckVersionKey:
        {
            detla = 60 * 60 * 12;
        }
            break;
        case SSCommonLogictimeDictRequestAppActivityKey:
        {
            detla = 60 * 5;
        }
            break;
        case SSCommonLogicTimeDictRequestUpdateListAutoReloadKey:
        {
            detla = [SSUpdateListNotifyManager refreshUpdateListTimeinterval];
        }
            break;
        case SSCommonLogicTimeDictRequestChannelKey:
        {
            detla = 60 * 60;
        }
            break;
        default:
            break;
    }
    if (now - time > detla) {
        return YES;
    }
    return NO;
}

+ (NSString *)parseShareContentWithTemplate:(NSString *)templateString title:(NSString *)t shareURLString:(NSString *)urlString
{
    if (isEmptyString(templateString)) {
        return nil;
    }
    
    @try {
        NSString * dealString = templateString;
        
        NSMutableString * resultString = [NSMutableString stringWithCapacity:50];
        
        NSString * patternStr = @"\\{.*?\\}";
        NSError *tError = nil;
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:patternStr options:NSRegularExpressionCaseInsensitive error:&tError];
        
        int replacedCount = 0;
        while (replacedCount < 30) {
            replacedCount ++;
            NSRange matchRange = [regex rangeOfFirstMatchInString:dealString options:0 range:NSMakeRange(0, [dealString length])];
            if (matchRange.location == NSNotFound) {
                [resultString appendString:dealString];
                break;
            }
            [resultString appendString:[dealString substringToIndex:matchRange.location]];
            
            NSString * subStr = [dealString substringWithRange:matchRange];
            if (subStr != nil) {
                NSArray * ary = nil;
                if ([subStr length] >= 3) {
                    NSString * tempStr = [subStr substringWithRange:NSMakeRange(1, [subStr length] - 2)];
                    ary = [tempStr componentsSeparatedByString:@":"];
                }
                NSString * replaceString = nil;
                if ([ary count] == 1) {
                    if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"share_url"]) {
                        replaceString = urlString;
                    }
                    else if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"title"]) {
                        replaceString = t;
                    }
                    
                }
                else if ([ary count] == 2) {
                    
                    NSString * tmpStr = nil;
                    
                    if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"title"]) {
                        tmpStr = t;
                    }
                    else if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"share_url"]) {
                        tmpStr = urlString;
                    }
                    
                    int length = [[ary objectAtIndex:1] intValue];
                    
                    if ([tmpStr length] <= length) {
                        replaceString = tmpStr;
                    }
                    else {
                        replaceString = [tmpStr substringToIndex:length];
                    }
                }
                if (replaceString) {
                    [resultString appendString:replaceString];
                }
                if ((matchRange.location + matchRange.length) < [dealString length]) {
                    dealString = [dealString substringFromIndex:matchRange.location + matchRange.length];
                }
                else {
                    break;
                }
                
            }
        }
        
        return resultString;
        
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (void)saveInterceptURLs:(NSArray *)ary
{
    if ([ary count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KInterceptURLsKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:ary forKey:KInterceptURLsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getInterceptURLs
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KInterceptURLsKey];
}

+ (void)saveShareTemplate:(NSDictionary *)dict
{
    if (dict == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kShareTemplatesKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kShareTemplatesKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)getShareTemplate
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kShareTemplatesKey];
    return dict;
}

+ (NSString *)getRecentAppsInterval{
    
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentAppsIntervalKey];
    return string;
}

+ (void)saveRecentAppsInterval:(NSString *)recentAppsInterval{
    
    if (recentAppsInterval == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRecentAppsIntervalKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:recentAppsInterval forKey:kRecentAppsIntervalKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getInstallAppsInterval{
    
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:kInstallAppsIntervalKey];
    return string;
}

+ (void)saveInstallAppsInterval:(NSString *)installAppsInterval{
    
    if (installAppsInterval == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstallAppsIntervalKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:installAppsInterval forKey:kInstallAppsIntervalKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)monitorLoginoutWithUrl:(NSString *)url status:(NSInteger)status error:(NSError *)error
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    NSString *message = error.userInfo[kErrorDisplayMessageKey];
    if(!isEmptyString(message)) {
        [extra setObject:message forKey:@"message"];
    }
    NSString *errorCode = [NSString stringWithFormat:@"%zd",error.code];
    [extra setObject:errorCode forKey:@"error_code"];
    NSString *isLogin = [NSString stringWithFormat:@"%d",[TTAccountManager isLogin]];
    [extra setObject:isLogin forKey:@"is_login"];
    if(!isEmptyString(url)) {
        [extra setObject:url forKey:@"url"];
    }
    
    NSString *deviceID  = [[TTInstallIDManager sharedInstance] deviceID];
    if(!isEmptyString(deviceID)) {
        [extra setObject:deviceID forKey:@"device_id"];
    }
    
    NSString *userID = [TTAccountManager userID];
    if(!isEmptyString(userID)) {
        [extra setObject:userID forKey:@"user_id"];
    }
    
    if(!isEmptyString(error.description)) {
        [extra setObject:error.description forKey:@"error_description"];
    }
    [[TTMonitor shareManager] trackService:@"account_coerced_logout" status:status extra:extra];
}

+ (NSError*)handleError:(NSError*)error responseResult:(NSDictionary*)result exceptionInfo:(NSString**)exceptionInfo
{
    return [self handleError:error responseResult:result exceptionInfo:exceptionInfo treatExceptionAsError:YES];
}

+ (NSError*)handleError:(NSError*)error responseResult:(NSDictionary*)result exceptionInfo:(NSString**)exceptionInfo treatExceptionAsError:(BOOL)treat {
    return [self handleError:error responseResult:result exceptionInfo:exceptionInfo treatExceptionAsError:YES requestURL:nil];
}

+ (NSError*)handleError:(NSError*)error responseResult:(NSDictionary*)result exceptionInfo:(NSString**)exceptionInfo treatExceptionAsError:(BOOL)treat requestURL:(NSString *)requestURL
{
    
    
    if (!result && [error.userInfo[@"TTNetworkErrorOriginalDataKey"] isKindOfClass:[NSData class]]) {
        NSData *data = error.userInfo[@"TTNetworkErrorOriginalDataKey"];
        NSDictionary *resultData = nil;
        @try {
            resultData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }
        @catch (NSException *exception) {
            
        }
        if ([resultData isKindOfClass:[NSDictionary class]]) {
            result = @{@"result":resultData};
        }
    }
    
    NSError *resultError = nil;
    int errorCode = 0;
    NSString *errorMessage = nil;
    NSDictionary *userInfo = nil;
    
    NSString *status = [[result tt_dictionaryValueForKey:@"result"] tt_stringValueForKey:@"message"];
    
    if([status isEqualToString:@"exception"]) {
        if(exceptionInfo)
        {
            *exceptionInfo = [[result objectForKey:@"result"] objectForKey:@"data"];
            if(isEmptyString((*exceptionInfo)))
            {
                *exceptionInfo = @"unkown exception";
            }
        }
        
        NSError *result = nil;
        if(treat)
        {
            result =  [NSError errorWithDomain:kCommonErrorDomain code:kExceptionErrorCode userInfo:[NSDictionary dictionaryWithObject:kExceptionTipMessage forKey:kErrorDisplayMessageKey]];
        }
        
        return result;
    }
    
    // invalid message
    NSError *customError = [error.userInfo objectForKey:kTTNetworkCustomErrorKey];
    
    if(!isEmptyString(status) && ![status isEqualToString:@"success"] && ![status isEqualToString:@"error"])
    {
        error = [NSError errorWithDomain:kCommonErrorDomain code:kInvalidDataFormatErrorCode userInfo:[NSDictionary dictionaryWithObject:kDataErrorTipMessage forKey:kErrorDisplayMessageKey]];
        return error;
    }
    
    if(error && !TTNetworkConnected())
    {
        errorCode = kNoNetworkErrorCode;
        errorMessage = kNoNetworkTipMessage;
    }
    else if((error && [[error domain] isEqualToString:kTTNetworkErrorDomain]) || (customError && [[customError domain] isEqualToString:kTTNetworkErrorDomain]))
    {
        errorCode = kNoNetworkErrorCode;
        if(error.code == TTNetworkErrorCodeNetworkError || customError.code == TTNetworkErrorCodeNetworkError) {
            errorMessage = kNetworkConnectionErrorTipMessage;
        } else if (error.code == TTNetworkErrorCodeNetworkHijacked || customError.code == TTNetworkErrorCodeNetworkHijacked) {
            errorMessage = kNetworkConnectionHijackTipMessage;
        } else if (error.code == kTTNetworkManagerJsonResultNotDictionaryErrorCode || customError.code == kTTNetworkManagerJsonResultNotDictionaryErrorCode) {
            errorCode = kInvalidDataFormatErrorCode;
            errorMessage = kJSONParseErrorTipMessage;
        } else if (error.code == NSURLErrorCancelled) {
            errorCode = NSURLErrorCancelled;
        }
    }
    
    // specific error
    if(!isEmptyString(status) && [status isEqualToString:@"error"])
    {
        NSDictionary *data = [[result objectForKey:@"result"] objectForKey:@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            userInfo = data;
        }
        if ([data isKindOfClass:[NSDictionary class]] && [data.allKeys containsObject:@"name"])
        {
            NSString *strName = [data objectForKey:@"name"];
            if([strName isEqualToString:@"auth_failed"])
            {
                errorCode = kAuthenticationFailCode;
                errorMessage = kUserAuthErrorTipMessage;
            }
            else if([strName isEqualToString:@"session_expired"])
            {
                SSLog(@"%s, error:%@, result:%@", __PRETTY_FUNCTION__, error, result);
                errorCode = kSessionExpiredErrorCode;
                errorMessage = kSessionExpiredTipMessage;
            }
            else if([strName isEqualToString:@"name_existed"])
            {
                errorCode = kChangeNameExistsErrorCode;
            }
            else if([strName isEqualToString:@"user_not_exist"])
            {
                errorCode = kUserNotExistErrorCode;
                errorMessage = kUserNotExistTipMessage;
            }
            else if([strName isEqualToString:@"antispam_error"])
            {
                errorCode = kUGCAntispamErrorCode;
                if ([data.allKeys containsObject:kErrorDescriptionAPIKey]) {
                    errorMessage = [data objectForKey:kErrorDescriptionAPIKey];
                }
                else {
                    errorMessage = kUGCAntispamTipMessage;
                }
            }
            else if([strName isEqualToString:@"ugc_post_too_fast"])
            {
                errorCode = kUGCUserPostTooFastErrorCode;
                if ([data.allKeys containsObject:kErrorDescriptionAPIKey]) {
                    errorMessage = [data objectForKey:kErrorDescriptionAPIKey];
                }
                else {
                    errorMessage = kUGCUserPostTooFastTipMessage;
                }
            }
            else if([strName isEqualToString:@"connect_switch"]) {
                errorCode = kAccountBoundForbidCode;
                errorMessage = kAccountBountForbidMessage;
            }
            else
            {
                errorCode = kUndefinedErrorCode;
                errorMessage = [data objectForKey:@"description"];
                if (isEmptyString(errorMessage)) errorMessage = @"";
            }
            
            //如果错误里包含description 那没用他来做 errorMsg -- 5.3 nick
            if (data[@"description"]) {
                errorMessage = data[@"description"];
            }
            
        }
        else if ([data isKindOfClass:[NSDictionary class]] && [data.allKeys containsObject:@"error_code"])
        {
            int ec = [[data valueForKey:@"error_code"] intValue];
            switch (ec) {
                case 1101:
                {
                    errorCode = kPRNeedCaptchaCode;
                }
                    break;
                case 1102:
                {
                    errorCode = kPRWrongCaptchaErrorCode;
                }
                    break;
                case 1103:
                {
                    errorCode = kPRExpiredCaptchaErrorCode;
                }
                    break;
                case 1001:
                {
                    errorCode = kPRHasRegisteredErrorCode;
                }
                    break;
                case 1002:
                {
                    errorCode = kPRPhoneNumberEmptyErrorCode;
                }
                    break;
                default:
                {
                    errorCode = kPROtherErrorCode;
                }
                    break;
            }
            
            errorMessage = [data objectForKey:@"description"];
            if (isEmptyString(errorMessage)) errorMessage = @"";
        }
        else
        {
            errorCode = kUndefinedErrorCode;
            errorMessage = [data valueForKey:@"description"];
            if (isEmptyString(errorMessage)) errorMessage = @"";
        }
    }
    
    //    #warning remove it
    //    errorCode = kSessionExpiredErrorCode;
    
    if ([[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"expired_platform"]) { // it's not an error, if care about this, register kPlatformExpiredNotification
        NSString *platformString = [[result objectForKey:@"result"] objectForKey:@"expired_platform"];
        NSArray *platforms = [platformString componentsSeparatedByString:@","];
        
        if (![TTAccountTestSettings httpResponseSerializerHandleAccountMsgEnabled]) {
            
            [[TTPlatformAccountManager sharedManager] cleanExpiredPlatformAccountsByNames:platforms];
            
            // 发送平台过期消息
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setValue:[[TTAccountManager userID] copy] forKey:@"user_id"];
            [userInfo setValue:platforms forKey:kExpiredPlatformKey];
            [userInfo setValue:error.description forKey:@"error_description"];
            [userInfo setValue:platformString forKey:@"expired_platforms"];
            [userInfo setValue:platformString forKey:TTAccountAuthPlatformNameKey];
            [userInfo setValue:@(TTAccountErrCodePlatformExpired) forKey:TTAccountStatusCodeKey];
            NSError *platformExpirationError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            [TTAccountMulticastDispatcher dispatchAccountExpireAuthPlatform:platformString error:platformExpirationError bisectBlock:nil];
        }
        
        // if has platform expired, session_expired should be ignored
        if (errorCode == kSessionExpiredErrorCode) {
            errorCode = 0;
            errorMessage = nil;
        }
    }
    
    if (errorCode != 0 && errorCode != NSURLErrorCancelled) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
        if (userInfo) {
            [dict addEntriesFromDictionary:userInfo];
        }
        
        NSString *description = [error.userInfo objectForKey:@"description"];
        errorMessage = isEmptyString(errorMessage) && !isEmptyString(description) ? description : errorMessage;
        
        [dict setValue:errorMessage forKey:kErrorDisplayMessageKey];
        resultError = [NSError errorWithDomain:kCommonErrorDomain code:errorCode userInfo:dict];
        if (errorCode == kSessionExpiredErrorCode) {
            BOOL loggedOnCurrently = [TTAccountManager isLogin];
            NSString *userIDString = [[TTAccountManager userID] copy];
            
            if (![TTAccountTestSettings httpResponseSerializerHandleAccountMsgEnabled]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
                    [errorUserInfo setValue:userIDString forKey:@"user_id"];
                    [errorUserInfo setValue:(loggedOnCurrently ? @(1) : @(0)) forKey:@"is_login"];
                    [errorUserInfo setValue:requestURL forKey:@"request_url"];
                    [errorUserInfo setValue:error.description forKey:@"error_description"];
                    [errorUserInfo setValue:@(error.code) forKey:@"error_code"];
                    [errorUserInfo setValue:result forKey:@"response"];
                    [errorUserInfo setValue:@(TTAccountErrCodeSessionExpired) forKey:TTAccountStatusCodeKey];
                    if (exceptionInfo) {
                        [errorUserInfo setValue:*exceptionInfo forKey:@"context"];
                    }
                    NSError *accountError = [NSError errorWithDomain:error.domain code:error.code userInfo:errorUserInfo];
                    [TTAccountMulticastDispatcher dispatchAccountSessionExpired:accountError bisectBlock:nil];
                });
            }
            
            // 目前会话过期会自动清理用户信息
            [TTAccountManager setIsLogin:NO];
        }
    } else {
        resultError = error;
    }
    
    return resultError;
}


+ (BOOL)isZoneVersion
{
    return [[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.ss.iphone.essay.EssayZone"];
}

+ (NSNumber *)fixNumberTypeGroupID:(NSNumber *)gID
{
    long long fixedID = [self fixLongLongTypeGroupID:[gID longLongValue]];
    return @(fixedID);
}

+ (long long)fixLongLongTypeGroupID:(long long)gIDStr
{
    long long fixedID = gIDStr;
    if (fixedID < 0) {  //逻辑修正，爱看2.7(包括)版本之前，使用int32存储groupID，溢出，新版本需要兼容负数groupID
        fixedID = fixedID + 4294967296;
    }
    return fixedID;
}

+ (NSString *)fixStringTypeGroupID:(NSString *)gIDStr
{
    long long fixedID = [self fixLongLongTypeGroupID:[gIDStr longLongValue]];
    NSString * fixedGroupIDString = [NSString stringWithFormat:@"%lli", fixedID];
    return fixedGroupIDString;
}

//评论/转发/回复时，如果输入框内容为空，出一条提示，此提示由服务端控制
+ (NSString *)commentInputViewPlaceHolder {
    NSString * placeHolder = [[NSUserDefaults standardUserDefaults] stringForKey:kCommentInputViewPlaceHolder];
    if (![placeHolder isKindOfClass:[NSString class]] || placeHolder.length==0) {
        placeHolder = @"";
    }
    return placeHolder;
}

+ (void)saveCommentInputViewPlaceHolder:(NSString *)placeHolder {
    [[NSUserDefaults standardUserDefaults] setObject:placeHolder forKey:kCommentInputViewPlaceHolder];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#endif

@end

#ifndef SS_TODAY_EXTENSTION

NSString * const SSCommonLogicSettingDisabledTBUFPKey = @"tbufpdisabled";
NSString * const SSCommonLogicSettingTokenKey = @"apptoken";
NSString * const SSCommonLogicSettingTBUFPTimeIntervalKey = @"ufprequesttimeinterval";

@implementation SSCommonLogic (TaobaoUFP)

+ (BOOL) disabledTBUFP {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL disabled = YES;
    if ([userDefaults valueForKey:SSCommonLogicSettingDisabledTBUFPKey]) {
        disabled = [[userDefaults valueForKey:SSCommonLogicSettingDisabledTBUFPKey] boolValue];
    }
    return disabled;
}

+ (void) setDisabledTBUFP:(BOOL) disabled {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(disabled) forKey:SSCommonLogicSettingDisabledTBUFPKey];
    [userDefaults synchronize];
}

+ (NSString *) token {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * token = nil;
    if ([userDefaults valueForKey:SSCommonLogicSettingTokenKey]) {
        token = [NSString stringWithFormat:@"%@",[userDefaults valueForKey:SSCommonLogicSettingTokenKey]];
    }
    return token;
}

+ (void) setToken:(NSString *) token {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:token forKey:SSCommonLogicSettingTokenKey];
    [userDefaults synchronize];
}

/// 默认10分钟
+ (NSTimeInterval) minimumTimeInterval {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval timeInterval = 60*10;
    if ([userDefaults valueForKey:SSCommonLogicSettingTBUFPTimeIntervalKey]) {
        timeInterval = [[userDefaults valueForKey:SSCommonLogicSettingTBUFPTimeIntervalKey] doubleValue];
    }
    return timeInterval;
}
+ (void) setMinimumTimeInterval:(NSTimeInterval) timeInterval {
    if (timeInterval == 0) {
        timeInterval = 60 * 10;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(timeInterval) forKey:SSCommonLogicSettingTBUFPTimeIntervalKey];
    [userDefaults synchronize];
}

@end


NSString * const SSCommonLogicLocationUploadKey = @"SSCommonLogicLocationUploadKey";
NSString * const SSCommonLogicLocateTimeoutKey = @"SSCommonLogicLocateTimeoutKey";
NSString * const SSCommonLogicLocationAlertKey = @"SSCommonLogicLocationAlertKey";
NSString * const SSCommonLogicLocationBaiduKey = @"SSCommonLogicLocationBaiduKey";
NSString * const SSCommonLogicLocationAmapKey = @"SSCommonLogicLocationAmapKey";

@implementation SSCommonLogic (TTUploadLocation)

+ (NSString *)baiduMapKey {
    //    return @"ZLEavPGATUQ55W7SRqyTHLE8";
    return [[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicLocationBaiduKey];
}

+ (void)setBaiduMapKey:(NSString *)baiduMapKey {
    [[NSUserDefaults standardUserDefaults] setValue:baiduMapKey forKey:SSCommonLogicLocationBaiduKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSString *)amapKey {
    //    return @"9cd846b712242e1e28dda3d1dd2c1d12";
    return [[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicLocationAmapKey];
}

+ (void)setAmapKey:(NSString *)amapKey {
    [[NSUserDefaults standardUserDefaults] setValue:amapKey forKey:SSCommonLogicLocationAmapKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// 定位超时时间
+ (void)setLocateTimeoutInterval:(NSTimeInterval)timeoutInterval {
    if (timeoutInterval == 0) {
        timeoutInterval = 60;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(timeoutInterval) forKey:SSCommonLogicLocateTimeoutKey];
    [userDefaults synchronize];
}

/// 定位超时时间 60s 是对定位起码的保护
+ (NSTimeInterval)locateTimeoutInterval {
    return MAX([[[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicLocateTimeoutKey] doubleValue], 60);
}

+ (NSTimeInterval)minimumLocationUploadTimeInterval {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval timeInterval = MAX([[userDefaults valueForKey:SSCommonLogicLocationUploadKey] doubleValue], kMinimumLocationUploadTimeInterval);
#ifdef SIMULATE_LOCATION
    timeInterval = 30;
#endif
    return timeInterval;
}

+ (void)setMinimumLocationUploadTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval == 0) {
        timeInterval = kMinimumLocationUploadTimeInterval;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(timeInterval) forKey:SSCommonLogicLocationUploadKey];
    [userDefaults synchronize];
}

+ (NSTimeInterval)minimumLocationAlertTimeInterval {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval timeInterval = kMiniAlertTime;
    if ([userDefaults valueForKey:SSCommonLogicLocationAlertKey]) {
        timeInterval = [[userDefaults valueForKey:SSCommonLogicLocationAlertKey] doubleValue];
    }
#ifdef SIMULATE_LOCATION
    timeInterval = 60;
#endif
    return timeInterval;
}

+ (void)setMinimumLocationAlertTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval == 0) {
        timeInterval = kMiniAlertTime;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(timeInterval) forKey:SSCommonLogicLocationAlertKey];
    [userDefaults synchronize];
}

@end


NSString * const SSCommonLogicSettingQuickPageTitleKey = @"SSCommonLogicSettingQuickPageTitleKey";
NSString * const SSCommonLogicSettingQuickButtonTextKey = @"SSCommonLogicSettingQuickButtonTextKey";
NSString * const SSCommonLogicSettingQuickLoginSwitch = @"SSCommonLogicSettingQuickLoginSwitch";
NSString * const SSCommonLogicSettingQuickLoginDialogTitlesKey = @"SSCommonLogicSettingQuickLoginDiaLogTitlesKey";
NSString * const SSCommonLogicSettingQuickLoginAlertTitlesKey = @"SSCommonLogicSettingQuickLoginQuickDialogTitlesKey";



@implementation SSCommonLogic (QuickRegister)
+ (NSString *)quickRegisterPageTitle  {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:SSCommonLogicSettingQuickPageTitleKey]) {
        return [userDefaults objectForKey:SSCommonLogicSettingQuickPageTitleKey];
    }
    return NSLocalizedString(@"云端同步兴趣\n精彩收藏永不丢失",nil);
}

+ (void)setQuickRegisterPageTitle:(NSString *)quickRegisterPageTitle {
    [[NSUserDefaults standardUserDefaults] setValue:quickRegisterPageTitle forKey:SSCommonLogicSettingQuickPageTitleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)quickRegisterButtonText {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:SSCommonLogicSettingQuickButtonTextKey]) {
        return [userDefaults objectForKey:SSCommonLogicSettingQuickButtonTextKey];
    }
    return NSLocalizedString(@"进入头条",nil);
}

+ (void)setQuickRegisterButtonText:(NSString *)quickRegisterButtonText {
    [[NSUserDefaults standardUserDefaults] setValue:quickRegisterButtonText forKey:SSCommonLogicSettingQuickButtonTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//5.7版本注释掉 大弹窗直接进入账户密码页面，不受服务端控制
+ (BOOL)quickLoginSwitch {
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults objectForKey:SSCommonLogicSettingQuickLoginSwitch]) {
    //        return [[userDefaults objectForKey:SSCommonLogicSettingQuickLoginSwitch] boolValue];
    //    }
    //默认关闭，采用旧版密码登录
    return NO;
}

+ (void)setQuickLoginSwitch:(BOOL)quickLogin {
    //    [[NSUserDefaults standardUserDefaults] setValue:@(quickLogin) forKey:SSCommonLogicSettingQuickLoginSwitch];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setDialogTitles:(NSDictionary *)dict {
    if (SSIsEmptyDictionary(dict)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:SSCommonLogicSettingQuickLoginDialogTitlesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)dialogTitleOfIndex:(NSUInteger)index {
    NSString *defaultTtitle = NSLocalizedString(@"手机登录", nil);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingQuickLoginDialogTitlesKey]) {
        NSDictionary *titleDict = [userDefaults objectForKey:SSCommonLogicSettingQuickLoginDialogTitlesKey];
        switch (index) {
            case 0:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_default"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_default" defaultValue:defaultTtitle];
                }
                break;
            case 1:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_register"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_register" defaultValue:defaultTtitle];
                }
                break;
            case 2:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_favor"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_favor" defaultValue:defaultTtitle];
                }
                break;
            default:
                return defaultTtitle;
                break;
        }
    }
    
    return defaultTtitle;
}

+ (void)setLoginAlertTitles:(NSDictionary *)dict {
    if (SSIsEmptyDictionary(dict)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:SSCommonLogicSettingQuickLoginAlertTitlesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)loginAlertTitleOfIndex:(NSUInteger)index{
    NSString *defaultTtitle = NSLocalizedString(@"登录你的专属头条", nil);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingQuickLoginAlertTitlesKey]) {
        NSDictionary *titleDict = [userDefaults objectForKey:SSCommonLogicSettingQuickLoginAlertTitlesKey];
        switch (index) {
            case 0:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_default"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_default" defaultValue:defaultTtitle];
                }
                break;
            case 1:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_post"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_post" defaultValue:defaultTtitle];
                }
                break;
            case 2:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_favor"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_favor" defaultValue:defaultTtitle];
                }
                break;
            case 3:
                if ([[titleDict objectForKey:@"title_social"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_social" defaultValue:defaultTtitle];
                }
                break;
            case 4:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_pgc_like"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_pgc_like" defaultValue:defaultTtitle];
                }
                break;
            case 5:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_my_favor"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_my_favor" defaultValue:defaultTtitle];
                }
                break;
            case 6:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_push_history"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_push_history" defaultValue:defaultTtitle];
                }
                break;
            case 7:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_dislike"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_dislike" defaultValue:defaultTtitle];
                }
                break;
            case 8:
                // 处理服务器返回字符串为“”的情况
                if ([[titleDict objectForKey:@"title_boot"] isEqual:@""]) {
                    return defaultTtitle;
                } else {
                    return [titleDict stringValueForKey:@"title_boot" defaultValue:defaultTtitle];
                }
                break;
            default:
                return defaultTtitle;
                break;
        }
    }
    
    return defaultTtitle;
}

@end




NSString * const SSCommonLogicSettingWapSearchKey = @"SSCommonLogicSettingWapSearchKey";

NSString * const SSCommonLogicSettingAFNetworkingKey = @"SSCommonLogicSettingAFNetworkingKey";

NSString * const SSCommonLogicSettingVideoOnTabKey = @"SSCommonLogicSettingVideoOnTabKey";

NSString * const SSCommonLogicSettingVideoOnSecondTabKey = @"SSCommonLogicSettingVideoOnSecondTabKey";

NSString * const SSCommonLogicSettingTipGestureShowKey = @"SSCommonLogicSettingTipGestureShowKey";

NSString * const SSCommonLogicSettingChatTipViewShowKey = @"SSCommonLogicSettingChatTipViewShowKey";

NSString * const SSCommonLogicSettingAccountABVersionEnabledKey = @"SSCommonLogicSettingAccountABVersionEnabledKey";

NSString * const SSCommonLogicSettingWKWebViewSettingSwitchKey = @"kWKWebViewSettingSwitchKey";

NSString * const SSCommonLogicSettingWebViewHttpsSwitchKey = @"SSCommonLogicSettingWebViewHttpsSwitchKey";

NSString * const SSCommonLogicSettingWebviewRedirectReportTypeSwitchKey = @"kWebviewRedirectReportTypeSwitchKey";

//NSString * const SSCommonLogicSettingABVersionKey = @"SSCommonLogicSettingABVersionKey";


@implementation SSCommonLogic (WebSearch)

// 4.6中 首次引入AFNetworking 做一个开关控制
+ (BOOL)enabledAFNetworking {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 服务端可以控制是否使用AFNetworking
    if ([userDefaults objectForKey:SSCommonLogicSettingAFNetworkingKey]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingAFNetworkingKey] boolValue];
    }
    // 默认开启AFNetworking
    return YES;
}

+ (void)setEnabledAFNetworking:(BOOL)enabledAFNetworking {
    [[NSUserDefaults standardUserDefaults] setValue:@(enabledAFNetworking) forKey:SSCommonLogicSettingAFNetworkingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


NSString * const SSCommonLogicWhitePageMonitorKey = @"SSCommonLogicWhitePageMonitorKey";
+ (BOOL)enabledWhitePageMonitor{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 服务端可以控制是否使用AFNetworking
    if ([userDefaults objectForKey:SSCommonLogicWhitePageMonitorKey]) {
        return [[userDefaults objectForKey:SSCommonLogicWhitePageMonitorKey] boolValue];
    }
    // 默认开启AFNetworking
    return YES;
}


+ (void)setEnabledWhitePageMonitor:(BOOL)enabledWhitePageMonitor{
    [[NSUserDefaults standardUserDefaults] setValue:@(enabledWhitePageMonitor) forKey:SSCommonLogicSettingAFNetworkingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL)enableWebViewHttps {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicSettingWebViewHttpsSwitchKey] boolValue];
}

+ (void)setEnableWebViewHttps:(BOOL)enableWebViewHttps {
    [[NSUserDefaults standardUserDefaults] setValue:@(enableWebViewHttps) forKey:SSCommonLogicSettingWebViewHttpsSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (SSCommentRedirectReportType)webviewRedirectReportType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicSettingWebviewRedirectReportTypeSwitchKey];
}

+ (void)setWebviewRedirectReportType:(SSCommentRedirectReportType)type {
    [[NSUserDefaults standardUserDefaults] setValue:@(type) forKey:SSCommonLogicSettingWebviewRedirectReportTypeSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const kSSCommonLogicSettingUseDNSMappingKey = @"SSCommonLogicSettingUseDNSMappingKey";
@implementation SSCommonLogic (TTDNSEnabled)

+ (BOOL)enabledDNSMapping {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 服务端可以控
    if ([userDefaults objectForKey:kSSCommonLogicSettingUseDNSMappingKey]) {
        
        NSInteger dns_mapping = [[userDefaults objectForKey:kSSCommonLogicSettingUseDNSMappingKey] integerValue];
        if (dns_mapping <= 0) {
            return NO;
        }
        NSInteger enable = 0;
        TTNetworkFlags nt = TTNetworkGetFlags();
        switch (nt) {
            case TTNetworkFlagWifi:
                enable = 0x1;
                break;
            case TTNetworkFlag3G:
            case TTNetworkFlag4G:
                enable = 0x2;
                break;
            case TTNetworkFlagMobile:
            case TTNetworkFlag2G:
                enable = 0x4;
                break;
            default:
                break;
        }
        if ((enable & dns_mapping) > 0) {
            return YES;
        }
        return  NO;
    }
    // 默认关
    return NO;
}

+ (void)setEnabledDNSMapping:(NSInteger)DNSMapping {
    [[NSUserDefaults standardUserDefaults] setValue:@(DNSMapping) forKey:kSSCommonLogicSettingUseDNSMappingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicSettingDiscoverURLKey = @"SSCommonLogicSettingDiscoverURLKey";
NSString * const SSCommonLogicSettingDiscoverRefreshKey = @"SSCommonLogicSettingDiscoverRefreshKey";

@implementation SSCommonLogic (TipGesture)

// 5.4中 控制显示 详情页右滑返回的 tip
+ (BOOL)showGestureTip {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingTipGestureShowKey]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingTipGestureShowKey] boolValue];
    }
    // 默认关
    return NO;
}

+ (void)setShowGestureTip:(BOOL)showGestureTip {
    [[NSUserDefaults standardUserDefaults] setValue:@(showGestureTip) forKey:SSCommonLogicSettingTipGestureShowKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (TTLiveChatTipView)

//直播室提示关注
+ (BOOL)showLiveChatTipViewForliveId:(NSString *)liveId
{
    NSString *key = [NSString stringWithFormat:@"%@-%@",SSCommonLogicSettingChatTipViewShowKey,liveId];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:key]) {
        return [[userDefaults objectForKey:key] boolValue];
    }
    // 默认开
    return YES;
}

+ (void)setShowLiveChatTipView:(BOOL)show  liveId:(NSString *)liveId
{
    NSString *key = [NSString stringWithFormat:@"%@-%@",SSCommonLogicSettingChatTipViewShowKey,liveId];
    [[NSUserDefaults standardUserDefaults] setValue:@(show) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

//是否可以重复显示“总是查看大图”alert
NSString * const SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey = @"SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey";
@implementation SSCommonLogic (ShowAlwaysOriginImageAlertRepeatly)

+ (BOOL)enabledShowAlwaysOriginImageAlertRepeatly{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey] boolValue];
    }
    return YES;
}

+ (void)setEnabledShowAlwaysOriginImageAlertRepeatly:(BOOL)showAlwaysOriginImageAlertRepeatly{
    [[NSUserDefaults standardUserDefaults] setValue:@(showAlwaysOriginImageAlertRepeatly) forKey:SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (AccountABTest)

// 5.4中 控制显示 是否启用新的绑定流程
+ (BOOL)accountABVersionEnabled {
    return YES; // PM说关闭，直接使用新的登录界面
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    if ([userDefaults objectForKey:SSCommonLogicSettingAccountABVersionEnabledKey]) {
    //        return [[userDefaults objectForKey:SSCommonLogicSettingAccountABVersionEnabledKey] boolValue];
    //    }
    //    // 默认关
    //    return NO;
}

+ (void)setAccountABVersionEnabled:(BOOL)accountABVersionEnabled {
    [[NSUserDefaults standardUserDefaults] setValue:@(accountABVersionEnabled) forKey:SSCommonLogicSettingAccountABVersionEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicSettingTopSearchBarTipForNormalKey = @"SSCommonLogicSettingTopSearchBarTipForNormalKey";

NSString * const SSCommonLogicSettingTopSearchBarTipForVideoKey = @"SSCommonLogicSettingTopSearchBarTipForVideoKey";

NSString * const SSCommonLogicSettingTopSearchResultSourceKey = @"SSCommonLogicSettingTopSearchResultSourceKey";

NSString * const SSCommonLogicSettingSearchInDetailNavBarKey = @"SSCommonLogicSettingSearchInDetailNavBarKey";

NSString * const SSCommonLogicSettingWebViewQueryStringEnableKey = @"SSCommonLogicSettingWebViewQueryStringEnableKey";

NSString * const SSCommonLogicSettingWebViewQueryStringListKey = @"SSCommonLogicSettingWebViewQueryStringListKey";

NSString * const SSCommonLogicSettingSearchInitialPageWap = @"SSCommonLogicSettingSearchInitialPageWap";

NSString * const SSCommonLogicSettingSearchTransitionEnabel = @"SSCommonLogicSettingSearchTransitionEnabel";

@implementation SSCommonLogic (searchButton)

+ (void)setSearchTransitionEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicSettingSearchTransitionEnabel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSearchTransitionEnabled {
    BOOL isSearchTransitionEnabled = YES;
    NSNumber * enable = [[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicSettingSearchTransitionEnabel];
    if (nil != enable && [enable isKindOfClass:[NSNumber class]]) {
        isSearchTransitionEnabled = [enable boolValue];
    }
    return isSearchTransitionEnabled;
}

// 搜索框文案可控
+ (NSString *)searchBarTipForNormal {
    if ([SSCommonLogic searchInitialPageWapEnabled] || ![TTArticleSearchManager recommendHiddenIndeed]) {
        NSString *placeholder = [[NSUserDefaults standardUserDefaults] valueForKey:@"kHomepageSearchSuggestnormal"];
        if (!isEmptyString(placeholder)) {
            return placeholder;
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingTopSearchBarTipForNormalKey]) {
        return [userDefaults objectForKey:SSCommonLogicSettingTopSearchBarTipForNormalKey];
    }
    return @"搜索";
}

+ (void)setSearchBarTipForNormal:(NSString *)tip {
    [[NSUserDefaults standardUserDefaults] setValue:tip forKey:SSCommonLogicSettingTopSearchBarTipForNormalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)searchBarTipForVideo {
    if ([SSCommonLogic searchInitialPageWapEnabled] || ![TTArticleSearchManager recommendHiddenIndeed]) {
        NSString *placeholder = [[NSUserDefaults standardUserDefaults] valueForKey:@"kHomepageSearchSuggestvideo"];
        if (!isEmptyString(placeholder)) {
            return placeholder;
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingTopSearchBarTipForNormalKey]) {
        return [userDefaults objectForKey:SSCommonLogicSettingTopSearchBarTipForNormalKey];
    }
    return @"搜索";
}

+ (void)setSearchBarTipForVideo:(NSString *)tip{
    [[NSUserDefaults standardUserDefaults] setValue:tip forKey:SSCommonLogicSettingTopSearchBarTipForVideoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 详情页导航栏上显示搜索条
+ (BOOL)searchInDetailNavBarEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingSearchInDetailNavBarKey]) {
        return [userDefaults integerForKey:SSCommonLogicSettingSearchInDetailNavBarKey] > 0;
    }
    return NO;
}

+ (void)enableSearchInDetailNavBar:(NSInteger)enable {
    [[NSUserDefaults standardUserDefaults] setInteger:enable forKey:SSCommonLogicSettingSearchInDetailNavBarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)enableWebViewQueryString:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:SSCommonLogicSettingWebViewQueryStringEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setWebViewQueryEnableHostList:(NSArray<NSString *> *)hostList
{
    [[NSUserDefaults standardUserDefaults] setObject:hostList forKey:SSCommonLogicSettingWebViewQueryStringListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldAppendQueryStirngWithUrl:(NSURL *)url
{
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicSettingWebViewQueryStringEnableKey];
    if (enable) {
        NSArray *hostList = [[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicSettingWebViewQueryStringListKey];
        for (NSString *host in hostList) {
            if ([url.host rangeOfString:host].length > 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)searchInitialPageWapEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicSettingSearchInitialPageWap];
}

+ (void)enableSearchInitialPageWap:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:SSCommonLogicSettingSearchInitialPageWap];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (MineTabSearch)

NSString * const SSCommonLogicMineTabSearchKey = @"SSCommonLogicMineTabSearchKey";
+ (BOOL)mineTabSearchEnabled {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicMineTabSearchKey];
    return enabled;
}

+ (void)setMineTabSearchEnabled:(BOOL)mineTabSearchEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:mineTabSearchEnabled forKey:SSCommonLogicMineTabSearchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation SSCommonLogic (WKWebViewSwitch)

// 5.4中 控制是否使用WKWebview
+ (BOOL)WKWebViewEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingWKWebViewSettingSwitchKey]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingWKWebViewSettingSwitchKey] boolValue];
    }
    // 默认关
    return NO;
}

+ (void)setWKWebViewEnabledEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setValue:@(enabled) forKey:SSCommonLogicSettingWKWebViewSettingSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicSettingIarKey = @"SSCommonLogicSettingIarKey";

@implementation SSCommonLogic (Iar)

+ (BOOL)iar
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingIarKey]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingIarKey] boolValue];
    }
    return NO;
}

+ (void)setIar:(BOOL)iar
{
    [[NSUserDefaults standardUserDefaults] setValue:@(iar) forKey:SSCommonLogicSettingIarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIarNotification object:nil];
}

@end


NSString * const SSCommonLogicSettingForumListRefreshKey = @"SSCommonLogicSettingForumListRefreshKey";

//增加 话题列表刷新时间 的配置项
@implementation SSCommonLogic (Forum)

+ (NSTimeInterval)forumListRefreshTimeInterval {
    id timeValue = [[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicSettingForumListRefreshKey];
    if (timeValue) {
        return [timeValue doubleValue];
    }
    // 默认3分钟
    return 60*3;
}

+ (void)setForumRefreshTimeInterval:(NSTimeInterval)timeInterval {
    [[NSUserDefaults standardUserDefaults] setValue:@(timeInterval) forKey:SSCommonLogicSettingForumListRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end

NSString * const SSCommonLogicSettingShouldFilterContact = @"SSCommonLogicSettingShouldFilterContact";
@implementation SSCommonLogic (Contact)

+ (BOOL)shouldFilterContact {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingShouldFilterContact]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingShouldFilterContact] boolValue];
    }
    // 默认过滤通讯录中不存在的好友
    return YES;
}

+ (void)setShouldFilterContact:(BOOL)filterContact {
    [[NSUserDefaults standardUserDefaults] setValue:@(filterContact) forKey:SSCommonLogicSettingShouldFilterContact];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end


NSString * const SSCommonLogicSettingNeedCleanCoreDataKey = @"SSCommonLogicSettingNeedCleanCoreDataKey";
@implementation SSCommonLogic (CleanCoreData)

+ (BOOL)needCleanCoreData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicSettingNeedCleanCoreDataKey]) {
        return [[userDefaults objectForKey:SSCommonLogicSettingNeedCleanCoreDataKey] boolValue];
    }
    // 默认启动不清空数据库
    return NO;
}

+ (void)setNeedCleanCoreData:(BOOL)needCleanCoreData {
    [[NSUserDefaults standardUserDefaults] setValue:@(needCleanCoreData) forKey:SSCommonLogicSettingNeedCleanCoreDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

NSString * const SSCommonLogicWeixinSharedExtendedObjectEnabledKey = @"SSCommonLogicWeixinSharedExtendedObjectEnabledKey";
@implementation SSCommonLogic (WeixinShareStyle)

+ (BOOL)weixinSharedExtendedObjectEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicWeixinSharedExtendedObjectEnabledKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicWeixinSharedExtendedObjectEnabledKey];
    }
    else {
        //默认否
        return NO;
    }
}

+ (void)setWeixinSharedExtendedObjectEnabled:(BOOL)sharedExtendedObjectEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:sharedExtendedObjectEnabled forKey:SSCommonLogicWeixinSharedExtendedObjectEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicTTAlertControllerEnabledKey = @"SSCommonLogicTTAlertControllerEnabledKey";
@implementation SSCommonLogic (TTAlertControllerEnabled)

+ (BOOL)ttAlertControllerEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicTTAlertControllerEnabledKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicTTAlertControllerEnabledKey];
    }
    else {
        //默认否
        return NO;
    }
}

+ (void)setTTAlertControllerEnabled:(BOOL)ttAlertControllerEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:ttAlertControllerEnabled forKey:SSCommonLogicTTAlertControllerEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicWebContentArticleTimeoutDisableKey = @"SSCommonLogicWebContentArticleTimeoutDisableKey";
NSString * const SSCommonLogicWebContentArticleTimeoutIntervalKey = @"SSCommonLogicWebContentArticleTimeoutIntervalKey";
@implementation SSCommonLogic (WebContentArticleProtectionTimeout)

+ (BOOL)webContentArticleProtectionTimeoutDisabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicWebContentArticleTimeoutDisableKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicWebContentArticleTimeoutDisableKey];
    }
    else {
        return NO;
    }
}

+ (void)setWebContentArticleProtectionTimeoutDisabled:(BOOL)disabled
{
    [[NSUserDefaults standardUserDefaults] setBool:disabled forKey:SSCommonLogicWebContentArticleTimeoutDisableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)webContentArticleProtectionTimeoutInterval
{
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:SSCommonLogicWebContentArticleTimeoutIntervalKey]) {
        return [[NSUserDefaults standardUserDefaults] doubleForKey:SSCommonLogicWebContentArticleTimeoutIntervalKey];
    }
    else {
        return kWebContentProtectDefaultInterval;
    }
}

+ (void)setWebContentArticleProtectionTimeoutInterval:(NSTimeInterval)timeoutValue
{
    [[NSUserDefaults standardUserDefaults] setDouble:timeoutValue forKey:SSCommonLogicWebContentArticleTimeoutIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicExploreDetailToolBarWriteCommentPlaceholderTextKey = @"SSCommonLogicExploreDetailToolBarWriteCommentPlaceholderTextKey";
@implementation SSCommonLogic (ExploreDetailToolBarWriteCommentPlaceholderText)

+ (NSString *)exploreDetailToolBarWriteCommentPlaceholderText
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:SSCommonLogicExploreDetailToolBarWriteCommentPlaceholderTextKey]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:SSCommonLogicExploreDetailToolBarWriteCommentPlaceholderTextKey];
    }
    else {
        return NSLocalizedString(@"写评论...", nil);
    }
}

+ (void)setExploreDetailToolBarWriteCommentPlaceholderText:(NSString *)placeHolderText
{
    [[NSUserDefaults standardUserDefaults] setObject:placeHolderText forKey:SSCommonLogicExploreDetailToolBarWriteCommentPlaceholderTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicJsActLogURLStringKey = @"SSCommonLogicJsActLogURLStringKey";
@implementation SSCommonLogic (TTJsActLogURLString)

+ (NSString *)jsActLogURLString
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:SSCommonLogicJsActLogURLStringKey]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:SSCommonLogicJsActLogURLStringKey];
    }
    else {
        return nil;
    }
}

+ (NSString *)shouldEvaluateActLogJsStringForAdID:(NSString *)adID
{
    //actLogURL format: http://xyxyxy.com/xx/yy/?ad_id={{ad_id}}
    NSString *jsActLogURL = [self jsActLogURLString];
    NSString *placeholder = @"{{ad_id}}";
    NSString *actLogID = @"custom_act_log";
    if (!isEmptyString(jsActLogURL) && [jsActLogURL rangeOfString:placeholder].location != NSNotFound) {
        NSString *actUrl = [jsActLogURL stringByReplacingOccurrencesOfString:placeholder withString:adID];
        NSString *jsString = [NSString stringWithFormat:@"(function () {    \
                              var customScript = document.getElementById('%@'); \
                              if (!customScript) { \
                              var JS_ACTLOG_URL = '%@';   \
                              var head = document.getElementsByTagName('head')[0];  \
                              var script = document.createElement('script');    \
                              script.type = 'text/javascript';  \
                              script.src = JS_ACTLOG_URL;   \
                              script.id = '%@'; \
                              head.appendChild(script); \
                              }})();", actLogID, actUrl, actLogID];
        return jsString;
    }
    return nil;
}

+ (void)setJsActLogURLString:(NSString *)actLogURLString
{
    [[NSUserDefaults standardUserDefaults] setObject:actLogURLString forKey:SSCommonLogicJsActLogURLStringKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicJsSafeDomainListKey = @"SSCommonLogicJsSafeDomainListKey";
@implementation SSCommonLogic (TTJsSafeDomainList)

+ (void)setJsSafeDomainList:(NSArray *)safeDomainList
{
    [[TTJSBAuthManager sharedManager] updateInnerDomainsFromRemote:safeDomainList];
}

@end

NSString * const SSCommonLogicTaobaoSlotKey = @"SSCommonLogicTaobaoSlotKey";
@implementation SSCommonLogic (TTUMUFPSlotIDs)

+ (NSArray *)taobaoSlotIDs
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:SSCommonLogicTaobaoSlotKey]) {
        return [[NSUserDefaults standardUserDefaults] arrayForKey:SSCommonLogicTaobaoSlotKey];
    }
    else {
        return nil;
    }
}

+ (void)setTaobaoSlotIDs:(NSArray *)slotIDs
{
    [[NSUserDefaults standardUserDefaults] setObject:slotIDs forKey:SSCommonLogicTaobaoSlotKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //setting更新slotID后立即去拉取一次所有feed淘宝广告
}

@end

NSString * const SSCommonLogicLastReadRefreshEnableKey = @"SSCommonLogicLastReadRefreshEnableKey";
NSString * const SSCommonLogicLastReadCellViewStyleKey = @"SSCommonLogicLastReadCellViewStyleKey";
NSString * const SSCommonLogicLastReadRefreshViewShowEnableKey = @"SSCommonLogicLastReadRefreshViewShowEnableKey";
NSString * const SSCommonLogicLastReadRefreshViewShowIntervalKey = @"SSCommonLogicLastReadRefreshViewShowIntervalKey";

@implementation SSCommonLogic (LastReadRefresh)

+ (BOOL)LastReadRefreshEnabled
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicLastReadRefreshEnableKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicLastReadRefreshEnableKey];
    }
    else {
        return YES;
    }
}

+ (void)setLastReadRefreshEnabled:(BOOL)lastReadRefreshEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:lastReadRefreshEnabled forKey:SSCommonLogicLastReadRefreshEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLastReadStyle:(NSInteger)style
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicLastReadCellViewStyleKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSCommonLogicLastReadCellViewStyleKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)setShowFloatingRefreshBtn:(BOOL)show
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicLastReadRefreshViewShowEnableKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSCommonLogicLastReadRefreshViewShowEnableKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)setAutoFloatingRefreshBtnInterval:(NSInteger)interval
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicLastReadRefreshViewShowIntervalKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSCommonLogicLastReadRefreshViewShowIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

NSString * const SSCommonLogicFeedShowWithScenesEnabledKey = @"SSCommonLogicFeedShowWithScenesEnabledKey";
@implementation SSCommonLogic (ShowWithScenes)

+ (BOOL)showWithScensEnabled
{
    //  settings没有下发默认为yes
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicFeedShowWithScenesEnabledKey]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicFeedShowWithScenesEnabledKey];
}

+ (void)setShowWithScensEnabled:(BOOL)showWithScensEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:showWithScensEnabled forKey:SSCommonLogicFeedShowWithScenesEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicFeedNewPlayerEnabledKey = @"SSCommonLogicFeedNewPlayerEnabledKey";
@implementation SSCommonLogic (FeedNewPlayer)

+ (BOOL)feedNewPlayerEnabled
{
    //  settings没有下发默认为yes
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicFeedNewPlayerEnabledKey]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicFeedNewPlayerEnabledKey];
}

+ (void)setFeedNewPlayerEnabled:(BOOL)feedNewPlayerEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:feedNewPlayerEnabled forKey:SSCommonLogicFeedNewPlayerEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


NSString * const SSCommonLogicVideoVisibleEnabledKey = @"SSCommonLogicVideoVisibleEnabledKey";
@implementation SSCommonLogic (VideoVisible)

+ (BOOL)videoVisibleEnabled
{
    //  settings没有下发默认为yes
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicVideoVisibleEnabledKey]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicVideoVisibleEnabledKey];
}

+ (void)setVideoVisibleEnabled:(BOOL)videoVisibleEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:videoVisibleEnabled forKey:SSCommonLogicVideoVisibleEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicFeedVideoEnterBackEnabledKey = @"SSCommonLogicFeedVideoEnterBackEnabledKey";
@implementation SSCommonLogic (FeedVideoEnterBack)

+ (BOOL)feedVideoEnterBackEnabled
{
    //  settings没有下发默认为yes
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicFeedVideoEnterBackEnabledKey]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicFeedVideoEnterBackEnabledKey];
}

+ (void)setFeedVideoEnterBackEnabled:(BOOL)enterBackEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enterBackEnabled forKey:SSCommonLogicFeedVideoEnterBackEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicArticleFLAnimatedImageViewEnabledKey = @"SSCommonLogicArticleFLAnimatedImageViewEnabledKey";
@implementation SSCommonLogic (ArticleFLAnimatedImageView)

+ (BOOL)articleFLAnimatedImageViewEnabled
{
    //  settings没有下发默认为yes
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicArticleFLAnimatedImageViewEnabledKey]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicArticleFLAnimatedImageViewEnabledKey];
}

+ (void)setArticleFLAnimatedImageViewEnabled:(BOOL)articleFLAnimatedImageViewEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:articleFLAnimatedImageViewEnabled forKey:SSCommonLogicArticleFLAnimatedImageViewEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicReportInWapPageEnabledKey = @"SSCommonLogicReportInWapPageEnabledKey";
@implementation SSCommonLogic (ReportInWapPage)

+ (BOOL)reportInWapPageEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicReportInWapPageEnabledKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicReportInWapPageEnabledKey];
    }
    else {
        //默认否
        return NO;
    }
}

+ (void)setReportInWapPageEnabled:(BOOL)reportInWapPageEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:reportInWapPageEnabled forKey:SSCommonLogicReportInWapPageEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicEssayCommentDetailEnabledKey = @"SSCommonLogicEssayCommentDetailEnabledKey";
@implementation SSCommonLogic (EssayCommentDetail)

+ (BOOL)essayCommentDetailEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicEssayCommentDetailEnabledKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicEssayCommentDetailEnabledKey];
    }
    else {
        //默认否
        return NO;
    }
}

+ (void)setEssayCommentDetailEnabled:(BOOL)essayCommentDetailEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:essayCommentDetailEnabled forKey:SSCommonLogicEssayCommentDetailEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end



NSString * const SSCommonLogicRefreshButtonSettingEnabledKey = @"SSCommonLogicRefreshButtonSettingEnabledKey";
@implementation SSCommonLogic (RefreshButtonSettingEnabled)

+ (BOOL)refreshButtonSettingEnabled
{
    if ([TTDeviceHelper isPadDevice]) {
        return YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicRefreshButtonSettingEnabledKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicRefreshButtonSettingEnabledKey];
    }
    return NO; // 默认不显示
}

+ (void)setRefreshButtonSettingEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicRefreshButtonSettingEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


///...
NSString * const SSCommonLogicLaunchedTimes4ShowIntroductionViewKey = @"SSCommonLogicLaunchedTimes4ShowIntroductionViewKey";
@implementation SSCommonLogic (LaunchedTimes4ShowIntroductionView)

+ (NSInteger)launchedTimes4ShowIntroductionView
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicLaunchedTimes4ShowIntroductionViewKey]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicLaunchedTimes4ShowIntroductionViewKey];
    }
    return 2;
}

+ (void)setLaunchedTimes4ShowIntroductionView:(NSInteger)launchedTimes
{
    [[NSUserDefaults standardUserDefaults] setInteger:launchedTimes forKey:SSCommonLogicLaunchedTimes4ShowIntroductionViewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

///...
NSString * const SSCommonLogicFeedRefreshADDisableKey = @"SSCommonLogicFeedRefreshADDisableKey";
@implementation SSCommonLogic (FeedRefreshADDisable)
+ (BOOL)feedRefreshADDisable
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicFeedRefreshADDisableKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicFeedRefreshADDisableKey];
    }
    return NO;
}

+ (void)setFeedRefreshADDisable:(BOOL)disabled
{
    [[NSUserDefaults standardUserDefaults] setBool:disabled forKey:SSCommonLogicFeedRefreshADDisableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

NSString * const SSCommonLogicRefreshADDisableKey = @"SSCommonLogicRefreshADDisableKey";
@implementation SSCommonLogic (RefreshAdControl)

//下拉刷新网络请求时间间隔
+ (NSTimeInterval)refreshDefaultAdFetchInterval{
    
    return 20;
}

//下拉刷新开启关闭控制
+ (BOOL)RefreshADDisable{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicRefreshADDisableKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicRefreshADDisableKey];
    }
    return NO;
}

//下拉刷新开启关闭控制
+ (void)setRefreshADDisable:(BOOL)disabled{
    [[NSUserDefaults standardUserDefaults] setBool:disabled forKey:SSCommonLogicRefreshADDisableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//下拉刷新广告默认展示次数限制
+ (NSNumber *)refreshADDefaultShowLimit{
    
    return @(4);
}

@end

NSString * const SSCommonLogicFeedRefreshADExpireInterval = @"SSCommonLogicFeedRefreshADExpireInterval";
@implementation SSCommonLogic (FeedRefreshADExpireInterval)
+ (NSTimeInterval)feedRefreshADExpireInterval
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicFeedRefreshADExpireInterval]) {
        return [[NSUserDefaults standardUserDefaults] doubleForKey:SSCommonLogicFeedRefreshADExpireInterval];
    }
    return 60*60*12;
}

+ (void)setFeedRefreshADExpireInterval:(NSTimeInterval)expireInterval
{
    [[NSUserDefaults standardUserDefaults] setDouble:expireInterval
                                              forKey:SSCommonLogicFeedRefreshADExpireInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end


NSString * const SSCommonLogicRefactorPhotoAlbumControlKey = @"SSCommonLogicRefactorPhotoAlbumControlKey";

@implementation SSCommonLogic (RefactorPhotoAlbumControl)

+(void)setRefacorPhotoAlbumControlAble:(BOOL)abled{
    
    [[NSUserDefaults standardUserDefaults] setBool:abled forKey:SSCommonLogicRefactorPhotoAlbumControlKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(BOOL)refectorPhotoAlbumControlEnable{
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicRefactorPhotoAlbumControlKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicRefactorPhotoAlbumControlKey];
    }
    return YES;
}

@end

NSString * const SSCommonLogicShowRefreshButtonKey = @"SSCommonLogicShowRefreshButtonKey";
@implementation SSCommonLogic (ShowRefreshButton)

+ (BOOL)showRefreshButton
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicShowRefreshButtonKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicShowRefreshButtonKey];
    }
    return YES; // 默认显示
}

+ (void)setShowRefreshButton:(BOOL)show
{
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:SSCommonLogicShowRefreshButtonKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


NSString * const SSCommonLogicVideoTipServerSettingKey = @"SSCommonLogicVideoTipServerSettingKey";
NSString * const SSCommonLogicVideoTipServerIntervalKey = @"SSCommonLogicVideoTipServerIntervalKey";

@implementation SSCommonLogic (VideoTip)

+ (BOOL)videoTipServerSettingEnabled
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicVideoTipServerSettingKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicVideoTipServerSettingKey];
    }
    return YES;
}

+ (void)setVideoTipServerEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicVideoTipServerSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)videoTipServerInterval
{
    NSTimeInterval day = 60 * 60 * 24;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicVideoTipServerIntervalKey]) {
        return day * [[NSUserDefaults standardUserDefaults] doubleForKey:SSCommonLogicVideoTipServerIntervalKey];
    }
    return day * 7; // default a week
}

+ (void)setVideoTipServerInterval:(NSTimeInterval)interval
{
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:SSCommonLogicVideoTipServerIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const SSCommonLogicDetailQuickExitServerSettingKey = @"SSCommonLogicDetailQuickExitServerSettingKey";
NSString * const SSCommonLogicNewCommentStyleServerSettingKey = @"SSCommonLogicNewCommentStyleServerSettingKey";
NSString * const SSCommonLogicNewNatantStyleServerSettingKey = @"SSCommonLogicNewNatantStyleServerSettingKey";
NSString * const SSCommonLogicDetailWKEnableServerSettingKey = @"SSCommonLogicDetailWKEnableServerSettingKey";
NSString * const SSCommonLogicNewNatantStyleADServerSettingKey = @"SSCommonLogicNewNatantStyleADServerSettingKey";
NSString * const SSCommonLogicNewCommentImpServerSettingKey = @"SSCommonLogicNewCommentImpServerSettingKey";
NSString * const SSCommonLogicDetailSharedWebViewSettingKey = @"SSCommonLogicDetailSharedWebViewSettingKey";
@implementation SSCommonLogic (Detail)

+ (BOOL)detailQuickExitEnabled {
    return NO;
    //    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicDetailQuickExitServerSettingKey];
}

+ (void)setDetailQuickExitEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicDetailQuickExitServerSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)newNatantStyleEnabled {
    //settings没有下发 默认为YES
    if (![[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicNewNatantStyleServerSettingKey]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicNewNatantStyleServerSettingKey];
}

+ (void)setNewNatantStyleEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicNewNatantStyleServerSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)newNatantStyleInADEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicNewNatantStyleADServerSettingKey];
}

+ (void)setNewNatantStyleInADEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicNewNatantStyleADServerSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setDetailWKEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicDetailWKEnableServerSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)detailWKEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicDetailWKEnableServerSettingKey];
}

+ (void)setDetailSharedWebViewEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicDetailSharedWebViewSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)detailSharedWebViewEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicDetailSharedWebViewSettingKey];
}

+ (void)setDetailNewLayoutEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_detail_layout_optimize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)detailNewLayoutEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_detail_layout_optimize"];
}

+ (void)setCDNBlockEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_cdn_block_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)CDNBlockEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_cdn_block_enable"];
}

+ (void)setToolbarLabelEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_user_interactive_action_guide_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)toolbarLabelEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_user_interactive_action_guide_enable"];
}

+ (void)setShareIconStyle:(NSInteger)style {
    [[NSUserDefaults standardUserDefaults] setInteger:style forKey:@"tt_share_icon_type"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)shareIconStye {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"tt_share_icon_type"];
}
@end

NSString * const SSCommonLogicVideoTabSpotServerSettingKey = @"SSCommonLogicVideoTabSpotServerSettingKey";
NSString * const SSCommonLogicVideoTabSpotServerVersionKey = @"SSCommonLogicVideoTabSpotServerVersionKey";
NSString * const SSCommonLogicVideoTabSpotLocalVersionKey = @"SSCommonLogicVideoTabSpotLocalVersionKey";

@implementation SSCommonLogic (VideoTabBadge)

+ (BOOL)shouldShowVideoTabSpotForVersion:(NSInteger)version
{
    [self saveServerVideoTabSpotVersion:version];
    if (![self shouldShowVideoTabSpotServerEnabled]) {
        return NO;
    }
    if ([self serverVideoTabSpotVersion] > [self localVideoTabSpotVersion]) {
        return YES;
    }
    return NO;
}

+ (BOOL)shouldShowVideoTabSpotServerEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicVideoTabSpotServerSettingKey];
}

+ (void)setVideoTabSpotServerEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicVideoTabSpotServerSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)showedVideoTabSpot
{
    if (![self shouldShowVideoTabSpotForVersion:[self serverVideoTabSpotVersion]]) {
        return;
    }
    [self saveLocalVideoTabSpotVersion:[self serverVideoTabSpotVersion]];
}

+ (void)saveServerVideoTabSpotVersion:(NSInteger)version
{
    if (version > [self serverVideoTabSpotVersion]) {
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:SSCommonLogicVideoTabSpotServerVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)saveLocalVideoTabSpotVersion:(NSInteger)version
{
    if (version > [self localVideoTabSpotVersion]) {
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:SSCommonLogicVideoTabSpotLocalVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSInteger)localVideoTabSpotVersion
{
    if ([self hasLocalVideoSpotVersion]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicVideoTabSpotLocalVersionKey];
    }
    return -1;
}

+ (NSInteger)serverVideoTabSpotVersion
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicVideoTabSpotServerVersionKey];
}

+ (BOOL)hasLocalVideoSpotVersion
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicVideoTabSpotLocalVersionKey] != nil;
}

@end

NSString * const SSCommonLogicCommentDraftCacheKey = @"SSCommonLogicCommentDraftCacheKey";
NSString * const SSCommonLogicSaveForwordStatusCacheKey = @"SSCommonLogicSaveForwordStatusCacheKey";

@implementation SSCommonLogic (CommentDraft)

+ (void)setDraft:(NSDictionary *)draft forType:(SSCommentType)type {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSObject *cachedValue = [userDefaults valueForKey:SSCommonLogicCommentDraftCacheKey];
    NSMutableDictionary *drafts = nil;
    if ([cachedValue isKindOfClass:[NSDictionary class]]) {
        drafts = [cachedValue mutableCopy];
    } else {
        drafts = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    NSString *key = [NSString stringWithFormat:@"%ld", (long)type];
    [drafts setValue:draft forKey:key];
    [userDefaults setValue:drafts forKey:SSCommonLogicCommentDraftCacheKey];
    [userDefaults synchronize];
}

+ (NSDictionary *)draftForType:(SSCommentType)type {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)type];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *cachedValue = [userDefaults valueForKey:SSCommonLogicCommentDraftCacheKey];
    if ([cachedValue isKindOfClass:[NSDictionary class]]) {
        return [cachedValue valueForKey:key];
    }
    return nil;
}

+ (void)cleanDrafts {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nil forKey:SSCommonLogicCommentDraftCacheKey];
    [userDefaults synchronize];
}

+ (void)setSaveForwordStatusEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:SSCommonLogicSaveForwordStatusCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)saveForwordStatusEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicSaveForwordStatusCacheKey];
}

@end


#define SSCrashReporterUserDefaultKey @"SSCrashReporterUserDefaultKey"

typedef NS_ENUM(NSUInteger, SSCrashReportSettingType)
{
    SSCrashReportSettingTypeNone = -1,
    SSCrashReportSettingTypeCrashlytics = 0,
    SSCrashReportSettingTypeTouTiao = 1,
    SSCrashReportSettingTypeUmeng = 2,
};

@implementation SSCommonLogic(SSCrashReportSetting)

+ (BOOL)umengCrashReportEnable
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SSCrashReporterUserDefaultKey] intValue] == SSCrashReportSettingTypeUmeng;
}

+ (BOOL)toutiaoCrashReportEnable
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SSCrashReporterUserDefaultKey] intValue] == SSCrashReportSettingTypeTouTiao;
}

+ (BOOL)crashlyticsCrashReportEnable
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:SSCrashReporterUserDefaultKey] intValue] == SSCrashReportSettingTypeCrashlytics;
}

+ (void)setCrashReporter:(NSString *)reporter
{
    if (!isEmptyString(reporter)) {
        SSCrashReportSettingType type = SSCrashReportSettingTypeCrashlytics;
        if ([reporter isEqualToString:@"umeng"]) {
            type = SSCrashReportSettingTypeUmeng;
        }
        else if ([reporter isEqualToString:@"toutiao"]) {
            type = SSCrashReportSettingTypeTouTiao;
        }
        else if ([reporter isEqualToString:@"no_reporter"]) {
            type = SSCrashReportSettingTypeNone;
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:@(type) forKey:SSCrashReporterUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

NSString * const TTUgcCellSingleImage = @"TTUgcCellSingleImage";
NSString * const TTUgcCellNormal = @"TTUgcCellNormal";
NSString * const TTUgcCellArticleAbstract = @"TTUgcCellArticleAbstract";
NSString * const TTUgcCellArticlePostContent = @"TTUgcCellArticlePostContent";
NSString * const TTUgcCellArticleComment = @"TTUgcCellArticleComment";
NSString * const TTUgcCellTopicComment = @"TTUgcCellTopicComment";
NSString * const TTUgcCellTopicTitle = @"TTUgcCellTopicTitle";
NSString * const TTUgcCellTopicContent = @"TTUgcCellTopicContent";

@implementation SSCommonLogic (UGCCellLineNumber)
typedef NS_ENUM(NSUInteger, TTUgcCellLineNumber) {
    TTUgcCellLineNumberSingleImage = 0,
    TTUgcCellLineNumberNormal,
    TTUgcCellLineNumberArticleAbstract,
    TTUgcCellLineNumberArticlePostContent,
    TTUgcCellLineNumberArticleComment,
    TTUgcCellLineNumberTopicComment,
    TTUgcCellLineNumberTopicTitle,
    TTUgcCellLineNumberTopicContent,
};

+ (NSInteger)getUgcCellLineNumber:(NSUInteger)type {
    switch ((TTUgcCellLineNumber)type) {
        case TTUgcCellLineNumberSingleImage:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellSingleImage]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellSingleImage];
            }
            return 3;
        case TTUgcCellLineNumberNormal:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellNormal]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellNormal];
            }
            return 2;
        case TTUgcCellLineNumberArticleAbstract:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellArticleAbstract]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellArticleAbstract];
            }
            return 4;
        case TTUgcCellLineNumberArticlePostContent:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellArticlePostContent]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellArticlePostContent];
            }
            return 3;
        case TTUgcCellLineNumberArticleComment:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellArticleComment]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellArticleComment];
            }
            return 2;
        case TTUgcCellLineNumberTopicComment:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellTopicComment]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellTopicComment];
            }
            return 5;
        case TTUgcCellLineNumberTopicTitle:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellTopicTitle]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellTopicTitle];
            }
            return 2;
        case TTUgcCellLineNumberTopicContent:
            if ([[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellTopicContent]) {
                return [[NSUserDefaults standardUserDefaults] integerForKey:TTUgcCellTopicContent];
            }
            return 10;
    }
}

+ (void)setUgcCellLineNumber:(NSDictionary *)dic {
    if (dic != nil) {
        if ([dic objectForKey:@"single_image"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"single_image"] forKey:TTUgcCellSingleImage];
        }
        if ([dic objectForKey:@"normal"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"normal"] forKey:TTUgcCellNormal];
        }
        if ([dic objectForKey:@"article_abstract"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"article_abstract"] forKey:TTUgcCellArticleAbstract];
        }
        if ([dic objectForKey:@"article_post_content"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"article_post_content"] forKey:TTUgcCellArticlePostContent];
        }
        if ([dic objectForKey:@"article_comment"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"article_comment"] forKey:TTUgcCellArticleComment];
        }
        if ([dic objectForKey:@"topic_comment"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"topic_comment"] forKey:TTUgcCellTopicComment];
        }
        if ([dic objectForKey:@"topic_title"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"topic_title"] forKey:TTUgcCellTopicTitle];
        }
        if ([dic objectForKey:@"topic_content"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"topic_content"] forKey:TTUgcCellTopicContent];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

static NSString * const kSScommonLogicFollowButtonColorDict = @"kSScommonLogicFollowButtonColorDict";

@implementation SSCommonLogic (FollowButtonColor)

+ (void)setFollowButtonColorTemplate:(NSDictionary *)dict {
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kSScommonLogicFollowButtonColorDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)followButtonDefaultColorDict {
    static NSDictionary *followButtonColorDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary * colorDict = [[NSUserDefaults standardUserDefaults] objectForKey:kSScommonLogicFollowButtonColorDict];
        if ([colorDict isKindOfClass:[NSDictionary class]]) {
            followButtonColorDict = colorDict;
        }
        if (followButtonColorDict.count == 0) {
            followButtonColorDict = @{@"color_style" : @"red"};
        }
    });
    return followButtonColorDict;
}

+ (NSString *)followButtonColorStringForWap {
    static NSString *jsonStr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([SSCommonLogic followButtonDefaultColorDict]) {
            NSDictionary *dictColor = [SSCommonLogic followButtonDefaultColorDict];
            NSError *jsonError;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dictColor options:0 error:&jsonError];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!jsonError) {
                jsonStr = str;
            }
        }
    });
    return jsonStr;
}

+ (NSString *)followButtonDefaultColorStyle {
    return [[SSCommonLogic followButtonDefaultColorDict] objectForKey:@"color_style"];
}

+ (NSString *)followSelectedImageName {
    return [SSCommonLogic followButtonDefaultColorStyleRed] ? @"follow_coldstart_select_red" : @"follow_coldstart_select";
}

+ (NSString *)followUnSelectedImageName {
    return [SSCommonLogic followButtonDefaultColorStyleRed] ? @"follow_coldstart_unselect_red" : @"follow_coldstart_unselect";
}

+ (BOOL)followButtonDefaultColorStyleRed {
    return [[SSCommonLogic followButtonDefaultColorStyle] isEqualToString:@"red"];
}

//二期会下发，一期使用UI提供的色值
+ (NSString *)followButtonDefaultColor {
    return @"#EF514A";
}

@end

NSString *const kTTAppseeEnableKey = @"appsee_enable";

@implementation SSCommonLogic (TTAppseeSample)

+ (NSNumber *)appseeSampleSetting
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTTAppseeEnableKey];
}

+ (void)setAppseeSampleSetting:(NSNumber *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kTTAppseeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString *const kTTGallerySlideDownOutTipKey =  @"gallerySlideDownOut";

@implementation SSCommonLogic (TTGallerySlideDownOutTip)

//下滑退出只显示一次
+ (BOOL)needToShowSlideDownOutTip
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTGallerySlideDownOutTipKey]) {
        NSNumber *slideDown =  [[NSUserDefaults standardUserDefaults] objectForKey:kTTGallerySlideDownOutTipKey];
        if (slideDown.integerValue == 1) {
            return NO;
        }
        return YES;
    }
    
    return YES;
}

+ (void)setGallerySlideDownOutTip:(NSNumber *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kTTGallerySlideDownOutTipKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString *const kTTGalleryTileSwitchKey =  @"galleryTileSwitch";

@implementation SSCommonLogic (TTGalleryTileSwitch)

+ (BOOL)appGalleryTileSwitchOn
{
    NSNumber *tileSwitch =  [[NSUserDefaults standardUserDefaults] objectForKey:kTTGalleryTileSwitchKey];
    if (tileSwitch.integerValue == 1) {
        return YES;
    }
    return NO;
}

+ (void)setGalleryTileSwitch:(NSNumber *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kTTGalleryTileSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString *const kTTGallerySlideOutSwitchKey =  @"gallerySlideOutSwitch";

@implementation SSCommonLogic (TTGallerySlideOutSwitch)

+ (BOOL)appGallerySlideOutSwitchOn
{
    NSNumber *tileSwitch =  [[NSUserDefaults standardUserDefaults] objectForKey:kTTGallerySlideOutSwitchKey];
    if (tileSwitch.integerValue == 1) {
        return YES;
    }
    return YES;
}

+ (void)setGallerySlideOutSwitch:(NSNumber *)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kTTGallerySlideOutSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const TTPGCAuthorSelfRecommendAllowedKey = @"TTPGCAuthorSelfRecommendAllowedKey";

@implementation SSCommonLogic (PGCAuthorRecommend)

+ (BOOL)isPGCAuthorSelfRecommendAllowed {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:TTPGCAuthorSelfRecommendAllowedKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:TTPGCAuthorSelfRecommendAllowedKey];
    }
    return NO;
}

+ (void)setPGCAuthorSelfRecommendAllowed:(BOOL)allowed {
    [[NSUserDefaults standardUserDefaults] setBool:allowed forKey:TTPGCAuthorSelfRecommendAllowedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const TTTaobaoSDKEnabbleKey = @"TTTaobaoSDKEnabbleKey";

@implementation SSCommonLogic (TAOBAOSDK)

+ (BOOL)newTaobaoSDkEnable{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:TTTaobaoSDKEnabbleKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:TTTaobaoSDKEnabbleKey];
    }
    return NO;
}

+ (void)setNewTaobaoSDkEnable:(BOOL)allowed{
    [[NSUserDefaults standardUserDefaults] setBool:allowed forKey:TTTaobaoSDKEnabbleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const TTTeMaiURLKey = @"TTTeMaiURLKey";

@implementation SSCommonLogic (TeMaiControls)

+ (BOOL)isTeMaiURL:(NSString*)url {
    
    for (NSString * temaiUrl in [self getTeMaiURLs]) {
        if ([url rangeOfString:temaiUrl].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)getTeMaiURLs
{
    NSArray * ary = [[NSUserDefaults standardUserDefaults] objectForKey:TTTeMaiURLKey];
    if (ary == nil) {
        ary = @[@"www.jinritemai.com",@"temai.snssdk.com",@"temai.toutiao.com"];
    }
    return ary;
}

+ (void)saveTeMaiURLs:(NSArray *)ary
{
    if ([ary count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TTTeMaiURLKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:ary forKey:TTTeMaiURLKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

NSString * const kTTTBSDKEnable = @"kTTTBSDKEnable";
NSString * const kTTKeplerEnable = @"kTTKeplerEnable";
@implementation SSCommonLogic (TBJDSDK)

+ (BOOL)isTBSDKEnable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTTBSDKEnable];
}

+ (BOOL)isKeplerEnable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTKeplerEnable];
}

+ (void)setTBSDKEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTTBSDKEnable];
}

+ (void)setKeplerEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTKeplerEnable];
}

@end

@implementation SSCommonLogic (CategoryGuide)

NSString * const SSCommonLogicCagetoryGuideCountKey = @"SSCommonLogicCagetoryGuideCountKey";
+ (NSInteger)cagetoryGuideCount {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicCagetoryGuideCountKey]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicCagetoryGuideCountKey];
    }
    return  0;
}
+ (void)setCagetoryGuideCount:(NSInteger)count {
    
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:SSCommonLogicCagetoryGuideCountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

// 针对强制or非强制登录弹窗
@implementation SSCommonLogic (LoginDialogStrategyDetail)
NSString * const SSCommonLogicLoginDialogStrategyDetail = @"SSCommonLogicLoginDialogStrategyDetail";
+ (NSInteger)detailActionType {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicLoginDialogStrategyDetail]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicLoginDialogStrategyDetail];
    }
    return 0;
}

+ (void)setDetailActionType:(NSInteger)type {
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:SSCommonLogicLoginDialogStrategyDetail];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (LoginDialogStrategyDetailActionTick)
NSString *const SSCommonLogicDialogStrategyDetailActionTick = @"SSCommonLogicDialogStrategyDetailActionTick";
+ (NSArray *)detailActionTick {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicDialogStrategyDetailActionTick]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicDialogStrategyDetailActionTick];
    }
    return @[@1,@3,@5,@7,@9,@50,@100];
}

+ (void)setDetailActionTick:(NSArray *)actionTick {
    if (actionTick) {
        [[NSUserDefaults standardUserDefaults] setObject:actionTick forKey:SSCommonLogicDialogStrategyDetailActionTick];
    } else {
        actionTick = @[@1,@3,@5,@7,@9,@50,@100];
        [[NSUserDefaults standardUserDefaults] setObject:actionTick forKey:SSCommonLogicDialogStrategyDetailActionTick];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (LoginDialogStrategyFavorDetail)
NSString *const SSCommonLogicDialogFavorDetailActionType = @"SSCommonLogicDialogFavorDetailActionType";
+ (NSInteger)favorDetailActionType {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicDialogFavorDetailActionType]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicDialogFavorDetailActionType];
    }
    return 0;
}

+ (void)setFavorDetailActionType:(NSInteger)type {
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:SSCommonLogicDialogFavorDetailActionType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (LoginDialogStrategyFavorDetailActionTick)
NSString *const SSCommonLogicDialogFavorDetailActionTick = @"SSCommonLogicDialogFavorDetailActionTick";
+ (NSArray *)favorDetailActionTick {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicDialogFavorDetailActionTick]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicDialogFavorDetailActionTick];
    }
    return @[];
}

+ (void)setFavorDetailActionTick:(NSArray *)actionTick {
    if (actionTick) {
        [[NSUserDefaults standardUserDefaults] setObject:actionTick forKey:SSCommonLogicDialogFavorDetailActionTick];
    } else {
        actionTick = @[];
        [[NSUserDefaults standardUserDefaults] setObject:actionTick forKey:SSCommonLogicDialogFavorDetailActionTick];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
    
@end


@implementation SSCommonLogic (SSCommonLogicDialogFavorDetailActionHasFavor)
NSString *const SSCommonLogicDialogFavorDetailActionHasFavor = @"SSCommonLogicDialogFavorDetailActionHasFavor";

+ (BOOL)needShowLoginTipsForFavor {
    static BOOL hasShowLoginTips;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hasShowLoginTips = [NSUserDefaults.standardUserDefaults boolForKey:SSCommonLogicDialogFavorDetailActionHasFavor];
    });
    if (hasShowLoginTips) {
        return NO;
    } else {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:SSCommonLogicDialogFavorDetailActionHasFavor];
        hasShowLoginTips = YES;
        return YES;
    }
}

@end

@implementation SSCommonLogic (LoginDialogStrategyFavorDetailDialogOrder)
NSString *const SSCommonLogicDialogFavorDetailDialogOrder = @"SSCommonLogicDialogFavorDetailDialogOrder";
+ (NSInteger)favorDetailDialogOrder {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicDialogFavorDetailDialogOrder]) {
        NSInteger ret = [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicDialogFavorDetailDialogOrder];
        if(ret == 0 || ret == 1){  //0：动作生效前；1：动作生效后
            return ret;
        }
    }
    return 0;
}

+ (void)setFavorDetailDialogOrder:(NSInteger)type {
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:SSCommonLogicDialogFavorDetailDialogOrder];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (UnForceLoginSubscribeCount)
NSString *const SSCommonLogicUnForceLoginSubscribeCount = @"SSCommonLogicUnForceLoginSubscribeCount";
+ (NSInteger)subscribeCount {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicUnForceLoginSubscribeCount]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicUnForceLoginSubscribeCount];
    }
    return 0;
}

+ (void)setSubscribeCount:(NSInteger)subscribeCount {
    [[NSUserDefaults standardUserDefaults] setInteger:subscribeCount forKey:SSCommonLogicUnForceLoginSubscribeCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end;

@implementation SSCommonLogic (UnForceLoginFavorCount)
NSString *const SSCommonLogicUnForceLoginFavorCount = @"SSCommonLogicUnForceLoginFavorCount";
+ (NSInteger)favorCount {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicUnForceLoginFavorCount]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicUnForceLoginFavorCount];
    }
    return 0;
}

+ (void)setFavorCount:(NSInteger)favorCount {
    [[NSUserDefaults standardUserDefaults] setInteger:favorCount forKey:SSCommonLogicUnForceLoginFavorCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end


NSString * const SSCommonLogicUseOptimizedLogKey = @"SSCommonLogicUseOptimizedLogKey";
@implementation SSCommonLogic (APPlog)

NSString * const SSCommonLogicSdWebMonitorKey = @"SSCommonLogicSdWebMonitorKey";
+ (void)setEnableSdWebImageMonitor:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:SSCommonLogicSdWebMonitorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableSdWebImageMonitor{
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicSdWebMonitorKey];
    return enabled;
}

NSString * const SSCommonLogicUseEncryptLogKey = @"SSCommonLogicUseEncryptLogKey";
+ (BOOL)useEncrypt{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicUseEncryptLogKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicUseEncryptLogKey];
    }
    return YES;
}

+ (void)setUseEncrypt:(BOOL)encrypted{
    [[NSUserDefaults standardUserDefaults] setBool:encrypted forKey:SSCommonLogicUseEncryptLogKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicMonitorLogKey = @"SSCommonLogicMonitorLogKey";
+ (BOOL)monitorLog{
    BOOL monitorLogEnabled = YES;//默认值写为YES
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicMonitorLogKey]) {
        monitorLogEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicMonitorLogKey];
    }
    BOOL result = monitorLogEnabled && (![TTSandBoxHelper isAppStoreChannel]);
    return result;
}

+ (void)setMonitorLog:(BOOL)shouldMonitor{
    [[NSUserDefaults standardUserDefaults] setBool:shouldMonitor forKey:SSCommonLogicMonitorLogKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicCheckLogKey = @"SSCommonLogicCheckLogKey";
+ (BOOL)checkLog{
    BOOL monitorLogEnabled = YES;//默认值写为YES
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicCheckLogKey]) {
        monitorLogEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicCheckLogKey];
    }
    return monitorLogEnabled;
}

+ (void)setCheckLog:(BOOL)shouldCheck{
    [[NSUserDefaults standardUserDefaults] setBool:shouldCheck forKey:SSCommonLogicCheckLogKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicCrasMonitorKey = @"SSCommonLogicCrasMonitorKey";

+ (BOOL)enableCrashMonitor{
#if INHOUSE
    return YES;
#else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicCrasMonitorKey]) {
        return [[userDefaults objectForKey:SSCommonLogicCrasMonitorKey] boolValue];
    }
    return NO;
#endif
}

+ (void)setEnableCrashMonitor:(BOOL)enableCrashMonitor{
    [[NSUserDefaults standardUserDefaults] setValue:@(enableCrashMonitor) forKey:SSCommonLogicCrasMonitorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicDebugRealMonitorKey = @"SSCommonLogicDebugRealMonitorKey";
+ (BOOL)enableDebugRealMonitor{
#if INHOUSE
    return YES;
#else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:SSCommonLogicDebugRealMonitorKey]) {
        return [[userDefaults objectForKey:SSCommonLogicDebugRealMonitorKey] boolValue];
    }
    return NO;
#endif
}

+ (void)setEnableDebugRealMonitor:(BOOL)enableDebuguReal{
    [[NSUserDefaults standardUserDefaults] setValue:@(enableDebuguReal) forKey:SSCommonLogicDebugRealMonitorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicJSONModelMonitorKey = @"SSCommonLogicJSONModelMonitorKey";
+ (BOOL)enableJSONModelMonitor {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicJSONModelMonitorKey];
#if DEBUG
    enabled = YES;
#endif
    return enabled;
}

+ (void)setEnableJSONModelMonitor:(BOOL)enableJSONModelMonitor {
    [[NSUserDefaults standardUserDefaults] setBool:enableJSONModelMonitor forKey:SSCommonLogicJSONModelMonitorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicCacheSizeReportKey = @"SSCommonLogicCacheSizeReport";
+ (BOOL)enableCacheSizeReport {
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicCacheSizeReportKey];
    return enabled;
}

+ (void)setEnableCacheSizeReport:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:SSCommonLogicCacheSizeReportKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (PreloadVideo)
static NSString *const kSSCommonLogicPreloadVideo = @"kSSCommonLogicPreloadVideo";
+ (void)setPreloadVideoEnable:(BOOL)preload
{
    [[NSUserDefaults standardUserDefaults] setBool:preload forKey:kSSCommonLogicPreloadVideo];
}

+ (BOOL)isPreloadVideoEnabled
{
#warning todo delete 自研播放器暂时不支持预先加载。
    return NO;
    BOOL isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicPreloadVideo];
#if DEBUG
    isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"__TTEnableVideoCacheDebug"];
#endif
    return isEnable;
}

static NSString *const kSSCommonLogicPreloadVideoDisableStreamKey = @"kSSCommonLogicPreloadVideoDisableStreamKey";
+ (void)setPreloadVideoDisableStream:(BOOL)useStream
{
    [[NSUserDefaults standardUserDefaults] setBool:useStream forKey:kSSCommonLogicPreloadVideoDisableStreamKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)isPreloadVideoUseStreamDisabled
{
    BOOL isDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicPreloadVideoDisableStreamKey];
    return isDisabled;
}
@end

@implementation SSCommonLogic (VideoFloating)
static NSString *const kSSCommonLogicVideoFloating = @"kSSCommonLogicVideoFloating";
+ (void)setVideoFloatingEnable:(NSNumber *)floating
{
    [[NSUserDefaults standardUserDefaults] setBool:[floating boolValue] forKey:kSSCommonLogicVideoFloating];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isVideoFloatingEnabled
{
    BOOL isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicVideoFloating];
    return isEnable;
}
@end



@implementation SSCommonLogic (FollowTabTips)
static NSString *const kSSCommonLogicFollowTabTipsEnalbe = @"kSSCommonLogicFollowTabTipsEnalbe";
static NSString *const kSSCommonLogicFollowTabTipsString = @"kSSCommonLogicFollowTabTipsString";
+ (void)setFollowTabTipsEnable:(BOOL)allowed
{
    [[NSUserDefaults standardUserDefaults] setBool:allowed forKey:kSSCommonLogicFollowTabTipsEnalbe];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFollowTabTipsEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicFollowTabTipsEnalbe];
}

+ (void)setFollowTabTipsString:(NSString *)string
{
    [[NSUserDefaults standardUserDefaults] setValue:string forKey:kSSCommonLogicFollowTabTipsString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)followTabTipsString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kSSCommonLogicFollowTabTipsString];
}
@end

@implementation SSCommonLogic (PreloadFollow)
static NSString *const kSSCommonLogicPreloadFollowEnable = @"kSSCommonLogicPreloadFollowEnable";
+ (void)setPreloadFollowEnable:(BOOL)allowed
{
    [[NSUserDefaults standardUserDefaults] setBool:allowed forKey:kSSCommonLogicPreloadFollowEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isPreloadFollowEnable
{
    BOOL isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicPreloadFollowEnable];
    return isEnable;
}
@end

@implementation SSCommonLogic (Article)
static NSString *const kSSCommonLogicArticeReadPositionEnable = @"kSSCommonLogicArticeReadPositionEnable";

+ (void)setArticleReadPositionEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicArticeReadPositionEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isEnableArticleReadPosition {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicArticeReadPositionEnable];
}
@end

@implementation SSCommonLogic (ChannelControl)
static NSString *const kSSCommonLogicChannelControlKey = @"kSSCommonLogicChannelControlKey";
+ (void)setChannelControlDict:(NSDictionary *)channelControlDict
{
    [[NSUserDefaults standardUserDefaults] setValue:channelControlDict forKey:kSSCommonLogicChannelControlKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (NSDictionary *)getChannelControlDict
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicChannelControlKey];;
}

+ (NSUInteger)getAutoRefreshIntervalForCategoryID:(NSString *)categoryID
{
    NSUInteger interval = 0;
    NSDictionary *channelControlDict = [self getChannelControlDict];
    if ([channelControlDict objectForKey:categoryID]) {
        NSDictionary *result = [channelControlDict tt_dictionaryValueForKey:categoryID];
        if ([result objectForKey:@"auto_refresh_interval"]) {
            interval = [result tt_longValueForKey:@"auto_refresh_interval"];
        }
    }
    return interval;
}

+ (BOOL)shouldShowLastReadForCategoryID:(NSString *)categoryID
{
    BOOL shouldShow = YES;
    NSDictionary *channelControlDict = [self getChannelControlDict];
    if ([channelControlDict objectForKey:categoryID]) {
        NSDictionary *result = [channelControlDict tt_dictionaryValueForKey:categoryID];
        if ([result objectForKey:@"show_last_read"]) {
            shouldShow = [result tt_boolValueForKey:@"show_last_read"];
        }
    }
    return shouldShow;
}
@end

@implementation SSCommonLogic (HomepageUIConfig)
static NSString *const kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey = @"kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey";
+ (BOOL)homepageUIConfigSimultaneouslyValid {
    BOOL enable = NO;//默认不同时生效
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey]) {
        enable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey];
    }
    return enable;
}

+ (void)setHomepageUIConfigSimultaneouslyValid:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeHomepageUIConfigSimultaneousKey {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSSCommonLogicHomepageUIConfigSimutaneousValidEnableKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

@implementation SSCommonLogic (AccurateTrack)

static NSString *const kSSCommonLogicAccurateTrackKey = @"kSSCommonLogicAccurateTrackKey";

+ (BOOL)hasUploadAccurateTrack {
    BOOL finished = NO;//默认没有上传
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicAccurateTrackKey]) {
        finished = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicAccurateTrackKey];
    }
    return finished;
}

+ (void)setUploadAccurateTrackFinished:(BOOL)finished {
    [[NSUserDefaults standardUserDefaults] setBool:finished forKey:kSSCommonLogicAccurateTrackKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (PosterAD)

static NSString *const kSSCommonLogicPosterADClickEnabledKey = @"kSSCommonLogicPosterADClickEnabledKey";
+ (void)setPosterADClickEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicPosterADClickEnabledKey];
}
+ (BOOL)isPosterADClickEnabled
{
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicPosterADClickEnabledKey];
    return isEnabled;
}

@end

@implementation SSCommonLogic (LoginEntryList)
static NSString *const kTTCommonLogicLoginEntryList = @"kTTCommonLogicLoginEntryList";
+ (void)setLoginEntryList:(NSArray *)loginEntries {
    if ([loginEntries count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:loginEntries forKey:kTTCommonLogicLoginEntryList];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTCommonLogicLoginEntryList];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)loginEntryList {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kTTCommonLogicLoginEntryList];
}
@end

@implementation SSCommonLogic (NaviRefactor)
static NSString *const kSSCommonLogicRefactorNaviEnable = @"kSSCommonLogicRefactorNaviEnable";
+ (void)setRefactorNaviEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicRefactorNaviEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (VideoOwnPlayer)
static NSString *const kSSCommonLogicVideoOwnPlayerEnabledKey = @"video_own_player";
+ (void)setVideoOwnPlayerEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicVideoOwnPlayerEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isVideoOwnPlayerEnabled {
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicVideoOwnPlayerEnabledKey];
    return isEnabled;
}

@end

NSString * const SSCommonLogicUseOptimizedAPPLaunchKey = @"SSCommonLogicUseOptimizedAPPLaunchKey";
@implementation SSCommonLogic (Optimise)

+ (BOOL)shouldUseOptimisedLaunch{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicUseOptimizedAPPLaunchKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicUseOptimizedAPPLaunchKey];
    }
    return  YES;
}

+ (void)setShouldUseOptimisedLaunch:(BOOL)useOptimised{
    [[NSUserDefaults standardUserDefaults] setBool:useOptimised forKey:SSCommonLogicUseOptimizedAPPLaunchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString * const SSCommonLogicUseALBBServiceKey = @"SSCommonLogicUseALBBServiceKey";
+ (BOOL)shouldUseALBBService{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:SSCommonLogicUseALBBServiceKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicUseALBBServiceKey];
    }
    return  NO;
}

+ (void)setShouldUseALBBService:(BOOL)useOptimised{
    [[NSUserDefaults standardUserDefaults] setBool:useOptimised forKey:SSCommonLogicUseALBBServiceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

NSString * const SSCommonLogicMaxUrlCacheKey = @"SSCommonLogicMaxUrlCacheKey";
+ (CGFloat)maxNSUrlCache{
    CGFloat maxValue = [[NSUserDefaults standardUserDefaults] floatForKey:SSCommonLogicMaxUrlCacheKey];
    return maxValue > 0 ? maxValue : 100;
}

+ (void)setMaxNSUrlCache:(CGFloat)maxValue{
    [[NSUserDefaults standardUserDefaults] setFloat:maxValue forKey:SSCommonLogicMaxUrlCacheKey];
}

NSString * const SSCommonLogicSettingNetworkDebugKey = @"debug_disable_network";
+ (BOOL)isNetWorkDebugEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SSCommonLogicSettingNetworkDebugKey];
}

+ (void)setIsNetWorkDebugEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:SSCommonLogicSettingNetworkDebugKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (CDN)

+ (NSUInteger)detailCDNVersion {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"tt_article_api_cdn_version"];
}

+ (void)setDetailCDNVersion:(NSUInteger)version {
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"tt_article_api_cdn_version"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation SSCommonLogic (NewFeedImpression)
static NSString *const kSSCommonLogicNewFeedImpressionEnabledKey =
@"kSSCommonLogicNewFeedImpressionEnabledKey";
+ (void)setNewFeedImpressionEnabled:(BOOL)enabled{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicNewFeedImpressionEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNewFeedImpressionEnabled{
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicNewFeedImpressionEnabledKey]){
        BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicNewFeedImpressionEnabledKey];
        return isEnabled;
    }
    else{
        return NO;
    }
}

@end

@implementation SSCommonLogic (Author)

+ (void)setH5SettingsForAuthor:(NSDictionary *)settings {
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"h5Settings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)fetchH5SettingsForAuthor {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"h5Settings"];
}

@end

@implementation SSCommonLogic (StrictDetailJudgement)

static NSString *const kSSCommonStrictDetailJudgementEnableKey = @"kSSCommonStrictDetailJudgementEnableKey";
+ (void)setStrictDetailJudgementEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonStrictDetailJudgementEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)strictDetailJudgementEnabled {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonStrictDetailJudgementEnableKey]) {
        BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonStrictDetailJudgementEnableKey];
        return isEnabled;
    } else {
        return NO;
    }
}

@end

@implementation SSCommonLogic (SearchOptimize)

static NSString * const kSSCommonLogicDisableSearchOptimize = @"kSSCommonLogicDisableSearchOptimize";

+ (void)disableSearchOptimize:(BOOL)disable {
    [[NSUserDefaults standardUserDefaults] setBool:disable forKey:kSSCommonLogicDisableSearchOptimize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSearchOptimizeDisabled {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicDisableSearchOptimize]) {
        BOOL disable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicDisableSearchOptimize];
        return disable;
    }
    else {
        return NO;
    }
}

@end

@implementation SSCommonLogic (ImageDisplayMode)
static NSString *const kSSCommonLogicImageDisplayModeFor3GIsSameAs2GKey = @"kSSCommonLogicImageDisplayModeFor3GIsSameAs2GKey";
static NSString *const kSSCommonLogicImageDisplayModeIsUpgradeUserKey = @"kSSCommonLogicImageDisplayModeIsUpgradeUserKey";
+ (void)setImageDisplayModeFor3GIsSameAs2GEnable:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicImageDisplayModeFor3GIsSameAs2GKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)imageDisplayModeFor3GIsSameAs2G
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicImageDisplayModeFor3GIsSameAs2GKey]) {
        BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicImageDisplayModeFor3GIsSameAs2GKey];
        return isEnabled;
    }
    return YES;
}

+ (void)setIsUpgradeUserAfterImageDisplayModeControlled:(BOOL)upgrade
{
    [[NSUserDefaults standardUserDefaults] setBool:upgrade forKey:kSSCommonLogicImageDisplayModeIsUpgradeUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//是否是移动网络流量可控功能上线后由新用户转变成的升级用户
+ (BOOL)isUpgradeUserAfterImageDisplayModelControlled
{
    BOOL isUpgrade = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicImageDisplayModeIsUpgradeUserKey];
    return isUpgrade;
}
@end

static NSString *const kSSCommonLogicThirdTabWeitoutiaoEnabledKey = @"kSSCommonLogicThirdTabWeitoutiaoEnabledKey";
@implementation SSCommonLogic (ThirdTabSwitch)

+ (void)setThirdTabWeitoutiaoEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicThirdTabWeitoutiaoEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isThirdTabWeitoutiaoEnabled {
    //确保在整个app生命周期内isThirdTabWeitoutiaoEnabled不变
    if ([SSCommonLogic isThirdTabHTSEnabled]) {
        return NO;
    }
    static BOOL isThirdTabWeitoutiaoEnabled = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //第三个tab默认是微头条
        NSNumber * enable = [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicThirdTabWeitoutiaoEnabledKey];
        if (nil != enable && [enable isKindOfClass:[NSNumber class]]) {
            isThirdTabWeitoutiaoEnabled = [enable boolValue];
        }
    });
    return isThirdTabWeitoutiaoEnabled;
}

+ (BOOL)isThirdTabFollowEnabled {
    if ([SSCommonLogic isThirdTabWeitoutiaoEnabled]) {
        return NO;
    } else if ([SSCommonLogic isThirdTabHTSEnabled]) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)isMyFollowSwitchEnabled {
    if ([SSCommonLogic isThirdTabWeitoutiaoEnabled]) {
        return YES;
    } else if ([SSCommonLogic isThirdTabHTSEnabled]) {
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation SSCommonLogic (UserVerifyConfig)
static NSString * const kSSCommonLogicUserVerifyConfigKey = @"kSSCommonLogicUserVerifyConfigKey";
+ (void)setUserVerifyConfigs:(NSDictionary *)configs
{
    if (SSIsEmptyDictionary(configs)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:configs forKey:kSSCommonLogicUserVerifyConfigKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)userVerifyConfigs
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSSCommonLogicUserVerifyConfigKey];
}

+ (NSDictionary *)userVerifyIconModelConfigs {
    static NSMutableDictionary *iconModelConfigs;
    NSDictionary *userVerifyConfigs = [[self class] userVerifyConfigs];
    if (!SSIsEmptyDictionary(userVerifyConfigs)) {
        NSArray<NSDictionary *> *configArray = [userVerifyConfigs tt_arrayValueForKey:@"type_config"];
        if (!SSIsEmptyArray(configArray)) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                iconModelConfigs = [NSMutableDictionary dictionaryWithCapacity:2];
                [configArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!SSIsEmptyDictionary(obj)) {
                        NSString *type = [obj tt_stringValueForKey:@"type"];
                        NSString *url = [obj tt_stringValueForKey:@"url"];
                        NSDictionary *avatarIcon = [obj tt_dictionaryValueForKey:@"avatar_icon"];
                        NSDictionary *labelIcon = [obj tt_dictionaryValueForKey:@"label_icon"];
                        iconModelConfigs[type] = @{
                                                   @"avatar_icon" : avatarIcon,
                                                   @"label_icon" : labelIcon,
                                                   @"url" : url
                                                   };
                    }
                }];
            });
        }
    }
    
    return [iconModelConfigs copy];
}

+ (NSDictionary *)userVerifyLabelIconModelOfType:(NSString *)type {
    if (isEmptyString(type)) {
        return nil;
    }
    
    NSDictionary *configs = [[self class] userVerifyIconModelConfigs];
    NSDictionary *config = [configs tt_dictionaryValueForKey:type];
    if (SSIsEmptyDictionary(config)) {
        return nil;
    }
    NSDictionary *labelIconModel = [config tt_dictionaryValueForKey:@"label_icon"];
    if (SSIsEmptyDictionary(labelIconModel)) {
        return nil;
    }
    
    return labelIconModel;
}

+ (NSDictionary *)userVerifyAvatarIconModelOfType:(NSString *)type {
    if (isEmptyString(type)) {
        return nil;
    }
    
    NSDictionary *configs = [[self class] userVerifyIconModelConfigs];
    NSDictionary *config = [configs tt_dictionaryValueForKey:type];
    if (SSIsEmptyDictionary(config)) {
        return nil;
    }
    NSDictionary *avatarIconModel = [config tt_dictionaryValueForKey:@"avatar_icon"];
    if (SSIsEmptyDictionary(avatarIconModel)) {
        return nil;
    }
    
    return avatarIconModel;
}

+ (NSArray<NSString *> *)userVerifyFeedShowArray
{
    NSDictionary *userVerifyConfigs = [[self class] userVerifyConfigs];
    if (!SSIsEmptyDictionary(userVerifyConfigs)) {
        return [userVerifyConfigs tt_arrayValueForKey:@"feed_show_type"];
    }
    
    return nil;
}
@end

static NSString * const kSSCommonLogicWeitoutiaoTabListUpdateTipTypeKey = @"kSSCommonLogicWeitoutiaoTabListUpdateTipTypeKey";
@implementation SSCommonLogic (WeitoutiaoTabListUpdateTipType)

+ (void)setWeitoutiaoTabListUpdateTipType:(NSUInteger)type {
    // 0：不作更新提醒；1：tab bar上出红点；2：列表顶部出蓝条
    if (type > 2) {
        type = 0;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:kSSCommonLogicWeitoutiaoTabListUpdateTipTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)WeitoutiaoTabListUpdateTipType {
    NSUInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:kSSCommonLogicWeitoutiaoTabListUpdateTipTypeKey];
    if (type > 2) {
        type = 2;
    }
    return type;
}

@end


static NSString *const kSSCommonLogicCollectDiskSpaceEnableKey = @"kSSCommonLogicCollectDiskSpaceEnableKey";

@implementation SSCommonLogic (CollectDiskSpace)

+ (void)setCollectDiskSpaceEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicCollectDiskSpaceEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isCollectDiskSpaceEnable {
    BOOL isCollectDiskSpaceEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicCollectDiskSpaceEnableKey];
    return isCollectDiskSpaceEnable;
}

@end

@implementation SSCommonLogic (TTLiveUseOwnPlayer)
static NSString *const kSSCommonLogicLiveUseOwnPlayerEnabledKey = @"live_use_own_player";
+ (void)setLiveUseOwnPlayerEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicLiveUseOwnPlayerEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isLiveUseOwnPlayerEnabled {
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicLiveUseOwnPlayerEnabledKey];
    return isEnabled;
}
@end

@implementation SSCommonLogic (TTPicsFollowEnable)

static NSString *const kSSCommonPicsFollowEnableKey = @"pics_follow_enable";
+ (void)setPicsFollowEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonPicsFollowEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isPicsFollowEnabled {
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonPicsFollowEnableKey];
    return isEnabled;
}

@end

@implementation SSCommonLogic (TTTrackSwitch)

static NSString *const kSSCommonTrackSwitchEnabledKey = @"kSSCommonTrackSwitchEnabledKey";
+ (void)setV3LogFormatEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonTrackSwitchEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isV3LogFormatEnabled {
    if([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonTrackSwitchEnabledKey]) {
        BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonTrackSwitchEnabledKey];
        return isEnabled;
    }
    return YES;
}
@end

@implementation SSCommonLogic (RefactorGetDomainsEnabled)
static NSString *const kSSRefactorGetDomainsEnabledKey = @"kSSRefactorGetDomainsEnabledKey";
+ (void)setRefactorGetDomainsEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSRefactorGetDomainsEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRefactorGetDomainsEnabled {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSRefactorGetDomainsEnabledKey]) {
        BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSRefactorGetDomainsEnabledKey];
        return isEnabled;
    }
    return YES;
}
@end

@implementation SSCommonLogic (VideoNewRotate)
static NSString *const kSSCommonVideoUseNewRotateKey = @"kSSCommonVideoUseNewRotate4Key";

+ (void)setVideoNewRotateTipEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_rotate_tip"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRotateTipEnabled
{
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_rotate_tip"];
    return isEnabled;
}

@end

@implementation SSCommonLogic (SDWebImage)
static NSString *const kSSCommonCustomSDDownloaderOperationKey = @"kSSCommonCustomSDDownloaderOperationKey";
+ (void)setCustomSDDownloaderOperationEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonCustomSDDownloaderOperationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableCustomSDDownloaderOperation {
    static BOOL enable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonCustomSDDownloaderOperationKey]) {
            enable = YES;
        } else {
            enable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonCustomSDDownloaderOperationKey];
        }
    });
    return enable;
}

+ (void)setBugfixSDWebImageDownloaderEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"tt_sddownloader_bugfix_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableBugfixSDWebImageDownloader {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"tt_sddownloader_bugfix_enable"]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_sddownloader_bugfix_enable"];
}

static NSString *const kSSImageOptimizeStrategyEnableKey = @"kSSImageOptimizeStrategyEnableKey";
+ (void)setUseImageOptimizeStrategyEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSImageOptimizeStrategyEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableImageOptimizeStrategy{
#ifdef DEBUG
    return YES;
#endif
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSImageOptimizeStrategyEnableKey];
}

static NSString *const KSSetMonitorFirstHostSuccessRateEnable = @"KSSetMonitorFirstHostSuccessRateEnable";
+ (void)setMonitorFirstHostSuccessRateEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:KSSetMonitorFirstHostSuccessRateEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableMonitorFirstHostSuccessRate{
#ifdef DEBUG
    return YES;
#endif
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:KSSetMonitorFirstHostSuccessRateEnable];
}

@end

@implementation SSCommonLogic (TTAdSplash)
static NSString *const kAdFirstSplashEnaleKey = @"kAdFirstSplashEnaleKey";
+ (void)setFirstSplashEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdFirstSplashEnaleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstSplashEnable {
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdFirstSplashEnaleKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}
@end

@implementation SSCommonLogic (TTAd_ForbidJump)
static NSString *const kAdShouldInterceptAdJumpKey = @"kAdShouldInterceptAdJump";
+ (BOOL)shouldInterceptAdJump
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdShouldInterceptAdJumpKey];
    if (!enable || ![enable boolValue]) {
        return NO;
    }
    return YES;
}
+ (void)setShouldInterceptAdJump:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kAdShouldInterceptAdJumpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kAdShouldAutoJumpControlEnabledKey = @"kAd_ShouldAutoJumpControlEnabled";
+ (BOOL)shouldAutoJumpControlEnabled
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdShouldAutoJumpControlEnabledKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}
+ (void)setShouldAutoJumpControlEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kAdShouldAutoJumpControlEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kAdSplashWhiteListForbidJumpKey = @"kAdSplash_WhiteList4ForbidJump";
+ (NSSet<NSString *> *)whiteListForAutoJump
{
    NSArray *defaultWhite = @[@"https", @"http", @"wss", @"ws", @"file", @"telnet", @"tcp", @"udp", @"tel", @"sslocal", @"snssdk141", @"snssdk32", @"snssdk51", @"snssdk1112", @"snssdk36", @"snssdk1128", @"snssdk1165", @"snssdk1370", @"bytedance", @"about"];
    NSArray *dynamicWhite =  [[NSUserDefaults standardUserDefaults] stringArrayForKey:kAdSplashWhiteListForbidJumpKey];
    NSMutableSet *set = [NSMutableSet setWithArray:defaultWhite];
    if (dynamicWhite != nil) {
        [set addObjectsFromArray:dynamicWhite];
    }
    return [set copy];
}
+ (void)setWhiteListForAutoJump:(NSArray<NSString *> *)whiteList
{
    [[NSUserDefaults standardUserDefaults] setValue:whiteList forKey:kAdSplashWhiteListForbidJumpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kAdShouldClickJumpControlEnabledKey = @"kAd_ShouldClickJumpControlEnabled";
+ (BOOL)shouldClickJumpControlEnabled
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdShouldClickJumpControlEnabledKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}
+ (void)setShouldClickJumpControlEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kAdShouldClickJumpControlEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kAdClickJumpTimeIntervalKey = @"kAd_ClickJumpTimeInterval";
+ (NSTimeInterval)clickJumpTimeInterval
{
    NSNumber *timeInterval = [[NSUserDefaults standardUserDefaults] objectForKey:kAdClickJumpTimeIntervalKey];
    if (timeInterval) {
        return [timeInterval doubleValue];
    }
    return 1000.0f; // 默认1000毫秒ms
}
+ (void)setClickJumpTimeInterval:(NSTimeInterval)interval
{
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kAdClickJumpTimeIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kAdForbidClickJumpTipsKey = @"kAd_ForbidClickJumpTips";
+ (NSString *)frobidClickJumpTips
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAdForbidClickJumpTipsKey]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:kAdForbidClickJumpTipsKey];
    }
    return @"不支持此类跳转";
}
+ (void)setFrobidClickJumpTips:(NSString *)tips
{
    [[NSUserDefaults standardUserDefaults] setObject:tips forKey:kAdForbidClickJumpTipsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kAdBlackListClickJumpKey = @"kAd_BlackList4ClickJump";
+ (NSSet<NSString *> *)blackListForClickJump
{
    NSArray *dynamicWhite = [[NSUserDefaults standardUserDefaults] stringArrayForKey:kAdBlackListClickJumpKey];
    NSMutableSet *set = [NSMutableSet set];
    if (dynamicWhite) {
        [set addObjectsFromArray:dynamicWhite];
    }
    return [set copy];
}
+ (void)setBlackListForClickJump:(NSArray<NSString *> *)blackList
{
    [[NSUserDefaults standardUserDefaults] setValue:blackList forKey:kAdBlackListClickJumpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (TTAd_ForbidClickJump)


@end

@implementation SSCommonLogic (TTAdGifImageView)

static NSString *const kAdGifImageViewEnaleKey = @"kAdGifImageViewEnaleKey";
+ (void)setAdGifImageViewEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdGifImageViewEnaleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAdGifImageViewEnable {
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdGifImageViewEnaleKey];
    if (enable) {
        return [enable boolValue];
    }
    return YES;
}

@end

@implementation SSCommonLogic (TTAdImpressionTrack)

static NSString *const kAdImpressionTrackEnableKey = @"kAdImpressionTrackEnableKey";
+ (void)setAdImpressionTrack:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdImpressionTrackEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAdImpressionTrack {
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdImpressionTrackEnableKey];
    if (enable && ![enable boolValue]) {
        return NO;
    }
    return YES;
}
@end

@implementation SSCommonLogic (TTAdResPreload)

static NSString* const kAdResPreloadEnableKey = @"kAdResPreloadEnableKey";

+ (void)setAdResPreloadEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdResPreloadEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAdResPreloadEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdResPreloadEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdUseV2Preload)

static NSString* const kAdUseV2PreloadEnableKey = @"kAdUseV2PreloadEnableKey";

+ (void)setAdUseV2PreloadEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdUseV2PreloadEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAdUseV2PreloadEnable {
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdUseV2PreloadEnableKey];
    if (enable) {
        return [enable boolValue];
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdCanvas)

static NSString* const kAdCanvasEnableKey = @"kAdCanvasEnableKey";

+ (void)setCanvasEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdCanvasEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isCanvasEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdCanvasEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdCanvas_NativeEnable)
static NSString* const kAdCanvaNativesEnableKey = @"kAdCanvasNativeEnableKey";
+ (void)setCanvasNativeEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdCanvaNativesEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isCanvasNativeEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdCanvaNativesEnableKey];
    if ([enable boolValue]) {
        return YES;
    }
    return NO;
}
@end

@implementation SSCommonLogic (TTAdCanvas_PreloadStrategy)
static NSString *const kAdCanvasPreloadStrategyKey = @"kAdCanvasPreloadStrategyKey";
+ (NSDictionary *)canvasPreloadStrategy {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kAdCanvasPreloadStrategyKey];
}

+ (void)setCanvasPreloadStrategy:(NSDictionary *)dict {
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kAdCanvasPreloadStrategyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (TTAdUrlTracker)

static NSString* const kAdUrlTrackerEnableKey = @"kAdUrlTrackerEnableKey";

+ (void)setUrlTrackerEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAdUrlTrackerEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUrlTrackerEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAdUrlTrackerEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end


@implementation SSCommonLogic (TTTemailTracker)
static NSString *const kTemailTrackerKey = @"kTemailTrackerKey";
+ (void)setTemailTrackerEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTemailTrackerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isTemailTrackerEnable {
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kTemailTrackerKey];
    if (enable) {
        return [enable boolValue];
    }
    return YES;
}
@end


@implementation SSCommonLogic (TTAdAppPreload)

static NSString* const kAppPreloadEnableKey = @"kAppPreloadEnableKey";

+ (void)setAppPreloadEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kAppPreloadEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAppPreloadEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kAppPreloadEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdWebDomComplete)

static NSString* const kWebDomCompleteEnableKey = @"kWebDomCompleteEnableKey";

+ (void)setWebDomCompleteEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kWebDomCompleteEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isWebDomCompleteEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kWebDomCompleteEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdMZSDKEnable)

static NSString* const kMZSDKEnableKey = @"kMZSDKEnableKey";

+ (void)setMZSDKEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kMZSDKEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isMZSDKEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kMZSDKEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdUAEnable)

static NSString* const kTTAdUAEnableKey = @"kTTAdUAEnableKey";

+ (void)setUAEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTAdUAEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUAEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAdUAEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdRNMonitorEnable)

static NSString* const TTAdRNMonitorEnable = @"TTAdRNMonitorEnable";

+ (void)setRNMonitorEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:TTAdRNMonitorEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRNMonitorEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:TTAdRNMonitorEnable];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdSDKDelayEnable)

static NSString* const kTTAdSDKDelayEnableKey = @"kTTAdSDKDelayEnableKey";

+ (void)setSDKDelayEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTAdSDKDelayEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSDKDelayEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAdSDKDelayEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAd_RawAdData)

static NSString* const kTTAdRawAdDataEnableKey = @"kTTAdRawAdDataEnableKey";

+ (void)setRawAdDataEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTAdRawAdDataEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRawAdDataEnable {
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAdRawAdDataEnableKey];
    if (enable == nil) {
        return YES;
    }
    return [enable boolValue];
}

@end

@implementation SSCommonLogic (TTAdSKVCBugFixEnable)

static NSString* const kTTAdSKVCBugFixEnableKey = @"kTTAdSKVCBugFixEnableKey";

+ (void)setSKVCBugFixEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTAdSKVCBugFixEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSKVCBugFixEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAdSKVCBugFixEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (TTAdSKVCLoadEnable)

static NSString* const kTTAdSKVCLoadEnableKey = @"kTTAdSKVCLoadEnableKey";

+ (void)setSKVCLoadEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTAdSKVCLoadEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isSKVCLoadEnable
{
    NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kTTAdSKVCLoadEnableKey];
    if (!enable || [enable boolValue]) {
        return YES;
    }
    return NO;
}

@end

@implementation SSCommonLogic (VideoBusinessSplit)
static NSString *const kSSCommonVideoBusinessSplitKey = @"kSSCommonVideoBusinessSplitKey";
+ (void)setVideoBusinessSplitEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonVideoBusinessSplitKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)isVideoBusinessSplitEnabled {
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonVideoBusinessSplitKey];
    return isEnabled;
}
@end

@implementation SSCommonLogic (FetchSettings)
static NSString *const kFetchSettingWhenEnterForeground = @"kFetchSettingWhenEnterForeground";
static NSString *const kFetchSettingTimeInterval = @"kFetchSettingTimeInterval";
+ (void)setFetchSettingWhenEnterForegroundEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kFetchSettingWhenEnterForeground];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)isFetchSettingWhenEnterForegroundEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFetchSettingWhenEnterForeground];
}
+ (void)setFetchSettingTimeInterval:(NSTimeInterval)interval {
    [[NSUserDefaults standardUserDefaults] setDouble:interval forKey:kFetchSettingTimeInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSTimeInterval)fetchSettingTimeInterval {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kFetchSettingTimeInterval];
}
@end

@implementation SSCommonLogic (mixedBaseList)
static NSString *const kGetRemoteCheckNetwork = @"kGetRemoteCheckNetwork";
+ (void)setGetRemoteCheckNetworkEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kGetRemoteCheckNetwork];
}
+ (BOOL)isGetRemoteCheckNetworkEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGetRemoteCheckNetwork];
}
@end

static NSString *const kIsScreenshotShareEnable = @"kIsScreenshotShareEnable";
static NSString *const kScreenshotShareText = @"kScreenshotShareText";
static NSString *const kScreenshotShareQR = @"kScreenshotShareQR";
static NSString *const kScreenshotMethodB = @"kScreenshotMethodB";
@implementation SSCommonLogic (screenshotShare)

+ (BOOL)screenshotEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsScreenshotShareEnable];
}

+ (void)setScreenshotEnable:(BOOL)enabled{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kIsScreenshotShareEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)shareText{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kScreenshotShareText];
}

+ (void)setShareTextWithText:(NSString *)text{
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:kScreenshotShareText];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)screenshotShareQR{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kScreenshotShareQR];
}
+ (void)setScreenshotShareQR:(NSString *)url{
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:kScreenshotShareQR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)makeScreenshotForMethodB{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kScreenshotMethodB];
}

+ (void)setMakeScreenshotForMethodBEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kScreenshotMethodB];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

@implementation SSCommonLogic (PullRefresh)

+ (void)setNewPullRefreshEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"pull_refresh_new_enabled"];
}

+ (BOOL)isNewPullRefreshEnabled {
    static BOOL bEnabled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_refresh_new_enabled"];
    });
    return bEnabled;
}

+ (CGFloat)articleNotifyBarHeight {
    if ([SSCommonLogic isNewPullRefreshEnabled]) {
        return 40.0;
    } else {
        return 32.0;
    }
}

@end

static NSString * const kVideoCompressRefactorEnabled = @"kVideoCompressRefactorEnabled";
@implementation SSCommonLogic (VideoCompressRefactor)

+ (BOOL)isVideoCompressRefactorEnabled {
    if([[NSUserDefaults standardUserDefaults] objectForKey:kVideoCompressRefactorEnabled]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoCompressRefactorEnabled];
    }
    return NO;
}

+ (void)setVideoCompressRefactorEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kVideoCompressRefactorEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation SSCommonLogic (VideoFeedCellHeightAjust)
+ (void)setVideoFeedCellHeightAjust:(NSInteger)enabled {
    [[NSUserDefaults standardUserDefaults] setInteger:enabled forKey:@"tt_video_feed_cellui_height_adjust"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSInteger)isVideoFeedCellHeightAjust {
    if ([TTDeviceHelper isPadDevice]) {
        return 0;
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"tt_video_feed_cellui_height_adjust"];
}
@end

@implementation SSCommonLogic (VideoAdAutoPlayedHalfShow)
+ (void)setVideoAdAutoPlayedWhenHalfShow:(BOOL)enabled  {
    [[NSUserDefaults standardUserDefaults] setBool: enabled forKey:@"tt_video_autoplayad_halfshow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)isVideoAdAutoPlayedWhenHalfShow {
    if ([TTDeviceHelper isPadDevice]){
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_video_autoplayad_halfshow"];
}
@end

static NSString * const kWeitoutiaoRepostOriginalReviewHintKey = @"kWeitoutiaoRepostOriginalReviewHintKey";
@implementation SSCommonLogic (WeitoutiaoRepostOriginalStatusHint)

+ (NSString *)repostOriginalReviewHint {
    NSString * hint = [[NSUserDefaults standardUserDefaults] objectForKey:kWeitoutiaoRepostOriginalReviewHintKey];
    if (isEmptyString(hint)) {
        hint = NSLocalizedString(@"原内容审核中", nil);
    }
    return hint;
}

+ (void)setRepostOriginalReviewHint:(NSString *)reviewHint {
    if (!isEmptyString(reviewHint)) {
        [[NSUserDefaults standardUserDefaults] setObject:reviewHint forKey:kWeitoutiaoRepostOriginalReviewHintKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end

@implementation SSCommonLogic (TTDislikeRefctor)
NSString *const kTTArticleDislikeRefactor = @"tt_article_dislike_refactor";
NSString *const kTTArticleFeedDislikeRefactor = @"tt_article_feed_dislike_refactor";
+ (void)setDislikeRefactorEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kTTArticleDislikeRefactor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isDislikeRefactorEnabled {
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTArticleDislikeRefactor];
}

+ (void)setFeedDislikeRefactorEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kTTArticleFeedDislikeRefactor];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFeedDislikeRefactorEnabled {
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTArticleFeedDislikeRefactor];
}
@end

static NSString *const kVideoADReplayBtnEnabled = @"video_ad_replay_btn_enabled";
@implementation SSCommonLogic (VideoPasterADReplay)

+ (void)setVideoADReplayBtnEnabled:(BOOL)enabled {
    
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kVideoADReplayBtnEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isVideoADReplayBtnEnabled {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoADReplayBtnEnabled];
}

@end

@implementation SSCommonLogic (IsIcloudEabled)

+ (BOOL)isIcloudEabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"openImagePickerIcloud"];
}
+ (void)setIcloudBtnEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"openImagePickerIcloud"];
}


@end




@implementation SSCommonLogic (RealnameAuth)
+ (void)setRealnameAuthEncryptDisabled:(BOOL)disabled
{
    [[NSUserDefaults standardUserDefaults] setBool:disabled forKey:@"realname_auth_encrypt_disabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)isRealnameAuthEncryptDisabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"realname_auth_encrypt_disabled"];
}
@end

@implementation SSCommonLogic (ReportTyposAlert)
+ (void)setReportTyposEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"article_report_alert_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isReportTyposEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"article_report_alert_enable"];
}
@end

static NSString *const KSSCommonLogicTransitionAnimationEnableKey = @"KSSCommonLogicTransitionAnimationEnableKey";
static BOOL _transitonAnimationEnable = NO;
@implementation SSCommonLogic (TransitonAnimationEnable)
+ (void)setTransitionAnimationEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:KSSCommonLogicTransitionAnimationEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)transitionAnimationEnable {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _transitonAnimationEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KSSCommonLogicTransitionAnimationEnableKey];
    });
    return _transitonAnimationEnable;
}
@end

@implementation SSCommonLogic (IMServer)

+ (void)setIMServerEnabled:(BOOL)enable {
    /*
     if (enable && [SSCommonLogic isIMServerEnable] != enable) {
     [[TTIMManager sharedManager] accountDidChanged];
     [[TTIMSDKService sharedInstance] queryCenterMsgList];
     }
     [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"im_server_enabled"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     [[TTPLManager sharedManager] refreshUnreadNumber];
     [[TTSettingMineTabManager sharedInstance_tt] refreshPrivateLetterEntry:enable];
     */
    
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"im_server_enabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [[TTPLManager sharedManager] resetIMServerEnabled:enable];
}

+ (BOOL)isIMServerEnable {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"im_server_enabled"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"im_server_enabled"];
    }
    return NO;
}

@end

static NSString *const KSSCommonLogicImageTransitionAnimationEnableKey = @"KSSCommonLogicImageTransitionAnimationEnableKey";
static BOOL _imageTransitionAnimationEnable = NO;
@implementation SSCommonLogic (ImageTransitionAnimationControl)
+ (void)setImageTransitionAnimationEnable:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:KSSCommonLogicImageTransitionAnimationEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)imageTransitionAnimationEnable{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KSSCommonLogicImageTransitionAnimationEnableKey]){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _imageTransitionAnimationEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KSSCommonLogicImageTransitionAnimationEnableKey];
        });
        return _imageTransitionAnimationEnable;
    }
    else{
        return NO;
    }
}
@end

static NSString * const kNewMessageNotificationEnabledKey = @"kNewMessageNotificationEnabledKey";
@implementation SSCommonLogic (NewMessageNotification)
+ (void)setNewMessageNotificationEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kNewMessageNotificationEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNewMessageNotificationEnabled
{
    static BOOL isNewMessageNotificationEnabled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if([[NSUserDefaults standardUserDefaults] objectForKey:kNewMessageNotificationEnabledKey]){
            isNewMessageNotificationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kNewMessageNotificationEnabledKey];
        }
        else{
            isNewMessageNotificationEnabled = YES;
        }
    });
    return isNewMessageNotificationEnabled;
}

@end

@implementation SSCommonLogic (PersonalHome)

+ (void)setPersonalHomeMediaTypeThreeEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"tt_personal_home_media_type_three_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isPersonalHomeMediaTypeThreeEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_personal_home_media_type_three_enable"];
}

@end

static NSString *const kSSCommonLogicForthTabHTSEnabledKey = @"kSSCommonLogicForthTabHTSEnabledKey";
static NSString *const kSSCommonLogicForthTabInitialVisibleCategoryIndexKey = @"kSSCommonLogicForthTabInitialVisibleCategoryIndexKey";
static NSString *const kSSCommonLogicLaunchHuoShanAppEnabledKey = @"kSSCommonLogicLaunchHuoShanAppEnabledKey";
static NSString *const kSSCommonLogicHTSTabBannerInfoDictKey = @"kSSCommonLogicHTSTabBannerInfoDictKey";
static NSString *const kSSCommonLogicHTSTabMineIconURLKey = @"kSSCommonLogicHTSTabMineIconURLKey";
static NSString *const kSSCommonLogicHTSAppDownloadInfoDictKey = @"kSSCommonLogicHTSAppDownloadInfoDictKey";
static NSString *const kSSCommonLogicHTSTabMineIconTipsHasShowKey = @"kSSCommonLogicHTSTabMineIconTipsHasShowKey";
static NSString *const kSSCommonLogicHTSVideoPlayerTypeKey = @"kSSCommonLogicHTSVideoPlayerTypeKey";
static NSString *const kSSCommonLogicAWEVideoDetailFirstFrameKey = @"kSSCommonLogicAWEVideoDetailFirstFrameKey";

@implementation SSCommonLogic (HTSTabSettings)

+ (void)setHTSTabSwitch:(NSInteger)tabSwitch {
    [[NSUserDefaults standardUserDefaults] setInteger:tabSwitch forKey:kSSCommonLogicForthTabHTSEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isThirdTabHTSEnabled {
    static BOOL isThirdTabHTSEnabled = NO;
    //确保在整个app生命周期内isThirdTabHTSEnabled不变
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper OSVersionNumber] < 8 || [SSCommonLogic isForthTabHTSEnabled]){
            isThirdTabHTSEnabled = NO;//ipad 或者iOS 7及以下不支持,第四个tab是火山的话第三个tab一定不是
        }
        else if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicForthTabHTSEnabledKey]){
            NSInteger tabSwitch = [[NSUserDefaults standardUserDefaults] integerForKey:kSSCommonLogicForthTabHTSEnabledKey];
            isThirdTabHTSEnabled = tabSwitch == 2;
        }
    });
    return isThirdTabHTSEnabled;
}

+ (BOOL)isForthTabHTSEnabled {
    //确保在整个app生命周期内isForthTabHTSEnabledd不变
    if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper OSVersionNumber] < 8){
        return NO;//ipad 或者iOS 7及以下不支持
    }
    static BOOL isForthTabHTSEnabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //第四个tab默认是我的tab
        NSInteger tabSwitch = [[NSUserDefaults standardUserDefaults] integerForKey:kSSCommonLogicForthTabHTSEnabledKey];
        if (tabSwitch > 0 && tabSwitch != 2) {
            isForthTabHTSEnabled = YES;
        } else{
            isForthTabHTSEnabled = NO;
        }
    });
    return isForthTabHTSEnabled;
}

//火山tab 首次进入显示火山／抖音频道
+ (void)setForthTabInitialVisibleCategoryIndex:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kSSCommonLogicForthTabInitialVisibleCategoryIndexKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)forthTabInitialVisibleCategoryIndex
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSSCommonLogicForthTabInitialVisibleCategoryIndexKey];
}

+ (BOOL)isHTSAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"snssdk1370://"]];
}

//火山tab列表点击cell是否跳转到火山app开关
+ (void)setLaunchHuoShanAppEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSCommonLogicLaunchHuoShanAppEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isLaunchHuoShanAppEnabled
{
    static BOOL isLaunchHuoShanAppEnabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //默认是跳转到火山app
        NSNumber *enable = [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicLaunchHuoShanAppEnabledKey];
        if (enable && [enable isKindOfClass:[NSNumber class]]) {
            isLaunchHuoShanAppEnabled = [enable boolValue];
        }
    });
    return isLaunchHuoShanAppEnabled;
}

//火山tab顶部banner
+ (void)setHTSTabBannerInfoDict:(NSDictionary *)dict{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kSSCommonLogicHTSTabBannerInfoDictKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)htsTabBannerInfoDict{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicHTSTabBannerInfoDictKey];
}

+ (BOOL)htsTabBannerEnabled
{
    NSDictionary *infoDict = [self htsTabBannerInfoDict];
    if ([infoDict objectForKey:@"banner_switch"]) {
        return [[self htsTabBannerInfoDict] tt_boolValueForKey:@"banner_switch"];
    }
    return NO;
}

//火山tab出现时，我的在左上角展示，我的icon的默认图的url
+ (void)setHTSTabMineIconURL:(NSString *)url{
    [[NSUserDefaults standardUserDefaults] setValue:url forKey:kSSCommonLogicHTSTabMineIconURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)htsTabMineIconURL{
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicHTSTabMineIconURLKey];
    if (!isEmptyString(url)) {
        return url;
    }
    return nil;
}

//火山app下载apple_id
+ (void)setHTSAppDownloadInfoDict:(NSDictionary *)dict{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kSSCommonLogicHTSAppDownloadInfoDictKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)htsAppDownloadInfoDict{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicHTSAppDownloadInfoDictKey];
}

+ (NSString *)htsAPPAppleID{
    NSDictionary *dict = [self htsAppDownloadInfoDict];
    if ([dict objectForKey:@"download_item"]){
        NSDictionary *downloadItem = [dict tt_dictionaryValueForKey:@"download_item"];
        if ([downloadItem objectForKey:@"apple_id"]){
            return [downloadItem tt_stringValueForKey:@"apple_id"];
        }
    }
    return @"1086047750";
}

+ (void)setHTSTabMineIconTipsHasShow:(BOOL)show
{
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:kSSCommonLogicHTSTabMineIconTipsHasShowKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)htsTabMineIconTipsHasShow
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicHTSTabMineIconTipsHasShowKey];
}

//播放器类型 0：系统播放器 1：自研播放器
+ (NSInteger)htsVideoPlayerType
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSSCommonLogicHTSVideoPlayerTypeKey];
}

//播放器类型 0：系统播放器 1：自研播放器
+ (void)setHTSVideoPlayerType:(NSInteger)playType
{
    if (playType < 0 || playType > 1) {
        playType = 0;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:playType forKey:kSSCommonLogicHTSVideoPlayerTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//小视频详情页是否开启显示首帧
+ (void)setAWEVideoDetailFirstFrame:(NSNumber *)type;
{
    [[NSUserDefaults standardUserDefaults] setObject:type forKey:kSSCommonLogicAWEVideoDetailFirstFrameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation SSCommonLogic (AWEMEVideoSettings)

+ (BOOL)isAWEMEAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"snssdk1128://"]];
}

+ (NSString *)awemeAPPAppleID
{
    return @"1142110895";
}
@end

@implementation SSCommonLogic (AppLogSendOptimize)
+ (void)setAppLogSendOptimizeEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kAppLogSendOptimize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAppLogSendOptimizeEnabled
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kAppLogSendOptimize"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"kAppLogSendOptimize"];
    }
    return YES;
}
@end

@implementation SSCommonLogic (NewLaunchOptimize)

+ (void)setNewLaunchOptimizeEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"kSSCommonLogicNewLaunchOptimizeEnabledKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNewLaunchOptimizeEnabled {
    static BOOL isNewLaunchOptimizeEnabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber * enable = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSSCommonLogicNewLaunchOptimizeEnabledKey"];
        if (nil != enable && [enable isKindOfClass:[NSNumber class]]) {
            isNewLaunchOptimizeEnabled = [enable boolValue];
        }
    });
    return isNewLaunchOptimizeEnabled;
}

@end

@implementation SSCommonLogic (PlayWithIP)

+ (void)setPlayerImageEnhancementEnabel:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_play_image_enhancement"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)playerImageEnhancementEnabel
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_play_image_enhancement"] && [TTDeviceHelper OSVersionNumber] >= 9;
}
@end

static NSString *const kVideoDetailPlayLastShowText = @"tt_video_detail_playlast_showtext";
@implementation SSCommonLogic (VideoDetailPlayLastShowText)

+ (void)setVideoDetailPlayLastShowText:(BOOL)enabled {
    
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kVideoDetailPlayLastShowText];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isVideoDetailPlayLastShowText {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kVideoDetailPlayLastShowText];
}

@end

static NSString *const kUGCThreadPostImageUserWebP = @"tt_ugc_threadpost_uploadimage_webp";
static NSString *const kUGCNewCellEnable = @"tt_ugc_new_cell_enable";
@implementation SSCommonLogic (UGCThreadPost)

+ (void)setUGCThreadPostImageWebP:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kUGCThreadPostImageUserWebP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUGCThreadPostImageWebP {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kUGCThreadPostImageUserWebP]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUGCThreadPostImageUserWebP];
}

+ (void)setUGCNewCellEnable:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kUGCNewCellEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUGCNewCellEnable {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kUGCNewCellEnable]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUGCNewCellEnable];
}

@end

static NSString *const kTTChatroomInterrupt = @"tt_chatroom_handle_interrupt";
@implementation SSCommonLogic (ChatroomInterrupt)

+ (void)setHandleInterruptTrickMethodEnable:(BOOL)enabled{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kTTChatroomInterrupt];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)handleInterruptTrickMethodEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTChatroomInterrupt];
}
@end

static NSString *const kUGCEmojiQuickInputEnabled = @"tt_ugc_emoji_quick_input_enabled";
@implementation SSCommonLogic (UGCEmojiQuickInput)
+ (void)setUGCEmojiQuickInputEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kUGCEmojiQuickInputEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUGCEmojiQuickInputEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUGCEmojiQuickInputEnabled];
}
@end

static NSString * const kSSCommonLogicFollowChannelColdStartEnableKey = @"kSSCommonLogicFollowChannelColdStartEnableKey";
static NSString * const kSSCommonLogicFollowChannelMessageEnableKey = @"kSSCommonLogicFollowChannelMessageEnableKey";
static NSString * const kSSCommonLogicFollowChannelUploadContactsKey = @"kSSCommonLogicFollowChannelUploadContactsKey";
static NSString * const kSSCommonLogicFollowChannelUploadContactsTextKey = @"kSSCommonLogicFollowChannelUploadContactsTextKey";

@implementation SSCommonLogic (FollowChannel)

+ (void)setFollowChannelColdStartEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable
                                            forKey:kSSCommonLogicFollowChannelColdStartEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)followChannelColdStartEnable {
    static BOOL followChannelColdStartEnable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicFollowChannelColdStartEnableKey]) {
            followChannelColdStartEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicFollowChannelColdStartEnableKey];
        }else {
            followChannelColdStartEnable = YES;
        }
    });
    return followChannelColdStartEnable;
}

+ (void)setFollowChannelMessageEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable
                                            forKey:kSSCommonLogicFollowChannelMessageEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)followChannelMessageEnable {
    BOOL followChannelMessageEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicFollowChannelMessageEnableKey];
    return followChannelMessageEnable;
}

+ (void)setFollowChannelUploadContactsEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable
                                            forKey:kSSCommonLogicFollowChannelUploadContactsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)followChannelUploadContactsEnable {
    static BOOL followChannelUploadContacts = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        followChannelUploadContacts = [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicFollowChannelUploadContactsKey];
    });
    return followChannelUploadContacts;
}

+ (void)setFollowChannelUploadContactsText:(NSString *)text {
    if (isEmptyString(text) || ![text isKindOfClass:[NSString class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:text
                                              forKey:kSSCommonLogicFollowChannelUploadContactsTextKey];
}

+ (NSString *)followChannelUploadContactsText {
    static NSString * followChannelUploadContactsText = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        followChannelUploadContactsText = [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicFollowChannelUploadContactsTextKey];
        if (isEmptyString(followChannelUploadContactsText)) {
            followChannelUploadContactsText = NSLocalizedString(@"同步通讯录，找到更多好友", nil);
        }
    });
    return followChannelUploadContactsText;
}

@end

static NSString *const kTTWeiboExpirationDetect = @"tt_weibo_expiration_enable";
@implementation SSCommonLogic (WeiboExpiration)
+ (void)setWeiboExpirationDetectEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTWeiboExpirationDetect];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)weiboExpirationDetectEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTWeiboExpirationDetect];
}
@end

static NSString *const kTTFeedDetailShareImageStyle = @"tt_feed_detail_share_image_style";
@implementation SSCommonLogic (FeedDetailShareImageStyle)
+ (void)setFeedDetailShareImageStyle:(NSInteger)feedDetailShareImageStyle
{
    [[NSUserDefaults standardUserDefaults] setInteger:feedDetailShareImageStyle forKey:kTTFeedDetailShareImageStyle];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)feedDetailShareImageStyle
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kTTFeedDetailShareImageStyle];
}
@end

static NSString *const kTTFeedHomeClickRefreshSetting = @"tt_home_click_refresh_setting";
@implementation SSCommonLogic (FeedHomeClickRefreshSetting)
+ (void)setFeedHomeClickRefreshSetting:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedHomeClickRefreshSetting];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)homeClickNoAction
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedHomeClickRefreshSetting];
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    if ([[dic valueForKey:@"is_enable"] integerValue] == -1) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)homeClickRefreshEnable
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedHomeClickRefreshSetting];
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    if ([[dic valueForKey:@"is_enable"] integerValue] == 0) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)homeClickLoadmoreEnable
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedHomeClickRefreshSetting];
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    if ([[dic valueForKey:@"is_enable"] integerValue] == 1) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)homeClickLoadmoreEnableForCategoryID:(NSString *)categoryID
{
    if (!categoryID || ![categoryID isKindOfClass:[NSString class]] || categoryID.length < 1) {
        return NO;
    }
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedHomeClickRefreshSetting];
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    NSDictionary *info = [dic valueForKey:@"category_map"];
    if (!info || ![info isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    if ([[info valueForKey:categoryID] integerValue] == 1) {
        return YES;
    }
    
    return NO;
}

+ (NSInteger)homeClickActionTypeForCategoryID:(NSString *)categoryID
{
    if (!categoryID || ![categoryID isKindOfClass:[NSString class]] || categoryID.length < 1) {
        return -2;
    }
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedHomeClickRefreshSetting];
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return -2;
    }
    
    NSDictionary *info = [dic valueForKey:@"category_map"];
    if (!info || ![info isKindOfClass:[NSDictionary class]]) {
        return -2;
    }
    
    if ([info valueForKey:categoryID]) {
        return [[info valueForKey:categoryID] integerValue];
    } else {
        return -2;
    }
}
@end

static NSString *const kTTFeedStartCategoryConfig = @"f_category_settings";
@implementation SSCommonLogic (FeedStartCategoryConfig)
+ (void)setFeedStartCategoryConfig:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedStartCategoryConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)feedStartCategory
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedStartCategoryConfig];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"category_name"] && [dic[@"category_name"] isKindOfClass:[NSString class]]) {
            NSString *startCategory = dic[@"category_name"];
            if (startCategory.length > 0) {
                return startCategory;
            }
        }
    }
    return nil;
}
@end

static NSString *const kTTFeedStartTabConfig = @"tt_start_tab_config";
@implementation SSCommonLogic (FeedStartTabConfig)
+ (void)setFeedStartTabConfig:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedStartTabConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)feedStartTab
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedStartTabConfig];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"tab_config"] && [dic[@"tab_config"] isKindOfClass:[NSArray class]]) {
            NSArray *tabsConfigArray = dic[@"tab_config"];
            for (NSDictionary *dic in tabsConfigArray) {
                if (dic[@"tab_priority"] && ([dic[@"tab_priority"] integerValue] < 2)) {
                    return dic[@"tab_name"];
                }
            }
        }
    }
    return nil;
}
@end

static NSString *const kTTFeedCategoryTabAllConfig = @"tt_feed_category_tab_config";
@implementation SSCommonLogic (FeedCategoryTabAllConfig)
+ (void)setCategoryTabAllConfig:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedCategoryTabAllConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)firstCategoryStyle
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedCategoryTabAllConfig];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"feed_tactics"]) {
            return [dic[@"feed_tactics"] integerValue];
        }
    }
    
    return 0;
}

+ (NSInteger)firstTabStyle
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedCategoryTabAllConfig];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"tab_tactics"]) {
            return [dic[@"tab_tactics"] integerValue];
        }
    }
    
    return 0;
}
@end

static NSString *const kTTFeedLoadLocalStrategy = @"tt_feed_load_local_strategy";
@implementation SSCommonLogic (FeedLoadLocalStrategy)
+ (void)setFeedLoadLocalStrategy:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedLoadLocalStrategy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)showMyAppFansView
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"profile_show_my_app_fans"]) {
            return [dic[@"profile_show_my_app_fans"] boolValue];
        }
    }
    
    return NO;
}

+ (BOOL)useImageVideoNewApi
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"image_video_use_new_api"]) {
            return [dic[@"image_video_use_new_api"] boolValue];
        }
    }
    
    return NO;
}

+ (BOOL)useNewSearchTransitionAnimation
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"new_search_animation"]) {
            return [dic[@"new_search_animation"] boolValue];
        }
    }
    
    return NO;
}

+ (BOOL)useNewSearchTransitionAnimationForVideo
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"new_search_animation_video"]) {
            return [dic[@"new_search_animation_video"] boolValue];
        }
    }
    
    return NO;
}

+ (BOOL)useRealUnixTimeEnable
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"real_unix_time"]) {
            return [dic[@"real_unix_time"] boolValue];
        }
    }
    
    return NO;
}

+ (NSInteger)feedLoadLocalStrategy
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"strategy"]) {
            return [dic[@"strategy"] integerValue];
        }
    }
    
    return 0;
}

+ (BOOL)newItemIndexStrategyEnable
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"new_index"]) {
            return [dic[@"new_index"] boolValue];
        }
    }
    
    return NO;
}

+ (BOOL)loadLocalUseMemoryCache
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedLoadLocalStrategy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        if (dic[@"memory_cache"]) {
            return [dic[@"memory_cache"] boolValue];
        }
    }
    
    return NO;
}
@end

static NSString *const kTTFeedCaregoryAddHidden = @"tt_feed_category_add_hidden";
@implementation SSCommonLogic (FeedCaregoryAddHidden)
+ (void)setFeedCaregoryAddHiddenEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTFeedCaregoryAddHidden];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)feedCaregoryAddHiddenEnable
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTFeedCaregoryAddHidden]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kTTFeedCaregoryAddHidden];
    }
    return YES;
}
@end

static NSString *const kTTPreloadmoreOutScreenNumber = @"tt_pre_load_more_out_screen_number";
@implementation SSCommonLogic (PreloadmoreOutScreenNumber)
+ (void)setPreloadmoreOutScreenNumber:(NSInteger)number
{
    [[NSUserDefaults standardUserDefaults] setInteger:number forKey:kTTPreloadmoreOutScreenNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)preloadmoreOutScreenNumber
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kTTPreloadmoreOutScreenNumber];
}
@end

static NSString *const kTTSearchHintSuggestEnable = @"tt_search_hint_homepage_suggest";
@implementation SSCommonLogic (SearchHintSuggestEnable)
+ (void)setSearchHintSuggestEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTSearchHintSuggestEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)searchHintSuggestEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTSearchHintSuggestEnable];
}
@end

static NSString *const kTTFeedSearchEntryEnable = @"tt_feed_search_entry_enable";
@implementation SSCommonLogic (FeedSearchEntry)
+ (void)setFeedSearchEntryEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:kTTFeedSearchEntryEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)feedSearchEntrySettingsSaved
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kTTFeedSearchEntryEnable];
    if (value) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)feedSearchEntryEnable
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:kTTFeedSearchEntryEnable];
    return [value boolValue];
}
@end

static NSString *const kTTFeedFantasyLocalSettings = @"tt_feed_fantasy_local_settings";
@implementation SSCommonLogic (Fantasy)
+ (void)setFeedFantasyLocalSettings:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedFantasyLocalSettings];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)fantasyCountDownEnable
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    
    BOOL res = NO;
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedFantasyLocalSettings];
    if ([info[@"count_down_enable"] integerValue] == 1) {
        res = YES;
    }
    
    return res;
}

+ (BOOL)fantasyWindowResizeable
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    
    BOOL res = NO;
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedFantasyLocalSettings];
    if ([info[@"fantasy_window_resize_enable"] integerValue] == 1) {
        res = YES;
    }
    
    return res;
}

+ (BOOL)fantasyWindowAlwaysResizeable
{
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    
    BOOL res = NO;
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedFantasyLocalSettings];
    if ([info[@"fantasy_window_always_resize_enable"] integerValue] == 1) {
        res = YES;
    }
    
    return res;
}
@end

static NSString *const kTTFeedTipsShowStrategy = @"tt_feed_tips_show_strategy";
@implementation SSCommonLogic (FeedTipsShowStrategy)
+ (void)setFeedTipsShowStrategyDict:(NSDictionary *)dict{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedTipsShowStrategy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)feedTipsShowStrategyEnable{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedTipsShowStrategy];
    BOOL res = NO;
    if (info && [info[@"enable"] integerValue] == 1 && ([info[@"type"] integerValue] == 0 || [info[@"type"] integerValue] == 1)) {
        res = YES;
    }
    
    return res;
}

+ (NSInteger)feedTipsShowStrategyType{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedTipsShowStrategy];
    NSInteger res = 0;
    if ([info[@"enable"] integerValue] == 1 && info[@"type"]) {
        res = [info[@"type"] integerValue];
    }
    
    return res;
}

+ (NSInteger)feedTipsShowStrategyColor{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedTipsShowStrategy];
    NSInteger res = 0;
    if ([info[@"enable"] integerValue] == 1 && info[@"color"]) {
        res = [info[@"color"] integerValue];
    }
    
    return res;
}
@end

static NSString *const kTTFeedRefreshStrategy = @"tt_feed_refresh_settings";
static NSString *const kTTFeedRefreshHistoryStrategy = @"tt_feed_refresh_history_settings";
@implementation SSCommonLogic (FeedRefreshStrategy)
+ (void)setFeedRefreshStrategyDict:(NSDictionary *)dict{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedRefreshStrategy];
    if (dict[@"refresh_history_notify_count"]) {
        NSInteger count = [dict[@"refresh_history_notify_count"] integerValue];
        [[NSUserDefaults standardUserDefaults] setValue:@(count) forKey:kTTFeedRefreshHistoryStrategy];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)showRefreshHistoryTip
{
    NSNumber *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedRefreshHistoryStrategy];
    if (info && [info isKindOfClass:[NSNumber class]]) {
        NSInteger value = [info integerValue];
        if (value > 0) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)updateRefreshHistoryTip
{
    NSNumber *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedRefreshHistoryStrategy];
    if (info && [info isKindOfClass:[NSNumber class]]) {
        NSInteger value = [info integerValue];
        if (value > 0) {
            [[NSUserDefaults standardUserDefaults] setValue:@(value - 1) forKey:kTTFeedRefreshHistoryStrategy];
        }
    }
}

+ (BOOL)feedLoadingInitImageEnable
{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedRefreshStrategy];
    BOOL res = NO;
    if (info && [info[@"is_place_holder_show"] integerValue] == 1) {
        res = YES;
    }
    
    return res;
}
@end

static NSString *const kTTDetailPushTipsEnable = @"tt_detail_push_tips_enable";
@implementation SSCommonLogic (PushTipsEnable)
+ (void)setDetailPushTipsEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTDetailPushTipsEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)detailPushTipsEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTDetailPushTipsEnable];
}
@end

static NSString *const kTTFeedAutoInsertEnable = @"tt_feed_auto_insert_setting";
@implementation SSCommonLogic (FeedAutoInsertEnable)
+ (void)setFeedAutoInsertDict:(NSDictionary *)dict;
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kTTFeedAutoInsertEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)feedAutoInsertEnable{
    NSDictionary *res = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedAutoInsertEnable];
    
    if (!res) {
        return NO;
    }
    
    NSInteger times = 0;
    if (res[@"max_count"]) {
        times = [res[@"max_count"] integerValue];
    }
    
    NSTimeInterval timeinterval = 0.0;
    if (res[@"auto_insert_interval"]) {
        timeinterval = [res[@"auto_insert_interval"] doubleValue];
    }
    
    if (times > 0 && timeinterval > 0.01) {
        return YES;
    }
    
    return NO;
}

+ (NSInteger)feedAutoInsertTimes
{
    NSDictionary *res = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedAutoInsertEnable];
    NSInteger times = 0;
    if (res[@"max_count"]) {
        times = [res[@"max_count"] integerValue];
    }
    
    return times;
}

+ (NSTimeInterval)feedAutoInsertTimeInterval
{
    NSDictionary *res = [[NSUserDefaults standardUserDefaults] valueForKey:kTTFeedAutoInsertEnable];
    NSTimeInterval timeinterval = 0.0;
    if (res[@"auto_insert_interval"]) {
        timeinterval = [res[@"auto_insert_interval"] doubleValue];
    }
    
    return timeinterval;
}
@end

@implementation SSCommonLogic (RepeatedAd)

+ (void)setRepeatedAdDisable:(BOOL)disable {
    [[NSUserDefaults standardUserDefaults] setBool:disable forKey:@"tt_repeated_ad_disable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL)isRepeatedAdDisable {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tt_repeated_ad_disable"];
}
@end

static NSString *const SSCommonLogicIMCommunicateStrategy = @"SSCommonLogicIMCommunicateStrategy";
@implementation SSCommonLogic (IMCommunicateStrategy)

+ (void)setimCommunicateStrategy:(NSInteger)imCommunicateStrategy{
    [[NSUserDefaults standardUserDefaults] setInteger:imCommunicateStrategy forKey:SSCommonLogicIMCommunicateStrategy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)imCommunicateStrategy{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SSCommonLogicIMCommunicateStrategy]) {
        NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:SSCommonLogicIMCommunicateStrategy];
        if (style < 1 || style > 2) {
            return 0;
        }
        else {
            return style;
        }
    }
    else {
        return 0;
    }
}
@end

@implementation SSCommonLogic (LoginDialogStrategy)
+ (void)setAppBootEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"tt_boot_login_dialog_strategy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)appBootEnable
{
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_boot_login_dialog_strategy"];
}

+ (void)setDislikeEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"tt_dislike_login_dialog_strategy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)dislikeEnable
{
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_dislike_login_dialog_strategy"];
}

@end

static NSString *const SSCommonMiniProgramID = @"SSCommonMiniProgramID";
static NSString *const SSCommonMiniProgramPathTemplate = @"SSCommonMiniProgramPathTemplate";
@implementation SSCommonLogic (MiniProgramShare)

+ (NSString *)miniProgramID{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SSCommonMiniProgramID];
}

+ (void)setMiniProgramID:(NSString *)ID{
    [[NSUserDefaults standardUserDefaults] setObject:ID forKey:SSCommonMiniProgramID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)miniProgramPathTemplate{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SSCommonMiniProgramPathTemplate];
}

+ (void)setMiniProgramPathTemplate:(NSString *)pathTemplate{
    [[NSUserDefaults standardUserDefaults] setObject:pathTemplate forKey:SSCommonMiniProgramPathTemplate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static NSString *const kTTOpenInSafariWindow = @"tt_openinsafari_setting";
@implementation SSCommonLogic (OpenInSafariWindow)

+ (void)setOpenInSafariWindowEnable:(BOOL)Enable{
    [[NSUserDefaults standardUserDefaults] setBool:Enable forKey:kTTOpenInSafariWindow];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)openInSafariWindowEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTOpenInSafariWindow];
}

@end

static NSString *const kTTThreeTopBarKey = @"ThreeTopBar";
@implementation SSCommonLogic (ThreeTopBar)
+ (void)setThreeTopBarEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTThreeTopBarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)threeTopBarEnable{
    
    static BOOL threeTopBarEnable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //是否前三个tab都有搜索框
        threeTopBarEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTTThreeTopBarKey];
    });
    return threeTopBarEnable;
}
@end

@implementation SSCommonLogic (CommonParameter)
+ (void)setCommonParameterWithValue:(NSString *)value index:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"SSDebugCommonParameter%ld",index];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)commonParameterValueWithIndex:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"SSDebugCommonParameter%ld",index];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (isEmptyString(value)){
        value = @"0";
    }
    return value;
}

+ (void)setCommonParameterNameWithName:(NSString *)name index:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"SSDebugCommonParameterName%ld",index];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)commonParameterNameWithIndex:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"SSDebugCommonParameterName%ld",index];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (isEmptyString(name)){
        name = @"未启用";
    }
    return name;
}
@end

static NSString *const KTTVideoDetailRelatedStyle = @"tt_video_detail_relate_style";
@implementation SSCommonLogic (VideoDetailRelatedStyle)
+ (void)setVideoDetailRelatedStyle:(NSInteger)style {
    
    [[NSUserDefaults standardUserDefaults] setInteger:style forKey:KTTVideoDetailRelatedStyle];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSInteger)videoDetailRelatedStyle {
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:KTTVideoDetailRelatedStyle];
}
@end

static NSString *const kSSCommonLogicAutoUploadContactsIntervalKey = @"kSSCommonLogicAutoUploadContactsIntervalKey";
@implementation SSCommonLogic (AutoUploadContacts)
+ (void)setAutoUploadContactsInterval:(NSNumber *)interval {
    if (![interval isKindOfClass:[NSNumber class]]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:interval forKey:kSSCommonLogicAutoUploadContactsIntervalKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSNumber *)autoUploadContactsInterval {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicAutoUploadContactsIntervalKey];
}
@end


static NSString *const kSSCommonLogicShortVideoDetailScrollDirectionKey = @"kSSCommonLogicShortVideoDetailScrollDirectionKey";
@implementation SSCommonLogic (ShortVideoScrollDirection)
+(void)setShortVideoScrollDirection:(NSNumber *)direction {
    [[NSUserDefaults standardUserDefaults] setObject:direction forKey:kSSCommonLogicShortVideoDetailScrollDirectionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSNumber *)shortVideoScrollDirection {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicShortVideoDetailScrollDirectionKey];
}
@end

static NSString *const kSSCommonLogicShortVideoFirstUsePromptTypeKey = @"kSSCommonLogicShortVideoFirstUsePromptTypeKey";
@implementation SSCommonLogic (ShortVideoFirstUsePromptType)
+(void)setShortVideoFirstUsePromptType:(NSNumber *)direction {
    [[NSUserDefaults standardUserDefaults] setObject:direction forKey:kSSCommonLogicShortVideoFirstUsePromptTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSNumber *)shortVideoFirstUsePromptType {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicShortVideoFirstUsePromptTypeKey];
}
@end

static NSString *const kSSCommonLogicShortVideoDetailInfiniteScrollEnableKey = @"kSSCommonLogicShortVideoDetailInfiniteScrollEnableKey";
@implementation SSCommonLogic (ShortVideoDetailInfiniteScrollEnable)
+(void)setShortVideoDetailInfiniteScrollEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicShortVideoDetailInfiniteScrollEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(BOOL)shortVideoDetailInfiniteScrollEnable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicShortVideoDetailInfiniteScrollEnableKey];
}
@end

static NSString *const kTTMonitorMemoryWarningViewHierarchy = @"kTTMonitorMemoryWarningViewHierarchy";
@implementation SSCommonLogic (MemoryWarningHierarchy)
+ (void)setShouldMonitorMemoryWarningHierarchy:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTMonitorMemoryWarningViewHierarchy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldMonitorMemoryWarningHierarchy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTMonitorMemoryWarningViewHierarchy];
}
@end

@implementation SSCommonLogic (pushSDK)

+ (void)setPushSDKEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"tt_push_sdk_upload_enable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)pushSDKEnable
{
//    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_push_sdk_upload_enable"];
    return YES;
}
@end

@implementation SSCommonLogic (commonweal)

+ (void)setCommonwealEntranceEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"tt_commonweal_enable_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)commonwealEntranceEnable
{
    static BOOL wealEnabled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wealEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_commonweal_enable_key"];
    });
    return wealEnabled;
}

+ (void)setCommonwealInfo:(NSDictionary *)dict
{
    BOOL entranceEnable = [[dict valueForKey:@"tt_commonweal_enable"] integerValue];
    [self setCommonwealEntranceEnable:entranceEnable];
    
    NSString *tips = [dict valueForKey:@"tt_commonweal_tips"];
    [self setCommonwealTips:tips];
    
    int64_t time = [[dict valueForKey:@"tt_commonweal_show_tips_time"] longLongValue];
    [self setCommonwealDefaultShowTipTime:time];
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"tt_commonweal_info_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)commonwealInfo
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_info_key"];
}

+ (void)setCommonwealDefaultShowTipTime:(int64_t)time
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:time] forKey:@"tt_commonweal_show_tips_time_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int64_t)commonwealDefaultShowTipTime
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_show_tips_time_key"] longLongValue];
}

+ (void)setCommonwealTips:(NSString *)tips
{
    [[NSUserDefaults standardUserDefaults] setObject:tips forKey:@"tt_commonweal_tips_key"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSString *)commonwealTips
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_tips_key"];
}

@end

@implementation SSCommonLogic (InhouseSetting)

+ (void)setInHouseSetting:(NSDictionary *)settings
{
    [[SSInHouseFeatureManager defaultManager] resetServerDiskCacheWithSettings:settings];
}

+ (BOOL)isLoginPlatformPhoneOnly
{
    return SSInHouseFeatureManager.feature.login_phone_only;
}

+ (BOOL)isQuickFeedbackGateShow
{
    return SSInHouseFeatureManager.feature.show_quick_feedback_gate;
}

@end
static NSString *const kTTSSCommonLogicMultiDiggEnableKey = @"kTTSSCommonLogicMultiDiggEnableKey";
@implementation SSCommonLogic (MultiDigg)

+ (void)setMultiDiggEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTSSCommonLogicMultiDiggEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)multiDiggEnable
{
    static BOOL multiDiggEnable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        multiDiggEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTTSSCommonLogicMultiDiggEnableKey];
    });
    return multiDiggEnable;
}
@end

static NSString *const kTTSSCommonLogicLocalImageTrackerEnableKey = @"kTTSSCommonLogicLocalImageTrackerEnableKey";
@implementation SSCommonLogic (LocalImageTracker)

+ (BOOL)shouldTrackLocalImage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTSSCommonLogicLocalImageTrackerEnableKey];
}

+ (void)setShouldTrackLocalImage:(BOOL)shouldTrack {
    [[NSUserDefaults standardUserDefaults] setBool:shouldTrack forKey:kTTSSCommonLogicLocalImageTrackerEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static NSString *const kSSCommonLogicNavBarShowFansNumEnableKey = @"kSSCommonLogicNavBarShowFansNumEnableKey";
static NSString *const kSSCommonLogicNavBarShowFansMinNumKey = @"kSSCommonLogicNavBarShowFansMinNumKey";
@implementation SSCommonLogic (NavBarShowFansNum)

+ (BOOL)articleNavBarShowFansNumEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicNavBarShowFansNumEnableKey];
}
+ (void)setArticleNavBarShowFansNumEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicNavBarShowFansNumEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSInteger)navBarShowFansMinNum
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicNavBarShowFansMinNumKey]){
        return [[NSUserDefaults standardUserDefaults] integerForKey:kSSCommonLogicNavBarShowFansMinNumKey];
    }
    return 1;
}
+ (void)setNavBarShowFansMinNum:(NSInteger)minNum
{
    [[NSUserDefaults standardUserDefaults] setInteger:minNum forKey:kSSCommonLogicNavBarShowFansMinNumKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end


static NSString *const kSSCommonLogicRecorderVideoMaxLengthKey = @"kSSCommonLogicRecorderVideoMaxLengthKey";
@implementation SSCommonLogic (TTRecordVideoLength)

+ (NSTimeInterval)recorderMaxLength {
    //return 120.0f;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicRecorderVideoMaxLengthKey]) {
        return [[NSUserDefaults standardUserDefaults] doubleForKey:kSSCommonLogicRecorderVideoMaxLengthKey];
    }
    return 30.0f;
}

+ (void)setRecorderMaxLength:(NSTimeInterval)maxLength {
    [[NSUserDefaults standardUserDefaults] setDouble:maxLength forKey:kSSCommonLogicRecorderVideoMaxLengthKey];
}

@end

static NSString * const kSSCommonLogicChatroomVideoLiveSDKEnableKey = @"kSSCommonLogicChatroomVideoLiveSDKEnableKey";
@implementation SSCommonLogic (ChatroomVideoLiveSDK)

+ (void)setChatroomVideoLiveSDKEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicChatroomVideoLiveSDKEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)chatroomVideoLiveSDKEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicChatroomVideoLiveSDKEnableKey];
}

@end

static NSString * const kSSCommonLogicSensetimeLicenceURLKey = @"kSSCommonLogicSensetimeLicenceURLKey";
static NSString * const kSSCommonLogicSensetimeLicenceMd5Key = @"kSSCommonLogicSensetimeLicenceMd5Key";
@implementation SSCommonLogic (TTSensetimeLicenceURL)

+ (NSString *)sensetimeLicenceURL {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicSensetimeLicenceURLKey]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:kSSCommonLogicSensetimeLicenceURLKey];
    }
    return nil;
}

+ (NSString *)sensetimeLicenceMd5 {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicSensetimeLicenceMd5Key]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:kSSCommonLogicSensetimeLicenceMd5Key];
    }
    return nil;
}

+ (void)setSensetimeLicenceURL:(NSString *)url {
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:kSSCommonLogicSensetimeLicenceURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setSensetimeLicenceMd5:(NSString *)md5 {
    [[NSUserDefaults standardUserDefaults] setObject:md5 forKey:kSSCommonLogicSensetimeLicenceMd5Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

static NSString * const kSSCommonLogicArticleShareWithPGCNameEnableKey = @"kSSCommonLogicArticleShareWithPGCNameEnableKey";
@implementation SSCommonLogic (ArticleShareWithPGCName)

+ (void)setArticleShareWithPGCName:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kSSCommonLogicArticleShareWithPGCNameEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)shouldArticleShareWithPGCName
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSSCommonLogicArticleShareWithPGCNameEnableKey]){
        return [[NSUserDefaults standardUserDefaults] boolForKey:kSSCommonLogicArticleShareWithPGCNameEnableKey];
    }
    return 1;
}

@end

static NSString *const kTTCommonLoigcArticleTitleLogoSettingsKey = @"tt_enable_detail_title_logo";
@implementation SSCommonLogic (ArticleTitleLogoSettings)
+ (void)setArticleTitleLogoEnbale:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTCommonLoigcArticleTitleLogoSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)articleTitleLogoEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTCommonLoigcArticleTitleLogoSettingsKey];
}
@end

static NSString *const kTTSearchCancelClickActionChange = @"tt_search_cancel_click_action_change_enable";
@implementation SSCommonLogic (SearchCancelClickActionChange)
+ (void)setSearchCancelClickActionChangeEnable:(BOOL)enable{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTSearchCancelClickActionChange];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)searchCancelClickActionChangeEnable{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTSearchCancelClickActionChange];
}
@end


static NSString *const kTTFeedDisableGetLocalDataSettingsKey = @"kTTFeedGetLocalDataSettingsKey";
static NSString *const kTTFeedClearLocalCacheSettingsKey = @"kTTFeedClearLocalCacheSettingsKey";
@implementation SSCommonLogic (FeedGetLocalDataSettings)
+ (void)setGetLocalDataDisable:(BOOL)disable
{
    [[NSUserDefaults standardUserDefaults] setBool:disable forKey:kTTFeedDisableGetLocalDataSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)disableGetLocalData
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTFeedDisableGetLocalDataSettingsKey];
}

+ (NSArray *)clearLocalFeedDataList
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTTFeedClearLocalCacheSettingsKey];
}

+ (void)setClearLocalFeedDataList:(NSArray *)list
{
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:kTTFeedClearLocalCacheSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

static NSString * const kTTHomePageAddAuthSettingsKey = @"kTTHomePageAddAuthSettingsKey";
static NSString * const kTTHomePageAddVSettingsKey = @"kTTHomePageAddVSettingsKey";
@implementation SSCommonLogic (TTHomeAuthControl)

+ (void)setHomePageAddAuthSettings:(NSDictionary *)settings
{
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:kTTHomePageAddAuthSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)HomePageAddAuthSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTHomePageAddAuthSettingsKey]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTHomePageAddAuthSettingsKey];
    } else {
        return nil;
    }
}

+ (void)setHomePageAddVSettings:(NSDictionary *)settings
{
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:kTTHomePageAddVSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)HomePageAddVSettings
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTTHomePageAddVSettingsKey]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTHomePageAddVSettingsKey];
    } else {
        return nil;
    }
}
@end

//频道下发配置
static NSString *const kTTHomeTabMainCategoryNameKey = @"kTTHomeTabMainCategoryNameKey";
static NSString *const kTTVideoTabMainCategoryNameKey = @"kTTVideoTabMainCategoryNameKey";
@implementation SSCommonLogic (CategoryConfig)

+ (void)setCategoryNameConfigDict:(NSDictionary *)dict{
    if ([dict tt_stringValueForKey:kTTMainCategoryID]) {
        [SSCommonLogic setHomeTabMainCategoryName:[dict tt_stringValueForKey:kTTMainCategoryID]];
        return;
    }
    
    [SSCommonLogic setHomeTabMainCategoryName:[dict tt_stringValueForKey:@"stream_category_all"]];
    [SSCommonLogic setVideoTabMainCategoryName:[dict tt_stringValueForKey:@"video_category_all"]];
}

//首页推荐名称
+ (void)setHomeTabMainCategoryName:(NSString *)name{
    [[NSUserDefaults standardUserDefaults] setValue:name forKey:kTTHomeTabMainCategoryNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)homeTabMainCategoryName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTHomeTabMainCategoryNameKey];
}

+ (void)setVideoTabMainCategoryName:(NSString *)name{
    [[NSUserDefaults standardUserDefaults] setValue:name forKey:kTTVideoTabMainCategoryNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)videoTabMainCategoryName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTVideoTabMainCategoryNameKey];
}
@end

// 微信老share接口回调配置
static NSString *const kTTEnableWXShareCallbackKey = @"kTTEnableWXShareCallbackKey";
@implementation SSCommonLogic (WXShareConfig)
+ (void)setEnableWXShareCallback:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kTTEnableWXShareCallbackKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enableWXShareCallback
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTEnableWXShareCallbackKey];
}
@end


//f_settings配置 add by zjing

static NSString *const kFHSettingsKey = @"kFHSettingsKey";

@implementation SSCommonLogic (FHSettings)
+ (void)setFHSettings:(NSDictionary *)fhSettings {
    
    [[NSUserDefaults standardUserDefaults] setObject:fhSettings forKey:kFHSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFHSettingsKey]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kFHSettingsKey];
    } else {
        return nil;
    }
}

+ (BOOL)wendaShareEnable {
    NSDictionary *fhSettings = [self fhSettings];
    return [fhSettings tta_boolForKey:@"f_wenda_share_enable"];
}

+ (NSInteger)configSwitchTimeDaysCount
{
    NSDictionary *fhSettings = [self fhSettings];
    NSInteger settingSwitchTime = [fhSettings tt_integerValueForKey:@"f_switch_city_time"];
    return settingSwitchTime;
}

+ (NSInteger)configEditProfileEntry
{
    NSDictionary *fhSettings = [self fhSettings];
    NSInteger settingSwitchTime = [fhSettings tt_integerValueForKey:@"f_is_show_profile_edit_entry"];
    return settingSwitchTime;
}

+ (NSInteger)findTabShowHouse {
    
    NSDictionary *fhSettings = [self fhSettings];
    return [fhSettings tt_intValueForKey:@"find_tab_show_house"];
}

+ (NSInteger)categoryBadgeTimeInterval
{
    NSDictionary *fhSettings = [self fhSettings];
    NSInteger timeInterval = [[fhSettings tta_stringForKey:@"f_category_tip_refresh_interval"] integerValue] / 1000; //配置已毫秒计算
    if (timeInterval > 1) {
        return timeInterval;
    }else
    {
        return 60;
    }
}

static NSString *const kFFeedRefreshStrategy = @"feed_refresh_settings";

+ (BOOL)feedLoadMoreWithNewData
{
    NSDictionary *info = [[self fhSettings] valueForKey:kFFeedRefreshStrategy];
    BOOL res = NO;
    if (info && [info[@"load_more_new_data"] integerValue] == 1) {
        res = YES;
    }
    
    return res;
}

+ (BOOL)feedLastReadCellShowEnable{
    NSDictionary *info = [[self fhSettings] valueForKey:kFFeedRefreshStrategy];
    BOOL res = YES;
    if (info && [info.allKeys containsObject:@"is_show_last_read_docker"] && [info[@"is_show_last_read_docker"] integerValue] == 0) {
        res = NO;
    }
    
    if (info && [info[@"refresh_clear_all_enable"] integerValue] == 1) {
        res = NO;
    }
    
    return res;
}

+ (BOOL)feedRefreshClearAllEnable
{
    NSDictionary *info = [[self fhSettings] valueForKey:kFFeedRefreshStrategy];
    BOOL res = NO;
    if (info && [info[@"refresh_clear_all_enable"] integerValue] == 1) {
        res = YES;
    }
    
    return res;
}

+ (BOOL)imCanStart
{
    NSDictionary *fhSettings = [self fhSettings];
    if (fhSettings != nil && [fhSettings objectForKey:@"f_im_open"] != nil) {
        NSInteger info = [[fhSettings objectForKey:@"f_im_open"] integerValue];
        if (info == 0) {
            return NO;
        }
    }
    return YES;
}

@end



#endif

