//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/10/22.
//

#import "FHHomeListViewModel.h"
#import "FHHomeConfigManager.h"
#import "FHHomeSectionHeader.h"
#import "FHEnvContext.h"
#import "FHHomeRequestAPI.h"
#import <FHHomeHouseModel.h>
#import "TTURLUtils.h"
#import "FHTracerModel.h"
#import "TTCategoryStayTrackManager.h"
#import "ToastManager.h"
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import <UIScrollView+Refresh.h>
#import <MJRefresh.h>
#import <FHRefreshCustomFooter.h>
#import <TTArticleCategoryManager.h>
#import "FHHomeCellHelper.h"
#import <TTSandBoxHelper.h>
#import "FHHomeItemViewController.h"
#import "FHHomeSearchPanelViewModel.h"
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import <FHUtils.h>
#import <FHHomeMainViewController.h>

#define KFHScreenWidth [UIScreen mainScreen].bounds.size.width
#define KFHScreenHeight [UIScreen mainScreen].bounds.size.height
#define KFHHomeSectionHeight 30
#define KFHHomeSearchBarHeight 50

#define KFHHomeHeaderCellId @"kHouseListCellid"
#define KFHHomeSearchCellId @"kHouseSearchCellid"
#define KFHHomeCategoryCellId @"kCategoryCellid"
#define KFHHomeHouseListCellId @"kHouseListCellid"


