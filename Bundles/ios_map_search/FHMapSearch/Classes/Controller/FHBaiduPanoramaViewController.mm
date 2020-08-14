//
//  FHBaiduPanoramaViewController.m
//  Pods
//
//  Created by bytedance on 2020/7/15.
//

#import "FHBaiduPanoramaViewController.h"
#import <F100BaiduMapKit/BaiduPanoUtils.h>
#import <F100BaiduMapKit/BaiduPanoramaView.h>
#import <F100BaiduMapKit/BMKBaseComponent.h>
#import <F100BaiduMapKit/BMKMapComponent.h>
#import <F100BaiduMapKit/BMKSearchComponent.h>
#import <F100BaiduMapKit/BMKMapComponent.h>
#import <F100BaiduMapKit/BMKUtilsComponent.h>

#import "TTSandBoxHelper.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <ByteDanceKit/UIView+BTDAdditions.h>
#import <objc/runtime.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import "UIViewController+Track.h"
#import <FHHouseBase/FHUserTracker.h>
#import "TTReachability.h"
#import "ToastManager.h"

char *const FHBaiduPanoramaPOISearchResultKeyName = "FHBaiduPanoramaPOISearchResultKeyName";
char *const FHBaiduPanoramaPOISearchResultTypeName = "FHBaiduPanoramaPOISearchResultTypeName";

@interface BMKPoiSearch (fh_property)
@property (nonatomic, copy) NSString *fh_keyword;
@end

@implementation BMKPoiSearch (fh_property)
- (void)setFh_keyword:(NSString *)fh_keyword {
    objc_setAssociatedObject(self, FHBaiduPanoramaPOISearchResultKeyName, fh_keyword, OBJC_ASSOCIATION_COPY);
}

- (NSString *)fh_keyword {
    return objc_getAssociatedObject(self, FHBaiduPanoramaPOISearchResultKeyName);
}
@end

@interface BaiduPanoImageOverlay (fh_property)

@property (nonatomic, copy) NSString *fh_name;
@property (nonatomic, copy) NSString *fh_imageName;
@property (nonatomic) NSInteger fh_distance;

@end

@implementation BaiduPanoImageOverlay (fh_property)

- (void)setFh_name:(NSString *)fh_name {
    objc_setAssociatedObject(self, @selector(fh_name), fh_name, OBJC_ASSOCIATION_COPY);
}

- (NSString *)fh_name {
    return objc_getAssociatedObject(self, @selector(fh_name));
}

- (void)setFh_imageName:(NSString *)fh_imageName {
    objc_setAssociatedObject(self, @selector(fh_imageName), fh_imageName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)fh_imageName {
    return objc_getAssociatedObject(self, @selector(fh_imageName));
}

- (void)setFh_distance:(NSInteger)fh_distance {
    objc_setAssociatedObject(self, @selector(fh_distance), @(fh_distance), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)fh_distance {
    NSNumber *distance = objc_getAssociatedObject(self, @selector(fh_distance));
    return [distance integerValue];
}

@end

@interface FHBaiduPanoramaViewController ()<BMKGeneralDelegate,BMKMapViewDelegate,BaiduPanoramaViewDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, weak) UIButton *overlayButton;
@property (nonatomic, weak) UIButton *zoomButton;
@property (nonatomic, weak) UIButton *headingButton;
@property (nonatomic, weak) UIButton *originPositionButton;

@property (nonatomic, strong) BaiduPanoramaView *panoramaView;

@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic, strong) BMKMapManager *mapManager;

@property (nonatomic) double gaodeLat;
@property (nonatomic) double gaodeLon;

@property (nonatomic) CLLocationCoordinate2D firstLoadPoint;
@property (nonatomic) CLLocationCoordinate2D point;
@property (nonatomic) CLLocationCoordinate2D lastPoint;

@property (nonatomic, strong) UIImage *gradientImage;

@property (nonatomic, strong) NSMutableArray *overlays;
@property (nonatomic, strong) NSMutableArray *filterPoiList;
@property (nonatomic, strong) NSMutableDictionary *limitDict;

@property (nonatomic) BOOL isZoomMapAnimation;

@property (nonatomic, assign) UIStatusBarStyle lastStatusBarStyle;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, strong) BaiduPanoImageOverlay *selectOverlay;

@property (nonatomic, strong) NSMutableArray *testArray;
@end

@implementation FHBaiduPanoramaViewController

- (NSMutableArray *)testArray {
    if (!_testArray) {
        _testArray = [NSMutableArray array];
    }
    return _testArray;
}

- (void)dealloc {
    [[UIApplication sharedApplication] setStatusBarStyle:_lastStatusBarStyle];
}

