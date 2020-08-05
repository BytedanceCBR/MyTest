//
//  FHCommunityFeedListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"
#import <CoreLocation/CoreLocation.h>
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
#import "FHHouseUGCAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListController : FHBaseViewController

@property(nonatomic, assign) FHCommunityFeedListType listType;
@property(nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic, strong) NSArray *dataList;
//内容分类
@property(nonatomic, strong) NSString *category;
//附加在feed上面的自定义view
@property(nonatomic, strong) UIView *tableHeaderView;
@property(nonatomic, strong) UITableView *tableView;
//是否需要下拉刷新，默认为YES
@property(nonatomic, assign) BOOL tableViewNeedPullDown;
//是否需要在返回这个页面时候去刷新数据
@property(nonatomic, assign) BOOL needReloadData;
//当前定位的位置
@property(nonatomic, strong) CLLocation *currentLocaton;
//小区详情页进入需要传这个参数，圈子子id
@property(nonatomic, strong) NSString *forumId;
//tab的名字,调用接口时候会传给服务器
@property(nonatomic, strong) NSString *tabName;
//小区群聊的conversation id
@property(nonatomic, strong) NSString *conversationId;
//传入以后点击三个点以后显示该数组的内容
@property(nonatomic, strong) NSArray *operations;
//当接口返回空数据的时候是否显示空态页，默认为YES
@property(nonatomic, assign) BOOL showErrorView;
//网络请求成功回调
@property(nonatomic, copy) void (^requestSuccess)(BOOL hasFeedData);
//是否需要上报enterCategory和stayCategory埋点，默认不报
@property(nonatomic, assign) BOOL needReportEnterCategory;
//埋点上报
//是否是通过点击触发刷新
@property(nonatomic, assign) BOOL isRefreshTypeClicked;
//是否需要强插
@property(nonatomic, assign) BOOL isInsertFeedWhenPublish;
@property(nonatomic, assign) CGFloat headerViewHeight;
//圈子详情页使用
//空态页具体顶部offset
@property (nonatomic, assign) CGFloat errorViewTopOffset;
@property (nonatomic, assign) CGFloat errorViewHeight;
@property (nonatomic, assign) BOOL notLoadDataWhenEmpty;
@property(nonatomic, copy) void(^beforeInsertPostBlock)(void);
//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;
//圈子信息
@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
//页面打开速度
@property(nonatomic, assign) NSTimeInterval startMonitorTime;
@property(nonatomic, assign) BOOL alreadyReportPageMonitor;

- (void)showNotify:(NSString *)message ;
- (void)showNotify:(NSString *)message completion:(void(^)())completion;
//下拉刷新数据
- (void)startLoadData;
//下拉刷新数据,不清之前的数据
- (void)startLoadData:(BOOL)isFirst;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)scrollToTopAndRefresh;

- (void)scrollToTopAndRefreshAllData;

- (void)hideImmediately;
@end

NS_ASSUME_NONNULL_END
