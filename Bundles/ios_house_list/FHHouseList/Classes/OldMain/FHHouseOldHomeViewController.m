//
//  FHHouseOldHomeViewController.m
//  AKCommentPlugin
//
//  Created by 张静 on 2019/3/3.
//

#import "FHHouseOldHomeViewController.h"
#import <FHCommonUI/FHFakeInputNavbar.h>
#import "FHHouseListRedirectTipView.h"
#import <ios_house_filter/FHBConditionFilterViewModel.h>
#import <FHHouseBase/FHHouseFilterBridge.h>
#import <TTPlatformUIModel/ArticleListNotifyBarView.h>
#import "FHHouseListViewModel.h"
#import <TTUIWidget/UIViewController+Track.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <FHCommonUI/UIView+House.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import <FHHouseBase/FHEnvContext.h>
#import "FHHouseOldMainViewModel.h"
#import <TTBaseLib/TTDeviceHelper.h>

#define kFilterBarHeight 44

@interface FHHouseOldHomeViewController ()<TTRouteInitializeProtocol>

@property (nonatomic , strong) FHFakeInputNavbar *navbar;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UIScrollView *containerScrollView;
@property (nonatomic , strong) UITableView* tableView;
@property (nonatomic , strong) UIView *tableContainerView;

@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) FHHouseListRedirectTipView *redirectTipView;

@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@property (nonatomic , strong) FHErrorView *errorMaskView;

@property (nonatomic , strong) FHHouseOldMainViewModel *viewModel;

@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) TTRouteParamObj *paramObj;

@property (nonatomic , copy) NSString *associationalWord;// 联想词
@property (nonatomic , copy) NSString *suggestionParams; // sug
@property (nonatomic , copy) NSString *queryString;
@property (nonatomic , strong) NSDictionary *tracerDict; // 埋点

@end

@implementation FHHouseOldHomeViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        self.houseType = FHHouseTypeSecondHandHouse;
        NSMutableDictionary *queryParams = paramObj.queryParams.mutableCopy;
        queryParams[@"house_type"] = @"2";
        paramObj.queryParams = queryParams;
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        self.tracerModel.categoryName = [self categoryName];
        self.tracerDict = paramObj.userInfo.allInfo[@"tracer"];
        self.associationalWord = [self placeholderByHouseType:self.houseType];
        NSString *fullText = paramObj.queryParams[@"full_text"];
        NSString *displayText = paramObj.queryParams[@"display_text"];
        if (fullText.length > 0) {
            self.associationalWord = fullText;
        }else if (displayText.length > 0) {
            self.associationalWord = displayText;
        }
        self.ttTrackStayEnable = YES;
    }
    return self;
}

-(void)initNavbar
{
    FHFakeInputNavbarType type = FHFakeInputNavbarTypeMap;
    _navbar = [[FHFakeInputNavbar alloc] initWithType:type];
    if (self.associationalWord.length > 0) {
        
        _navbar.placeHolder = self.associationalWord;
    }else {
        
        _navbar.placeHolder = [self placeholderByHouseType:_houseType];
    }
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
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;
    
    [self initNavbar];
    
    self.viewModel = [[FHHouseOldMainViewModel alloc]initWithTableView:self.tableView routeParam:self.paramObj];
    self.viewModel.viewController = self;
    [self initFilter];
    [self setupViewModelBlock];
    
    [self setupUI];
    
    [self initConstraints];
    self.viewModel.maskView = self.errorMaskView;
    [self.viewModel setRedirectTipView:self.redirectTipView];
    self.viewModel.containerScrollView = _containerScrollView;

    [self.houseFilterViewModel trigerConditionChanged];
}

- (void)setupUI
{
    _containerView = [[UIView alloc] initWithFrame:self.tableView.frame];
    _tableContainerView = [[UIView alloc]initWithFrame:_containerView.bounds];
    [_tableContainerView addSubview:self.tableView];
    [_containerView addSubview:_tableContainerView];

    self.automaticallyAdjustsScrollViewInsets = NO;

    _containerScrollView = [[UIScrollView alloc]init];
    _containerScrollView.backgroundColor = [UIColor whiteColor];
    _containerScrollView.scrollsToTop = NO;
    [self.view addSubview:_containerScrollView];

    if (@available(iOS 11.0 , *)) {
        _containerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_containerScrollView addSubview:_viewModel.iconHeaderView];
    self.filterContainerView.top = _viewModel.iconHeaderView.bottom;
    [_containerScrollView addSubview:self.filterContainerView];
    _containerView.top = self.filterContainerView.bottom;
    [_containerScrollView addSubview:_containerView];
    _containerScrollView.contentSize = CGSizeMake(self.view.width, _containerView.bottom);
    
    [_filterContainerView addSubview:self.filterPanel];
    [_containerScrollView bringSubviewToFront:self.filterContainerView];
    
    //error view
    self.errorMaskView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;
    
    [_containerView addSubview:_filterBgControl];
    //notifyview
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.width, 32)];
    [_containerView addSubview:self.notifyBarView];
    
    self.redirectTipView = [[FHHouseListRedirectTipView alloc]initWithFrame:CGRectZero];
    [_containerView addSubview:self.redirectTipView];
    
    [self.view addSubview:self.navbar];
}


