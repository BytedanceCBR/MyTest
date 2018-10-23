//
//  UIViewController+Monitor.m
//  Pods
//
//  Created by 苏瑞强 on 17/1/16.
//
//

#import "UIViewController+Monitor.h"
#import "TTDebugRealMonitorManager.h"
#import <objc/runtime.h>

@implementation UIViewController (Monitor)
+ (void)load
{
    [[NSUserDefaults standardUserDefaults] setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"app_launch_timeinteval"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(tt_monitor_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        SEL originalSelector2 = @selector(viewWillDisappear:);
        SEL swizzledSelector2 = @selector(tt_monitor_viewWillDisappear:);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL success2 = class_addMethod(class, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        if (success2) {
            class_replaceMethod(class, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
    });
}

- (void)tt_monitor_viewWillAppear:(BOOL)animated
{
    if ([TTDebugRealMonitorManager sharedManager].enabled) {
        NSMutableDictionary * willShowViewControllerItem = [[NSMutableDictionary alloc] init];
        [willShowViewControllerItem setValue:[NSString stringWithFormat:@"%@_enter",NSStringFromClass([self class])] forKey:@"viewControllerName"];
        [willShowViewControllerItem setValue:@([[NSDate date] timeIntervalSince1970]*1000) forKey:@"timestamp"];
        [TTDebugRealMonitorManager logEnterEvent:willShowViewControllerItem];
    }
    [self tt_monitor_viewWillAppear:animated];
}

- (void)tt_monitor_viewWillDisappear:(BOOL)animated
{
    if ([TTDebugRealMonitorManager sharedManager].enabled) {
        NSMutableDictionary * willHideViewControllerItem = [[NSMutableDictionary alloc] init];
        NSString * className = NSStringFromClass([self class]);
        [willHideViewControllerItem setValue:[NSString stringWithFormat:@"%@_leave",NSStringFromClass([self class])] forKey:@"viewControllerName"];
        [willHideViewControllerItem setValue:@([[NSDate date] timeIntervalSince1970]*1000) forKey:@"timestamp"];
        [TTDebugRealMonitorManager logLeaveEvent:willHideViewControllerItem];
    }
    [self tt_monitor_viewWillDisappear:animated];
}
@end
