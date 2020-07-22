//
//  FHMapSearchViewModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchViewModel.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "UIViewAdditions.h"
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
#import "TTReachability.h"
#import "FHMainManager+Toast.h"
#import "FHUserTracker.h"
#import "FHMapSearchBubbleModel.h"
#import "UIColor+Theme.h"
#import "FHHouseRentModel.h"
#import <Heimdallr/HMDTTMonitor.h>
#import "FHMapDrawMaskView.h"
#import "FHMapSearchWayChooseView.h"
#import <FHCommonUI/ToastManager.h>
#import "FHMapSearchDrawGuideView.h"
#import "FHMapSearchLevelPopLayer.h"
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <BDALog/BDAgileLog.h>
#import "FHMainApi+MapSearch.h"
#import "FHMapSubwayPickerView.h"
#import <FHHouseBase/FHEnvContext.h>
#import "FHMapStationAnnotationView.h"
#import "FHMapStationIconAnnotationView.h"
#import "FHMapSearchStationIconAnnotation.h"
#import "FHMapSearchFilterView.h"
#import "FHMapAreaHouseListViewController.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import <TTUIWidget/TTNavigationController.h>
#import "FHHouseOpenURLUtil.h"
#import <NSDictionary+TTAdditions.h>
#import "FHMapSimpleNavbar.h"

#define kTipDuration 3

extern NSString *const COORDINATE_ENCLOSURE;
extern NSString *const NEIGHBORHOOD_IDS ;

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


@interface FHMapSearchViewModel ()<FHMapSearchWayChooseViewDelegate,FHMapDrawMaskViewDelegate>
{
    MAMapPoint *drawLinePoints;//用户画圈选择的坐标点
    int drawLinePointCount;
    int onSaleHouseCount;//指定区域（画圈、地图） 在售房源数目
}
@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , assign) NSInteger requestMapLevel;
@property(nonatomic , weak)   TTHttpTask *requestHouseTask;
@property(nonatomic , strong) FHMapSearchHouseListViewController *houseListViewController;//小区房源

@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) NSString *houseTypeName;
@property(nonatomic , weak)   FHHouseAnnotation *currentSelectAnnotation;
@property(nonatomic , strong) FHMapSearchDataListModel *currentSelectHouseData;
@property(nonatomic , strong) NSMutableDictionary<NSString * , NSString *> *selectedAnnotations;
@property(nonatomic , assign) NSTimeInterval startShowTimestamp;
@property(nonatomic , assign) CGFloat lastRecordZoomLevel; //for statistics
@property(nonatomic , assign) CLLocationCoordinate2D lastRequestCenter;
@property(nonatomic , assign) BOOL firstEnterLogAdded;
@property(nonatomic , assign) BOOL needReload;
@property(nonatomic , copy) NSString *houseListOpenUrl;//返回列表页时的openurl
@property(nonatomic , strong) FHMapSearchBubbleModel *lastBubble;
@property(nonatomic , assign) BOOL movingToCenter;
@property(nonatomic , assign) BOOL configUserLocationLayer;
@property(nonatomic , assign) BOOL mapViewRegionSuccess;

@property(nonatomic , strong) MAPolygon *drawLayer;//画圈图层 画地铁线路图层
@property(nonatomic , strong) NSArray *drawLineXCoords;
@property(nonatomic , strong) NSArray *drawLineYCoords;
@property(nonatomic , strong) NSArray *drawLineNeighbors;
@property(nonatomic , strong) NSDate *enterDrawLineTime;
@property(nonatomic , assign) FHMapSearchShowMode lastShowMode;//画圈使用
@property(nonatomic , strong) NSDictionary *filterParam;
@property(nonatomic , strong) FHSearchFilterConfigOption *selectedLine;
@property(nonatomic , strong) FHSearchFilterConfigOption *selectionStation;
@property(nonatomic , strong) FHMapSubwayPickerView *subwayPicker;
@property(nonatomic , strong) FHSearchFilterConfigOption *subwayData;
@property(nonatomic , strong) NSArray *subwayLines;//地铁以一段一段的方式拼接
@property(nonatomic , strong) FHMapSearchFilterView *filterView;
@property(nonatomic , strong) FHMapAreaHouseListViewController *areaHouseListController; //区域内房源
@property(nonatomic , assign) CLLocationCoordinate2D drawMinCoordinate;
@property(nonatomic , assign) CLLocationCoordinate2D drawMaxCoordinate;
@property(nonatomic , assign) BOOL hidingAreaHouseList;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:TTReachabilityChangedNotification object:nil];
        
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
        
        if (self.configModel.houseType == FHHouseTypeSecondHandHouse) {
            self.subwayData = [self loadSubwayData];
        }
        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTReachabilityChangedNotification object:nil];
    if (self->drawLinePoints) {
        free(self->drawLinePoints);
    }
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
        }else{
            [[HMDTTMonitor defaultManager] hmdTrackService:@"map_location_failed" attributes:@{@"longitude":@(center.longitude),@"latitude":@(center.latitude)}];
            BDALOG_ERROR(@"map_search_location : (longitude:%fmlatitude:%f) ",center.longitude,center.latitude);
        }
        
        //设置地图style
        NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_map_style.data" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:stylePath];
        NSString *extraPath = [[NSBundle mainBundle] pathForResource:@"gaode_style_extra.data" ofType:nil];
        NSData *extraData = [NSData dataWithContentsOfFile:extraPath];
//        [_mapView setCustomMapStyleWithWebData:data];
        MAMapCustomStyleOptions *options = [MAMapCustomStyleOptions new];
//        options.styleId = @"ff4f227ed4a5b4431c987097c46b63c8";
        options.styleData = data;
        options.styleExtraData = extraData;
        [_mapView setCustomMapStyleOptions:options];
        [_mapView setCustomMapStyleEnabled:YES];
        
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
        
    }
    return _mapView;
}

