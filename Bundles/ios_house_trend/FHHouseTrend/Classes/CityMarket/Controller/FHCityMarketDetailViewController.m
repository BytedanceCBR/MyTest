//
//  FHCityMarketDetailViewController.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketDetailViewController.h"
#import "FHDetailListViewModel.h"
#import "FHCityMarketHeaderView.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import "FHCityMarketTrendHeaderViewModel.h"
#import "FHDetailListViewModel.h"
#import "FHChatSectionCellPlaceHolder.h"
#import "FHCityMarketRecommendSectionPlaceHolder.h"
#import "FHAreaItemSectionPlaceHolder.h"
#import "CityMarketDetailAPI.h"
#import "ReactiveObjC.h"
#import "FHCityMarketHeaderPropertyItemView.h"
#import "FHCityMarketHeaderPropertyBar.h"
#import "RXCollection.h"
#import "FHCityMarketDetailResponseModel.h"
#import "FHCityMarketBottomBarView.h"
#import "FHCityMarketRecommendViewModel.h"
#import "FHImmersionNavBarViewModel.h"
#import "TTTracker.h"
#import "TTTrackerWrapper.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHCityOpenUrlJumpAction : NSObject
@property (nonatomic, strong) NSURL* openUrl;
@property (nonatomic, strong) TTRouteUserInfo* userInfo;
-(void)jump;
@end

@implementation FHCityOpenUrlJumpAction

- (void)jump {
    if (_userInfo != nil) {
        [[TTRoute sharedRoute] openURLByPushViewController:_openUrl userInfo:_userInfo];
    } else {
        [[TTRoute sharedRoute] openURLByPushViewController:_openUrl];
    }
}

@end

@interface FHCityMarketDetailViewController ()<FHCityMarketRecommendViewModelDataChangedListener, FHCityMarketTrendHeaderViewModelDelegate>
{
    NSMutableArray<FHCityOpenUrlJumpAction*>* _actions;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) FHDetailListViewModel* listViewModel;
@property (nonatomic, strong) FHCityMarketHeaderView* headerView;
@property (nonatomic, strong) FHCityMarketTrendHeaderViewModel* headerViewModel;
@property (nonatomic, strong) FHChatSectionCellPlaceHolder* chatSectionCellPlaceHolder;
@property (nonatomic, strong) FHAreaItemSectionPlaceHolder* areaItemSectionCellPlaceHolder;
@property (nonatomic, strong) FHCityMarketRecommendSectionPlaceHolder* recommendSectionPlaceHolder;
@property (nonatomic, strong) FHCityMarketBottomBarView* bottomBarView;
@property (nonatomic, strong) FHImmersionNavBarViewModel* navBarViewModel;
@property (nonatomic, strong) RACDisposable* disposable;
@end

@implementation FHCityMarketDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.navBarViewModel = [[FHImmersionNavBarViewModel alloc] init];
        _actions = [[NSMutableArray alloc] init];
        self.tracerDict[@"enter_from"] = paramObj.allParams[@"enter_from"];
        self.tracerDict[@"origin_from"] = paramObj.allParams[@"origin_from"];
        self.tracerDict[@"origin_search_id"] = paramObj.allParams[@"origin_search_id"];
        self.tracerDict[@"search_id"] = paramObj.allParams[@"search_id"];

        _headerViewModel = [[FHCityMarketTrendHeaderViewModel alloc] init];
        _headerViewModel.delegate = self;
        [_headerViewModel requestData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initNavBar];
    [self setupBottomBar];
    self.tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [_tableView setHidden:YES];
    _listViewModel = [[FHDetailListViewModel alloc] init];
    _listViewModel.tableView = _tableView;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = _listViewModel;
    _tableView.dataSource = _listViewModel;

    if (@available(iOS 7.0, *)) {
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedRowHeight = 0;
    } else {
        // Fallback on earlier versions
    }

    self.tableView.sectionFooterHeight = 0;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 0.1)]; //to do:设置header0.1，防止系统自动设置高度

    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    }

    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
    }];
    UIView* tableBgView = [[UIView alloc] init];
    tableBgView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = tableBgView;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 84 : 64;

    self.headerView = [[FHCityMarketHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 195 + navBarHeight)]; //174
    _tableView.tableHeaderView = _headerView;
    [self.view bringSubviewToFront:_bottomBarView];

    [self addDefaultEmptyViewFullScreen];
    [self setupSections];
    [self bindHeaderView];
    [self logGoDetail];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self bindStatusBarObv];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_disposable dispose];
    _disposable = nil;
}

