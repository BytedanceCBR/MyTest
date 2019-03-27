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
@interface FHCityMarketDetailViewController ()
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) FHDetailListViewModel* listViewModel;
@property (nonatomic, strong) FHCityMarketHeaderView* headerView;
@property (nonatomic, strong) FHCityMarketTrendHeaderViewModel* headerViewModel;
@property (nonatomic, strong) FHChatSectionCellPlaceHolder* chatSectionCellPlaceHolder;
@property (nonatomic, strong) FHAreaItemSectionPlaceHolder* areaItemSectionCellPlaceHolder;
@end

@implementation FHCityMarketDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavBar];

    self.tableView = [[UITableView alloc] init];
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
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 64 : 84;

    self.headerView = [[FHCityMarketHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 195 + navBarHeight)]; //174
    _tableView.tableHeaderView = _headerView;

    _listViewModel = [[FHDetailListViewModel alloc] init];
    _listViewModel.tableView = _tableView;
    _tableView.delegate = _listViewModel;
    _tableView.dataSource = _listViewModel;
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
    [_headerViewModel requestData];
}

-(void)setupSections {
    _chatSectionCellPlaceHolder = [[FHChatSectionCellPlaceHolder alloc] init];
    [_listViewModel addSectionPlaceHolder:_chatSectionCellPlaceHolder];


    id<FHSectionCellPlaceHolder> holder = nil;
    holder = [[FHCityMarketRecommendSectionPlaceHolder alloc] init];
    [_listViewModel addSectionPlaceHolder:holder];
    self.areaItemSectionCellPlaceHolder = [[FHAreaItemSectionPlaceHolder alloc] init];
    [_listViewModel addSectionPlaceHolder:_areaItemSectionCellPlaceHolder];
    [self.tableView reloadData];
}

@end
