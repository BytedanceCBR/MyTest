//
//  UIViewController+Track.m
//  TestAutoLayout
//
//  Created by yuxin on 9/11/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "UIViewController+Track.h"

@import ObjectiveC;

@implementation UIViewController (Track)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(tt_track_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }

        SEL originalSelector2 = @selector(viewWillDisappear:);
        SEL swizzledSelector2 = @selector(tt_track_viewWillDisappear:);
        
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

- (void)tt_track_viewWillAppear:(BOOL)animated
{
    NSMutableDictionary * willShowViewControllerItem = [[NSMutableDictionary alloc] init];
    [willShowViewControllerItem setValue:[NSString stringWithFormat:@"%@_enter",NSStringFromClass([self class])] forKey:@"viewControllerName"];

    [willShowViewControllerItem setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"timestamp"];

    [self tt_track_viewWillAppear:animated];
    
    if (self.ttTrackStayEnable) {
        if ([self tt_hadObservedNotification] == NO) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_ApplicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_ApplicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
            [self tt_setHadObservedNotification:YES];
        }
        
        [self tt_startTrack];
    }
    
}

- (void)tt_track_viewWillDisappear:(BOOL)animated
{
    NSMutableDictionary * willHideViewControllerItem = [[NSMutableDictionary alloc] init];
//    NSString * className = NSStringFromClass([self class]);
    [willHideViewControllerItem setValue:[NSString stringWithFormat:@"%@_leave",NSStringFromClass([self class])] forKey:@"viewControllerName"];
    [willHideViewControllerItem setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"timestamp"];
    [self tt_track_viewWillDisappear:animated];
    
    if (self.ttTrackStayEnable) {
        [self tt_endTrack];
        if ([self tt_hadObservedNotification] == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
            [self tt_setHadObservedNotification:NO];
        }
    }
}

- (void)tt_ApplicationDidEnterBackground
{
    if (self.ttTrackStayEnable) {
        [self tt_endTrack];
        
        if ([self respondsToSelector:@selector(trackEndedByAppWillEnterBackground)]) {
            [self trackEndedByAppWillEnterBackground];
        }
    }
}

- (void)tt_ApplicationWillEnterForeground
{
    if (self.ttTrackStayEnable) {
        [self tt_startTrack];
        
        if ([self respondsToSelector:@selector(trackStartedByAppWillEnterForground)]) {
            [self trackStartedByAppWillEnterForground];
        }
    }
}

- (void)tt_startTrack {
    
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)tt_endTrack {
    
    
    self.ttTrackStayTime += [[NSDate date] timeIntervalSince1970] - self.ttTrackStartTime;
 
    //NSLog(@"%@",@(self.ttTrackStayTime).stringValue);
    
}

-(void)tt_resetStayTime {
    
    self.ttTrackStayTime = 0;
    
}


#pragma mark Properties

- (NSTimeInterval)ttTrackStayTime {
    
    return (NSTimeInterval)[objc_getAssociatedObject(self, @selector(ttTrackStayTime)) doubleValue];
}

- (void)setTtTrackStayTime:(NSTimeInterval)ttTrackStayTime {
    
    objc_setAssociatedObject(self, @selector(ttTrackStayTime),@(ttTrackStayTime), OBJC_ASSOCIATION_RETAIN);
}

- (NSTimeInterval)ttTrackStartTime {
    
    return (NSTimeInterval)[objc_getAssociatedObject(self, @selector(ttTrackStartTime)) doubleValue];
}

- (void)setTtTrackStartTime:(NSTimeInterval)ttTrackStartTime {
    
    objc_setAssociatedObject(self, @selector(ttTrackStartTime),@(ttTrackStartTime), OBJC_ASSOCIATION_RETAIN);
}


- (BOOL)ttTrackStayEnable {
    
    return (BOOL)[objc_getAssociatedObject(self, @selector(ttTrackStayEnable)) boolValue];
}

- (void)setTtTrackStayEnable:(BOOL)ttTrackStayEnable{
    
    objc_setAssociatedObject(self, @selector(ttTrackStayEnable),@(ttTrackStayEnable), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)tt_hadObservedNotification {
    return (BOOL)[objc_getAssociatedObject(self, @selector(tt_hadObservedNotification)) boolValue];
}

- (void)tt_setHadObservedNotification:(BOOL)hadSet {
    objc_setAssociatedObject(self, @selector(tt_hadObservedNotification), @(hadSet), OBJC_ASSOCIATION_RETAIN);
    
}
@end
