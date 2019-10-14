//
//  FHNeighborListViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHNeighborListViewController.h"
#import "FHHouseType.h"
#import "FHNeighborViewModel.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHNeighborListViewController ()<FHHouseFilterDelegate>

@property (nonatomic, copy) NSString *neighborhoodId;
@property (nonatomic, copy) NSString *houseId;

@property (nonatomic, strong) FHNeighborViewModel *viewModel;
@property (nonatomic, strong) TTRouteParamObj *paramObj;

@property (nonatomic, assign) FHNeighborListVCType neighborListVCType;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FHRefreshCustomFooter *refreshFooter;

// 过滤器filter
@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) id houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@end

@implementation FHNeighborListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        /*
         origin_from
         origin_search_id
         category_name：same_neighborhood_list & related_list ((page_type))
         enter_from:rent_detail（租房详情页）,小区详情页，二手房详情页
         element_from:same_neighborhood（同小区房源），related（周边房源），house_renting（在租房源）,）'在售房源': 'house_onsale',
         $$ search_id:外部的searchId无用，每次使用网络返回的searchId
         */
        _paramObj = paramObj;
        self.neighborhoodId = paramObj.allParams[@"neighborhood_id"];
        self.houseId = paramObj.allParams[@"house_id"];
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        if (paramObj.allParams[@"list_vc_type"]) {
            self.neighborListVCType = [paramObj.allParams[@"list_vc_type"] integerValue];
        }else {
            if ([paramObj.host isEqualToString:@"house_list_related_house"]) {
                self.neighborListVCType = (self.houseType == FHHouseTypeRentHouse) ? FHNeighborListVCTypeRentNearBy : FHNeighborListVCTypeErshouNearBy;
                self.tracerModel.categoryName = [self categoryName];
                if (self.tracerDict) {
                    self.tracerDict[@"category_name"] = self.tracerModel.categoryName;
                }
            }else if ([paramObj.host isEqualToString:@"house_list_same_neighborhood"]) {
                self.neighborListVCType = (self.houseType == FHHouseTypeRentHouse) ? FHNeighborListVCTypeRentSameNeighbor : FHNeighborListVCTypeErshouSameNeighbor;
                self.tracerModel.categoryName = [self categoryName];
                if (self.tracerDict) {
                    self.tracerDict[@"category_name"] = self.tracerModel.categoryName;
                }

            }
        }
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (NSString *)categoryName
{
    if ([_paramObj.host isEqualToString:@"house_list_related_house"]) {
        return @"related_list";
    }else if ([_paramObj.host isEqualToString:@"house_list_same_neighborhood"]) {
        return @"same_neighborhood_list";
    }
    return @"";
}

- (NSString *)titleName
{
    if ([_paramObj.host isEqualToString:@"house_list_related_house"]) {
        return @"周边房源";
    }else if ([_paramObj.host isEqualToString:@"house_list_same_neighborhood"]) {
        return @"同小区房源";
    }
    return @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupFilter];
    [self setupUI];
    [self setupData];
    [self startLoadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.ttNeedHideBottomLine = YES;
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.view).offset(height);
    }];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.top.equalTo(self.filterPanel.mas_bottom);
    }];
    
    [self configTableView];
    self.viewModel = [[FHNeighborViewModel alloc] initWithController:self tableView:_tableView];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.filterPanel.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.view bringSubviewToFront:self.filterBgControl];
    
    if ([_paramObj.allParams[@"title"] isKindOfClass:[NSString class]]) {
        self.customNavBarView.title.text = _paramObj.allParams[@"title"];
    }else {
        self.customNavBarView.title.text = [self titleName];
    }
}

-(void)setupFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:self.houseType showAllCondition:NO showSort:NO];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    self.houseFilterViewModel = bridge;
    [bridge showBottomLine:NO];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [self.filterPanel addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.view addSubview:self.filterPanel];
    [self.view addSubview:self.filterBgControl];
}

- (void)configTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadMore];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [_refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
    
    _refreshFooter.hidden = YES;
}

- (void)setupData {
    __weak typeof(self) wself = self;
    
    _viewModel.conditionNoneFilterBlock = ^NSString * _Nullable(NSDictionary * _Nonnull params) {
        return [wself.houseFilterBridge getNoneFilterQueryParams:params];
    };
    [self.houseFilterViewModel setFilterConditions:_paramObj.queryParams];
    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:self];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.houseFilterBridge trigerConditionChanged];
//        [self firstRequestDataWithLoading:YES];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

// 第一次或者过滤器变化之后重新加载
- (void)firstRequestDataWithLoading:(BOOL)needLoading {
    if (![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    [self.viewModel.houseList removeAllObjects];
    [self.viewModel.houseShowTracerDic removeAllObjects];
    self.hasValidateData = NO;
    self.viewModel.searchId = NULL;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self realRequestWithOffset:0];
    self.viewModel.currentOffset = 0;
}

- (void)loadMore {
    [self.viewModel addCategoryRefreshLog];
    [self realRequestWithOffset:self.viewModel.currentOffset];
}

- (void)realRequestWithOffset:(NSInteger)offset {
    // 是否是第一次请求
    self.viewModel.firstRequestData = (offset == 0 ? YES : NO);
    if (self.neighborListVCType == FHNeighborListVCTypeErshouSameNeighbor ||
        self.neighborListVCType == FHNeighborListVCTypeNeighborOnSales ||
        self.neighborListVCType == FHNeighborListVCTypeNeighborErshou) {
        [self.viewModel requestHouseInSameNeighborhoodSearch:self.neighborhoodId houseId:self.houseId offset:offset];
    } else if (self.neighborListVCType == FHNeighborListVCTypeNeighborOnRent ||
               self.neighborListVCType == FHNeighborListVCTypeNeighborRent ||
               self.neighborListVCType == FHNeighborListVCTypeRentSameNeighbor) {
        [self.viewModel requestRentInSameNeighborhoodSearch:self.neighborhoodId houseId:self.houseId offset:offset];
    } else if (self.neighborListVCType == FHNeighborListVCTypeErshouNearBy) {
        [self.viewModel requestRelatedHouseSearch:self.neighborhoodId houseId:self.houseId offset:offset];
    } else if (self.neighborListVCType == FHNeighborListVCTypeRentNearBy) {
        [self.viewModel requestRentRelatedHouseSearch:self.neighborhoodId houseId:self.houseId offset:offset];
    }
}

#pragma mark - FHHouseFilterDelegate

- (void)onConditionChanged:(NSString *)condition {
    self.tableView.mj_footer.hidden = YES;
    self.viewModel.condition = condition; // 过滤器条件改变
    [self firstRequestDataWithLoading:NO];
}
#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.viewModel addStayCategoryLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
