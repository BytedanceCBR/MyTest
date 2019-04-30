//
//  FHHouseFindResultViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindResultViewController.h"
#import "FHHouseFindResultViewModel.h"
#import <FHErrorView.h>
#import <UIViewController+Track.h>

@interface FHHouseFindResultViewController () <TTRouteInitializeProtocol>

@property (nonatomic , strong) FHHouseFindResultViewModel *viewModel;
@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIButton *rightBtn;
@property (nonatomic, assign)   BOOL     isViewDidDisapper;

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;

@end

@implementation FHHouseFindResultViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
        NSDictionary *recommendHouseParam = paramObj.allParams[@"recommend_house"];
        
        if (recommendHouseParam && [recommendHouseParam isKindOfClass:[NSDictionary class]]) {
           self.recommendModel = [[FHHouseFindRecommendDataModel alloc] initWithDictionary:recommendHouseParam error:nil];
        }
        
        self.ttTrackStayEnable = YES;
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewDidDisapper = NO;
    [self refreshContentOffset:self.tableView.contentOffset];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewDidDisapper = YES;
}

-(void)setupUI {
    [self initNavbar];

    _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_containerView];
    self.isViewDidDisapper = NO;
    
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }

    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.mas_equalTo(- bottomHeight);
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 7.0, *)) {
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedRowHeight = 0;
    } else {
        // Fallback on earlier versions
    }

    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.001)]; //to do:设置header0.1，防止系统自动设置高度
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.001)]; //to do:设置header0.1，防止系统自动设置高度
  
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;

    [_containerView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView);
        make.bottom.mas_equalTo(0);
    }];
    
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    
    
    //error view
    self.errorMaskView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;
    
    [self startLoading];
}


- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self setNavBar:NO];
    [self.customNavBarView setNaviBarTransparent:YES];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateHighlighted];
    [_rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:_rightBtn];
    
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.bottom.mas_equalTo(-10);
        make.right.equalTo(self.customNavBarView).offset(-20);
    }];
}

- (void)rightBtnClick
{
    if ([self.parentViewController respondsToSelector:@selector(jump2HouseFindHelpVC)]) {
        [self.parentViewController performSelector:@selector(jump2HouseFindHelpVC)];
    }
}

- (void)setNaviBarTitle:(NSString *)stringTitle
{
    self.customNavBarView.title.text = stringTitle;
}

- (FHHouseFindRecommendDataModel *)getRecommendModel
{
    return self.viewModel.recommendModel;
}

- (void)refreshRecommendModel:(FHHouseFindRecommendDataModel *)recommendModel
{
    self.viewModel.recommendModel = recommendModel;
}

- (void)setNavBar:(BOOL)error {
    if(error){
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_black"] forState:UIControlStateNormal];
        [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_black"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    }else{
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateNormal];
        [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}


- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat alpha = contentOffset.y / 15;
    if(alpha > 1){
        alpha = 1;
    }
    if (alpha > 0) {
        if (alpha > 0.98) {
            self.customNavBarView.title.hidden = NO;
        }
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_black"] forState:UIControlStateNormal];

    }else {
        self.customNavBarView.title.hidden = YES;
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [_rightBtn setImage:[UIImage imageNamed:@"house_find_help_right_btn_white"] forState:UIControlStateNormal];
    }
    [self.customNavBarView refreshAlpha:alpha];
    if (!self.isViewDidDisapper) {
        
        if (contentOffset.y > 0) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        }else {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    _viewModel = [[FHHouseFindResultViewModel alloc] initWithTableView:self.tableView viewController:self routeParam:_paramObj];
    // Do any additional setup after loading the view.
}

- (void)endEditing:(BOOL)isHideKeyBoard {
    
}

@end