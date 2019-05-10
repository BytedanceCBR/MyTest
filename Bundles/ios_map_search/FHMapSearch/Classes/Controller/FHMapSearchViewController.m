//
//  FHMapSearchViewController.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHMapSearchViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "TTNetworkManager.h"
#import "FHMapSearchTypes.h"
#import "FHNeighborhoodAnnotationView.h"
#import "FHDistrictAreaAnnotationView.h"
#import "FHHouseAnnotation.h"
#import "FHMapSearchViewModel.h"
#import "FHMapSearchViewModel.h"
#import <Masonry/Masonry.h>
#import "FHMapSearchTipView.h"
#import <TTRoute/TTRouteDefine.h>
#import "UIFont+House.h"
#import "FHMapNavigationBar.h"
#import <UIViewAdditions.h>
#import <TTRoute.h>
#import "FHMainManager+Toast.h"
#import "UIColor+Theme.h"
#import <UIViewController+NavigationBarStyle.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHMapSearchOpenUrlDelegate.h"
#import "FHMapDrawMaskView.h"
#import "FHMapSearchWayChooseView.h"
#import <TTUIWidget/TTNavigationController.h>
#import "FHMapSearchBottomBar.h"

#define kTapDistrictZoomLevel  16
#define kFilterBarHeight 44

@interface FHMapSearchViewController ()<TTRouteInitializeProtocol>

@property(nonatomic , strong) FHMapNavigationBar *navBar;
@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , strong) FHMapSearchViewModel *viewModel;
@property(nonatomic , strong) UIView *filterPanel;
@property(nonatomic , strong) UIControl *filterBgControl;
@property(nonatomic , strong) id houseFilterViewModel;
@property(nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;
@property(nonatomic , strong) FHMapSearchTipView *tipView;
@property(nonatomic , strong) UIBarButtonItem *showHouseListBarItem;
@property(nonatomic , strong) UIBarButtonItem *showMapBarItem;
@property(nonatomic , strong) UILabel *navTitleLabel;
@property(nonatomic , strong) UIButton *locationButton;

@property(nonatomic , strong) FHMapDrawMaskView *drawMaskView;
@property(nonatomic , strong) FHMapSearchWayChooseView *chooseView;
@property(nonatomic , strong) FHMapSearchBottomBar *bottomBar;

@end

@implementation FHMapSearchViewController

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.configModel = configModel;
        [self setupConfigModel];
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    if (paramObj == nil) {
        return nil;
    }
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *param = nil;
        if (self.tracerDict) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.tracerDict];
            [dict addEntriesFromDictionary:paramObj.allParams];
            param = dict;
        }else{
            param = paramObj.allParams;
        }
        self.configModel = [[FHMapSearchConfigModel alloc] initWithDictionary:param error:nil];
        self.configModel.mapOpenUrl = [paramObj.sourceURL absoluteString];
        if (self.configModel.houseType < FHHouseTypeNewHouse) {
            NSString *host = paramObj.sourceURL.host;
            if ([host isEqualToString:@"mapfind_rent"]) {
                self.configModel.houseType = FHHouseTypeRentHouse;
            }else if([host isEqualToString:@"mapfind_house"]){
                self.configModel.houseType = FHHouseTypeSecondHandHouse;
            }
        }
        
        NSHashTable *hashTable =  (NSHashTable *) paramObj.userInfo.allInfo[OPENURL_CALLBAK];
        if ([hashTable isKindOfClass:[NSHashTable class]]) {
            id delegate = hashTable.anyObject;
            if (delegate) {
                self.openUrlDelegate = delegate;
            }
        }else{
//            self.openUrlDelegate = (id<FHMapSearchOpenUrlDelegate>) paramObj.userInfo.allInfo[OPENURL_CALLBAK];
        }

        [self setupConfigModel];
    }
    return self;
}

-(void)dealloc
{
    [self tryCallbackOpenUrl];
}

