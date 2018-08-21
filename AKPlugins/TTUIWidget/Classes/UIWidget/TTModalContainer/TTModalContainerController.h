//
//  TTModalContainerController.h
//  Article
//
//  Created by muhuai on 2017/4/6.
//
//

#import <Foundation/Foundation.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TTModalWrapController.h"

@class TTModalContainerController;

@protocol TTModalContainerDelegate <NSObject>

@optional

- (void)beginDismissModalContainerController:(TTModalContainerController *)container;

- (void)willDismissModalContainerController:(TTModalContainerController *)container;

- (void)didDismissModalContainerController:(TTModalContainerController *)container;

- (void)dismissAnimationDidComplete:(TTModalContainerController *)container;

- (void)slideDownScrollViewWillDismiss;

- (void)tapTitleViewCloseButtonWillDismiss;

@end

@interface TTModalContainerController : TTNavigationController

@property (nonatomic, weak) id<TTModalContainerDelegate> containerDelegate;

- (instancetype)initWithRootViewController:(UIViewController<TTModalWrapControllerProtocol> *)rootViewController;

- (void)setTopPadding:(CGFloat)topPadding;//默认为statusBar的高度
- (void)setNavVCViewInitAtBottom:(BOOL)flag;//默认在下面，在viewDidLoad之前设置有效
- (void)setMaskViewBackgroundColor:(UIColor *)color;//默认50%透明度黑色
- (void)insideNavigationControllerPopToRootViewControllerAnimated:(BOOL)animated;

@end
