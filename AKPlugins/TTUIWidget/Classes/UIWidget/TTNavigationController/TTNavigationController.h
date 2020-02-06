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
#if __has_include(<BDMobileRuntime/BDNavigationController.h>)
    #import <BDMobileRuntime/BDNavigationController.h>
#endif

typedef enum {
    TT_PUSH_FADE,
    TT_PUSH_DIRECTION_DOWN,
    TT_PUSH_DIRECTION_UP,
} TT_PUSH_STYLE;

#if __has_include(<BDMobileRuntime/BDNavigationController.h>)
@interface TTNavigationController : BDNavigationController
#else
@interface TTNavigationController : UINavigationController
#endif

#define TTNavigationControllerDefaultSwapLeftEdge ([UIScreen mainScreen].bounds.size.width / 6)

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeRecognizer;
@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;
@property (nonatomic, assign) BOOL shouldIgnoreBackGroundColor;

+ (BOOL)refactorNaviEnabled;//是否使用重构之后的NavigationController 默认不

//snapShot的crash优化：https://blog.csdn.net/lizitao/article/details/74857890
+ (void)optimizeSnapshotEnable:(BOOL)enable;  
+ (void)setIgnorePushVCThrottleTimer:(float)throttleTimer;
+ (void)fixWKGestureConflictEnable:(BOOL)enable;

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

@property (nonatomic, assign) BOOL forbidPanGesture DEPRECATED_MSG_ATTRIBUTE("该属性将要废弃，请使用 ttDisableDragBack");// 当前VC禁用滑动返回手势
@property (nonatomic, copy) void(^panBeginAction)(void);
@property (nonatomic, copy) void(^panRestoreAction)(void);
@property (nonatomic, copy) void(^panPopDoneAction)(void);
- (void)pushAnimationCompletion;
@end

//提供兜底默认行为，防crash
//https://slardar.bytedance.net/node/app_detail/?aid=13&os=iOS&region=cn#/abnormal/detail/crash/13_2d766a4382180981c15a3137a78a3217?params=%7B%22start_time%22%3A1565232600%2C%22end_time%22%3A1565837400%2C%22event_index%22%3A1%7D
@interface UINavigationController (TTCommonFix)

- (void)pushViewControllerByTransitioningAnimation:(UIViewController *)viewController animated:(BOOL)animated;

@end
