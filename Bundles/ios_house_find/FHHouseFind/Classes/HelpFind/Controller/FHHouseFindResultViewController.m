//
//  FHHouseFindResultViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindResultViewController.h"
#import "FHHouseFindResultViewModel.h"
#import <FHErrorView.h>
#import "FHHouseFindRecommendModel.h"

@interface FHHouseFindResultViewController () <TTRouteInitializeProtocol>

@property (nonatomic , strong) FHHouseFindResultViewModel *viewModel;
@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIView *bottomView;
@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindRecommendModel *recommendModel;

@end

@implementation FHHouseFindResultViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
        NSDictionary *recommendDict = @{ @"bottom_open_url": @"sslocal://house_list?",
            @"district_title": @"浦口/玄武/建邺",
            @"find_house_number": @(2977),
            @"open_url": @"sslocal://house_list?",
            @"price_title": @"400000000-500000000万",
            @"room_num_title": @"2室/3室",
            @"used": @(YES) };
        _recommendModel = [[FHHouseFindRecommendModel alloc] initWithDictionary:recommendDict error:nil];
        
        
//     NSDictionary *recommendDict = paramObj.allParams[@"recommend_house"];
    }
    return self;
}

-(void)setupUI {
    [self initNavbar];

    _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_containerView];
    self.customNavBarView.title.text = @"帮我找房";
   
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    //    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.right.mas_equalTo(self.view);
    //        make.height.mas_equalTo(60);
    //        make.bottom.mas_equalTo(self.view).offset(-bottomHeight);
    //    }];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.mas_equalTo(- bottomHeight);
    }];
    
    [_containerView setBackgroundColor:[UIColor redColor]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
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
    
    self.tableView.sectionFooterHeight = 0;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.1)]; //to do:设置header0.1，防止系统自动设置高度
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.1)]; //to do:设置header0.1，防止系统自动设置高度
  
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;

    [_containerView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView);
        make.bottom.mas_equalTo(bottomHeight != 0 ? -bottomHeight - 16 : -70);
    }];
    
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    
    
    self.bottomView = [UIView new];
    [_containerView addSubview:self.bottomView];
    [self.bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.containerView);
        make.height.mas_equalTo(bottomHeight != 0 ? bottomHeight + 16 : 70);
        make.bottom.equalTo(self.containerView).offset(0);
    }];
    
    
    UIButton *buttonOpenMore = [UIButton new];
    [buttonOpenMore setTitle:@"查看其他房源" forState:UIControlStateNormal];
    [buttonOpenMore setBackgroundColor:[UIColor themeGray7]];
    [buttonOpenMore setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [buttonOpenMore.titleLabel setFont:[UIFont themeFontRegular:14]];
    
    [self.bottomView addSubview:buttonOpenMore];
    [buttonOpenMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(40);
    }];
    

    //error view
    self.errorMaskView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"查房价";
    [self setNavBar:NO];
    [self.customNavBarView setNaviBarTransparent:YES];
}

- (void)setNavBar:(BOOL)error {
    if(error){
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    }else{
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}


- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat alpha = contentOffset.y / 15;
    if(alpha > 1){
        alpha = 1;
    }
    if (alpha > 0) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    }else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
    }
    [self.customNavBarView refreshAlpha:alpha];
    
    if (contentOffset.y > 0) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    }else {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    _viewModel = [[FHHouseFindResultViewModel alloc] initWithTableView:self.tableView routeParam:_paramObj];
    // Do any additional setup after loading the view.
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshContentOffset:scrollView.contentOffset];
}



@end
