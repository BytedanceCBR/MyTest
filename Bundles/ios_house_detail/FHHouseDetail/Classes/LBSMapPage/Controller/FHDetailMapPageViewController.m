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

#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "FHEnvContext.h"
#import "UIViewController+Track.h"
#import "FHEnvContext.h"
#import "HMDTTMonitor.h"
#import "FHMyMAAnnotation.h"
#import "FHDetailMapView.h"
#import "FHFakeInputNavbar.h"
#import "UIImage+FIconFont.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import "TTReachability.h"
#import "FHOldDetailStaticMapCell.h"

static NSInteger const kBottomBarTagValue = 100;
static NSInteger const kBottomButtonLabelTagValue = 1000;
static NSInteger const kBottomButtonIndicatorTagValue = 10000;

static MAMapView *kFHPageMapView = nil;

@interface FHDetailMapPageViewController () <TTRouteInitializeProtocol,AMapSearchDelegate,MAMapViewDelegate>

@property (nonatomic, strong) FHDetailMapPageNaviBarView *naviBar;
@property (nonatomic, weak) MAMapView *mapView;
@property (nonnull, strong) UIView *mapContainer;
@property (nonatomic, strong) UIView * bottomBarView;
@property (nonatomic, strong) UIButton * previouseIndicator;
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
@property (nonatomic , strong) FHMyMAAnnotation *pointCenterAnnotation;
@property (nonatomic , strong) MACircle *locationCircle;
@property (nonatomic , strong) NSString *titleStr;
@property (nonatomic, weak)     UIScrollView       *bottomScrollView;
@property (nonatomic, copy) NSString *baiduPanoramaUrl;
@property (nonatomic , strong) FHMyMAAnnotation *baiduPanoAnnotation;
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
        
        if ([paramObj.allParams objectForKey:@"latitude"] && [paramObj.allParams objectForKey:@"longitude"]) {
            self.centerPoint = CLLocationCoordinate2DMake([[paramObj.allParams objectForKey:@"latitude"] floatValue], [[paramObj.allParams objectForKey:@"longitude"] floatValue]);
        }
        
        if ([[userInfo.allInfo objectForKey:@"category"] isKindOfClass:[NSString class]]) {
            self.searchCategory = [userInfo.allInfo objectForKey:@"category"];
        }
        
        if ([[userInfo.allInfo objectForKey:@"title"] isKindOfClass:[NSString class]]) {
            self.titleStr = [userInfo.allInfo objectForKey:@"title"];
        }
        
        if (paramObj.allParams[@"baiduPanoramaUrl"]) {
            self.baiduPanoramaUrl = [paramObj.allParams btd_stringValueForKey:@"baiduPanoramaUrl"];
        }
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nameArray = [NSArray arrayWithObjects:@"交通",@"教育",@"医疗",@"生活",@"休闲", nil];
    _imageNameArray = [NSArray arrayWithObjects:@"tab-bank",@"tab-bus",@"tab-subway",@"tab-education",@"tab-hospital",@"tab-relaxation",@"tab-mall",@"tab-swim",@"tab-food", nil];
    _keyWordArray = [NSArray arrayWithObjects:@"bank",@"bus",@"subway",@"scholl",@"hospital",@"entertainment",@"shopping",@"gym",@"food", nil];
    _iconImageArray = [NSArray arrayWithObjects:@"icon-bank",@"icon-bus",@"icon-subway",@"icon_education",@"icon_hospital",@"icon-relaxation",@"icon-mall",@"icon_swim",@"icon-restaurant", nil];
    
    //修复外部没有传入searchCategory的情况下
    if (!self.searchCategory.length) {
        self.searchCategory = self.nameArray.firstObject;
    }
    //修复index越界的情况
    if ([self.nameArray indexOfObject:self.searchCategory] < self.nameArray.count) {
        self.selectedIndex = [self.nameArray indexOfObject:self.searchCategory];
    }
    
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
    _naviBar = [[FHDetailMapPageNaviBarView alloc] init];
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
    CGFloat bottomBarHeight = 44;
    [_bottomBarView setBackgroundColor:[UIColor whiteColor]];
    
    [_bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
//        if ([TTDeviceHelper isIPhoneXDevice]) {
//            make.top.equalTo(self.naviBar.mas_bottom);
//        }else
//        {
//            make.bottom.equalTo(self.view);
//        }
        make.top.equalTo(self.naviBar.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(bottomBarHeight);
        make.left.right.equalTo(self.view);
    }];
    
    
    UIScrollView *scrollViewItem = [[UIScrollView alloc] init];
    scrollViewItem.tag = kBottomBarTagValue;
    [_bottomBarView addSubview:scrollViewItem];
    self.bottomScrollView = scrollViewItem;
    
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width / 5;
    scrollViewItem.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, bottomBarHeight);
    scrollViewItem.contentSize = CGSizeMake(itemWidth * [_nameArray count], bottomBarHeight);
    scrollViewItem.showsVerticalScrollIndicator = NO;
    scrollViewItem.showsHorizontalScrollIndicator = NO;
    
    for (int i = 0; i < [_nameArray count]; i++) {
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth * i, 0, itemWidth, scrollViewItem.contentSize.height)];
        [scrollViewItem addSubview:iconView];

        UIButton *buttonIcon = [UIButton buttonWithType:UIButtonTypeCustom];
