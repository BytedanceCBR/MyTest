//
//  TTUniversalLinksTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTUniversalLinksTask.h"
#import "NewsBaseDelegate.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "SSWebViewController.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
#import "TTOpenInSafariWindow.h"
//#import "TTSFShareManager.h"
//#import "TTVFantasy.h"

@implementation TTUniversalLinksTask

- (NSString *)taskIdentifier {
    return @"UniversalLinks";
}

- (BOOL)isResident {
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        
        // 添加统计
        NSString *url = webpageURL.absoluteString;
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
        [extraDict setValue:url forKey:@"url"];
        wrapperTrackEventWithCustomKeys(@"activity_type", @"click_wap_browsing_web", nil, nil, extraDict);
        
        NSDictionary *queryDict = [TTURLUtils queryItemsForURL:webpageURL];
        
        NSString *scheme = [queryDict objectForKey:@"scheme"];
        
        if ([SSCommonLogic openInSafariWindowEnable]) {
            [TTOpenInSafariWindow showQuickGotoWindowWithOpenURL:scheme?:url];
        }
        
        if (!isEmptyString(scheme)) {
            //通过deeplink打开文章不出开屏广告
//            [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
            [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:scheme]];
            NSURL *webpageURL = userActivity.webpageURL;
//            NSDictionary *queryDict = [TTURLUtils queryItemsForURL:webpageURL];
//            BOOL isFantasyShareHost = [webpageURL.host isEqualToString:@"api-spe-i.snssdk.com"] ||
//            [webpageURL.host isEqualToString:@"api-spe-h.snssdk.com"];
//            if (isFantasyShareHost && [webpageURL.path hasPrefix:@"/h/1/cli/page/"]) {
//                [TTVFantasy ttf_enterFantasyFromViewController:[TTUIResponderHelper topmostViewController]
//                                            trackerDescriptor:@{kTTFEnterFromTypeKey:@"click_wap"}];
//                return YES;
//            }
            
            [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
//            [SSADManager shareInstance].splashADShowType = SSSplashADShowTypeHide;
//            NSURL *url = [TTStringHelper URLWithURLString:scheme];
            
            // 处理route action
//            if (![TTSFShareManager openUniversalLinkWithURL:url]) {
//                [[TTRoute sharedRoute] openURLByPushViewController:url];
//            }
        }
        else {
            NSURL *webpageURL = userActivity.webpageURL;
            // path是/i*格式，没有scheme时使用webview打开
            if ([webpageURL.path hasPrefix:@"i"]) {
                ssOpenWebView(webpageURL, nil, [SharedAppDelegate appTopNavigationController], NO, nil);
            } else {
                return NO;
            }
        }
    }
    return YES;
}

@end