- (void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:self.houseType showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    
    [self.houseFilterViewModel setFilterConditions:self.paramObj.queryParams];
    
    [bridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
    
    [bridge showBottomLine:NO];
    
    _filterContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kFilterBarHeight)];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [self.filterPanel addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    self.viewModel.bottomLine = bottomLine;
    
}

-(void)setupViewModelBlock {
    
    __weak typeof(self) wself = self;
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
    _viewModel.setConditionsBlock = ^(NSDictionary * _Nonnull params) {
        
        [wself.houseFilterBridge setFilterConditions:params];
        [wself.houseFilterBridge trigerConditionChanged];
    };
    _viewModel.getAllQueryString = ^NSString * _Nonnull{
        
        return [wself.houseFilterBridge getAllQueryString];
    };
    _viewModel.getSortTypeString = ^NSString * _Nullable {
        if ([wself.houseFilterViewModel isLastSearchBySort]) {
            return [wself.houseFilterViewModel sortType] ? : @"default";
        }
        return nil;
    };
//    _viewModel.sugSelectBlock = ^(TTRouteParamObj * _Nonnull paramObj) {
//
//        [wself handleSugSelection:paramObj];
//    };
    _viewModel.houseListOpenUrlUpdateBlock = ^(TTRouteParamObj * _Nonnull paramObj, BOOL isFromMap) {
        
        [wself handleListOpenUrlUpdate:paramObj];
        if (isFromMap) {
            [wself.houseFilterViewModel trigerConditionChanged];
        }
    };

    _viewModel.showNotify = ^(NSString * _Nonnull message) {
        [wself showNotify:message];
    };
}

#pragma mark 处理sug带回的houseType，导航栏placeholder，筛选器
-(void)handleListOpenUrlUpdate:(TTRouteParamObj *)paramObj {
    
    NSString *placeholder = [self placeholderByHouseType:self.houseType];
    NSString *fullText = paramObj.queryParams[@"full_text"];
    NSString *displayText = paramObj.queryParams[@"display_text"];
    
    if (fullText.length > 0) {
        
        placeholder = fullText;
    }else if (displayText.length > 0) {
        
        placeholder = displayText;
    }
    [self refreshNavBar:self.houseType placeholder:placeholder];
    
    [self.houseFilterBridge setFilterConditions:paramObj.queryParams];
    
}

-(void)refreshNavBar:(FHHouseType)houseType placeholder:(NSString *)placeholder {
    
    [self.navbar refreshNavbarType:FHFakeInputNavbarTypeMap];
    self.navbar.placeHolder = placeholder;
    self.associationalWord = placeholder;
}

//-(void)handleSugSelection:(TTRouteParamObj *)paramObj {
//
//    NSString *houseTypeStr = paramObj.allParams[@"house_type"];
//    if (houseTypeStr.length > 0 && houseTypeStr.integerValue != self.houseType) {
//
//        self.viewModel.isEnterCategory = YES;
//        self.houseType = houseTypeStr.integerValue;
//        [self resetFilter:paramObj];
//
//    }
//
//    [self handleListOpenUrlUpdate:paramObj];
//    [self.houseFilterBridge trigerConditionChanged];
//
//}

-(NSString *)placeholderByHouseType:(FHHouseType)houseType
{
    return @"请输入小区/商圈/地铁";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


-(void)initConstraints
{
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.navbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    [self.containerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navbar.mas_bottom);
    }];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
    [self.errorMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(kFilterBarHeight);
    }];
    
    [self.redirectTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(32);
    }];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message
{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            
            UIEdgeInsets inset = self.tableView.contentInset;
            inset.top = 0;
            self.tableView.contentInset = inset;
        }];
    });
    
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

#pragma mark - lazy load

-(UITableView *)tableView {
    if (!_tableView) {
        
        CGFloat height = [FHFakeInputNavbar perferredHeight];
        CGRect frame = self.view.bounds;
        frame.size.height = self.view.height - height - kFilterBarHeight;
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        if (@available(iOS 11.0, *)) {
            
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ([TTDeviceHelper isIPhoneXDevice]) {
            
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
    }
    return _tableView;
}


@end