-(void)logGoDetail {
    [TTTrackerWrapper eventV3:@"go_detail" params:@{
                                                    @"event_type": @"house_app2c_v2",
                                                    @"page_type": @"city_market",
//                                                    @"enter_from": self.tracerDict[@"enter_from"] ? : @"be_null",
                                                    @"enter_from": @"maintab_operation",
                                                    }];
}

-(void)initNavBar {
    [self setupDefaultNavBar:NO];
    //    self.customNavBarView.leftBtn.hidden = [self leftActionHidden];
    self.customNavBarView.title.text = @"城市行情";
    self.customNavBarView.title.textColor = [UIColor whiteColor];
    [self.customNavBarView cleanStyle:YES];
    self.customNavBarView.bgView.backgroundColor = [UIColor whiteColor];
}

-(void)bindHeaderView {
    RAC(_headerView.titleLabel, text) = RACObserve(_headerViewModel, title);
    RAC(_headerView.priceLabel, text) = RACObserve(_headerViewModel, price);
    RAC(_headerView.sourceLabel, text) = RACObserve(_headerViewModel, source);
    RAC(_headerView.unitLabel, text) = RACObserve(_headerViewModel, unit);
    @weakify(self);
    [[[RACObserve(_headerViewModel, properties) filter:^BOOL(id  _Nullable value) {
        return value != nil;
    }] map:^id _Nullable(NSArray<FHCityMarketDetailResponseDataSummaryItemListModel*>*  _Nullable value) {
        NSArray* result = [value rx_mapWithBlock:^id(FHCityMarketDetailResponseDataSummaryItemListModel* each) {
            FHCityMarketHeaderPropertyItemView* itemView = [[FHCityMarketHeaderPropertyItemView alloc] init];
            itemView.nameLabel.text = each.desc;
            itemView.valueLabel.text = each.value;
            [itemView setArraw:[each.showArrow integerValue]];
            return itemView;
        }];
        return result;
    }] subscribeNext:^(NSArray*  _Nullable x) {
        @strongify(self);
        [self.headerView.propertyBar setPropertyItem:x];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listViewModel adjustSectionOffset];
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listViewModel notifyCellDisplay];
            });
        });
        self.navBarViewModel.isHasData = YES;
        [self endLoading];
        if ([x count] > 0) {
            [self.tableView setHidden:NO];
            [self.emptyView setHidden:YES];
        }
        [self fillDataToBottomBar];
    }];

    RAC(_chatSectionCellPlaceHolder, marketTrendList) = [RACObserve(_headerViewModel, model) map:^id _Nullable(FHCityMarketDetailResponseModel*  _Nullable value) {
        return value.data.marketTrendList;
    }];

    RAC(_chatSectionCellPlaceHolder, districtNameList) = [RACObserve(_headerViewModel, model) map:^id _Nullable(FHCityMarketDetailResponseModel*  _Nullable value) {
        FHCityMarketDetailResponseDataMarketTrendListModel* listModel = value.data.marketTrendList.firstObject;
        return [listModel.districtMarketInfoList rx_mapWithBlock:^id(FHCityMarketDetailResponseDataMarketTrendListDistrictMarketInfoListModel* each) {
            return each.locationName;
        }];
    }];

    RAC(_areaItemSectionCellPlaceHolder, hotList) = [RACObserve(_headerViewModel, model) map:^id _Nullable(FHCityMarketDetailResponseModel* _Nullable value) {
        return value.data.hotList;
    }];
    RAC(_recommendSectionPlaceHolder, specialOldHouseList) = [RACObserve(_headerViewModel, model) map:^id _Nullable(FHCityMarketDetailResponseModel*  _Nullable value) {
        return value.data.specialOldHouseList;
    }];

    RAC(self.customNavBarView.bgView, alpha) = RACObserve(_navBarViewModel, alpha);
    [RACObserve(_navBarViewModel, backButtonImage) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.customNavBarView.leftBtn setImage:x forState:UIControlStateNormal];
    }];
    RAC(self.customNavBarView.title, textColor) = RACObserve(_navBarViewModel, titleColor);
    RAC(_navBarViewModel, currentContentOffset) = RACObserve(_tableView, contentOffset);
    [self bindStatusBarObv];
    if (_headerViewModel.model == nil) {
        [self startLoading];
    }
//    [_headerViewModel requestData];
}

-(void)bindStatusBarObv {
    if (_disposable != nil) {
        [_disposable dispose];
        _disposable = nil;
    }
    _disposable = [RACObserve(_navBarViewModel, statusBarStyle) subscribeNext:^(id  _Nullable x) {
        if ([x integerValue] == 0) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }];
}

