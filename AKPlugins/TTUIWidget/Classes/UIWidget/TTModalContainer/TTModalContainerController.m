//
//  TTModalContainerController.m
//  Article
//
//  Created by muhuai on 2017/4/6.
//
//

#import "TTModalContainerController.h"
#import "TTModalInsideNavigationController.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import "SSThemed.h"

@interface TTModalContainerRootController : SSViewControllerBase<TTModalInsideNavigationDelegate>
@property (nonatomic, strong) UIViewController<TTModalWrapControllerProtocol> *detailVC;
@property (nonatomic, strong) TTModalInsideNavigationController *navVC;
@property (nonatomic, strong) SSThemedView *maskView;
@property (nonatomic, assign) BOOL hasEntered;
@property (nonatomic, assign) UIStatusBarStyle origStatusBarStyle;//保存之前的StatusBar样式, dismiss后恢复
@property (nonatomic, assign) CGFloat topPadding;//支持设置，需要再viewDidLoad之前设置
@property (nonatomic, assign) BOOL navVCViewInitAtBottom;
@end

@implementation TTModalContainerRootController


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller {
    self = [super init];
    if (self) {
        _detailVC = controller;
        _maskView = [[SSThemedView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithHexString:@"0000007f"];
        CGFloat topPadding = 0;
        if (@available(iOS 11.0, *)) {
            topPadding = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
        }
        if (topPadding <= 0){
            topPadding = 20.f;
        }
        _topPadding = topPadding;
        _navVCViewInitAtBottom = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.ttNeedIgnoreZoomAnimation = YES;
    self.ttHideNavigationBar = YES;
    self.navVC = [[TTModalInsideNavigationController alloc] initWithRootViewController:self.detailVC];
    self.navVC.modalNavigationDelegate = self;
    [self.navVC willMoveToParentViewController:self];
    [self addChildViewController:self.navVC];
    [self.view addSubview:self.navVC.view];
    [self.navVC didMoveToParentViewController:self];
    self.navVC.view.frame = CGRectMake(0, self.topPadding, [[UIScreen mainScreen] bounds].size.width, self.view.height - self.topPadding);
    self.maskView.frame = self.view.bounds;
    self.maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.maskView.layer.opacity = 0;
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.navVC.view];
    
    if (self.navVCViewInitAtBottom) {
        self.navVC.view.top = self.view.bottom;
    }

    self.origStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self _showEnterAnimationIfNeed];
}

- (void)_showEnterAnimationIfNeed {
    if (self.hasEntered) {
        return;
    }
    if (self.navVC.view.top == self.topPadding) {
        return;
    }
    self.hasEntered = YES;
    [UIView animateWithDuration:0.35f customTimingFunction:CustomTimingFunctionQuadIn delay:0.f usingSpringWithDamping:0.92f initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navVC.view.top = self.topPadding;
        self.maskView.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.detailVC.view.backgroundColor = [UIColor clearColor];
    }];
}

- (void)updateProgress:(CGFloat)progress {
    self.maskView.alpha = 1 - progress;
}

- (void)dismissViewController {
    TTModalContainerController *container = [self.navigationController isKindOfClass:[TTModalContainerController class]]? (TTModalContainerController *)self.navigationController: nil;
    //偷懒了...没有再开一层delegate出去.
    //这个是内部类. 这么搞也没事😝
    if ([container.containerDelegate respondsToSelector:@selector(willDismissModalContainerController:)]) {
        [container.containerDelegate willDismissModalContainerController:container];
    }
    void (^completion)(BOOL) = ^void(BOOL finished) {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:self.origStatusBarStyle];
            if ([container.containerDelegate respondsToSelector:@selector(didDismissModalContainerController:)]) {
                [container.containerDelegate didDismissModalContainerController:container];
            }
        }];
        
        if ([container.containerDelegate respondsToSelector:@selector(dismissAnimationDidComplete:)]) {
            [container.containerDelegate dismissAnimationDidComplete:container];
        }
    };
    
    if (self.navVC.view.top >= self.view.bottom) {
        completion(YES);
        return;
    }
    [UIView animateWithDuration:0.15f customTimingFunction:CustomTimingFunctionQuadIn animation:^{
        self.navVC.view.top = self.view.bottom;
        self.maskView.alpha = 0.f;
    } completion:completion];
}

#pragma mark - TTModalInsideNavigationDelegate
- (void)modalInsideNavigationController:(TTModalInsideNavigationController *)modalNavigationController closeButtonOnClick:(id)sender {
    TTModalContainerController *container = [self.navigationController isKindOfClass:[TTModalContainerController class]]? (TTModalContainerController *)self.navigationController: nil;
    if (sender) {
        if ([container.containerDelegate respondsToSelector:@selector(tapTitleViewCloseButtonWillDismiss)]) {
            [container.containerDelegate tapTitleViewCloseButtonWillDismiss];
        }
    } else {
        if ([container.containerDelegate respondsToSelector:@selector(slideDownScrollViewWillDismiss)]) {
            [container.containerDelegate slideDownScrollViewWillDismiss];
        }
    }
    [self dismissViewController];
}

- (void)modalInsideNavigationController:(TTModalInsideNavigationController *)modalNavigationController panAtPercent:(CGFloat)percent {
    [self updateProgress:percent];
    
    TTModalContainerController *container = [self.navigationController isKindOfClass:[TTModalContainerController class]]? (TTModalContainerController *)self.navigationController: nil;
    //偷懒了...没有再开一层delegate出去.
    //这个是内部类. 这么搞也没事😝
    if ([container.containerDelegate respondsToSelector:@selector(beginDismissModalContainerController:)]) {
        [container.containerDelegate beginDismissModalContainerController:container];
    }
}

- (void)setTopPadding:(CGFloat)topPadding
{
    _topPadding = topPadding;
    
    self.navVC.view.frame = CGRectMake(0, _topPadding, [[UIScreen mainScreen] bounds].size.width, self.view.height - _topPadding);
}

- (void)insideNavigationControllerPopToRootViewControllerAnimated:(BOOL)animated
{
    [self.navVC popToRootViewControllerAnimated:animated];
}

@end

@interface TTModalContainerController ()

@property (nonatomic, strong) TTModalContainerRootController *rootController;

@end

@implementation TTModalContainerController

- (instancetype)initWithRootViewController:(UIViewController<TTModalWrapControllerProtocol> *)rootViewController {
    TTModalContainerRootController *rootController = [self wrapModalController:rootViewController];
    self = [super initWithRootViewController:rootController];
    if (self) {
        _rootController = rootController;
        if (@available(iOS 8.0, *)) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
    }
    return self;
}

- (TTModalContainerRootController *)wrapModalController:(UIViewController<TTModalWrapControllerProtocol> *)rootViewController {
    return [[TTModalContainerRootController alloc] initWithController:rootViewController];
}

- (void)setTopPadding:(CGFloat)topPadding
{
    self.rootController.topPadding = topPadding;
}

- (void)setNavVCViewInitAtBottom:(BOOL)flag
{
    self.rootController.navVCViewInitAtBottom = flag;
}

- (void)setMaskViewBackgroundColor:(UIColor *)color
{
    self.rootController.maskView.backgroundColor = color;
}

- (void)insideNavigationControllerPopToRootViewControllerAnimated:(BOOL)animated
{
    [self.rootController insideNavigationControllerPopToRootViewControllerAnimated:animated];
}

@end
