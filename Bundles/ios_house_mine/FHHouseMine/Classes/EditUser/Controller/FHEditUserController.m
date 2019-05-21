//
//  FHEditUserController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import "FHEditUserController.h"
#import "FHEditUserViewModel.h"

@interface FHEditUserController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHEditUserViewModel *viewModel;

@end

@implementation FHEditUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self loadData];
    
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"我的个人信息";
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
    self.viewModel = [[FHEditUserViewModel alloc] initWithTableView:_tableView controller:self];
}

- (void)loadData {
    // initialize loadData
    [self.viewModel reloadViewModel];
    [self.viewModel loadRequest];
}

@end