+ (NSString *)baiduAK {
    return [TTSandBoxHelper isInHouseApp] ? @"9Q6O7p5wl7wz2F5DELMyqqlaGesstoLf" : @"3oO4DAuGjZu1IBz4UwmhOXWHoLRQZTpo";;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        [self setupMapManager];
        
        _lastStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        self.isResetStatusBar = NO;
        
        self.ttDisableDragBack = NO;
        self.ttDragBackLeftEdge = 20;
        if (paramObj.allParams[@"gaodeLat"]) {
            self.gaodeLat = [paramObj.allParams btd_doubleValueForKey:@"gaodeLat"];
        }
        if (paramObj.allParams[@"gaodeLon"]) {
            self.gaodeLon = [paramObj.allParams btd_doubleValueForKey:@"gaodeLon"];
        }
        
        self.firstLoadPoint = kCLLocationCoordinate2DInvalid;
        self.point = [BaiduPanoUtils baiduCoorEncryptLon:self.gaodeLon lat:self.gaodeLat coorType:COOR_TYPE_COMMON];
        self.serialQueue = dispatch_queue_create("baidu_pano_serial_queue", DISPATCH_QUEUE_SERIAL);
        [self addGoDetailLog];
    }
    return self;
}

- (NSMutableArray *)overlays {
    if (!_overlays) {
        _overlays = [NSMutableArray array];
    }
    return _overlays;
}

- (NSMutableArray *)filterPoiList {
    if (!_filterPoiList) {
        _filterPoiList = [NSMutableArray array];
    }
    return _filterPoiList;
}

- (void)setupMapManager {
    self.mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:[self.class baiduAK] generalDelegate:self];
    if (!ret) {
        NSLog(@"baidu_start_fail");
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self setupTopBottomBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)setupTopBottomBar {
    CGFloat topInset = 0;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    if (topInset < 1) {
        topInset = 20;
    }
    self.topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44 + topInset)];
    self.topBar.backgroundColor = [UIColor clearColor]; //[UIColor colorWithHexString:@"#000000" alpha:0.3];
    [self.view addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(44 + topInset);
    }];
        
    UIImageView *topBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_detail_header_bg"]];
    topBgImageView.frame = self.topBar.bounds;
    [self.topBar addSubview:topBgImageView];
    [topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
        
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]) forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]) forState:UIControlStateHighlighted];
    //    self.customNavBarView.backgroundColor = [UIColor clearColor];
    //    self.customNavBarView.seperatorLine.hidden = YES;
    self.customNavBarView.title.textColor = [UIColor themeWhite];
    [self.customNavBarView cleanStyle:YES];
    [self.customNavBarView setNaviBarTransparent:YES];
    [self.customNavBarView removeFromSuperview];
    [self.topBar addSubview:self.customNavBarView];
    [self.customNavBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topInset);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"baidu_panorama_overlay_show"] forState:UIControlStateNormal];
    [overlayButton setImage:[UIImage imageNamed:@"baidu_panorama_overlay_hidden"] forState:UIControlStateSelected];
    [overlayButton addTarget:self action:@selector(overlayButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:overlayButton];
    self.overlayButton = overlayButton;
    [self.overlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.centerY.mas_equalTo(self.customNavBarView.leftBtn);
        make.right.mas_equalTo(-5);
    }];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)-120, CGRectGetWidth(self.view.bounds), 120)];
    self.mapView.delegate = self;
    self.mapView.centerCoordinate = self.point;
//    self.mapView.buildingsEnabled = NO;
//    self.mapView.showMapPoi = NO;
    self.mapView.rotateEnabled = NO;
//    self.mapView.overlookEnabled = NO;
//    self.mapView.showMapScaleBar = NO;
    self.mapView.zoomLevel = 18;
    [self.mapView setMapType:BMKMapTypeStandard];
    self.mapView.layer.masksToBounds = YES;
    self.mapView.layer.cornerRadius = 4.0;
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-40);
        make.width.mas_equalTo(42);
        make.height.mas_equalTo(42);
    }];
    
    UIButton *originPositionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    originPositionButton.backgroundColor = [UIColor whiteColor];
    originPositionButton.layer.masksToBounds = YES;
    originPositionButton.layer.cornerRadius = 4.0;
    [originPositionButton setImage:[UIImage imageNamed:@"baidu_panorama_location_icon"] forState:UIControlStateNormal];
    [originPositionButton addTarget:self action:@selector(originPositionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:originPositionButton];
    self.originPositionButton = originPositionButton;
    [self.originPositionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(self.mapView.mas_top).mas_offset(-20);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    UIButton *headingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headingButton.backgroundColor = [UIColor clearColor];
    [headingButton setImage:[UIImage imageNamed:@"baidu_panorama_direction_big_icon"] forState:UIControlStateNormal];
    headingButton.userInteractionEnabled = YES;
    [headingButton addTarget:self action:@selector(headingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headingButton];
    self.headingButton = headingButton;
    [self.headingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(47, 47));
        make.centerX.mas_equalTo(self.mapView.mas_centerX);
        make.centerY.mas_equalTo(self.mapView.mas_centerY);
    }];
    
    
    UIButton *zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomButton.backgroundColor = [UIColor clearColor];
    [zoomButton setImage:[UIImage imageNamed:@"baidu_panorama_scale_icon"] forState:UIControlStateNormal];
    [zoomButton addTarget:self action:@selector(zoomButtonAction) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.alpha = 0;
    [self.mapView addSubview:zoomButton];
    self.zoomButton = zoomButton;
    [self.zoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.top.mas_equalTo(0);
    }];
}

