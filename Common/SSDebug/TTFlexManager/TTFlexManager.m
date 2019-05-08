//
//  TTFlexManager.m
//  Article
//
//  Created by liuzuopeng on 16/06/2017.
//
//

#if INHOUSE

#import "TTFlexManager.h"
#import <UIKit/UIKit.h>
#import <FLEXManager.h>
#import <TTNavigationController.h>
#import <TTUIResponderHelper.h>
#import <NSObject+FBKVOController.h>
#import <Aspects.h>
#import <TTSandBoxHelper.h>
//#import <RCTUtils.h>
#import "SSDebugViewController.h"
//#import "TTKitchenViewController.h"
#import "TTSettingsBrowserViewController.h"

@interface UIWindow (DEBUG_FLEX_SHAKE)

+ (void)debug_hookWindowShakeEvent;

@end

@implementation UIWindow (DEBUG_FLEX_SHAKE)

static NSString *kTTShakeToShowFlexEnabledKey = @"TTShakeFlexEnabled";

- (void)FLEX_motionBegan:(__unused UIEventSubtype)motion withEvent:(UIEvent *)event
{
    static NSUInteger debugShakeCount = 0;
    static NSTimeInterval absoluteTimeLastShake = 0;
    
    if (event.subtype == UIEventSubtypeMotionShake) {
        
        //        NSDictionary *environment = [[NSProcessInfo processInfo] environment];
        //        NSString *flexEnvVar = environment[kTTShakeToShowFlexEnabledKey]; /** 只要填写，随便填啥**都可以 */
        //        NSNumber *flexUserDefVar = [[NSUserDefaults standardUserDefaults] objectForKey:kTTShakeToShowFlexEnabledKey];
        //        if (!flexUserDefVar) {
        //            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kTTShakeToShowFlexEnabledKey];
        //            [[NSUserDefaults standardUserDefaults] synchronize];
        //        }
        //        if ((![flexEnvVar boolValue]) && (![flexUserDefVar boolValue])) {
        //            return;
        //        }
        
        NSTimeInterval currentAbsoluteTime = CFAbsoluteTimeGetCurrent();
        
        if (debugShakeCount == 0) {
            absoluteTimeLastShake = currentAbsoluteTime;
        }
        
        if (currentAbsoluteTime - absoluteTimeLastShake > 10) {
            debugShakeCount = 0;
        }
        
        absoluteTimeLastShake = currentAbsoluteTime;
        debugShakeCount++;
        
        if (debugShakeCount == 3) {
            debugShakeCount = 0;
            [[FLEXManager sharedManager] showExplorer];
        }
    }
}

+ (void)debug_hookWindowShakeEvent
{
    //    [UIWindow aspect_hookSelector:@selector(canBecomeFirstResponder) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
    //
    //        if (!aspectInfo) return;
    //
    //        BOOL canBecome;
    //        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
    //        if (!originalInvoc) return;
    //        if (![originalInvoc.target respondsToSelector:originalInvoc.selector]) return;
    //
    //        [originalInvoc invoke];
    //        [originalInvoc getReturnValue:&canBecome];
    //
    //        canBecome = YES;
    //        [originalInvoc setReturnValue:&canBecome];
    //
    //    } error:nil];
    
    
//    RCTSwapInstanceMethods([UIWindow class], @selector(motionBegan:withEvent:), @selector(FLEX_motionBegan:withEvent:));
    
    /* UIApplication not working (test is OK) ??? */
    //    [UIWindow aspect_hookSelector:@selector(motionBegan:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
    //
    //        if (!aspectInfo) return;
    //
    //        static NSUInteger debugShakeCount = 0;
    //
    //        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
    //        if (!originalInvoc) return;
    //        if (![originalInvoc.target respondsToSelector:originalInvoc.selector]) return;
    //
    //        UIEvent *motionEvent = nil;
    //        [originalInvoc getArgument:&motionEvent atIndex:3];
    //
    //        /** AspectPositionInstead */
    //        [originalInvoc invoke];
    //
    //        if (!motionEvent) return;
    //
    //        if (motionEvent.subtype == UIEventSubtypeMotionShake) {
    //
    //            debugShakeCount++;
    //
    //            if (debugShakeCount == 1) {
    //                debugShakeCount = 0;
    //
    //                [[FLEXManager sharedManager] showExplorer];
    //            }
    //        }
    //    } error:nil];
}

