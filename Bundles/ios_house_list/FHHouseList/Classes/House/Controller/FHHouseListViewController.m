//
//  FHHouseListViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewController.h"
#import <TTRoute.h>
#import <Masonry.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHFakeInputNavbar.h"
#import <UIViewAdditions.h>
#import "ArticleListNotifyBarView.h"
#import "FHTracerModel.h"
#import "FHErrorMaskView.h"
#import "FHHouseListViewModel.h"

#import "TTDeviceHelper.h"
#import "NSDictionary+TTAdditions.h"
#import "FHConditionFilterViewModel.h"
#import "FHHouseListRedirectTipView.h"
#import "HMDTTMonitor.h"
#import "FHEnvContext.h"
#import "TTInstallIDManager.h"

#define kFilterBarHeight 44

@interface FHHouseListViewController ()<TTRouteInitializeProtocol, FHHouseListViewModelDelegate>

@property (nonatomic , strong) FHFakeInputNavbar *navbar;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UITableView* tableView;

@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) FHHouseListRedirectTipView *redirectTipView;

@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@property (nonatomic , strong) FHErrorView *errorMaskView;

@property (nonatomic , strong) FHHouseListViewModel *viewModel;

@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) TTRouteParamObj *paramObj;

@property (nonatomic , copy) NSString *associationalWord;// 联想词
@property (nonatomic , copy) NSString *suggestionParams; // sug
@property (nonatomic , copy) NSString *queryString;
@property (nonatomic , strong) NSDictionary *tracerDict; // 埋点

@end

@implementation FHHouseListViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        //init coordinate viewmodel according to viewmodel
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;
        if (self.houseType <= 0 || self.houseType > 4) {
            // 目前4种房源：1，2，3，4
            NSString *res = [NSString stringWithFormat:@"%ld",self.houseType];
            // device_id
            NSString *did = [[TTInstallIDManager sharedInstance] deviceID];
            if (did.length == 0) {
                did = @"null";
            }
            [[HMDTTMonitor defaultManager] hmdTrackService:@"house_list_house_type_error"
                                                    metric:nil
                                                  category:@{@"status":@(0),@"house_type":res}
                                                     extra:@{@"device_id":did}];
            self.houseType = FHHouseTypeSecondHandHouse;
        }
        self.tracerModel.categoryName = [self categoryName];
        self.tracerDict = [paramObj.userInfo.allInfo tt_dictionaryValueForKey:@"tracer"];
        NSDictionary *sugDict = [paramObj.userInfo.allInfo tt_dictionaryValueForKey:@"sugParams"];
//        self.associationalWord = [sugDict tt_stringValueForKey:@"associateWord"];
//        self.suggestionParams = [sugDict tt_stringValueForKey:@"sug"];
        
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

-(NSString *)categoryName
{
    return [self.viewModel categoryName];
}

-(NSString *)placeholderByHouseType:(FHHouseType)houseType {
    
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"请输入楼盘名/地址";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeNeighborhood:
            return @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeRentHouse:
            return @"请输入小区/商圈/地铁";
            break;
        default:
            return @"";
            break;
    }
}

