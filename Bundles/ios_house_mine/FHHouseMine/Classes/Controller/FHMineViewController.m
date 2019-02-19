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

@interface FHMineViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHMineViewModel *viewModel;
@property (nonatomic, strong) NSDate *enterDate;
@property (nonatomic, assign) NSTimeInterval lastRequestFavoriteTime;

@end

@implementation FHMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttTrackStayEnable = YES;
    
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self setupHeaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)initNavbar {
    self.ttHideNavigationBar = YES;
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    [self.view addSubview:_tableView];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)initConstraints {
    CGFloat bottom = 49;
    CGFloat top = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        top = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(top);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHMineViewModel alloc] initWithTableView:_tableView controller:self];
}

- (void)setupHeaderView {
    FHMineHeaderView *headerView = [[FHMineHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 141)];
    headerView.userInteractionEnabled = YES;
    _tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo)];
    [headerView addGestureRecognizer:gesture];
}

- (void)loadData {
    [self.viewModel updateHeaderView];
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - self.lastRequestFavoriteTime;
    if(currentTime > 2){
        [self.viewModel requestData];
        self.lastRequestFavoriteTime = currentTime;
    }
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

@end
