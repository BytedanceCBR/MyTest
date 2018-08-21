//
//  SSViewBase.h
//  Gallery
//
//  Created by 苏瑞强 on 17/3/10.
//  Copyright © 2017年 苏瑞强. All rights reserved.
//
#import <UIKit/UIKit.h>

/*
 *  将调整subview的代码写到ssLayoutSubviews中，
 *  父类中layoutSubviews 调用trySSLayoutSubviews
 */

typedef enum ModeChangeActionType
{
    ModeChangeActionTypeNone = 0, // do nothing
    ModeChangeActionTypeMask = 1 << 1, // add a mask for night mode
    ModeChangeActionTypeCustom = 1 << 2 //invoke themeChanged method for day/night mode change
}ModeChangeActionType;


@interface SSViewBase : UIView

@property (nonatomic, copy) NSString * backgroundColorThemeName;
@property(nonatomic, assign)ModeChangeActionType modeChangeActionType;

/**
 *  将要展示view
 *
 */
- (void)willAppear;

/**
 *  已经展示view
 *
 */
- (void)didAppear;

/**
 *  视图将要消失，类似于viewcontroller的viewwilldisappear
 *
 */
- (void)willDisappear;

/**
 *  视图已消失，类似于viewcontroller的viewDidDisappear
 *
 */
- (void)didDisappear;

/**
 *  收到系统内存报警
 *
 */
- (void)didReceiveMemoryWarning;

/**
 *  主题发生改变
 *
 */
- (void)themeChanged:(NSNotification*)notification;

/*
 *  调整子View
 *  必须调用super
 *  返回YES表示应该调整子view，返回NO表示不应该调整
 */
- (void)ssLayoutSubviews;

/*
 *  调整子View
 *  必须调用super
 *  返回YES表示应该调整子view，返回NO表示不应该调整
 */
- (void)trySSLayoutSubviews;

/*
 *  信号栏方向发送变化
 */
- (void)applicationStatusBarOrientationDidChanged;

/*
 根据modeChangeActionType更新theme相关UI，会铺上mask view，或者调用themeChanged
 */
- (void)reloadThemeUI;


@end

@interface UIView (SSViewControllerAccessor)
- (UIViewController *) viewController;
- (UINavigationController *) navigationController;
@end
