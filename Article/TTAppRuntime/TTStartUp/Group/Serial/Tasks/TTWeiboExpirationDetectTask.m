//
//  TTWeiboExpirationDetectTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTWeiboExpirationDetectTask.h"
#import "NewsBaseDelegate.h"
#import "SSADSplashControllerView.h"
#import "TTAdSplashControllerView.h"
#import "TTAdSplashMediator.h"

@implementation TTWeiboExpirationDetectTask

- (NSString *)taskIdentifier {
    return @"WeiboExpirationDetect";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    //如果是西瓜直播，则不需要走下面的statusbar控制逻辑
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSString *schemaString = [userInfo tta_stringForKey:@"o_url"];
    if ([[[TTStringHelper URLWithURLString:schemaString] host] isEqualToString:@"xigua_live"]) {;
        return;
    }
    
    if ([SSCommonLogic shouldUseOptimisedLaunch]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[self class] checkWeiboExpiration];
        });
    } else {
        [[self class] checkWeiboExpiration];
    }
}

+ (void)checkWeiboExpiration {
    // if the app is launched by schema, [NewsListViewController viewDidAppear] won't be invoked
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        __block BOOL shouldShowStatusBar = YES;
        [SharedAppDelegate.window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([TTAdSplashMediator useSplashSDK]) {
                if ([view isKindOfClass:[TTAdSplashControllerView  class]]) {
                    shouldShowStatusBar = NO;
                }
            }
            else{
                if ([view isKindOfClass:[SSADSplashControllerView class]]) {
                    shouldShowStatusBar = NO;
                }
            }
        }];
        
        UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:nil];
        if (navController.topViewController){
            UIViewController *topVC = navController.topViewController;
            if (topVC.prefersStatusBarHidden){
                shouldShowStatusBar = NO;
            }
        }
        
        if (shouldShowStatusBar) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    });
}

@end
