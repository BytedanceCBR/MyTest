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
@property (nonatomic, assign) CGFloat topPadding;//支持设置，需要再viewDidLoad之前设置
@property (nonatomic, assign) BOOL navVCViewInitAtBottom;
@property (nonatomic, strong) UIGestureRecognizer *disabledGesture;//外界传入一个Gesture，需要将其禁止掉。
@property (nonatomic, assign) BOOL timorFix;

@end

@implementation TTModalContainerRootController


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller disabledGesture:(UIGestureRecognizer *)disabledGesture {
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
        _disabledGesture = disabledGesture;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.ttNeedIgnoreZoomAnimation = YES;
    self.ttHideNavigationBar = YES;
    self.navVC = [[TTModalInsideNavigationController alloc] initWithRootViewController:self.detailVC disabledGesture:self.disabledGesture];
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

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self _showEnterAnimationIfNeed];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)_showEnterAnimationIfNeed {
    if (self.hasEntered) {
        return;
    }
    if (self.navVC.view.top == self.topPadding) {
        if (self.timorFix) {
            self.maskView.alpha = 1.f;
        }
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

- (void)setTimorFix:(BOOL)timorFix
{
    _timorFix = timorFix;
}

- (void)dismissViewController {
    TTModalContainerController *container = [self.navigationController isKindOfClass:[TTModalContainerController class]]? (TTModalContainerController *)self.navigationController: nil;
    //偷懒了...没有再开一层delegate出去.
    //这个是内部类. 这么搞也没事😝
    if ([container.containerDelegate respondsToSelector:@selector(willDismissModalContainerController:)]) {
        [container.containerDelegate willDismissModalContainerController:container];
    }
    void (^completion)(BOOL) = ^void(BOOL finished) {
        // 有些业务方不是通过present的方式 打开的 ModalContainer, 有可能是通过addChildVC的方式打开的。
        // 如果当前的presentingVC 和 parent 的 presentingVC 是用一个VC , 就是通过addChildVC的方式打开。
        if (self.timorFix && self.presentingViewController && self.presentingViewController == self.navigationController.parentViewController.presentingViewController) {
            [self.navigationController removeFromParentViewController];
            [self.navigationController.view removeFromSuperview];
            if ([container.containerDelegate respondsToSelector:@selector(didDismissModalContainerController:)]) {
                [container.containerDelegate didDismissModalContainerController:container];
            }
        } else {
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                if ([container.containerDelegate respondsToSelector:@selector(didDismissModalContainerController:)]) {
                    [container.containerDelegate didDismissModalContainerController:container];
                }
            }];
        }
        
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
    
    // 如果初始的时候不是在bottom 才需要设置topPadding
    if (self.timorFix) {
        if (!self.navVCViewInitAtBottom) {
            self.navVC.view.frame = CGRectMake(0, _topPadding, [[UIScreen mainScreen] bounds].size.width, self.view.height - _topPadding);
        }
    } else {
        self.navVC.view.frame = CGRectMake(0, _topPadding, [[UIScreen mainScreen] bounds].size.width, self.view.height - _topPadding);
    }
    
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
    return [self initWithRootViewController:rootViewController disabledGesture:nil];
}

- (instancetype)initWithRootViewController:(UIViewController<TTModalWrapControllerProtocol> *)rootViewController disabledGesture:(UIGestureRecognizer *)gestureRecognizer {
    TTModalContainerRootController *rootController = [[TTModalContainerRootController alloc] initWithController:rootViewController disabledGesture:gestureRecognizer];
    self = [super initWithRootViewController:rootController];
    if (self) {
        _rootController = rootController;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)setTopPadding:(CGFloat)topPadding
{
    self.rootController.topPadding = topPadding;
}

- (void)setTimorFix:(BOOL)timorFix
{
    _timorFix = timorFix;
    self.rootController.timorFix = timorFix;
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

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (self.timorFix && animated) {
        [self.rootController dismissViewController];
    } else {
        [super dismissViewControllerAnimated:animated completion:completion];
    }
}

@end
