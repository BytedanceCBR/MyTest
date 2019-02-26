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
#import <MAMapKit/MAMapKit.h>

#import <TTDeviceHelper.h>
#import <TTUIResponderHelper.h>
#import <UIViewAdditions.h>
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <FHEnvContext.h>
#import "UIViewController+Track.h"
#import <FHEnvContext.h>

#import "FHMyMAAnnotation.h"

static NSInteger const kBottomBarTagValue = 100;
static NSInteger const kBottomButtonLabelTagValue = 1000;

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
@property (nonatomic, strong) NSArray * iconImageArray;
@property (nonatomic, strong) NSString * searchCategory;
@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) NSMutableArray <FHMyMAAnnotation *> *poiAnnotations;
@property (nonatomic, strong) NSMutableDictionary *traceDict;

@end

@implementation FHDetailMapPageViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        TTRouteUserInfo *userInfo = paramObj.userInfo;
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
        self.selectedIndex = 0;
        self.ttTrackStayEnable = YES;
        _traceDict =[NSMutableDictionary dictionaryWithDictionary:paramObj.allParams[@"tracer"]];
        
        if ([userInfo.allInfo objectForKey:@"latitude"] && [userInfo.allInfo objectForKey:@"longitude"]) {
            self.centerPoint = CLLocationCoordinate2DMake([[userInfo.allInfo objectForKey:@"latitude"] floatValue], [[userInfo.allInfo objectForKey:@"longitude"] floatValue]);
        }
        
        if ([[userInfo.allInfo objectForKey:@"category"] isKindOfClass:[NSString class]]) {
            self.searchCategory = [userInfo.allInfo objectForKey:@"category"];
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameArray = [NSArray arrayWithObjects:@"银行",@"公交",@"地铁",@"教育",@"医院",@"休闲",@"购物",@"健身",@"美食", nil];
    _imageNameArray = [NSArray arrayWithObjects:@"tab-bank",@"tab-bus",@"tab-subway",@"tab-education",@"tab-hospital",@"tab-relaxation",@"tab-mall",@"tab-swim",@"tab-food", nil];
    _keyWordArray = [NSArray arrayWithObjects:@"bank",@"bus",@"subway",@"scholl",@"hospital",@"entertainment",@"shopping",@"gym",@"food", nil];
    _iconImageArray = [NSArray arrayWithObjects:@"icon-bank",@"icon-bus",@"icon-subway",@"icon_education",@"icon_hospital",@"icon-relaxation",@"icon-mall",@"icon_swim",@"icon-restaurant", nil];
    
    NSInteger selectIndex = [_nameArray indexOfObject:self.searchCategory];

    self.selectedIndex = selectIndex;
    
    [self setUpNaviBar];
    
    [self setUpMapView];
    
    [self setUpBottomBarView];
    
    [_traceDict removeObjectForKey:@"page_type"];
    [_traceDict removeObjectForKey:@"card_type"];
    [_traceDict removeObjectForKey:@"rank"];

    [FHEnvContext recordEvent:_traceDict andEventKey:@"enter_map"];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)addStayPageLog:(NSTimeInterval)stayTime
{
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.traceDict];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHEnvContext recordEvent:params andEventKey:@"stay_map"];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)setUpNaviBar
{
    _naviBar = [[FHDetailMapPageNaviBarView alloc] initWithBackImage:[UIImage imageNamed:@"icon-return"]];
    [self.view addSubview:_naviBar];
    
    
    __weak typeof(self) wself = self;
    _naviBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    
    _naviBar.naviMapActionBlock = ^{
        [wself createMenu];
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
    [_bottomBarView setBackgroundColor:[UIColor whiteColor]];
    
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
    
    self.searchCategory = self.nameArray[self.selectedIndex];
    
}

- (UILabel *)getLabelFromTag:(NSInteger)index
{
    UIView *scrollContent = [_bottomBarView viewWithTag:kBottomBarTagValue];
    UILabel *buttonLabel = (UILabel *)[scrollContent viewWithTag:index + kBottomButtonLabelTagValue];
    return buttonLabel;
}

- (void)typeButtonClick:(UIButton *)button
{
//    if (button == self.previouseIconButton) {
//
//        return;
//    }
//
    UILabel *buttonLabel = [self getLabelFromTag:button.tag];
    
    if (button.tag < [_imageNameArray count] && self.previouseIconButton.tag < [_imageNameArray count]) {
        [self.previouseIconButton setImage:[UIImage imageNamed:_imageNameArray[self.previouseIconButton.tag]] forState:UIControlStateNormal];
        self.previouseLabel.textColor = [UIColor themeGray];
        buttonLabel.textColor = [UIColor themeBlue];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-pressed",_imageNameArray[button.tag]]] forState:UIControlStateNormal];
    }
    if (self.nameArray.count > button.tag) {
        self.searchCategory = self.nameArray[button.tag];
        [self requestPoiInfo:self.centerPoint andKeyWord:self.nameArray[button.tag]];
    }
    self.previouseIconButton = button;
    self.previouseLabel = buttonLabel;
}

- (void)cleanAllAnnotations
{
    [self.mapView removeAnnotations:self.poiAnnotations];
    [self.poiAnnotations removeAllObjects];
}

- (void)requestPoiInfo:(CLLocationCoordinate2D)center andKeyWord:(NSString *)categoryName
{
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    if ([categoryName isEqualToString:@"交通"]) {
        categoryName = @"公交";
    }
    
    AMapPOIKeywordsSearchRequest *requestPoi = [AMapPOIKeywordsSearchRequest new];
    requestPoi.keywords = categoryName;
    requestPoi.location = [AMapGeoPoint locationWithLatitude:self.centerPoint.latitude longitude:self.centerPoint.longitude];
    requestPoi.requireExtension = YES;
    requestPoi.requireSubPOIs = YES;
    requestPoi.cityLimit = YES;
    
    [self.searchApi AMapPOIIDSearch:requestPoi];
}

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
            make.bottom.equalTo(self.view).offset(-43);
        }
        make.top.equalTo(self.naviBar.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    [_mapContainer setBackgroundColor:[UIColor whiteColor]];
    
    
    _mapView = [[MAMapView alloc] init];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = YES;
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.showsUserLocation = NO;
    _mapView.zoomLevel  = 15;
    [_mapContainer addSubview:_mapView];
    [_mapView setBackgroundColor:[UIColor whiteColor]];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.mapContainer);
    }];
    [_mapView setBackgroundColor:[UIColor whiteColor]];
    [_mapView setCenterCoordinate:self.centerPoint];
    
    