@end

@implementation TTFlexManager

+ (void)load
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.class confCustomizationDebugMenus];
    });
}

static NSString * const TTAPPTestChannelNameKey = @"local_test";

+ (void)confCustomizationDebugMenus
{
    if (![[TTSandBoxHelper getCurrentChannel] isEqualToString:TTAPPTestChannelNameKey] && ![[TTSandBoxHelper getCurrentChannel] isEqualToString:@"chenshafeng_redpackage"]) {
        return;
    }
    
    [self.class hookApplicationShakeMotion];
    
//    [self.class customizeFlexMenus];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.class observeKeyWindowChange];
    });
}

+ (void)observeKeyWindowChange
{
    [UIWindow aspect_hookSelector:@selector(makeKeyAndVisible) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIWindow *oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
        if (!originalInvoc) return;
        if (![originalInvoc.target respondsToSelector:originalInvoc.selector]) return;
        
        [originalInvoc invoke];
        
        UIWindow *newKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableDictionary *changedWindowDesp = [NSMutableDictionary dictionaryWithCapacity:3];
        [changedWindowDesp setValue:NSStringFromSelector(@selector(makeKeyAndVisible))
                             forKey:@"SEL"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(oldKeyWindow.class), oldKeyWindow]
                             forKey:@"OldKeyWindow"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(newKeyWindow.class), newKeyWindow]
                             forKey:@"NewKeyWindow"];
        
        [self.class writeChangedKeyWindowToMonitorFile:changedWindowDesp];
        
    } error:nil];
    
    [UIWindow aspect_hookSelector:@selector(makeKeyWindow) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIWindow *oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
        if (!originalInvoc) return;
        if (![originalInvoc.target respondsToSelector:originalInvoc.selector]) return;
        
        [originalInvoc invoke];
        
        UIWindow *newKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableDictionary *changedWindowDesp = [NSMutableDictionary dictionaryWithCapacity:3];
        [changedWindowDesp setValue:NSStringFromSelector(@selector(makeKeyWindow))
                             forKey:@"SEL"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(oldKeyWindow.class), oldKeyWindow]
                             forKey:@"OldKeyWindow"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(newKeyWindow.class), newKeyWindow]
                             forKey:@"NewKeyWindow"];
        
        [self.class writeChangedKeyWindowToMonitorFile:changedWindowDesp];
        
    } error:nil];
}

+ (void)writeChangedKeyWindowToMonitorFile:(NSDictionary *)contents
{
    if (!contents || [contents count] <= 0) return;
    
    NSDate   *currentDate = [NSDate date];
    NSString *currentDateString = [currentDate descriptionWithLocale:nil] ? : [currentDate description];
    NSMutableDictionary *newRecordDict = [[NSMutableDictionary alloc] initWithDictionary:contents];
    [newRecordDict setValue:currentDateString forKey:@"Time"];
    if (!newRecordDict || !currentDateString) return;
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/keywindow_monitor.plist",
                          documentsDirectory];
    
    NSMutableDictionary *fileRecordsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    if (!fileRecordsDict) {
        fileRecordsDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    NSMutableArray *keywindowRecords = [[NSMutableArray alloc] initWithArray:[fileRecordsDict objectForKey:@"root"]];
    NSArray *newKeywindowRecords = nil;
    @synchronized (keywindowRecords) {
        if (!keywindowRecords) {
            keywindowRecords = [NSMutableArray arrayWithCapacity:2];
        }
        [keywindowRecords addObject:newRecordDict];
        
        const NSInteger MAX_RECORDS = 8;
        NSInteger currentNumberOfRecords = [keywindowRecords count];
        if (currentNumberOfRecords > MAX_RECORDS) {
            newKeywindowRecords = [keywindowRecords subarrayWithRange:NSMakeRange(currentNumberOfRecords - MAX_RECORDS/2, MAX_RECORDS/2)];
        } else {
            newKeywindowRecords = keywindowRecords;
        }
    }
    
    [fileRecordsDict setValue:newKeywindowRecords forKey:@"root"];
    
    [fileRecordsDict writeToFile:filePath atomically:YES];
}

+ (void)hookApplicationShakeMotion
{
    [UIWindow debug_hookWindowShakeEvent];
}

