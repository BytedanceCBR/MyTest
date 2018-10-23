//
//  SSActionManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-2-10.
//
//

#import "SSActionManager.h"
#import "SSAppStore.h"
#import "TTRoute.h"
#import "SSWebViewController.h"
#import "TTNavigationController.h"
#import "TTStringHelper.h"

#import "TTModuleBridge.h"
#import "TTAppLinkManager.h"
#import "TTAdConstant.h"
#import "TTNetworkManager.h"

static SSActionManager * shareManager;
@interface SSActionManager()

@end

@implementation SSActionManager

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TSVDownloadAPP" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        NSString *appleID = [((NSDictionary *)params) tt_stringValueForKey:@"app_appleid"];
        NSAssert(!isEmptyString(appleID), @"App ID is nil");

        NSString *trackURL = [((NSDictionary *)params) tt_stringValueForKey:@"download_track_url"];
        NSString *downloadURL = [((NSDictionary *)params) tt_stringValueForKey:@"download_url"];
        [[self class] trackURL:trackURL];
        [[self sharedManager] openDownloadURL:downloadURL appleID:appleID];
        return nil;
    }];
}

+ (SSActionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[SSActionManager alloc] init];
    });
    return shareManager;
}

+ (void)trackURL:(NSString *)urlString
{
    if (!isEmptyString(urlString)) {
        [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        }];
    }
}

- (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID
{
    [self openDownloadURL:downloadURL appleID:appleID appName:@""];
}


- (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID appName:(NSString *)appName
{
    if (appleID) {
        UIViewController *topViewController = [self getTopViewController];
        [[SSAppStore shareInstance] openAppStoreByActionURL:downloadURL itunesID:appleID presentController:topViewController appName:appName];
    } else {
        [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:downloadURL]];
    }
}

- (void)openWebURL:(NSString *)webURL appName:(NSString *)appName adID:(NSString *)adID logExtra:(NSString *)logExtra inNavigationController:(UINavigationController *)viewController {
    BOOL isSupportRotate = !isEmptyString(adID)? YES:NO;
    SSWebViewController *webViewController = [[SSWebViewController alloc] initWithSupportIPhoneRotate:isSupportRotate];
    webViewController.adID = adID;
    webViewController.logExtra = logExtra;
    webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    if (appName) {
        webViewController.titleText = appName;
    }
    [webViewController requestWithURLString:webURL];
    
    UIViewController *topViewController = viewController;
    if (!topViewController) {
        topViewController = [self getTopViewController];
    }
    
    if (topViewController) {
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)topViewController pushViewController:webViewController animated:YES];
        } else {
            TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:webViewController];
            nav.ttDefaultNavBarStyle = @"White";
            [topViewController presentViewController:nav animated:YES completion:nil];
        }
    }
}

- (void)openWebURL:(NSString *)webURL appName:(NSString *)appName adID:(NSString *)adID logExtra:(NSString *)logExtra {
    [self openWebURL:webURL appName:appName adID:adID logExtra:logExtra inNavigationController:nil];
}

- (void)openAppURL:(NSString *)appURL tabURL:(NSString *)tabURL adID:(NSString *)adID logExtra:(NSString *)logExtra {
    NSString *openURLStr = [NSString stringWithFormat:@"%@%@", appURL, tabURL];
    NSString *escapesBackURL = [TTAppLinkManager escapesBackURL:nil value:adID extraDic:nil];
    NSURL *openURL = [NSURL URLWithString:[openURLStr stringByReplacingOccurrencesOfString:kAppLinkBackURLPlaceHolder withString:escapesBackURL]];
    [[UIApplication sharedApplication] openURL:openURL];
}

- (void)openDownloadURL:(NSString *)downloadURL appleID:(NSString *)appleID localDownloadURL:(NSString *)localURL
{
    if ([TTDeviceHelper isJailBroken] && !isEmptyString(localURL)) {
        [self openDownloadURL:localURL appleID:nil];
    }
    else {
        [self openDownloadURL:downloadURL appleID:appleID];
    }
}

-  (BOOL)actionForModel:(SSTipModel *)model {
    NSParameterAssert(model != nil);
    if (model == nil) {
        return NO;
    }
    BOOL canOpen = NO;
    NSURL *openURL = [NSURL URLWithString:model.openURL];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        NSMutableDictionary *params = @{}.mutableCopy;
        params[@"ad_id"] = model.adID.stringValue;
        params[@"log_extra"] = model.logExtra;
        canOpen = [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(params)];
    }
    if (canOpen) {
        return YES;
    }
    if ([model.type isEqualToString:@"web"] && model.webURL != nil) {
        [self openWebURL:model.webURL appName:model.appName adID:model.adID.stringValue logExtra:model.logExtra];
    } else if ([model.type isEqualToString:@"app"]) {
        if (model.openURL == nil) {
            return NO;
        }
        NSString * kSeperatorString =  @"://";
        NSString *openURL = model.openURL;
        NSRange seperateRange = [openURL rangeOfString:kSeperatorString];
        if (seperateRange.location == NSNotFound) {
            return NO;
        }
        NSString *appURL = [openURL substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
        NSString *tabURL = [openURL substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [openURL length] - NSMaxRange(seperateRange))];
        [self openAppURL:appURL tabURL:tabURL adID:model.adID.stringValue logExtra:model.logExtra];
    }
    return YES;
}

- (UIViewController *)getTopViewController {
    UIViewController *tController = [TTUIResponderHelper topNavigationControllerFor: nil];
    if (!tController) {
        tController = [TTUIResponderHelper topViewControllerFor:nil];
        while (tController.presentedViewController) {
            tController = tController.presentedViewController;
        }
        if ([tController isKindOfClass:[UITabBarController class]]) {
            tController = ((UITabBarController *)tController).selectedViewController;
        }
        if (tController.navigationController) {
            tController = tController.navigationController;
        }
    }
    return tController;
}

@end
