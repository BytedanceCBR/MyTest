//
//  TTFlexManager.m
//  Article
//
//  Created by liuzuopeng on 16/06/2017.
//
//

#import "TTFlexManager.h"
#import <UIKit/UIKit.h>
#import <FLEXManager.h>
#import <TTNavigationController.h>
#import <TTUIResponderHelper.h>
#import <NSObject+FBKVOController.h>
#import <Aspects.h>



#if defined(DEBUG) || defined(INHOUSE)

@interface UIApplication (TT_DEBUG_KEYWINDOW)
@property (nonatomic, strong) UIWindow *lastKeyWindow;
@end

@implementation UIApplication (TT_DEBUG_KEYWINDOW)


@end



@implementation TTFlexManager

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.class confCustomizationDebugMenus];
    });
}

+ (void)observeKeyWindowChange
{
    [UIWindow aspect_hookSelector:@selector(canBecomeFirstResponder) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        BOOL canBecome;
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        [invocation getReturnValue:&canBecome];
        
        canBecome = YES;
        [invocation setReturnValue:&canBecome];
        
    } error:nil];
    
    [[UIApplication sharedApplication] aspect_hookSelector:@selector(motionEnded:withEvent:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        
        static NSUInteger debugShakeCount = 0;
        
        NSInvocation *invocation = aspectInfo.originalInvocation;
        UIEventSubtype motion = 0;
        [invocation getArgument:&motion atIndex:2];
        
        //        if ([invocation.target respondsToSelector:invocation.selector]) {
        //            [invocation invoke];
        //        }
        
        if (motion == UIEventSubtypeMotionShake) {
            debugShakeCount++;
            
            if (debugShakeCount == 1) {
                debugShakeCount = 0;
                
                [[FLEXManager sharedManager] toggleExplorer];
            }
        }
        
    } error:nil];
    
    [UIWindow aspect_hookSelector:@selector(makeKeyAndVisible) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIWindow *oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
        
        [originalInvoc invoke];
        
        UIWindow *newKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableDictionary *changedKeyWindowDesp = [NSMutableDictionary dictionaryWithCapacity:3];
        [changedKeyWindowDesp setValue:NSStringFromSelector(@selector(makeKeyAndVisible))
                                forKey:@"SEL"];
        [changedKeyWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(oldKeyWindow.class), oldKeyWindow]
                                forKey:@"OldKeyWindow"];
        [changedKeyWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(newKeyWindow.class), newKeyWindow]
                                forKey:@"NewKeyWindow"];
        
        NSLog(@"%@", changedKeyWindowDesp);
        
        //        [self.class writeToKeyWindowChangedMonitorFile:changedKeyWindowDesp];
        
    } error:nil];
    
    [UIWindow aspect_hookSelector:@selector(makeKeyWindow) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIWindow *oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
        
        [originalInvoc invoke];
        
        UIWindow *newKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableDictionary *changedKeyWindowDesp = [NSMutableDictionary dictionaryWithCapacity:3];
        [changedKeyWindowDesp setValue:NSStringFromSelector(@selector(makeKeyWindow))
                                forKey:@"SEL"];
        [changedKeyWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(oldKeyWindow.class), oldKeyWindow]
                                forKey:@"OldKeyWindow"];
        [changedKeyWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(newKeyWindow.class), newKeyWindow]
                                forKey:@"NewKeyWindow"];
        
        NSLog(@"%@", changedKeyWindowDesp);
        
        //        [self.class writeToKeyWindowChangedMonitorFile:changedKeyWindowDesp];
        
    } error:nil];
    
    [UIWindow aspect_hookSelector:@selector(becomeKeyWindow) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIWindow *oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
        
        [originalInvoc invoke];
        
        UIWindow *newKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableDictionary *changedWindowDesp = [NSMutableDictionary dictionaryWithCapacity:3];
        [changedWindowDesp setValue:NSStringFromSelector(@selector(becomeKeyWindow))
                             forKey:@"SEL"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(oldKeyWindow.class), oldKeyWindow]
                             forKey:@"OldKeyWindow"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(newKeyWindow.class), newKeyWindow]
                             forKey:@"NewKeyWindow"];
        
        NSLog(@"%@", changedWindowDesp);
        
    } error:nil];
    
    [UIWindow aspect_hookSelector:@selector(resignKeyWindow) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UIWindow *oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSInvocation *originalInvoc = [aspectInfo originalInvocation];
        
        [originalInvoc invoke];
        
        UIWindow *newKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        NSMutableDictionary *changedWindowDesp = [NSMutableDictionary dictionaryWithCapacity:3];
        [changedWindowDesp setValue:NSStringFromSelector(@selector(resignKeyWindow))
                             forKey:@"SEL"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(oldKeyWindow.class), oldKeyWindow]
                             forKey:@"OldKeyWindow"];
        [changedWindowDesp setValue:[NSString stringWithFormat:@"[Class: %@, Addr: %p]", NSStringFromClass(newKeyWindow.class), newKeyWindow]
                             forKey:@"NewKeyWindow"];
        
        NSLog(@"%@", changedWindowDesp);
        
    } error:nil];
}

+ (void)writeToKeyWindowChangedMonitorFile:(NSDictionary *)contents
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

+ (void)confCustomizationDebugMenus
{
    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue226 头条高级调试 & 关闭FLEX" objectFutureBlock:^id{
        
        return nil;
    }];
    
    [[FLEXManager sharedManager] registerGlobalEntryWithName:@"\ue428 头条高级调试" objectFutureBlock:^id{
        
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.class observeKeyWindowChange];
    });
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
