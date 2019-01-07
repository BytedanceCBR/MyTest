//
//  FHLocManager.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHLocManager.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import "AMapLocationCommonObj.h"
#import "TTSandBoxHelper.h"
#import "FHConfigApi.h"
#import "FHEnvContext.h"
#import "YYCache.h"

@interface FHLocManager ()

@property (nonatomic, strong)   YYCache       *locationCache;
@property (nonatomic, assign)   BOOL       isShowSwitch;

@end

@implementation FHLocManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadCurrentLocationData];
    }
    return self;
}

- (YYCache *)locationCache
{
    if (!_locationCache) {
        _locationCache = [YYCache cacheWithName:@"fh_location_cache"];
    }
    return _locationCache;
}

- (void)loadCurrentLocationData {
    self.currentReGeocode = [self.locationCache objectForKey:@"fh_currentReGeocode"];
    self.currentLocaton = [self.locationCache objectForKey:@"fh_currentLocaton"];
    self.isLocationSuccess = [(NSNumber *)[self.locationCache objectForKey:@"fh_isLocationSuccess"] boolValue];
}

- (void)saveCurrentLocationData {
    if (self.currentReGeocode) {
        [self.locationCache setObject:self.currentReGeocode forKey:@"fh_currentReGeocode"];
    }
    if (self.currentLocaton) {
        [self.locationCache setObject:self.currentLocaton forKey:@"fh_currentLocaton"];
    }
}

- (void)setIsLocationSuccess:(BOOL)isLocationSuccess {
    _isLocationSuccess = isLocationSuccess;
    [self.locationCache setObject:@(self.isLocationSuccess) forKey:@"fh_isLocationSuccess"];
}

- (void)showLocationGuideAlert
{
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"无定位权限，请前往系统设置开启" message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithGrayTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        
    }];
    
    [alertVC addActionWithTitle:@"立刻前往" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:jumpUrl]) {
            [[UIApplication sharedApplication] openURL:jumpUrl];
        }
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
}

- (void)showCitySwitchAlert:(NSString *)cityName
{
    
    NSString *titleStr = [NSString stringWithFormat:@"是否切换到当前城市:%@",cityName];
    
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:titleStr message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithGrayTitle:@"暂不" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        
    }];
    
    [alertVC addActionWithTitle:@"切换" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:jumpUrl]) {
            [[UIApplication sharedApplication] openURL:jumpUrl];
        }
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
}

- (void)checkUserLocationStatus
{
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    switch (status) {
        case kCLAuthorizationStatusDenied:
        {
            [self showLocationGuideAlert];
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            [self showLocationGuideAlert];
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            [self showLocationGuideAlert];
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)setUpLocManagerLocalInfo
{
    NSString *apiKeyString = nil;
    if ([[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.bytedance.fp1"]) {
        apiKeyString = @"003c8c31d052f8882bfb2a1d712dea84";
    }else
    {
        apiKeyString = @"69c1887b8d0d2d252395c58e3da184dc";
    }
    
    [AMapServices sharedServices].apiKey = apiKeyString;
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].crashReportEnabled = false;
}

- (void)requestCurrentLocation:(BOOL)showAlert completion:(void(^)(AMapLocationReGeocode * reGeocode))completion
{
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locManager setLocationTimeout:2];
    
    [self.locManager setReGeocodeTimeout:2];
    __weak typeof(self) wSelf = self;
    [self.locManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (showAlert)
        {
            [wSelf checkUserLocationStatus];
        }
        
        if (error.code == AMapLocationErrorLocateFailed) {
            NSLog(@"定位错误:%@",error.localizedDescription);
        }else if (error.code == AMapLocationErrorReGeocodeFailed || error.code == AMapLocationErrorTimeOut || error.code == AMapLocationErrorCannotFindHost || error.code == AMapLocationErrorBadURL || error.code == AMapLocationErrorNotConnectedToInternet || error.code == AMapLocationErrorCannotConnectToHost)
        {
            NSLog(@"逆地理错误:%@",error.localizedDescription);
        }else
        {
            
        }
                
        NSMutableDictionary * amapInfo = [NSMutableDictionary new];
        
        amapInfo[@"sub_locality"] = regeocode.district;
        amapInfo[@"locality"] = regeocode.city;
        if (location.coordinate.latitude) {
            amapInfo[@"latitude"] = @(location.coordinate.latitude);
        }
        
        if (location.coordinate.longitude) {
            amapInfo[@"longitude"] = @(location.coordinate.longitude);
        }
        
//      [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance setUpLocationInfo:amapInfo];
        
        if (regeocode) {
            wSelf.currentReGeocode = regeocode;
        }
        
        if (location) {
            wSelf.currentLocaton = location;
        }
        
        // 存储当前定位信息
        [self saveCurrentLocationData];
        
        if (completion) {
            // 城市选择重新定位需回调
            completion(regeocode);
        } else {
            [FHConfigAPI requestGeneralConfig:0 gaodeLocation:location.coordinate gaodeCityId:regeocode.citycode gaodeCityName:regeocode.city completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
                //更新config
                [wSelf updateAllConfig:model];
                if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && self.isShowSwitch) {
                    [self showCitySwitchAlert:[NSString stringWithFormat:@"是否切换到当前城市:%@",model.data.citySwitch.cityName]];
                    self.isShowSwitch = NO;
                }
            }];
        }
    }];
}

- (void)requestCurrentLocation:(BOOL)showAlert andShowSwitch:(BOOL)switchCity
{

    self.isShowSwitch = switchCity;
    [self requestCurrentLocation:showAlert completion:NULL];
}

- (void)requestCurrentLocation:(BOOL)showAlert
{
    [self requestCurrentLocation:showAlert completion:NULL];
}

- (void)requestConfigByCityId:(NSInteger)cityId completion:(void(^)(BOOL isSuccess))completion
{
     __weak typeof(self) wSelf = self;
    [FHConfigAPI requestGeneralConfig:cityId gaodeLocation:CLLocationCoordinate2DMake(0, 0) gaodeCityId:nil gaodeCityName:nil completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
        [wSelf updateAllConfig:model];
        
        if (model.data && completion) {
            completion(YES);
        }
    }];
}

- (void)updateAllConfig:(FHConfigModel * _Nullable) model
{
    if (![model isKindOfClass:[FHConfigModel class]]) {
        return ;
    }
    [[FHEnvContext sharedInstance] saveGeneralConfig:model];
    
    [FHEnvContext saveCurrentUserCityId:model.data.currentCityId];
    
    if (model.data.currentCityName) {
        [FHEnvContext saveCurrentUserDeaultCityName:model.data.currentCityName];
    }
    
    [[FHEnvContext sharedInstance] updateRequestCommonParams];
    
    if (model.data) {
        [[FHEnvContext sharedInstance] acceptConfigDataModel:model.data];
    }
    
    if ([FHEnvContext sharedInstance].homeConfigCallBack) {
        [FHEnvContext sharedInstance].homeConfigCallBack(model.data);
    }
}


- (void)setLocManager:(AMapLocationManager *)locManager
{
    _locMgr = locManager;
}

- (AMapLocationManager *)locManager
{
    if (!_locMgr) {
        _locMgr = [[AMapLocationManager alloc] init];
    }
    return _locMgr;
}

@end
