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
#import "FHMapSimpleNavbar.h"
#import "FHMapSearchInfoTopBar.h"
#import "FHMapSearchSideBar.h"

#define kTapDistrictZoomLevel  16
#define kFilterBarHeight 44
#define TOP_INFO_BAR_HEIGHT 45
#define TOP_INFO_BAR_HOR_MARGIN 10

@interface FHMapSearchViewController ()<TTRouteInitializeProtocol>

@property(nonatomic , strong) FHMapSimpleNavbar *simpleNavBar;
@property(nonatomic , strong) FHMapSearchInfoTopBar *topInfoBar;
@property(nonatomic , strong) FHMapSearchSideBar *sideBar;
@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , strong) FHMapSearchViewModel *viewModel;
@property(nonatomic , strong) FHMapSearchTipView *tipView;
@property(nonatomic , strong) UIBarButtonItem *showHouseListBarItem;
@property(nonatomic , strong) UIBarButtonItem *showMapBarItem;
@property(nonatomic , strong) UILabel *navTitleLabel;
@property(nonatomic , strong) UIButton *locationButton;

@property(nonatomic , strong) FHMapDrawMaskView *drawMaskView;
//@property(nonatomic , strong) FHMapSearchWayChooseView *chooseView;
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
        self.locationButton.hidden = NO;
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

-(FHMapSearchSideBar *)sideBar
{
    if (!_sideBar) {
        _sideBar = [[FHMapSearchSideBar alloc]initWithFrame:CGRectMake(0, 0, 36, 246)];
        [_sideBar showWithTypes:@[ @(FHMapSearchSideBarItemTypeSubway) , @(FHMapSearchSideBarItemTypeCircle) , @(FHMapSearchSideBarItemTypeFilter) , @(FHMapSearchSideBarItemTypeList)]];
        _sideBar.chooseTypeBlock = ^(FHMapSearchSideBarItemType type) {
            
        };
    }
    return _sideBar;
}

-(FHMapSearchInfoTopBar *)topInfoBar
{
    if (!_topInfoBar) {
        _topInfoBar = [[FHMapSearchInfoTopBar alloc]initWithFrame:CGRectMake(0, 0, self.view.width-20, TOP_INFO_BAR_HEIGHT)];
        __weak typeof(self) wself = self;
        _topInfoBar.backBlock = ^{
            [wself.viewModel hideAreaHouseList];
        };
        
        _topInfoBar.filterBlock = ^{
            [wself.viewModel showFilterForAreaHouseList];
        };
        _topInfoBar.hidden = YES;
    }
    return _topInfoBar;
}

-(void)backAction
{
    if (self.viewModel.showMode == FHMapSearchShowModeMap || self.viewModel.showMode == FHMapSearchShowModeSubway) {
        [self.navigationController popViewControllerAnimated:YES];
        [self tryCallbackOpenUrl];
    }else{
        [self.viewModel dismissHouseListView];
//        [self.houseFilterBridge closeConditionFilterPanel];
    }
    
}

-(void)locationAction
{
    [self.viewModel moveToUserLocation];
}

-(void)showHouseList
{
//    [self.houseFilterBridge closeConditionFilterPanel];
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
//    [self.houseFilterBridge closeConditionFilterPanel];
    [self switchNavbarMode:FHMapSearchShowModeMap];
    [self.viewModel showMap];
}

-(void)initNavbar
{
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100);
    if (@available(iOS 11.0 , *)) {
        UIEdgeInsets insets = [[UIApplication sharedApplication]delegate].window.safeAreaInsets;
        if (insets.top > 1) {
            frame.size.height += insets.top;
        }
    }
    __weak typeof(self) wself = self;
    self.simpleNavBar = [[FHMapSimpleNavbar alloc]initWithFrame:frame];
    _simpleNavBar.backActionBlock = ^(FHMapSimpleNavbarType type) {
        if (type == FHMapSimpleNavbarTypeClose) {
            [wself.viewModel exitCurrentMode];
        }else{
            [wself backAction];
        }
    };
    [self.view addSubview:_simpleNavBar];
    
//    self.navBar = [[FHMapNavigationBar alloc] initWithFrame:frame];
//
//
//    _navBar.backActionBlock = ^{
//        [wself backAction];
//    };
//
//    _navBar.listActionBlock = ^{
//        [wself showHouseList];
//    };
//
//    _navBar.mapActionBlock = ^{
//        [wself showMap];
//    };
//
//    [self.view addSubview:self.navBar];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavbar];
    self.view.backgroundColor = [UIColor whiteColor];
    self.ttNeedIgnoreZoomAnimation = YES;
    self.viewModel = [[FHMapSearchViewModel alloc]initWithConfigModel:_configModel viewController:self];
    __weak typeof(self) wself = self;
    
    if (self.configModel.mapOpenUrl.length > 0) {
        
        NSURL *url = [NSURL URLWithString:self.configModel.mapOpenUrl];
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
//        [bridge resetFilter:self.houseFilterViewModel withQueryParams:paramObj.allParams updateFilterOnly:NO];
        
    }else if (self.configModel.conditionParams) {
//        [bridge resetFilter:self.houseFilterViewModel withQueryParams:_configModel.conditionParams updateFilterOnly:NO];
    }
    