- (void)setupUI {
    self.panoramaView = [[BaiduPanoramaView alloc] initWithFrame:self.view.bounds key:[self.class baiduAK]];
    self.panoramaView.delegate = self;
    [self.view addSubview:self.panoramaView];
    [self.panoramaView setPanoramaWithLon:self.point.longitude lat:self.point.latitude];
    [self.panoramaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - Action
- (void)originPositionButtonAction {
    double distance = [self distanceBetweenOrderBy:self.firstLoadPoint other:self.point];
    if (distance < 1.0) {
        return;
    }
    self.point = [BaiduPanoUtils baiduCoorEncryptLon:self.gaodeLon lat:self.gaodeLat coorType:COOR_TYPE_COMMON];
    self.mapView.zoomLevel = 18;
    [self.mapView setCenterCoordinate:self.point animated:YES];
    [self.panoramaView setPanoramaWithLon:self.point.longitude lat:self.point.latitude];
}

- (void)zoomButtonAction {
    self.isZoomMapAnimation = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.mapView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-40);
            make.width.mas_equalTo(42);
            make.height.mas_equalTo(42);
        }];
        self.mapView.layer.cornerRadius = 4.0;
        self.zoomButton.alpha = .0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.zoomButton.hidden = YES;
        self.headingButton.userInteractionEnabled = YES;
        self.isZoomMapAnimation = NO;
    }];
}

- (void)headingButtonAction {
    self.headingButton.userInteractionEnabled = NO;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.isZoomMapAnimation = YES;
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.mapView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(120 + bottomInset);
        }];
        self.mapView.layer.cornerRadius = .0;
        self.zoomButton.hidden = NO;
        self.zoomButton.alpha = 1.0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isZoomMapAnimation = NO;
    }];
}

- (void)overlayButtonAction {
//    [self.panoramaView removeAllOverlay];
//    [self.overlays removeAllObjects];
//    [self addOverlays:self.testArray];
//
//    [self.testArray removeAllObjects];
//    return;
    self.overlayButton.selected = !self.overlayButton.selected;
    [self.panoramaView setAllCustomOverlaysHidden:self.overlayButton.selected];
    [self.panoramaView setPoiOverlayHidden:self.overlayButton.selected];
}

- (void)searchCurrentPOI {
    /**
    
    radius 1000
    isRadiusLimit true
    BMK_POI_SCOPE_DETAIL_INFORMATION
    
    关键字类型 取前三
     
     //@"银行",@"公交",@"地铁",@"教育",@"医院",@"商场",@"小区"
    */

    [self.filterPoiList removeAllObjects];
    [self.panoramaView removeAllOverlay];
    [self.overlays removeAllObjects];
    self.limitDict = @{@"公交": @(0),
                       @"地铁": @(0),
                       @"教育": @(0),
                       @"医院": @(0),
                       @"商场": @(0),
                       @"小区": @(0)}.mutableCopy;
    
    for (NSString *keyword in @[@"公交",@"地铁",@"教育",@"医院",@"商场",@"小区"]) {
        BMKPoiSearch *poiSearch = [[BMKPoiSearch alloc] init];
        poiSearch.delegate = self;
        poiSearch.fh_keyword = keyword;
        BMKPOINearbySearchOption *option = [[BMKPOINearbySearchOption alloc] init];
        option.keywords = @[keyword];
        option.location = self.point;
        option.radius = 1000;
        option.isRadiusLimit = YES;
        option.scope = BMK_POI_SCOPE_DETAIL_INFORMATION;
//        option.pageIndex = 0;
        option.pageSize = 20;
        [poiSearch poiSearchNearBy:option];
    }
    
    if (!self.selectOverlay) {
        BMKGeoCodeSearch *geoSearch = [[BMKGeoCodeSearch alloc] init];
        geoSearch.delegate = self;
        BMKReverseGeoCodeSearchOption *geoSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
        geoSearchOption.location = self.point;
        geoSearchOption.isLatestAdmin = YES;
        geoSearchOption.pageSize = 1;
        geoSearchOption.pageNum = 0;
        [geoSearch reverseGeoCode:geoSearchOption];
    }
}

