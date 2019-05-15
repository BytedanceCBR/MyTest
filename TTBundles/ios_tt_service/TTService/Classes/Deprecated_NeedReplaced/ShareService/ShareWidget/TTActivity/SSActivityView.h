//
//  SSActivityView.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-7.
//
//

#import <UIKit/UIKit.h>
#import "SSAlertViewBase.h"
#import "TTActivity.h"
#import "TTNewPanelController.h"

typedef NS_ENUM(NSInteger, ActivityLayoutScheme)
{
    ActivityLayoutSchemePadShare,
    ActivityLayoutSchemeFixed,
    ActivityLayoutSchemeNone,
};

@protocol SSActivityViewDelegate;
@protocol SSActivityViewDataSource;

@interface SSActivityView : SSAlertViewBase

@property(nonatomic, weak)NSArray * activityItems;
@property(nonatomic, weak)id<SSActivityViewDelegate>delegate;
@property(nonatomic, weak)id<SSActivityViewDataSource>dataSource;
@property(nonatomic, assign) ActivityLayoutScheme layoutScheme;
@property(nonatomic, weak) TTNewPanelController * panelController;

- (void)refreshCancelButtonTitle:(NSString *)title;
- (void)removeActivityItemsAnimation;
- (void)fontSettingPressed;
- (void)cancelButtonClicked;
- (void)cancelButtonClickedWithAnimation:(BOOL)animated;
- (void)showActivityOnWindow:(UIWindow *)window;

- (void)show;
- (void)showOnViewController:(UIViewController *)controller
           useShareGroupOnly:(BOOL)useShareGroupOnly;
- (void)showOnViewController:(UIViewController *)controller
useShareGroupOnly:(BOOL)useShareGroupOnly isFullScreen:(BOOL)isFullScreen;

- (void)setActivityItemsWithFakeLayout:(NSArray *)activityItems;

// 特殊需求：显式传入分组信息（多维数组）
- (void)showActivityItems:(NSArray *)activityItems;

- (void)showActivityItems:(NSArray *)activityItems isFullSCreen:(BOOL)isFullScreen;

@end


@protocol SSActivityViewDelegate <NSObject>

@optional

//iphone应removeFromSuperView(不实现默认行为),
//ipad应dismissPopoverAnimated:(无默认行为)
- (void)activityView:(SSActivityView *)view willCompleteByItemType:(TTActivityType)itemType;

//可以在此处释放成员变量，节省内存
- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType;

//顺带传回了button，为了能够自己控制点击状态
- (void)activityView:(SSActivityView *)view button:(UIButton *)button didCompleteByItemType:(TTActivityType)itemType;

@end

@protocol SSActivityViewDataSource <NSObject>

@required

- (void)activityView:(SSActivityView *)view actionOnViewController:(UIViewController *)controller;

@end