@interface FHHomeListViewModel()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableViewV;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, strong) FHHomeViewController *homeViewController;
@property (nonatomic, strong) FHHomeSectionHeader *categoryView;
@property (nonatomic, assign) FHHouseType previousHouseType;
@property (nonatomic, assign) FHHomePullTriggerType currentPullType;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property (nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
@property (nonatomic, strong) TTHttpTask * requestOriginTask;
@property (nonatomic, strong) TTHttpTask * requestRefreshTask;
@property (nonatomic, assign) BOOL isHasCallBackForFirstTime;
@property (nonatomic, assign) BOOL isFirstChange;
@property (nonatomic, assign) BOOL isRequestFromSwitch; //左右切换房源类型
@property(nonatomic, weak)   NSTimer *timer;

@property (nonatomic, strong) UIScrollView *childVCScrollView;
@property (nonatomic, assign) BOOL isSelectIndex;
@property (nonatomic, assign) NSInteger headerHeight;

@property (nonatomic, strong) NSArray *itemsVCArray;

@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC andPanelVM:(FHHomeSearchPanelViewModel *)panelVM
{
    self = [super init];
    if (self) {
        self.categoryView = [[FHHomeSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, KFHHomeSectionHeight)];
        self.tableViewV = tableView;
        self.homeViewController = homeVC;
        self.isSelectIndex = YES;
        self.isResetingOffsetZero = NO;
        self.panelVM = panelVM;
        _itemsVCArray = [NSMutableArray new];
        
        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        
        //更新冷启动默认选项
        if (configDataModel.houseTypeDefault && (configDataModel.houseTypeDefault.integerValue > 0)) {
            [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:configDataModel.houseTypeDefault];
            self.houseType = configDataModel.houseTypeDefault.integerValue;
        }
        
        [self configIconRowCountAndHeight];
        
        [self updateCategoryViewSegmented:YES];
        
        self.tableViewV.delegate = self;
        self.tableViewV.dataSource = self;
        self.hasShowedData = NO;
        self.isHasCallBackForFirstTime = NO;
        self.isFirstChange = YES;
        self.isRequestFromSwitch = NO;
        
        //**************
        // 监听子控制器发出的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTableViewDidScroll:) name:@"FHHomeSubTableViewDidScroll" object:nil];


        //*************
        self.tableViewV.hasMore = YES;
        
        WeakSelf;
        // 下拉刷新，修改tabbar条和请求数据
        [self.tableViewV tt_addDefaultPullDownRefreshWithHandler:^{
            StrongSelf;
            
            if (self.reloadType == TTReloadTypeTab) {
                [self setUpTableScrollOffsetZero];
            }
            
            if (![FHEnvContext isNetworkConnected]) {
                
                [[ToastManager manager] showToast:@"网络异常"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableViewV finishPullDownWithSuccess:YES];
                    });
                });
                return ;
            }
            
            if (self.panelVM) {
                [self.panelVM fetchSearchPanelRollData];
            }
            
            if (![FHEnvContext sharedInstance].isRefreshFromCitySwitch) {
                [self requestOriginData:self.isFirstChange isShowPlaceHolder:[FHEnvContext sharedInstance].isRefreshFromCitySwitch];
            }
        }];
        
        [self.tableViewV setBackgroundColor:[UIColor themeHomeColor]];
        [self.tableViewV.pullDownView setUpRefreshBackColor:[UIColor themeHomeColor]];
        //       __block NSString *previousCityId = configDataModel.currentCityId;
        //订阅config变化发送网络请求
        [FHHomeCellHelper sharedInstance].isFirstLanuch = YES;
        [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
            StrongSelf;
            self.isRequestFromSwitch = NO;
            FHConfigDataModel *xConfigDataModel = (FHConfigDataModel *)x;
            
            if (xConfigDataModel.cityAvailability.enable.boolValue)
            {
                [self.homeViewController.emptyView hideEmptyView];
            }
            
            [self checkCityStatus];
            
            self.headerHeight = [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
    
            [self.tableViewV reloadData];
            
            [self setUpTableScrollOffsetZero];
            
            self.isSelectIndex = YES;
            
            [self configIconRowCountAndHeight];
            
            
            //更新冷启动默认选项
            if (xConfigDataModel.houseTypeDefault && (xConfigDataModel.houseTypeDefault.integerValue > 0) && [TTSandBoxHelper isAPPFirstLaunchForAd]) {
                [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:xConfigDataModel.houseTypeDefault];
                self.houseType = xConfigDataModel.houseTypeDefault.integerValue;
            }
            
            //如果启动时 类型没有变
            if ([configDataModel.houseTypeList containsObject:@(self.houseType)] && [configDataModel.houseTypeList isEqualToArray:xConfigDataModel.houseTypeList] && ![FHEnvContext sharedInstance].isRefreshFromCitySwitch && [FHHomeCellHelper sharedInstance].isFirstLanuch) {
                //更新切换
                [self updateCategoryViewSegmented:NO];
                
                [FHEnvContext addTabUGCGuid];
            }else
            {
                //收起tip
                [self.homeViewController hideImmediately];
                //                [self.homeViewController resetMaintableView];
                [self updateCategoryViewSegmented:YES];
            }
            
            //清空首页show埋点
            if(!self.isFirstChange && [FHEnvContext sharedInstance].isRefreshFromCitySwitch)
            {
                [[FHHomeCellHelper sharedInstance] clearShowCache];
            }
            
            //非首次只刷新头部
            if ((!self.isFirstChange && [FHEnvContext sharedInstance].isSendConfigFromFirstRemote) && ![FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch) {
                [FHHomeCellHelper sharedInstance].isFirstLanuch = NO;
                
                //                [self.tableViewV reloadData];
                
                [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdateFowFindHouse = YES;
                
                return;
            }
            
            self.isFirstChange = NO;
        }];
        
        //切换推荐房源类型
        self.categoryView.clickIndexCallBack = ^(NSInteger indexValue) {
            StrongSelf;
            [self selectIndexHouseType:indexValue];
        };
        
    }
    return self;
}

- (void)selectIndexHouseType:(NSInteger)indexValue
{
    //上报stay埋点
    [self sendTraceEvent:FHHomeCategoryTraceTypeStay];
    
    //收起tip
    [self.homeViewController hideImmediately];
    
    //设置当前房源类型
    FHConfigDataModel *currentDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (currentDataModel.houseTypeList.count > indexValue) {
        NSNumber *numberType = [currentDataModel.houseTypeList objectAtIndex:indexValue];
        if ([numberType isKindOfClass:[NSNumber class]]) {
            self.houseType = [numberType integerValue];
        }
    }
    
    self.isRequestFromSwitch = YES;
    
    for (FHHomeItemViewController *vc in self.itemsVCArray) {
        if ([vc isKindOfClass:[FHHomeItemViewController class]] && vc.houseType == self.previousHouseType) {
            [vc sendTraceEvent:FHHomeCategoryTraceTypeStay];
        }
    }
    
    [self setUpSubtableIndex:indexValue];
    
    [self bindItemVCTrace];
}

