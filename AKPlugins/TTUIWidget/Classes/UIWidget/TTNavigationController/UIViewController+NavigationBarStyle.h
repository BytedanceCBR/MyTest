//
//  UIViewController+NavigationBarConfig.h
//  TestUniversaliOS6
//
//  Created by yuxin on 3/26/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SSThemedView;

#define TTNavigationBarHeight 44.f
@interface TTNavigationBar : UINavigationBar

@property (nonatomic, weak)     UIViewController *viewController;
@property (nonatomic, strong)   UINavigationItem * item;

- (void)tt_configNavBarWithTheme:(NSString *)style;

@end

@interface UIViewController (NavigationBarConfig)

@property (nonatomic, copy) IBInspectable NSString * ttNavBarStyle;

@property (nonatomic, assign) IBInspectable  BOOL ttHideNavigationBar;

@property (nonatomic, assign) IBInspectable  NSInteger ttStatusBarStyle;

@property (nonatomic, assign) IBInspectable  BOOL ttDisableDragBack;

@property (nonatomic, assign) IBInspectable  BOOL ttDragToRoot;

@property (nonatomic, assign) BOOL ttNeedChangeNavBar;

@property (nonatomic, strong) TTNavigationBar *ttNavigationBar;

@property (nonatomic, assign) BOOL ttNeedHideBottomLine;//是否隐藏底下那条线

@property (nonatomic, assign) BOOL ttNeedTopExpand;//是否延伸到状态栏下面

@property (nonatomic, assign) BOOL ttNaviTranslucent;//导航栏是否透明

@property (nonatomic, assign) BOOL ttNeedIgnoreZoomAnimation;//是否忽略转场缩放动画 默认不忽略

@end