//        if (i == self.selectedIndex) {
//            NSString *stringName = [NSString stringWithFormat:@"%@-pressed",_imageNameArray[i]];
//            [buttonIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-pressed",_imageNameArray[i]]] forState:UIControlStateNormal];
//            self.previouseIconButton = buttonIcon;
//        }else
//        {
//        [buttonIcon setImage:[UIImage imageNamed:_imageNameArray[i]] forState:UIControlStateNormal];
//        }
        [buttonIcon addTarget:self action:@selector(typeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        buttonIcon.tag = i;
        [buttonIcon setFrame:CGRectMake((itemWidth - 32) / 2, 0, 32, 32)];

        
        UILabel *buttonLabel = [UILabel new];
        buttonLabel.text = _nameArray[i];
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.textColor = [UIColor themeGray1];

  

        buttonLabel.tag = i + kBottomButtonLabelTagValue;
        [buttonLabel setFrame:CGRectMake(0, 11, itemWidth, 22)];
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        [iconView addSubview:buttonLabel];
        
        
        UIView *selectIndicator = [[UIView alloc] initWithFrame:CGRectMake((itemWidth - 20)/2,buttonLabel.frame.origin.y + buttonLabel.frame.size.height + 3, 20, 4)];
        [selectIndicator setBackgroundColor:[UIColor colorWithHexStr:@"#ff9629"]];
        selectIndicator.layer.masksToBounds = YES;
        selectIndicator.layer.cornerRadius = 2;
        selectIndicator.tag = i + kBottomButtonIndicatorTagValue;
        [iconView addSubview:selectIndicator];
        
        if (i == self.selectedIndex) {
              self.previouseLabel = buttonLabel;
              self.previouseIndicator = selectIndicator;
              buttonLabel.font = [UIFont themeFontMedium:16];
              selectIndicator.hidden = NO;
        }else{
              buttonLabel.font = [UIFont themeFontRegular:16];
              selectIndicator.hidden = YES;
        }

        
        [iconView addSubview:buttonIcon];
    }
    [self changeBottomItemViewOffsetByIndex:self.selectedIndex];
    self.searchCategory = self.nameArray[self.selectedIndex];
}

