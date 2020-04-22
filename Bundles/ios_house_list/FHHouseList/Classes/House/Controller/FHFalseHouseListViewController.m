//
//  FHFalseHouseListViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/30.
//

#import "FHFalseHouseListViewController.h"
#import "FHFalseHouseListViewModel.h"
#import "FHErrorView.h"
#import "UIViewController+Track.h"
#import "UIViewAdditions.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHFalseHouseListViewController () <TTRouteInitializeProtocol>

@property (nonatomic , strong) FHFalseHouseListViewModel *viewModel;
@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIButton *rightBtn;
@property (nonatomic, assign)   BOOL     isViewDidDisapper;

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) NSString *searchIdStr;

@end

@implementation FHFalseHouseListViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
        NSDictionary *recommendHouseParam = paramObj.allParams[@"searchId"];
        _searchIdStr = paramObj.allParams[@"searchId"];
        
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

- (void)addDefaultEmptyViewFullScreen
{
    self.emptyView = [[FHErrorView alloc] init];
    self.emptyView.hidden = YES;
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    __weak typeof(self) wself = self;
    self.emptyView.retryBlock = ^{
       
    };
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
        if (@available(iOS 13.0 , *)) {
            make.top.mas_equalTo(44.f + [UIApplication sharedApplication].keyWindow.safeAreaInsets.top);
        } else if (@available(iOS 11.0 , *)) {
            make.top.mas_equalTo(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            make.top.mas_equalTo(65);
        }
        make.bottom.mas_equalTo(- bottomHeight);
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
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
    
    [self addDefaultEmptyViewFullScreen];
}


- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self setNavBar:NO];
    [self.customNavBarView setNaviBarTransparent:NO];
}

- (void)rightBtnClick
{
    
}

- (void)setNaviBarTitle:(NSString *)stringTitle
{
    self.customNavBarView.title.text = stringTitle;
}


- (void)setNavBar:(BOOL)error {
}


- (void)refreshContentOffset:(CGPoint)contentOffset {
 
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
    _viewModel = [[FHFalseHouseListViewModel alloc] initWithTableView:self.tableView viewController:self routeParam:_paramObj];
    // Do any additional setup after loading the view.
}

- (void)endEditing:(BOOL)isHideKeyBoard {
    
}

@end
