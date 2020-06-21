//
//  FHCommuteConfigViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHCommuteConfigViewController.h"
#import "FHCommuteFilterView.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTRoute/TTRoute.h>
#import "FHCommutePOISearchViewController.h"
#import <AMapSearchKit/AMapCommonObj.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <FHCommonUI/ToastManager.h>
#import "FHCommuteManager.h"
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <FHHouseBase/FHEnvContext.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHLocManager.h>

#define BANNER_HEIGHT SCREEN_WIDTH*(224/375.0)
#define INPUT_BG_HEIGHT 40
@interface FHCommuteConfigViewController ()<FHCommutePOISearchDelegate>

@property(nonatomic , strong) UIImageView *topBanner;
@property(nonatomic , strong) UIButton *backButton;
@property(nonatomic , strong) UILabel *bannerTitleLabel;
@property(nonatomic , strong) UILabel *bannerSubtitleLabel;
@property(nonatomic , strong) FHCommuteFilterView *filterView;
@property(nonatomic , strong) UIView *inputBgView;
@property(nonatomic , strong) UIView *inputBgShadowView;
@property(nonatomic , strong) UILabel *inputLabel;
@property(nonatomic , strong) AMapAOI *choosePOI;
@property(nonatomic , strong) AMapLocationReGeocode *chooseRegeoCode; //选择当前的反GEO定位
@property(nonatomic , strong) CLLocation *chooseLocation; //选择当前的反GEO定位
@property(nonatomic , assign) BOOL useLocation;//是否使用定位
@end

@implementation FHCommuteConfigViewController


-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSHashTable *table= paramObj.allParams[COMMUTE_CONFIG_DELEGATE];
        if (table) {
            self.delegate = UNWRAP_WEAK(table);
        }
    }
    return self;
    
}

-(UILabel *)label:(UIFont *)font text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.text = text;
    
    return label;
}

-(void)initBanners
{
    _topBanner = [[UIImageView alloc]initWithImage:SYS_IMG(@"commute_banner.jpg")];
    
    _bannerTitleLabel = [self label:[UIFont themeFontMedium:32] text:@"通勤找房"];
    _bannerSubtitleLabel = [self label:[UIFont themeFontRegular:14] text:@"更好的生活从缩短通勤开始"];
    
    [self.view addSubview:_topBanner];
    [self.view addSubview:_bannerTitleLabel];
    [self.view addSubview:_bannerSubtitleLabel];
    
}

-(void)initInputTip
{
 
    _inputBgView = [[UIView alloc] init];
    CALayer *clayer = [CALayer layer];
    clayer.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2*HOR_MARGIN_NEW, INPUT_BG_HEIGHT);
    clayer.backgroundColor = [[UIColor whiteColor]CGColor];
    clayer.cornerRadius = 20;
    clayer.masksToBounds = YES;
    
    _inputBgShadowView = [[UIView alloc]init];
    _inputBgShadowView.layer.cornerRadius = 20;
    _inputBgShadowView.backgroundColor = [UIColor whiteColor];
    
    CALayer *slayer = _inputBgShadowView.layer;
    slayer.frame = clayer.frame;
    slayer.shadowColor = [[UIColor blackColor]CGColor];
    slayer.shadowRadius = 20;
    slayer.shadowOpacity = 0.1;
    slayer.shadowOffset = CGSizeMake(2, 6);
    
    [_inputBgView.layer addSublayer:clayer];
    
    _inputLabel = [[UILabel alloc] init];
    _inputLabel.font = [UIFont themeFontRegular:14];
    _inputLabel.textColor = [UIColor themeGray4];
    _inputLabel.backgroundColor = [UIColor clearColor];
    _inputLabel.text = @"请输入公司地址";
    
    [_inputBgView addSubview:_inputLabel];
    
    [self.view addSubview:_inputBgShadowView];
    [self.view addSubview:_inputBgView];
    
 
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInputAction:)];
    [_inputBgView addGestureRecognizer:gesture];
    
}