- (void)changeBottomItemViewOffsetByIndex:(NSInteger)selectIndex {
    if (selectIndex < 0) {
        return;
    }
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width / 6.5;
    NSInteger currentIndex = selectIndex;
    CGFloat winWidth = [UIScreen mainScreen].bounds.size.width;
    // +2 后一个是否也没显示完全，显示出来方便点击（+1也可）
    if ((currentIndex + 2) * itemWidth > winWidth ) {
        NSInteger namesCount = self.nameArray.count;
        if (currentIndex < namesCount - 1) {
            // 说明后面还有内容可显示
            [self.bottomScrollView setContentOffset:CGPointMake((currentIndex + 2) * itemWidth - winWidth, 0) animated:YES];
        } else {
            [self.bottomScrollView setContentOffset:CGPointMake((currentIndex + 1) * itemWidth - winWidth, 0) animated:YES];
        }
    } else {
        CGFloat offsetX = self.bottomScrollView.contentOffset.x;
        // 前一个是否也没显示完全，显示出来方便点击
        if ((currentIndex - 1) * itemWidth < offsetX) {
            if (currentIndex == 0) {
                [self.bottomScrollView setContentOffset:CGPointMake(currentIndex * itemWidth, 0) animated:YES];
            } else {
                [self.bottomScrollView setContentOffset:CGPointMake((currentIndex - 1) * itemWidth, 0) animated:YES];
            }
        }
    }
}

- (UILabel *)getLabelFromTag:(NSInteger)index
{
    UIView *scrollContent = [_bottomBarView viewWithTag:kBottomBarTagValue];
    UILabel *buttonLabel = (UILabel *)[scrollContent viewWithTag:index + kBottomButtonLabelTagValue];
    return buttonLabel;
}

- (UIView *)getIndicatorFromTag:(NSInteger)index
{
    UIView *scrollContent = [_bottomBarView viewWithTag:kBottomBarTagValue];
    UIView *buttonLabel = [scrollContent viewWithTag:index + kBottomButtonIndicatorTagValue];
    return buttonLabel;
}

- (void)typeButtonClick:(UIButton *)button
{
    UILabel *buttonLabel = [self getLabelFromTag:button.tag];
    UIView *indicatorView = [self getIndicatorFromTag:button.tag];
    self.previouseIndicator.hidden = YES;
    self.previouseLabel.font = [UIFont themeFontRegular:16];

    if (button.tag < [_imageNameArray count] && indicatorView) {
        indicatorView.hidden = NO;
        buttonLabel.font = [UIFont themeFontMedium:16];
    }
    if (self.nameArray.count > button.tag) {
        NSString *category = self.nameArray[button.tag];
        if (![category isEqualToString:self.searchCategory]) {
            self.searchCategory = category;
            [self requestPoiInfo:self.centerPoint andKeyWord:[FHOldDetailStaticMapCell keyWordConver:self.nameArray[button.tag]]];
        }
    }
    [self changeBottomItemViewOffsetByIndex:button.tag];
    self.previouseIndicator = indicatorView;
    self.previouseLabel = buttonLabel;
}

- (void)cleanAllAnnotations
{
    [self.mapView removeAnnotation:self.pointCenterAnnotation];
    [self.mapView removeAnnotation:self.baiduPanoAnnotation];
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
    
    AMapPOIAroundSearchRequest *requestPoi = [AMapPOIAroundSearchRequest new];
    requestPoi.keywords = categoryName;
    requestPoi.location = [AMapGeoPoint locationWithLatitude:self.centerPoint.latitude longitude:self.centerPoint.longitude];
    requestPoi.requireExtension = YES;
    requestPoi.requireSubPOIs = YES;
//    requestPoi.cityLimit = YES;
    requestPoi.radius = 2000;
    
    [self.searchApi AMapPOIIDSearch:requestPoi];
}

