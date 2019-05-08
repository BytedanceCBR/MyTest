//
//  TTMessageNotificationTipsManager.h
//  Article
//
//  Created by lizhuoli on 17/3/24.
//
//

#import <Foundation/Foundation.h>

@import ObjectiveC;
#define kTTMessageNotificationTipsViewDefaultDisplayTime 6.f

#define kTTMessageNotificationTipsViewSpringDuration 0.8f
#define kTTMessageNotificationTipsViewSpringDelay 0.5f
#define kTTMessageNotificationTipsViewSpringDampingRatio 0.6f
#define kTTMessageNotificationTipsViewSpringVelocity 0.f

#define kTTMessageNotificationTipsViewScaleSize 0.96
#define kTTMessageNotificationTipsViewDismissDuration 0.2f
#define kTTMessageNotificationTipsViewHorZoomBoundary 10.f
#define kTTMessageNotificationTipsViewHorDismissBoundary 60.f
#define kTTMessageNotificationTipsViewVerZoomBoundary 10.f
#define kTTMessageNotificationTipsViewVerDismissBoundary 20.f

extern NSString * const kTTMessageNotificationTipsChangeNotification;
extern NSString * const kTTMessageNotificationLastTipSaveKey;
extern NSString * const kTTMessageNotificationLastListMaxCursorSaveKey;

extern NSString * const kTTMessageNotificationTipsDialogKey;
extern NSString * const kTTMessageNotificationTipsDialogLocationKey;

typedef NS_ENUM(NSUInteger, TTMessageNotificationTipsMoveDirection){
    TTMessageNotificationTipsMoveDirectionNone,
    TTMessageNotificationTipsMoveDirectionLeft,
    TTMessageNotificationTipsMoveDirectionRight,
    TTMessageNotificationTipsMoveDirectionDown
};

NS_ASSUME_NONNULL_BEGIN

@class TTMessageNotificationTipsModel;
@interface TTMessageNotificationTipsManager : NSObject

@property (nonatomic, assign, readonly) NSUInteger unreadNumber; //新消息通知的消息未读数
@property (nonatomic, copy, readonly) NSString *tips; //新消息通知tips
@property (nonatomic, copy, readonly) NSString *followChannelTips;//关注频道新消息提示文案，该字段非空则使用这个服务端下发的文案，否则客户端拼接
@property (nonatomic, copy, readonly) NSString *userName;//新消息通知用户名
@property (nonatomic, copy, readonly) NSString *action;  //新消息通知动作
@property (nonatomic, assign, readonly) BOOL isImportantMessage; //是否是重要的消息
@property (nonatomic, copy, readonly) NSString *thumbUrl; //新消息通知的"我的"Tab的cell头像URL，如果不存在重要的人信息，返回nil
@property (nonatomic, copy, readonly) NSString *userAuthInfo; //新消息通知"我的"Tab的cell头像认证信息，如果不存在重要的人信息，返回nil
@property (nonatomic, copy, readonly) NSString *msgID; //新消息通知"我的"Tab的msgID
@property (nonatomic, copy, readonly) NSString *actionType; //新消息通知"我的"Tab的actionType
@property (nonatomic, assign, readonly) BOOL isShowingTips; //是否正在显示消息通知Tips
@property (nonatomic, copy, readonly) NSString *lastImageUrl; //最新消息相关用户头像

+ (instancetype)sharedManager;

/** 在指定的View展示消息通知提示，需要箭头指向的centerX，如果小于等于0表示无箭头 */
- (void)showTipsInView:(UIView *)view
            tabCenterX:(CGFloat)centerX
              callback:(void(^)(void))callback;

/** 使用Model更新tips和未读数 */
- (void)updateTipsWithModel:(TTMessageNotificationTipsModel *)model;

/** 手动清除"我的"Tab相关tips数据 */
- (void)clearTipsModel;

- (void)forceRemoveTipsView;

- (void)clearTipView;

/** 针对的是在我的tab地方或者这条重要的消息已经显示过的，显示过重要的消息后，不应该在切到别的tab时，出这条重要的消息**/
- (void)saveLastImportantMessageID;

/** 保存list接口获取到的最新的cursor，用来防止从推送进来时，气泡出现两次**/
- (void)saveLastListMaxCursor:(NSNumber *)cursor;

@end

NS_ASSUME_NONNULL_END
