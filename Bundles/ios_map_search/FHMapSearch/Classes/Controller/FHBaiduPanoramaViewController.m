//
//  FHBaiduPanoramaViewController.m
//  Pods
//
//  Created by bytedance on 2020/7/15.
//

#import "FHBaiduPanoramaViewController.h"
#import "BaiduPanoramaView.h"
#import "BMKBaseComponent.h"
#import "BMKMapComponent.h"
#import "BMKSearchComponent.h"
#import "BMKUtilsComponent.h"
#import "TTSandBoxHelper.h"

@interface FHBaiduPanoramaViewController ()<BMKGeneralDelegate,BMKMapViewDelegate>

@property (nonatomic, strong) BaiduPanoramaView *panoramaView;

@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic, strong) BMKMapManager *mapManager;

@end

@implementation FHBaiduPanoramaViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        [self setupMapManager];
    }
    return self;
}

- (void)setupMapManager {
    self.mapManager = [[BMKMapManager alloc] init];
    NSString *baiduAK = [TTSandBoxHelper isInHouseApp] ? @"9Q6O7p5wl7wz2F5DELMyqqlaGesstoLf" : @"3oO4DAuGjZu1IBz4UwmhOXWHoLRQZTpo";;
    BOOL ret = [_mapManager start:baiduAK generalDelegate:self];
    if (!ret) {
        NSLog(@"");
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - BMKGeneralDelegate
/**
 *返回网络错误
 *@param iError 错误号
 */
- (void)onGetNetworkState:(int)iError {
    NSLog(@"onGetNetworkState %d",iError);
}

/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError {
    NSLog(@"onGetPermissionState %d",iError);
}

@end