- (void)requestOriginData:(BOOL)isFirstChange isShowPlaceHolder:(BOOL)showPlaceHolder
{
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSInteger currentSelectIndex = self.categoryView.segmentedControl.selectedSegmentIndex;
    
    if (configDataModel.houseTypeList.count > currentSelectIndex && self.itemsVCArray.count > currentSelectIndex) {
        FHHomeItemViewController *itemVC = self.itemsVCArray[currentSelectIndex];
        if ([itemVC respondsToSelector:@selector(requestDataForRefresh:andIsFirst:)]) {
            [itemVC requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:NO];
        }
    }
}

- (void)setUpTableScrollOffsetZero
{
    self.isResetingOffsetZero = YES;
    self.tableViewV.contentOffset = CGPointMake(0, 0);
    
    if (self.tableViewV.numberOfSections > 0 && [self.tableViewV numberOfRowsInSection:0] > 0) {
        [self.tableViewV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        
        for (FHHomeItemViewController *vc in self.itemsVCArray) {
            if (vc.tableView.numberOfSections > 0 && [vc.tableView numberOfRowsInSection:0] > 0){
                [vc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
        }
    }
}

- (void)setUpSubtableViewContrllers
{
    for (UIView *subView in self.homeViewController.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    for (UIViewController *subController in self.homeViewController.childViewControllers) {
        [subController removeFromParentViewController];
    }
    
    self.homeViewController.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight]);
    //    self.tableViewV.scrollEnabled = NO;
    
    _childVCScrollView.contentOffset = CGPointMake(0, 0);
    __weak typeof(self) weakSelf = self;
    
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSMutableArray *itemVCArrayTmp = [NSMutableArray new];
    for (int i = 0; i < configDataModel.houseTypeList.count; i++) {
        NSNumber *houseTypeNum = configDataModel.houseTypeList[i];
        if ([houseTypeNum isKindOfClass:[NSNumber class]]) {
            FHHomeItemViewController *itemVC = [[FHHomeItemViewController alloc] initItemWith:self];
            itemVC.houseType = [houseTypeNum integerValue];
            itemVC.panelVM = self.panelVM;
            if (houseTypeNum.integerValue == self.houseType) {
                itemVC.isOriginShowSelf = YES;
                self.previousHouseType = self.houseType;
            }else
            {
                itemVC.isOriginShowSelf = NO;
            }
            
            // 添加子控制器
            [self.homeViewController addChildViewController:itemVC];
            itemVC.requestCallBack = ^(FHHomePullTriggerType refreshType, FHHouseType houseType, BOOL isSuccess, JSONModel * _Nonnull dataModel) {
                [weakSelf processRequestData:refreshType andHouseType:houseType andIsSucees:isSuccess andDataModel:dataModel];
            };
            
            itemVC.scrollDidBegin = ^{
                self.homeViewController.scrollView.scrollEnabled = NO;
            };
            
            itemVC.scrollDidEnd = ^{
                self.homeViewController.scrollView.scrollEnabled = YES;
            };
            
            itemVC.requestNetworkUnAvalableRetryCallBack = ^{
                [weakSelf.homeViewController retryLoadData];
            };
            //将子控制的view添加到scrollView上去
            [self.homeViewController.scrollView addSubview:itemVC.view];
            
            itemVC.view.frame = CGRectMake(KFHScreenWidth * i, 0, KFHScreenWidth, self.homeViewController.scrollView.frame.size.height);
            
            [itemVCArrayTmp addObject:itemVC];
        }
    }
    
    self.homeViewController.scrollView.delegate = self;
    self.itemsVCArray = itemVCArrayTmp;
    [self.homeViewController.scrollView setContentSize:CGSizeMake(KFHScreenWidth * configDataModel.houseTypeList.count + 1, self.homeViewController.scrollView.frame.size.height)];
    NSInteger currentSelectIndex = self.categoryView.segmentedControl.selectedSegmentIndex;
    [self setUpSubtableIndex:currentSelectIndex];
    
    if (![FHEnvContext isNetworkConnected]) {
        self.homeViewController.scrollView.scrollEnabled = NO;
    }
    //    [self.tableViewV reloadData];
    //    self.tableViewV.scrollEnabled = YES;
}

- (void)setIsShowRefreshTip:(BOOL)isShowRefreshTip {
    for (FHHomeItemViewController *vc in self.itemsVCArray) {
        if ([vc isKindOfClass:[FHHomeItemViewController class]]) {
            FHHomeItemViewController *itemVC = (FHHomeItemViewController *)vc;
            itemVC.isShowRefreshTip = isShowRefreshTip;
        }
    }
}

- (void)setUpHomeItemScrollView:(BOOL)isCanScroll
{
    for (FHHomeItemViewController *vc in self.itemsVCArray) {
        if ([vc isKindOfClass:[FHHomeItemViewController class]]) {
            FHHomeItemViewController *itemVC = (FHHomeItemViewController *)vc;
            itemVC.tableView.scrollEnabled = isCanScroll;
        }
    }
}

- (void)setUpSubtableIndex:(NSInteger)index
{
    if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.houseType)];
    }
    self.homeViewController.scrollView.contentOffset = CGPointMake(KFHScreenWidth * index, 0);
    [self uploadFirstScreenHouseShow:self.categoryView.segmentedControl.selectedSegmentIndex andEnterType:@"switch"];
    self.previousHouseType = self.houseType;
}

