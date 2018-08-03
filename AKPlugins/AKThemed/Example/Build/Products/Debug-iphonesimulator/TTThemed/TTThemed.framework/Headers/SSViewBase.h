//
//  SSViewBase.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
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

- (void)willAppear;
- (void)didAppear;
- (void)willDisappear;
- (void)didDisappear;
- (void)didReceiveMemoryWarning;
- (void)themeChanged:(NSNotification*)notification;

//- (void)applicationStautsBarDidRotate:(NSNotification *)notification;

// default to ModeChangeActionTypeCustom
@property(nonatomic, assign)ModeChangeActionType modeChangeActionType;

/*
 *  调整子View
 *  必须调用super
 *  返回YES表示应该调整子view，返回NO表示不应该调整
 */
- (void)ssLayoutSubviews;
- (void)trySSLayoutSubviews;

- (void)applicationStatusBarOrientationDidChanged;

/*
 根据modeChangeActionType更新theme相关UI，会铺上mask view，或者调用themeChanged
 */
- (void)reloadThemeUI;

// life cycle related
//- (void)maskViewCreated:(UIView*)maskView;


@end

@interface UIView (SSViewControllerAccessor)
/// self.viewController
- (UIViewController *) viewController;
/// self.navigationController
- (UINavigationController *) navigationController;
/// toBe continue
/*
 - (UITabBarController *) tabBarController;
 */

@end
