//
//  FHHomeItemViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/6/12.
//

#import "FHHomeItemViewController.h"
#import <FHRefreshCustomFooter.h>
#import <TTBaseMacro.h>
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <UIScrollView+Refresh.h>
#import <TTHttpTask.h>
#import "FHHomeRequestAPI.h"
#import <FHHomePlaceHolderCell.h>
#import "FHhomeHouseTypeBannerCell.h"
#import "TTDeviceHelper.h"
#import <FHHouseBaseItemCell.h>
#import <FHHomeCellHelper.h>
#import <FHPlaceHolderCell.h>

@interface FHHomeItemViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSInteger itemCount;
@property(nonatomic , assign) FHHomePullTriggerType currentPullType;
@property(nonatomic, strong) TTHttpTask * requestTask;
@property(nonatomic, strong) NSString *currentSearchId;
@property(nonatomic, strong) NSMutableArray *houseDataItemsModel;
@property(nonatomic, assign) BOOL isRetryedPullDownRefresh;
@property(nonatomic, assign) BOOL hasMore;
@property(nonatomic, strong) NSString *enterType; //当前enterType，用于enter_category
@property(nonatomic, strong) NSString *originSearchId;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间

@end

@implementation FHHomeItemViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.houseDataItemsModel = [NSMutableArray new];
    self.isRetryedPullDownRefresh = NO;
    self.hasMore = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageTitleViewToTop) name:@"headerViewToTop" object:nil];
    
    [self.view addSubview:self.tableView];
    
    [FHHomeCellHelper registerCells:self.tableView];
    
    _itemCount = 30;
    
    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        if ([FHEnvContext isNetworkConnected]) {
            [self requestDataForRefresh:FHHomePullTriggerTypePullUp andIsFirst:NO];
        }else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView finishPullUpWithSuccess:YES];
                });
            });
            [self.tableView.mj_footer endRefreshing];
            [[ToastManager manager] showToast:@"网络异常"];
        }
    }];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.mj_footer = self.refreshFooter;
    
    [self registerCells];
    
    [self showPlaceHolderCells];
    
    [self requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
}

- (void)registerCells
{
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHomeSmallImageItemCell"];
    
    [self.tableView  registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHHomePlaceHolderCell class])];
    
    [self.tableView  registerClass:[FHHomeBaseTableCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBaseTableCell class])];
    
    [self.tableView  registerClass:[FHhomeHouseTypeBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHhomeHouseTypeBannerCell class])];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
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

- (void)pageTitleViewToTop {
    self.tableView.contentOffset = CGPointZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200);
}

#pragma mark reload data

- (void)showPlaceHolderCells
{
    self.showPlaceHolder = YES;
    [self.tableView reloadData];
}
//城市开通，且无房源时显示error页
- (void)reloadCityEnbaleAndNoHouseData:(BOOL)isNoData
{
    self.tableView.hasMore = NO;
    self.tableView.mj_footer.hidden = YES;
    [self.refreshFooter setUpNoMoreDataText:@"" offsetY:3];
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    self.showNoDataErrorView = isNoData;
    self.showRequestErrorView = !isNoData;
    self.showPlaceHolder = NO;
    [self.tableView reloadData];
}

//重载当前请求下发的数据
- (void)reloadHomeTableHouseSection
{
    self.showNoDataErrorView = NO;
    self.showRequestErrorView = NO;
    self.showPlaceHolder = NO;
    [self.tableView reloadData];
}