static NSInteger overlayIndex = 0;

- (void)handlePoiResult:(BMKPOISearchResult *)poiResult keyword:(NSString *)keyword{
    dispatch_async(self.serialQueue, ^{
        NSMutableArray *overlays = [NSMutableArray array];
        for (BMKPoiInfo *poiInfo in poiResult.poiInfoList) {
            if (!poiInfo.hasDetailInfo) {
                if ([keyword isEqualToString:@"公交"]) {
                    BMKPOIDetailInfo *detailIn = [[BMKPOIDetailInfo alloc] init];
                    detailIn.type = @"bus";
                    detailIn.tag = keyword;
                    detailIn.distance = [self distanceBetweenOrderBy:self.point other:poiInfo.pt];
                    poiInfo.detailInfo = detailIn;
                } else {
                    continue;
                }
            }
            
            BMKPOIDetailInfo *detailInfo = poiInfo.detailInfo;
            NSString *type = detailInfo.type;
            if ([detailInfo.tag containsString:@"atm"]) {
                continue;
            }
            if (!detailInfo.tag.length) {
                //                [self.filterPoiList addObject:poiInfo];
                continue;
            }
            if (detailInfo.distance < 10) {
                continue;
            }
            NSString *name = poiInfo.name;
            NSString *typeName = keyword;
            //tag

            if (!typeName.length) {
                if ([detailInfo.type isEqualToString:@"education"]) {
                    typeName = @"教育";
                } else if ([detailInfo.type isEqualToString:@"hospital"]) {
                    typeName = @"医院";
                } else if ([detailInfo.type isEqualToString:@"shopping"]) {
                    typeName = @"商场";
                } else if ([detailInfo.type isEqualToString:@"house"]) {
                    typeName = @"小区";
                } else if ([detailInfo.tag containsString:@"地铁"]) {
                    typeName = @"地铁";
                }
            }
            if (!typeName.length) {
                continue;
            }
            if (self.limitDict[typeName]) {
                NSInteger limit = [[self.limitDict objectForKey:typeName] integerValue];
                if (limit >= 3) {
                    continue;
                }
                //名称去重
                __block NSUInteger index = NSNotFound;
                [self.filterPoiList enumerateObjectsUsingBlock:^(BMKPoiInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.name isEqualToString:poiInfo.name]) {
                        index = idx;
                        *stop = YES;
                    }
                }];
                if (index != NSNotFound) {
                    continue;
                }

                limit += 1;
                self.limitDict[typeName] = @(limit);
            } else {
                self.limitDict[typeName] = @(1);
            }
            [self.filterPoiList addObject:poiInfo];
            
            NSString *imageName = nil;
            //@"公交",@"地铁",@"教育",@"医院",@"商场",@"小区"
            if ([typeName isEqualToString:@"公交"]) {
                imageName = @"baidu_overlay_type_bus";
            } else if ([typeName isEqualToString:@"银行"]) {
                imageName = @"baidu_overlay_type_bank";
            }else if ([typeName isEqualToString:@"地铁"]) {
                imageName = @"baidu_overlay_type_subway";
            } else if ([typeName isEqualToString:@"教育"]) {
                imageName = @"baidu_overlay_type_school";
            } else if ([typeName isEqualToString:@"医院"]) {
                imageName = @"baidu_overlay_type_hospital";
            } else if ([typeName isEqualToString:@"商场"]) {
                imageName = @"baidu_overlay_type_shop";
            } else if ([typeName isEqualToString:@"小区"]) {
                imageName = @"baidu_overlay_type_area";
            }
            
            //type

            overlayIndex += 1;
            BaiduPanoImageOverlay *overlay = [[BaiduPanoImageOverlay alloc] init];
            overlay.overlayKey = [@(overlayIndex) stringValue];
            overlay.type = BaiduPanoOverlayTypeImage;
            overlay.coordinate = poiInfo.pt;
            overlay.height = 0;
            overlay.fh_imageName = imageName;
            overlay.fh_name = poiInfo.name;
            overlay.fh_distance = detailInfo.distance;
            [overlays addObject:overlay];
        }
        if (overlays.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addOverlays:overlays.copy];
            });
        }
    });
}

