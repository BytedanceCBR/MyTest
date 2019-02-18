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

@interface FHIMConfigDelegateImpl : NSObject<FHIMConfigDelegate>

@end

@implementation FHIMConfigDelegateImpl

- (ClientType)getClientType {
    return ClientTypeB;
}

- (ThemeType)getThemeType {
    return ClientBTheme;
}

- (UIColor *)getChatBubbleColor {
    return [UIColor themeBlue];
}

- (UIColor *)getChatNewTipColor {
    return [UIColor themeRed];
}

- (UIColor *)getChatTipTxtColor {
    return [UIColor themeBlue];
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