//    NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_map_style" ofType:@"data"];
//    if ([stylePath isKindOfClass:[NSString class]]) {
//        NSURL *styleUrl = [NSURL URLWithString:stylePath];
//        if ([styleUrl isKindOfClass: [NSURL class]]) {
//            NSData *dataStype = [NSData dataWithContentsOfFile:styleUrl];
//            if ([dataStype isKindOfClass:[NSData class]]) {
//                _mapView.customMapStyleEnabled = YES;
//                [_mapView setCustomMapStyleWithWebData:dataStype];
//            }
//        }
//    }
    
    [self requestPoiInfo:self.centerPoint andKeyWord:@"交通"];
}

- (void)createMenu
{
    UIApplication *shareApplication = [UIApplication sharedApplication];
    UIAlertController *optionMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString * qqUrlString = [NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to="")&coord_type=1&policy=0",self.centerPoint.latitude,self.centerPoint.longitude];
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        UIAlertAction *qqmapAction = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *qqurl = [NSURL URLWithString:[qqUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            if ([qqurl isKindOfClass:[NSURL class]]) {
                [application openURL:qqurl];
            }
        }];
        
        [optionMenu addAction:qqmapAction];
    }
    
    
    
    NSString * iosMapUrlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&t=0",self.centerPoint.latitude,self.centerPoint.longitude];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        UIAlertAction *iosmapAction = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *iosMapurl = [NSURL URLWithString:[iosMapUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            if ([iosMapurl isKindOfClass:[NSURL class]]) {
                [application openURL:iosMapurl];
            }
        }];
        
        [optionMenu addAction:iosmapAction];
    }

    NSString * googleMapUrlString = [NSString stringWithFormat:@"comgooglemaps://?x-source=app名&x-success=comgooglemaps://&saddr=&daddr=%f,%f&directionsmode=driving",self.centerPoint.latitude,self.centerPoint.longitude];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        UIAlertAction *googlemapAction = [UIAlertAction actionWithTitle:@"Google地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *googleMapurl = [NSURL URLWithString:[googleMapUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            if ([googleMapurl isKindOfClass:[NSURL class]]) {
                [application openURL:googleMapurl];
            }
        }];
        
        [optionMenu addAction:googlemapAction];
    }
    
    if (self.centerPoint.latitude != 0 && self.centerPoint.longitude != 0)
    {
        UIAlertAction *appleAction = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            MKMapItem *mapItemCurrent = [MKMapItem mapItemForCurrentLocation];
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.centerPoint postalAddress:nil]];
            NSDictionary *dictOptions = [NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,@(YES),MKLaunchOptionsShowsTrafficKey,nil];
            
            [MKMapItem openMapsWithItems:@[mapItemCurrent,toLocation] launchOptions:dictOptions];
        }];
   
        [optionMenu addAction:appleAction];
    }
    
    
    NSString * baiduMapUrlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=\("")&mode=driving&coord_type=gcj02",self.centerPoint.latitude,self.centerPoint.longitude];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *baiduMapUrlString = [NSURL URLWithString:[googleMapUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            if ([baiduMapUrlString isKindOfClass:[NSURL class]]) {
                [application openURL:baiduMapUrlString];
            }
        }];
        
        [optionMenu addAction:baiduAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [optionMenu addAction:cancelAction];

    
    [self presentViewController:optionMenu animated:YES completion:nil];

}