-(void)setupSections {
    self.chatSectionCellPlaceHolder = [[FHChatSectionCellPlaceHolder alloc] init];
    self.chatSectionCellPlaceHolder.tracer = self.tracerDict;
    [_listViewModel addSectionPlaceHolder:_chatSectionCellPlaceHolder];
    FHCityMarketRecommendViewModel* viewModel = [[FHCityMarketRecommendViewModel alloc] init];
    viewModel.listener = self;
    self.recommendSectionPlaceHolder = [[FHCityMarketRecommendSectionPlaceHolder alloc] initWithViewModel:viewModel];
    self.recommendSectionPlaceHolder.tracer = self.tracerDict;
    [_listViewModel addSectionPlaceHolder:_recommendSectionPlaceHolder];

    self.areaItemSectionCellPlaceHolder = [[FHAreaItemSectionPlaceHolder alloc] init];
    self.areaItemSectionCellPlaceHolder.tracer = self.tracerDict;
    [_listViewModel addSectionPlaceHolder:_areaItemSectionCellPlaceHolder];

//    [self.tableView reloadData];
}

-(void)setupBottomBar {
    self.bottomBarView = [[FHCityMarketBottomBarView alloc] init];
//    _bottomBarView.layer.shadowRadius = 4;
//    _bottomBarView.layer.shadowColor = [UIColor blackColor].CGColor;
//    _bottomBarView.layer.shadowOpacity = 0.06;
//    _bottomBarView.layer.shadowOffset = CGSizeMake(0, -2);
    [self.view addSubview:_bottomBarView];
    [_bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.view);
        if ([TTDeviceHelper isIPhoneXDevice]) {
            make.height.mas_equalTo(98);
        } else {
            make.height.mas_equalTo(64);
        }
    }];
}

-(void)fillDataToBottomBar {
    TTRouteUserInfo* info = [[TTRouteUserInfo alloc] initWithInfo:[self traceParams]];
    NSArray<FHCityMarketBottomBarItem*>* items = [_headerViewModel.model.data.bottomButtons rx_mapWithBlock:^id(FHCityMarketDetailResponseBottomButton* each) {
        FHCityMarketBottomBarItem* item = [[FHCityMarketBottomBarItem alloc] init];
        item.titleLabel.text = each.text;
        item.backgroundColor = [UIColor colorWithHexString:each.color];

        FHCityOpenUrlJumpAction* action = [[FHCityOpenUrlJumpAction alloc] init];
        if (each.openUrl != nil) {
            action.openUrl = [NSURL URLWithString:each.openUrl];
        }
        action.userInfo = info;
        [item addTarget:action action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
        [_actions addObject:action];
        item.layer.cornerRadius = 22;
        return item;
    }];

    if (items.count == 0) {
        _bottomBarView.hidden = YES;
        CGFloat buttomBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 30 : 10;

        _tableView.contentInset = UIEdgeInsetsMake(0, 0, buttomBarHeight, 0);
    } else {
        CGFloat buttomBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 98 : 64;
        // 这里设置tableView底部滚动的区域，保证内容可以完全露出
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, buttomBarHeight, 0);
        [_bottomBarView setBottomBarItems:items];
        [_headerViewModel.model.data.bottomButtons enumerateObjectsUsingBlock:^(FHCityMarketDetailResponseBottomButton*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type != nil) {
                [self traceElementShow:obj.type];
            }
        }];
    }
}

-(void)traceElementShow:(NSString*)elementType {
    NSParameterAssert(elementType);
    NSMutableDictionary* tracer = [self.tracerDict mutableCopy];
    tracer[@"rank"] = @"be_null";
    tracer[@"page_type"] = @"city_market";
    tracer[@"element_type"] = elementType;
    tracer[@"enter_from"] = nil;
    [FHUserTracker writeEvent:@"element_show" params:tracer];
}

-(NSDictionary*)traceParams {
    self.tracerDict[@"enter_from"] = @"city_market";
    self.tracerDict[@"origin_from"] = @"city_market";
    NSDictionary *tracer = @{@"tracer":[self.tracerDict copy] ? : @{}};
    return tracer;
}

-(void)onDataArrived {
    [self.listViewModel adjustSectionOffset];
    [_tableView reloadData];
}


-(void)onNetworkError {
    [self endLoading];
    _navBarViewModel.isHasData = NO;
    [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
}

-(void)onNoNetwork {
    _navBarViewModel.isHasData = NO;
    [self endLoading];
    [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
}

- (void)retryLoadData {
    [_headerViewModel requestData];
}

@end
