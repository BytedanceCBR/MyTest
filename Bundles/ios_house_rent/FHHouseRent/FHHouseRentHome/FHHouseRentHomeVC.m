//
//  FHHouseRentHomeVC.m
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHHouseRentHomeVC.h"
#import <Masonry/Masonry.h>
#import "FHFakeInputNavbar.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHSpringboardView.h"
#import "FHHouseRentMainViewModel.h"
#import "FHHouseRentCell.h"
#import <TTRoute.h>
#import <FHConfigModel.h>
#import <UIImageView+WebCache.h>
#import "FHErrorMaskView.h"
#import "FHRentArticleListNotifyBarView.h"
#import "UIColor+Theme.h"
#import "FHHouseRentAnimateView.h"
#import "UIViewAdditions.h"
#import "FHTracerModel.h"
#import <UIViewController+NavigationBarStyle.h>
#import "UIViewController+Track.h"
#import "FHConditionFilterViewModel.h"

#define kFilterBarHeight 44
#define MAX_ICON_COUNT 4
#define HOR_MARGIN     20


@interface FHHouseRentHomeVC ()<TTRouteInitializeProtocol>

@property (nonatomic , strong) FHFakeInputNavbar *navbar;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIScrollView *containerScrollView;
@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UIView *tableContainerView;
@property (nonatomic , strong) FHErrorMaskView *errorMaskView;
@property (nonatomic , strong) FHSpringboardView *iconsHeaderView;
@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;
@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@property (nonatomic , strong) FHHouseRentMainViewModel *viewModel;
@property (nonatomic , strong) FHConfigDataRentOpDataModel *rentModel;
@property (nonatomic , strong) TTRouteParamObj *paramObj;

@end

@implementation FHHouseRentHomeVC

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.paramObj = paramObj;
        self.tracerModel.categoryName = [self categoryName];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

-(NSString *)categoryName
{
    return @"renting";
}

-(void)initNavbar
{
    _navbar = [[FHFakeInputNavbar alloc] initWithType:FHFakeInputNavbarTypeDefault];
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

-(void)initFilterView
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:FHHouseTypeRentHouse showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    
    _viewModel = [[FHHouseRentMainViewModel alloc]initWithViewController:self tableView:self.tableView routeParam:self.paramObj];
    __weak typeof(self) wself = self;
//    _viewModel.resetConditionBlock = ^(NSDictionary *condition){
//        [wself.houseFilterBridge resetFilter:wself.houseFilterViewModel withQueryParams:condition updateFilterOnly:YES];
//    };
    
    _viewModel.conditionNoneFilterBlock = ^NSString * _Nullable(NSDictionary * _Nonnull params) {
        return [wself.houseFilterBridge getNoneFilterQueryParams:params];
    };

    _viewModel.closeConditionFilter = ^{
        [wself.houseFilterBridge closeConditionFilterPanel];
    };
    
    _viewModel.clearSortCondition = ^{
        [wself.houseFilterBridge clearSortCondition];
    };
    
    _viewModel.getConditions = ^NSString * _Nonnull{
        return [wself.houseFilterBridge getConditions];
    };
    
    _viewModel.showNotify = ^(NSString * _Nonnull message) {
        [wself showNotify:message];
    };
    _viewModel.getSortTypeString = ^NSString * _Nullable {
        if ([wself.houseFilterViewModel isLastSearchBySort]) {
            return [wself.houseFilterViewModel sortType] ? : @"default";
        }
        return nil;
    };
    
//    _viewModel.overwriteFilter = ^(NSString * _Nonnull houseListUrl) {
//        
//    };
    
    [bridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
    _filterBgControl.hidden = YES;
    
    [bridge resetFilter:self.houseFilterViewModel withQueryParams:nil updateFilterOnly:NO];
    [bridge showBottomLine:NO];
    
    _filterContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kFilterBarHeight)];
    [_filterContainerView addSubview:_filterPanel];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [_filterContainerView addSubview:bottomLine];
    
    [_filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.filterContainerView);
        make.height.mas_equalTo(kFilterBarHeight);
    }];
    
    [bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(bottomLine.superview).offset(HOR_MARGIN);
        make.right.mas_equalTo(bottomLine.superview).offset(-HOR_MARGIN);
        make.bottom.mas_equalTo(self.filterPanel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}

-(void)initTableView
{
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    CGRect frame = self.view.bounds;
    frame.size.height = self.view.height - height - kFilterBarHeight;
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.scrollsToTop = YES;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UIEdgeInsets inset = UIEdgeInsetsZero;
        inset.bottom = [[UIApplication sharedApplication]keyWindow].safeAreaInsets.bottom;
        _tableView.contentInset = inset;
        
        _containerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
}

-(void)initContainer
{
    _containerView = [[UIView alloc] initWithFrame:self.tableView.frame];
    _tableContainerView = [[UIView alloc]initWithFrame:_containerView.bounds];
    [_tableContainerView addSubview:self.tableView];
    [_containerView addSubview:_tableContainerView];
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, 32)];
    [_containerView addSubview:self.notifyBarView];
    
    _containerScrollView = [[UIScrollView alloc]init];
    _containerScrollView.backgroundColor = [UIColor whiteColor];
    _containerScrollView.scrollsToTop = NO;
    
    if (@available(iOS 11.0 , *)) {
        _containerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [_containerScrollView addSubview:_viewModel.iconHeaderView];
    self.filterContainerView.top = _viewModel.iconHeaderView.height;
    [_containerScrollView addSubview:self.filterContainerView];
    _containerView.top = self.filterContainerView.bottom;
    [_containerScrollView addSubview:_containerView];
    _containerScrollView.contentSize = CGSizeMake(self.view.width, _containerView.bottom);
    
    [_containerScrollView bringSubviewToFront:self.filterContainerView];
    
    self.errorMaskView = [[FHErrorMaskView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.viewModel.errorMaskView = _errorMaskView;
    [_errorMaskView showRetry:NO];
    
    [_containerView addSubview:_filterBgControl];
    
}

-(void)initConstraints
{
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.navbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
    
    [self.containerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navbar.mas_bottom);
    }];
    
    [self.errorMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.notifyBarView.superview);
        make.height.mas_equalTo(32);
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initTableView];
    [self initFilterView];
    [self initContainer];
    
    [self.view addSubview:_containerScrollView];
    self.viewModel.notifyBarView = self.notifyBarView;
    self.viewModel.containerScrollView = _containerScrollView;
    
    [self.view bringSubviewToFront:self.navbar];

    [self initConstraints];

    [self.viewModel requestData:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.viewModel viewWillAppear];
    
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisapper];
    
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)showNotify:(NSString *)message
{
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];

    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = self.notifyBarView.height;
    self.tableView.contentInset = insets;

    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{            
            if (!wself) {
                return ;
            }
            UIEdgeInsets toinsets = wself.tableView.contentInset;
            toinsets.top = 0;
            wself.tableView.contentInset = toinsets;
        }];
    });
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - for filter keyboard show
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