- (void)setUpMapView
{
    _mapContainer = [UIView new];
    [self.view addSubview:_mapContainer];
    [_mapContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//        if ([TTDeviceHelper isIPhoneXDevice]) {
//            make.bottom.equalTo(self.view).offset(-40);
//        }else
//        {
//            make.bottom.equalTo(self.view).offset(0);
//        }
        make.bottom.equalTo(self.view).offset(0);
        make.top.equalTo(self.naviBar.mas_bottom).offset(44);
        make.left.right.equalTo(self.view);
    }];
    [_mapContainer setBackgroundColor:[UIColor whiteColor]];
    
    // mapFrame 暂时没有用到
    CGFloat navHeight = [FHFakeInputNavbar perferredHeight];
    CGFloat bottomHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        bottomHeight = 83;
    } else {
        bottomHeight = 43;
    }
    CGRect mapFrame = CGRectMake(0, bottomHeight, self.view.width, self.view.height - navHeight - bottomHeight);
    if (!kFHPageMapView) {
        kFHPageMapView = [[MAMapView alloc] initWithFrame:mapFrame];// 不会同时出两个页面

        //设置地图style
        NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_house_detail_style.data" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:stylePath];
        NSString *extraPath = [[NSBundle mainBundle] pathForResource:@"gaode_house_detail_style_extra.data" ofType:nil];
        NSData *extraData = [NSData dataWithContentsOfFile:extraPath];
        MAMapCustomStyleOptions *options = [MAMapCustomStyleOptions new];
        options.styleData = data;
        options.styleExtraData = extraData;
        [kFHPageMapView setCustomMapStyleOptions:options];
        [kFHPageMapView setCustomMapStyleEnabled:YES];

        kFHPageMapView.zoomLevel  = 18;
        [kFHPageMapView setCenterCoordinate:self.centerPoint];
    }
    _mapView = kFHPageMapView;
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = YES;
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.showsUserLocation = NO;
    _mapView.rotateCameraEnabled = NO;
    _mapView.rotateEnabled = NO;
    [_mapView setCenterCoordinate:self.centerPoint];
    [_mapContainer addSubview:_mapView];
    [_mapView setBackgroundColor:[UIColor whiteColor]];
    [_mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.mapContainer);
    }];
    [_mapView setBackgroundColor:[UIColor whiteColor]];
    
    
    [self requestPoiInfo:self.centerPoint andKeyWord:self.searchCategory];
}

- (void)dealloc
{
    [self cleanAllAnnotations];
    if (self.locationCircle) {
        [self.mapView removeOverlay:self.locationCircle];
    }
    [_mapView removeFromSuperview];
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
            MKPlacemark *placeMark = nil;
            if (@available(iOS 10.0 , *)) {
                placeMark = [[MKPlacemark alloc] initWithCoordinate:self.centerPoint postalAddress:nil];
            }else
            {
                placeMark = [[MKPlacemark alloc] initWithCoordinate:self.centerPoint addressDictionary:nil];
            }
            
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placeMark];
            NSDictionary *dictOptions = [NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,@(YES),MKLaunchOptionsShowsTrafficKey,nil];
            
            [MKMapItem openMapsWithItems:@[mapItemCurrent,toLocation] launchOptions:dictOptions];
        }];
   
        [optionMenu addAction:appleAction];
    }
    
    
    NSString * baiduMapUrlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=\("")&mode=driving&coord_type=gcj02",self.centerPoint.latitude,self.centerPoint.longitude];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stringEncode = [baiduMapUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURL *baiduMapUrl = [NSURL URLWithString:stringEncode];
            if ([baiduMapUrl isKindOfClass:[NSURL class]]) {
                [application openURL:baiduMapUrl];
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
    for (NSInteger i = 0; i < self.poiAnnotations.count; i++) {
        [self.mapView addAnnotation:self.poiAnnotations[i]];
    }
    
    FHMyMAAnnotation *userAnna = [[FHMyMAAnnotation alloc] init];
    userAnna.type = @"user";
    userAnna.coordinate = self.centerPoint;
    
    userAnna.title = self.titleStr;
    
    [self.mapView addAnnotation:userAnna];
    self.pointCenterAnnotation = userAnna;
    
    if (self.baiduPanoramaUrl.length) {
        FHMyMAAnnotation *baiduPanoAnnotation = [[FHMyMAAnnotation alloc] init];
        baiduPanoAnnotation.type = @"baiduPano";
        baiduPanoAnnotation.coordinate = self.centerPoint;
        [self.mapView addAnnotation:baiduPanoAnnotation];
        self.baiduPanoAnnotation = baiduPanoAnnotation;
    }
    
    NSLog(@"self.baiduPanoramaUrl=%@",self.baiduPanoramaUrl);
    
    
    // PM 确认 不进行缩放
//    [self.mapView showAnnotations:self.mapView.annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:NO];
}

