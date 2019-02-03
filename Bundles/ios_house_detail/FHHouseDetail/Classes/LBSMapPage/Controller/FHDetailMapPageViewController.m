//
//  FHDetailMapPageViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/1/31.
//

#import "FHDetailMapPageViewController.h"
#import "FHDetailMapPageNaviBarView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <TTDeviceHelper.h>
#import <TTUIResponderHelper.h>
#import <UIViewAdditions.h>
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <AMapSearchKit/AMapSearchKit.h>

static NSInteger const kBottomBarTagValue = 100;
static NSInteger const kBottomButtonLabelTagValue = 1000;

@interface FHMyMAAnnotation : MAPointAnnotation
@property (nonnull, strong) NSString *type;
@end

@implementation FHMyMAAnnotation

@end

@interface FHDetailMapPageViewController () <TTRouteInitializeProtocol,AMapSearchDelegate,MAMapViewDelegate>

@property (nonatomic, strong) FHDetailMapPageNaviBarView *naviBar;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonnull, strong) UIView *mapContainer;
@property (nonatomic, strong) UIView * bottomBarView;
@property (nonatomic, strong) UIButton * previouseIconButton;
@property (nonatomic, strong) UILabel * previouseLabel;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray * nameArray;
@property (nonatomic, strong) NSArray * imageNameArray;
@property (nonatomic, strong) NSArray * keyWordArray;
@property (nonatomic, strong) NSString * searchCategory;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) NSMutableArray <FHMyMAAnnotation *> *poiAnnotations;


@end

@implementation FHDetailMapPageViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        TTRouteUserInfo *userInfo = paramObj.userInfo;
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
        self.selectedIndex = 0;
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        NSLog(@"userinfo = %@",[userInfo.allInfo objectForKey:@"url"]);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameArray = [NSArray arrayWithObjects:@"银行",@"公交",@"地铁",@"教育",@"医院",@"休闲",@"购物",@"健身",@"美食", nil];
    _imageNameArray = [NSArray arrayWithObjects:@"tab-bank",@"tab-bus",@"tab-subway",@"tab-education",@"tab-hospital",@"tab-relaxation",@"tab-mall",@"tab-swim",@"tab-food", nil];
    _keyWordArray = [NSArray arrayWithObjects:@"bank",@"bus",@"subway",@"scholl",@"hospital",@"entertainment",@"shopping",@"gym",@"food", nil];
    
    
    [self setUpNaviBar];
    
    [self setUpBottomBarView];
    
    [self setUpMapView];
    
    // Do any additional setup after loading the view.
}

- (void)setUpNaviBar
{
    _naviBar = [[FHDetailMapPageNaviBarView alloc] initWithBackImage:[UIImage imageNamed:@"icon-return"]];
    [self.view addSubview:_naviBar];
    
    
    __weak typeof(self) wself = self;
    _naviBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };

    CGFloat navHeight = 44;
    
    if (@available(iOS 11.0 , *)) {
        CGFloat top  = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
        if (top > 0) {
            navHeight += top;
        }else{
            navHeight += [self statusBarHeight];
        }
    }else{
        navHeight += [self statusBarHeight];
    }
    
    [self.naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.view);
        make.height.mas_equalTo(navHeight);
    }];
}