-(void)setupConfigModel
{
    if(_configModel.resizeLevel == 0){
        _configModel.resizeLevel = 11;
    }

    // 使用open url 不需要该逻辑
    BOOL locationEnabled = [CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||  [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    
    if(locationEnabled && [[FHMainManager sharedInstance] locationSameAsChooseCity]){
        //定位城市和选择城市是同一城市时 进入小区视野
//        _configModel.resizeLevel = 16;
        self.locationButton.hidden = NO;

//        CLLocationCoordinate2D location = [[FHMainManager sharedInstance] currentLocation];
//        if (location.latitude > 0 && location.longitude > 0) {
//            _configModel.centerLatitude = [@(location.latitude) description];
//            _configModel.centerLongitude = [@(location.longitude) description];
//        }
    }
}

-(FHMapSearchTipView *)tipView
{
    if (!_tipView) {
        _tipView = [[FHMapSearchTipView alloc]initWithFrame:CGRectZero];
    }
    return _tipView;
}

-(UIBarButtonItem *)showHouseListBarItem
{
    if (!_showHouseListBarItem) {
        UIImage *img = [UIImage imageNamed:@"mapsearch_nav_list"];
        _showHouseListBarItem= [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(showHouseList)];
    }
    return _showHouseListBarItem;
}

-(UIBarButtonItem *)showMapBarItem
{
    if (!_showMapBarItem) {
        UIImage *img =[UIImage imageNamed:@"navbar_showmap"];
        _showMapBarItem = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
    }
    return _showMapBarItem;
}

-(UIButton *)locationButton
{
    if (!_locationButton) {
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"mapsearch_location"];
        [_locationButton setImage:img forState:UIControlStateNormal];
        [_locationButton setImage:img forState:UIControlStateHighlighted];
        _locationButton.backgroundColor = [UIColor clearColor];
        [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
        _locationButton.hidden = YES;
    }
    return _locationButton;
}

-(void)backAction
{
    if (self.viewModel.showMode == FHMapSearchShowModeMap) {
        [self.navigationController popViewControllerAnimated:YES];
        [self tryCallbackOpenUrl];
    }else{
        [self.viewModel dismissHouseListView];
        [self.houseFilterBridge closeConditionFilterPanel];
    }
    
}

-(void)locationAction
{
    [self.viewModel moveToUserLocation];
}

-(void)showHouseList
{
    [self.houseFilterBridge closeConditionFilterPanel];
    [self.viewModel addNavSwitchHouseListLog];
    
    if ([self.configModel.enterFrom isEqualToString:@"city_market"]) {
        //从城市行情进入的 要先跳到二手房列表页 QA确认
        NSString *strUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld",self.configModel.houseType];
        NSString *houseListOpenUrl = [self.viewModel backHouseListOpenUrl];
        NSURL *openUrl = [NSURL URLWithString:houseListOpenUrl];
        if( [openUrl query].length > 0) {
            strUrl = [strUrl stringByAppendingFormat:@"&%@",[openUrl query]];
        }
        NSURL *url = [NSURL URLWithString:strUrl];
        NSMutableDictionary *traceInfo = [NSMutableDictionary new];
        [traceInfo addEntriesFromDictionary:[self.configModel toDictionary]];
        traceInfo[@"enter_from"] = @"mapfind";
        NSDictionary *info = @{@"tracer":traceInfo};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        
        [self.navigationController popViewControllerAnimated:NO];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMap
{
    [self.houseFilterBridge closeConditionFilterPanel];
    [self switchNavbarMode:FHMapSearchShowModeMap];
    [self.viewModel showMap];
}

-(void)initNavbar
{
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44);
    if (@available(iOS 11.0 , *)) {
        UIEdgeInsets insets = [[UIApplication sharedApplication]delegate].window.safeAreaInsets;
        if (insets.top > 1) {
            frame.size.height += insets.top;
        }else{
            frame.size.height +=  [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
    }else{
        frame.size.height +=  [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    self.navBar = [[FHMapNavigationBar alloc] initWithFrame:frame];
    
    __weak typeof(self) wself = self;
    _navBar.backActionBlock = ^{
        [wself backAction];
    };
    
    _navBar.listActionBlock = ^{
        [wself showHouseList];
    };
    
    _navBar.mapActionBlock = ^{
        [wself showMap];
    };
    
    [self.view addSubview:self.navBar];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavbar];
    self.view.backgroundColor = [UIColor whiteColor];
    self.ttNeedIgnoreZoomAnimation = YES;
    self.viewModel = [[FHMapSearchViewModel alloc]initWithConfigModel:_configModel viewController:self];
    
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:_configModel.houseType showAllCondition:NO showSort:NO];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    self.houseFilterViewModel = bridge;
    [bridge showBottomLine:NO];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [self.filterPanel addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    __weak typeof(self) wself = self;
    _viewModel.resetConditionBlock = ^(NSDictionary *condition){
        [wself.houseFilterBridge resetFilter:wself.houseFilterViewModel withQueryParams:condition updateFilterOnly:YES];
    };
    
    _viewModel.conditionNoneFilterBlock = ^NSString * _Nullable(NSDictionary * _Nonnull params) {
        return [wself.houseFilterBridge getNoneFilterQueryParams:params];
    };
    
    if (self.configModel.mapOpenUrl.length > 0) {
        
        NSURL *url = [NSURL URLWithString:self.configModel.mapOpenUrl];
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        [bridge resetFilter:self.houseFilterViewModel withQueryParams:paramObj.allParams updateFilterOnly:NO];
        
    }else if (self.configModel.conditionParams) {
        [bridge resetFilter:self.houseFilterViewModel withQueryParams:_configModel.conditionParams updateFilterOnly:NO];
    }
    
    [bridge setViewModel:self.houseFilterViewModel withDelegate:_viewModel];
    
    BOOL showDraw = (self.configModel.houseType == FHHouseTypeSecondHandHouse);
    
    if (showDraw) {
        _chooseView = [[FHMapSearchWayChooseView alloc]initWithFrame:CGRectZero];
        _chooseView.delegate = _viewModel;
        _viewModel.chooseView = _chooseView;
        
        _bottomBar = [[FHMapSearchBottomBar alloc] init];
        _bottomBar.delegate = _viewModel;
        _bottomBar.hidden = YES;
        _viewModel.bottomBar = _bottomBar;
    }
        
    MAMapView *mapView = self.viewModel.mapView;
    [self.view addSubview:mapView];
    if (showDraw) {
        [self.view addSubview:_chooseView];
        [self.view addSubview:_bottomBar];
    }
    [self.view addSubview:self.locationButton];
    [self.view addSubview:self.filterBgControl];
    [self.view addSubview:self.filterPanel];
    self.filterBgControl.hidden = YES;
    
    [self initConstraints];
    
    _viewModel.tipView = self.tipView;
    
    self.title = _viewModel.navTitle;
    [self.navBar setTitle:self.title];
    [self.view bringSubviewToFront:self.navBar];
}

-(void)enablePan:(BOOL)enable
{
    TTNavigationController *navController = (TTNavigationController *)self.navigationController;
    navController.panRecognizer.enabled = enable;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    if (self.viewModel.showMode == FHMapSearchShowModeDrawLine || self.viewModel.showMode == FHMapSearchShowModeSubway) {
        [self enablePan:NO];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
    
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    
    [self enablePan:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.viewModel showMapUserLocationLayer];
}


-(CGFloat)statusBarHeight
{
    CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (height < 1) {
        height = 20;
    }
    return height;
}

-(void)initConstraints
{
    CGFloat navHeight = 44;
    CGFloat bottomSafeInset = 0;
    if (@available(iOS 11.0 , *)) {
        CGFloat top  = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
        if (top > 0) {
            navHeight += top;
        }else{
            navHeight += [self statusBarHeight];
        }
        bottomSafeInset = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        
    }else{
        navHeight += [self statusBarHeight];
    }
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view);
        make.height.mas_equalTo(navHeight);
    }];
    
    [self.viewModel.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.bottom.right.mas_equalTo(self.view);
    }];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.top.equalTo(self.filterPanel.mas_bottom);
    }];

    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navHeight);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kFilterBarHeight);
    }];
    
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(self.navBar.mas_bottom).offset(kFilterBarHeight+20);
        make.size.mas_equalTo(CGSizeMake(58, 58));
    }];
    
    CGFloat bottomMargin = -(39+bottomSafeInset);
    
    [self.chooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(bottomMargin);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(160, 58));
    }];
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(bottomMargin);
        make.height.mas_equalTo(58);
    }];    
}

