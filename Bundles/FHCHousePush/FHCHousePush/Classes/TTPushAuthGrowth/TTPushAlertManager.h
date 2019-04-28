//
//  TTPushAlertManager.h
//  Article
//
//  Created by liuzuopeng on 21/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTPushAlertViewProtocol.h"
#import "TTPushAlertModel.h"
#import "TTWeakPushAlertView.h"
#import "TTStrongPushAlertView.h"



/**
 *  隐藏原因
 *
 *  通知TTStrongPushNotificationWillHideNotification和TTStrongPushNotificationDidHideNotification中使用，具体内容查看userInfo
 *
 *  <[userInfo[TTStrongPushHideOnlyResultKey] boolValue]> NO: 表示打开了新页面，否则仅仅关闭弹窗
 */
FOUNDATION_EXTERN NSString * const TTStrongPushHideOnlyResultKey;

FOUNDATION_EXTERN NSString * const TTStrongPushNotificationWillShowNotification;
FOUNDATION_EXTERN NSString * const TTStrongPushNotificationDidShowNotification;
FOUNDATION_EXTERN NSString * const TTStrongPushNotificationWillHideNotification;
FOUNDATION_EXTERN NSString * const TTStrongPushNotificationDidHideNotification;


typedef NS_ENUM(NSInteger, TTPushAlertUrgency) {
    TTPushAlertUnimportance = 0,
    TTPushAlertImportance,
};

typedef NS_ENUM(NSInteger, TTPushWeakAlertPageType) {
    TTPushWeakAlertPageTypeNone,
    TTPushWeakAlertPageTypeMainFeed,
    TTPushWeakAlertPageTypeWatermelonVideoFeed,
    TTPushWeakAlertPageTypeUGCFeed,
    TTPushWeakAlertPageTypeSmallVideoFeed,
};

/**
 *  1. 视频全屏播放时，不显示推送弹窗
 *  2. 键盘展示时，弱弹窗从上面弹出
 */
@interface TTPushAlertManager : NSObject

/** 进入feed页 */
+ (void)enterFeedPage:(TTPushWeakAlertPageType)pageType;

/** 退出feed页 */
+ (void)leaveFeedPage:(TTPushWeakAlertPageType)pageType;

+ (id<TTPushAlertViewProtocol>)showPushAlertViewWithModel:(TTPushAlertModel *)aModel
                                                  urgency:(TTPushAlertUrgency)urgency
                                              didTapBlock:(TTPushAlertDismissBlock)didTaphandler
                                            willHideBlock:(TTPushAlertDismissBlock)willHideHandler
                                             didHideBlock:(TTPushAlertDismissBlock)didHideHandler;

/** 视频全屏播放 */
+ (BOOL)isFullScreenVideoPlaying;

/** 键盘展示中 */
+ (BOOL)isKeyboardShowing;

+ (BOOL)newAlertEnabled;

@end
