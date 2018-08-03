//
//  TTLiveMainViewController.h
//  Article
//
//  Created by matrixzk on 1/15/16.
//
//

#import <UIKit/UIKit.h>

#import "SSViewControllerBase.h"

#import "TTLiveMessageBox.h"
#import "TTLiveOverallInfoModel.h"
#import "TTLiveFakeNavigationBar.h"

#import "TTLiveMessageBaseCell.h"

#import "TTLiveDataSourceManager.h"

@class TTLiveHeaderView, TTLivePariseView, TTHorizontalCategoryBar, TTLiveRemindView, TTSwipePageViewController, TTImageView;

// type值为channelID，
// server返回未约定给出类型时，全部显示成webView样式.
typedef NS_ENUM(NSUInteger, TTLiveChannelType) {
    TTLiveChannelTypeLive = 1,        // 嘉宾、主持人直播列表
    TTLiveChannelTypeChat,            // 观众交流列表
    // TTLiveChannelTypeMatchRanking     // 赛事排行榜（webView）
};


@class TTLiveStreamDataModel, TTLiveTopBannerInfoModel, TTLiveChatTableViewController, TTLiveTabCategoryItem;

static CGFloat kHeightOfTopTabView = 44;

@interface TTLiveMainViewController : SSViewControllerBase <TTLiveMessageHandleDelegate>

@property (nonatomic, assign, readonly) CGFloat bannerHeight;
@property (nonatomic, strong, readonly) TTLiveFakeNavigationBar *fakeNavigationBar;
@property (nonatomic, strong, readonly) TTLiveFakeNavigationBar *droppedNavigationBar;
@property (nonatomic, strong, readonly) TTLiveHeaderView *headerView;
@property (nonatomic, strong, readonly) TTHorizontalCategoryBar *topTabView;
@property (nonatomic, strong, readonly) TTSwipePageViewController *swipePageVC;

@property (nonatomic, strong, readonly) TTLiveMessageBox *messageBoxView;
@property (nonatomic, strong, readonly) TTLivePariseView *pariseView;

@property (nonatomic, strong, readonly) TTLiveOverallInfoModel *overallModel;
@property (nonatomic, strong, readonly) TTLiveStreamDataModel *streamDataModel;
@property (nonatomic, strong, readonly) TTLiveTopBannerInfoModel *topInfoModel;

@property (nonatomic, strong, readonly) TTLiveDataSourceManager *dataSourceManager;

@property (nonatomic, strong) TTLiveRemindView *remindView;

@property (nonatomic) NSUInteger pariseCount;
@property (nonatomic) NSUInteger lastInfiniteLike;
@property (nonatomic) NSUInteger userDigCount;
@property (nonatomic, strong) NSMutableArray<NSString *> * infiniteIconUrlList;

- (void)othersPariseDig:(NSUInteger)count inTime:(CGFloat)time;
- (void)firstInDig;

- (UIViewController *)currentChannelVC;
- (UIViewController *)channelVCWithIndex:(NSInteger)index;

- (TTLiveChatTableViewController *)suitableChatViewController;

- (TTLiveTabCategoryItem *)channelItemWithChannelId:(NSInteger)channelId;
- (NSUInteger)tabIndexOfLiveChannelWithType:(TTLiveChannelType)channelType;

- (NSString *)leaderRoleNameWithUserID:(NSString *)userID;
- (BOOL)roleOfCurrentUserIsLeader;

- (UIEdgeInsets)edgeInsetsOfContentScrollView;
- (UIEdgeInsets)edgeInsetsOfContentWebScrollView;
// 嘉宾身份登陆后，切换tab下的scrollView的contentInset
//- (void)resetEdgeInsetsOfContentScrollView;

/// 将发送的消息展示在相应的列表中
- (void)showMessageOnSuitableChannel:(NSArray<TTLiveMessage *> *)messageArray;

/// 展开HeaderView
- (void)unfoldedHeaderView;

/// 停掉(或暂停)当前正在播放的直播视频(或回放视频)
//- (void)stopLiveVideoIfNeeded;
- (void)pauseLiveVideoIfNeeded;

/// 开始播放直播视频(或回放视频)
- (void)startLiveVideoIfNeeded;

/// headerView 处于收起状态
- (BOOL)headerViewIsFolded;


- (void)makeShare;

//生成输入框
- (void)setUpMessageView:(TTLiveTopBannerInfoModel *)modle;

//刷新红点、在线人数、比分
- (void)refreshRedBadgeAndOnlineUserAndScore:(TTLiveStreamDataModel *)model;

//重新生成box
//- (void)reloadMessageBoxViewToSupportAll;

- (void)updateRemindView:(TTLiveMessage *)message;

- (BOOL)roleOfCurrentUserIsLeader;//判断是不是主持人;

@end


@interface TTLiveMainViewController (EventTracker)

- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label;
- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label channelId:(NSNumber *)channelId;
- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label channelId:(NSNumber *)channelId extraValue:(NSString *)extValue;

@end