//    [bridge setViewModel:self.houseFilterViewModel withDelegate:_viewModel];
    
    BOOL showDraw = (self.configModel.houseType == FHHouseTypeSecondHandHouse);

    if (showDraw) {
        _bottomBar = [[FHMapSearchBottomBar alloc] init];
        _bottomBar.delegate = _viewModel;
        _bottomBar.hidden = YES;
        _viewModel.bottomBar = _bottomBar;
    }
    
    MAMapView *mapView = self.viewModel.mapView;
    [self.view addSubview:mapView];
    if (showDraw) {
//        [self.view addSubview:_chooseView];
        [self.view addSubview:_bottomBar];
    }
    if (!self.locationButton.hidden) {
        [self.view addSubview:self.locationButton];
    }
    [self.view addSubview:self.sideBar];
    [self.view addSubview:self.topInfoBar];
    
    [self initConstraints];
    
    _viewModel.sideBar = self.sideBar;
    _viewModel.topInfoBar = self.topInfoBar;
    _viewModel.tipView = self.tipView;
    
    self.title = _viewModel.navTitle;
    [self.simpleNavBar setTitle:self.title];
    [self.view bringSubviewToFront:self.simpleNavBar];
    
    [_viewModel tryUpdateSideBar];
    [self switchNavbarMode:FHMapSearchShowModeMap];
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
    CGFloat topSafeInset = 0;
    if (@available(iOS 11.0 , *)) {
        CGFloat top  = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
        if (top > 0) {
            navHeight += top;
            topSafeInset = top;
        }else{
            navHeight += [self statusBarHeight];
        }
        bottomSafeInset = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        
    }else{
        navHeight += [self statusBarHeight];
    }
    
    [self.simpleNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view);
        make.height.mas_equalTo(self.simpleNavBar.height);
    }];
    
    [self.viewModel.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.bottom.right.mas_equalTo(self.view);
    }];
    
//    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(self.view);
//        make.top.equalTo(self.filterPanel.mas_bottom);
//    }];
//
//    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(navHeight);
//        make.left.right.mas_equalTo(self.view);
//        make.height.mas_equalTo(kFilterBarHeight);
//    }];
    
    if (self.locationButton.superview) {
        [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-5);
            make.bottom.mas_equalTo(self.view).offset(-(20+bottomSafeInset));
            make.size.mas_equalTo(CGSizeMake(58, 58));
        }];
    }

    [self.sideBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.bottom.mas_equalTo(self.view).offset(-(96+bottomSafeInset));
        make.width.mas_equalTo(40);
    }];
    
    [self.topInfoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(TOP_INFO_BAR_HOR_MARGIN);
        make.right.mas_equalTo(-TOP_INFO_BAR_HOR_MARGIN);
        make.top.mas_equalTo((topSafeInset>0?topSafeInset:20)+10);
        make.height.mas_equalTo(TOP_INFO_BAR_HEIGHT);
    }];
    
    CGFloat bottomMargin = -(31+bottomSafeInset);
    
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(bottomMargin);
        make.height.mas_equalTo(58);
    }];    
}

-(CGFloat)contentViewHeight
{
    UIEdgeInsets safeEdges = UIEdgeInsetsZero;
    if (@available(iOS 11.0 , *)) {
        safeEdges =  [[UIApplication sharedApplication]delegate].window.safeAreaInsets;
    }
    return self.view.height - (10+ (safeEdges.top > 0 ? safeEdges.top: 20)) ;
}

-(CGFloat)topBarBottom
{
    return  self.simpleNavBar.height;//self.filterPanel.bottom;
}

-(void)switchNavbarMode:(FHMapSearchShowMode)mode
{
    self.title =  self.viewModel.navTitle ;
    [self.simpleNavBar setTitle:self.title];
    self.simpleNavBar.type = (FHMapSearchShowModeMap == mode ? FHMapSimpleNavbarTypeBack : FHMapSimpleNavbarTypeClose);
}

-(void)showNavTopViews:(CGFloat)ratio animated:(BOOL)animated
{
    if(ratio < 0 || ratio > 1){
        return;
    }
    CGFloat alpha = ratio;
    if (!animated) {
        self.simpleNavBar.alpha =  alpha;
        return;
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.simpleNavBar.alpha =  alpha;
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
    self.sideBar.hidden = NO;
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
    [self switchNavbarMode:FHMapSearchShowModeDrawLine];
    self.bottomBar.hidden = YES;
    self.sideBar.hidden = YES;
    self.locationButton.alpha = 0;
    
    [self.view addSubview:self.drawMaskView];
    TTNavigationController *navController = (TTNavigationController *)self.navigationController;
    navController.panRecognizer.enabled = NO;
    [self.view bringSubviewToFront:self.simpleNavBar];
}

-(void)enterSubwayMode
{
    self.bottomBar.hidden = YES;
    self.sideBar.hidden = NO;
    self.locationButton.alpha = 0;
    
    [self.sideBar showWithTypes:@[@(FHMapSearchSideBarItemTypeSubway)]];
    [self.sideBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.sideBar.height);
    }];
    [self switchNavbarMode:FHMapSearchShowModeSubway];
}

-(BOOL)isShowingMaskView
{
    return _drawMaskView.superview && !_drawMaskView.hidden;
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

