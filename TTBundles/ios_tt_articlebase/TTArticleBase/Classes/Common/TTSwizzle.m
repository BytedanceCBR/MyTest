//
//  TTSwizzle.m
//  Article
//
//  Created by panxiang on 15/10/20.
//
//

#import "TTSwizzle.h"
#import "RSSwizzle.h"
#import "NSObject+TTAdditions.h"

@implementation TTSwizzle
+ (void)swizzleViewWillAppear
{
    static const void *key = &key;
    SEL selector = NSSelectorFromString(@"viewWillAppear:");
    [RSSwizzle swizzleInstanceMethod:selector inClass:[UIViewController class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^void(__unsafe_unretained id self,BOOL animated){
            NSLog(@"swizzleViewWillAppear %@ %@",NSStringFromSelector(selector),NSStringFromClass([self class]));
            
            [NSObject elapsedTimeBlock:^{
                void (*originalIMP)(__unsafe_unretained id, SEL);
                originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
                originalIMP(self,selector);
            }];
        };
    } mode:RSSwizzleModeOncePerClassAndSuperclasses key:key];
}

+ (void)swizzleHitTest
{
    static const void *key = &key;
    SEL selector = NSSelectorFromString(@"hitTest:withEvent:");
    [RSSwizzle swizzleInstanceMethod:selector inClass:[UIView class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^UIView*(__unsafe_unretained id self,CGPoint point,UIEvent *event){
            NSLog(@"swizzleHitTest %@ %@",NSStringFromSelector(selector),NSStringFromClass([self class]));
            UIView* (*originalIMP)(__unsafe_unretained id, SEL,CGPoint,UIEvent *);
            originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
            UIView *view = originalIMP(self, selector, point, event);
            return view;
        };
    } mode:RSSwizzleModeOncePerClassAndSuperclasses key:key];
}

+ (void)swizzleMethod
{
//    [self swizzleViewWillAppear];
//    #pragma mark ============= TODOP delete =============
//    [self swizzleHitTest];
    //[self swizzleWebRequest];
    
}

+ (void)swizzleWebRequest{
    static const void *key = &key;
    SEL selector = NSSelectorFromString(@"loadRequest:");
    [RSSwizzle swizzleInstanceMethod:selector inClass:[UIWebView class] newImpFactory:^id(RSSwizzleInfo *swizzleInfo) {
        return ^void(__unsafe_unretained id self,NSURLRequest* reuqest){
            NSLog(@"swizzleWebRequest %@ %@",NSStringFromSelector(selector),NSStringFromClass([self class]));
            NSLog(@"reuqest.url=%@", reuqest.URL.absoluteString);
            [NSObject elapsedTimeBlock:^{
                void (*originalIMP)(__unsafe_unretained id, SEL);
                originalIMP = (__typeof(originalIMP))[swizzleInfo getOriginalImplementation];
                originalIMP(self,selector);
            }];
        };    } mode:RSSwizzleModeOncePerClassAndSuperclasses key:key];

}

@end
