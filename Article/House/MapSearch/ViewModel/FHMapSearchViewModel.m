//
//  FHMapSearchViewModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchViewModel.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "Bubble-Swift.h"
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
@property(nonatomic , strong) FHHouseAnnotation *currentSelectAnnotation;
@property(nonatomic , strong) FHNeighborhoodAnnotationView *currentSelectAnnotationView;
@property(nonatomic , strong) NSMutableDictionary<NSString * , FHMapSearchDataListModel *> *selectedAnnotations;
@property(nonatomic , assign) NSTimeInterval startShowTimestamp;
@property(nonatomic , assign) CGFloat lastRecordZoomLevel; //for statistics
@property(nonatomic , assign) CLLocationCoordinate2D lastRequestCenter;
@property(nonatomic , assign) BOOL firstEnterLogAdded;
@property(nonatomic , copy) NSString *originCondition;

@end

@implementation FHMapSearchViewModel

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel viewController:(FHMapSearchViewController *)viewController
{
    self = [super init];
    if (self) {
        self.configModel = configModel;
        
        NSString *title = @"二手房";
        switch (configModel.houseType) {
            case HouseTypeNewHouse:{
                title = @"新房";
                break;
            }
            case HouseTypeRentHouse:{
                title = @"小区";
                break;
            }
                
            default:
                break;
        }
        self.houseTypeName = title;
        self.viewController = viewController;
        _showMode = FHMapSearchShowModeMap;
        _selectedAnnotations = [NSMutableDictionary new];
        _lastRecordZoomLevel = configModel.resizeLevel;
    }
    return self;
}

-(void)dealloc
{
    [_requestHouseTask cancel];
    
}

-(MAMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:CGRectZero];
        _mapView.rotateEnabled = false;
        _mapView.showsUserLocation = true;
        _mapView.showsCompass = false;
        _mapView.showsIndoorMap = false;
        _mapView.showsIndoorMapControl = false;
        _mapView.rotateCameraEnabled = false;
        _mapView.delegate = self;
        
        _mapView.zoomLevel = _configModel.resizeLevel;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
        representation.showsAccuracyRing = YES;
        [_mapView updateUserLocationRepresentation:representation];
        
        CLLocationCoordinate2D center = {_configModel.centerLatitude.floatValue,_configModel.centerLongitude.floatValue};        
        if (center.latitude > 0 && center.longitude > 0) {
            [_mapView setCenterCoordinate:center animated:NO];
        }
        
//        NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_map_style.data" ofType:nil];
//        NSData *styleData = [NSData dataWithContentsOfFile:stylePath];
//        if (styleData) {
//            _mapView.customMapStyleEnabled = YES;
//            [_mapView setCustomMapStyleWithWebData:styleData];
//        }
    }
    return _mapView;
}

-(void)moveToUserLocation
{
    MAUserLocation *location =  self.mapView.userLocation;
    if (location.location) {
        [self.mapView setZoomLevel:16 animated:YES];//变化到小区的范围
        [self.mapView setCenterCoordinate:location.location.coordinate animated:YES];        
    }
}

-(void)changeNavbarAppear:(BOOL)show
{
    [self.viewController showNavTopViews:show?1:0 animated:YES];
}

-(void)changeNavbarAlpha:(BOOL)animated
{
    CGFloat alpha = 1 - (self.houseListViewController.view.top - [self.houseListViewController minTop])/100;
    if (alpha < 0) {
        alpha = 0;
    }else if (alpha > 1){
        alpha = 1;
    }
    [self.viewController showNavTopViews:alpha animated:animated];
    
}

-(BOOL)conditionChanged
{
    return ![_originCondition isEqualToString: _configModel.conditionQuery];
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
        _houseListViewController.willSwipeDownDismiss = ^(CGFloat duration) {
            if (wself) {
                [wself changeNavbarAppear:YES];
                wself.showMode = FHMapSearchShowModeMap;
                [wself.viewController switchNavbarMode:FHMapSearchShowModeMap];
                [wself.mapView deselectAnnotation:wself.currentSelectAnnotation animated:YES];
                [wself moveAnnotationToCenter:wself.currentSelectAnnotation];
                wself.currentSelectAnnotation = nil;
                [wself.mapView becomeFirstResponder];
            }
        };
        _houseListViewController.didSwipeDownDismiss = ^{
            
        };
        _houseListViewController.moveToTop = ^{
            [wself changeNavbarAppear:YES];
            wself.showMode = FHMapSearchShowModeHouseList;
            [wself.viewController switchNavbarMode:FHMapSearchShowModeHouseList];
        };
        _houseListViewController.moveDock = ^{
            wself.showMode = FHMapSearchShowModeHalfHouseList;
            [wself changeNavbarAlpha:YES];
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
        
        _houseListViewController.viewModel.configModel = self.configModel;
    }
    return _houseListViewController;
}