-(void)showInputAction:(id)sender
{
    [self addClickSearchLog];
    FHCommutePOISearchViewController *controller = [[FHCommutePOISearchViewController alloc] init];
    controller.sugDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initBanners];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:SYS_IMG(@"nav_back_arrow_white") forState:UIControlStateNormal];
    [_backButton addTarget:self
                    action:@selector(backAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(57, 0, 10, 0);
    if (@available(iOS 11.0 , *)) {
       insets.bottom += [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    _filterView = [[FHCommuteFilterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200) insets:insets type:FHCommuteTypeDrive];
    __weak typeof(self) wself = self;
    _filterView.chooseBlock = ^(NSString * _Nonnull time, FHCommuteType type) {
        if (!wself.choosePOI && !wself.chooseRegeoCode) {
            SHOW_TOAST(@"请选择目的地");
            return ;
        }
        [wself startSearch:time type:type];                
    };
    _filterView.boldTitle = YES;
    
    [self.view addSubview:_filterView];
    
    [self initInputTip];
    
    [self initConstraints];
    
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    NSString *destLocation = manager.destLocation;
    if (destLocation.length == 0) {
        NSString *selectCityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        AMapLocationReGeocode * currentReGeocode =  [FHLocManager sharedInstance].currentAmpReGeocode;
        
        if ([FHEnvContext isSameLocCityToUserSelect] && currentReGeocode.city &&([currentReGeocode.city hasPrefix:selectCityName] || [selectCityName hasPrefix:currentReGeocode.city])) {
            AMapLocationReGeocode *currentReGeocode =  [FHLocManager sharedInstance].currentAmpReGeocode;
            self.chooseLocation = [FHLocManager sharedInstance].currentLocaton;
            if (currentReGeocode && self.chooseLocation) {
                destLocation = currentReGeocode.AOIName;
                self.chooseRegeoCode = currentReGeocode;
                self.useLocation = YES;
            }
        }
    }
    
    if (destLocation.length > 0) {
        _inputLabel.text = destLocation;
        self.inputLabel.textColor = [UIColor themeGray1];
    }else{
        _filterView.enableSearch = NO;
    }
    [_filterView updateType:manager.commuteType time:manager.duration];
    
    [self addGoDetailLog];

    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.useLocation && _chooseRegeoCode != [FHLocManager sharedInstance].currentAmpReGeocode ) {
        _chooseRegeoCode = [FHLocManager sharedInstance].currentAmpReGeocode;
        _inputLabel.text = _chooseRegeoCode.AOIName;
    }
}

-(void)initConstraints
{
    CGFloat topMargin = 29;
    if (@available(iOS 11.0 , *)) {
        CGFloat safeTop = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
        if (safeTop > 0) {
            topMargin = safeTop+9 ;
        }
    }
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.top.mas_equalTo(topMargin);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [_topBanner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(BANNER_HEIGHT);
    }];
    
    [_bannerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.right.mas_lessThanOrEqualTo(self.view).offset(-HOR_MARGIN_NEW);
        make.top.mas_equalTo(topMargin + 64);
        make.height.mas_equalTo(45);
    }];
    
    [_bannerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.top.mas_equalTo(self.bannerTitleLabel.mas_bottom).offset(0);
        make.right.mas_lessThanOrEqualTo(self.view).offset(-HOR_MARGIN_NEW);
        make.height.mas_equalTo(20);
    }];
    
    
    [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topBanner.mas_bottom);
    }];
    
    
    [_inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN_NEW);
        make.right.mas_equalTo(self.view).offset(-HOR_MARGIN_NEW);
        make.top.mas_equalTo(_topBanner.mas_bottom).offset(-19);
        make.height.mas_equalTo(INPUT_BG_HEIGHT);
    }];
    
    [_inputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(self.inputBgView);
    }];
    
    [_inputBgShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.inputBgView);
    }];
}


-(void)userChoosePoi:(AMapAOI *)poi inViewController:(UIViewController *)viewController
{
    self.useLocation = NO;
    self.inputLabel.text = poi.name;
    self.inputLabel.textColor = [UIColor themeGray1];
    [viewController.navigationController popViewControllerAnimated:YES];
    self.choosePOI = poi;
    _filterView.enableSearch = YES;
}

-(void)userChooseLocation:( CLLocation * )location geoCode:(AMapLocationReGeocode *)geoCode inViewController:(UIViewController *)viewController
{    
    self.inputLabel.text = geoCode.AOIName;
    self.inputLabel.textColor = [UIColor themeGray1];
    [viewController.navigationController popViewControllerAnimated:YES];
    self.chooseRegeoCode = geoCode;
    self.chooseLocation = location;
    _filterView.enableSearch = YES;
}

-(void)userCanced:(FHCommutePOISearchViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}


-(void)startSearch:(NSString *)duration type:(FHCommuteType)type
{
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    manager.duration = duration;
    manager.commuteType = type;
    manager.destLocation = self.inputLabel.text;
    if (self.choosePOI) {
        manager.latitude = self.choosePOI.location.latitude;
        manager.longitude = self.choosePOI.location.longitude;
    }else{
        manager.latitude = self.chooseLocation.coordinate.latitude;
        manager.longitude = self.chooseLocation.coordinate.longitude;
    }
    
    manager.cityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    [manager sync];
    
    if ([self.delegate respondsToSelector:@selector(commuteWithDest:type:duration:inController:)]) {
        [self.delegate commuteWithDest:self.choosePOI.name type:type duration:duration inController:self];
    }else{        
        [self.navigationController popViewControllerAnimated:YES ];
    }
    
    [self addStartSearchLog];
}

-(NSString *)pageType
{
    return @"commuter_detail";
}
#pragma mark - tracker
-(void)addGoDetailLog
{
    /*
     "1.event_type:house_app2c_v2
     2.page_type:commuter_detail(通勤选项页）
     3.enter_from:renting(从租房icon进入),rent_list（从修改进入）
     4.element_from:commuter_info（从租房icon进入），be_null（从修改进入）
     5.origin_from:commuter（通勤找房）
     6. origin_search_id"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:[self.tracerModel logDict]];
    param[UT_PAGE_TYPE] = [self pageType];
    TRACK_EVENT(UT_GO_DETAIL, param);
}

-(void)addStartSearchLog
{
    /*
     1. event_type：house_app2c_v2
     2. page_type：commuter_detail(通勤选项页）
     3. house_type：rent(租房)
     4.enter_from:renting(从租房icon进入),rent_list（从修改进入）
     5.element_from:commuter_info（从租房icon进入），be_null（从修改进入）
     6. origin_from:commuter(通勤找房）
     7. origin_search_id
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = [self pageType];
    param[UT_HOUSE_TYPE] = @"rent";
    param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
    param[UT_ELEMENT_FROM] = @"commuter_info";
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom?:UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = self.tracerModel.originSearchId?:UT_BE_NULL;
    
    TRACK_EVENT(@"start_commute", param);
    
}

-(void)addClickSearchLog
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = [self pageType];
    param[UT_ORIGIN_SEARCH_ID] = self.tracerModel.originSearchId?:UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom?:@"commuter";
    param[@"selected_word"] = self.choosePOI.name?:UT_BE_NULL;
    
    TRACK_EVENT(@"click_house_search", param);
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

NSString *const COMMUTE_CONFIG_DELEGATE = @"_COMMUTE_CONFIG_DELEGATE_";
