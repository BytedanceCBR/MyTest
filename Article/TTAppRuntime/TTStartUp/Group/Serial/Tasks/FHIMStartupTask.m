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
    return [[TTAccount sharedAccount] sessionKey];
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

- (void)tryGetPhoneNumber:(nonnull NSString *)userId withImprId:(nonnull NSString *)imprId withBlock:(nullable PhoneCallback)finishBlock{
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/virtual_number"];
    NSDictionary *param = @{
                            @"realtor_id":userId,
                            @"impr_id": imprId
                            };
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:param  method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        if (!error) {
            NSString *number = @"";
            NSString *serverImprId = imprId;
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonObj = (NSDictionary *)obj;
                NSDictionary *data = [jsonObj objectForKey:@"data"];
                number = data[@"virtual_number"];
                serverImprId = data[@"impr_id"] ?: @"be_null";
            }
            NSString *phone = @"";
            BOOL isAssociate = NO;
            phone = [number stringByReplacingOccurrencesOfString:@"" withString:@""];
            isAssociate = YES;
            
            finishBlock(@"click_call", serverImprId);
            NSString *phoneUrl = [NSString stringWithFormat:@"telprompt://%@",phone];
            NSURL *url = [NSURL URLWithString:phoneUrl];
            [[UIApplication sharedApplication] openURL:url];
        } else {
            finishBlock(@"click_call", imprId);
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
    NSLog(@"startup IM");
    FHIMAccountCenterImpl* accountCenter = [[FHIMAccountCenterImpl alloc] init];
    [IMManager shareInstance].accountCenter = accountCenter;

    FHIMConfigDelegateImpl* delegate = [[FHIMConfigDelegateImpl alloc] init];
    [[FHIMConfigManager shareInstance] registerDelegate:delegate];

    NSString* uid = [[TTAccount sharedAccount] userIdString];
    [[IMManager shareInstance] startupWithUid:uid];
}

#pragma mark - 打开Watch Session

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {

}

@end
