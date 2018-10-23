//
//  TTOrientationTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTOrientationTask.h"
#import "NewsBaseDelegate.h"
#import "TTMovieFullscreenViewController.h"
#import "TTArticleTabBarController.h"
#import "TTDetailContainerViewController.h"
#import "SSWebViewController.h"
#import "TTVFullscreenViewController.h"

@implementation TTOrientationTask

- (NSString *)taskIdentifier {
    return @"Orientation";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (window == SharedAppDelegate.window) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        
        if(![TTDeviceHelper isPadDevice]) {
            id  rootController = SharedAppDelegate.window.rootViewController;
            
            //如果当前正在播放全屏视频，则需要支持横评
            UIViewController *topmostViewController = rootController;
            while (topmostViewController.presentedViewController) {
                topmostViewController = topmostViewController.presentedViewController;
            }
            if ([topmostViewController isKindOfClass:[TTMovieFullscreenViewController class]] || [topmostViewController isKindOfClass:[TTVFullscreenViewController class]]) {
                return UIInterfaceOrientationMaskAll;
            }
            
            if ([rootController isKindOfClass:[UINavigationController class]]) {
            }
            else if ([rootController isKindOfClass:[UITabBarController class]]) {
            }
            else {
                return UIInterfaceOrientationMaskPortrait;
            }
            
            UIViewController *presentedViewController = [SharedAppDelegate appTopNavigationController].topViewController;
            
            ///...
            if ([presentedViewController isKindOfClass:NSClassFromString(@"SSWebViewController")]) {
                SSWebViewController *webViewController = (SSWebViewController *)presentedViewController;
                if (webViewController.supportLandscapeOnly) {
                    return UIInterfaceOrientationMaskLandscapeRight;
                } else if (webViewController.iphoneSupportRotate) {
                    return UIInterfaceOrientationMaskAll;
                }
                return UIInterfaceOrientationMaskPortrait;
            }
            else if ([presentedViewController isKindOfClass:[TTDetailContainerViewController class]]) {
                TTDetailContainerViewController *detailVC = (TTDetailContainerViewController *)presentedViewController;
                if ([detailVC isNewsDetailForImageSubject] &&
                    [detailVC canRotateNewsDetailForImageSubject]) {
                    return UIInterfaceOrientationMaskAllButUpsideDown;
                }
                else {
                    return UIInterfaceOrientationMaskPortrait;
                }
            }
            else {
                return UIInterfaceOrientationMaskPortrait;
            }
            
        }
        else {
            return UIInterfaceOrientationMaskAll;
        }
    }
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
    NSString *label = UIInterfaceOrientationIsLandscape(newStatusBarOrientation) ? @"landscape": @"portrait";
    wrapperTrackEvent(@"orientation", label);
    
    TLS_LOG(@"willChangeStatusBarOrientation");
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
