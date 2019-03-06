//
//  FHMapSearchViewModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchViewModel.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <UIViewAdditions.h>
#import "FHHouseType.h"
#import "TTNetworkManager.h"
#import "FHMapSearchTypes.h"
#import "FHNeighborhoodAnnotationView.h"
#import "FHDistrictAreaAnnotationView.h"
#import "FHHouseAnnotation.h"
#import "FHMapSearchViewModel.h"
#import "FHMapSearchViewController.h"
#import "FHMapSearchHouseListViewController.h"
#import "FHHouseSearcher.h"
#import <TTRoute/TTRoute.h>
#import <TTReachability.h>
#import "FHMainManager+Toast.h"
#import "FHUserTracker.h"
#import "FHMapSearchBubbleModel.h"
#import "UIColor+Theme.h"
#import "FHHouseRentModel.h"

#define kTipDuration 3

typedef NS_ENUM(NSInteger , FHMapZoomTrigerType) {
    FHMapZoomTrigerTypeZoomMap = 0,// 缩放地图
    FHMapZoomTrigerTypeClickAnnotation , //点击气泡
    FHMapZoomTrigerTypeDefault ,//进入时设置
};

typedef NS_ENUM(NSInteger , FHMapZoomViewLevelType) {
    FHMapZoomViewLevelTypeArea = 0 , // 区域视野
    FHMapZoomViewLevelTypeDistrict = 1 , // 商圈视野
    FHMapZoomViewLevelTypeNeighborhood = 2 , // 小区视野
};


@interface FHMapSearchViewModel ()

@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , assign) NSInteger requestMapLevel;
@property(nonatomic , weak)  TTHttpTask *requestHouseTask;
@property(nonatomic , strong) FHMapSearchHouseListViewController *houseListViewController;

@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) NSString *houseTypeName;
@property(nonatomic , weak) FHHouseAnnotation *currentSelectAnnotation;
@property(nonatomic , strong) FHMapSearchDataListModel *currentSelectHouseData;
@property(nonatomic , strong) NSMutableDictionary<NSString * , NSString *> *selectedAnnotations;
@property(nonatomic , assign) NSTimeInterval startShowTimestamp;
@property(nonatomic , assign) CGFloat lastRecordZoomLevel; //for statistics
@property(nonatomic , assign) CLLocationCoordinate2D lastRequestCenter;
@property(nonatomic , assign) BOOL firstEnterLogAdded;
@property(nonatomic , assign) BOOL needReload;
@property(nonatomic , copy) NSString *houseListOpenUrl;//返回列表页时的openurl
//@property(nonatomic , copy) NSString *mapFindHouseOpenUrl;
@property(nonatomic , strong) FHMapSearchBubbleModel *lastBubble;
@property(nonatomic , assign) BOOL movingToCenter;
@property(nonatomic , assign) BOOL configUserLocationLayer;
@property(nonatomic , assign) BOOL mapViewRegionSuccess;

@end

