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

- (NSString *)appId {
    return [[TTInstallIDManager sharedInstance] appID];
}

- (NSString *)deviceId {
    return [[TTInstallIDManager sharedInstance] deviceID];
}

- (void)onMessageRecieved:(ChatMsg *)msg {
    [[FHBubbleTipManager shareInstance] tryShowBubbleTip:msg openUrl:@""];
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
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:param  method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        if (!error) {
            NSString *number = @"";
            NSString *serverImprId = imprId;
            @try {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *jsonObj = (NSDictionary *)obj;
                    NSDictionary *data = [jsonObj objectForKey:@"data"];
                    number = data[@"virtual_number"];
                    serverImprId = data[@"impr_id"] ?: @"be_null";
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
        }
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