- (void)setUpAnnotations
{
    FHMyMAAnnotation *userAnna = [[FHMyMAAnnotation alloc] init];
    userAnna.type = @"user";
    userAnna.coordinate = self.centerPoint;
    [self.mapView addAnnotation:userAnna];
    
    for (NSInteger i = 0; i < self.poiAnnotations.count; i++) {
        [self.mapView addAnnotation:self.poiAnnotations[i]];
    }
    _mapView.zoomLevel  = 15;
    [self.mapView setCenterCoordinate:self.centerPoint];
}

#pragma poi Delegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self cleanAllAnnotations];
    
    if (response.count == 0) {
        [[ToastManager manager] showToast:@"暂无相关信息"];
        [self.mapView setCenterCoordinate:self.centerPoint];
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
    
    [self setUpAnnotations];
}

- (UIImage *)getIconImageFromCategory:(NSString *)category
{
    if ([self.nameArray containsObject:category]) {
        NSInteger indexValue = [self.nameArray indexOfObject:category];
        UIImage *image = [UIImage imageNamed:self.iconImageArray[indexValue]];
        return image;
    }else
    {
        return [UIImage imageNamed:@"icon-location"];
    }
}

#pragma MapViewDelegata

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[FHMyMAAnnotation class]]) {
        NSString *pointResueseIdetifier = @"pointReuseIndetifier";
        MAAnnotationView *annotationV = [mapView dequeueReusableAnnotationViewWithIdentifier:pointResueseIdetifier];
        if (annotationV == nil) {
            annotationV = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointResueseIdetifier];
        }
        
        annotationV.image = [self getIconImageFromCategory:((FHMyMAAnnotation *)annotation).type];
        annotationV.centerOffset = CGPointMake(0, -18);
        annotationV.canShowCallout = true;
        
        return annotationV ? annotationV : [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
    }
    
    return [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}


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