- (void)processRequestData:(FHHomePullTriggerType)refreshType andHouseType:(FHHouseType)houseType andIsSucees:(BOOL)isSuccess andDataModel:(JSONModel * _Nonnull) dataModel
{
    [self.tableViewV finishPullDownWithSuccess:YES];
    [self.tableViewV finishPullUpWithSuccess:YES];
    
    if (isSuccess) {
        self.homeViewController.scrollView.scrollEnabled = YES;
    }
    
    if (isSuccess && !self.hasShowedData) {
        self.hasShowedData = YES;
    }
    
    if (refreshType == FHHomePullTriggerTypePullDown  && self.houseType == houseType) {
        if([dataModel isKindOfClass:[FHHomeHouseModel class]] && isSuccess)
        {
            FHHomeHouseModel *houseData = (FHHomeHouseModel *)dataModel;
            [self.homeViewController showNotify:houseData.data.refreshTip];
            [self setUpTableScrollOffsetZero];
        }
        if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
            [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.houseType)];
        }
    }
    [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
    [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
    self.tableViewV.scrollEnabled = YES;
    [self checkLoadingAndEmpty];
}

//检测加载情况，去除圆圈loading
- (void)checkLoadingAndEmpty
{
    if ([self.homeViewController respondsToSelector:@selector(tt_endUpdataData)]) {
        [self.homeViewController.emptyView hideEmptyView];
        [self.homeViewController tt_endUpdataData];
    }
}

- (void)configIconRowCountAndHeight
{
    [[FHHomeCellHelper sharedInstance] initFHHomeHeaderIconCountAndHeight];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableViewV.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:3];
        [self.tableViewV.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableViewV.mj_footer endRefreshing];
    }
}

