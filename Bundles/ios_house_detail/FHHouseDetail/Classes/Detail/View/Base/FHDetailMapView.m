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
@property (nonatomic, weak)     id<MAMapViewDelegate> origin_delegate;
@property (nonatomic, strong)   NSMutableArray       *origin_annos;

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
        _origin_annos = [NSMutableArray new];
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

// 位置和周边地图实例，外部修改中心点，记录先前的delegate和中心点
- (MAMapView *)nearbyMapviewWithFrame:(CGRect)mapFrame {
    if (self.mapView.annotations.count > 0) {
        [self.origin_annos addObjectsFromArray:self.mapView.annotations];
    }
    self.origin_delegate = self.mapView.delegate;
    
    self.origin_centerPoint = self.mapView.centerCoordinate;
    
    __weak MAMapView *map = [self defaultMapViewWithFrame:mapFrame];
    map.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [map forceRefresh];
    });
    return map;
}

// 重置详情页地图实例，恢复状态数据
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
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(160);
    }];
    // 标注点恢复，周边配套，切换“交通 购物 医院 教育”时标注点可能绘制不上去问题
    __weak typeof(self) wSelf = self;
    if (self.origin_annos.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wSelf.centerPoint = wSelf.origin_centerPoint;
            wSelf.mapView.delegate = wSelf.origin_delegate;
            [wSelf.mapView addAnnotations:wSelf.origin_annos];
            [wSelf.origin_annos removeAllObjects];
            [wSelf.mapView forceRefresh];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf.mapView forceRefresh];
        });
    }
}

@end