-(void)setSideBar:(FHMapSearchSideBar *)sideBar
{
    _sideBar = sideBar;
    __weak typeof(self) wself = self;
    sideBar.chooseTypeBlock = ^(FHMapSearchSideBarItemType type) {
        switch (type) {
            case FHMapSearchSideBarItemTypeList:
            {
                [wself showSiderHouseList];
            }
                break;
            case FHMapSearchSideBarItemTypeCircle:
            {
                if (![TTReachability isNetworkConnected]) {
                    [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                    return;
                }
                [wself chooseDrawLine];
            }
                break;
            case FHMapSearchSideBarItemTypeFilter:
            {
                [wself showFilter];
            }
                break;
            case FHMapSearchSideBarItemTypeSubway:
            {
                if (wself.showMode == FHMapSearchShowModeSubway) {
                    [wself showSubwayPicker];
                }else{
                    [wself chooseSubWay];
                }
            }
                break;
            default:
                break;
        }
    };
}

-(FHMapSearchFilterView *)filterView
{
    if (!_filterView) {
        _filterView = [[FHMapSearchFilterView alloc]initWithFrame:self.viewController.view.bounds];
        __weak typeof(self) wself = self;
        _filterView.confirmWithQueryBlock = ^(NSString * _Nonnull query) {
            [wself changeFilter:query];
        };
        
        _filterView.resetBlock = ^{
            [wself changeFilter:@""];
        };
        
        FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        NSArray<FHSearchFilterConfigItem> *filter = nil;
        
        if (self.configModel.houseType == FHHouseTypeSecondHandHouse) {
            [_filterView updateWithOldFilter:configModel.filter];
        }else if(self.configModel.houseType == FHHouseTypeRentHouse){
            [_filterView updateWithRentFilter:configModel.rentFilter];
        }
        
        if(_configModel.mapOpenUrl){
            [_filterView selectedWithOpenUrl:_configModel.mapOpenUrl];
        }else if(_configModel.conditionParams){
            
        }
    }
    return _filterView;
}

-(void)showFilter
{
    NSString *query =  [self.lastBubble query];
    NSString *url = [NSString stringWithFormat:@"https:a?%@",query];
    [self.filterView selectedWithOpenUrl:url];
    [self.filterView showInView:self.viewController.view animated:YES];
}

-(void)changeFilter:(NSString *)query
{
    if(self.areaHouseListController.view.superview){
        [self.areaHouseListController.viewModel refreshWithFilter:query];
        [self.lastBubble overwriteFliter:query];
        self.needReload = YES;
    }else{
        [self.lastBubble overwriteFliter:query];
        if ([TTReachability isNetworkConnected]) {
            [self requestHouses:YES showTip:YES];
        }else{
            SHOW_TOAST(@"网络异常");
        }
        
    }
}

-(void)exitCurrentMode
{    
    [self addStayCircelFindLog];
    
    [self userExit:self.drawMaskView];
    
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
    UIImage *image = [UIImage imageNamed:@"mapsearch_location_center_orange"];
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
    [self.viewController showNavTopViews:show?1:0 animated:YES ];
    
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
        _houseListViewController.willSwipeDownDismiss = ^(CGFloat duration , FHMapSearchBubbleModel *fromBubble) {
            if (wself) {
                [wself changeNavbarAppear:YES];
                if (wself.lastShowMode == FHMapSearchShowModeDrawLine ) {
                    
                    wself.showMode = wself.lastShowMode;
                    //恢复筛选器
                    if (wself.resetConditionBlock && wself.filterParam) {
                        wself.resetConditionBlock(wself.filterParam);
                    }
                }else{
                    wself.showMode = FHMapSearchShowModeMap;
                    [wself checkNeedRequest];
                }
//                [wself.viewController switchNavbarMode:FHMapSearchShowModeMap];
                [wself.mapView deselectAnnotation:wself.currentSelectAnnotation animated:YES];
                [wself moveAnnotationToCenter:wself.currentSelectHouseData animated:YES];
                NSString *nid = wself.currentSelectHouseData.nid;
                if (nid.length > 0) {
                    wself.selectedAnnotations[nid] = nid;
                }
                wself.currentSelectAnnotation = nil;
                wself.currentSelectHouseData = nil;
                [wself.mapView becomeFirstResponder];
                
            }
        };
        _houseListViewController.didSwipeDownDismiss = ^(FHMapSearchBubbleModel *fromBubble){
            if (wself) {
                [wself changeNavbarAppear:YES];
                if (wself.lastShowMode == FHMapSearchShowModeDrawLine) {
                    wself.showMode = FHMapSearchShowModeDrawLine;                    
                }else{
                    if (wself.lastShowMode == FHMapSearchShowModeSubway){
                        wself.showMode = FHMapSearchShowModeSubway;
                    }else{
                        wself.showMode = FHMapSearchShowModeMap;
                    }
                }
            }
        };
        _houseListViewController.moveToTop = ^{
            [wself changeNavbarAppear:NO];
            wself.showMode = FHMapSearchShowModeHouseList;
//            [wself.viewController switchNavbarMode:FHMapSearchShowModeHouseList];
            if (wself.lastShowMode == FHMapSearchShowModeDrawLine ) {
                if (wself.resetConditionBlock && wself.filterParam) {
                    wself.resetConditionBlock(wself.filterParam);
                }
                
            }
        };
        _houseListViewController.moveDock = ^{
            wself.showMode = FHMapSearchShowModeHalfHouseList;
//            [wself changeNavbarAlpha:NO];
            NSString *nid = wself.currentSelectHouseData.nid;
            if (nid.length > 0) {
                wself.selectedAnnotations[nid] = nid;
            }
            if (wself.lastShowMode != FHMapSearchShowModeDrawLine) {
                [wself checkNeedRequest];
            }
        };
        _houseListViewController.movingBlock = ^(CGFloat top) {
//            [wself changeNavbarAlpha:NO];
        };
        _houseListViewController.showHouseDetailBlock = ^(FHHouseListBaseItemModel * _Nonnull model , NSInteger rank , FHMapSearchBubbleModel *fromBubble) {
            [wself showHoseDetailPage:model rank:rank fromBubble:fromBubble];
        };
        
        _houseListViewController.showNeighborhoodDetailBlock = ^(FHMapSearchDataListModel * _Nonnull model ,FHMapSearchBubbleModel *fromBubble) {
            [wself showNeighborhoodDetailPage:model fromBubble:fromBubble];
        };
        
        _houseListViewController.showRentHouseDetailBlock = ^(FHHouseListBaseItemModel * _Nonnull model, NSInteger rank , FHMapSearchBubbleModel *fromBubble) {
            [wself showRentHouseDetailPage:model rank:rank fromBubble:fromBubble];
        };
                
        _houseListViewController.viewModel.configModel = self.configModel;
    }
    return _houseListViewController;
}

-(NSString *)navTitle
{
    if (_showMode == FHMapSearchShowModeHouseList) {
        return _currentSelectHouseData.name;
    }else if (_showMode == FHMapSearchShowModeSubway){
        return self.selectedLine.text;
    }else if (_showMode == FHMapSearchShowModeDrawLine){
        return nil;
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

-(void)requestHouses:(BOOL)byUser showTip:(BOOL)showTip
{
    [self requestHouses:byUser showTip:showTip region:_mapView.region];
}

-(void)requestHouses:(BOOL)byUser showTip:(BOOL)showTip region:(MACoordinateRegion )region
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
    NSMutableDictionary *extraParams = [NSMutableDictionary new];
    NSString *targetType = nil;
    if (_showMode == FHMapSearchShowModeDrawLine) {
//        extraParams[CHANNEL_ID] = CHANNEL_ID_CIRCEL_SEARCH;
        targetType = @"neighborhood";
    }else if (_showMode == FHMapSearchShowModeSubway || (_lastShowMode == FHMapSearchShowModeSubway && _showMode == FHMapSearchShowModeHalfHouseList)){
        if (!(([query containsString:@"line"]||[query containsString:@"station"]))) {
            if ([self.selectionStation.value isEqualToString:self.selectedLine.value]) {
                extraParams[@"line[]"] = self.selectedLine.value;
            }else{
                extraParams[@"station[]"] = self.selectionStation.value;
                extraParams[@"line[]"] = self.selectedLine.value;
            }
        }
        extraParams[CHANNEL_ID] = CHANNEL_ID_SUBWAY_SEARCH;
    }
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher mapSearch:houseType searchId:self.searchId query:query maxLocation:CLLocationCoordinate2DMake(maxLat, maxLong) minLocation:CLLocationCoordinate2DMake(minLat, minLong) resizeLevel:_mapView.zoomLevel targetType:targetType suggestionParams:nil extraParams:extraParams callback:^(NSError * _Nullable error, FHMapSearchDataModel * _Nullable model) {
        
        if (!wself) {
            return ;
        }
        typeof(self) strongSelf = wself;
        if (error) {
            //show toast
            if (error.code != NSURLErrorCancelled) {
                //请求取消
                if (![TTReachability isNetworkConnected]) {
                    SHOW_TOAST(@"网络异常");
                }
                strongSelf->onSaleHouseCount = 0;
                [strongSelf.bottomBar showDrawLine:@"0套房源" withNum:0 showIndicator:NO];
                [[FHMainManager sharedInstance] showToast:@"房源请求失败" duration:2];
                if ([TTReachability isNetworkConnected]) {
                    [[HMDTTMonitor defaultManager] hmdTrackService:@"map_house_request_failed" attributes:@{@"message":error.domain?:@""}];
                    BDALOG_ERROR(@"map_search_params : msg:  %s query is: %s",[error.domain UTF8String]?:"",[query UTF8String]?:"");
                }
                [wself.viewController switchToNormalMode];
            }
            return;
        }
        if (showTip && wself.showMode == FHMapSearchShowModeMap) {
            NSString *tip = model.tips;
            if (tip && [tip isKindOfClass:[NSString class]] && tip.length > 0) {
//                CGFloat topY = [wself.viewController topBarBottom] + 14 ;
                CGFloat topY = [UIScreen mainScreen].bounds.size.height - 100;
                [wself.tipView showIn:wself.viewController.view at:CGPointMake(wself.viewController.view.width/2, topY) content:tip duration:kTipDuration above:wself.viewController.navBarView];
            }
        }
        wself.searchId = model.searchId;
        if (model.path.count > 0) {
            BOOL move= NO;
            if (!byUser && [wself.selectionStation.value isEqualToString:wself.selectedLine.value]) {
                move = YES;
            }
            [wself addLinePathAndMoveMap:model.path move:move];
        }
        
        if (![wself.viewController isShowingMaskView]) {
            //只有不展示maskview时才显示
            [wself addAnnotations:model.list];
        }
        
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
        if (wself.showMode == FHMapSearchShowModeDrawLine) {
            [wself.bottomBar showDrawLine:[NSString stringWithFormat:@"%ld套房源",strongSelf->onSaleHouseCount] withNum:strongSelf->onSaleHouseCount showIndicator:strongSelf->onSaleHouseCount > 0];
        }
        NSDictionary *urlParams = [FHHouseOpenURLUtil queryDict:model.mapFindHouseOpenUrl];
         CLLocationCoordinate2D moveCenter = CLLocationCoordinate2DMake([urlParams tt_floatValueForKey:@"center_latitude"], [urlParams tt_floatValueForKey:@"center_longitude"]);
        CGFloat zoomLevel = [urlParams tt_floatValueForKey:@"resize_level"];
        
        //handle open url
        [wself updateBubble:model.mapFindHouseOpenUrl];
        
        if (moveCenter.latitude != 0 && moveCenter.longitude != 0 && zoomLevel) {
            [self.mapView setCenterCoordinate:moveCenter animated:YES];
            [self.mapView setZoomLevel:zoomLevel animated:YES]; //atP
        }

    }];
    _requestMapLevel = _mapView.zoomLevel;
    _requestHouseTask = task;

}

