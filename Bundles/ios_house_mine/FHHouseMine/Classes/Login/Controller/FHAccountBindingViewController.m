//
//  FHAccountBindingViewController.m
//  FHHouseMine
//
//  Created by luowentao on 2020/4/20.
//

#import "FHAccountBindingViewController.h"
#import "TTAccountManager.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHAccountBindingViewModel.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHAccountBindingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHAccountBindingViewModel *viewModel;
@end

@implementation FHAccountBindingViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNavbar];
    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewScrollPositionNone;
    self.tableView.backgroundColor = [UIColor themeGray8];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.viewModel = [[FHAccountBindingViewModel alloc] initWithTableView:self.tableView];
    [self.viewModel loadData];
}

-(void)setupNavbar {
    [self setTitle:@"账号和绑定设置"];
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]) forState:UIControlStateHighlighted];
    self.customNavBarView.seperatorLine.hidden = YES;
//    [self.customNavBarView cleanStyle:YES];
//    [self.customNavBarView setNaviBarTransparent:YES];
}
@end