//更新房源切换选择器
- (void)updateCategoryViewSegmented:(BOOL)isNeedCreateScroll
{
    if (!isNeedCreateScroll) {
        return;
    }
    
    NSNumber *userSelectType = [[FHEnvContext sharedInstance].generalBizConfig getUserSelectTypeDiskCache];
    NSInteger indexValue = 0;
    NSArray *houstTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    
    if ([houstTypeList containsObject:userSelectType]) {
        indexValue = [houstTypeList indexOfObject:userSelectType];
        NSNumber *numberType = [houstTypeList objectAtIndex:indexValue];
        self.houseType = [userSelectType integerValue];
    }else
    {
        if (houstTypeList.count > 0 && [houstTypeList.firstObject respondsToSelector:@selector(integerValue)]) {
            self.houseType = [houstTypeList.firstObject integerValue];
        }else
        {
            self.houseType = FHHouseTypeSecondHandHouse;
        }
    }
    
    NSArray *houseSegmentArray = [FHHomeCellHelper matchHouseSegmentedTitleArray];
    [self.categoryView updateSegementedTitles:houseSegmentArray andSelectIndex:indexValue];
    
    FHHomeMainViewController *mainVC = nil;
    if ([self.homeViewController.parentViewController isKindOfClass:[FHHomeMainViewController class]]) {
        mainVC = (FHHomeMainViewController *)self.homeViewController.parentViewController;
        [mainVC.topView updateSegementedTitles:houseSegmentArray andSelectIndex:indexValue];
    };
    
    if (isNeedCreateScroll) {
        [self setUpSubtableViewContrllers];
    }
}



- (void)checkCityStatus
{
    
//    if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
//    }else
//    {
//        [self.homeViewController.emptyView.retryButton setTitle:@"先逛逛发现" forState:UIControlStateNormal];
//
//        self.homeViewController.emptyView.retryBlock = ^{
//            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarSecond];
//        };
//
//        [self.homeViewController.emptyView.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [self.homeViewController.emptyView showEmptyWithTip:@"房产资讯、大咖观点、问答百科、攻略指南" errorImage:[UIImage imageNamed:@"group-9"] showRetry:YES];
//        [self.homeViewController.emptyView.retryButton setBackgroundColor:[UIColor themeRed1]];
//        [self.homeViewController.emptyView setUpHomeRedBtn];
//    }
}

- (BOOL)checkIsHasFindHouse
{
    return [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]];
}

- (BOOL)checkIsHaveEntrancesList
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    BOOL isShowHouseBanner = NO;
    
    for (NSInteger i = 0; i < dataModel.opData2list.count; i ++) {
        FHConfigDataOpData2ListModel *dataModelItem = dataModel.opData2list[i];
        if (dataModelItem.opData2Type && [dataModelItem.opData2Type integerValue] == self.houseType && dataModelItem.opDataList && dataModelItem.opDataList.items.count > 0) {
            isShowHouseBanner = YES;
        }
    }
    
    return isShowHouseBanner;
}


#pragma mark 埋点相关

-(NSString *)pageTypeString {
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"new_list";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

- (NSTimeInterval)getCurrentTime
{
    return  [[NSDate date] timeIntervalSince1970];
}

- (void)uploadFirstScreenHouseShow:(NSInteger)index andEnterType:(NSString *)enterType
{
    if (self.itemsVCArray.count > index) {
        FHHomeItemViewController *itemVC = self.itemsVCArray[index];
        itemVC.enterType = enterType;
        [itemVC currentViewIsShowing];
        
        [self bindItemVCTrace];
    }
}

- (void)bindItemVCTrace
{
    for (FHHomeItemViewController *vc in self.itemsVCArray) {
        if ([vc isKindOfClass:[FHHomeItemViewController class]] && vc.houseType == self.previousHouseType) {
            [vc initNotifications];
        }else
        {
            [vc removeNotifications];
        }
    }
}

- (void)sendSwitchButtonClickTrace
{
    NSString *stringClickType = @"be_null";
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            stringClickType = @"new";
            break;
        case FHHouseTypeSecondHandHouse:
            stringClickType = @"old";
            break;
        case FHHouseTypeRentHouse:
            stringClickType = @"rent";
            break;
        default:
            break;
    }
    tracerDict[@"click_type"] = stringClickType;
    
    [FHEnvContext recordEvent:tracerDict andEventKey:@"click_switch_maintablist"];
    
}

- (void)sendTraceEvent:(FHHomeCategoryTraceType)traceType
{
    
}