+ (void)customizeFlexMenus
{
//    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue428 Kitchen" objectFutureBlock:^id{
//        TTKitchenViewController *debugViewController = [[TTKitchenViewController alloc] init];
//        TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:debugViewController];
//        navigationController.ttDefaultNavBarStyle = @"White";
//
//        UIViewController *currentVC = [self.class flexTopViewController] ? : [TTUIResponderHelper topmostViewController];
//
//        [currentVC presentViewController:navigationController animated:YES completion:NULL];
//
//        return nil;
//    }];
    
    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue301 Settings调试选项" objectFutureBlock:^id{
        UIViewController *currentVC = [self.class flexTopViewController] ? : [TTUIResponderHelper topmostViewController];
        
        [TTSettingsBrowserViewController showBrowserViewControllerInViewController:currentVC];
        
        return nil;
    }];
    
    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue226 头条高级调试 & 关闭FLEX" objectFutureBlock:^id{
        
        SSDebugViewController *debugViewController = [[SSDebugViewController alloc] init];
        TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:debugViewController];
        navigationController.ttDefaultNavBarStyle = @"White";
        
        UIViewController *currentVC = [TTUIResponderHelper topmostViewController];
        
        [[FLEXManager sharedManager] hideExplorer];
        
        [currentVC presentViewController:navigationController animated:YES completion:^{
            
        }];
        
        return nil;
    }];
    
    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue428 头条高级调试" objectFutureBlock:^id{
        
        SSDebugViewController *debugViewController = [[SSDebugViewController alloc] init];
        TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:debugViewController];
        navigationController.ttDefaultNavBarStyle = @"White";
        
        UIViewController *currentVC = [self.class flexTopViewController] ? : [TTUIResponderHelper topmostViewController];
        
        [currentVC presentViewController:navigationController animated:YES completion:NULL];
        
        return nil;
    }];
    
    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue429 CHANGE FLEX WINDOW LEVEL" objectFutureBlock:^id{
        
        UIWindow *flexWindow = [self.class flexWindow];
        if (flexWindow.windowLevel == UIWindowLevelAlert + 100) {
            flexWindow.windowLevel = UIWindowLevelStatusBar + 100;
        } else {
            flexWindow.windowLevel = UIWindowLevelAlert + 100;
        }
        
        [self.class resignKeyAndDismissFlexViewControllerAnimated:YES];
        // [[FLEXManager sharedManager] hideExplorer];
        
        return nil;
    }];
}

+ (UIViewController *)flexTopViewController
{
    UIViewController *flexVC = nil;
    if ([[FLEXManager sharedManager] respondsToSelector:@selector(topViewController)]) {
        flexVC = [[FLEXManager sharedManager] performSelector:@selector(topViewController)];
    }
    return flexVC;
}

+ (UIViewController *)flexRootExplorerViewController
{
    UIViewController *flexVC = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[FLEXManager sharedManager] respondsToSelector:@selector(explorerViewController)]) {
        flexVC = [[FLEXManager sharedManager] performSelector:@selector(explorerViewController)];
    }
#pragma clang diagnostic pop
    return flexVC;
}


+ (UIWindow *)flexWindow
{
    UIWindow *flexWindow = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[FLEXManager sharedManager] respondsToSelector:@selector(explorerWindow)]) {
        flexWindow = [[FLEXManager sharedManager] performSelector:@selector(explorerWindow)];
    }
#pragma clang diagnostic pop
    return flexWindow;
}

+ (void)resignKeyAndDismissFlexViewControllerAnimated:(BOOL)animated
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIViewController *flexVC = [self.class flexRootExplorerViewController];
    if ([flexVC respondsToSelector:@selector(resignKeyAndDismissViewControllerAnimated:completion:)]) {
        
        NSMethodSignature *signature = [flexVC.class instanceMethodSignatureForSelector:@selector(resignKeyAndDismissViewControllerAnimated:completion:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        invocation.target = flexVC;
        invocation.selector = @selector(resignKeyAndDismissViewControllerAnimated:completion:);
        [invocation setArgument:&animated atIndex:2];
        id completedBlock = nil;
        [invocation setArgument:&completedBlock atIndex:3];
        
        [invocation invoke];
        
        // [flexVC performSelector:@selector(resignKeyAndDismissViewControllerAnimated:completion:) withObject:@(animated) withObject:nil];
    }
#pragma clang diagnostic pop
}

@end

#endif
