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



@interface FHAccountBindingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHAccountBindingViewModel *viewModel;
@end

@implementation FHAccountBindingViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    [self setupUI];
    
}

- (void)setupUI{
    
    [self initNavbar];
    [self configTableView];
    [self initConstraints];
    [self initViewModel];
    
}
- (void) configTableView{
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewScrollPositionNone;
    _tableView.backgroundColor = [UIColor themeGray8];
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    [self.view addSubview:_tableView];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}
- (void)initViewModel {
    self.viewModel = [[FHAccountBindingViewModel alloc] initWithTableView:_tableView controller:self];
    [self.viewModel initData];
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

-(void)initNavbar{
    [self setTitle:@"账号和绑定设置"];
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"ic-arrow-left-line"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"ic-arrow-left-line"] forState:UIControlStateHighlighted];
    self.customNavBarView.seperatorLine.hidden = YES;
}

- (void)dealloc{
    NSLog(@"FHAccountBindingViewController");
}

- (void)reload{
//    if (!_sections) {
//        _sections = [NSMutableArray array];
//        [self.sections removeAllObjects];
//        if (isEmptyString([TTAccountManager currentUser].mobile)) {
//            [self.sections addObjectsFromArray:@[@(kFHCellTypeBindingPhone)]];
//        } else {
//
//        }
//    }
}
@end
