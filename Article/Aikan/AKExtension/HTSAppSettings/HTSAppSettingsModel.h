//
//  HTSAppSettingsModel.h
//  LiveStreaming
//
//  Created by Quan Quan on 16/11/6.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Mantle/Mantle.h>

typedef NS_ENUM(NSInteger, HTSVideoPageSlideAction)
{
    /// 视频页上下滑动手势关闭
    HTSVideoPageSlideActionNone = 0,
    /// 视频页上下滑动手势切换视频
    HTSVideoPageSlideActionSwitchVideo = 1,
};

typedef NS_ENUM(NSInteger, HTSVideoFollowGuideAction)
{
    /// 视频页关注引导关闭
    HTSVideoFollowGuideNone = 0,
    /// 视频页点赞触发关注引导
    HTSVideoFollowGuideAfterLike = 1,
    /// 视频页播放完成触发关注引导
    HTSVideoFollowGuideAfterPlay = 2,
};

// 启动时位置的ABTest
typedef NS_ENUM(NSUInteger, HTSLaunchPositionABTest) {
    HTSLaunchPositionOldLogic = 0,        // 老逻辑：只出现在首页的位置
    HTSLaunchPositionHomeAndFollow = 1,   // 新逻辑：出现在首页或者关注tab位置
    HTSLaunchPositionVideo = 2,           // 新逻辑：新启动永远都只定位到视频tab
};

typedef NS_ENUM(NSInteger, HTSABTestLiveFeedLayoutStyle)
{
    HTSABTestLiveFeedLayoutStyleBouth  = 1,
    HTSABTestLiveFeedLayoutStyleSingle = 2,
    HTSABTestLiveFeedLayoutStyleDouble = 3,
};

typedef NS_ENUM(NSUInteger, HTSGuestModeLoginButtonStyles) {
    HTSGuestModeLoginButtonStyleText = 0,
    HTSGuestModeLoginButtonStyleIcon,
};

typedef NS_ENUM(NSUInteger, HTSVideoPlayerType) {
    HTSVideoPlayerTypeSystem = 0,
    HTSVideoPlayerTypeTTOwn,
};

typedef NS_ENUM(NSUInteger, HTSVideoSlideController) {
    HTSVideoPageControl = 0,
    HTSVideoTableControl,
};

/// 2.1版本: "关注"帧红点与直播标记的优先级, 1:优选直播, 2:优选红点
typedef NS_ENUM(NSUInteger, HTSFollowTabBadgePriority) {
    HTSFollowTabBadgePriorityLive     = 1,
    HTSFollowTabBadgePriorityRedPoint = 2,
};

@class HTSProfileActivityModel;
@class HTSSettingsEncryptModel;

@interface HTSAppSettingsModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *HTTP_RETRY_COUNT;
@property (nonatomic, strong) NSNumber *HTTP_RETRY_INTERVAL;
@property (nonatomic, strong) NSNumber *HTTP_TIMEOUT;

/// Encrypt Model
@property (nonatomic, strong) HTSSettingsEncryptModel *encryptModel;

/// 个人页活动cell
@property (nonatomic, strong) HTSProfileActivityModel *profileActivity;

/// 视频页上下滑动手势配置
@property (nonatomic, assign) HTSVideoPageSlideAction videoSlideAction;

/// 视频页关注引导
@property (nonatomic, assign) HTSVideoFollowGuideAction videoFollowGuide;

/// 弹窗最多显示一次的天数
@property (nonatomic, assign) int pushFreq;

/// 弹窗连续拒绝的次数
@property (nonatomic, assign) int pushDenyThreshold;

/// 超过弹窗次数阈值时的天数
@property (nonatomic, assign) int pushCandidateFreq;

/// 视频录制时长
@property (nonatomic, assign) int videoDurationLimit;

/// 统计crash前N次用户操作并上报Fabric
@property (nonatomic, assign) BOOL reportCrashAction;

/// 直播Feed大小图
@property (nonatomic, assign) HTSABTestLiveFeedLayoutStyle liveFeedStyle;

/// 访客模式 拍摄按钮是否显示
@property (nonatomic, assign) BOOL guestPhotoButtonShow;

/// 访客模式 登录按钮样式
@property (nonatomic, assign) HTSGuestModeLoginButtonStyles loginBtnStyle;

/// 2.1版本: "关注"帧红点与直播标记的优先级, 1:优选直播, 2:优选红点
@property (nonatomic, assign) HTSFollowTabBadgePriority followBadgePriority;

/// 2.2版本: 设置页面的引导列表
@property (nonatomic, copy) NSArray<HTSProfileActivityModel *> *settingGuideList;

/// 网络库版本升级
@property (nonatomic, assign) BOOL networkLibUpgrade;

/// 2.3版本: 视频播放器类型
@property (nonatomic, assign) HTSVideoPlayerType videoPlayerType;

/// 2.3版本: 启动记录上次位置AB
@property (nonatomic, assign) HTSLaunchPositionABTest launchPositionAB;

/// 视频播放页上下滑动控件
@property (nonatomic, assign) HTSVideoSlideController videoSlideControl;

/// 是否是审核版本，审核版本部分页面需要做响应配置,审核版本为1，非审核版本这个字段没有
@property (nonatomic, strong) NSNumber *isFakeVersion;

/* 2.4版本: 首次提现成功是否展示好评弹窗 */
@property (nonatomic, assign) BOOL showCommentAlert;

/// 拍摄工具选择音乐页显示搜索框
@property (nonatomic, assign) BOOL enableMusicSearch;

/// 拍摄工具选择音乐页搜索过滤条件
@property (nonatomic, strong) NSArray<NSString *> *musicFilterTitles;
@property (nonatomic, strong) NSArray<NSString *> *musicFilterAuthors;

/// 他人页显示用户推荐
@property (nonatomic, assign) BOOL enableProfileUserRecommend;

@end

#pragma mark -- HTSProfileActivityModel

@interface HTSProfileActivityModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSNumber *activityID;           /* 活动ID */
@property (nonatomic, copy) NSString *title;                            /* 标题 */
@property (nonatomic, copy) NSString *message;                          /* 描述 */
@property (nonatomic, copy) NSString *text;                             /* 按钮标题 */
@property (nonatomic, copy) NSString *URL;                              /* 跳转URL */

- (BOOL)isValid;

@end

#pragma mark -- HTSRequestEncryptModel

@interface HTSSettingsEncryptModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *estr;

@end





