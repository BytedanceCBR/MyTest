//
//  TTPluginsLoadTask.m
//  Article
//
//  Created by fengyadong on 2017/3/9.
//
//

#import "TTPluginsLoadTask.h"
#import <TTServiceKit/TTMessageCenter.h>
#import <TTServiceKit/TTServiceLoader.h>

@implementation TTPluginsLoadTask

- (NSString *)taskIdentifier {
    return @"TTPluginsLoad";
}

- (BOOL)isResistent {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    SAFECALL_MESSAGE(UIApplicationDelegate, @selector(application:didFinishLaunchingWithOptions:), application:application didFinishLaunchingWithOptions:launchOptions)
    [[TTServiceLoader sharedInstance] loadServicesRecursivelyFromBundleName:@"Titan" plistName:@"TitanService"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, applicationDidBecomeActive:application)
}

- (void)applicationWillResignActive:(UIApplication *)application {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, applicationWillResignActive:application)
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    return [self foward_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, applicationDidReceiveMemoryWarning:application)
}

- (void)applicationWillTerminate:(UIApplication *)application {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, applicationWillTerminate:application)
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, application:application willChangeStatusBarOrientation:newStatusBarOrientation duration:duration)
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, application:application didChangeStatusBarOrientation:oldStatusBarOrientation)
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, applicationDidEnterBackground:application)
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    SAFECALL_MESSAGE(UIApplicationDelegate, _cmd, applicationWillEnterForeground:application)
}

- (BOOL)foward_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    TTMessage *__oMessage__ = [GET_SERVICE(TTMessageCenter) getMessage:@protocol(UIApplicationDelegate)];
    if (__oMessage__) {
        NSArray *__ary__ = [__oMessage__ getMessageListForSelector:@selector(application:openURL:sourceApplication:annotation:)];
        for(UInt32 __index__ = 0; __index__ < __ary__.count; __index__++) {
            TTMessageObject *__obj__ = [__ary__ objectAtIndex:__index__];
            if(__obj__.m_deleteMark == YES)continue;
            NSObject<UIApplicationDelegate>* __oMessageObj__ = (__bridge NSObject<UIApplicationDelegate>*)[__obj__ getObject];
            BOOL canOpenURL = [__oMessageObj__ application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
            if (canOpenURL) {
                return canOpenURL;
            }
        }
    }
    return YES;
}

@end
