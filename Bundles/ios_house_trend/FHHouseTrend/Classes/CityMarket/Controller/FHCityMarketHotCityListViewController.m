//
//  FHCityMarketHotCityListViewController.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/27.
//

#import "FHCityMarketHotCityListViewController.h"
#import "FHCityMarketDetailResponseModel.h"
#import "FHDetailListViewModel.h"
#import "FHAreaItemListSectionPlaceHolder.h"
#import "TTDeviceHelper.h"
#import "FHCityMarketBottomBarView.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHCityMarketHotCityListViewController ()
@property (nonatomic, strong) FHCityMarketDetailResponseDataHotListModel* model;
@property (nonatomic, strong) FHDetailListViewModel* listViewModel;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) FHAreaItemListSectionPlaceHolder* areaItemSectionCellPlaceHolder;
@property (nonatomic, strong) FHCityMarketBottomBarView* bottomBarView;

@end

@implementation FHCityMarketHotCityListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.model = [paramObj allParams][@"model"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    // Do any additional setup after loading the view.
    [self initNavBar];
    [self setupBottomBar];
    self.tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _listViewModel = [[FHDetailListViewModel alloc] init];
    _listViewModel.tableView = _tableView;
    _tableView.delegate = _listViewModel;
    _tableView.dataSource = _listViewModel;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    if (@available(iOS 11.0, *)) {
        [_tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    }
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 84 : 64;

    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
//        make.bottom.mas_equalTo(self.bottomBarView.mas_top);
        make.top.mas_equalTo(self.view).mas_offset(navBarHeight);
    }];

    [self.view bringSubviewToFront:_bottomBarView];
    // 这里设置tableView底部滚动的区域，保证内容可以完全露出
    CGFloat bottomBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 98 : 64;

    _tableView.contentInset = UIEdgeInsetsMake(0, 0, bottomBarHeight, 0);

    [self setupSections];
    [self traceEnterCategory];
}

-(void)traceEnterCategory {
    NSMutableDictionary* dict = [self.tracerDict mutableCopy];
    dict[@"category_name"] = @"neighborhood_trade_list";
    [FHUserTracker writeEvent:@"enter_category" params:dict];
}

-(void)initNavBar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView cleanStyle:YES];
    self.customNavBarView.backgroundColor = [UIColor whiteColor];
}


-(void)setupSections {
    self.areaItemSectionCellPlaceHolder = [[FHAreaItemListSectionPlaceHolder alloc] init];
    [_listViewModel addSectionPlaceHolder:_areaItemSectionCellPlaceHolder];
    _areaItemSectionCellPlaceHolder.tracer = self.tracerDict;
    _areaItemSectionCellPlaceHolder.hotList = @[_model];
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
    item.titleLabel.text = self.model.bottomText;
    item.backgroundColor = [UIColor themeOrange4];//[UIColor colorWithHexString:@"ff5869"];
    [item addTarget:self action:@selector(jumpTo) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBarView setBottomBarItems:@[item]];

}

-(void)jumpTo {
    if (self.model.moreOpenUrl == nil || [self.model.moreOpenUrl length] == 0) {
        return;
    }
    NSURL* theUrl = [[NSURL alloc] initWithString:self.model.moreOpenUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:theUrl];
}

@end