-(NSString *)navTitle
{
    if (_showMode == FHMapSearchShowModeHouseList) {
        return _currentSelectAnnotation.houseData.name;
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

-(void)requestHouses:(BOOL)byUser showTip:(BOOL)showTip
{
    if (_requestHouseTask &&  _requestHouseTask.state == TTHttpTaskStateRunning) {
        [_requestHouseTask cancel];
    }
    
    BOOL firstEnter = _firstEnterLogAdded;
    _firstEnterLogAdded = YES;
    _lastRequestCenter = _mapView.centerCoordinate;
    
    MACoordinateRegion region = _mapView.region;
    if (region.span.latitudeDelta == 0 || region.span.longitudeDelta == 0) {
        MACoordinateRegion r = [self.mapView convertRect:self.mapView.bounds toRegionFromView:self.mapView];
        if (r.span.latitudeDelta == 0 || r.span.longitudeDelta == 0) {
            MACoordinateSpan s ;
            s.latitudeDelta = 0.1;
            s.longitudeDelta = 0.2;
            region.span = s;
        }else{
            region.span =r.span;
        }
    }
    
    CGFloat maxLat = region.center.latitude + region.span.latitudeDelta/2;
    CGFloat minLat = maxLat - region.span.latitudeDelta;
    CGFloat maxLong = region.center.longitude + region.span.longitudeDelta/2;
    CGFloat minLong = maxLong - region.span.longitudeDelta;
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher mapSearch:self.configModel.houseType searchId:self.searchId query:self.filterConditionParams maxLocation:CLLocationCoordinate2DMake(maxLat, maxLong) minLocation:CLLocationCoordinate2DMake(minLat, minLong) resizeLevel:_mapView.zoomLevel suggestionParams:nil callback:^(NSError * _Nullable error, FHMapSearchDataModel * _Nullable model) {
        
        if (!wself) {
            return ;
        }
        if (error) {
            //show toast
            [[[EnvContext shared] toast] showToast:@"房源请求失败" duration:2];
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
        
        //for enter default log
        if (!firstEnter) {
            [wself addEnterMapLog];
        }
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

        for (FHMapSearchDataListModel *info in list) {
            FHHouseAnnotation *houseAnnotation = removeAnnotationDict[info.nid];
            
            if (houseAnnotation) {
                if ([info.nid isEqualToString:self.currentSelectAnnotation.houseData.nid]) {
                    houseAnnotation.type = FHHouseAnnotationTypeSelected;
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
            if ([info.nid isEqualToString:self.currentSelectAnnotation.houseData.nid]) {
                houseAnnotation.type = FHHouseAnnotationTypeSelected;
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
    }else{
        [self.mapView removeAnnotations:self.mapView.annotations];
    }

}

-(void)handleSelect:(MAAnnotationView *)annotationView
{
    if (![TTReachability isNetworkConnected]) {
        [[[EnvContext shared] toast] showToast:@"网络异常" duration:1];
        return;
    }
    
    if (![annotationView.annotation isKindOfClass:[FHHouseAnnotation class]]) {
        return;
    }
    FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotationView.annotation;
    if (houseAnnotation.searchType == FHMapSearchTypeDistrict || houseAnnotation.searchType == FHMapSearchTypeArea) {
        //show district zoom map
        CGFloat zoomLevel = self.mapView.zoomLevel;
        /*
         *  zoomlevel 与显示对应关系
         *  区域 7 - 13
         *  商圈 13 - 16
         *  小区 16 - 20
         */
        if (zoomLevel < 7) {
            zoomLevel = 7;
        }else if (zoomLevel < 13) {
            zoomLevel = 13;
        }else if (zoomLevel < 16){
            zoomLevel = 16;
        }else{
            zoomLevel += 1;
        }
        if (zoomLevel > 20) {
            zoomLevel = 20;
        }
        
        [self tryAddMapZoomLevelTrigerby:FHMapZoomTrigerTypeClickAnnotation currentLevel:zoomLevel];
        [self.mapView setZoomLevel:zoomLevel atPivot:annotationView.center animated:YES];
        
    }else{
        //show house list
        if (self.currentSelectAnnotation.houseData) {
            _selectedAnnotations[self.currentSelectAnnotation.houseData.nid] = self.currentSelectAnnotation.houseData;
        }
        
        self.currentSelectAnnotation = houseAnnotation;
        [self showNeighborHouseList:houseAnnotation.houseData];
    }
    
    [self addClickBubbleLog:houseAnnotation];
}

-(void)moveAnnotationToCenter:(FHHouseAnnotation *)annotation
{
    if (!annotation) {
        return;
    }
    FHMapSearchDataListModel *model = annotation.houseData;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(model.centerLatitude.floatValue, model.centerLongitude.floatValue);
    [self.mapView setCenterCoordinate:center animated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    self.startShowTimestamp = [[NSDate date] timeIntervalSince1970];
//    if (self.showMode != FHMapSearchShowModeMap) {
//        [_houseListViewController viewWillAppear:animated];
//    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = now - _startShowTimestamp;
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[@"enter_from"] = @"old_list";
    param[@"search_id"] = self.searchId?:@"be_null";
    param[@"origin_from"] = self.configModel.originFrom?:@"be_null";
    param[@"origin_search_id"] = self.configModel.originSearchId ?: @"be_null";
    param[@"stay_time"] = @((NSInteger)(duration*1000));
    
    //TraceEventName
    [EnvContext.shared.tracer writeEvent:@"stay_mapfind" params:param];
    
//    if (self.showMode != FHMapSearchShowModeMap) {
//        [_houseListViewController viewWillDisappear:animated];
//    }
}

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    CLLocationCoordinate2D currentCenter = mapView.centerCoordinate;
    CGPoint ccenter = [mapView convertCoordinate:currentCenter toPointToView:mapView];
    CGPoint lcenter = [mapView convertCoordinate:_lastRequestCenter toPointToView:mapView];
    CGFloat threshold = MIN(self.viewController.view.width/2, self.viewController.view.height/3);
    threshold *= (mapView.zoomLevel/8);
    if (fabs(ccenter.x - lcenter.x) > threshold || fabs(ccenter.y - lcenter.y) > threshold) {
        [self requestHouses:wasUserAction showTip:NO];
    }
}

/**
 * @brief 地图缩放结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    if (fabs(ceil(_requestMapLevel) - ceil(mapView.zoomLevel))> 1) {
        [self tryAddMapZoomLevelTrigerby:FHMapZoomTrigerTypeZoomMap currentLevel:mapView.zoomLevel];
    }
    
    if (fabs(_requestMapLevel - mapView.zoomLevel) > 0.08*mapView.zoomLevel) {
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
    CGPoint destCenterPoint = CGPointMake(self.mapView.width/2, self.mapView.height/6);
    CGPoint currentCenterPoint = CGPointMake(self.mapView.width/2, self.mapView.height/2);
    CGPoint toMovePoint = CGPointMake(annotationViewPoint.x - destCenterPoint.x + currentCenterPoint.x, annotationViewPoint.y - destCenterPoint.y + currentCenterPoint.y);
    toMovePoint.y -= 18;//annotationview height/2
    CLLocationCoordinate2D destCenter = [self.mapView convertPoint:toMovePoint toCoordinateFromView:self.mapView];
    [self.mapView setCenterCoordinate:destCenter animated:YES];
    [self.houseListViewController showNeighborHouses:model];
    
}

#pragma mark - filter delegate
-(void)onConditionChangedWithCondition:(NSString *)condition
{
    if (!_originCondition) {
        _originCondition = condition;
        return;
    }
    
    if (![self.filterConditionParams isEqualToString:condition]) {
        self.filterConditionParams = condition;
        if (![TTReachability isNetworkConnected]) {
            [[[EnvContext shared] toast] showToast:@"网络异常" duration:1];
            return;
        }        
        if (_firstEnterLogAdded) {
            [self requestHouses:NO showTip:YES];
            if (self.showMode != FHMapSearchShowModeMap) {
                [self.houseListViewController.viewModel reloadingHouseData];
            }
        }        
    }
    
}

-(void)showHoseDetailPage:(FHSearchHouseDataItemsModel *)model rank:(NSInteger)rank
{
    //fschema://old_house_detail?house_id=xxx
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?house_id=%@&card_type=left_pic&enter_from=mapfind&element_from=half_category&rank=%ld",model.hid,rank];
    if (model.logPb) {
        NSString *groupId = model.logPb.groupId;
        NSString *imprId = model.logPb.imprId;
        NSString *searchId = model.logPb.searchId;
        if (groupId) {
            [strUrl appendFormat:@"&group_id=%@",groupId];
        }
        if (imprId) {
            [strUrl appendFormat:@"&impr_id=%@",imprId];
        }
        if (searchId) {
            [strUrl appendFormat:@"&search_id=%@",searchId];
        }
    }
    if (self.configModel.originFrom) {
        [strUrl appendFormat:@"&origin_from=%@",_configModel.originFrom];
    }
    if (_configModel.originSearchId) {
        [strUrl appendFormat:@"&origin_search_id=%@",_configModel.originSearchId];
    }
    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:nil];
}

-(void)showNeighborhoodDetailPage:(FHMapSearchDataListModel *)neighborModel
{
    NSMutableString *strUrl = [NSMutableString stringWithFormat:@"fschema://old_house_detail?neighborhood_id=%@&card_type=no_pic&enter_from=mapfind&element_from=half_category&rank=0",neighborModel.nid];
    if (neighborModel.logPb) {
        NSString *groupId = neighborModel.logPb.groupId;
        NSString *imprId = neighborModel.logPb.imprId;
        NSString *searchId = neighborModel.logPb.searchId;
        if (groupId) {
            [strUrl appendFormat:@"&group_id=%@",groupId];
        }
        if (imprId) {
            [strUrl appendFormat:@"&impr_id=%@",imprId];
        }
        if (searchId) {
            [strUrl appendFormat:@"&search_id=%@",searchId];
        }
    }
    if (self.configModel.originFrom) {
        [strUrl appendFormat:@"&origin_from=%@",_configModel.originFrom];
    }
    if (_configModel.originSearchId) {
        [strUrl appendFormat:@"&origin_search_id=%@",_configModel.originSearchId];
    }

    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:nil];
}

-(FHMapZoomViewLevelType)mapZoomViewType:(CGFloat)zoomLevel
{
    /*
     *  zoomlevel 与显示对应关系
     *  区域 7 - 13
     *  商圈 13 - 16
     *  小区 16 - 20
     */
    if (zoomLevel < 13) {
        return FHMapZoomViewLevelTypeArea;
    }else if (zoomLevel < 16){
        return FHMapZoomViewLevelTypeDistrict;
    }
    return FHMapZoomViewLevelTypeNeighborhood;
}

#pragma mark log
-(NSMutableDictionary *)logBaseParams
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[@"enter_from"] = @"old_list";
    param[@"search_id"] = self.searchId?:@"be_null";
    param[@"origin_from"] = self.configModel.originFrom?:@"be_null";
    param[@"origin_search_id"] = self.configModel.originSearchId ?: @"be_null";

    return param;
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

    [EnvContext.shared.tracer writeEvent:@"mapfind_view" params:param];
    
}


-(void)addClickBubbleLog:(FHHouseAnnotation *) annotation
{
    FHMapSearchType bubbleType = annotation.searchType;
    NSString *clickType = nil;
    switch (bubbleType) {
        case FHMapSearchTypeArea:
            clickType = @"district";            
            break;
        case FHMapSearchTypeDistrict:
            clickType = @"area";
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
    
    [EnvContext.shared.tracer writeEvent:@"mapfind_click_bubble" params:param];
}

-(void)addHouseListShowLog:(FHMapSearchDataListModel*)model houseListModel:(FHSearchHouseDataModel *)houseDataModel
{
    NSMutableDictionary *param = [self logBaseParams];
    param[@"search_id"] = houseDataModel.searchId;
    [EnvContext.shared.tracer writeEvent:@"mapfind_half_category" params:param];
}

-(void)addNavSwitchHouseListLog
{
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"enter_type"] = @"click";
    param[@"click_type"] = @"list";
    param[@"category_name"] = @"old_list";
    param[@"element_from"] = self.configModel.elementFrom ?: @"be_null";
    
    [EnvContext.shared.tracer writeEvent:@"click_switch_mapfind" params:param];
}

@end
