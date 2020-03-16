//
//  FHMineViewController.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineViewController.h"
#import <Masonry/Masonry.h>
#import "TTNavigationController.h"
#import "TTRoute.h"
#import "FHMineViewModel.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import "UIViewController+Track.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTReachability.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "UIViewController+Track.h"
#import "TTTabBarItem.h"
#import "TTTabBarManager.h"
#import <FHPopupViewCenter/FHPopupViewManager.h>

@interface FHMineViewController ()<UIViewControllerErrorHandler>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHMineViewModel *viewModel;
@property (nonatomic, strong) NSDate *enterDate;
@property (nonatomic, assign) NSTimeInterval lastRequestFavoriteTime;
@property (nonatomic, assign) NSTimeInterval lastRequestConfigTime;
@property (nonatomic, strong) UIButton *phoneBtn;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGFloat naviBarHeight;
@end

@implementation FHMineViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [TTAccount addMulticastDelegate:self];

    }

    return self;
}

- (void)dealloc {
    [TTAccount removeMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self checkMineTabName];
}

- (void)checkMineTabName {
    //登录或未登录切换tab的名称
    TTTabBarItem *tabItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMineTabKey];
    if([TTAccount sharedAccount].isLogin){
        [tabItem setTitle:@"我的"];
    } else {
        [tabItem setTitle:@"未登录"];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttTrackStayEnable = YES;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self setupHeaderView];
    [self initSignal];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel updateHeaderView];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshContentOffset:self.tableView.contentOffset];
    [[FHPopupViewManager shared] triggerPopupView];
    [[FHPopupViewManager shared] triggerPendant];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"我的";
    self.customNavBarView.title.textColor = [UIColor whiteColor];
    self.customNavBarView.title.alpha = 0;
    self.customNavBarView.seperatorLine.alpha = 0;
    self.customNavBarView.leftBtn.hidden = YES;
    self.customNavBarView.bgView.alpha = 0;
    self.customNavBarView.bgView.image = [UIImage imageNamed:@"fh_mine_header_bg"];
    
    self.settingBtn = [[UIButton alloc] init];
    [_settingBtn setBackgroundImage:[UIImage imageNamed:@"fh_mine_setting"] forState:UIControlStateNormal];
    _settingBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_settingBtn addTarget:self action:@selector(goToSystemSetting) forControlEvents:UIControlEventTouchUpInside];
    
    self.phoneBtn = [[UIButton alloc] init];
    [_phoneBtn setBackgroundImage:[UIImage imageNamed:@"fh_mine_phone"] forState:UIControlStateNormal];
    _phoneBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_phoneBtn addTarget:self action:@selector(callPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addRightViews:@[_settingBtn,_phoneBtn] viewsWidth:@[@24,@24] viewsHeight:@[@24,@24] viewsRightOffset:@[@20,@30]];
    
    [self.view layoutIfNeeded];
    self.naviBarHeight = CGRectGetMaxY(self.customNavBarView.frame);
}

- (void)initView {
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor themeGray7];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    _tableView.estimatedRowHeight = 124;
    [self.view addSubview:_tableView];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)initConstraints {
    CGFloat bottom = 49;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHMineViewModel alloc] initWithTableView:_tableView controller:self];
}

- (void)setupHeaderView {
    self.headerViewHeight = 74 + self.naviBarHeight;
    
    FHMineHeaderView *headerView = [[FHMineHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.headerViewHeight) naviBarHeight:self.naviBarHeight];
    headerView.userInteractionEnabled = YES;
    _tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo)];
    [headerView addGestureRecognizer:gesture];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(self.headerViewHeight - self.naviBarHeight, 0, 0, 0)];
}

- (void)initSignal {
    //config改变后需要重新刷新数据
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
//        if([FHEnvContext isSpringHangOpen] && self.springView){
//            [self.springView show:[FHEnvContext enterTabLogName]];
//        }
        [self startLoadData];
    }];
}

- (void)loadData {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - self.lastRequestFavoriteTime;
    if(currentTime > 2 && [TTReachability isNetworkConnected]){
        if([TTAccount sharedAccount].isLogin){
            [self.viewModel requestData];
            self.lastRequestFavoriteTime = currentTime;
        }else{
            [self.viewModel updateFocusTitles];
        }
    }
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - self.lastRequestConfigTime;
        if(currentTime > 2){
            [self.viewModel requestMineConfig];
            self.lastRequestConfigTime = currentTime;
        }

    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            self.tableView.bounces = NO;
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
    [self loadData];
}

- (void)showInfo {
    [self.viewModel showInfo];
}

-(NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"enter_type"] = @"click_tab";
    tracerDict[@"tab_name"] = @"mine";
    tracerDict[@"with_tips"] = @"0";
    
    return tracerDict;
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_tab", tracerDict);
}

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat begin = self.naviBarHeight;
    
    CGFloat alpha = (contentOffset.y - begin) / (self.headerViewHeight + 32 - self.naviBarHeight - begin);
    if(alpha < 0){
        alpha = 0;
    }
    
    if(alpha > 1){
        alpha = 1;
    }
    
    self.customNavBarView.title.alpha = alpha;
    [self.customNavBarView refreshAlpha:alpha];
}

- (void)goToSystemSetting {
    [self.viewModel goToSystemSetting];
}

- (void)callPhone {
    [self.viewModel callPhone];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return self.viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
}

- (void)trackStartedByAppWillEnterForground {

}

@end
