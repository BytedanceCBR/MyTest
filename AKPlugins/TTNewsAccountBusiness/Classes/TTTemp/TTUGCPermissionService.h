//
//  TTUGCPermissionService.h
//  Pods
//
//  Created by Jiyee Sheng on 19/01/2018.
//
//

@class FRPublishConfigStructModel;
@class FRRedpackStructModel;

typedef NS_ENUM(NSUInteger, TTPostUGCEntrancePosition) {
    // 底tabbar发布器入口
        TTPostUGCEntrancePositionTabbar = 0,
    // 微头条tab顶部发布器入口
        TTPostUGCEntrancePositionWeitoutiaoTop,
    // 微头条tab右下角发布器入口
        TTPostUGCEntrancePositionWeitoutiaoRightBottom,
    // 屏蔽发布器入口
        TTPostUGCEntrancePositionNone
};

static NSString * const kTTPostUGCPermissionUpdateNotification = @"kTTPostUGCPermissionUpdateNotification";
static NSString * const kTTNotificationNameRedpackIntroUpdated = @"kTTNotificationNameRedpackIntroUpdated";
static NSString * const kTTNotificationNameNormalIntroUpdated  = @"kTTNotificationNameNormalIntroUpdated";

@protocol TTUGCPermissionService <NSObject>

//针对部分头部用户，在该用户发布的帖子下面，帖子的评论详情页中，v2详情页中，增加删除别人评论的权限
- (BOOL)showAuthorDeleteEntrance;

//是否有权限删除自己帖子底下的评论
- (BOOL)hasDeletePermissionWithOriginCommentOrThreadUserID:(NSString *)uid;

// 获取UGC发文权限信息
- (void)startFetchPostUGCPermission;

// 是否被封禁（注：仅对底tabbar发布器入口生效）
- (BOOL)postUGCBan;

// 封禁提示
- (nullable NSString *)postUGCBanTips;

// 获取发布器入口的位置
- (TTPostUGCEntrancePosition)postUGCEntrancePosition;

//是否展示问答发布入口（只在发布器在tabbar底部时进行判断）
- (BOOL)isShowWendaPulishEntrance;

// 发帖页面占位文案
- (nullable NSString *)postUGCHint;

// 发帖页面编辑状态控制
- (NSUInteger)postUGCShowEtStatus;

// UGC发文tips
- (nonnull NSString *)postUGCTips;

// 是否需要展示UGC发文tips
- (BOOL)isNeedShowPostUGCTipsView;

// 设置需要展示UGC发文tips
- (void)setIsNeedShowPostUGCTipsView;

// 设置已经展示UGC发文tips
- (void)setHadShowPostUGCTipsView;

- (nullable NSArray<FRPublishConfigStructModel *> *)publishTypeModels;

- (nullable FRRedpackStructModel *)redpackModel;

- (nullable NSString *)shortVideoTabNormalIntroText;

//是否需要展示小视频tab右上角普通引导
- (BOOL)needShowShortVideoTabNormalIntro;

//是否需要展示主发布器普通引导
- (BOOL)needShowShortVideoMainNormalIntro;

//是否需要展示红包引导
- (BOOL)needShowShortVideoRedpackIntro;

//设置主发布器入口被用户打开过
- (void)setShortVideoNormalMainIntroClicked;

//设置小视频tab入口被用户打开过
- (void)setShortVideoTabIntroHasClicked;

//设置小视频红包已经被用户领取
- (void)setShortVideoRedpackHasGot;

//点击进入小视频拜年红包
- (void)didEnterSpringShortVideoRedPackEntrance;

//设置小视频春节活动入口是否展示成红包样式
- (BOOL)shouldShowSpringShortVideoRedPackGuide;

@end