- (void)addOverlays:(NSArray *)overlays {
    for (BaiduPanoImageOverlay *overlay in overlays) {
        //重叠问题，添加到全景上以后，后续的点都要与前面的比对，有重复的height 增加
        UIImage *image = [self imageWithName:overlay.fh_name icon:[UIImage imageNamed:overlay.fh_imageName] distance:overlay.fh_distance];
        overlay.image = image;
        overlay.size = image.size;
        
        double overlayAngle = [self computeAzimuthBy:self.point other:overlay.coordinate];
        for (BaiduPanoImageOverlay *item in self.overlays) {
            double itemAngle = [self computeAzimuthBy:self.point other:item.coordinate];
            if (abs(overlayAngle - itemAngle) < 20) {
                double distance = [self distanceBetweenOrderBy:self.point other:overlay.coordinate];
                double itemDistance = [self distanceBetweenOrderBy:self.point other:item.coordinate];
                if (abs(overlay.height - item.height * distance/itemDistance) < 20) {
                    CGFloat heightRate = distance/1000.0 * 200;
                    overlay.height += heightRate;
                }
            }
        }
        [self.overlays addObject:overlay];
        [self.panoramaView addOverlay:overlay];
    }
}

//两个经纬度之间的角度
//- (double)getBearingWithLat1:(double)lat1 whitLng1:(double)lng1 whitLat2:(double)lat2 whitLng2:(double)lng2{
//
//    double d = 0;
//    double radLat1 =  [self radian:lat1];
//    double radLat2 =  [self radian:lat2];
//    double radLng1 = [self radian:lng1];
//    double radLng2 =  [self radian:lng2];
//    d = sin(radLat1)*sin(radLat2)+cos(radLat1)*cos(radLat2)*cos(radLng2-radLng1);
//    d = sqrt(1-d*d);
//    d = cos(radLat2)*sin(radLng2-radLng1)/d;
//    d = [self angle:asin(d)];
//    return d;
//}
//根据角度计算弧度
-(double)radian:(double)d{
    
    return d * M_PI/180.0;
}
//根据弧度计算角度
-(double)angle:(double)r{
    
    return r * 180/M_PI;
}

-(double)distanceBetweenOrderBy:(CLLocationCoordinate2D ) point other:(CLLocationCoordinate2D) otherPoint {
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:otherPoint.latitude longitude:otherPoint.longitude];
    double distance  = [curLocation distanceFromLocation:otherLocation];
    return distance;
}

- (double)computeAzimuthBy:(CLLocationCoordinate2D ) point other:(CLLocationCoordinate2D) otherPoint {
    double lat1 = point.latitude, lon1 = point.longitude, lat2 = otherPoint.latitude,
            lon2 = otherPoint.longitude;
    double result = 0.0;

    int ilat1 = (int) (0.50 + lat1 * 360000.0);
    int ilat2 = (int) (0.50 + lat2 * 360000.0);
    int ilon1 = (int) (0.50 + lon1 * 360000.0);
    int ilon2 = (int) (0.50 + lon2 * 360000.0);
//
//    lat1 = Math.toRadians(lat1);
//    lon1 = Math.toRadians(lon1);
//    lat2 = Math.toRadians(lat2);
//    lon2 = Math.toRadians(lon2);
    lat1 =  [self radian:lat1];
    lat2 =  [self radian:lat2];
    lon1 = [self radian:lon1];
    lon2 =  [self radian:lon2];

    if ((ilat1 == ilat2) && (ilon1 == ilon2)) {
        return result;
    } else if (ilon1 == ilon2) {
        if (ilat1 > ilat2)
            result = 180.0;
    } else {
        double c = acos(sin(lat2) * sin(lat1) + cos(lat2)
                        * cos(lat1) * cos((lon2 - lon1)));
        double A = asin(cos(lat2) * sin((lon2 - lon1))
                / sin(c));
//        result = Math.toDegrees(A);
        result = [self angle:A];
        if ((ilat2 > ilat1) && (ilon2 > ilon1)) {
        } else if ((ilat2 < ilat1) && (ilon2 < ilon1)) {
            result = 180.0 - result;
        } else if ((ilat2 < ilat1) && (ilon2 > ilon1)) {
            result = 180.0 - result;
        } else if ((ilat2 > ilat1) && (ilon2 < ilon1)) {
            result += 360.0;
        }
    }
    return result;
}

