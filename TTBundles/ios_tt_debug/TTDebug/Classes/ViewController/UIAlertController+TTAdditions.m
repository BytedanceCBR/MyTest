//
//  UIAlertController+TTAdditions.m
//  TTBaseLib
//
//  Created by Jiang Jingtao on 2019/8/13.
//

#import "UIAlertController+TTAdditions.h"
#import "TTUIResponderHelper.h"

@implementation UIAlertController (TTAdditions)

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle sourceView:(UIView *)sourceView
{
    NSAssert(sourceView, @"sourceView is nil");
    if (!sourceView) {
        sourceView = [TTUIResponderHelper mainWindow];
    }
    return [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle sourceView:sourceView sourceRect:sourceView.bounds];
}

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect
{
    NSAssert(sourceView, @"sourceView is nil");
    if (!sourceView) {
        sourceView = [TTUIResponderHelper mainWindow];
        sourceRect = [TTUIResponderHelper mainWindow].bounds;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = sourceView;
        popPresenter.sourceRect = sourceRect;
        popPresenter.permittedArrowDirections = 0;
    }
    return alert;
}

@end