-(void)addAnnotations:(NSArray *)list
{
    self.drawLineNeighbors = nil;
    
    if (self.showMode == FHMapSearchShowModeDrawLine) {
        //处理小区
        self->onSaleHouseCount = 0;
        NSMutableArray *hlist = [NSMutableArray new];
        for (FHMapSearchDataListModel *info in list) {
            MAMapPoint point = MAMapPointMake(info.centerLatitude.floatValue, info.centerLongitude.floatValue);
            if (MAPolygonContainsPoint(point,self->drawLinePoints,self->drawLinePointCount)) {
                [hlist addObject:info];
                self->onSaleHouseCount += [info.onSaleCount intValue];
            }
        }
        list = hlist;
        self.drawLineNeighbors = list;
    }
    
    if (list.count > 0) {
        NSArray *cAnnotations = self.mapView.annotations;
        NSMutableDictionary *removeAnnotationDict = [[NSMutableDictionary alloc] initWithCapacity:cAnnotations.count];
        NSMutableArray *currentHouseAnnotations = [[NSMutableArray alloc] initWithCapacity:cAnnotations.count];
        for (NSInteger i = 0 ; i < cAnnotations.count ;  i++) {
            id <MAAnnotation> annotation = cAnnotations[i];
            if ([annotation isKindOfClass:[FHHouseAnnotation class]]) {
                FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotation;
                removeAnnotationDict[houseAnnotation.houseData.nid] = annotation;
                [currentHouseAnnotations addObject:annotation];//站点有重复的
            }else if([annotation isKindOfClass:[FHMapSearchStationIconAnnotation class]]){
                [self.mapView removeAnnotation:annotation];
            }
        }

        NSMutableArray *annotations = [NSMutableArray new];

        FHHouseAnnotation *selectedAnnoation = nil;
        
        BOOL inSubwayMode = self.showMode == FHMapSearchShowModeSubway || self.lastShowMode == FHMapSearchShowModeSubway;
        
        for (FHMapSearchDataListModel *info in list) {
            FHHouseAnnotation *houseAnnotation = removeAnnotationDict[info.nid];
            if (!inSubwayMode && houseAnnotation) {
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
                [currentHouseAnnotations removeObject:houseAnnotation];
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
            
            if ([info.type integerValue] == FHMapSearchTypeFakeStation) {
                //地铁站增加 火车头icon
                FHMapSearchStationIconAnnotation *stationIconAnnotation = [FHMapSearchStationIconAnnotation new];
                stationIconAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
                [annotations addObject:stationIconAnnotation];
            }
        }
        NSArray *needRemoveAnnotations = [removeAnnotationDict allValues];
        [self.mapView removeAnnotations:currentHouseAnnotations];
        [self.mapView addAnnotations:annotations];
        if (selectedAnnoation) {
            [self.mapView selectAnnotation:selectedAnnoation animated:NO];
        }
    }else{
        [self.mapView removeAnnotations:self.mapView.annotations];
    }

}
/*
 * 绘制地铁线路
 */
-(void)addLinePathAndMoveMap:(NSArray *)paths move:(BOOL)move
{
    if (paths.count == 0) {
        return;
    }
    
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:paths.count];
    CLLocationCoordinate2D min = CLLocationCoordinate2DMake(INT_MAX, INT_MAX);
    CLLocationCoordinate2D max = CLLocationCoordinate2DMake(0, 0);
    
    for (NSString *path in paths) {
        
        NSArray *points = [path componentsSeparatedByString:@";"];
        
        CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D)*points.count);
        NSInteger count = 0;
        for (NSString *point in points) {
            NSArray *kv = [point componentsSeparatedByString:@","];
            if (kv.count == 2) {
                coords[count].longitude = [kv[0] floatValue];
                coords[count].latitude = [kv[1] floatValue];
                if (coords[count].longitude > max.longitude) {
                    max.longitude = coords[count].longitude;
                }
                if (coords[count].longitude < min.longitude) {
                    min.longitude = coords[count].longitude;
                }
                if (coords[count].latitude > max.latitude) {
                    max.latitude = coords[count].latitude;
                }
                if (coords[count].latitude < min.latitude) {
                    min.latitude = coords[count].latitude;
                }
                
                count++;
            }
        }
        
        MAPolyline *line = [MAPolyline polylineWithCoordinates:coords count:count];
        [lines addObject:line];
        free(coords);
    }
        
//    if (self.drawLayer) {
//        [self.mapView removeOverlay:self.drawLayer];
//    }
//    [self.mapView addOverlay:line];
//    self.drawLayer = line;
    if (self.subwayLines) {
        [self.mapView removeOverlays:self.subwayLines];
    }    
    [self.mapView addOverlays:lines level:MAOverlayLevelAboveRoads];
    self.subwayLines = lines;
    
    if (move) {
        //move mapview
        MACoordinateRegion region;
        region.center = CLLocationCoordinate2DMake((min.latitude+max.latitude)/2 +((max.latitude - min.latitude)/self.viewController.view.height)*64, (min.longitude+max.longitude)/2);
        region.span = MACoordinateSpanMake((max.latitude - min.latitude)*2.05 , (max.longitude - min.longitude)*1.25);
        if (region.span.latitudeDelta > 0 && region.span.longitudeDelta > 0) {
            [self.mapView setRegion:region animated:YES];
        }
    }
}

