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

@interface FHMapSearchViewModel ()

@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , assign) NSInteger requestMapLevel;
@property(nonatomic , weak)  TTHttpTask *requestHouseTask;
@property(nonatomic , strong) FHMapSearchHouseListViewController *houseListViewController;
@property(nonatomic , copy)  NSString *suggestionParams;
@property(nonatomic , strong) NSString *searchId;

@end

@implementation FHMapSearchViewModel

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configMode
{
    self = [super init];
    if (self) {
        self.configModel = configMode;
    }
    return self;
}

-(void)dealloc
{
    [_requestHouseTask cancel];
    
}

-(FHMapSearchHouseListViewController *)houseListViewController
{
    if (!_houseListViewController) {
        _houseListViewController = [[FHMapSearchHouseListViewController alloc]init];
        [self.viewController addChildViewController:_houseListViewController];
    }
    return _houseListViewController;
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
    TTHttpTask *task = [FHHouseSearcher mapSearch:self.configModel.houseType searchId:self.searchId  maxLatitude:maxLat minLatitude:minLat maxLongitude:maxLong minLongitude:minLong resizeLevel:_mapView.zoomLevel suggestionParams:nil callback:^(NSError * _Nonnull error, FHMapSearchDataModel *  _Nonnull model) {
        if (!wself) {
            return ;
        }
        if (error) {
            //show toast
            return;
        }
        NSString *tip = model.tips;
        if (tip) {
            CGFloat topY = 44;
            if (@available(iOS 11.0 , *)) {
                topY += wself.viewController.view.safeAreaInsets.top;
            }else{
                topY += 20;
            }
            [wself.tipView showIn:wself.viewController.view at:CGPointMake(0, topY) content:tip duration:2];
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
        
        NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
        for (NSInteger i = 0 ; i < annotations.count ;  i++) {
            id <MAAnnotation> annotation = annotations[i];
            if (![annotation isKindOfClass:[FHHouseAnnotation class]]) {
                [annotations removeObjectAtIndex:i];
            }
        }
        [self.mapView removeAnnotations: annotations];
        for (FHMapSearchDataListModel *info in list) {
            
            CGFloat lat = [info.centerLatitude floatValue];
            CGFloat lon = [info.centerLongitude floatValue];
            
            FHHouseAnnotation *houseAnnotation = [[FHHouseAnnotation alloc] init];
            houseAnnotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
            houseAnnotation.title = info.name;
            houseAnnotation.subtitle = info.desc;
            houseAnnotation.houseData = info;
            houseAnnotation.searchType = [info.type integerValue];
            
            [self.mapView addAnnotation:houseAnnotation];
        }
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
        if (zoomLevel < 14) {
            zoomLevel += 2;
        }else{
            zoomLevel += 1;
        }
        [self.mapView setZoomLevel:zoomLevel atPivot:annotationView.center animated:YES];
        
    }else{
        //show house list
        [self requestNeighborhoodHouses:houseAnnotation.houseData];
    }
}

-(void)showMapViewInfo
{
    NSLog(@"map level is: %lf ",self.mapView.zoomLevel);
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
            }
            
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -18);
            annotationView.canShowCallout = NO;
            return annotationView;
        }
    }
    
    return nil;
}

/**
 * @brief 当mapView新添加annotation views时，调用此接口
 * @param mapView 地图View
 * @param views 新添加的annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"---%@---",NSStringFromSelector(_cmd));
    [self showMapViewInfo];
}

///**
// * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
// * @param mapView 地图View
// * @param view 选中的annotation view
// */
//- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
//{
//    NSLog(@"---%@---",NSStringFromSelector(_cmd));
//    [self showMapViewInfo];
//    [self handleSelect:view];
//}

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    NSLog(@"---%@---",NSStringFromSelector(_cmd));
    [self showMapViewInfo];
}


/**
 * @brief 标注view被点击时，触发该回调。（since 5.7.0）
 * @param mapView 地图的view
 * @param view annotationView
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewTapped:(MAAnnotationView *)view
{
    NSLog(@"---%@---",NSStringFromSelector(_cmd));
    [self showMapViewInfo];
    [self handleSelect:view];
}


/**
 * @brief 长按地图，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"---%@---",NSStringFromSelector(_cmd));
    [self showMapViewInfo];
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
            [wself.houseListViewController showWithHouseData:houseModel neighbor:model];
        }else{
            //TODO: show error toast
        }

    }];
}

#pragma mark - filter delegate
-(void)onConditionChangedWithCondition:(NSString *)condition
{
    self.suggestionParams = condition;
}

@end