#pragma mark tableView 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == kFHHomeListHeaderSearchSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KFHHomeSearchCellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:KFHHomeSearchCellId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (![cell.contentView.subviews containsObject:self.homeViewController.topBar]) {
            [cell.contentView addSubview:self.homeViewController.topBar];
            [self.homeViewController.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.centerX.mas_equalTo(0);
                make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
                make.height.mas_equalTo(50);
            }];
        }
        [cell.contentView setBackgroundColor:[UIColor themeHomeColor]];
        return cell;
    }
    
    if (indexPath.row == kFHHomeListHeaderBaseViewSection) {
        JSONModel *model = [[FHEnvContext sharedInstance] getConfigFromCache];
        if (!model) {
            model = [[FHEnvContext sharedInstance] readConfigFromLocal];
        }
        NSString *identifier = [FHHomeCellHelper configIdentifier:model];
        
        FHHomeBaseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [FHHomeCellHelper configureHomeListCell:cell withJsonModel:model];
        return cell;
    }
    
    if (indexPath.row == kFHHomeListHouseTypeBannerViewSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KFHHomeCategoryCellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:KFHHomeCategoryCellId];
        }
        // 添加分页菜单
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (![cell.contentView.subviews containsObject:self.categoryView]) {
            [cell.contentView addSubview:self.categoryView];
        }
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KFHHomeHouseListCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:KFHHomeHouseListCellId];
    }
    // 添加分页菜单
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.homeViewController.scrollView];
    [cell.contentView setBackgroundColor:[UIColor themeHomeColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == kFHHomeListHeaderSearchSection) {
        return KFHHomeSearchBarHeight;
    }
    
    if (indexPath.row == kFHHomeListHeaderBaseViewSection) {
        return [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
    }
    
    if (indexPath.row == kFHHomeListHouseTypeBannerViewSection) {
        return KFHHomeSectionHeight;
    }
    
    return [[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight] + KFHHomeSectionHeight;
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [UIView new];
//    [headerView setBackgroundColor:[UIColor greenColor]];
//    return headerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section = 0) {
//        return KFHHomeSectionHeight;
//    }
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.homeViewController hideImmediately];
    self.isResetingOffsetZero = NO;
    if (scrollView == self.homeViewController.scrollView) {
        self.isSelectIndex = NO;
        self.tableViewV.scrollEnabled = NO;
          self.previousHouseType = self.houseType;
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollBegin" object:nil];
        
        [self setUpHomeItemScrollView:NO];
    }else if(scrollView == self.tableViewV)
    {
        // 滚动时发出通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    if (self.tableViewV == scrollView) {
        
        [self changeTopSearchBtn:scrollView.contentOffset.y > KFHHomeSearchBarHeight];
        
        if ((self.childVCScrollView && _childVCScrollView.contentOffset.y > 0) || (scrollView.contentOffset.y > self.headerHeight + KFHHomeSectionHeight + KFHHomeSearchBarHeight)) {
            [self.categoryView showOriginStyle:NO];
            [self changeHouseCategoryStatus:NO];
            if (!self.isResetingOffsetZero) {
                [self.homeViewController hideImmediately];
                self.tableViewV.contentOffset = CGPointMake(0, self.headerHeight + KFHHomeSectionHeight + KFHHomeSearchBarHeight + 0.01);
            }else
            {
                [self changeHouseCategoryStatus:YES];
            }
        }else
        {
            [self changeHouseCategoryStatus:YES];
        }
        
        
        CGFloat offSetY = scrollView.contentOffset.y;
        
        if (offSetY < self.headerHeight + 80) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"headerViewToTop" object:nil];
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:NO];
        }else
        {
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
        }
    } else if (scrollView == self.homeViewController.scrollView) {
        
        CGFloat contentWidth = (KFHScreenWidth * [FHEnvContext sharedInstance].generalBizConfig.configCache.houseTypeList.count) - KFHScreenWidth;
        if (scrollView.contentOffset.x >= contentWidth) {
            scrollView.contentOffset = CGPointMake(contentWidth, 0);
        }
        
        NSInteger scrollIndex = (NSInteger)((scrollView.contentOffset.x + KFHScreenWidth/2)/KFHScreenWidth);
        if (!self.isSelectIndex) {
            if ([[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList.count > scrollIndex) {
                if ([[[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList[scrollIndex] respondsToSelector:@selector(integerValue)]) {
                    self.houseType = [[[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList[scrollIndex] integerValue];
                    if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.houseType)];
                    }
                    self.categoryView.segmentedControl.selectedSegmentIndex = scrollIndex;
                }
            }
        }
        [self.categoryView refreshSelectionIconFromOffsetX:scrollView.contentOffset.x];
        FHHomeMainViewController *mainVC = nil;
        if ([self.homeViewController.parentViewController isKindOfClass:[FHHomeMainViewController class]]) {
            mainVC = (FHHomeMainViewController *)self.homeViewController.parentViewController;
        };
        mainVC.topView.houseSegmentControl.selectedSegmentIndex = scrollIndex;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.homeViewController.scrollView) {
        [self setUpHomeItemScrollView:YES];
    }else if(scrollView == self.tableViewV)
    {
        // 滚动时发出通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.homeViewController.scrollView) {
        self.isSelectIndex = YES;
        self.tableViewV.scrollEnabled = YES;
        
        if (self.previousHouseType != self.houseType) {
            for (FHHomeItemViewController *vc in self.itemsVCArray) {
                if ([vc isKindOfClass:[FHHomeItemViewController class]] && vc.houseType == self.previousHouseType) {
                    [vc sendTraceEvent:FHHomeCategoryTraceTypeStay];
                }
            }
            
            NSInteger scrollIndex = (NSInteger)((scrollView.contentOffset.x + KFHScreenWidth/2)/KFHScreenWidth);
            [self uploadFirstScreenHouseShow:self.categoryView.segmentedControl.selectedSegmentIndex andEnterType:@"switch"];
            
            self.previousHouseType = self.houseType;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setUpHomeItemScrollView:YES];
        // 滚动时发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
    });
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//    if (scrollView == self.homeViewController.scrollView) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
//    }
    [self setUpHomeItemScrollView:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeMainDidScrollEnd" object:nil];
}

#pragma mark notifications

- (void)subTableViewDidScroll:(NSNotification *)noti {
    self.tableViewV.scrollEnabled = YES;
    UIScrollView *scrollView = noti.object;
    self.childVCScrollView = scrollView;
    if (self.tableViewV.contentOffset.y < self.headerHeight + KFHHomeSectionHeight + KFHHomeSearchBarHeight) {
        scrollView.contentOffset = CGPointZero;
        scrollView.showsVerticalScrollIndicator = NO;
        
        //将未滑动到置顶的子table置顶
        for (FHHomeItemViewController *vc in self.itemsVCArray) {
            if (vc.tableView.numberOfSections > 0 && [vc.tableView numberOfRowsInSection:0] > 0 && (NSInteger)vc.tableView.contentOffset.y != 0){
                vc.tableView.contentOffset = CGPointZero;
            }
        }
    } else {
        //        self.tableView.contentOffset = CGPointMake(0, HeaderViewH);
        scrollView.showsVerticalScrollIndicator = YES;
    }
}

#pragma mark changeTopStatus
- (void)changeHouseCategoryStatus:(BOOL)isShowTopHouse
{
    FHHomeMainViewController *mainVC = nil;
    if ([self.homeViewController.parentViewController isKindOfClass:[FHHomeMainViewController class]]) {
        mainVC = (FHHomeMainViewController *)self.homeViewController.parentViewController;
    };
    [self.categoryView showOriginStyle:isShowTopHouse];
    [mainVC changeTopStatusShowHouse:!isShowTopHouse];
}

- (void)changeTopSearchBtn:(BOOL)isShow
{
    FHHomeMainViewController *mainVC = nil;
    if ([self.homeViewController.parentViewController isKindOfClass:[FHHomeMainViewController class]]) {
        mainVC = (FHHomeMainViewController *)self.homeViewController.parentViewController;
    };
    [mainVC changeTopSearchBtn:isShow];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