-(void)handleSelect:(MAAnnotationView *)annotationView
{
    if (![annotationView.annotation isKindOfClass:[FHHouseAnnotation class]]) {
        return;
    }
    FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotationView.annotation;
    if (houseAnnotation.searchType == FHMapSearchTypeFakeStation) {
        //地铁站不响应
        return;
    }
    
    [self addClickBubbleLog:houseAnnotation];
    
    if (houseAnnotation.searchType == FHMapSearchTypeDistrict || houseAnnotation.searchType == FHMapSearchTypeArea || houseAnnotation.searchType == FHMapSearchTypeSegment || houseAnnotation.searchType == FHMapSearchTypeStation) {
        
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
            if (zoomLevel < 1 || zoomLevel > 20) {
                if (houseAnnotation.searchType == FHMapSearchTypeSegment) {
                    zoomLevel = 13.5;
                }else if (houseAnnotation.searchType == FHMapSearchTypeStation){
                    zoomLevel = 16.5;
                }
            }
            if (self.lastBubble.centerLatitude > 0 && self.lastBubble.centerLongitude > 0) {
                moveCenter = CLLocationCoordinate2DMake(self.lastBubble.centerLatitude, self.lastBubble.centerLongitude);
            }
        }else{
            /*
             *  zoomlevel 与显示对应关系
             *  区域 7 - 13
             *  商圈 13 - 15
             *  小区 15 - 20
             */
            if (houseAnnotation.searchType == FHMapSearchTypeSegment) {
                zoomLevel = 13.5;
            }else if (houseAnnotation.searchType == FHMapSearchTypeStation){
                zoomLevel = 16.5;
            }else if (zoomLevel < 10) {
                //BY PM qiuruixiang
                zoomLevel = 10;
            }else if (zoomLevel < 13) {
                zoomLevel = 13.5;
            }else if (zoomLevel < 15){
                zoomLevel = 15.5;
            }else{
                zoomLevel += 1;
            }
            
        }
        if (zoomLevel > 20) {
            zoomLevel = 20;
        }
        
        if (houseAnnotation.searchType == FHMapSearchTypeSegment || houseAnnotation.searchType == FHMapSearchTypeStation) {
            self.selectionStation = [self.selectionStation copy];
            self.selectionStation.value = houseAnnotation.houseData.nid;
            self.selectionStation.text = houseAnnotation.houseData.name;
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
        
        if (_areaHouseListController.view.superview) {
            //用户点击了底部栏展示出了列表页
            [self.mapView deselectAnnotation:annotationView.annotation animated:NO];
            return;
        }
        
        if (self.currentSelectAnnotation.houseData) {
            _selectedAnnotations[self.currentSelectAnnotation.houseData.nid] = self.currentSelectAnnotation.houseData.nid;
        }
        
        self.currentSelectAnnotation = houseAnnotation;
        self.currentSelectHouseData = houseAnnotation.houseData;
        [self showNeighborHouseList:houseAnnotation.houseData];
    }
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

//是否忽略 用户地图 点击、缩放等操作
-(BOOL)shouldIgnoreUserMapOperation
{
    if (self.showMode == FHMapSearchShowModeDrawLine  || (self.showMode == FHMapSearchShowModeHalfHouseList && ([self.houseListViewController.viewModel enterShowMode] == FHMapSearchShowModeDrawLine ))) {
        //|| [self.houseListViewController.viewModel enterShowMode] == FHMapSearchShowModeSubway
        //|| self.showMode == FHMapSearchShowModeSubway
        return YES;
    }
    return NO;
}


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
    if ([self shouldIgnoreUserMapOperation]) {
        return;
    }
    
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
    [self tryUpdateSideBar];
    
    if (wasUserAction) {
        [self tryAddMapZoomLevelTrigerby:FHMapZoomTrigerTypeZoomMap currentLevel:mapView.zoomLevel];
    }
        
    if ( !wasUserAction) {
        //only send request by user
        return;
    }
    
    if ([self shouldIgnoreUserMapOperation]) {
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
        if (houseAnnotation.searchType == FHMapSearchTypeDistrict || houseAnnotation.searchType == FHMapSearchTypeArea || houseAnnotation.searchType == FHMapSearchTypeSegment || houseAnnotation.searchType == FHMapSearchTypeStation) {
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
            annotationView.centerOffset = CGPointMake(0, 0);
            annotationView.canShowCallout = NO;
            return annotationView;
            
        }else if (houseAnnotation.searchType == FHMapSearchTypeFakeStation){
            static NSString *reuseIndetifier = @"StationAnnotationIndetifier";
            FHMapStationAnnotationView *stationView = (FHMapStationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
            if (!stationView) {
                stationView = [[FHMapStationAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            }else{
                stationView.annotation = houseAnnotation;
            }
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            stationView.centerOffset = CGPointMake(0, -24);
            stationView.canShowCallout = NO;
            stationView.zIndex = 1;
            return stationView;
            
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
                    annotationView.zIndex = 2;
                    break;
            }
            return annotationView;
        }
    }else if ([annotation isKindOfClass:[FHMapSearchStationIconAnnotation class]]){
        static NSString *reuseIndetifier = @"StationIconAnnotationIndetifier";
        FHMapStationIconAnnotationView *annotationView = (FHMapStationIconAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[FHMapStationIconAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.enabled = NO;
        
        return annotationView;
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
    }else if (_showMode == FHMapSearchShowModeDrawLine || _showMode == FHMapSearchShowModeSubway){
        //画圈找房 不做处理
    }else{
        //强制显示导航栏，增加保护
        [self.viewController showNavTopViews:1 animated:NO ];
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
//        accuracyCircleRenderer.lineWidth    = 1.f;
//        accuracyCircleRenderer.strokeColor  = RGB(41, 156 ,255 );
        accuracyCircleRenderer.fillColor = RGBA(0xfe, 0x55, 0x00,0.3);
//        accuracyCircleRenderer.fillColor    = [[UIColor themeRed1] colorWithAlphaComponent:0.3];
        return accuracyCircleRenderer;
    } else if ([overlay isKindOfClass:[MAPolygon class]]) {
        
        MAPolygonRenderer *polygonRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        polygonRenderer.lineWidth   = 10.f;
        polygonRenderer.strokeColor = [UIColor themeOrange1];
        polygonRenderer.fillColor   = RGBA(0xfe, 0x55, 0x00,0.1);
        
        return polygonRenderer;
    }else if ([overlay isKindOfClass:[MAPolyline class]]){
        MAPolylineRenderer *polygonRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polygonRenderer.lineWidth   = 12.f;
        polygonRenderer.strokeColor = [UIColor themeOrange1];
        polygonRenderer.lineJoinType = kMALineJoinRound;
        polygonRenderer.lineCapType  = kMALineCapRound;
        return polygonRenderer;
    }
    return nil;
}

-(void)mapInitComplete:(MAMapView *)mapView
{
    [self requestHouses:NO showTip:YES];
}

- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error
{
    if ([TTReachability isNetworkConnected]) { //有网再报
        [[HMDTTMonitor defaultManager] hmdTrackService:@"map_load_failed" attributes:@{@"desc":error.localizedDescription?:@"",@"reason":error.localizedFailureReason?:@""}];
    }
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

#pragma mark - area house list
-(void)showSiderHouseList
{
    [self addSideBarHouseListLog];
    
    if ([self.configModel.enterFrom isEqualToString:@"city_market"] || [self.configModel.enterFrom isEqualToString:@"maintab"] || !self.configModel.enterFromList) {
        //从城市行情进入的 要先跳到二手房列表页 QA确认
        NSString *strUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld",self.configModel.houseType];
        NSString *houseListOpenUrl = [self backHouseListOpenUrl];
        NSURL *openUrl = [NSURL URLWithString:houseListOpenUrl];
        if( [openUrl query].length > 0) {
            strUrl = [strUrl stringByAppendingFormat:@"&%@",[openUrl query]];
        }
        NSURL *url = [NSURL URLWithString:strUrl];
        NSMutableDictionary *traceInfo = [NSMutableDictionary new];
        [traceInfo addEntriesFromDictionary:[self.configModel toDictionary]];
        traceInfo[@"enter_from"] = @"mapfind";
        traceInfo[UT_ENTER_TYPE] = @"click";
        NSDictionary *info = @{@"tracer":traceInfo};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        
        TTNavigationController *navController = self.viewController.navigationController;
        navController.panRecognizer.enabled = YES;
        
        [self.viewController.navigationController popViewControllerAnimated:NO];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        return;
    }
    
    [self.viewController.navigationController popViewControllerAnimated:YES];
    
    
//    if(self.areaHouseListController){
//        [self.areaHouseListController.view removeFromSuperview];
//        [self.areaHouseListController removeFromParentViewController];
//    }
//
//    NSString *title = @"二手房";
//
//    NSMutableDictionary *logParam = [self logBaseParams];
//    logParam[UT_ENTER_FROM] = @"circlefind";
//    logParam[UT_ENTER_TYPE] = @"click";
//    logParam[UT_ELEMENT_FROM] = @"bottom_district";
//    logParam[UT_CATEGORY_NAME] = @"circlefind_list";//(self.configModel.houseType == FHHouseTypeRentHouse)?@"rent_list":@"old_list";
//
//    FHMapSearchBubbleModel *bubble = [self houseListSearchBubble];
//
//    NSURL *url = [NSURL URLWithString:@"sslocal://mapfind_area_house_list"];
//    NSDictionary *userInfoDict = @{COORDINATE_ENCLOSURE:[self drawLineCoordinates]?:@"",
//                                   NEIGHBORHOOD_IDS:[self drawLineNeighborIds]?:@"",
//                                   HOUSE_TYPE_KEY:@(self.configModel.houseType),
//                                   @"filter":bubble.query?:@"",
//                                   @"title":title,
//                                   TRACER_KEY:logParam
//                                   };
//
//    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
//    //    [[TTRoute sharedRoute] openURLByViewController:url userInfo:userInfo];
//    WeakSelf;
//    [[TTRoute sharedRoute] openURL:url userInfo:userInfo objHandler:^(TTRouteObject *routeObj) {
//        wself.areaHouseListController = routeObj.instance;
//        wself.areaHouseListController.title = title;
//        [wself showAreaHouseList];
//    }];
//
//    [self showAreaHouseList];
}

-(void)showAreaHouseList
{
    if(!_areaHouseListController){
        return;
    }
    
    self.topInfoBar.title = _areaHouseListController.title;
    
    [self.viewController showNavTopViews:0 animated:NO];
    self.topInfoBar.hidden = NO;
    
    [self.viewController addChildViewController:_areaHouseListController];
    [self.viewController.view addSubview:_areaHouseListController.view];
    _areaHouseListController.viewModel.delegate = self;
    
    CGRect frame =  _areaHouseListController.view.frame;
    frame.origin.y = CGRectGetMaxY(self.viewController.view.bounds);
    frame.size.height = self.viewController.view.height - CGRectGetMaxY(self.topInfoBar.frame) - 10;
    _areaHouseListController.view.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect nframe = frame;
        nframe.origin.y = CGRectGetMaxY(self.topInfoBar.frame) + 10;
        self.areaHouseListController.view.frame = nframe;
    } completion:^(BOOL finished) {
    }];
    
    
}

-(void)hideAreaHouseList
{
    if (self.hidingAreaHouseList) {
        return;
    }
    self.hidingAreaHouseList = YES;
    CGRect frame = self.areaHouseListController.view.frame;
    frame.origin.y = CGRectGetMaxY(self.viewController.view.bounds);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.areaHouseListController.view.frame = frame;
        self.topInfoBar.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidingAreaHouseList = NO;
        [self.areaHouseListController.view removeFromSuperview];
        self.areaHouseListController = nil;
        
        self.topInfoBar.alpha = 1;
        self.topInfoBar.hidden = YES;
        
        [self.viewController showNavTopViews:1 animated:YES];
        
        if(_needReload){
            if (self.lastShowMode == FHMapSearchShowModeDrawLine) {
                MACoordinateRegion region;
                region.center = CLLocationCoordinate2DMake((self.drawMinCoordinate.latitude+self.drawMaxCoordinate.latitude)/2, (self.drawMinCoordinate.longitude+self.drawMaxCoordinate.longitude)/2);
                region.span = MACoordinateSpanMake((self.drawMaxCoordinate.latitude - self.drawMinCoordinate.latitude)*1.05 , (self.drawMaxCoordinate.longitude - self.drawMinCoordinate.longitude)*1.05);
                
                self.lastBubble.centerLatitude = region.center.latitude;
                self.lastBubble.centerLongitude = region.center.longitude;
                
                [self.mapView setRegion:region animated:YES];
                [self requestHouses:YES showTip:NO region:region];
            }else{
                [self requestHouses:YES showTip:NO];
            }
        }
        
    }];
    
}

-(void)showFilterForAreaHouseList
{
    [self showFilter];
}

-(void)overwriteWithOpenUrl:(NSString *)openUrl andViewModel:(FHMapAreaHouseListViewModel *)viewModel
{
    //open url 回写
    [self updateBubble:openUrl];
}

-(CGFloat)areaListMinTop
{
    return self.topInfoBar.bottom + 10;
}

-(void)areaListDismissed:(FHMapAreaHouseListViewModel *)viewModel
{
    [self hideAreaHouseList];
}


#pragma mark - sidebar
-(void)tryUpdateSideBar
{
    if (self.showMode == FHMapSearchShowModeHalfHouseList) {
        //半屏列表 不更新sidebar
        return;
    }
    CGFloat zoomLevel = self.mapView.zoomLevel;
    BOOL showCircle = (self.configModel.houseType == FHHouseTypeSecondHandHouse) && (zoomLevel >= 13);
    NSArray *types = nil;
    if(self.showMode == FHMapSearchShowModeSubway){
        types = @[@(FHMapSearchSideBarItemTypeSubway)];
    }else{
        
        NSMutableArray *showTyeps = [NSMutableArray new];
        if (self.configModel.houseType == FHHouseTypeSecondHandHouse && self.subwayData) {
            [showTyeps addObject:@(FHMapSearchSideBarItemTypeSubway)];
        }
                        
        if (showCircle) {
            //增加画圈显示
            [showTyeps addObject:@(FHMapSearchSideBarItemTypeCircle)];
        }
        
        if(self.showMode == FHMapSearchShowModeDrawLine){
            [self.simpleNavBar updateCicleBtn:showCircle];
        }
        
        [showTyeps addObject:@(FHMapSearchSideBarItemTypeFilter)];
//        [showTyeps addObject:@(FHMapSearchSideBarItemTypeList)];
        
        types = showTyeps;
        
        if(types && [[self.sideBar currentTypes] isEqualToArray:types]){
            types = nil;
        }
    }
    
    if (types && self.sideBar.height > 0) {
        [self.sideBar showWithTypes:types];
        CGFloat height = self.sideBar.height;      
        [self.sideBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    }
    
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
    CGPoint destCenterPoint = CGPointMake(self.mapView.width/2, self.mapView.height/4);
    CGPoint currentCenterPoint = CGPointMake(self.mapView.width/2, self.mapView.height/2);
    CGPoint toMovePoint = CGPointMake(annotationViewPoint.x - destCenterPoint.x + currentCenterPoint.x, annotationViewPoint.y - destCenterPoint.y + currentCenterPoint.y);
    toMovePoint.y -= 18;//annotationview height/2
    CLLocationCoordinate2D destCenter = [self.mapView convertPoint:toMovePoint toCoordinateFromView:self.mapView];
    [self.mapView setCenterCoordinate:destCenter animated:YES];
    
    FHMapSearchBubbleModel *houseListBubble = [self bubleFromOpenUrl:model.houseListOpenUrl];
    houseListBubble.lastShowMode = self.lastShowMode;
    
    [self.viewController.view bringSubviewToFront:self.houseListViewController.view];
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

//#pragma mark - filter delegate
//-(void)onConditionChanged:(NSString *)condition
//{
//    BOOL mapViewFilterShouldChange = NO;
//    if (!(self.showMode == FHMapSearchShowModeHouseList && (self.lastShowMode == FHMapSearchShowModeDrawLine))) {
//        //在非画圈找房进入列表页时才更新
//        mapViewFilterShouldChange = YES;
//    }
//    if (mapViewFilterShouldChange) {
//        [self.lastBubble overwriteFliter:condition];
//    }
//
//    if (![self.filterConditionParams isEqualToString:condition]) {
//
//        if (mapViewFilterShouldChange) {
//            //在非画圈找房进入列表页时才更新
//            self.filterConditionParams = condition;
//        }
//        if (![TTReachability isNetworkConnected]) {
//            [[FHMainManager sharedInstance]showToast:@"网络异常" duration:1];
//            if (self.showMode != FHMapSearchShowModeMap) {
//                [self.houseListViewController.viewModel overwirteCondition:condition];
//            }
//            return;
//        }
//        if (self.showMode == FHMapSearchShowModeHouseList || self.showMode == FHMapSearchShowModeHalfHouseList) {
//            [self.houseListViewController.viewModel reloadingHouseData:condition];
//            self.needReload = mapViewFilterShouldChange;
//        }else{
//            [self requestHouses:NO showTip:YES];
//        }
//    }
//}



-(void)updateBubble:(NSString *)openUrl
{
    if (openUrl.length == 0 ) {
        return;
    }
    self.lastBubble = [FHMapSearchBubbleModel bubbleFromUrl:openUrl];
    [self.filterView selectedWithOpenUrl:openUrl];
    self.lastBubble.noneFilterQuery = self.filterView.noneFilterQuery;
        
}


-(NSString *)backHouseListOpenUrl
{
    if (self.configModel.mapOpenUrl) {        
        FHMapSearchBubbleModel *bubble = [FHMapSearchBubbleModel bubbleFromUrl:self.configModel.mapOpenUrl];
        NSRange range = [self.houseListOpenUrl rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            FHMapSearchBubbleModel *cbubble = [FHMapSearchBubbleModel bubbleFromUrl:self.houseListOpenUrl];
            NSMutableDictionary *addDict = [NSMutableDictionary new];
            for (NSString *key in bubble.queryDict.allKeys) {
                if ([key isEqualToString:@"area[]"] || [key isEqualToString:@"district[]"] || [key isEqualToString:@"line[]"]
                    || [key isEqualToString:@"station[]"] || [key isEqualToString:NEIGHBORHOOD_IDS]) {
                    addDict[key] = bubble.queryDict[key];
                }
            }
            
            NSArray *removeKeys = @[@"line[]",@"station[]",NEIGHBORHOOD_IDS,@"resize_level",@"center_latitude",@"center_longitude"];
            for (NSString *key in removeKeys) {
                [cbubble removeQueryOfKey:key];
            }

            
            [cbubble addQueryParams:addDict];
            NSString *query = [cbubble query];
            return  [[self.houseListOpenUrl substringToIndex:range.location+range.length] stringByAppendingString:query];
        }

    }
    return self.houseListOpenUrl;
}

-(void)showHoseDetailPage:(FHHouseListBaseItemModel *)model rank:(NSInteger)rank fromBubble:(FHMapSearchBubbleModel *)fromBubble
{
    //fschema://old_house_detail?house_id=xxx
    NSString *enterFrom =  @"mapfind";
    if (fromBubble.lastShowMode == FHMapSearchShowModeDrawLine) {
        enterFrom = @"circlefind";
    }else if (fromBubble.lastShowMode == FHMapSearchShowModeSubway){
        enterFrom = @"subwayfind";
    }
    
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?house_id=%@",model.houseid];
    TTRouteUserInfo *userInfo = nil;
    NSMutableDictionary *tracerDic = [NSMutableDictionary new];
    [tracerDic addEntriesFromDictionary:self.logBaseParams];
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"enter_from"] = enterFrom;
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

-(void)showNeighborhoodDetailPage:(FHMapSearchDataListModel *)neighborModel fromBubble:(FHMapSearchBubbleModel *)fromBubble
{
    NSString *enterFrom =  @"mapfind";
    if (fromBubble.lastShowMode == FHMapSearchShowModeDrawLine) {
        enterFrom = @"circlefind";
    }else if (fromBubble.lastShowMode == FHMapSearchShowModeSubway){
        enterFrom = @"subwayfind";
    }
    
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?neighborhood_id=%@",neighborModel.nid];
    NSMutableDictionary *tracerDic = [NSMutableDictionary new];
    [tracerDic addEntriesFromDictionary:self.logBaseParams];
    tracerDic[@"card_type"] = @"no_pic";
    tracerDic[@"enter_from"] = enterFrom;
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
    if (_configModel.houseType == FHHouseTypeRentHouse) {
        [strUrl appendFormat:@"&source=rent_detail"]; // 租房半屏列表进入小区
    }    
    
    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
}

-(void)showRentHouseDetailPage:(FHHouseListBaseItemModel *)model rank:(NSInteger)rank fromBubble:(FHMapSearchBubbleModel *)fromBubble
{
    NSString *enterFrom =  @"mapfind";
    if (fromBubble.lastShowMode == FHMapSearchShowModeDrawLine) {
        enterFrom = @"circlefind";
    }else if (fromBubble.lastShowMode == FHMapSearchShowModeSubway){
        enterFrom = @"subwayfind";
    }
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://rent_detail?house_id=%@&card_type=left_pic&enter_from=mapfind&element_from=half_category&rank=%ld",model.houseid,rank];
    TTRouteUserInfo *userInfo = nil;
    
    NSMutableDictionary *tracer = [[NSMutableDictionary alloc]init];
    
    [tracer addEntriesFromDictionary:[self logBaseParams]];
    tracer[@"enter_from"] = enterFrom;
    tracer[@"element_from"] = @"half_category";
    tracer[@"log_pb"] = model.logPb;
    tracer[@"card_type"] = @"left_pic";
    tracer[@"rank"] = [@(rank) description];
    
    if (model.logPb) {
        NSString *groupId = model.houseid;
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

/*
 * 列表请求去除 区域和地铁
 */
-(FHMapSearchBubbleModel *)houseListSearchBubble
{
    FHMapSearchBubbleModel *bubble = [FHMapSearchBubbleModel bubbleFromUrl:@"http://a"];
    [bubble addQueryParams:self.lastBubble.queryDict];
    [bubble removeQueryOfKey:@"district[]"];
    [bubble removeQueryOfKey:@"area[]"];
    [bubble removeQueryOfKey:@"line[]"];
    [bubble removeQueryOfKey:@"station[]"];
    [bubble removeQueryOfKey:NEIGHBORHOOD_IDS];
    return bubble;
}

#pragma mark - 画圈找房
-(void)userDrawWithXcoords:(NSArray *)xcoords ycoords:(NSArray *)yxcoords inView:(FHMapDrawMaskView *)view
{
    NSInteger count = MIN(xcoords.count, yxcoords.count);
    
    CLLocationCoordinate2D min = CLLocationCoordinate2DMake(INT_MAX, INT_MAX);
    CLLocationCoordinate2D max = CLLocationCoordinate2DMake(0, 0);
    
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D)*count);
    for (int i = 0 ; i < count ; i++) {
        CGFloat x = [xcoords[i] floatValue];
        CGFloat y = [yxcoords[i] floatValue];
        CLLocationCoordinate2D loc  = [self.mapView convertPoint:CGPointMake(x, y) toCoordinateFromView:view];
        coords[i] = loc;
        if (loc.latitude > max.latitude) {
            max.latitude = loc.latitude;
        }
        if (loc.latitude < min.latitude){
            min.latitude = loc.latitude;
        }
        if (loc.longitude > max.longitude) {
            max.longitude = loc.longitude;
        }
        if (loc.longitude < min.longitude) {
            min.longitude = loc.longitude;
        }
        
    }
    
    CGFloat minDelta = 0.0001;
    if (max.latitude - min.latitude < minDelta || max.longitude - min.longitude < minDelta) {
        //画的线
        [view clear];
        return;
    }
    
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coords count:count];
    if (self.drawLayer) {
        [self.mapView removeOverlay:self.drawLayer];
    }
    [self.mapView addOverlay:polygon];
    self.drawLayer = polygon;
    
    if (self->drawLinePoints) {
        free(self->drawLinePoints);
    }
    self->drawLinePoints = coords;
    self->drawLinePointCount = count;
    
    [view removeFromSuperview];
    [self.viewController showNavTopViews:1 animated:NO];
    
    self.drawMaxCoordinate = max;
    self.drawMinCoordinate = min;
    //move mapview
    MACoordinateRegion region;
    region.center = CLLocationCoordinate2DMake((min.latitude+max.latitude)/2, (min.longitude+max.longitude)/2);
    region.span = MACoordinateSpanMake((max.latitude - min.latitude)*1.05 , (max.longitude - min.longitude)*1.05);
    
    [self.mapView setRegion:region animated:YES];
    
    self.bottomBar.hidden = NO;
    
    [self.bottomBar hideContentBgView];
    
    if ([TTReachability isNetworkConnected]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestHouses:YES showTip:NO];
        });
    }else{
        SHOW_TOAST(@"网络异常");
        self->onSaleHouseCount = 0;
        [self.bottomBar showDrawLine:@"0套房源" withNum:0 showIndicator:NO];
    }
    
}