-(CGFloat)contentViewHeight
{
    return self.view.height - self.filterPanel.bottom;
}

-(CGFloat)topBarBottom
{
    return self.filterPanel.bottom;
}

-(void)switchNavbarMode:(FHMapSearchShowMode)mode
{
    FHMapNavigationBarRightMode smode = FHMapNavigationBarRightModeMap;
    if (mode == FHMapSearchShowModeMap) {
        smode = FHMapNavigationBarRightModeList;
    }
    
    [self.navBar showRightMode:smode];
    
    self.title = self.viewModel.navTitle;
    [self.navBar setTitle:self.title];
}

-(void)showNavTopViews:(CGFloat)ratio animated:(BOOL)animated
{
    if(ratio < 0 || ratio > 1){
        return;
    }
    CGFloat alpha = ratio;
    if (!animated) {
        self.filterPanel.alpha =  alpha;
        self.navBar.alpha =  alpha;
        self.locationButton.alpha = alpha;
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.filterPanel.alpha =  alpha;
        self.navBar.alpha =  alpha;
        self.locationButton.alpha = alpha;
    }completion:^(BOOL finished) {
    }];
}

-(void)tryCallbackOpenUrl
{
    if (self.openUrlDelegate) {
        NSString *houseListOpenUrl = [self.viewModel backHouseListOpenUrl];
        if( houseListOpenUrl.length > 0) {
            [self.openUrlDelegate handleHouseListCallback:houseListOpenUrl];
        }
        self.openUrlDelegate = nil;
    }
}