- (void)checkCityStatus
{
    [self reloadCityEnbaleAndNoHouseData:[[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue];
}

#pragma mark request
//请求推荐刷新数据，包括上拉和下拉
- (void)requestDataForRefresh:(FHHomePullTriggerType)pullType andIsFirst:(BOOL)isFirst
{
    self.currentPullType = pullType;
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    NSInteger offsetValue = self.houseDataItemsModel.count;
    
    if (isFirst) {
        [requestDictonary setValue:@(0) forKey:@"offset"];
    }else
    {
        [requestDictonary setValue:@(offsetValue) forKey:@"offset"];
    }
    [requestDictonary setValue:@(self.houseType) forKey:@"house_type"];
    [requestDictonary setValue:@(20) forKey:@"count"];
    
    if ([self.requestTask isKindOfClass:[TTHttpTask class]]) {
        [self.requestTask cancel];
        self.requestTask = nil;
    }
    
    WeakSelf;
    self.requestTask = [FHHomeRequestAPI requestRecommendForLoadMore:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        
        self.requestTask = nil;
        
        [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
                
        //判断下拉刷新
        if (pullType == FHHomePullTriggerTypePullDown) {
            //请求无错误,无错误
            if (model.data.items.count == 0 && !error && isFirst) {
                [self checkCityStatus];
                if (self.requestCallBack) {
                    self.requestCallBack(pullType, self.houseType, NO, nil);
                }
                return;
            }
            
            if (error && [error.userInfo[@"NSLocalizedDescription"] isKindOfClass:[NSString class]] && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                [self reloadCityEnbaleAndNoHouseData:NO];
                if (self.requestCallBack) {
                    self.requestCallBack(pullType, self.houseType, NO, nil);
                }
                return ;
            }
        }else
        {
            if (error) {
                if ([error.userInfo[@"NSLocalizedDescription"] isKindOfClass:[NSString class]] && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                    [[ToastManager manager] showToast:@"网络异常"];
                }
                [self updateTableViewWithMoreData:YES];
                return;
            }
        }
        
        self.isRetryedPullDownRefresh = NO;
        
        [self.tableView finishPullDownWithSuccess:YES];
        [self.tableView finishPullUpWithSuccess:YES];
        
        
        if (pullType == FHHomePullTriggerTypePullDown) {
            self.originSearchId = model.data.searchId;
            self.houseDataItemsModel = [NSMutableArray arrayWithArray:model.data.items];
        }else
        {
            if (model.data.items) {
              self.houseDataItemsModel = [self.houseDataItemsModel arrayByAddingObjectsFromArray:model.data.items];
            }
        }
        [self reloadHomeTableHouseSection];
        
        self.tableView.hasMore = model.data.hasMore;
        [self updateTableViewWithMoreData:model.data.hasMore];
        
        [self sendTraceEvent:FHHomeCategoryTraceTypeRefresh];
        
        if (model.data.refreshTip && pullType == FHHomePullTriggerTypePullDown) {
            [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = NO;
            self.tableView.contentOffset = CGPointMake(0, 0);
        }
        
        if (pullType == FHHomePullTriggerTypePullUp) {
            [self.tableView finishPullUpWithSuccess:YES];
        }
        
        if (self.requestCallBack) {
            self.requestCallBack(pullType, self.houseType, YES, model);
        }
    }];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark 埋点

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

- (void)sendTraceEvent:(FHHomeCategoryTraceType)traceType
{
    NSMutableDictionary *tracerDict = [NSMutableDictionary new];
    self.tracerModel.enterFrom = @"maintab";
    self.tracerModel.elementFrom = @"maintab_list";
    
    tracerDict[@"category_name"] = [self pageTypeString] ? : @"be_null";
    tracerDict[@"enter_from"] = @"maintab";
    tracerDict[@"enter_type"] = self.enterType ? : @"be_null";
    tracerDict[@"element_from"] = @"maintab_list";
    tracerDict[@"search_id"] = self.currentSearchId ? : @"be_null";
    tracerDict[@"origin_from"] = [self pageTypeString]  ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.currentSearchId ? :@"be_null";
    
    
    if (traceType == FHHomeCategoryTraceTypeEnter) {
        [FHEnvContext recordEvent:tracerDict andEventKey:@"enter_category"];
    }else if (traceType == FHHomeCategoryTraceTypeStay)
    {
        NSTimeInterval duration = ([self getCurrentTime] - self.stayTime) * 1000.0;
        if (duration) {
            [tracerDict setValue:@((int)duration) forKey:@"stay_time"];
        }
        [FHEnvContext recordEvent:tracerDict andEventKey:@"stay_category"];
    }else if (traceType == FHHomeCategoryTraceTypeRefresh)
    {
        NSString *stringReloadType = @"pull";
        if (self.reloadType == TTReloadTypeTab) {
            stringReloadType = @"tab";
        }
        if (self.reloadType == TTReloadTypeClickCategory) {
            stringReloadType = @"click";
        }
        tracerDict[@"refresh_type"] = (self.currentPullType == FHHomePullTriggerTypePullUp ? @"pre_load_more" : stringReloadType);
        [FHEnvContext recordEvent:tracerDict andEventKey:@"category_refresh"];
        
        self.reloadType = nil;
    }
    
}

- (CGFloat)getHeightShowNoData
{
    if([TTDeviceHelper isScreenWidthLarge320])
    {
        return [UIScreen mainScreen].bounds.size.height * 0.45;
    }else
    {
        return [UIScreen mainScreen].bounds.size.height * 0.65;
    }
}

#pragma mark delegte

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 滚动时发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeSubTableViewDidScroll" object:scrollView];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([self checkIsHaveEntrancesList]) {
            return 1;
        }
        return 0;
    }
    
    if (self.showNoDataErrorView || self.showRequestErrorView) {
        return 1;
    }
    
    if (self.showPlaceHolder) {
        return 10;
    }
    return self.houseDataItemsModel.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self checkIsHaveEntrancesList]) {
            //适配5s
            if ([TTDeviceHelper isScreenWidthLarge320]) {
                return 89;
            }else
            {
                return 74;
            }
        }
        return 0;
    }else
    {
        if (self.showNoDataErrorView || self.showRequestErrorView) {
            return [self getHeightShowNoData];
        }
        
        return 75;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kFHHomeHouseTypeBannerViewSection)
    {
        FHhomeHouseTypeBannerCell *bannerCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHhomeHouseTypeBannerCell class])];
        [bannerCell refreshData:self.houseType];
        return bannerCell;
    }else
    {
        
        if (self.showNoDataErrorView) {
            
            UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            for (UIView *subView in cellError.contentView.subviews) {
                [subView removeFromSuperview];
            }
            cellError.selectionStyle = UITableViewCellSelectionStyleNone;
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self getHeightShowNoData])];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [cellError.contentView addSubview:noDataErrorView];
            
            [noDataErrorView showEmptyWithTip:@"当前城市暂未开通服务，敬请期待" errorImageName:@"group-9"
                                    showRetry:NO];
            return cellError;
        }
        
        if (self.showRequestErrorView) {
            UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
            for (UIView *subView in cellError.contentView.subviews) {
                [subView removeFromSuperview];
            }
            cellError.selectionStyle = UITableViewCellSelectionStyleNone;
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [self getHeightShowNoData])];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [cellError.contentView addSubview:noDataErrorView];
            
            [noDataErrorView showEmptyWithTip:@"数据走丢了" errorImageName:@"group-9"
                                    showRetry:YES];
            __weak typeof(self) weakSelf = self;
            noDataErrorView.retryBlock = ^{
                [self requestDataForRefresh:FHHomePullTriggerTypePullDown andIsFirst:YES];
            };
            return cellError;
        }
        
        if (self.showPlaceHolder) {
            FHHomePlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHHomePlaceHolderCell class])];
            return cell;
        }
        
        //to do 房源cell
        FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHHomeSmallImageItemCell"];
        if (indexPath.row < self.houseDataItemsModel.count) {
            JSONModel *model = self.houseDataItemsModel[indexPath.row];
            [cell refreshTopMargin:([TTDeviceHelper is896Screen3X] || [TTDeviceHelper is896Screen2X]) ? 4 : 0];
            [cell updateHomeSmallImageHouseCellModel:model andType:self.houseType];
        }
        return cell;
    }
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

