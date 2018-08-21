//
//  TTPushMsgUserGuideManger.m
//  Article
//
//  Created by zuopengliu on 26/11/2017.
//

#import "TTPushMsgUserGuideManger.h"
#import <Bytedancebase/BDSDKApi+CompanyProduct.h>
#import <Bytedancebase/BDSDKApiObject+CompanyProduct.h>
#import <TTURLUtils.h>
#import <TTAccount+PlatformAuthLogin.h>
#import <TTThemedAlertController.h>



@implementation TTPushMsgUserGuideManger

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTMessageCenterRouter registerRouter:(id<TTMessageRouteProtocol>)self];
    });
}

+ (void)handlePushMsgGuide:(NSDictionary *)msgDict
{
    // Parse `msgDict` to get data
    NSString *productName  = msgDict[@"app_name"];
    NSInteger platformType = [self.class platformTypeFromBDProductName:productName];
    NSString *productInstallUrl = msgDict[@"app_install_url"];
    NSString *downloadText = msgDict[@"download_text"];
    NSString *appOpenUrlString = msgDict[@"app_open_url"];
    NSString *supportedScheme  = msgDict[@"app_support_scheme"];
    
    if (!downloadText) {
        NSString *displayPlatformName = [TTAccount localizedDisplayNameForPlatform:platformType];
        downloadText = [NSString stringWithFormat:@"下载%@，发现更多有趣内容", displayPlatformName];
    }
    
    NSCAssert(appOpenUrlString, @"APP openurl不能为空");
    
    if (![TTAccount isAppInstalledForPlatform:platformType]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:downloadText preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", @"取消") actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:NSLocalizedString(@"去下载", @"去下载") actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [self.class openAppStore:productInstallUrl forPlatform:platformType];
        }];
        [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
        return;
    } else if (supportedScheme.length > 0 && ![self.class canOpenURLSchemes:@[supportedScheme]]) {
        // 引导APP升级
        NSString *updateAPPText = [downloadText stringByReplacingOccurrencesOfString:@"下载" withString:@"更新"];
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:updateAPPText preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", @"取消") actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:NSLocalizedString(@"去更新", @"去更新") actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [self.class openAppStore:productInstallUrl forPlatform:platformType];
        }];
        [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
        return;
    }
    
    NSURL *openURL = [NSURL URLWithString:appOpenUrlString];
    if (openURL && [[UIApplication sharedApplication] canOpenURL:openURL]) {
        [[UIApplication sharedApplication] openURL:openURL];
    }
}

#pragma mark - TTMessageRouteProtocol

+ (BOOL)canHandleOpenURL:(NSURL *)url
{
    if (!url) return NO;
    
    NSString *scheme = url.scheme;
    NSString *host = url.host;
    if (![scheme isEqualToString:@"sslocal"]) return NO;
    if (![host isEqualToString:@"user_activation"]) return NO;
    return YES;
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    if (![self.class canHandleOpenURL:url]) return NO;
    
    NSDictionary *msgData = [TTURLUtils queryItemsForURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.class handlePushMsgGuide:msgData];
    });
    
    return YES;
}

#pragma mark - helper

+ (NSInteger)productTypeFromProductName:(NSString *)productName
{
    if (!productName) return BDSDKProductTypeHuoshan;
    if ([productName isEqualToString:@"hotsoon"]) {
        return BDSDKProductTypeHuoshan;
    } else if ([productName isEqualToString:@"aweme"]) {
        return BDSDKProductTypeDouyin;
    }
    return BDSDKErrorCodeUnsupported;
}

+ (NSInteger)platformTypeFromBDProductName:(NSString *)productName
{
    NSInteger platformType = TTAccountAuthTypeUnsupport;
    NSInteger productType = [self.class productTypeFromProductName:productName];
    switch (productType) {
        case BDSDKProductTypeDouyin: {
            platformType = TTAccountAuthTypeDouyin;
        }
            break;
        case BDSDKProductTypeHuoshan: {
            platformType = TTAccountAuthTypeHuoshan;
        }
            break;
        default:
            break;
    }
    if (TTAccountAuthTypeUnsupport == platformType) {
        platformType = [TTAccount accountAuthTypeForPlatform:productName];
    }
    return platformType;
}

+ (void)openAppStore:(NSString *)appUrl forPlatform:(NSInteger)platformType
{
    NSString *appInstallUrlString = appUrl ? : [TTAccount getAppInstallUrlForPlatform:platformType];
    if (appInstallUrlString) {
        NSURL *appStoreURL = [NSURL URLWithString:appInstallUrlString];
        [[UIApplication sharedApplication] openURL:appStoreURL];
    } else {
        NSLog(@"app (%ld) install url is nil", (long)platformType);
    }
}

+ (BOOL)canOpenURLSchemes:(NSArray<NSString *> *)schemes
{
    if (!schemes || schemes.count == 0) return NO;
    
    __block BOOL canOpen = NO;
    [schemes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", obj]]]) {
            canOpen = YES;
            *stop = YES;
        }
    }];
    return canOpen;
}

@end
