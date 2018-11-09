//
//  FHMapSearchViewController.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHMapSearchViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "Bubble-Swift.h"
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


#define kTapDistrictZoomLevel  16
#define kFilterBarHeight 51

@interface FHMapSearchViewController ()<TTRouteInitializeProtocol>

@property(nonatomic , strong) FHMapNavigationBar *navBar;
@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , strong) FHMapSearchViewModel *viewModel;
@property(nonatomic , strong) UIView *filterPanel;
@property(nonatomic , strong) UIControl *filterBgControl;
@property(nonatomic , strong) HouseFilterViewModel* houseFilterViewModel;
@property(nonatomic , strong) FHMapSearchTipView *tipView;
@property(nonatomic , strong) UIBarButtonItem *showHouseListBarItem;
@property(nonatomic , strong) UIBarButtonItem *showMapBarItem;
@property(nonatomic , strong) UILabel *navTitleLabel;

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
    self = [super init];
    if (self) {
        self.configModel = [[FHMapSearchConfigModel alloc] initWithDictionary:paramObj.allParams error:nil];
        [self setupConfigModel];        
    }
    return self;
}

-(void)dealloc
{
    [self tryCallbackFilterCondition];
}

-(void)setupConfigModel
{
    if(_configModel.resizeLevel == 0){
        _configModel.resizeLevel = 11;
    }
    
    if([[[EnvContext shared] client] locationSameAsChooseCity]){
        //定位城市和选择城市是同一城市时 进入小区视野
        _configModel.resizeLevel = 16;
        
        CLLocationCoordinate2D location = [[[EnvContext shared] client] currentLocation];
        if (location.latitude > 0 && location.longitude > 0) {
            _configModel.centerLatitude = [@(location.latitude) description];
            _configModel.centerLongitude = [@(location.longitude) description];
        }
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

-(void)backAction
{
    if (self.viewModel.showMode == FHMapSearchShowModeMap) {
        [self.navigationController popViewControllerAnimated:YES];
        [self tryCallbackFilterCondition];
    }else{
        [self.viewModel dismissHouseListView];
    }
    
}

-(void)showHouseList
{
    [self.viewModel addNavSwitchHouseListLog];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMap
{
    [self switchNavbarMode:FHMapSearchShowModeMap];
    [self.viewModel showMap];
}

-(void)initNavbar
{
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44);
    if (@available(iOS 11.0 , *)) {
        UIEdgeInsets insets = [[UIApplication sharedApplication]keyWindow].safeAreaInsets;
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
    
    MapFindHouseFilterFactory* factory = [[MapFindHouseFilterFactory alloc] init];
    self.houseFilterViewModel = [factory createFilterPanelViewModelWithHouseType: HouseTypeSecondHandHouse];
    self.filterBgControl = [[UIControl alloc] init];
    self.filterPanel = self.houseFilterViewModel.filterPanelView;
    self.filterBgControl = self.houseFilterViewModel.filterConditionPanel;
    if (_configModel.conditionParams) {
        [self.houseFilterViewModel resetFilterConditionWithQueryParams:self.configModel.conditionParams];
    }

    self.viewModel = [[FHMapSearchViewModel alloc]initWithConfigModel:_configModel viewController:self];
    MAMapView *mapView = self.viewModel.mapView;
    [self.view addSubview:mapView];
    [self.view addSubview:self.filterBgControl];
    [self.view addSubview:self.filterPanel];
    self.filterBgControl.hidden = YES;
    
    [self initConstraints];
    
    _viewModel.tipView = self.tipView;
    if (self.configModel.conditionParams) {
        [self.houseFilterViewModel resetFilterConditionWithQueryParams:_configModel.conditionParams];
        _viewModel.filterConditionParams = [self.houseFilterViewModel getConditions];
    }
    self.houseFilterViewModel.delegate = _viewModel;
    
    self.title = _viewModel.navTitle;
    [self.navBar setTitle:self.title];
    [self.view bringSubviewToFront:self.navBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
}


-(void)initConstraints
{
    CGFloat navHeight = 44;
    
    if (@available(iOS 11.0 , *)) {
        CGFloat top  = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        if (top > 0) {
            navHeight += top;
        }else{
            navHeight += [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }else{
        navHeight += [UIApplication sharedApplication].statusBarFrame.size.height;
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
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.filterPanel.alpha =  alpha;
        self.navBar.alpha =  alpha;
    }completion:^(BOOL finished) {
    }];
}

-(void)tryCallbackFilterCondition
{
    if (self.choosedConditionFilter) {
        NSString *conditions =  [self.viewModel filterConditionParams];
        if (conditions) {
            NSURL *url = [NSURL URLWithString:[@"https://a?" stringByAppendingString:conditions]];
            TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
            NSString *suggestion =  [self.viewModel configModel].suggestionParams;
            if(paramObj.queryParams || suggestion){
                self.choosedConditionFilter(paramObj.queryParams,suggestion);
            }
        }
        self.choosedConditionFilter = nil;
    }
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

@end
