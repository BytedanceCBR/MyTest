//
//  FHMapAreaHouseListViewController.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import "FHMapAreaHouseListViewController.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHHouseBase/FHHouseFilterBridge.h>
#import <TTUIWidget/UIViewController+Track.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <Masonry/Masonry.h>
#import "FHMapAreaHouseListViewModel.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import <TTBaseLib/UIViewAdditions.h>

@interface FHMapAreaHouseListViewController ()

@property (nonatomic , strong) NSDictionary *userInfo;
@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) FHMapAreaHouseListViewModel *viewModel;

// 过滤器filter
@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) id houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) UIView *topSplitView;
@property (nonatomic , strong) UIView *topSplitLine;

@end

@implementation FHMapAreaHouseListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        self.ttTrackStayEnable = YES;
        self.userInfo = paramObj.allParams;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    [self setupUI];
//    [self setupData];
    
    [self.viewModel loadData];
    
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
    [self setupDefaultNavBar:YES];
    self.ttNeedHideBottomLine = YES;
    
    CGFloat height = 0;
    
    _topSplitView = [[UIView alloc] initWithFrame:CGRectZero];
    _topSplitLine = [[UIView alloc]initWithFrame:CGRectZero];
    _topSplitLine.backgroundColor = [UIColor themeGray5];
    _topSplitLine.layer.cornerRadius = 1.5;
    _topSplitLine.layer.masksToBounds = YES;
    
    [_topSplitView addSubview:_topSplitLine];
    [self.view addSubview:_topSplitView];
    
    [self.topSplitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    [self.topSplitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 3));
        make.center.mas_equalTo(self.topSplitView);
    }];
    
    [self configTableView];
    self.viewModel = [[FHMapAreaHouseListViewModel alloc] initWithWithController:self tableView:_tableView userInfo:self.userInfo];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topSplitView.mas_bottom);
    }];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsZero];
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}


- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        insets = [[[[UIApplication sharedApplication]delegate] window] safeAreaInsets];
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, insets.bottom, 0);
}

//- (void)setupData {
//
//    self.viewModel.houseFilterBridge = self.houseFilterBridge;
//    self.viewModel.houseFilterViewModel = self.houseFilterViewModel;
//    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
//}


- (void)retryLoadData {
    [self.viewModel loadData];
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


NSString *const COORDINATE_ENCLOSURE = @"coordinate_enclosure";
NSString *const NEIGHBORHOOD_IDS = @"neighborhood_id[]";
