//
//  UIView+TTFFrame.m
//  TTFantasy
//
//  Created by 钟少奋 on 2017/11/30.
//

#import "UIView+TTFFrame.h"
#import <objc/runtime.h>

@implementation UIView (TTFFrame)

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)left {
    return self.x;
}

- (void)setLeft:(CGFloat)left {
    [self setX:left];
}

- (CGFloat)right {
    return self.left + self.width;
}

- (void)setRight:(CGFloat)right {
    self.left = right - self.width;
}

- (CGFloat)top {
    return self.y;
}

- (void)setTop:(CGFloat)top {
    self.y = top;
}

- (CGFloat)bottom {
    return self.y + self.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.y = bottom - self.height;
}

- (CGFloat)ttf_centerX {
    return self.x + self.width/2;
}

- (void)setTtf_centerX:(CGFloat)centerX {
    self.x = centerX - self.width/2;
}

- (CGFloat)ttf_centerY {
    return self.y + self.height/2;
}

- (void)setTtf_centerY:(CGFloat)centerY {
    self.y = centerY - self.height/2;
}

@end

@implementation UIView (TTFHitTestExtensions)

@dynamic ttf_hitTestEdgeInsets;

static const NSString *TTF_KEY_HIT_TEST_EDGE_INSETS = @"TTF_KEY_HIT_TEST_EDGE_INSETS";

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(pointInside:withEvent:)),
                                   class_getInstanceMethod([self class], @selector(increasePointInside:withEvent:)));
}

- (void)setTtf_hitTestEdgeInsets:(UIEdgeInsets)ttf_hitTestEdgeInsets
{
    NSValue *value = [NSValue value:&ttf_hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &TTF_KEY_HIT_TEST_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)ttf_hitTestEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &TTF_KEY_HIT_TEST_EDGE_INSETS);
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
    if (UIEdgeInsetsEqualToEdgeInsets(self.ttf_hitTestEdgeInsets, UIEdgeInsetsZero)) {
        return [self increasePointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.ttf_hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end

@implementation UIView (TTFResponder)

- (UIViewController *)ttf_viewController
{
    for (UIView *next = self; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