@implementation FHMapSearchViewModel

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel viewController:(FHMapSearchViewController *)viewController
{
    self = [super init];
    if (self) {
        self.configModel = configModel;
        
        self.viewController = viewController;
        _showMode = FHMapSearchShowModeMap;
        _selectedAnnotations = [NSMutableDictionary new];
        _lastRecordZoomLevel = configModel.resizeLevel;
        
        if (self.configModel.mapOpenUrl) {
            //            _lastBubble = [FHMapSearchBubbleModel bubbleFromUrl:self.configModel.mapOpenUrl];
            dispatch_async(dispatch_get_main_queue(), ^{                
                [self updateBubble:self.configModel.mapOpenUrl];
                if (_lastBubble) {
                    if (_lastBubble.resizeLevel > 1) {
                        _configModel.resizeLevel = _lastBubble.resizeLevel;
                    }
                    _configModel.centerLatitude = [@(_lastBubble.centerLatitude) description];
                    _configModel.centerLongitude = [@(_lastBubble.centerLongitude) description];
                    
                    _configModel.houseType = _lastBubble.houseType;
                }
            });
        }
        if ([_configModel.centerLatitude floatValue] < 1 || [_configModel.centerLongitude floatValue] < 1) {
            CLLocationCoordinate2D location = [[FHMainManager sharedInstance] currentLocation];
            if (location.latitude > 0 && location.longitude > 0) {
                _configModel.centerLatitude = [@(location.latitude) description];
                _configModel.centerLongitude = [@(location.longitude) description];
                _lastBubble.centerLongitude = location.longitude;
                _lastBubble.centerLatitude = location.latitude;
            }
        }
        
        if (![TTReachability isNetworkConnected]) {
            _configModel.resizeLevel = 10;
            _lastBubble.resizeLevel = 10;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.configModel.searchId = nil;
        
        NSString *title = @"二手房";
        switch (configModel.houseType) {
            case FHHouseTypeNewHouse:{
                title = @"新房";
                break;
            }
            case FHHouseTypeNeighborhood:{
                title = @"小区";
                break;
            }
            case FHHouseTypeRentHouse:{
                title = @"租房";
            }
                break;
            default:
                break;
        }
        self.houseTypeName = title;
        
        
//        if (self.configModel.originSearchId.length == 0 || [self.configModel.originSearchId isEqualToString:@"be_null"]) {
//            //从租房或者city market 进入时没有origin search id 使用map search返回的search id
//            self.configModel.originSearchId = nil;
//        }else{
//            [self addEnterMapLog];
//        }
        
        
    }
    return self;
}

-(void)dealloc
{
    [_requestHouseTask cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

-(MAMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:CGRectZero];
        _mapView.rotateEnabled = false;
        _mapView.showsUserLocation = false;
        _mapView.showsCompass = false;
        _mapView.showsIndoorMap = false;
        _mapView.showsIndoorMapControl = false;
        _mapView.rotateCameraEnabled = false;
        _mapView.delegate = self;
        _mapView.customizeUserLocationAccuracyCircleRepresentation = true;
        _mapView.runLoopMode = NSDefaultRunLoopMode;
        _mapView.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        _mapView.zoomLevel = _configModel.resizeLevel;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
        representation.showsAccuracyRing = YES;
        [_mapView updateUserLocationRepresentation:representation];
        
        CLLocationCoordinate2D center = {_configModel.centerLatitude.floatValue,_configModel.centerLongitude.floatValue};
        if (_lastBubble) {
            center = CLLocationCoordinate2DMake(_lastBubble.centerLatitude, _lastBubble.centerLongitude);
        }
        if (center.latitude > 0 && center.longitude > 0) {
            [_mapView setCenterCoordinate:center animated:NO];
        }
        
//        MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
//        r.showsHeadingIndicator = NO;///是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
//        r.fillColor = RGBA(0x29, 0x9c, 0xff, 0.3);///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
//        r.strokeColor = r.fillColor;
//        r.lineWidth = 1;///精度圈 边线宽度，默认0
//        r.locationDotBgColor = [UIColor clearColor];///定位点背景色，不设置默认白色
//        r.locationDotFillColor = [UIColor themeRed1];///定位点蓝色圆点颜色，不设置默认蓝色
//        UIImage *image = [UIImage imageNamed:@"mapsearch_location_center"];
//        r.image = image;
//        [_mapView updateUserLocationRepresentation:r];
        
        
//        NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_map_style.data" ofType:nil];
//        NSData *styleData = [NSData dataWithContentsOfFile:stylePath];
//        if (styleData) {
//            _mapView.customMapStyleEnabled = YES;
//            [_mapView setCustomMapStyleWithWebData:styleData];
//        }
    }
    return _mapView;
}

-(void)showMapUserLocationLayer
{
    if (_configUserLocationLayer) {
        return;
    }
    
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    r.showsHeadingIndicator = NO;///是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
    r.fillColor = [[UIColor themeRed1] colorWithAlphaComponent:0.3];///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
//    r.strokeColor = r.fillColor;
//    r.lineWidth = 1;///精度圈 边线宽度，默认0
    r.locationDotBgColor = [UIColor clearColor];///定位点背景色，不设置默认白色
    r.locationDotFillColor = [UIColor themeRed1];///定位点蓝色圆点颜色，不设置默认蓝色
    UIImage *image = [UIImage imageNamed:@"mapsearch_location_center"];
    r.image = image;
    [self.mapView updateUserLocationRepresentation:r];
    
    _configUserLocationLayer = YES;
}

-(void)moveToUserLocation
{
    MAUserLocation *location =  self.mapView.userLocation;
    if (location.location) {
        CGFloat zoom = self.mapView.zoomLevel;
        CGFloat dstZoom = 17;
        [self.mapView setZoomLevel:dstZoom animated:NO];//变化到小区的范围
        _lastBubble.resizeLevel = dstZoom;
        if (fabs(zoom - dstZoom) > 1 && ![self shouldRequest:location.location.coordinate]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestHouses:NO showTip:NO];
            });
        }else{
            _movingToCenter = YES;
        }
        [self.mapView setCenterCoordinate:location.location.coordinate animated:YES];
    }
}

-(void)changeNavbarAppear:(BOOL)show
{
    [self.viewController showNavTopViews:show?1:0 animated:YES];
}

-(void)changeNavbarAlpha:(BOOL)animated
{
    CGFloat alpha = 1 - (self.houseListViewController.view.top - [self.houseListViewController minTop])/(([self.houseListViewController initialTop] - [self.houseListViewController minTop])/2);
    if (alpha < 0) {
        alpha = 0;
    }else if (alpha > 1){
        alpha = 1;
    }
    [self.viewController showNavTopViews:alpha animated:animated];
    
}

//-(BOOL)conditionChanged
//{
//    return ![_originCondition isEqualToString: _configModel.conditionQuery];
//}

-(void)setFilterConditionParams:(NSString *)filterConditionParams
{
    _configModel.conditionQuery = filterConditionParams;
}

-(NSString *)filterConditionParams
{
    return _configModel.conditionQuery;
}

-(FHMapSearchConfigModel *)configModel
{
    return _configModel;
}

