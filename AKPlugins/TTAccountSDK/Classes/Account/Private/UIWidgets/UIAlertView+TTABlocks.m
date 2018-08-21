//
//  UIAlertView+TTABlocks.m
//  TTAccountSDK
//
//  Created by Ryan Maxwell on 29/08/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Ryan Maxwell
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIAlertView+TTABlocks.h"
#import <objc/runtime.h>



static const void *TTA_UIAlertViewOriginalDelegateKey                   = &TTA_UIAlertViewOriginalDelegateKey;

static const void *TTA_UIAlertViewTapBlockKey                           = &TTA_UIAlertViewTapBlockKey;
static const void *TTA_UIAlertViewWillPresentBlockKey                   = &TTA_UIAlertViewWillPresentBlockKey;
static const void *TTA_UIAlertViewDidPresentBlockKey                    = &TTA_UIAlertViewDidPresentBlockKey;
static const void *TTA_UIAlertViewWillDismissBlockKey                   = &TTA_UIAlertViewWillDismissBlockKey;
static const void *TTA_UIAlertViewDidDismissBlockKey                    = &TTA_UIAlertViewDidDismissBlockKey;
static const void *TTA_UIAlertViewCancelBlockKey                        = &TTA_UIAlertViewCancelBlockKey;
static const void *TTA_UIAlertViewShouldEnableFirstOtherButtonBlockKey  = &TTA_UIAlertViewShouldEnableFirstOtherButtonBlockKey;



@implementation UIAlertView (TTA_Blocks)

+ (instancetype)tta_showWithTitle:(NSString *)title
                          message:(NSString *)message
                            style:(UIAlertViewStyle)style
                cancelButtonTitle:(NSString *)cancelButtonTitle
                otherButtonTitles:(NSArray *)otherButtonTitles
                         tapBlock:(TTA_UIAlertViewCompletionBlock)tapBlock {
    
    NSString *firstObject = otherButtonTitles.count ? otherButtonTitles[0] : nil;
    
    UIAlertView *alertView = [[self alloc] initWithTitle:title
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:cancelButtonTitle
                                       otherButtonTitles:firstObject, nil];
    
    alertView.alertViewStyle = style;
    
    if (otherButtonTitles.count > 1) {
        for (NSString *buttonTitle in [otherButtonTitles subarrayWithRange:NSMakeRange(1, otherButtonTitles.count - 1)]) {
            [alertView addButtonWithTitle:buttonTitle];
        }
    }
    
    if (tapBlock) {
        alertView.tta_tapBlock = tapBlock;
    }
    
    [alertView show];
    
#if !__has_feature(objc_arc)
    return [alertView autorelease];
#else
    return alertView;
#endif
}


+ (instancetype)tta_showWithTitle:(NSString *)title
                          message:(NSString *)message
                cancelButtonTitle:(NSString *)cancelButtonTitle
                otherButtonTitles:(NSArray *)otherButtonTitles
                         tapBlock:(TTA_UIAlertViewCompletionBlock)tapBlock {
    
    return [self tta_showWithTitle:title
                           message:message
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:cancelButtonTitle
                 otherButtonTitles:otherButtonTitles
                          tapBlock:tapBlock];
}

#pragma mark -

- (void)__tta_checkAlertViewDelegate__ {
    if (self.delegate != (id<UIAlertViewDelegate>)self) {
        objc_setAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey, self.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.delegate = (id<UIAlertViewDelegate>)self;
    }
}

- (TTA_UIAlertViewCompletionBlock)tta_tapBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewTapBlockKey);
}

- (void)setTta_tapBlock:(TTA_UIAlertViewCompletionBlock)tapBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewTapBlockKey, tapBlock, OBJC_ASSOCIATION_COPY);
}

- (TTA_UIAlertViewCompletionBlock)tta_willDismissBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewWillDismissBlockKey);
}

- (void)setTta_willDismissBlock:(TTA_UIAlertViewCompletionBlock)willDismissBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewWillDismissBlockKey, willDismissBlock, OBJC_ASSOCIATION_COPY);
}

- (TTA_UIAlertViewCompletionBlock)tta_didDismissBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewDidDismissBlockKey);
}

- (void)setTta_didDismissBlock:(TTA_UIAlertViewCompletionBlock)didDismissBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewDidDismissBlockKey, didDismissBlock, OBJC_ASSOCIATION_COPY);
}

- (TTA_UIAlertViewBlock)tta_willPresentBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewWillPresentBlockKey);
}

- (void)setTta_willPresentBlock:(TTA_UIAlertViewBlock)willPresentBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewWillPresentBlockKey, willPresentBlock, OBJC_ASSOCIATION_COPY);
}

- (TTA_UIAlertViewBlock)tta_didPresentBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewDidPresentBlockKey);
}

- (void)setTta_didPresentBlock:(TTA_UIAlertViewBlock)didPresentBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewDidPresentBlockKey, didPresentBlock, OBJC_ASSOCIATION_COPY);
}

- (TTA_UIAlertViewBlock)tta_cancelBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewCancelBlockKey);
}

- (void)setTta_cancelBlock:(TTA_UIAlertViewBlock)cancelBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewCancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
}

- (void)setTta_shouldEnableFirstOtherButtonBlock:(BOOL(^)(UIAlertView *alertView))shouldEnableFirstOtherButtonBlock {
    [self __tta_checkAlertViewDelegate__];
    objc_setAssociatedObject(self, TTA_UIAlertViewShouldEnableFirstOtherButtonBlockKey, shouldEnableFirstOtherButtonBlock, OBJC_ASSOCIATION_COPY);
}

- (BOOL(^)(UIAlertView *alertView))tta_shouldEnableFirstOtherButtonBlock {
    return objc_getAssociatedObject(self, TTA_UIAlertViewShouldEnableFirstOtherButtonBlockKey);
}

#pragma mark - UIAlertViewDelegate

- (void)willPresentAlertView:(UIAlertView *)alertView {
    TTA_UIAlertViewBlock block = alertView.tta_willPresentBlock;
    
    if (block) {
        block(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [originalDelegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    TTA_UIAlertViewBlock block = alertView.tta_didPresentBlock;
    
    if (block) {
        block(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [originalDelegate didPresentAlertView:alertView];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    TTA_UIAlertViewBlock block = alertView.tta_cancelBlock;
    
    if (block) {
        block(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertViewCancel:)]) {
        [originalDelegate alertViewCancel:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    TTA_UIAlertViewCompletionBlock completion = alertView.tta_tapBlock;
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [originalDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    TTA_UIAlertViewCompletionBlock completion = alertView.tta_willDismissBlock;
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [originalDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    TTA_UIAlertViewCompletionBlock completion = alertView.tta_didDismissBlock;
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [originalDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    BOOL(^__tta_shouldEnableFirstOtherButtonBlock__)(UIAlertView *alertView) = alertView.tta_shouldEnableFirstOtherButtonBlock;
    
    if (__tta_shouldEnableFirstOtherButtonBlock__) {
        return __tta_shouldEnableFirstOtherButtonBlock__(alertView);
    }
    
    id originalDelegate = objc_getAssociatedObject(self, TTA_UIAlertViewOriginalDelegateKey);
    if (originalDelegate && [originalDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
        return [originalDelegate alertViewShouldEnableFirstOtherButton:alertView];
    }
    
    return YES;
}

@end
