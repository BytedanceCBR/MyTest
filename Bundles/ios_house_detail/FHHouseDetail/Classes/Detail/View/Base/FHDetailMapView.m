//
//  FHDetailMapView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/12.
//

#import "FHDetailMapView.h"
#import "FHCommonDefines.h"
#import <Masonry/Masonry.h>

@interface FHDetailMapView ()

@property (nonatomic, strong)   MAMapView       *mapView;
@property (nonatomic, assign)   CGFloat       mapHightScale;
@property (nonatomic, assign)   CLLocationCoordinate2D       centerPoint;
@property (nonatomic, assign)   CGRect       originDetailFrame;
@property (nonatomic, assign)   CLLocationCoordinate2D       origin_centerPoint;
@property (nonatomic, weak) id<MAMapViewDelegate> origin_delegate;

@end

@implementation FHDetailMapView

+ (instancetype)sharedInstance {
    static FHDetailMapView *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[FHDetailMapView alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mapHightScale = 0.36;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.originDetailFrame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    self.mapView = [[MAMapView alloc] initWithFrame:self.originDetailFrame];
    self.mapView.runLoopMode = NSRunLoopCommonModes;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel = 14;
    self.mapView.showsUserLocation = NO;
    self.mapView.hidden = YES;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(160);
    }];
}

- (void)setCenterPoint:(CLLocationCoordinate2D)centerPoint {
    _centerPoint = centerPoint;
    _origin_centerPoint = centerPoint;
    [self.mapView setCenterCoordinate:centerPoint animated:NO];
}

- (void)clearAnnotationDatas {
    NSArray *annos = self.mapView.annotations;
    if (annos.count > 0) {
        [self.mapView removeAnnotations:annos];
    }
}

- (MAMapView *)defaultMapView {
    return [self defaultMapViewWithFrame:self.mapView.frame];
}

- (MAMapView *)defaultMapViewWithFrame:(CGRect)mapFrame {
    return [self defaultMapViewWithPoint:_centerPoint frame:mapFrame];
}

- (MAMapView *)defaultMapViewWithPoint:(CLLocationCoordinate2D)center frame:(CGRect)mapFrame {
    [self clearAnnotationDatas];
    if (center.latitude > 0 && center.longitude > 0) {
        self.centerPoint = center;
    }
    self.mapView.frame = mapFrame;
    return self.mapView;
}

// 位置和周边地图实例，外部修改中心点
- (MAMapView *)nearbyMapviewWithFrame:(CGRect)mapFrame {
    MAMapView *map = [self defaultMapViewWithFrame:mapFrame];
    self.origin_delegate = map.delegate;
    self.origin_centerPoint = map.centerCoordinate;
    map.hidden = NO;
    return map;
}

// 重置详情页地图实例
- (void)resetDetailMapView {
    self.mapView.hidden = YES;
    [self clearAnnotationDatas];
    self.mapView.runLoopMode = NSRunLoopCommonModes;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel = 14;
    self.mapView.showsUserLocation = NO;
    self.centerPoint = self.origin_centerPoint;
    self.mapView.delegate = self.origin_delegate;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.mapView];
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(160);
    }];
}

@end