-(FHMapSearchHouseListViewController *)houseListViewController
{
    if (!_houseListViewController) {
        _houseListViewController = [[FHMapSearchHouseListViewController alloc]init];
        [self.viewController addChildViewController:_houseListViewController];
        _houseListViewController.view.frame = CGRectMake(0, 0, self.viewController.view.width, [self.viewController contentViewHeight]);
        [self.viewController insertHouseListView:_houseListViewController.view];
        
        _houseListViewController.view.hidden = YES;
        /*
         * TTNavigationcontroller 会设置view的subview中scrollview的 contentinset 和 offset
         */
        [_houseListViewController resetScrollViewInsetsAndOffsets];
        
        __weak typeof(self) wself = self;
        _houseListViewController.willSwipeDownDismiss = ^(CGFloat duration) {
            if (wself) {
                [wself changeNavbarAppear:YES];
                wself.showMode = FHMapSearchShowModeMap;
                [wself.viewController switchNavbarMode:FHMapSearchShowModeMap];
                [wself.mapView deselectAnnotation:wself.currentSelectAnnotation animated:YES];
                [wself moveAnnotationToCenter:wself.currentSelectHouseData animated:YES];
                NSString *nid = wself.currentSelectHouseData.nid;
                if (nid.length > 0) {
                    wself.selectedAnnotations[nid] = nid;
                }
                wself.currentSelectAnnotation = nil;
                wself.currentSelectHouseData = nil;
                [wself.mapView becomeFirstResponder];
                [wself checkNeedRequest];
            }
        };
        _houseListViewController.didSwipeDownDismiss = ^{
            if (wself) {
                [wself changeNavbarAppear:YES];
                wself.showMode = FHMapSearchShowModeMap;
            }
        };
        _houseListViewController.moveToTop = ^{
            [wself changeNavbarAppear:YES];
            wself.showMode = FHMapSearchShowModeHouseList;
            [wself.viewController switchNavbarMode:FHMapSearchShowModeHouseList];
        };
        _houseListViewController.moveDock = ^{
            wself.showMode = FHMapSearchShowModeHalfHouseList;
            [wself changeNavbarAlpha:YES];
            NSString *nid = wself.currentSelectHouseData.nid;
            if (nid.length > 0) {
                wself.selectedAnnotations[nid] = nid;
            }
            [wself checkNeedRequest];
        };
        _houseListViewController.movingBlock = ^(CGFloat top) {
            [wself changeNavbarAlpha:NO];
        };
        _houseListViewController.showHouseDetailBlock = ^(FHSearchHouseDataItemsModel * _Nonnull model , NSInteger rank) {
            [wself showHoseDetailPage:model rank:rank];
        };
        
        _houseListViewController.showNeighborhoodDetailBlock = ^(FHMapSearchDataListModel * _Nonnull model) {
            [wself showNeighborhoodDetailPage:model];;
        };
        
        _houseListViewController.showRentHouseDetailBlock = ^(FHHouseRentDataItemsModel * _Nonnull model, NSInteger rank) {
            [wself showRentHouseDetailPage:model rank:rank];
        };
        
        _houseListViewController.viewModel.configModel = self.configModel;
    }
    return _houseListViewController;
}

-(NSString *)navTitle
{
    if (_showMode == FHMapSearchShowModeHouseList) {
        return _currentSelectHouseData.name;
    }
    return _houseTypeName;
}

-(void)showMap
{
    [self.houseListViewController dismiss];
}

-(void)dismissHouseListView
{
    [self.houseListViewController dismiss];
}

-(void)checkNeedRequest
{
    if (self.needReload) {
        [self requestHouses:NO showTip:NO];
        self.needReload = NO;
    }
}

//-(void)mapviewdeltaTest
//{
//    printf("========================\n\n");
//    NSMutableArray *latArray = [NSMutableArray new];
//    NSMutableArray *lonArray = [NSMutableArray new];
//    for (int i = 1; i <= 20; i++) {
//
//        [_mapView setZoomLevel:i animated:NO];
//        MACoordinateRegion region = _mapView.region;
//        [latArray addObject:@(region.span.latitudeDelta)];
//        [lonArray addObject:@(region.span.longitudeDelta)];
//    }
//
//
//    NSMutableString *output = [NSMutableString new];
//    [output appendString:@"NSArray *latDelta = @["];
//    for (NSNumber *num in latArray) {
//
//        [output appendFormat:@"@(%f),",[num floatValue]];
//    }
//    [output appendString:@"];\n"];
//    NSLog(@"\n%@",output);
//
//    output = [NSMutableString new];
//    [output appendString:@"NSArray *longDelta = @["];
//    for (NSNumber *num in lonArray) {
//        [output appendFormat:@"@(%f),",[num floatValue]];
//    }
//    [output appendString:@"];\n"];
//    NSLog(@"\n%@",output);
//    printf("========================\n\n");
//}