#pragma poi Delegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    AMapPOIAroundSearchRequest *searchReqeust = (AMapPOIAroundSearchRequest *)request;
    if (![searchReqeust isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        [[ToastManager manager] showToast:@"暂无相关信息"];
        [self.mapView setCenterCoordinate:self.centerPoint];
        return;
    }
    NSString *keyWords =[FHOldDetailStaticMapCell keyWordConverReverse:searchReqeust.keywords];
    if (keyWords.length <= 0) {
        [[ToastManager manager] showToast:@"暂无相关信息"];
        [self.mapView setCenterCoordinate:self.centerPoint];
        return;
    }
    NSInteger index = [self.nameArray indexOfObject:keyWords];
    if (index < 0 || index >= self.nameArray.count) {
        [[ToastManager manager] showToast:@"暂无相关信息"];
        [self.mapView setCenterCoordinate:self.centerPoint];
        return;
    }
    if (![self.searchCategory isEqualToString:keyWords]) {
        return;
    }
    
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
    self.mapView.zoomLevel  = 14;
    [self.mapView setCenterCoordinate:self.centerPoint];
    if (!self.locationCircle && self.centerPoint.latitude > 0 && self.centerPoint.longitude > 0) {
        MACircle *circle = [MACircle circleWithCenterCoordinate:self.centerPoint radius:1000];
        [_mapView addOverlay:circle];
        self.locationCircle = circle;
    }
}

- (UIImage *)getIconImageFromCategory:(NSString *)category
{
    if ([self.nameArray containsObject:category]) {
        if ([category isEqualToString:@"教育"]) {
            return [UIImage imageNamed:@"map_detail_education"];
        }
        if ([category isEqualToString:@"医疗"]) {
            return [UIImage imageNamed:@"map_detail_hospital"];
        }
        if ([category isEqualToString:@"交通"]) {
            return [UIImage imageNamed:@"map_detail_traffic"];
        }
        
        if ([category isEqualToString:@"生活"]) {
            return [UIImage imageNamed:@"map_detail_life"];
        }
        if ([category isEqualToString:@"休闲"]) {
            return [UIImage imageNamed:@"map_detail_play"];
        }
        NSInteger indexValue = [self.nameArray indexOfObject:category];
        UIImage *image = [UIImage imageNamed:self.iconImageArray[indexValue]];
        return image;
    } else if ([category isEqualToString:@"baiduPano"]) {
        UIImage *image = [UIImage imageNamed:@"baidu_panorama_entrance_icon"];
        return image;
    } else {
        return [UIImage imageNamed:@"detail_map_loc_annotation"];
    }
}

- (void)pushBaiduPano {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

    if (CLLocationCoordinate2DIsValid(self.centerPoint)) {
        NSMutableDictionary *tracerDict = self.traceDict.mutableCopy;
        tracerDict[@"element_from"] = @"map";
        NSMutableDictionary *param = [NSMutableDictionary new];
        param[TRACER_KEY] = tracerDict.copy;
        param[@"gaodeLat"] = [@(self.centerPoint.latitude) stringValue];
        param[@"gaodeLon"] = [@(self.centerPoint.longitude) stringValue];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
    }
}

