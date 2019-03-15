//
//  FHBaseMainListViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHBaseMainListViewController.h"
#import "FHMainListTopView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHHouseBase/FHHouseType.h>
#import "FHBaseMainListViewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import "FHHouseListRedirectTipView.h"

#define TOP_HOR_PADDING 3

@interface FHBaseMainListViewController ()

@property(nonatomic , strong) FHFakeInputNavbar *navbar;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UIView *topContainerView;
@property(nonatomic , strong) FHMainListTopView *topView;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) FHHouseListRedirectTipView *redirectTipView;
@property(nonatomic , strong) FHBaseMainListViewModel *viewModel;
@property(nonatomic , strong) FHErrorView *errorView;
@property (nonatomic , strong) TTRouteParamObj *paramObj;

@end

@implementation FHBaseMainListViewController


-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {        
        self.paramObj = paramObj;
        
        _houseType = FHHouseTypeSecondHandHouse;
        if (paramObj.allParams[@"house_type"]) {
            _houseType = [paramObj.allParams[@"house_type"] intValue];
        }else{
            NSString *host = paramObj.sourceURL.host;
            if ([host hasPrefix:@"rent"]) {
                _houseType = FHHouseTypeRentHouse;
            }
        }
    }
    return self;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            UIEdgeInsets inset = UIEdgeInsetsZero;
            inset.bottom = [[UIApplication sharedApplication]delegate].window.safeAreaInsets.bottom;
            _tableView.contentInset = inset;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.scrollsToTop = YES;
    }
    return _tableView;
}


-(void)initNavbar
{
    FHFakeInputNavbarType type = (_houseType == FHHouseTypeSecondHandHouse ? FHFakeInputNavbarTypeMap : FHFakeInputNavbarTypeDefault);
    _navbar = [[FHFakeInputNavbar alloc] initWithType:type];
    _navbar.placeHolder = @"你想住哪里？";
    __weak typeof(self) wself = self;
    _navbar.defaultBackAction = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    _navbar.showMapAction = ^{
        [wself.viewModel showMapSearch];
    };
    
    _navbar.tapInputBar = ^{
        [wself.viewModel showInputSearch];
    };
    
    [self.view addSubview:_navbar];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavbar];
    _topContainerView = [[UIView alloc]init];
    _topContainerView.clipsToBounds = YES;
    _containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    [self.view addSubview:_topContainerView];
    
    _viewModel = [[FHBaseMainListViewModel alloc] initWithTableView:self.tableView houseType:_houseType routeParam:self.paramObj];
    
    _topView = [[FHMainListTopView alloc] initWithBannerView:self.viewModel.topBannerView filterView:self.viewModel.filterPanel];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = CGRectGetHeight(_topView.bounds);
    self.tableView.contentInset = insets;
    _topView.top = -_topView.height;
    [self.tableView addSubview:_topView];
    
    [self.containerView addSubview:self.tableView];
    
    self.redirectTipView = [[FHHouseListRedirectTipView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    [self.containerView addSubview:_redirectTipView];
    
    _viewModel.viewController = self;
    _viewModel.navbar = self.navbar;
    _errorView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorView];
    _viewModel.errorMaskView = _errorView;
    _errorView.hidden = YES;
    _viewModel.topContainerView = _topContainerView;
    _viewModel.topView = self.topView;
    
    [self.containerView addSubview:self.viewModel.filterBgControl];
    self.viewModel.filterBgControl.hidden = YES;
    
    [self.view bringSubviewToFront:_navbar];
    
    [self initConstraints];
    
    [self.viewModel requestData:YES];
    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
}

-(void)initConstraints
{
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.navbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navbar.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navbar.mas_bottom);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
    [self.viewModel.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.viewModel.filterPanel.height);
    }];
    
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.viewModel.filterPanel.mas_bottom);
    }];
    
    [self.redirectTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