-(void)requestHouses:(BOOL)byUser showTip:(BOOL)showTip
{
    if (_requestHouseTask &&  _requestHouseTask.state == TTHttpTaskStateRunning) {
        [_requestHouseTask cancel];
    }
    
    BOOL firstEnter = _firstEnterLogAdded;
    _firstEnterLogAdded = YES;
    
    FHHouseType houseType = self.configModel.houseType;
    if (_lastBubble) {
        houseType = _lastBubble.houseType;
        if (![_lastBubble validResizeLevel]) {
            _lastBubble.resizeLevel = _mapView.zoomLevel;
        }
    }
    
    if (byUser || ![_lastBubble validCenter]) {
        //用户手动操作使用当前地图的数据
        CLLocationCoordinate2D center = _mapView.centerCoordinate;
        [_lastBubble updateResizeLevel:_mapView.zoomLevel centerLatitude:center.latitude centerLongitude:center.longitude];
        _lastRequestCenter = _mapView.centerCoordinate;
    }else{
        _lastRequestCenter = CLLocationCoordinate2DMake(_lastBubble.centerLatitude, _lastBubble.centerLongitude);
    }
        
    MACoordinateRegion region = _mapView.region;
    if (region.span.latitudeDelta == 0 || region.span.longitudeDelta == 0) {
        MACoordinateRegion r = [self.mapView convertRect:self.mapView.bounds toRegionFromView:self.mapView];
        if (r.span.latitudeDelta == 0 || r.span.longitudeDelta == 0) {
            //使用系统查表
            NSArray *latDelta = @[@(101.222778),@(101.222778),@(101.222778),@(53.829353),@(27.212019),
                                  @(13.637097),@(6.822136),@(3.411519),@(1.705816),@(0.852915),
                                  @(0.426458),@(0.213145),@(0.106488),@(0.053159),@(0.026580),
                                  @(0.013882),@(0.006941),@(0.003386),@(0.001693),@(0.000846)];
            NSArray *longDelta = @[@(80.106079),@(80.106079),@(80.106079),@(40.053040),@(20.026438),
                                   @(10.013219),@(5.006551),@(2.503275),@(1.251638),@(0.625819),
                                   @(0.312909),@(0.156393),@(0.078134),@(0.039005),@(0.019503),
                                   @(0.010186),@(0.005093),@(0.002484),@(0.001242),@(0.000621)];
            MACoordinateSpan s ;
            int deltaIndex = floor(self.mapView.zoomLevel) - 1;
            if (deltaIndex < 0) {
                deltaIndex = 0;
            }else if (deltaIndex >= 20){
                deltaIndex = 19;
            }
            s.latitudeDelta = self.mapView.width/375*[latDelta[deltaIndex] floatValue];
            s.longitudeDelta = self.mapView.height/667*[longDelta[deltaIndex] floatValue];
            region.span = s;
            _mapViewRegionSuccess = NO;
        }else{
            _mapViewRegionSuccess = YES;
            region.span =r.span;
        }
        region.center = _lastRequestCenter;
    }else{
        _mapViewRegionSuccess = YES;
    }

    CGFloat maxLat = region.center.latitude + region.span.latitudeDelta/2;
    CGFloat minLat = maxLat - region.span.latitudeDelta;
    CGFloat maxLong = region.center.longitude + region.span.longitudeDelta/2;
    CGFloat minLong = maxLong - region.span.longitudeDelta;
    
    if (minLat < 0  || minLong < 0) {
                        
        maxLat = _lastRequestCenter.latitude + region.span.latitudeDelta/2;
        minLat = maxLat - region.span.latitudeDelta;
        
        maxLong = _lastRequestCenter.longitude + region.span.longitudeDelta/2;
        minLong = maxLong - region.span.longitudeDelta;
    }
    
    
    NSString *query = nil;
    if (self.lastBubble) {
//        self.lastBubble.resizeLevel = self.mapView.zoomLevel;
        query = [self.lastBubble query];
    }else{
        query = self.filterConditionParams;
    }
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher mapSearch:houseType searchId:self.searchId query:query maxLocation:CLLocationCoordinate2DMake(maxLat, maxLong) minLocation:CLLocationCoordinate2DMake(minLat, minLong) resizeLevel:_mapView.zoomLevel suggestionParams:nil callback:^(NSError * _Nullable error, FHMapSearchDataModel * _Nullable model) {
        
        if (!wself) {
            return ;
        }
        if (error) {
            //show toast
            if (error.code != NSURLErrorCancelled) {
                //请求取消
                [[FHMainManager sharedInstance] showToast:@"房源请求失败" duration:2];
            }
            return;
        }
        if (showTip && wself.showMode == FHMapSearchShowModeMap) {
            NSString *tip = model.tips;
            if (tip) {
                CGFloat topY = [wself.viewController topBarBottom];
                [wself.tipView showIn:wself.viewController.view at:CGPointMake(0, topY) content:tip duration:kTipDuration above:self.mapView];
            }
        }
        wself.searchId = model.searchId;
        [wself addAnnotations:model.list];
        wself.houseListOpenUrl = model.houseListOpenUrl;
        if (!wself.configModel.searchId) {
            //first time
            wself.configModel.searchId = model.searchId;
            if (wself.configModel.originSearchId.length == 0 || [wself.configModel.originSearchId isEqualToString:@"be_null"]) {
                wself.configModel.originSearchId = model.searchId;
            }
            [wself addEnterMapSearchLog];
        }
        
        //for enter default log
        if (!firstEnter) {
            [wself addEnterMapLog];
        }
        
        //handle open url
        [wself updateBubble:model.mapFindHouseOpenUrl];
    }];
    _requestMapLevel = _mapView.zoomLevel;
    _requestHouseTask = task;

}

-(void)addAnnotations:(NSArray *)list
{
    if (list.count > 0) {
        NSArray *cAnnotations = self.mapView.annotations;
        NSMutableDictionary *removeAnnotationDict = [[NSMutableDictionary alloc] initWithCapacity:cAnnotations.count];
        for (NSInteger i = 0 ; i < cAnnotations.count ;  i++) {
            id <MAAnnotation> annotation = cAnnotations[i];
            if ([annotation isKindOfClass:[FHHouseAnnotation class]]) {
                FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotation;
                removeAnnotationDict[houseAnnotation.houseData.nid] = annotation;
            }
        }

        NSMutableArray *annotations = [NSMutableArray new];

        FHHouseAnnotation *selectedAnnoation = nil;
        
        for (FHMapSearchDataListModel *info in list) {
            FHHouseAnnotation *houseAnnotation = removeAnnotationDict[info.nid];
            
            if (houseAnnotation) {
                if ([info.nid isEqualToString:self.currentSelectHouseData.nid]) {
                    houseAnnotation.type = FHHouseAnnotationTypeSelected;
                    selectedAnnoation = houseAnnotation;
                }else if(_selectedAnnotations[info.nid]){
                    houseAnnotation.type = FHHouseAnnotationTypeOverSelected;
                }else{
                    houseAnnotation.type = FHHouseAnnotationTypeNormal;
                }
                houseAnnotation.houseData = info;//update date
                houseAnnotation.title = info.name;
                houseAnnotation.subtitle = info.desc;
                houseAnnotation.searchType = [info.type integerValue];
                MAAnnotationView *annotationView = [self.mapView viewForAnnotation:houseAnnotation];
                annotationView.annotation = houseAnnotation;
                [removeAnnotationDict removeObjectForKey:info.nid];
                continue;
            }

            CGFloat lat = [info.centerLatitude floatValue];
            CGFloat lon = [info.centerLongitude floatValue];

            houseAnnotation = [[FHHouseAnnotation alloc] init];
            houseAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
            houseAnnotation.title = info.name;
            houseAnnotation.subtitle = info.desc;
            houseAnnotation.houseData = info;
            houseAnnotation.searchType = [info.type integerValue];
            if ([info.nid isEqualToString:self.currentSelectHouseData.nid]) {
                houseAnnotation.type = FHHouseAnnotationTypeSelected;
                selectedAnnoation = houseAnnotation;
            }else if(_selectedAnnotations[info.nid]){
                houseAnnotation.type = FHHouseAnnotationTypeOverSelected;
            }else{
                houseAnnotation.type = FHHouseAnnotationTypeNormal;
            }
            [annotations addObject:houseAnnotation];
        }
        NSArray *needRemoveAnnotations = [removeAnnotationDict allValues];
        [self.mapView removeAnnotations:needRemoveAnnotations];
        [self.mapView addAnnotations:annotations];
        if (selectedAnnoation) {
            [self.mapView selectAnnotation:selectedAnnoation animated:NO];
        }
    }else{
        [self.mapView removeAnnotations:self.mapView.annotations];
    }

}

