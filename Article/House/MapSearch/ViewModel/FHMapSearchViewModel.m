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

#define kTipDuration 3



@interface FHMapSearchViewModel ()

@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , assign) NSInteger requestMapLevel;
@property(nonatomic , weak)  TTHttpTask *requestHouseTask;
@property(nonatomic , strong) FHMapSearchHouseListViewController *houseListViewController;
@property(nonatomic , copy)  NSString *suggestionParams;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) NSString *houseTypeName;
@property(nonatomic , strong) FHHouseAnnotation *currentSelectAnnotation;
@property(nonatomic , strong) FHNeighborhoodAnnotationView *currentSelectAnnotationView;
@property(nonatomic , strong) NSMutableDictionary<NSString * , FHMapSearchDataListModel *> *selectedAnnotations;

@end

@implementation FHMapSearchViewModel

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel
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
        _showMode = FHMapSearchShowModeMap;
        _selectedAnnotations = [NSMutableDictionary new];
    }
    return self;
}

-(void)dealloc
{
    [_requestHouseTask cancel];
    
}

-(void)changeNavbarAppear:(BOOL)show
{
    [self.viewController showNavTopViews:show];
}

-(FHMapSearchHouseListViewController *)houseListViewController
{
    if (!_houseListViewController) {
        _houseListViewController = [[FHMapSearchHouseListViewController alloc]init];
        [self.viewController addChildViewController:_houseListViewController];
        _houseListViewController.view.frame = CGRectMake(0, 0, self.viewController.view.width, [self.viewController contentViewHeight]);
        __weak typeof(self) wself = self;
        _houseListViewController.willSwipeDownDismiss = ^(CGFloat duration) {
            if (wself) {
                [wself changeNavbarAppear:YES];
                wself.showMode = FHMapSearchShowModeMap;
                [wself.viewController switchNavbarMode:FHMapSearchShowModeMap];
                [wself.mapView deselectAnnotation:wself.currentSelectAnnotation animated:YES];
                wself.currentSelectAnnotation = nil;
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
            [wself changeNavbarAppear:NO];
        };
        
        _houseListViewController.showHouseDetailBlock = ^(FHSearchHouseDataItemsModel * _Nonnull model) {
            [wself showHoseDetailPage:model];
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

-(void)requestHouses
{
    if (_requestHouseTask.state == TTHttpTaskStateRunning) {
        [_requestHouseTask cancel];
    }
    
    NSString *host = [EnvContext.networkConfig.host stringByAppendingString:@"/f100/api/map_search"];
    MACoordinateRegion region = _mapView.region;
    CGFloat maxLat = region.center.latitude + region.span.latitudeDelta/2;
    CGFloat minLat = maxLat - region.span.latitudeDelta;
    CGFloat maxLong = region.center.longitude + region.span.longitudeDelta/2;
    CGFloat minLong = maxLong - region.span.longitudeDelta;
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher mapSearch:self.configModel.houseType searchId:self.searchId  maxLatitude:maxLat minLatitude:minLat maxLongitude:maxLong minLongitude:minLong resizeLevel:_mapView.zoomLevel suggestionParams:self.suggestionParams callback:^(NSError * _Nonnull error, FHMapSearchDataModel *  _Nonnull model) {
        if (!wself) {
            return ;
        }
        if (error) {
            //show toast
            return;
        }
        if (wself.showMode == FHMapSearchShowModeMap) {
            NSString *tip = model.tips;
            if (tip) {
                CGFloat topY = [wself.viewController topBarBottom];
                [wself.tipView showIn:wself.viewController.view at:CGPointMake(0, topY) content:tip duration:kTipDuration];
            }
        }
        wself.searchId = model.searchId;
        [wself addAnnotations:model.list];
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
    }

}

-(void)handleSelect:(MAAnnotationView *)annotationView
{
    if (![annotationView.annotation isKindOfClass:[FHHouseAnnotation class]]) {
        return;
    }
    FHHouseAnnotation *houseAnnotation = (FHHouseAnnotation *)annotationView.annotation;
    if (houseAnnotation.searchType == FHMapSearchTypeDistrict || houseAnnotation.searchType == FHMapSearchTypeArea) {
        //show district zoom map
        CGFloat zoomLevel = self.mapView.zoomLevel ;
        /*
         *  zoomlevel 与显示对应关系
         *  区域 7 - 13
         *  商圈 13 - 16
         *  小区 16 - 20
         */
        if (zoomLevel < 13) {
            zoomLevel = 13;
        }else if (zoomLevel < 16){
            zoomLevel = 16;
        }else{
            zoomLevel += 1;
        }
        if (zoomLevel > 20) {
            zoomLevel = 20;
        }
        
        [self.mapView setZoomLevel:zoomLevel atPivot:annotationView.center animated:YES];
        
    }else{
        //show house list
        if (self.currentSelectAnnotation.houseData) {
            _selectedAnnotations[self.currentSelectAnnotation.houseData.nid] = self.currentSelectAnnotation.houseData;
        }
        
//        if (self.currentSelectAnnotationView) {
//            self.currentSelectAnnotation.type = FHHouseAnnotationTypeOverSelected;
//            self.currentSelectAnnotationView.annotation = self.currentSelectAnnotation;
//        }
//        self.currentSelectAnnotationView = (FHNeighborhoodAnnotationView *)annotationView;
//        [self.currentSelectAnnotationView changeSelectMode:FHHouseAnnotationTypeSelected];
        
        self.currentSelectAnnotation = houseAnnotation;
        [self requestNeighborhoodHouses:houseAnnotation.houseData];
    }
}

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    [self requestHouses];
}

/**
 * @brief 地图缩放结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction
{
    if (fabs(_requestMapLevel - mapView.zoomLevel) > 0.1) {
        [self requestHouses];
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
-(void)requestNeighborhoodHouses:(FHMapSearchDataListModel *)model
{
    /*
     "exclude_id[]=\(self.houseId ?? "")&exclude_id[]=\(self.neighborhoodId)&neighborhood_id=\(self.neighborhoodId)&house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" +
     */
    
    //TODO: add loading ...
    
    NSString *searchId = @"";
    NSString *query = [NSString stringWithFormat:@""];
    NSMutableDictionary *param = [NSMutableDictionary new];
    if (model.nid) {
        param[NEIGHBORHOOD_ID_KEY] = model.nid;
    }
    param[HOUSE_TYPE_KEY] = @(self.configModel.houseType);
    
    __weak typeof(self) wself = self;
    [FHHouseSearcher houseSearchWithQuery:query param:param offset:0 needCommonParams:YES callback:^(NSError * _Nullable error, FHSearchHouseDataModel * _Nullable houseModel) {
        if (!wself) {
            return ;
        }
        if (!error && model) {
            [wself showHouseList:houseModel searchModel:model];
        }else{
            //TODO: show error toast
        }

    }];
}

-(void)showHouseList:(FHSearchHouseDataModel *)houseDataModel searchModel:(FHMapSearchDataListModel *)model
{
    [self changeNavbarAppear:NO];
    self.showMode = FHMapSearchShowModeHalfHouseList;
    
    //move annotationview to center
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(model.centerLatitude.floatValue, model.centerLongitude.floatValue);
    CGPoint annotationViewPoint = [self.mapView convertCoordinate:center toPointToView:self.mapView];
    annotationViewPoint.y += self.mapView.height/3;
    CLLocationCoordinate2D destCenter = [self.mapView convertPoint:annotationViewPoint toCoordinateFromView:self.mapView];
    [self.mapView setCenterCoordinate:destCenter animated:YES];
    [self.houseListViewController showWithHouseData:houseDataModel neighbor:model];
    
}

#pragma mark - filter delegate
-(void)onConditionChangedWithCondition:(NSString *)condition
{
    if (![self.suggestionParams isEqualToString:condition]) {
        self.suggestionParams = condition;
        [self requestHouses];
    }
    
}

-(void)showHoseDetailPage:(FHSearchHouseDataItemsModel *)model
{
    //fschema://old_house_detail?house_id=xxx
    NSString *strUrl = [NSString stringWithFormat:@"fschema://old_house_detail?house_id=%@",model.hid];
    NSURL *url =[NSURL URLWithString:strUrl];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:nil];
}


@end
