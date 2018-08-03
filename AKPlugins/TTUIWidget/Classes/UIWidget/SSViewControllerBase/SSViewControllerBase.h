//
//  SSViewControllerBase.h
//  Article
//
//  Created by Yu Tianhang on 12-11-21.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "TTRoute.h"

// 仅用于手动设置status bar方向时使用，在调用setStatusBarOrientation:animated:前立即修改为YES，调用后立即修改为NO
extern BOOL STATUS_BAR_ORIENTATION_MODIFY;

typedef NS_ENUM(NSUInteger, SSViewControllerStatsBarStyle)
{
    SSViewControllerStatsBarNoneStyle,
    SSViewControllerStatsBarDayBlackNightWhiteStyle,
    SSViewControllerStatsBarDayWhiteNightBlackStyle,
};

typedef void (^TTAppPageCompletionBlock)(id);

@interface SSViewControllerBase : UIViewController <TTRouteInitializeProtocol>

@property(nonatomic, assign)BOOL viewBoundsChangedNotifyEnable;
// default to ModeChangeActionTypeCustom
@property(nonatomic, assign)ModeChangeActionType modeChangeActionType;
@property(nonatomic, assign)SSViewControllerStatsBarStyle statusBarStyle;

- (void)dismissSelf;

//- (instancetype)initWithBaseCondition:(NSDictionary *)baseCondition;

/*
 根据modeChangeActionType更新theme相关UI，会铺上mask view，或者调用themeChanged
 */
- (void)reloadThemeUI;

// life cycle related
- (void)themeChanged:(NSNotification*)notification;


@end
