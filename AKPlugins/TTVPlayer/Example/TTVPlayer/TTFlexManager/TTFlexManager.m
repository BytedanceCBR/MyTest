//

#import "TTFlexManager.h"
#import <UIKit/UIKit.h>
#import <FLEXManager.h>
#import <objc/runtime.h>


@interface UIWindow (DEBUG_FLEX_SHAKE)

@end

@implementation UIWindow (DEBUG_FLEX_SHAKE)

static NSString *kTTShakeToShowFlexEnabledKey = @"TTShakeFlexEnabled";

- (void)FLEX_motionBegan:(__unused UIEventSubtype)motion withEvent:(UIEvent *)event
{
    static NSUInteger debugShakeCount = 0;
    static NSTimeInterval absoluteTimeLastShake = 0;
    
    if (event.subtype == UIEventSubtypeMotionShake) {
        NSTimeInterval currentAbsoluteTime = CFAbsoluteTimeGetCurrent();
        
        if (debugShakeCount == 0) {
            absoluteTimeLastShake = currentAbsoluteTime;
        }
        
        if (currentAbsoluteTime - absoluteTimeLastShake > 10) {
            debugShakeCount = 0;
        }
        
        absoluteTimeLastShake = currentAbsoluteTime;
        debugShakeCount++;
        
        if (debugShakeCount == 1) {
            debugShakeCount = 0;
            [[FLEXManager sharedManager] showExplorer];
        }
    }
}
@end

@implementation TTFlexManager

+ (void)load
{
    dispatch_async(dispatch_get_main_queue(), ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class aClass = [UIWindow class];
            SEL originalSelector = @selector(motionBegan:withEvent:);
            SEL swizzledSelector = @selector(FLEX_motionBegan:withEvent:);
            Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
            method_exchangeImplementations(originalMethod, swizzledMethod);
        });
        
    });
}

@end

