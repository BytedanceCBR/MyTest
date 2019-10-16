//
//  FHHomePageSettingController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHHomePageSettingController.h"
#import "FHHomePageSettingViewModel.h"

@interface FHHomePageSettingController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHHomePageSettingViewModel *viewModel;

@end

@implementation FHHomePageSettingController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"个人主页设置";
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    [self.view addSubview:_tableView];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHHomePageSettingViewModel alloc] initWithTableView:_tableView controller:self];
}

@end