-(void)handleSelect:(MAAnnotationView *)annotationView
{
    if (![annotationView.annotation isKindOfClass:[FHHouseAnnotation class]]) {
        return;
    }
    FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotationView.annotation;
    if (houseAnnotation.searchType == FHMapSearchTypeDistrict || houseAnnotation.searchType == FHMapSearchTypeArea) {
        
        if (![TTReachability isNetworkConnected]) {
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            return;
        }
        //show district zoom map
        CGFloat zoomLevel = self.mapView.zoomLevel;
        
        FHMapSearchDataListModel *model = houseAnnotation.houseData;
        CLLocationCoordinate2D moveCenter = CLLocationCoordinate2DMake(model.centerLatitude.floatValue, model.centerLongitude.floatValue);
        
//        NSURL *url = [NSURL URLWithString:model.mapFindHouseOpenUrl];
//        if (url) {
//            [self.lastBubble overwriteFliter:url.query];
//        }
        self.lastBubble = [FHMapSearchBubbleModel bubbleFromUrl:model.mapFindHouseOpenUrl];
        if (self.lastBubble) {
            zoomLevel = self.lastBubble.resizeLevel;
            moveCenter = CLLocationCoordinate2DMake(self.lastBubble.centerLatitude, self.lastBubble.centerLongitude);
        }else{
            /*
             *  zoomlevel 与显示对应关系
             *  区域 7 - 13
             *  商圈 13 - 16
             *  小区 16 - 20
             */
            if (zoomLevel < 10) {
                //BY PM qiuruixiang
                zoomLevel = 10;
            }else if (zoomLevel < 13) {
                zoomLevel = 13.5;
            }else if (zoomLevel < 16){
                zoomLevel = 16.5;
            }else{
                zoomLevel += 1;
            }
        }
        if (zoomLevel > 20) {
            zoomLevel = 20;
        }
        
        _movingToCenter = NO;
        [self tryAddMapZoomLevelTrigerby:FHMapZoomTrigerTypeClickAnnotation currentLevel:zoomLevel];
        [self.mapView setCenterCoordinate:moveCenter animated:YES];
        [self.mapView setZoomLevel:zoomLevel animated:YES]; //atPivot:annotationView.center
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //待地图缩放完之后
            [self requestHouses:NO showTip:YES];
        });
        
        
    }else{
        //show house list
//        if (![TTReachability isNetworkConnected]) {
//            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
//            return;
//        }
        
        if (self.currentSelectAnnotation.houseData) {
            _selectedAnnotations[self.currentSelectAnnotation.houseData.nid] = self.currentSelectAnnotation.houseData.nid;
        }
        
        self.currentSelectAnnotation = houseAnnotation;
        self.currentSelectHouseData = houseAnnotation.houseData;
        [self showNeighborHouseList:houseAnnotation.houseData];
    }
    
    [self addClickBubbleLog:houseAnnotation];
}

-(void)moveAnnotationToCenter:(FHMapSearchDataListModel *)model animated:(BOOL)animated
{
    if (!model) {
        return;
    }
    _movingToCenter = YES;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(model.centerLatitude.floatValue, model.centerLongitude.floatValue);
    [self.mapView setCenterCoordinate:center animated:animated];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.startShowTimestamp = [[NSDate date] timeIntervalSince1970];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = now - _startShowTimestamp;
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[@"enter_from"] = self.configModel.enterFrom?:@"be_null";//@"old_list";
    param[@"search_id"] = self.searchId?:@"be_null";
    param[@"origin_from"] = self.configModel.originFrom?:@"be_null";
    param[@"origin_search_id"] = self.configModel.originSearchId ?: @"be_null";
    param[@"stay_time"] = @((NSInteger)(duration*1000));
    
    //TraceEventName
    [FHUserTracker writeEvent:@"stay_mapfind" params:param];
}

//-(void)checkAccuracy
//{
//    if(self.mapView.userLocationAccuracyCircle.radius > 100 ) {
//        [self.mapView.userLocationAccuracyCircle setRadius:100];
//        [self.mapView rendererForOverlay:self.mapView.userLocationAccuracyCircle];
//    }
//}
//
//- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView
//{
//    [self checkAccuracy];
//}


- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView
{
    if (!self.mapViewRegionSuccess) {
        [self requestHouses:NO showTip:YES];
    }
}

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    if (!_movingToCenter && !wasUserAction) {
        return;
    }
    CLLocationCoordinate2D currentCenter = mapView.centerCoordinate;
    if ([self shouldRequest:currentCenter]) {
        [self requestHouses:wasUserAction showTip:NO];
    }
    _movingToCenter = NO;
}