//画圈的坐标数组
-(NSString *)drawLineCoordinates
{
    if (self->drawLinePointCount <= 0) {
        return nil;
    }
    NSMutableString *coords = [NSMutableString new];
    for (int i = 0 ; i < self->drawLinePointCount; i++) {
        MAMapPoint point = self->drawLinePoints[i];
        if (coords.length > 0) {
            [coords appendString:@";"];
        }
        [coords appendFormat:@"%f,%f",point.x,point.y];
    }
    
    return coords;
}

-(NSString *)drawLineNeighborIds
{
    if (self.drawLineNeighbors.count == 0) {
        return nil;
    }
    
    NSMutableString *neighborIds = [NSMutableString new];
    [neighborIds appendString:@"["];
    for (FHMapSearchDataListModel *info in self.drawLineNeighbors ) {
        if (info.nid.length > 0) {
            if (neighborIds.length > 1) {
                [neighborIds appendString:@","];
            }
            [neighborIds appendString:info.nid];
        }
    }
    [neighborIds appendString:@"]"];
    return neighborIds;
}

-(void)userExit:(FHMapDrawMaskView *)view
{
    [view removeFromSuperview];
    [self.mapView removeOverlay:self.drawLayer];
    if (self.subwayLines) {
        [self.mapView removeOverlays:self.subwayLines];
    }
    self.showMode = FHMapSearchShowModeMap;
    self.lastShowMode = FHMapSearchShowModeMap;
    [self.viewController switchToNormalMode];
    self.selectedLine = nil;
    self.selectionStation = nil;
    [self.lastBubble removeQueryOfKey:@"line[]"];
    [self.lastBubble removeQueryOfKey:@"station[]"];
    [self tryUpdateSideBar];
    [self requestHouses:YES showTip:NO];
}


