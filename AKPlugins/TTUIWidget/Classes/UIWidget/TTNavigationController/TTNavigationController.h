//
//  TTNavigationController.h
//  TestUniversaliOS6
//
//  Created by Nick Yu on 3/13/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+NavigationBarConfig.h"
#import "UIViewController+NavigationBarStyle.h"

typedef enum {
    TT_PUSH_FADE,
    TT_PUSH_DIRECTION_DOWN,
    TT_PUSH_DIRECTION_UP,
} TT_PUSH_STYLE;

@interface TTNavigationController : UINavigationController


@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeRecognizer;
@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;

+ (BOOL)refactorNaviEnabled;//是否使用重构之后的NavigationController 默认不

- (void)pushViewController:(UIViewController *)viewController
              animationTag:(NSInteger)animationTag
                 direction:(TT_PUSH_STYLE)direction
                  animated:(BOOL)animated;

//使用UIViewControllerTransitioning做自定义push pop
- (void)pushViewControllerByTransitioningAnimation:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)popViewControllerByTransitioningAnimationAnimated:(BOOL)animated;
@end


// TODO: 由于右滑返回实现，viewController生命周期相关的方法调用时机问题，暂时添加提供特定时机的逻辑注入
@interface UIViewController (PanLifeCycleBlock)

@property (nonatomic, copy) void(^panBeginAction)();
@property (nonatomic, copy) void(^panRestoreAction)();
- (void)pushAnimationCompletion;
@end
