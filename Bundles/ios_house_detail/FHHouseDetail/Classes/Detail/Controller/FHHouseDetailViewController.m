//
//  FHHouseDetailViewController.m
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"

@interface FHHouseDetailViewController ()

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *bottomStatusBar;
@property (nonatomic, strong) FHDetailBottomBarView *bottomBar;

@property (nonatomic, strong)   FHHouseDetailBaseViewModel       *viewModel;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property (nonatomic, copy)   NSString* houseId; // 房源id

@end

@implementation FHHouseDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        self.houseId = paramObj.allParams[@"house_id"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

// 重新加载
- (void)retryLoadData {
    [self startLoadData];
}

- (void)setupUI {
    [self configTableView];
    self.viewModel = [FHHouseDetailBaseViewModel createDetailViewModelWithHouseType:self.houseType withController:self tableView:_tableView];
    self.viewModel.houseId = self.houseId;
    [self.view addSubview:_tableView];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _navBar = [[FHDetailNavBar alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width, navBarHeight + 44)];
    [self.view addSubview:_navBar];
    
    _bottomBar = [[FHDetailBottomBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_bottomBar];

    [self addDefaultEmptyViewFullScreen];

    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];

}

- (void)refreshContentOffset:(CGPoint)contentOffset
{
    CGFloat alpha = contentOffset.y / 139 * 2;
    [self.navBar refreshAlpha:alpha];

    if (contentOffset.y > 0) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    }else {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
}

@end