-(void)chooseSubWay
{
    self.selectionStation = nil;
    
    [self.tipView removeFromSuperview];
    self.showMode = FHMapSearchShowModeSubway;
    self.lastShowMode = self.showMode;
//    [self.viewController enterMapDrawMode];
    self.selectedLine = nil;
    self.selectionStation = nil;
    
    //FHHouseAnnotation
    [self.viewController enterSubwayMode];
    
    [self showSubwayPicker];
    [self addClickDrawLineOrSubwayLog:@"click_subwayfind" clickType:@"subwayfind"];
//    [self addEnterDrawOrSubwayLog:@"enter_subwayfind"];
    
}

-(void)chooseDrawLine
{
//    if (self.mapView.zoomLevel < 13) {
//        [FHMapSearchLevelPopLayer showInView:self.viewController.view atPoint:CGPointMake(self.chooseView.centerX, self.chooseView.top)];
//        return;
//    }
    
    [self.requestHouseTask cancel];
    
    [self addClickDrawLineOrSubwayLog:@"click_circlefind" clickType:@"circlefind"];
    [self addEnterDrawOrSubwayLog:@"enter_circlefind"];
    [self.tipView removeFromSuperview];
    self.showMode = FHMapSearchShowModeDrawLine;
    self.lastShowMode = self.showMode;
    [self.viewController enterMapDrawMode];
    
    //FHHouseAnnotation
    NSMutableArray *houseAnnotations = [NSMutableArray new];
    for (id annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[FHHouseAnnotation class]]) {
            [houseAnnotations addObject:annotation];
        }
    }
    [self.mapView removeAnnotations:houseAnnotations];
    
    NSString *showedGuide = @"MAP_DRAW_SHOW_GUIDE";
    if([[NSUserDefaults standardUserDefaults] boolForKey:showedGuide]){
        return;
    }

    self.drawMaskView.hidden = YES;
    
    [FHMapSearchDrawGuideView showInView:self.viewController.view dismiss:^{
        self.drawMaskView.hidden = NO;
    }];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:showedGuide];
}

