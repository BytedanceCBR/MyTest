//
//  FHHomeItemViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/6/12.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHTracerModel.h"
#import "FHHomeListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger , FHHomePullTriggerType){
    FHHomePullTriggerTypePullUp = 1, //上拉刷新
    FHHomePullTriggerTypePullDown = 2  //下拉刷新
};


static const NSUInteger kFHHomeHouseTypeBannerViewSection = 0;
static const NSUInteger kFHHomeHouseTypeHouseSection = 1;

@class FHHomeSearchPanelViewModel;

@interface FHHomeItemViewController : UIViewController

@property (nonatomic,assign) FHHouseType houseType;
@property (nonatomic, assign) BOOL showNoDataErrorView;
@property (nonatomic, assign) BOOL showRequestErrorView;
@property (nonatomic, assign) BOOL showDislikeNoDataView;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, assign) BOOL isOriginShowSelf;//当前显示的是不是自己这个类型的房源
@property (nonatomic , strong) FHTracerModel *tracerModel;
@property (nonatomic, assign) TTReloadType reloadType; //当前enterType，用于enter_category
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) FHHomeSearchPanelViewModel *panelVM;

@property (nonatomic, strong) NSMutableArray *traceNeedUploadCache;
@property (nonatomic, strong) NSMutableDictionary *traceEnterCategoryCache;
@property (nonatomic, strong) NSMutableDictionary *traceEnterTopTabache;
@property (nonatomic, strong) NSString *enterType; //当前enterType，用于enter_category
@property (nonatomic, assign) BOOL isShowRefreshTip; //是否主页的tip正在刷新，开始刷新为YES，tips收回之后变成NO


@property (nonatomic, copy) void (^requestCallBack)(FHHomePullTriggerType refreshType,FHHouseType houseType,BOOL isSuccess,JSONModel *dataModel);
@property (nonatomic, copy) void (^requestNetworkUnAvalableRetryCallBack)(void);
@property (nonatomic, copy) void (^scrollDidEnd)(void);
@property (nonatomic, copy) void (^scrollDidBegin)(void);
@property (nonatomic, copy) void (^scrollDidScrollCallBack)(UIScrollView *currentTable);


- (instancetype)initItemWith:(FHHomeListViewModel *)listModel;

- (void)requestDataForRefresh:(FHHomePullTriggerType)pullType andIsFirst:(BOOL)isFirst;

- (void)sendTraceEvent:(FHHomeCategoryTraceType)traceType;

- (void)showPlaceHolderCells;

- (void)currentViewIsShowing;

- (void)currentViewIsDisappeared;

- (void)initNotifications;

- (void)removeNotifications;

@end

NS_ASSUME_NONNULL_END