- (UIImage *)imageWithName:(NSString *)name icon:(UIImage *)icon distance:( NSInteger )distance {
    
    CGFloat titleWidth = 137 - 44 - 10;
    CGFloat titleCalculateWidth = [name btd_widthWithFont:[UIFont themeFontMedium:12] height:17];
    
    CGFloat totalWidth = 137;
    if (titleCalculateWidth > titleWidth) {
        totalWidth += (titleCalculateWidth - titleWidth);
    }
    
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, 51)];
    overlayView.layer.opaque = NO;
    overlayView.layer.cornerRadius = 4.0;
    overlayView.layer.masksToBounds = YES;
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    overlayView.opaque = NO;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:icon];
    iconImageView.contentMode = UIViewContentModeCenter;
    iconImageView.frame = CGRectMake(0, 0, 34, 51);
    [overlayView addSubview:iconImageView];
    
    UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(34, 16, 1, 20)];
    gradientImageView.image = self.gradientImage;
    [overlayView addSubview:gradientImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 10, totalWidth - 44 - 10, 17)];
    titleLabel.textColor = [UIColor themeWhite];
    titleLabel.font = [UIFont themeFontMedium:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = name;
    [overlayView addSubview:titleLabel];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLabel.frame), CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(titleLabel.frame), 14)];
    infoLabel.font = [UIFont themeFontRegular:10];
    infoLabel.textColor = [UIColor themeWhite];
    NSMutableAttributedString *infoString = [[NSMutableAttributedString alloc] initWithString:@"直线距离约 "];
    [infoString addAttributes:@{NSForegroundColorAttributeName : [UIColor themeWhite]} range:NSMakeRange(0, infoString.length)];
    [infoString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%dm",distance] attributes:@{NSForegroundColorAttributeName : [UIColor themeOrange1]}]];
    infoLabel.attributedText = infoString;
    [overlayView addSubview:infoLabel];
    
    return [overlayView btd_snapshotImage];
}

- (UIImage *)gradientImage {
    if (!_gradientImage) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = imageView.bounds;
        gradientLayer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor,(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.locations = @[@0,@0.5,@1];
        [imageView.layer addSublayer:gradientLayer];
        _gradientImage = [imageView btd_snapshotImage];
    }
    return _gradientImage;
}

#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
    NSLog(@"baidu_onGetNetworkState %d",iError);
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError {
    NSLog(@"baidu_onGetPermissionState %d",iError);
}

#pragma mark - 全景回掉
/**
 * @abstract 全景图将要加载
 * @param panoramaView 当前全景视图
 */
- (void)panoramaWillLoad:(BaiduPanoramaView *)panoramaView {
    NSLog(@"baidu_panoramaWillLoad");
}

/**
 * @abstract 全景图加载完毕
 * @param panoramaView 当前全景视图
 * @param jsonStr 全景单点信息
 *
 */
- (void)panoramaDidLoad:(BaiduPanoramaView *)panoramaView descreption:(NSString *)jsonStr {
    NSLog(@"baidu_panoramaDidLoad");
    [self searchCurrentPOI];
    self.lastPoint = kCLLocationCoordinate2DInvalid;
    
    if (jsonStr.length) {
        NSDictionary *jsonDict = [jsonStr btd_jsonDictionary];
        if (jsonDict[@"X"] && jsonDict[@"Y"]) {
            double lon = [jsonDict btd_doubleValueForKey:@"X"]/100.0;
            double lat = [jsonDict btd_doubleValueForKey:@"Y"]/100.0;
            self.point = [BaiduPanoUtils baiduCoorEncryptLon:lon lat:lat coorType:COOR_TYPE_BDMC];
            if (self.selectOverlay) {
                self.customNavBarView.title.text = self.selectOverlay.fh_name;
                BaiduPanoImageOverlay *overlay = [[BaiduPanoImageOverlay alloc] init];
                overlay.overlayKey = [@(overlayIndex) stringValue];
                overlay.type = BaiduPanoOverlayTypeImage;
                overlay.coordinate = self.selectOverlay.coordinate;
                overlay.height = 0;
                overlay.fh_imageName = self.selectOverlay.fh_imageName;
                overlay.fh_name = self.selectOverlay.fh_name;
                overlay.fh_distance = self.selectOverlay.fh_distance;
                overlay.size = self.selectOverlay.size;
                overlay.image = [self imageWithName:self.selectOverlay.fh_name icon:[UIImage imageNamed:self.selectOverlay.fh_imageName] distance:[self distanceBetweenOrderBy:self.point other:self.selectOverlay.coordinate]];
                [self.overlays addObject:overlay];
                [self.panoramaView addOverlay:overlay];
                self.selectOverlay = nil;
                
                double overlayHeading = [self computeAzimuthBy:self.point other:overlay.coordinate];
                [self.panoramaView setPanoramaHeading:overlayHeading];
            }
            if (CLLocationCoordinate2DIsValid(self.point)) {
                if (!CLLocationCoordinate2DIsValid(self.firstLoadPoint)) {
                    self.firstLoadPoint = self.point;
                }
                self.isZoomMapAnimation = YES;
                [self.mapView setCenterCoordinate:self.point animated:YES];
            }
        }
    }
}

/**
 * @abstract 全景图加载失败
 * @param panoramaView 当前全景视图
 * @param error 加载失败的返回信息
 *
 */
