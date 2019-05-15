//
//  UITextField+TTTouchAreaAddition.h
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import "UITextField+TTTouchAreaAddition.h"
#import <objc/runtime.h>



@implementation UITextField (TTTouchAreaAddition)

- (void)setExcludedHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets
{
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, @selector(excludedHitTestEdgeInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)excludedHitTestEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    if (value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets]; return edgeInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.excludedHitTestEdgeInsets, UIEdgeInsetsZero) ||
        !self.enabled || self.hidden) {
        return [super hitTest:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.excludedHitTestEdgeInsets);
    if (CGRectContainsPoint(hitFrame, point)) {
        return self;
    }
    
    __block UIView *hitTestSubView = nil;
    [self.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint hitTestViewPoint = [self convertPoint:point toView:obj];
        if ([obj pointInside:hitTestViewPoint withEvent:event]) {
            hitTestSubView = obj;
            *stop = YES;
        }
    }];
    return hitTestSubView;
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (UIEdgeInsetsEqualToEdgeInsets(self.excludedHitTestEdgeInsets, UIEdgeInsetsZero) ||
//        !self.enabled || self.hidden) {
//        return [super pointInside:point withEvent:event];
//    }
//
//    CGRect relativeFrame = self.bounds;
//    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.excludedHitTestEdgeInsets);
//
//    return CGRectContainsPoint(hitFrame, point);
//}

@end
