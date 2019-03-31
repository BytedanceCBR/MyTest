//
//  FHCityMarketDetailViewController.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketDetailViewController.h"
#import "FHDetailListViewModel.h"
#import "FHCityMarketHeaderView.h"
#import <Masonry.h>
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

@interface FHCityOpenUrlJumpAction : NSObject
@property (nonatomic, strong) NSURL* openUrl;
-(void)jump;
@end

@implementation FHCityOpenUrlJumpAction

- (void)jump {
    [[TTRoute sharedRoute] openURLByPushViewController:_openUrl];
}

- (void)dealloc
{

}

@end

@interface FHCityMarketDetailViewController ()<FHCityMarketRecommendViewModelDataChangedListener>
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
@end

@implementation FHCityMarketDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.navBarViewModel = [[FHImmersionNavBarViewModel alloc] init];
        _actions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavBar];

    [self setupBottomBar];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _listViewModel = [[FHDetailListViewModel alloc] init];
    _listViewModel.tableView = _tableView;
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
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 84 : 64;

    self.headerView = [[FHCityMarketHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 195 + navBarHeight)]; //174
    _tableView.tableHeaderView = _headerView;
    [self.view bringSubviewToFront:_bottomBarView];
    CGFloat buttomBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 98 : 64;
    // 这里设置tableView底部滚动的区域，保证内容可以完全露出
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, buttomBarHeight, 0);
    [self setupSections];
    [self bindHeaderView];
}

-(void)initNavBar {
    [self setupDefaultNavBar:NO];
    //    self.customNavBarView.leftBtn.hidden = [self leftActionHidden];
    self.customNavBarView.title.text = @"城市行情";
    self.customNavBarView.title.textColor = [UIColor whiteColor];
    [self.customNavBarView cleanStyle:YES];
}

-(void)bindHeaderView {
    _headerViewModel = [[FHCityMarketTrendHeaderViewModel alloc] init];

    RAC(_headerView.titleLabel, text) = RACObserve(_headerViewModel, title);
    RAC(_headerView.priceLabel, text) = RACObserve(_headerViewModel, price);
    RAC(_headerView.sourceLabel, text) = RACObserve(_headerViewModel, source);
    RAC(_headerView.unitLabel, text) = RACObserve(_headerViewModel, unit);
    @weakify(self);
    [[[RACObserve(_headerViewModel, properties) skip:1] map:^id _Nullable(NSArray<FHCityMarketDetailResponseDataSummaryItemListModel*>*  _Nullable value) {
        NSArray* result = [value rx_mapWithBlock:^id(FHCityMarketDetailResponseDataSummaryItemListModel* each) {
            FHCityMarketHeaderPropertyItemView* itemView = [[FHCityMarketHeaderPropertyItemView alloc] init];
            itemView.nameLabel.text = each.desc;
            itemView.valueLabel.text = each.value;
            [itemView setArraw:[each.showArrow integerValue]];
            return itemView;
        }];
        return result;
    }] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.headerView.propertyBar setPropertyItem:x];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listViewModel adjustSectionOffset];
            [self.tableView reloadData];
        });
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
    RAC(_navBarViewModel, currentContentOffset) = RACObserve(_tableView, contentOffset);
    [_headerViewModel requestData];
}

-(void)setupSections {
    self.chatSectionCellPlaceHolder = [[FHChatSectionCellPlaceHolder alloc] init];
    [_listViewModel addSectionPlaceHolder:_chatSectionCellPlaceHolder];
    FHCityMarketRecommendViewModel* viewModel = [[FHCityMarketRecommendViewModel alloc] init];
    viewModel.listener = self;
    self.recommendSectionPlaceHolder = [[FHCityMarketRecommendSectionPlaceHolder alloc] initWithViewModel:viewModel];
    [_listViewModel addSectionPlaceHolder:_recommendSectionPlaceHolder];

    self.areaItemSectionCellPlaceHolder = [[FHAreaItemSectionPlaceHolder alloc] init];
    [_listViewModel addSectionPlaceHolder:_areaItemSectionCellPlaceHolder];

    [self.tableView reloadData];
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

    FHCityMarketBottomBarItem* item = [[FHCityMarketBottomBarItem alloc] init];
    item.titleLabel.text = @"买房估价";
    item.backgroundColor = [UIColor colorWithHexString:@"ff8151"];
    FHCityOpenUrlJumpAction* action = [[FHCityOpenUrlJumpAction alloc] init];
    action.openUrl = [NSURL URLWithString:@"sslocal://price_valuation"];
    [item addTarget:action action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    [_actions addObject:action];
    FHCityMarketBottomBarItem* item2 = [[FHCityMarketBottomBarItem alloc] init];
    item2.titleLabel.text = @"帮我找房";
    item2.backgroundColor = [UIColor colorWithHexString:@"ff5869"];
    [_bottomBarView setBottomBarItems:@[item, item2]];
}

-(void)onDataArrived {
    [_tableView reloadData];
}

@end
