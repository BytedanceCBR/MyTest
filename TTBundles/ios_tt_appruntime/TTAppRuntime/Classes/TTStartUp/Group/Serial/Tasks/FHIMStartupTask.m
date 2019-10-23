//
//  FHIMStartupTask.m
//  Article
//
//  Created by leo on 2019/2/17.
//

#import "FHIMStartupTask.h"
#import "IMManager.h"
#import "FHIMConfigManager.h"
#import "TTCookieManager.h"
#import "FHUploaderManager.h"
#import "UIColor+Theme.h"
#import "TTAccount.h"
#import "TTInstallIDManager.h"
#import "FHIMAccountCenterImpl.h"
#import "FHBubbleTipManager.h"
#import "FHURLSettings.h"
#import <TTNetworkManager.h>
#import <FHEnvContext.h>
#import "ToastManager.h"
#import <TTArticleBase/SSCommonLogic.h>
#import <Heimdallr/HMDTTMonitor.h>
#import "FHIMAlertViewListenerImpl.h"
#import "TTLaunchDefine.h"
#import <FHHouseBase/FHMainApi+Contact.h>
#import <TTReachability/TTReachability.h>
#import <TTSandBoxHelper.h>

DEC_TASK("FHIMStartupTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+16);

@interface FHIMConfigDelegateImpl : NSObject<FHIMConfigDelegate>

@end

@implementation FHIMConfigDelegateImpl

- (ClientType)getClientType {
    return ClientTypeC;
}

- (ThemeType)getThemeType {
    return ClientCTheme;
}

- (UIColor *)getChatBubbleColor {
    return [UIColor themeIMBubbleRed];
}

- (UIColor *)getChatNewTipColor {
    return [UIColor themeIMOrange];
}

- (UIColor *)getChatTipTxtColor {
    return [UIColor themeIMBubbleRed];
}

- (UIColor *)getDefaultTxtColor {
   return [UIColor colorWithHexString:@"999999"];
}

- (NSArray<NSHTTPCookie *>*)getClientCookie {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    return cookies;
}

- (NSString *)sessionId {
    return [[TTAccount sharedAccount] sessionKey] ?: @"";
}

- (void)registerTTRoute {

}

- (BOOL)isBOE {
    if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults]boolForKey:@"BOE_OPEN_KEY"]) {
        return YES;
    }
    return NO;
}

- (NSString *)appId {
    return [[TTInstallIDManager sharedInstance] appID];
}

- (NSString *)deviceId {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (BOOL)isBOE {
    
    if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults]boolForKey:@"BOE_OPEN_KEY"]) {
        return YES;
    }
    return NO;
}

- (void)onMessageRecieved:(ChatMsg *)msg {
    [[FHBubbleTipManager shareInstance] tryShowBubbleTip:msg openUrl:@""];
}

- (NSString *)appVersionCode {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
}

