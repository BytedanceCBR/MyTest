//
//  FHUGCShortVideoListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"
#import <CoreLocation/CoreLocation.h>
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
#import "FHHouseUGCAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCShortVideoListController : FHBaseViewController

@property(nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic, strong) NSArray *dataList;
//内容分类
@property(nonatomic, strong) NSString *category;
//是否需要下拉刷新，默认为YES
@property(nonatomic, assign) BOOL tableViewNeedPullDown;
//是否需要在返回这个页面时候去刷新数据
@property(nonatomic, assign) BOOL needReloadData;
//当接口返回空数据的时候是否显示空态页，默认为YES
@property(nonatomic, assign) BOOL showErrorView;
//是否需要上报enterCategory和stayCategory埋点，默认不报
@property(nonatomic, assign) BOOL needReportEnterCategory;
//是否是通过点击触发刷新
@property(nonatomic, assign) BOOL isRefreshTypeClicked;
//圈子详情页使用
@property (nonatomic, assign) BOOL notLoadDataWhenEmpty;
//页面打开速度
@property(nonatomic, assign) NSTimeInterval startMonitorTime;
@property(nonatomic, assign) BOOL alreadyReportPageMonitor;

- (void)showNotify:(NSString *)message ;
- (void)showNotify:(NSString *)message completion:(nullable void(^)(void))completion;
//下拉刷新数据
- (void)startLoadData;
//下拉刷新数据,不清之前的数据
- (void)startLoadData:(BOOL)isFirst;

- (void)scrollToTopAndRefresh;

- (void)scrollToTopAndRefreshAllData;

- (void)hideImmediately;

- (void)viewAppearForEnterType:(NSInteger)enterType;

- (void)viewDisAppearForEnterType:(NSInteger)enterType;

@end

NS_ASSUME_NONNULL_END