- (void)panoramaLoadFailed:(BaiduPanoramaView *)panoramaView error:(NSError *)error {
    NSLog(@"baidu_panoramaLoadFailed error:%@",error);
    self.selectOverlay = nil;
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常" style:FHToastViewStyleDefault position:FHToastViewPositionBottom verticalOffset:-20];
    } else {
        [[ToastManager manager] showToast:@"该地区不支持全景信息，请重新选择" style:FHToastViewStyleDefault position:FHToastViewPositionBottom verticalOffset:-20];
    }
    if (CLLocationCoordinate2DIsValid(self.lastPoint)) {
        self.point = self.lastPoint;
        self.lastPoint = kCLLocationCoordinate2DInvalid;
        self.isZoomMapAnimation = YES;
        [self.mapView setCenterCoordinate:self.point animated:YES];
        [self.panoramaView setPanoramaWithLon:self.point.longitude lat:self.point.latitude];
    }
}

/**
 * @abstract 全景图中的覆盖物点击事件
 * @param overlayId 覆盖物标识
 */
- (void)panoramaView:(BaiduPanoramaView *)panoramaView overlayClicked:(NSString *)overlayId {
//    NSLog(@"baidu_overlayClicked");
    if (!self.overlays.count) {
        return;
    }
    for (BaiduPanoImageOverlay *overlay in self.overlays) {
        if ([overlay.overlayKey isEqualToString:overlayId]) {
//            overlay.height = 0;
//            [self.testArray addObject:overlay];
//            double itemAngle = [self computeAzimuthBy:self.point other:overlay.coordinate];
//            NSLog(@"itemAngle %f",itemAngle);
            self.selectOverlay = overlay;
            self.lastPoint = self.point;
            self.point = overlay.coordinate;
            self.isZoomMapAnimation = YES;
            [self.mapView setCenterCoordinate:self.point animated:YES];
            [self.panoramaView setPanoramaWithLon:self.point.longitude lat:self.point.latitude];
            break;
        }
    }
}

//panoEngine
- (void)panoramaView:(BaiduPanoramaView *)panoramaView didReceivedMessage:(NSDictionary *)dict {
//    NSLog(@"baidu_panoramaViewdidReceivedMessage:%@",dict);
    //全景拖动回调
    CGFloat heading = [panoramaView getPanoramaHeading];
    self.headingButton.transform = CGAffineTransformMakeRotation(heading * (M_PI /180.0f));
//    NSLog(@"baidu_panoramaViewdidReceivedMessage_heading:%f",heading);
}

/// MapView的Delegate，mapView通过此类来通知用户对应的事件
#pragma mark - BMKMapViewDelegate
/**
 *地图初始化完毕时会调用此接口
 *@param mapView 地图View
 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
//    NSLog(@"baidu_mapViewDidFinishLoading");
}

/**
 *地图绘制出有效数据时调用此接口
 *@param mapView 地图View
 *@param error 错误码
*/
- (void)mapViewDidRenderValidData:(BMKMapView *)mapView withError:(NSError *)error {
//    NSLog(@"baidu_mapViewDidRenderValidData");
}

/**
 *地图渲染完毕后会调用此接口
 *@param mapView 地图View
 */
- (void)mapViewDidFinishRendering:(BMKMapView *)mapView {
    
}

/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapView 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus*)status {
    
}

/**
 *地图区域即将改变时会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
}

/**
 *地图区域即将改变时会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 *@param reason 地区区域改变的原因
 */
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated reason:(BMKRegionChangeReason)reason {
    
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    NSLog(@"baidu_mapView_regionDidChangeAnimated");
//    拿到地图更改的经纬度 更新全景视图，如果全景视图更新失败，回到原来位置
    
}

