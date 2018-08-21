//
//  UIView+TTVHitTestExtensions.m
//  Article
//
//  Created by pei yun on 2017/5/18.
//
//

#import "UIView+TTVHitTestExtensions.h"
#import <objc/runtime.h>

@implementation UIView (TTVHitTestExtensions)

@dynamic ttv_hitTestEdgeInsets;

static const NSString *KEY_HIT_TEST_EDGE_INSETS = @"HitTestEdgeInsets";

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(pointInside:withEvent:)),
                                   class_getInstanceMethod([self class], @selector(increasePointInside:withEvent:)));
}

- (void)setTtv_hitTestEdgeInsets:(UIEdgeInsets)ttv_hitTestEdgeInsets
{
    NSValue *value = [NSValue value:&ttv_hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)ttv_hitTestEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS);
    if (value) {
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)increasePointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.ttv_hitTestEdgeInsets, UIEdgeInsetsZero)) {
        return [self increasePointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.ttv_hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end
