//
//  TTModalWrapController.m
//  Article
//
//  Created by muhuai on 2017/4/5.
//
//

#import "TTModalWrapController.h"
#import <KVOController/KVOController.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import <TTBaseLib/NSObject+MultiDelegates.h>

#import "TTModalInsideNavigationController.h"

#import <objc/runtime.h>
#define TTEdgeHeight 44.f


@interface TTModalWrapController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIViewController<TTModalWrapControllerProtocol> *nestedController;
@property (nonatomic, strong) UIScrollView *nestedContollerScrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) BOOL allowGesture;
@property (nonatomic, assign) BOOL isPortraitPanGesture;
@property (nonatomic, assign) CGFloat beginDragContentOffsetY;
@property (nonatomic, assign) CGFloat origNaiVCTopPadding;
@property (nonatomic, strong, readwrite) UIView<TTModalWrapControllerTitleViewProtocol> *titleView;
@property (nonatomic, strong) UIView <TTModalWrapControllerTitleViewProtocol>*configureTitleView;
@property (nonatomic, strong) UIGestureRecognizer *disabledGesture;//自己的panGesture生效的时候，把这个禁用掉。

@end

@implementation TTModalWrapController

- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller {
    return [self initWithController:controller disabledGesture:nil];
}
- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller disabledGesture:(UIGestureRecognizer *)disabledGesture {
    self = [self init];
    if (self) {
        if ([controller conformsToProtocol:@protocol(TTModalWrapControllerProtocol)]) {
            _nestedController = controller;
        } else {
            NSAssert(NO, @"controller need conforms TTModalWrapControllerProtocol");
        }
        _disabledGesture = disabledGesture;
        if ([controller respondsToSelector:@selector(tt_modalWrapperTitleViewHidden)]) {
            _titleViewHidden = [controller tt_modalWrapperTitleViewHidden];
        } else {
            _titleViewHidden = NO;
        }
        
        if ([_nestedController respondsToSelector:@selector(setModalWrapContainer:)]) {
            [_nestedController setModalWrapContainer:self];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ttHideNavigationBar = YES;
    self.ttNeedIgnoreZoomAnimation = YES;
    
    if ([self.nestedController respondsToSelector:@selector(setHasNestedInModalContainer:)]) {
        [self.nestedController setHasNestedInModalContainer:YES];
    }

    
    [self.view addSubview:self.titleView];
    self.titleView.width = self.view.width;
    self.titleView.hidden = self.titleViewHidden;
    
    [self.nestedController willMoveToParentViewController:self];
    [self addChildViewController:self.nestedController];
    self.nestedController.view.height = self.view.height - (self.titleViewHidden ? 0 : self.titleView.height);
    self.nestedController.view.top = (self.titleViewHidden ? 0 : self.titleView.bottom);
    self.nestedController.view.left = 0;
    self.nestedController.view.width = self.view.width;
    self.nestedController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.nestedController.ttStatusBarStyle = UIStatusBarStyleLightContent;
    [self.view addSubview:self.nestedController.view];
    [self.nestedController didMoveToParentViewController:self];
    
    if ([self.nestedController respondsToSelector:@selector(tt_scrollView)]) {
        self.nestedContollerScrollView = [self.nestedController tt_scrollView];
    }
    
    [self.nestedContollerScrollView tt_addDelegate:self asMainDelegate:NO];
    [self _setupGesture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.titleView.frame = CGRectMake(self.titleView.origin.x, self.titleView.origin.y, self.view.width, self.titleView.height);
    self.nestedController.view.height = self.view.height - (self.titleViewHidden ? 0 : self.titleView.height);
    self.nestedController.view.top = (self.titleViewHidden ? 0 : self.titleView.bottom);
    self.nestedController.view.left = 0;
    self.nestedController.view.width = self.view.width;
}

- (void)_setupGesture {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlerPanGesture:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - TTModalWrappedViewProtocol
- (void)refreshModalContainerTitleView {
    if ([self.nestedController respondsToSelector:@selector(leftBarItemStyle)]) {
        self.titleView.type = [self.nestedController leftBarItemStyle];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
        self.allowGesture = YES;
    }
    else {
        self.allowGesture = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginDragContentOffsetY = scrollView.contentOffset.y;
}

#pragma mark - Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        self.isPortraitPanGesture = fabs([pan velocityInView:pan.view].y) > fabs([pan velocityInView:pan.view].x);
        if (!self.isPortraitPanGesture && [self.nestedController respondsToSelector:@selector(shouldDisableRightSwipeGesture)]) {
            return ![self.nestedController shouldDisableRightSwipeGesture];
        }
    }
    return YES;
}

- (void)doHandlerPanGesture:(UIPanGestureRecognizer *)recognizer {
    if (!self.panGestureRecognizer.enabled) {
        return;
    }
    CGPoint point = [recognizer translationInView:self.view];
    CGPoint location = [recognizer locationInView:self.view];
    CGFloat progressY = [recognizer translationInView:recognizer.view].y / recognizer.view.height;
    CGFloat progressX = [recognizer translationInView:recognizer.view].x / recognizer.view.width;
    CGFloat progress = self.isPortraitPanGesture ? progressY : progressX;
    if (progress > 1) { progress = 1; }
    if (progress < 0) { progress = 0; }
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        self.origNaiVCTopPadding = self.navigationController.view.top;
        if (location.y <= TTEdgeHeight) {
            //点击范围在标题栏，标志位清零
            self.allowGesture = YES;
            self.beginDragContentOffsetY = 0;
        }
        if (!self.isPortraitPanGesture) {
            self.nestedContollerScrollView.scrollEnabled = NO;
        }
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        if (self.isPortraitPanGesture) {
            if (self.allowGesture) {
                CGFloat diff = point.y - self.beginDragContentOffsetY;
                if (diff < 0) {
                    diff = 0;
                }
                self.nestedContollerScrollView.scrollEnabled = NO;
                self.navigationController.view.top = self.origNaiVCTopPadding + diff;
                [self panAtPercent:diff / self.navigationController.view.height];
            }
        }
        else {
            CGFloat diff = [recognizer translationInView:recognizer.view].x;
            if (diff < 0) {
                diff = 0;
            }
            self.view.left = diff;
//            self.navigationController.view.layer.mask = nil;
            [self panAtPercent:diff / self.navigationController.view.height];
        }
        //这个下面神奇的代码，慎改，作用是，如果是内嵌的nav里面的view，则通过讲enabled设为no的方式干掉gesture，之后也不会走ended和canceled的状态了。
        //如果触动TTNavigationController右滑动画，取消当前gesture
        //这种判断方法也是 神奇
        if ([self innerTransitionView].left != 0) {
            recognizer.view.top = 0;
            self.panGestureRecognizer.enabled = NO;
            self.panGestureRecognizer.enabled = YES;
            self.nestedContollerScrollView.scrollEnabled = YES;
        }
    } else if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled) {
        if (self.isPortraitPanGesture) {
            CGFloat vy = [recognizer velocityInView:recognizer.view].y;
            BOOL complete = ((vy > -100 && progress > 0.3) || vy > 500);
            if (self.allowGesture && complete) {
                [UIView animateWithDuration:0.15 customTimingFunction:CustomTimingFunctionQuadIn animation:^{
                    self.navigationController.view.top += self.navigationController.view.height;
                    [self panAtPercent:100];
                } completion:^(BOOL finished) {
                    [self dismissModalController:nil];
                }];
            } else {
                [UIView animateWithDuration:0.15f animations:^{
                    self.navigationController.view.top = self.origNaiVCTopPadding;
                    [self panAtPercent:0];
                } completion:^(BOOL finished) {
                    if (self.nestedContollerScrollView) {
                        self.allowGesture = NO;
                    } else {
                        self.allowGesture = YES;
                    }
                    self.nestedContollerScrollView.scrollEnabled = YES;
                }];
            }
        }
        else {
            CGFloat vx = [recognizer velocityInView:recognizer.view].x;
            BOOL complete = (progress > 0.3 || vx > 500);
            if (complete) {
                [UIView animateWithDuration:0.15 customTimingFunction:CustomTimingFunctionQuadIn animation:^{
                    self.view.left += self.view.width;
                    [self panAtPercent:100];
                } completion:^(BOOL finished) {
                    [self dismissModalController:nil];
                    WeakSelf;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        StrongSelf;
                        if (self.view) {
                            self.view.frame = CGRectMake(0, 0, self.view.width, self.view.height);
                        }
                    });

                }];
            } else {
                [UIView animateWithDuration:0.15f animations:^{
                    self.view.left = 0;
                    [self panAtPercent:0];
                } completion:^(BOOL finished) {
                    self.nestedContollerScrollView.scrollEnabled = YES;
                }];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isEqual:self.disabledGesture]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"other:%@", otherGestureRecognizer);
    if (otherGestureRecognizer.view == self.nestedContollerScrollView) {
        return YES;
    }
    
    if ([self.nestedController respondsToSelector:@selector(simultaneouslyPullGestureViews)]) {
        for (UIView *simultaneouslyView in self.nestedController.simultaneouslyPullGestureViews) {
            if (otherGestureRecognizer.view == simultaneouslyView) {
                return YES;
            }
        }
    }
    
    if ([NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"UILayoutContainerView"]) {
        CGPoint location = [gestureRecognizer locationInView:self.view];
        //如果点击范围在标题栏，不响应TTNavigationController手势
        if (location.y <= TTEdgeHeight) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

- (void)panAtPercent:(CGFloat)percent {
    if ([self.delegate respondsToSelector:@selector(modalWrapController:panAtPercent:)]) {
        [self.delegate modalWrapController:self panAtPercent:percent];
    }
}

- (void)dismissModalController:(id)sender {
    if ([self.delegate respondsToSelector:@selector(modalWrapController:closeButtonOnClick:)]) {
        [self.delegate modalWrapController:self closeButtonOnClick:sender];
    }
}

- (void)popToLastModalController {
    if ([self.nestedController respondsToSelector:@selector(shouldInterceptBackBarItemInModalContainer)]) {
        if ([self.nestedController shouldInterceptBackBarItemInModalContainer]) {
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(modalWrapController:backButtonOnClick:)]) {
        [self.delegate modalWrapController:self backButtonOnClick:nil];
    }
    
}
#pragma mark - Utils
- (UIView *)innerTransitionView {
    for (UIView *subview in self.navigationController.view.subviews) {
        if ([subview isMemberOfClass:NSClassFromString(@"UINavigationTransitionView")]) {
            return subview;
        }
    }
    return nil;
}

- (UIView<TTModalWrapControllerTitleViewProtocol> *)titleView {
    if (!_titleView) {
        // 判断是否实现了tt_modalWrapTitleView，自定义titleView，否则初始化一个默认的值
        if ([self.nestedController respondsToSelector:@selector(tt_modalWrapTitleView)]) {
            UIView<TTModalWrapControllerTitleViewProtocol> *nestTitleView = [self.nestedController tt_modalWrapTitleView];
            // 保底一下类型，虽然感觉没啥必要
            if ([nestTitleView isKindOfClass:[UIView class]] && [nestTitleView conformsToProtocol:@protocol(TTModalWrapControllerTitleViewProtocol)]) {
                _titleView = nestTitleView;
                if ([self.nestedController respondsToSelector:@selector(tt_modalWrapTitleViewHeight)]) {
                    CGFloat height = [self.nestedController tt_modalWrapTitleViewHeight];
                    if (height < 0) {
                        height = 0;
                    }
                    _titleView.frame = CGRectMake(0, 0, 0, height);
                    WeakSelf;
                    _titleView.closeComplete = ^(UIButton *sender) {
                        StrongSelf;
                        [self dismissModalController:sender];
                    };
                    _titleView.backComplete = ^{
                        StrongSelf;
                        [self popToLastModalController];
                    };
                }
            }
         }
         if (!_titleView) {
             // 如果没有自定义，走默认值
             //自定义标题栏
             _titleView = [[TTModalControllerTitleView alloc] init];
             _titleView.type = TTModalControllerTitleTypeOnlyClose;
             WeakSelf;

             [self.KVOController observe:self.nestedController keyPath:@"title" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                 StrongSelf;
                 NSString *title = [change tt_stringValueForKey:NSKeyValueChangeNewKey];
                 [(TTModalControllerTitleView *)self.titleView setTitle:title];
             }];
             _titleView.closeComplete = ^(UIButton *sender) {
                 StrongSelf;
                 [self dismissModalController:sender];
             };
             _titleView.backComplete = ^{
                 StrongSelf;
                 [self popToLastModalController];
             };
         }
     }
     return _titleView;
}

@end



@implementation UIViewController (ModelControllerWrapper)

- (void)setTt_modalWrapperTitleViewHidden:(BOOL)tt_modalWrapperTitleViewHidden
{
    objc_setAssociatedObject(self, @selector(tt_modalWrapperTitleViewHidden), @(tt_modalWrapperTitleViewHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tt_modalWrapperTitleViewHidden
{
    NSNumber *hiddenNumber = objc_getAssociatedObject(self, _cmd);
    if (hiddenNumber && [hiddenNumber respondsToSelector:@selector(boolValue)]) {
        return [hiddenNumber boolValue];
    }
    return NO;
}

- (void)setTt_modalWrapTitleView:(UIView *)tt_modalWrapTitleView {
    objc_setAssociatedObject(self, @selector(tt_modalWrapTitleView), tt_modalWrapTitleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)tt_modalWrapTitleView {
    UIView *result = objc_getAssociatedObject(self, @selector(tt_modalWrapTitleView));
    return result;
}

- (void)setTt_modalWrapTitleViewHeight:(CGFloat)tt_modalWrapTitleViewHeight {
    objc_setAssociatedObject(self, @selector(tt_modalWrapTitleViewHeight), @(tt_modalWrapTitleViewHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)tt_modalWrapTitleViewHeight {
    NSNumber *result = objc_getAssociatedObject(self, @selector(tt_modalWrapTitleViewHeight));
    CGFloat height = result.floatValue;
    return height;
}

@end
