//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/10/22.
//

#import "FHHomeListViewModel.h"
#import "FHHomeMainTableViewDataSource.h"
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

#define KFHScreenWidth [UIScreen mainScreen].bounds.size.width
#define KFHScreenHeight [UIScreen mainScreen].bounds.size.height
#define KFHHomeSectionHeight 45

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
            if (xConfigDataModel.houseTypeList.count <= 1) {
                self.headerHeight += KFHHomeSectionHeight;
            }else
            {
                self.headerHeight += 1;
            }
            [self.tableViewV reloadData];
            
            [self setUpTableScrollOffsetZero];
            
            self.isSelectIndex = YES;
            
            [self configIconRowCountAndHeight];
            
            [FHEnvContext changeFindTabTitle];
            [FHEnvContext showRedPointForNoUgc];
            
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
        };
    }
    return self;
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
            
            itemVC.scrollDidEnd = ^{
                
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
    [self.homeViewController.scrollView setContentSize:CGSizeMake(KFHScreenWidth * configDataModel.houseTypeList.count, self.homeViewController.scrollView.frame.size.height)];
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

- (void)setUpSubtableIndex:(NSInteger)index
{
    if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
        [[FHEnvContext sharedInstance].generalBizConfig updateUserSelectDiskCacheIndex:@(self.houseType)];
    }
    self.homeViewController.scrollView.contentOffset = CGPointMake(KFHScreenWidth * index, 0);
    [self uploadFirstScreenHouseShow:self.categoryView.segmentedControl.selectedSegmentIndex andEnterType:@"click"];
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
    
    [self.categoryView updateSegementedTitles:[self matchHouseSegmentedTitleArray]  andSelectIndex:indexValue];
    
    if (isNeedCreateScroll) {
        [self setUpSubtableViewContrllers];
    }
}

//匹配房源名称
- (NSArray <NSString *>*)matchHouseSegmentedTitleArray
{
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSMutableArray *titleArrays = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < configDataModel.houseTypeList.count; i++) {
        NSNumber *houseTypeNum = configDataModel.houseTypeList[i];
        if ([houseTypeNum isKindOfClass:[NSNumber class]]) {
            NSString * houseStr = [self matchHouseString:[houseTypeNum integerValue]];
            if (kIsNSString(houseStr) && houseStr.length != 0) {
                [titleArrays addObject:houseStr];
            }
        }
    }
    return titleArrays;
}

- (void)checkCityStatus
{
    if ([[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
    }else
    {
        NSString *tabName = [FHEnvContext secondTabName];
        NSString *str = @"先逛逛发现";
        if(tabName.length > 0){
            str = [NSString stringWithFormat:@"先逛逛%@",tabName];
        }
        
        [self.homeViewController.emptyView.retryButton setTitle:str forState:UIControlStateNormal];
        
        self.homeViewController.emptyView.retryBlock = ^{
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarSecond];
        };
        
        [self.homeViewController.emptyView.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.homeViewController.emptyView showEmptyWithTip:@"房产资讯、大咖观点、问答百科、攻略指南" errorImage:[UIImage imageNamed:@"group-9"] showRetry:YES];
        [self.homeViewController.emptyView.retryButton setBackgroundColor:[UIColor themeRed1]];
        [self.homeViewController.emptyView setUpHomeRedBtn];
    }
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
    }
}

- (NSString *)matchHouseString:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
        {
            return @"新房";
        }
            break;
        case FHHouseTypeRentHouse:
        {
            return @"租房";
        }
            break;
        case FHHouseTypeNeighborhood:
        {
            return @"小区";
        }
            break;
        case FHHouseTypeSecondHandHouse:
        {
            return @"二手房";
        }
            break;
            
        default:
            return @"";
            break;
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        }
        // 添加分页菜单
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.categoryView];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    // 添加分页菜单
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.homeViewController.scrollView];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == kFHHomeListHeaderBaseViewSection) {
        return [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
    }
    
    if (indexPath.row == kFHHomeListHouseTypeBannerViewSection) {
        self.headerHeight = [[FHHomeCellHelper sharedInstance] heightForFHHomeHeaderCellViewType];
        
        if (self.categoryView.segmentedControl.sectionTitles.count <= 1) {
            self.headerHeight += KFHHomeSectionHeight;
        }else
        {
            self.headerHeight += 1;
        }
        
        return KFHHomeSectionHeight;
    }
    
    return [[FHHomeCellHelper sharedInstance] heightForFHHomeListHouseSectionHeight] + 45;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.homeViewController hideImmediately];
    self.isResetingOffsetZero = NO;
    if (scrollView == self.homeViewController.scrollView) {
        self.isSelectIndex = NO;
        self.tableViewV.scrollEnabled = NO;
        self.previousHouseType = self.houseType;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableViewV == scrollView) {
        if ((self.childVCScrollView && _childVCScrollView.contentOffset.y > 0) || (scrollView.contentOffset.y > self.headerHeight)) {
            [self.categoryView showOriginStyle:NO];
            
            if (!self.isResetingOffsetZero) {
                [self.homeViewController hideImmediately];
                self.tableViewV.contentOffset = CGPointMake(0, self.headerHeight);
            }else
            {
                [self.categoryView showOriginStyle:YES];
            }
        }else
        {
            [self.categoryView showOriginStyle:YES];
        }
        
        CGFloat offSetY = scrollView.contentOffset.y;
        
        if (offSetY < self.headerHeight) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"headerViewToTop" object:nil];
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:NO];
        }else
        {
            [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
        }
    } else if (scrollView == self.homeViewController.scrollView) {
        if (!self.isSelectIndex) {
            NSInteger scrollIndex = (NSInteger)((scrollView.contentOffset.x + KFHScreenWidth/2)/KFHScreenWidth);
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
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.homeViewController.scrollView) {
        
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
}

- (void)subTableViewDidScroll:(NSNotification *)noti {
    self.tableViewV.scrollEnabled = YES;
    UIScrollView *scrollView = noti.object;
    self.childVCScrollView = scrollView;
    if (self.tableViewV.contentOffset.y < self.headerHeight) {
        scrollView.contentOffset = CGPointZero;
        scrollView.showsVerticalScrollIndicator = NO;
    } else {
        //        self.tableView.contentOffset = CGPointMake(0, HeaderViewH);
        scrollView.showsVerticalScrollIndicator = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