/**
 * @brief 地图缩放结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    [self tryAddMapZoomLevelTrigerby:FHMapZoomTrigerTypeZoomMap currentLevel:mapView.zoomLevel];
    
    if ( !wasUserAction) {
        //only send request by user
        return;
    }
    
    if (fabs(floor(_requestMapLevel) - floor(mapView.zoomLevel)) >= 1 ||  fabs(_requestMapLevel - mapView.zoomLevel) > 0.08*mapView.zoomLevel) {
        self.lastBubble.resizeLevel = self.mapView.zoomLevel;
        [self requestHouses:wasUserAction showTip:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[FHHouseAnnotation class]])
    {
        FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotation;
        if (houseAnnotation.searchType == FHMapSearchTypeDistrict || houseAnnotation.searchType == FHMapSearchTypeArea) {
            static NSString *reuseIndetifier = @"DistrictAnnotationIndetifier";
            FHDistrictAreaAnnotationView *annotationView = (FHDistrictAreaAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[FHDistrictAreaAnnotationView alloc] initWithAnnotation:annotation
                                                                          reuseIdentifier:reuseIndetifier];
            }else{
                annotationView.annotation = houseAnnotation;
            }
            
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -32);
            annotationView.canShowCallout = NO;
            return annotationView;
            
        }else{
            static NSString *reuseIndetifier = @"HouseAnnotationIndetifier";
            FHNeighborhoodAnnotationView *annotationView = (FHNeighborhoodAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[FHNeighborhoodAnnotationView alloc] initWithAnnotation:annotation
                                                                          reuseIdentifier:reuseIndetifier];
            }else{
                annotationView.annotation = houseAnnotation;
            }
            
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -18);
            annotationView.canShowCallout = NO;
            switch (houseAnnotation.type) {
                case FHHouseAnnotationTypeSelected:
                    annotationView.zIndex = 100;
                    break;
                case FHHouseAnnotationTypeOverSelected:
                    annotationView.zIndex = 10;
                    break;
                default:
                    annotationView.zIndex = 0;
                    break;
            }
            return annotationView;
        }
    }
    
    return nil;
}

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[FHNeighborhoodAnnotationView class]]) {
        FHNeighborhoodAnnotationView *neighborView = (FHNeighborhoodAnnotationView *)view;
        [neighborView changeSelectMode:FHHouseAnnotationTypeOverSelected];
    }
}

-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if ([view isKindOfClass:[FHNeighborhoodAnnotationView class]]) {
        FHNeighborhoodAnnotationView *neighborView = (FHNeighborhoodAnnotationView *)view;
        [neighborView changeSelectMode:FHHouseAnnotationTypeSelected];
    }
}


/**
 * @brief 标注view被点击时，触发该回调。（since 5.7.0）
 * @param mapView 地图的view
 * @param view annotationView
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewTapped:(MAAnnotationView *)view
{
    [self handleSelect:view];
}

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (_showMode == FHMapSearchShowModeHalfHouseList) {
        //点击空白退出房源列表
        [self dismissHouseListView];
    }else{
        //强制显示导航栏，增加保护
        [self.viewController showNavTopViews:1 animated:NO];        
    }    
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if (overlay == mapView.userLocationAccuracyCircle) {
        
        if ([overlay isKindOfClass:[MACircle class]]) {
            MACircle *circle = (MACircle *)overlay;
            if (circle.radius > 100) {
                [circle setRadius:1000];
            }
        }
        
        MACircleRenderer *accuracyCircleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        accuracyCircleRenderer.lineWidth    = 1.f;
        accuracyCircleRenderer.strokeColor  = RGB(41, 156 ,255 );
        accuracyCircleRenderer.fillColor    = RGBA(41, 156 ,255 , 0.3);
        
        return accuracyCircleRenderer;
    }
    return nil;
}

-(void)mapInitComplete:(MAMapView *)mapView
{
    [self requestHouses:NO showTip:YES];
}

-(BOOL)shouldRequest:(CLLocationCoordinate2D )currentCenter
{
    CGPoint ccenter = [_mapView convertCoordinate:currentCenter toPointToView:_mapView];
    CGPoint lcenter = [_mapView convertCoordinate:_lastRequestCenter toPointToView:_mapView];
    CGFloat threshold = MIN(self.viewController.view.width/2, self.viewController.view.height/3);    
    if (_mapView.zoomLevel < 16) {
        //商圈和区域视野
        threshold *= (_mapView.zoomLevel/10);
    }
    if (fabs(ccenter.x - lcenter.x) > threshold || fabs(ccenter.y - lcenter.y) > threshold) {
        return YES;
    }
    return NO;
}

#pragma mark - neighborhood houses
-(void)showNeighborHouseList:(FHMapSearchDataListModel *)model
{
    [self changeNavbarAppear:NO];
    self.showMode = FHMapSearchShowModeHalfHouseList;
    [self.tipView removeTip];
    
    //move annotationview to center
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(model.centerLatitude.floatValue, model.centerLongitude.floatValue);
    CGPoint annotationViewPoint = [self.mapView convertCoordinate:center toPointToView:self.mapView];
    CGPoint destCenterPoint = CGPointMake(self.mapView.width/2, self.mapView.height/6);
    CGPoint currentCenterPoint = CGPointMake(self.mapView.width/2, self.mapView.height/2);
    CGPoint toMovePoint = CGPointMake(annotationViewPoint.x - destCenterPoint.x + currentCenterPoint.x, annotationViewPoint.y - destCenterPoint.y + currentCenterPoint.y);
    toMovePoint.y -= 18;//annotationview height/2
    CLLocationCoordinate2D destCenter = [self.mapView convertPoint:toMovePoint toCoordinateFromView:self.mapView];
    [self.mapView setCenterCoordinate:destCenter animated:YES];
    
    FHMapSearchBubbleModel *houseListBubble = [self bubleFromOpenUrl:model.houseListOpenUrl];
    
    [self.houseListViewController showNeighborHouses:model bubble:houseListBubble];
    
    if (![TTReachability isNetworkConnected]) {
        //当前不联网,判断更新筛选器选项
        if (self.filterConditionParams) {
            [self.houseListViewController.viewModel overwirteCondition:self.filterConditionParams];
        }
    }
    
}


-(FHMapSearchBubbleModel *)bubleFromOpenUrl:(NSString *)openUrl
{
    FHMapSearchBubbleModel *bubble = [FHMapSearchBubbleModel bubbleFromUrl:openUrl];
    NSURL *url = [NSURL URLWithString:openUrl];
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    if (self.conditionNoneFilterBlock) {
        NSString *noneFilter = self.conditionNoneFilterBlock(paramObj.queryParams);
        bubble.noneFilterQuery = noneFilter;
    }
    return bubble;
}

#pragma mark - filter delegate
//-(void)onConditionChangedWithCondition:(NSString *)condition
-(void)onConditionChanged:(NSString *)condition
{
    [self.lastBubble overwriteFliter:condition];
    
    if (![self.filterConditionParams isEqualToString:condition]) {
        self.filterConditionParams = condition;
        if (![TTReachability isNetworkConnected]) {
            [[FHMainManager sharedInstance]showToast:@"网络异常" duration:1];
            if (self.showMode != FHMapSearchShowModeMap) {
                [self.houseListViewController.viewModel overwirteCondition:condition];
            }            
            return;
        }
        if (self.showMode != FHMapSearchShowModeMap) {
            [self.houseListViewController.viewModel reloadingHouseData:condition];
            self.needReload = YES;
        }else{
            [self requestHouses:NO showTip:YES];
        }
    }
}

-(void)onConditionPanelWillDisplay
{
    
}

-(void)onConditionPanelWillDisappear
{
    
}


-(void)updateBubble:(NSString *)openUrl
{
    if (openUrl.length == 0 ) {
        return;
    }
//    self.mapFindHouseOpenUrl = openUrl;
    self.lastBubble = [FHMapSearchBubbleModel bubbleFromUrl:openUrl];
    NSURL *url = [NSURL URLWithString:openUrl];
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    if (self.resetConditionBlock) {
        self.resetConditionBlock(paramObj.queryParams);
    }
    
    if (self.conditionNoneFilterBlock) {
        NSString *noneFilter = self.conditionNoneFilterBlock(paramObj.queryParams);
        self.lastBubble.noneFilterQuery = noneFilter;
    }
}

-(void)updateFilter:(NSString *)condition
{
    if (condition.length > 0) {
        NSURL *url = [NSURL URLWithString:condition];
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        if (self.resetConditionBlock) {
            self.resetConditionBlock(paramObj.queryParams);
        }
        
        if (self.conditionNoneFilterBlock) {
            NSString *noneFilter = self.conditionNoneFilterBlock(paramObj.queryParams);
        }
    }
}

-(NSString *)backHouseListOpenUrl
{
    return self.houseListOpenUrl;
}

-(void)showHoseDetailPage:(FHSearchHouseDataItemsModel *)model rank:(NSInteger)rank
{
    //fschema://old_house_detail?house_id=xxx
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?house_id=%@",model.hid];
    TTRouteUserInfo *userInfo = nil;
    NSMutableDictionary *tracerDic = [NSMutableDictionary new];
    [tracerDic addEntriesFromDictionary:self.logBaseParams];
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"enter_from"] = @"mapfind";
    tracerDic[@"element_from"] = @"half_category";
    tracerDic[@"rank"] = @(rank);
    if (model.logPb) {
        tracerDic[@"log_pb"] = model.logPb;
    }
    if (tracerDic) {
        NSDictionary *dict = @{@"tracer":tracerDic};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
    }
    [strUrl appendFormat:@"&house_type=2"];
    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
}

-(void)showNeighborhoodDetailPage:(FHMapSearchDataListModel *)neighborModel
{
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?neighborhood_id=%@",neighborModel.nid];
    NSMutableDictionary *tracerDic = [NSMutableDictionary new];
    [tracerDic addEntriesFromDictionary:self.logBaseParams];
    tracerDic[@"card_type"] = @"no_pic";
    tracerDic[@"enter_from"] = @"mapfind";
    tracerDic[@"element_from"] = @"half_category";
    tracerDic[@"rank"] = @"0";
    TTRouteUserInfo *userInfo = nil;
    if (neighborModel.logPb) {
        tracerDic[@"log_pb"] = [neighborModel.logPb toDictionary];
    }
    if (tracerDic) {
        NSDictionary *dict = @{@"tracer":tracerDic};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
    }
    
    [strUrl appendFormat:@"&house_type=4"]; // 小区
    [strUrl appendFormat:@"&source=rent_detail"]; // 租房半屏列表进入小区
    
    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
}

-(void)showRentHouseDetailPage:(FHHouseRentDataItemsModel *)model rank:(NSInteger)rank
{
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://rent_detail?house_id=%@&card_type=left_pic&enter_from=mapfind&element_from=half_category&rank=%ld",model.id,rank];
    TTRouteUserInfo *userInfo = nil;
    
    NSMutableDictionary *tracer = [[NSMutableDictionary alloc]init];
    
    [tracer addEntriesFromDictionary:[self logBaseParams]];
    tracer[@"enter_from"] = @"mapfind";
    tracer[@"element_from"] = @"half_category";
    tracer[@"log_pb"] = model.logPb;
    tracer[@"card_type"] = @"left_pic";
    tracer[@"rank"] = [@(rank) description];
    
    if (model.logPb) {
        NSString *groupId = model.id;
        NSString *imprId = model.imprId;
        NSString *searchId = model.searchId;
        if (groupId) {
            [strUrl appendFormat:@"&group_id=%@",groupId];
        }
        if (imprId) {
            [strUrl appendFormat:@"&impr_id=%@",imprId];
        }
        if (searchId) {
            [strUrl appendFormat:@"&search_id=%@",searchId];
        }
        
        NSDictionary *dict = @{@"log_pb":model.logPb,
                               @"tracer":tracer
                               };
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
    }
    if (self.configModel.originFrom) {
        [strUrl appendFormat:@"&origin_from=%@",_configModel.originFrom];
    }
    if (_configModel.originSearchId) {
        [strUrl appendFormat:@"&origin_search_id=%@",_configModel.originSearchId];
    }
    [strUrl appendFormat:@"&house_type=3"];
    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
}

-(FHMapZoomViewLevelType)mapZoomViewType:(CGFloat)zoomLevel
{
    /*
     *  zoomlevel 与显示对应关系
     *  区域 7 - 13   district
     *  商圈 13 - 16  area
     *  小区 16 - 20  neighborhood
     */
    if (zoomLevel < 13) {
        return FHMapZoomViewLevelTypeDistrict;
    }else if (zoomLevel < 16){
        return FHMapZoomViewLevelTypeArea;
    }
    return FHMapZoomViewLevelTypeNeighborhood;
}