-(void)reDrawMapCircle
{
    CGFloat zoomLevel = self.mapView.zoomLevel;
    BOOL showCircle = (self.configModel.houseType == FHHouseTypeSecondHandHouse) && (zoomLevel >= 13);
    if (!showCircle) {
        [[ToastManager manager] showToast:@"请放大地图后使用画圈找房"];
        return;
    }
    
    [self.mapView removeOverlay:self.drawLayer];
    [self chooseDrawLine];
}

//退出画圈找房
-(void)closeBottomBar
{
    [self addStayCircelFindLog];
    
    [self userExit:nil];
}

-(void)showNeighborList:(NSString *)tip
{
    if (self.showMode == FHMapSearchShowModeHalfHouseList) {
        //快速点击气泡
        return;
    }
    
    if (self->onSaleHouseCount == 0) {
        //0套房源
        return;
    }
    //TODO: handle show house list
    NSMutableDictionary *logParam = [self logBaseParams];
    logParam[UT_ENTER_FROM] = @"circlefind";
    logParam[UT_ENTER_TYPE] = @"click";
    logParam[UT_ELEMENT_FROM] = @"bottom_district";
    logParam[UT_CATEGORY_NAME] = @"circlefind_list";//(self.configModel.houseType == FHHouseTypeRentHouse)?@"rent_list":@"old_list";
    
    FHMapSearchBubbleModel *bubble = [self houseListSearchBubble];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://mapfind_area_house_list"];
    NSDictionary *userInfoDict = @{COORDINATE_ENCLOSURE:[self drawLineCoordinates]?:@"",
                                   NEIGHBORHOOD_IDS:[self drawLineNeighborIds]?:@"",
                                   HOUSE_TYPE_KEY:@(self.configModel.houseType),
                                   @"filter":bubble.query?:@"",
                                   @"title":[NSString stringWithFormat:@"共找到%d套房源",self->onSaleHouseCount],
                                   TRACER_KEY:logParam
                                   };
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
//    [[TTRoute sharedRoute] openURLByViewController:url userInfo:userInfo];
    WeakSelf;
    [[TTRoute sharedRoute] openURL:url userInfo:userInfo objHandler:^(TTRouteObject *routeObj) {
        wself.areaHouseListController = routeObj.instance;
        wself.areaHouseListController.title = userInfoDict[@"title"];
        [wself showAreaHouseList];
    }];
}

