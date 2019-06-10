//
//  TTRWebViewApplication+TTRNKit.m
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/8/23.
//

#import "TTRWebViewApplication+TTRNKit.h"
#import "UIView+BridgeModule.h"
#import <objc/runtime.h>
#import "TTRNKit.h"
@implementation TTRWebViewApplication (TTRNKit)
+ (void)load {
    Class class = [self class];
    
    SEL originalSelector = @selector(handleRequest:withWebView:viewController:);
    SEL swizzledSelector = @selector(hook_handleRequest:withWebView:viewController:);
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(object_getClass(class),
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(object_getClass(class),
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling
+ (BOOL)hook_handleRequest:(NSURLRequest *)request withWebView:(UIView<TTRWebView> *)webView viewController:(UIViewController *)viewController {
    if ([webView getBridgeModule] != nil && [request.URL.absoluteString hasPrefix:@"sslocal://"]) {
        [[webView getBridgeModule].manager handleUrl:request.URL.absoluteString];
        return YES;
    }
    return [self hook_handleRequest:request
                        withWebView:webView
                     viewController:viewController];
}
@end