#pragma mark log
-(NSMutableDictionary *)logBaseParams
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[@"enter_from"] = self.configModel.enterFrom?: @"be_null";
    param[@"search_id"] = self.searchId?:@"be_null";
    param[@"origin_from"] = self.configModel.originFrom?:@"be_null";
    param[@"origin_search_id"] = self.configModel.originSearchId ?: @"be_null";

    return param;
}

//进入地图找房模块埋点
-(void)addEnterMapSearchLog
{
    /*
     let enterParams = TracerParams.momoid() <|>
     toTracerParams(enterFrom, key: "enter_from") <|>
     toTracerParams(categoryListViewModel?.originSearchId ?? "be_null", key: "search_id") <|>
     toTracerParams(originFrom, key: "origin_from") <|>
     toTracerParams(originSearchId, key: "origin_search_id")
     recordEvent(key: TraceEventName.enter_mapfind, params: enterParams)
     */
    NSMutableDictionary *param = [self logBaseParams];
    param[@"search_id"] = self.searchId?:@"be_null";
    
    [FHUserTracker writeEvent:@"enter_mapfind" params:param];
    
}

-(void)addEnterMapLog
{
    FHMapZoomViewLevelType zoomLevelType = [self mapZoomViewType:self.configModel.resizeLevel];
    [self addMapZoomLevelTrigerby:FHMapZoomTrigerTypeDefault viewTye:zoomLevelType];
    self.firstEnterLogAdded = YES;
}