-(void)initNavbar
{
    FHFakeInputNavbarType type = FHFakeInputNavbarTypeDefault;
    if (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeRentHouse) {
        type = FHFakeInputNavbarTypeMap;
    }
    _navbar = [[FHFakeInputNavbar alloc] initWithType:type];
    if (self.associationalWord.length > 0) {
        
        _navbar.placeHolder = self.associationalWord;
    }else {
        
        _navbar.placeHolder = [self placeholderByHouseType:self.houseType];
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

-(void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:self.houseType showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    
    [self.houseFilterViewModel setFilterConditions:self.paramObj.queryParams];
    
    self.viewModel.viewModelDelegate = self;
    [bridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
    
    [bridge showBottomLine:NO];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [self.filterPanel addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.filterPanel);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];


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
    _viewModel.sugSelectBlock = ^(TTRouteParamObj * _Nonnull paramObj) {
        
        [wself handleSugSelection:paramObj];
    };
    _viewModel.houseListOpenUrlUpdateBlock = ^(TTRouteParamObj * _Nonnull paramObj, BOOL isFromMap) {
        
        [wself handleListOpenUrlUpdate:paramObj];
        if (isFromMap) {
            [wself.houseFilterViewModel trigerConditionChanged];
        }
    };
    
    _viewModel.showNotify = ^(NSString * _Nonnull message) {
        //        [wself showNotify:message];
    };
    
}

-(void)resetFilter:(TTRouteParamObj *)paramObj {

    [_filterBgControl removeFromSuperview];
    [self.filterContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self initFilter];
    
    [self.view addSubview:self.filterBgControl];
    [self.filterContainerView addSubview:self.filterPanel];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.filterContainerView);
    }];
    

    self.viewModel.houseType = self.houseType;
    [self.houseFilterViewModel setFilterConditions:paramObj.queryParams];
    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];

    
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
-(void)handleSugSelection:(TTRouteParamObj *)paramObj {
    
    NSString *houseTypeStr = paramObj.allParams[@"house_type"];
    if (houseTypeStr.length > 0 && houseTypeStr.integerValue != self.houseType) {
        
        self.viewModel.isEnterCategory = YES;
        self.houseType = houseTypeStr.integerValue;
        [self resetFilter:paramObj];
        
    }
    
    [self handleListOpenUrlUpdate:paramObj];
    [self.houseFilterBridge trigerConditionChanged];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.houseFilterViewModel closeConditionFilterPanel];
}


-(void)initConstraints
{
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.navbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
    }];
    
    [self.errorMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navbar.mas_bottom);
    }];
    
    [self.filterContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.containerView);
        make.height.mas_equalTo(@44);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.filterContainerView);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.redirectTipView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
    
    [self.redirectTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;
    
    [self initNavbar];
    
    self.viewModel = [[FHHouseListViewModel alloc]initWithTableView:self.tableView routeParam:self.paramObj];
    self.viewModel.listVC = self;
    [self initFilter];
    [self setupViewModelBlock];

    [self setupUI];

    [self initConstraints];
    self.viewModel.maskView = self.errorMaskView;
    [self.viewModel setRedirectTipView:self.redirectTipView];
    
    [self.houseFilterViewModel trigerConditionChanged];

}

-(void)refreshNavBar:(FHHouseType)houseType placeholder:(NSString *)placeholder {
    
    if (houseType == FHHouseTypeRentHouse || houseType == FHHouseTypeSecondHandHouse) {
        
        [self.navbar refreshNavbarType:FHFakeInputNavbarTypeMap];
    }else {

        [self.navbar refreshNavbarType:FHFakeInputNavbarTypeDefault];
    }
    self.navbar.placeHolder = placeholder;
    self.associationalWord = placeholder;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

-(void)setupUI {
    
    _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_containerView];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [_containerView addSubview:self.tableView];
    
    //error view
    self.errorMaskView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;

    //notifyview
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
    
    self.redirectTipView = [[FHHouseListRedirectTipView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.redirectTipView];

    [self.view addSubview:self.navbar];
    [self.view addSubview:self.filterBgControl];
    
    _filterContainerView = [[UIView alloc]init];
    [self.view addSubview:_filterContainerView];

    [_filterContainerView addSubview:self.filterPanel];
    [self.view bringSubviewToFront:self.filterBgControl];

}

#pragma mark - show notify

- (void)showNotify:(NSString *)message inViewModel:(FHBaseHouseListViewModel *)viewModel
{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            
//            UIEdgeInsets inset = self.tableView.contentInset;
//            inset.top = 0;
            self.tableView.contentInset = UIEdgeInsetsZero;
        }];
    });

}

-(void)showErrorMaskView
{

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
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
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
