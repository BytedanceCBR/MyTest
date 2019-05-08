//
//  UIAlertView+FHAlertView.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/28.
//

#import "UIAlertView+FHAlertView.h"
#import <objc/runtime.h>
#import <objc/message.h>

static char dismissBlockKey;
static char cancelBlockKey;


@implementation UIAlertView (FHAlertView)

+ (UIAlertView *)fh_showAlertViewWithTitle:(NSString *)title
                                    message:(NSString *)message
                          cancelButtonTitle:(NSString *)cancelButtonTitle
                          otherButtonTitles:(NSArray *)titleArray
                                  dismissed:(FHAlertViewDismissBlock)dismissBlock
                                   canceled:(FHAlertViewCancelBlock)cancelBlock
{
    if (!title) {
        title = @"";
    }
    // For Extension which cannot use initXXX method
    UIAlertView *alertView = [NSClassFromString(@"UIAlertView") alloc];
    ((void (*)(id, SEL, NSString *, NSString *, id, id, id))objc_msgSend)((id)alertView, @selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:), title, message, nil, cancelButtonTitle, nil);

    for (NSString *buttonTitle in titleArray) {
        [alertView addButtonWithTitle:buttonTitle];
    }
    alertView.delegate = alertView;
    [alertView fh_setCancelBlock:cancelBlock];
    [alertView fh_setDismissBlock:dismissBlock];

    [alertView show];
    return alertView;
}

+ (UIAlertView *)fh_showAlertViewWithTitle:(NSString *)message
{
    return [self fh_showAlertViewWithTitle:@""
                                    message:message
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil
                                  dismissed:NULL
                                   canceled:NULL];
}

- (id)fh_cancelBlock
{
    return objc_getAssociatedObject(self, &cancelBlockKey);
}

- (void)fh_setCancelBlock:(void (^)())cancelBlock
{
    objc_setAssociatedObject(self, &cancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
}

- (id)fh_dismissBlock
{
    return objc_getAssociatedObject(self, &dismissBlockKey);
}

- (void)fh_setDismissBlock:(void (^)(NSInteger index))dismissBlock
{
    objc_setAssociatedObject(self, &dismissBlockKey, dismissBlock, OBJC_ASSOCIATION_COPY);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        void (^cancelBlock)() = [self fh_cancelBlock];
        if (cancelBlock) {
            cancelBlock();
        }
    } else {
        void (^dismissBlock)(NSInteger index) = [self fh_dismissBlock];
        if (dismissBlock) {
            dismissBlock(buttonIndex);
        }
    }
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

@end
