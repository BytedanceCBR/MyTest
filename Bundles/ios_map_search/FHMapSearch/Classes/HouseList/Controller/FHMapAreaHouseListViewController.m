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
#import <TTPlatformUIModel/ArticleListNotifyBarView.h>
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
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

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
    
    [self setupFilter];
    
    [self setupUI];
    [self setupData];
    
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
    self.viewModel = [[FHMapAreaHouseListViewModel alloc] initWithWithController:self tableView:_tableView userInfo:self.userInfo];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.filterPanel.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, 32)];
    [self.view addSubview:self.notifyBarView];
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    _viewModel.notifyBarView = _notifyBarView;
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.view bringSubviewToFront:self.filterPanel];
    [self.view bringSubviewToFront:self.filterBgControl];
}

-(void)setupFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:self.houseType showAllCondition:NO showSort:NO];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = (UIControl *)[bridge filterBgView:self.houseFilterViewModel];
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
}

- (void)setupData {
    
    self.viewModel.houseFilterBridge = self.houseFilterBridge;
    self.viewModel.houseFilterViewModel = self.houseFilterViewModel;
    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
}


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
