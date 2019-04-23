//
//  FHDetailMapView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/12.
//

#import "FHDetailMapView.h"
#import "FHCommonDefines.h"

@interface FHDetailMapView ()

@property (nonatomic, strong)   MAMapView       *mapView;
@property (nonatomic, assign)   CGFloat       mapHightScale;
@property (nonatomic, assign)   CLLocationCoordinate2D       centerPoint;

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
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    self.mapView.runLoopMode = NSRunLoopCommonModes;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel = 14;
    self.mapView.showsUserLocation = NO;
    self.mapView.hidden = YES;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.mapView];
}

- (void)setCenterPoint:(CLLocationCoordinate2D)centerPoint {
    _centerPoint = centerPoint;
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

@end
