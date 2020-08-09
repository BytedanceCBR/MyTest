//
//  FHHouseAgencyListViewController.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/5.
//

#import "FHHouseAgencyListViewController.h"
#import "FHHouseAgencyListViewModel.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHHouseAgencyListViewController ()

@property (nonatomic, strong) FHHouseAgencyListViewModel      *viewModel;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *confirmBtn;
@property(nonatomic, strong) TTRouteParamObj *paramObj;

@end

@implementation FHHouseAgencyListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)setupUI
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"选择服务方";
    [self setupTableView];
    self.viewModel = [[FHHouseAgencyListViewModel alloc]initWithTableView:_tableView paramObj:_paramObj];
    self.viewModel.viewController = self;
    UIView *bottomBar = [[UIView alloc]init];
    bottomBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBar];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(bottomBar.mas_top);
    }];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
    [bottomBar addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(44);
    }];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)confirmBtnDidClick:(UIButton *)btn
{
    [self.viewModel confirmAction];
}

- (void)setupTableView
{
//    CGFloat height = [FHFakeInputNavbar perferredHeight];
    UITableView *tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor themeGray7];
    _tableView = tableView;
}

- (UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc]init];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _confirmBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateHighlighted];
        _confirmBtn.layer.cornerRadius = 22; //4;
        _confirmBtn.backgroundColor = [UIColor themeOrange4];
    }
    return _confirmBtn;
}

@end