- (void)setUpBottomBarView
{
    _bottomBarView = [UIView new];
    [self.view addSubview:_bottomBarView];
    CGFloat bottomBarHeight = 43;
    [_bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper isIPhoneXDevice]) {
            make.bottom.equalTo(self.view).offset(-40);
        }else
        {
            make.bottom.equalTo(self.view);
        }
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(bottomBarHeight);
        make.left.right.equalTo(self.view);
    }];
    
    
    UIScrollView *scrollViewItem = [[UIScrollView alloc] init];
    scrollViewItem.tag = kBottomBarTagValue;
    [_bottomBarView addSubview:scrollViewItem];
    
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width / 6.5;
    scrollViewItem.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, bottomBarHeight);
    scrollViewItem.contentSize = CGSizeMake(itemWidth * [_nameArray count], bottomBarHeight);
    scrollViewItem.showsVerticalScrollIndicator = NO;
    scrollViewItem.showsHorizontalScrollIndicator = NO;
    
    for (int i = 0; i < [_nameArray count]; i++) {
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth * i, 0, itemWidth, scrollViewItem.contentSize.height)];
        [scrollViewItem addSubview:iconView];

        UIButton *buttonIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == self.selectedIndex) {
            NSString *stringName = [NSString stringWithFormat:@"%@-pressed",_imageNameArray[i]];
            [buttonIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-pressed",_imageNameArray[i]]] forState:UIControlStateNormal];
            self.previouseIconButton = buttonIcon;
        }else
        {
        [buttonIcon setImage:[UIImage imageNamed:_imageNameArray[i]] forState:UIControlStateNormal];
        }
        
        [buttonIcon addTarget:self action:@selector(typeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        buttonIcon.tag = i;
        [buttonIcon setFrame:CGRectMake((itemWidth - 32) / 2, 0, 32, 32)];
        [iconView addSubview:buttonIcon];

        
        UILabel *buttonLabel = [UILabel new];
        buttonLabel.text = _nameArray[i];
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.font = [UIFont themeFontRegular:9];
        if (i == self.selectedIndex) {
            buttonLabel.textColor = [UIColor themeBlue];
            self.previouseLabel = buttonLabel;
        }else
        {
            buttonLabel.textColor = [UIColor themeGray];
        }
        buttonLabel.tag = i + kBottomButtonLabelTagValue;
        [buttonLabel setFrame:CGRectMake(0, 30, itemWidth, 13)];
        [iconView addSubview:buttonLabel];
    }
}

- (UILabel *)getLabelFromTag:(NSInteger)index
{
    UIView *scrollContent = [_bottomBarView viewWithTag:kBottomBarTagValue];
    UILabel *buttonLabel = (UILabel *)[scrollContent viewWithTag:index + kBottomButtonLabelTagValue];
    return buttonLabel;
}

- (void)typeButtonClick:(UIButton *)button
{
    UILabel *buttonLabel = [self getLabelFromTag:button.tag];
    
    if (button.tag < [_imageNameArray count] && self.previouseIconButton.tag < [_imageNameArray count]) {
        [self.previouseIconButton setImage:[UIImage imageNamed:_imageNameArray[self.previouseIconButton.tag]] forState:UIControlStateNormal];
        self.previouseLabel.textColor = [UIColor themeGray];
        buttonLabel.textColor = [UIColor themeBlue];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-pressed",_imageNameArray[button.tag]]] forState:UIControlStateNormal];
    }
    self.previouseIconButton = button;
    self.previouseLabel = buttonLabel;
}

- (void)requestPoiInfo:(CLLocationCoordinate2D)center andKeyWord:(NSString *)categoryName
{
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    AMapPOIKeywordsSearchRequest *requestPoi = [AMapPOIKeywordsSearchRequest new];
    requestPoi.keywords = categoryName;
    requestPoi.location = [AMapGeoPoint locationWithLatitude:self.centerPoint.latitude longitude:self.centerPoint.longitude];
    requestPoi.requireExtension = YES;
    requestPoi.requireSubPOIs = YES;
    requestPoi.cityLimit = YES;
    
    [self.searchApi AMapPOIIDSearch:requestPoi];
}

//func requestPOIInfo(center: CLLocationCoordinate2D, category: String) {
//    search.cancelAllRequests()
//
//    if EnvContext.shared.client.reachability.connection == .none {
//        EnvContext.shared.toast.showToast("网络异常")
//        return
//    }
//    let request = AMapPOIKeywordsSearchRequest()
//    request.keywords = category
//    request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
//    request.requireExtension = true
//    request.requireSubPOIs = true
//    request.cityLimit = true
//    search.aMapPOIKeywordsSearch(request)
//}


- (void)setUpMapView
{
    _mapContainer = [UIView new];
    //[TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom
    [self.view addSubview:_mapContainer];
    [_mapContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper isIPhoneXDevice]) {
            make.bottom.equalTo(self.view).offset(-83);
        }else
        {
            make.bottom.equalTo(self.view);
        }
        make.top.equalTo(self.naviBar.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    [_mapContainer setBackgroundColor:[UIColor redColor]];
    
    
    _mapView = [[MAMapView alloc] init];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = YES;
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.showsUserLocation = NO;
    _mapView.zoomLevel  = 15;
    [_mapContainer addSubview:_mapView];
    [_mapView setBackgroundColor:[UIColor blueColor]];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.mapContainer);
    }];
    [_mapView setBackgroundColor:[UIColor blueColor]];
    [_mapView setCenterCoordinate:self.centerPoint];
    
    
    NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_map_style" ofType:@"data"];
    if ([stylePath isKindOfClass:[NSString class]]) {
        NSURL *styleUrl = [NSURL URLWithString:stylePath];
        if ([styleUrl isKindOfClass: [NSURL class]]) {
            NSData *dataStype = [NSData dataWithContentsOfFile:styleUrl];
            if ([dataStype isKindOfClass:[NSData class]]) {
                _mapView.customMapStyleEnabled = YES;
                [_mapView setCustomMapStyleWithWebData:dataStype];
            }
        }
    }
    
    [self requestPoiInfo:self.centerPoint andKeyWord:@"交通"];
}

#pragma poi Delegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.count == 0) {
        [[ToastManager manager] showToast:@"暂无相关信息"];
        return;
    }
    
    NSInteger poiCount = response.pois.count > 50 ? 50 :  response.pois.count;
    NSMutableArray *poiArray = [NSMutableArray new];
    for (NSInteger i = 0; i < poiCount; i++) {
        AMapPOI * poi = response.pois[i];
        
        FHMyMAAnnotation *maAnna = [FHMyMAAnnotation new];
        maAnna.type = self.searchCategory;
        maAnna.coordinate = CLLocationCoordinate2DMake(poi.location.latitude,poi.location.longitude);
        maAnna.title = poi.name;
        
        [poiArray addObject:maAnna];
    }
    
    self.poiAnnotations = poiArray;
    
    

//    let pois = response.pois.take(50).map { (poi) -> MyMAAnnotation in
//        let re = MyMAAnnotation()
//        re.type = searchCategory.value
//        re.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
//        re.title = poi.name
//        return re
//    }
}

#pragma MapViewDelegata
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    MACircle * cicle = [MACircle circleWithMapRect:MAMapRectZero];
    MAOverlayRenderer *overlayRender = [[MAOverlayRenderer alloc] initWithOverlay:overlay];
    return overlayRender;
}

#pragma safeInset

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeInset = self.view.safeAreaInsets;
    if (safeInset.top > 0 || [TTDeviceHelper isIPhoneXDevice]){
       
    }
}

-(CGFloat)statusBarHeight
{
    CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (height < 1) {
        height = 20;
    }
    return height;
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