#pragma mark - 画图找房
-(void)switchToNormalMode
{
    self.viewModel.showMode = FHMapSearchShowModeMap;
    self.bottomBar.hidden = YES;
    self.chooseView.hidden = NO;
    [self switchNavbarMode:FHMapSearchShowModeMap];
    [self showNavTopViews:1 animated:NO];
    [self enablePan:YES];
}

-(FHMapDrawMaskView *)drawMaskView
{
    if (!_drawMaskView) {
        _drawMaskView = [[FHMapDrawMaskView alloc] initWithFrame:self.view.bounds];
        _drawMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _drawMaskView.backgroundColor = RGBA(0, 0, 0, 0.0);
        _drawMaskView.delegate = self.viewModel;
        self.viewModel.drawMaskView = _drawMaskView;
    }
    return _drawMaskView;
}

-(void)enterMapDrawMode
{
    [self switchNavbarMode:FHMapSearchShowModeMap];
    [self showNavTopViews:0 animated:NO];
    [self.houseFilterBridge closeConditionFilterPanel];
    self.chooseView.hidden = YES;
    self.bottomBar.hidden = YES;
    self.locationButton.alpha = 0;
    
    [self.view addSubview:self.drawMaskView];
    TTNavigationController *navController = (TTNavigationController *)self.navigationController;
    navController.panRecognizer.enabled = NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)insertHouseListView:(UIView *)houseListView
{
    [self.view insertSubview:houseListView aboveSubview:self.locationButton];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

@end