#pragma mark - subway
-(void)showSubwayPicker
{
    if (!_subwayPicker) {
        FHMapSubwayPickerView *picker = [[FHMapSubwayPickerView alloc]initWithFrame:self.viewController.view.bounds];
        __weak typeof(self) wself = self;
        picker.chooseStation = ^(FHSearchFilterConfigOption * _Nonnull line, FHSearchFilterConfigOption * _Nonnull station) {
            
            if (![TTReachability isNetworkConnected]) {
                [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                return ;
            }
            
            wself.lastBubble =  [FHMapSearchBubbleModel bubbleFromUrl:@"http://a"];
            [wself.lastBubble overwriteFliter:self.filterConditionParams];
            
            NSMutableDictionary *param = [NSMutableDictionary new];
            
            wself.selectedLine = line;
            wself.selectionStation = station;
            if (station.centerLatitude.floatValue > 0 && station.centerLongitude.floatValue > 0) {
                wself.mapView.centerCoordinate = CLLocationCoordinate2DMake(station.centerLatitude.floatValue, station.centerLongitude.floatValue);
                wself.lastBubble.centerLongitude = station.centerLongitude.floatValue;
                wself.lastBubble.centerLatitude = station.centerLatitude.floatValue;
            }
            CGFloat zoomLevel = station.resizeLevel.floatValue;
            if (zoomLevel < 1) {
                if ([line.value isEqualToString:station.value]) {
                    //不限
                    zoomLevel = 10;
                }else{
                    zoomLevel = 16.5;
                }
            }

            wself.mapView.zoomLevel = zoomLevel;
            wself.lastBubble.resizeLevel = zoomLevel;

            [wself requestHouses:NO showTip:NO];
            [wself.viewController switchNavbarMode:wself.showMode];
//            wself.bottomBar.hidden = NO;
            [wself addSubwayConfirmLog];
            [wself addEnterDrawOrSubwayLog:@"enter_subwayfind"];
        };
        picker.dismissBlock = ^{
            if (!wself.selectedLine) {
                [wself userExit:nil];
            }
//            wself.showMode = FHMapSearchShowModeMap;
//            [wself requestHouses:YES showTip:NO];
        };
        _subwayPicker = picker;
    }
    [self.subwayPicker showWithSubwayData:self.subwayData inView:self.viewController.view];
    
}

-(BOOL)suportSubway
{
    return self.subwayData != NULL;
}

-(FHSearchFilterConfigOption *)loadSubwayData
{
    
    FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHSearchFilterConfigItem> *filter = configModel.filter;

    FHSearchFilterConfigOption *subway = nil;
    for (FHSearchFilterConfigItem *item in filter) {
        if (item.tabId.integerValue == 1) {
            //区域
            for (FHSearchFilterConfigOption *option in item.options) {
                if ([option.type isEqualToString:@"subway"]) {
                    subway = option;
                    return subway;
                }
            }
        }
    }
    
    return nil;
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
//    if (fabs(ceil(_lastRecordZoomLevel) - ceil(zoomLevel)) > 1) {
    //添加视野埋点
    FHMapZoomViewLevelType destType = [self mapZoomViewType:zoomLevel];
    FHMapZoomViewLevelType lastType = [self mapZoomViewType:_lastRecordZoomLevel];
//    if (destType != lastType) {
        [self addMapZoomLevelTrigerby:trigerType viewTye:destType];
        _lastRecordZoomLevel = zoomLevel;
//    }
//    }
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
    param[UT_ELEMENT_FROM] = @"map";
    param[@"trigger_type"] = triger;
    if (self.showMode == FHMapSearchShowModeDrawLine) {
        param[UT_ENTER_FROM] = @"mapfind";
        TRACK_EVENT(@"circlefind_view", param);
    }else if (self.showMode == FHMapSearchShowModeSubway){
        param[UT_ENTER_FROM] = @"mapfind";
        TRACK_EVENT(@"subwayfind_view", param);
    }else{
        [FHUserTracker writeEvent:@"mapfind_view" params:param];
    }
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
        case FHMapSearchTypeStation:
            clickType = @"station";
            break;
        case FHMapSearchTypeSegment:
            clickType = @"segment";
            break;
        default:
            return;
    }

    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"click_type"] = clickType;
    if(annotation.houseData.logPb){
        param[@"log_pb"] = [annotation.houseData.logPb toDictionary];
    }
    NSString *event = @"mapfind_click_bubble";
    if (self.showMode == FHMapSearchShowModeDrawLine) {
        event = @"circlefind_click_bubble";
    }else if (self.showMode == FHMapSearchShowModeSubway){
        event = @"subwayfind_click_bubble";
    }
    
    if (self.showMode != FHMapSearchShowModeMap) {
        param[UT_ENTER_FROM] = @"mapfind";
    }
        
    [FHUserTracker writeEvent:event params:param];
}

-(void)addHouseListShowLog:(FHMapSearchDataListModel*)model houseListModel:(FHSearchHouseDataModel *)houseDataModel
{
    NSMutableDictionary *param = [self logBaseParams];
    param[@"search_id"] = houseDataModel.searchId;
    param[@"category_name"] = @"be_null";
    param[@"element_from"] = @"be_null";
    
    [FHUserTracker writeEvent:@"mapfind_half_category" params:param];
}

-(void)addSideBarHouseListLog
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = @"mapfind";
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom?:UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom?:UT_BE_NULL;
    param[@"click_position"] = @"house_category";
    
    TRACK_EVENT(@"click_options",param);
        
}

#pragma mark - 画圈找房 埋点
-(void)addClickDrawLineOrSubwayLog:(NSString *)key clickType:(NSString *)clickType
{
    
    NSMutableDictionary *param = [self logBaseParams];
    FHTracerModel *tracer = self.viewController.tracerModel;
    
    param[@"click_type"] = clickType;// @"circlefind";
    param[UT_ENTER_FROM] = @"mapfind";
    param[UT_ENTER_TYPE] = @"click";
    param[UT_ELEMENT_FROM] = nil;
    param[UT_LOG_PB] = tracer.logPb?:UT_BE_NULL;
    
    TRACK_EVENT(key, param);
}

-(void)addEnterDrawOrSubwayLog:(NSString *)key
{
    /*
     enter_circlefind    进入画圈找房页    "从地图找房
     进入画圈找房页
     "    "1. event_type：house_app2c_v2
     2. enter_from（画圈找房页入口）：地图找房：mapfind
     3. search_id
     4. origin_from
     5. origin_search_id
     6. log_pb"
     */
    _enterDrawLineTime = [NSDate date];
    NSMutableDictionary *param = [self logBaseParams];
    FHTracerModel *tracer = self.viewController.tracerModel;
    param[UT_LOG_PB] = tracer.logPb?:UT_BE_NULL;
    param[UT_ENTER_FROM] = @"mapfind";
    
    TRACK_EVENT(key, param);
}

-(void)addStayCircelFindLog
{
    NSMutableDictionary *param = [self logBaseParams];
    FHTracerModel *tracer = self.viewController.tracerModel;
    param[UT_LOG_PB] = tracer.logPb?:UT_BE_NULL;
    param[UT_ELEMENT_FROM] = nil;
    param[UT_ENTER_FROM] = @"mapfind";
    param[UT_STAY_TIME] = [NSString stringWithFormat:@"%.0f",[[NSDate date]timeIntervalSinceDate:self.enterDrawLineTime]*1000];
    
    NSString *key = (self.showMode == FHMapSearchShowModeDrawLine)?@"stay_circlefind":@"stay_subwayfind";
    
    TRACK_EVENT(key, param);
}

#pragma mark - 地铁找房埋点
-(void)addSubwayConfirmLog
{
    /*
     subway_confirm
     "1. event_type：house_app2c_v2
     2. click_type: 点击类型,,{'地铁找房': 'subwayfind'}
     4. enter_from：mapfind
     5. enter_type：进入category方式,{'点击': 'click'}
     8. origin_from
     9. origin_search_id
     10.log_pb"
     */
    NSMutableDictionary *param = [self logBaseParams];
    FHTracerModel *tracer = self.viewController.tracerModel;
    
    param[@"click_type"] = @"subwayfind";
    param[UT_ENTER_FROM] = @"mapfind";
    param[UT_ENTER_TYPE] = @"click";
    param[UT_ELEMENT_FROM] = nil;
    param[UT_LOG_PB] = tracer.logPb?:UT_BE_NULL;
    
    TRACK_EVENT(@"subway_confirm", param);
}

#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        //有网络了，重新请求
        if (self.lastShowMode != FHMapSearchShowModeDrawLine && self.lastShowMode != FHMapSearchShowModeSubway  ) {
            [self requestHouses:YES showTip:YES];
        }        
        [self.houseListViewController.viewModel reloadingHouseData:self.houseListViewController.viewModel.condition];
    }
}

@end
