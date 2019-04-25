//
//  NewsListLogicManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-10-30.
//
//

#import <Foundation/Foundation.h>
#import "ExploreCellBase.h"

#define kNewsListFetchedRemoteReloadTipNotification @"kNewsListFetchedRemoteReloadTipNotification"
#define kNewsListShouldFetchedRemoteReloadTipNotification @"kNewsListShouldFetchedRemoteReloadTipNotification"
#define kNewsListFetchedRemoteReloadItemCountNotification @"kNewsListFetchedRemoteReloadItemCountNotification"

// 混排列表更新提醒
typedef NS_ENUM(NSUInteger, TTExploreMixedListUpdateTipType) {
    // 不提醒更新
    TTExploreMixedListUpdateTipTypeNone = 0,
    // tab bar上对应的tab显示红点作更新提醒
    TTExploreMixedListUpdateTipTypeTabbarRedPoint,
    // 混排列表顶部显示蓝条作更新提醒
    TTExploreMixedListUpdateTipTypeBlueBar,
};

@interface NewsListLogicManager : NSObject

@property(nonatomic, assign, readonly)NSTimeInterval listTipRefreshInterval;
@property(nonatomic, assign, readonly)NSTimeInterval listAutoReloadRefreshInterval;
@property(nonatomic, assign, readonly)NSTimeInterval listTipDisplayInterval;

+ (NewsListLogicManager *)shareManager;

- (void)willEnterForground;
- (void)didEnterBackground;

//tip logic
//请求tip
- (void)fetchReloadTipWithMinBehotTime:(NSTimeInterval)minBehotTime categoryID:(NSString *)categoryID count:(NSUInteger)count;
//判断是否应该请求"更新tip"
- (BOOL)shouldFetchReloadTipForCategory:(NSString *)categoryID;
//开始下次“更新Tip”的倒计时
- (void)beginFetchRemoteReloadTipCountDownForCategoryID:(NSString *)categoryID;
//更新最近一次请求tip的时间, 下拉刷新，加载更多都会更新该时间
- (void)updateLastFetchReloadTipTimeForCategory:(NSString *)categoryID;

//reload logic
- (BOOL)shouldAutoReloadFromRemoteForCategory:(NSString *)categoryID;
- (void)saveHasReloadForCategoryID:(NSString *)categoryID;
//+ (void)saveListLastReloadTimeForCategory:(NSString *)categoryID;

//关注频道，有红点时，只有离开时间大于此时间时才自动刷新
+ (NSTimeInterval)fetchFollowListAutoReloadWithNotifyInterval;

//是否需要强制刷新回到主Feed流
- (BOOL)needSwitchToRecommendTab;
//保存特定频道离开时间，不包括进入详情页的时候离开列表
+ (void)saveDisappearDateForCategoryID:(NSString *)categoryID;
+ (void)saveDisappearDateForFollowCategory;
//获取特定频道离开时间间隔
+ (NSTimeInterval)listDisappearIntercalForCategoryID:(NSString *)categoryID;
//保存自动刷新间隔时间常量
+ (void)saveListAutoReloadInterval:(NSTimeInterval)interval;
//获取tip获取间隔时间常量
+ (NSTimeInterval)fetchListTipRefreshInterval;
//保存tip获取间隔时间常量
+ (void)saveListTipRefreshInterval:(NSTimeInterval)interval;
//保存tip显示的时间常量
+ (void)saveListTipDisplayInterval:(NSTimeInterval)interval;
//保存超过一定时常，强制返回主feed流时间
+ (void)saveSwitchToRecommendChannelInterval:(NSTimeInterval)interval;

+ (BOOL)needShowFixationCategory;
+ (void)setNeedShowFixationCategory:(BOOL)need;

+ (void)setNewsListShowRefreshInfo:(NSDictionary *)info;
+ (NSDictionary *)newsListShowRefreshInfo;
+ (BOOL)checkIfJustReloadFromRemote:(NSString *)categoryID;
+ (NSTimeInterval)listLastReloadTimeForCategory:(NSString *)categoryID;

/**
 *  列表更新提醒方式
 *
 *  @param categoryID 频道ID
 *  @param listLocation 频道位置
 *  @return 返回提醒方式
 */
+ (TTExploreMixedListUpdateTipType)tipListUpdateUseTabbarOfCategoryID:(NSString *)categoryID
                                                         listLocation:(ExploreOrderedDataListLocation)listLocation;

/**
 *  设置是否使用tabbar来提示列表更新，只针对tabbar结构
 *
 *  @param useTabbar YES，使用tabbar更新;NO，使用蓝条更新
 */
+ (void)setTipListUpdateUseTabbar:(BOOL)useTabbar;

/**
 *  本地频道是否显示切换城市条
 */
+ (BOOL)needShowCitySelectionBar;
+ (void)setNeedShowCitySelectionBar:(BOOL)need;

@end