-(void)tryAddMapZoomLevelTrigerby:(FHMapZoomTrigerType)trigerType currentLevel:(CGFloat)zoomLevel
{
    if (fabs(ceil(_lastRecordZoomLevel) - ceil(zoomLevel)) > 1) {
        //添加视野埋点
        FHMapZoomViewLevelType destType = [self mapZoomViewType:zoomLevel];
        FHMapZoomViewLevelType lastType = [self mapZoomViewType:_lastRecordZoomLevel];
        if (destType != lastType) {
            [self addMapZoomLevelTrigerby:trigerType viewTye:destType];
            _lastRecordZoomLevel = zoomLevel;
        }
    }
}

-(void)addMapZoomLevelTrigerby:(FHMapZoomTrigerType)trigerType viewTye:(FHMapZoomViewLevelType)viewType
{
    NSMutableDictionary *param = [self logBaseParams];
    
    NSString *triger = nil;
    switch (trigerType) {
        case FHMapZoomTrigerTypeZoomMap:
            triger = @"map";
            break;
        case FHMapZoomTrigerTypeClickAnnotation:
            triger = @"click";
            break;
        default:
            triger = @"default";
            break;
    }
    
    NSString *viewTypeStr = nil;
    switch (viewType) {
        case FHMapZoomViewLevelTypeArea:
            viewTypeStr = @"area";
            break;
        case FHMapZoomViewLevelTypeDistrict:
            viewTypeStr = @"district";
            break;
        default:
            viewTypeStr = @"neighborhood";
            break;
    }
    param[@"view_level"] = viewTypeStr;
    param[@"trigger_type"] = triger;

    [FHUserTracker writeEvent:@"mapfind_view" params:param];
    
}


-(void)addClickBubbleLog:(FHHouseAnnotation *) annotation
{
    FHMapSearchType bubbleType = annotation.searchType;
    NSString *clickType = nil;
    switch (bubbleType) {
        case FHMapSearchTypeArea:
            clickType = @"area";
            break;
        case FHMapSearchTypeDistrict:
            clickType = @"district";
            break;
        case FHMapSearchTypeNeighborhood:
            clickType = @"neighborhood";
            break;
        default:
            return;
    }

    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"click_type"] = clickType;
    if(annotation.houseData.logPb){
        param[@"log_pb"] = [annotation.houseData.logPb toDictionary];
    }
    
    [FHUserTracker writeEvent:@"mapfind_click_bubble" params:param];
}

-(void)addHouseListShowLog:(FHMapSearchDataListModel*)model houseListModel:(FHSearchHouseDataModel *)houseDataModel
{
    NSMutableDictionary *param = [self logBaseParams];
    param[@"search_id"] = houseDataModel.searchId;
    param[@"category_name"] = @"be_null";
    param[@"element_from"] = @"be_null";
    
    [FHUserTracker writeEvent:@"mapfind_half_category" params:param];
}

-(void)addNavSwitchHouseListLog
{
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"enter_from"] = @"mapfind";
    param[@"enter_type"] = @"click";
    param[@"click_type"] = @"list";
    param[@"category_name"] = self.configModel.enterCategory?:@"be_null";//@"old_list";
    param[@"element_from"] = self.configModel.elementFrom ?: @"be_null";
    
    [FHUserTracker writeEvent:@"click_switch_mapfind" params:param];
}

#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        //有网络了，重新请求
        [self requestHouses:YES showTip:YES];
        
        [self.houseListViewController.viewModel reloadingHouseData:nil];
    }
}

@end