/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 *@param reason 地区区域改变的原因
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated reason:(BMKRegionChangeReason)reason {
    if (self.isZoomMapAnimation) {
        self.isZoomMapAnimation = NO;
        return;
    }
    self.lastPoint = self.point;
    [self.panoramaView setPanoramaWithLon:mapView.centerCoordinate.longitude lat:mapView.centerCoordinate.latitude];
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
//- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation;

/**
 *当mapView新添加annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 新添加的annotation views
 */
//- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views;

/**
 *当点击一个annotation view时，调用此接口
 *每次点击BMKAnnotationView都会回调此接口。
 *@param mapView 地图View
 *@param view 点击的annotation view
 */
//- (void)mapView:(BMKMapView *)mapView clickAnnotationView:(BMKAnnotationView *)view;

/**
 *当选中一个annotation views时，调用此接口
 *当BMKAnnotation的title为nil，BMKAnnotationView的canShowCallout为NO时，不显示气泡，点击BMKAnnotationView会回调此接口。
 *当气泡已经弹出，点击BMKAnnotationView不会继续回调此接口。
 *@param mapView 地图View
 *@param view 选中的annotation views
 */
//- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view;

/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param view 取消选中的annotation views
 */
//- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view;

/**
 *拖动annotation view时，若view的状态发生变化，会调用此函数。ios3.2以后支持
 *@param mapView 地图View
 *@param view annotation view
 *@param newState 新状态
 *@param oldState 旧状态
 */
//- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState fromOldState:(BMKAnnotationViewDragState)oldState;

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
//- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;

/**
 *根据overlay生成对应的View
 *@param mapView 地图View
 *@param overlay 指定的overlay
 *@return 生成的覆盖物View
 */
//- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay;

/**
 *当mapView新添加overlay views时，调用此接口
 *@param mapView 地图View
 *@param overlayViews 新添加的overlay views
 */
//- (void)mapView:(BMKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews;

/**
 *点中覆盖物后会回调此接口，目前只支持点中BMKPolylineView时回调
 *@param mapView 地图View
 *@param overlayView 覆盖物view信息
 */
//- (void)mapView:(BMKMapView *)mapView onClickedBMKOverlayView:(BMKOverlayView *)overlayView;

/**
 *点中底图标注后会回调此接口
 *@param mapView 地图View
 *@param mapPoi 标注点信息
 */
//- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi;

/**
 *点中底图空白处会回调此接口
 *@param mapView 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
//- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate;

/**
 *双击地图时会回调此接口
 *@param mapView 地图View
 *@param coordinate 返回双击处坐标点的经纬度
 */
//- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate;

/**
 *长按地图时会回调此接口
 *@param mapView 地图View
 *@param coordinate 返回长按事件坐标点的经纬度
 */
//- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate;

/**
 *3DTouch 按地图时会回调此接口（仅在支持3D Touch，且fouchTouchEnabled属性为YES时，会回调此接口）
 *@param mapView 地图View
 *@param coordinate 触摸点的经纬度
 *@param force 触摸该点的力度(参考UITouch的force属性)
 *@param maximumPossibleForce 当前输入机制下的最大可能力度(参考UITouch的maximumPossibleForce属性)
 */
//- (void)mapview:(BMKMapView *)mapView onForceTouch:(CLLocationCoordinate2D)coordinate force:(CGFloat)force maximumPossibleForce:(CGFloat)maximumPossibleForce;

/**
 *地图状态改变完成后会调用此接口
 *@param mapView 地图View
 */
//- (void)mapStatusDidChanged:(BMKMapView *)mapView;

/**
 *地图进入/移出室内图会调用此接口
 *@param mapView 地图View
 *@param flag  YES:进入室内图; NO:移出室内图
 *@param info 室内图信息
 */
//- (void)mapview:(BMKMapView *)mapView baseIndoorMapWithIn:(BOOL)flag baseIndoorMapInfo:(BMKBaseIndoorMapInfo *)info;

///搜索delegate，用于获取搜索结果
#pragma mark - BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
//    NSLog(@"baidu_onGetPoiResult");
    [self handlePoiResult:poiResult keyword:[searcher fh_keyword]];
    if (errorCode != BMK_SEARCH_NO_ERROR) {
        //上报"api_error"
    }
}

/**
 *返回POI详情搜索结果
 *@param searcher 搜索对象
 *@param poiDetailResult 详情搜索结果
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiDetailResult:(BMKPoiSearch*)searcher result:(BMKPOIDetailSearchResult*)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode {
//    NSLog(@"baidu_onGetPoiDetailResult");
}

/**
 *返回POI室内搜索结果
 *@param searcher 搜索对象
 *@param poiIndoorResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
//- (void)onGetPoiIndoorResult:(BMKPoiSearch*)searcher result:(BMKPOIIndoorSearchResult*)poiIndoorResult errorCode:(BMKSearchErrorCode)errorCode;

///搜索delegate，用于获取搜索结果
#pragma mark - BMKGeoCodeSearchDelegate
/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
//- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error;

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
//    NSLog(@"baidu_onGetReverseGeoCodeResult: %@ %@ %@ %@",result.address,result.businessCircle,result.addressDetail.streetName,result.sematicDescription);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result.addressDetail.streetName.length) {
            self.customNavBarView.title.text = result.addressDetail.streetName;
        } else {
            self.customNavBarView.title.text = @"未知路段";
        }
    });
}

#pragma mark - 埋点
- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:self.tracerDict];
    params[@"page_type"] = @"street_mapping";
//    params[@"event_tracking_id"] = @"70950";
    [FHUserTracker writeEvent:@"go_detail" params:params];
}
@end
