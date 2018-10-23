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

#import <objc/runtime.h>
#define TTEdgeHeight 44.f

@interface TTModalWrapController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIViewController<TTModalWrapControllerProtocol> *nestedController;
@property (nonatomic, strong) UIScrollView *nestedContollerScrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) BOOL allowGesture;
@property (nonatomic, assign) BOOL isPortraitPanGesture;
@property (nonatomic, assign) CGFloat beginDragContentOffsetY;
@property (nonatomic, assign) CGFloat origNaiVCTopPadding;

@end

@implementation TTModalWrapController

- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller {
    self = [self init];
    if (self) {
        if ([controller conformsToProtocol:@protocol(TTModalWrapControllerProtocol)]) {
            _nestedController = controller;
        } else {
            NSAssert(NO, @"controller need conforms TTModalWrapControllerProtocol");
        }
        
        if ([controller respondsToSelector:@selector(tt_modalWrapperTitleViewHidden)]) {
            _titleViewHidden = [controller tt_modalWrapperTitleViewHidden];
        } else {
            _titleViewHidden = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.ttHideNavigationBar = YES;
    self.ttNeedIgnoreZoomAnimation = YES;
    
    if ([self.nestedController respondsToSelector:@selector(setHasNestedInModalContainer:)]) {
        [self.nestedController setHasNestedInModalContainer:YES];
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.KVOController observe:self.nestedController keyPath:@"title" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSString *title = [change tt_stringValueForKey:NSKeyValueChangeNewKey];
        [weakSelf.titleView setTitle:title];
    }];
    
    [self.view addSubview:self.titleView];
    self.titleView.hidden = self.titleViewHidden;
    
    [self.nestedController willMoveToParentViewController:self];
    [self addChildViewController:self.nestedController];
    self.nestedController.view.height = self.view.height - (self.titleViewHidden ? 0 : self.titleView.height);
    self.nestedController.view.top = (self.titleViewHidden ? 0 : self.titleView.bottom);
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

- (void)_setupGesture {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlerPanGesture:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
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
                [self panAtPercent:self.navigationController.view.top / self.navigationController.view.height];
            }
        }
        else {
            CGFloat diff = [recognizer translationInView:recognizer.view].x;
            if (diff < 0) {
                diff = 0;
            }
            self.view.frame = CGRectMake(diff, 0, self.view.width, self.view.height);
            self.navigationController.view.layer.mask = nil;
            [self panAtPercent:self.view.left / self.view.width];
        }
        //如果触动TTNavigationController右滑动画，取消当前gesture
        //这种判断方法也是 神奇
        if ([self innerTransitionView].left != 0) {
            recognizer.view.top = 0;
            self.panGestureRecognizer.enabled = NO;
            self.panGestureRecognizer.enabled = YES;
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
                } completion:^(BOOL finished) {
                    if (self.nestedContollerScrollView) {
                        self.allowGesture = NO;
                    } else {
                        self.allowGesture = YES;
                    }
                    self.nestedContollerScrollView.scrollEnabled = YES;
                    [self panAtPercent:0];
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
                }];
            } else {
                [UIView animateWithDuration:0.15f animations:^{
                    self.view.left = 0;
                } completion:^(BOOL finished) {
                    [self panAtPercent:0];
                    self.nestedContollerScrollView.scrollEnabled = YES;
                }];
            }
        }
    }
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

- (TTModalControllerTitleView *)titleView {
    if (!_titleView) {
        //自定义标题栏
        _titleView = [[TTModalControllerTitleView alloc] init];
        _titleView.type = TTModalControllerTitleTypeOnlyClose;
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

@end