#pragma MapViewDelegata

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[FHMyMAAnnotation class]]) {
        MAAnnotationView *annotationV = nil;
        if ([[(FHMyMAAnnotation *)annotation type] isEqualToString:@"baiduPano"]) {
            NSString *pointResueseIdetifier = @"pointReuseIndetifier";
            annotationV = [mapView dequeueReusableAnnotationViewWithIdentifier:pointResueseIdetifier];
            if (annotationV == nil) {
                annotationV = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointResueseIdetifier];
            }
            
            annotationV.centerOffset = CGPointMake(0, -50);
            annotationV.canShowCallout = NO;
            annotationV.image = [self getIconImageFromCategory:@"baiduPano"];
            [annotationV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushBaiduPano)]];
            annotationV.zIndex = 101;

        }else if ([[(FHMyMAAnnotation *)annotation type] isEqualToString:@"user"]){
            NSString *pointResueseIdetifier = @"pointReuseIndetifierUser";
                     annotationV = [mapView dequeueReusableAnnotationViewWithIdentifier:pointResueseIdetifier];
             if (annotationV == nil) {
                 annotationV = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointResueseIdetifier];
             }
            annotationV.image = [self getIconImageFromCategory:@"user"];
            annotationV.centerOffset = CGPointMake(0, -10);
            annotationV.zIndex = 100;
        }else {
            
           NSString *reuseIdentifier = @"poi_annotation";
           MAAnnotationView *annotationView = (MAAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
           if (!annotationView) {
               annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
           }
            

           UIImageView *backImageView = [UIImageView new];
           [annotationView addSubview:backImageView];
            
            UIImageView *leftIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_detail_play"]];
                   [annotationView addSubview:leftIcon];
            leftIcon.image = [self getIconImageFromCategory:((FHMyMAAnnotation *)annotation).type];

            leftIcon.backgroundColor = [UIColor clearColor];
            leftIcon.frame = CGRectMake(11, 10.5, 11, 11);
            
            [annotationView addSubview:leftIcon];

           UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 100, 30)];
           titleLabel.text = annotation.title;
           titleLabel.frame = CGRectMake(0, 0, titleLabel.text.length * 13, 32);
           backImageView.frame = CGRectMake(0, 0, titleLabel.text.length * 13 + 20, 30);

//           UIImage *imageAnna = [UIImage imageNamed:@"mapsearch_detail_annotation_bg"];//mapsearch_annotation_bg
//
//           CGFloat width = imageAnna.size.width > 0 ? imageAnna.size.width : 10;
//           CGFloat height = imageAnna.size.height > 0 ? imageAnna.size.height : 10;
//
//           imageAnna = [imageAnna resizableImageWithCapInsets:UIEdgeInsetsMake(height / 2.0, width / 2.0, height / 2.0, width / 2.0) resizingMode:UIImageResizingModeStretch];
//           backImageView.image = imageAnna;

           backImageView.layer.cornerRadius = 15;
           backImageView.layer.masksToBounds = YES;

           [annotationView addSubview:titleLabel];
           titleLabel.font = [UIFont themeFontRegular:12];
           titleLabel.textColor = [UIColor whiteColor];
           titleLabel.layer.masksToBounds = YES;

           titleLabel.numberOfLines = 1;
           titleLabel.textAlignment = NSTextAlignmentCenter;
           titleLabel.backgroundColor = [UIColor clearColor];
           [titleLabel sizeToFit];
           backImageView.frame = CGRectMake(0, 0, titleLabel.frame.size.width + 60, 30);
           [backImageView setBackgroundColor:[UIColor colorWithHexStr:@"#ff9629"]];
           titleLabel.center = CGPointMake(backImageView.center.x, backImageView.center.y);

           UIImageView *bottomArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapsearch_annotation_arrow"]];
           [annotationView addSubview:bottomArrowView];
           bottomArrowView.backgroundColor = [UIColor clearColor];
           bottomArrowView.frame = CGRectMake(backImageView.frame.size.width / 2.0 - 5, backImageView.frame.size.height - 5.5, 10.5, 10.5);
           annotationView.centerOffset = CGPointMake(-backImageView.frame.size.width / 2.0, -40);
           return annotationView;
//            annotationV.centerOffset = CGPointMake(0, -10);
//            annotationV.canShowCallout = YES;
//            annotationV.selected = YES;
//            if (annotationV.gestureRecognizers.count) {
//                for (UIGestureRecognizer *gesture in annotationV.gestureRecognizers) {
//                    [annotationV removeGestureRecognizer:gesture];
//                }
//            }
        }
        
        return annotationV ? annotationV : [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
    }
    
    return [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    
    if ([overlay isKindOfClass:[MACircle class]]) {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth    = 0.0f;
        circleRenderer.strokeColor  = [UIColor clearColor];
        circleRenderer.fillColor    = [UIColor colorWithRed:255/255.0 green:88/255.0 blue:105/255.0 alpha:0.2];
        return circleRenderer;
    }
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

@end