- (void)tryGetPhoneNumber:(nonnull NSString *)userId withImprId:(nonnull NSString *)imprId tracer:(nonnull NSDictionary *)tracer withBlock:(nullable PhoneCallback)finishBlock{
    if (isEmptyString(userId)) {
        finishBlock(@"click_call", imprId,true);
        [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_EMPTY_UID extra:@{@"client_type":@"client_c"}];
        return;
    }
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/virtual_number"];
    NSDictionary *param = @{
                            @"realtor_id":userId,
                            @"enterfrom":@"app_chat",
                            @"impr_id": imprId ? : @"be_null"
                            };
    NSMutableDictionary *monitorParams = [NSMutableDictionary dictionaryWithDictionary:param];
    [monitorParams setValue:@"client_c" forKey:@"client_type"];

    [[TTNetworkManager shareInstance] requestForJSONWithResponse:url params:param  method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        
        NSMutableDictionary *categoryDict = @{}.mutableCopy;
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        if (![TTReachability isNetworkConnected]) {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
        }
        NSString *status = @"";
        NSString *message = @"";

        if (!error) {
            NSString *number = @"";
            NSString *serverImprId = imprId;
  
            @try {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *jsonObj = (NSDictionary *)obj;
                    NSDictionary *data = [jsonObj objectForKey:@"data"];
                    number = data[@"virtual_number"];
                    serverImprId = data[@"impr_id"] ?: @"be_null";
                    status = [jsonObj tta_stringForKey:@"status"];
                    message = [jsonObj tta_stringForKey:@"message"];
                }
            }
            @catch(NSException *e) {
                error = [NSError errorWithDomain:e.reason code:1000 userInfo:e.userInfo ];
                [monitorParams setValue:error forKey:@"json_error"];
                [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_JSON_ERROR extra:monitorParams];
            }
            
            NSString *phone = @"";
            BOOL isAssociate = NO;
            phone = [number stringByReplacingOccurrencesOfString:@"" withString:@""];
            isAssociate = YES;
            
            finishBlock(@"click_call", serverImprId,true);
            if (phone.length == 0) {
                [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_NUMBER_EMPTY extra:monitorParams];
                [[ToastManager manager] showToast:@"获取电话号码失败"];
                return;
            }
            
            if ([@"be_null" isEqualToString:serverImprId]) {
                [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_EMPTY_IMPRID extra:monitorParams];
            }
            
            NSString *phoneUrl = [NSString stringWithFormat:@"telprompt://%@",phone];
            NSURL *url = [NSURL URLWithString:phoneUrl];
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[ToastManager manager] showToast:@"网络异常，请稍后重试!"];
            [monitorParams setValue:error forKey:@"server_error"];
            [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_SERVER_ERROR extra:monitorParams];
            finishBlock(@"click_call", imprId,true);
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonObj = (NSDictionary *)obj;
                NSDictionary *data = [jsonObj objectForKey:@"data"];
                status = [jsonObj tta_stringForKey:@"status"];
                message = [jsonObj tta_stringForKey:@"message"];
            }
        }
        
        if (response.statusCode == 200) {
            if (status.length > 0) {
                if (status.integerValue != 0 || error != nil) {
                    if (status) {
                        extraDict[@"error_code"] = status;
                    }
                    extraDict[@"message"] = message.length > 0 ? message : error.domain;
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                    extraDict[@"request_url"] = response.URL.absoluteString;
                    extraDict[@"response_headers"] = response.allHeaderFields;
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                }
            }
        }else {
            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
            extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
        }
        [[self class] addClueCallErrorRateLog:categoryDict extraDict:extraDict];
    }];
}

- (NSString *)hostStr {
    NSString *host = [FHURLSettings baseURL];
    return host;
}

- (NSString *)cityId {
    return [FHEnvContext getCurrentSelectCityIdFromLocal];
}

- (void)gotoSelectHouse:(nonnull NSString *)covid {
    
}

+ (void)addClueCallErrorRateLog:categoryDict extraDict:(NSDictionary *)extraDict
{
    [[HMDTTMonitor defaultManager]hmdTrackService:@"clue_call_error_rate" metric:nil category:categoryDict extra:extraDict];
}

@end

@implementation FHIMStartupTask
- (NSString *)taskIdentifier {
    return @"FHIMStartupTask";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {    
    if ([SSCommonLogic imCanStart]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            FHIMAccountCenterImpl* accountCenter = [[FHIMAccountCenterImpl alloc] init];
            [IMManager shareInstance].accountCenter = accountCenter;

            FHIMConfigDelegateImpl* delegate = [[FHIMConfigDelegateImpl alloc] init];
            [[FHIMConfigManager shareInstance] registerDelegate:delegate];

            NSString* uid = [[TTAccount sharedAccount] userIdString];
            [[IMManager shareInstance] startupWithUid:uid];
            [IMManager shareInstance].imAlertViewListener = [FHIMAlertViewListenerImpl shareInstance];
        });
    }
}

#pragma mark - 打开Watch Session

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {

}

@end
