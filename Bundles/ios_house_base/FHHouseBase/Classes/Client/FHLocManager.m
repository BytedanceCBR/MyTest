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
#import "TTSandBoxHelper.h"

NSString * const kFHAllConfigLoadSuccessNotice = @"FHAllConfigLoadSuccessNotice"; //通知名称
NSString * const kFHAllConfigLoadErrorNotice = @"FHAllConfigLoadErrorNotice"; //通知名称

@interface FHLocManager ()

@property (nonatomic, strong) YYCache       *locationCache;
@property (nonatomic, assign) BOOL isHasSendPermissionTrace;

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
    self.retryConfigCount = 3;
    self.isShowSwitch = YES;
    self.isShowSplashAdView = NO;
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
    [alertVC addActionWithGrayTitle:@"手动选择" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        
    }];
    
    [alertVC addActionWithTitle:@"前往设置" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
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

- (void)showCitySwitchAlert:(NSString *)cityName openUrl:(NSString *)openUrl
{
    if (!cityName || !openUrl) {
        return;
    }
    
    NSDictionary *params = @{@"page_type":@"city_switch",
                             @"enter_from":@"default"};
    [FHEnvContext recordEvent:params andEventKey:@"city_switch_show"];
    
    
    NSString *titleStr = [NSString stringWithFormat:@"%@",cityName];
    
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:titleStr message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithGrayTitle:@"暂不" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        NSDictionary *params = @{@"click_type":@"cancel",
                                 @"enter_from":@"default"};
        [FHEnvContext recordEvent:params andEventKey:@"city_click"];
    }];
    
    [alertVC addActionWithTitle:@"切换" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        if (openUrl) {
            [FHEnvContext openSwitchCityURL:openUrl completion:^(BOOL isSuccess) {
            }];
            NSDictionary *params = @{@"click_type":@"switch",
                                     @"enter_from":@"default"};
            [FHEnvContext recordEvent:params andEventKey:@"city_click"];
        }
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
    
    self.isShowSwitch = NO;
}

- (void)checkUserLocationStatus
{
    if (![self isHaveLocationAuthorization]) {
        [self showLocationGuideAlert];
    }
}

- (BOOL)isHaveLocationAuthorization
{
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    switch (status) {
        case kCLAuthorizationStatusDenied:
        {
            return NO;
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            return NO;
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            return NO;
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            return YES;
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            return YES;
        }
            break;
        default:
            return NO;
            break;
    }
}

 - (void)sendLocationAuthorizedTrace
{
    if (!self.isHasSendPermissionTrace) {
        self.isHasSendPermissionTrace = YES;
        NSNumber *statusNumber = [NSNumber numberWithInteger:[self isHaveLocationAuthorization] ? 1 : 0];
        
        NSDictionary *dictTrace = [NSDictionary dictionaryWithObjectsAndKeys:statusNumber,@"status", nil];
        
        [FHEnvContext recordEvent:dictTrace andEventKey:@"location_permission_status"];
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
            BOOL isLocationEnabled = [CLLocationManager locationServicesEnabled];
            if (!isLocationEnabled && [TTSandBoxHelper isAPPFirstLaunch]) {
                return;
            }
            
            [wSelf checkUserLocationStatus];
        }
        
        [self sendLocationAuthorizedTrace];
        
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
            NSInteger cityId = 0;
            if ([[FHEnvContext getCurrentSelectCityIdFromLocal] respondsToSelector:@selector(integerValue)]) {
                cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
            }
            [FHConfigAPI requestGeneralConfig:cityId gaodeLocation:location.coordinate gaodeCityId:regeocode.citycode gaodeCityName:regeocode.city completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
                if (!model) {
                    self.retryConfigCount -= 1;
                    if (self.retryConfigCount >= 0)
                    {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self requestCurrentLocation:NO];
                            });
                        });
                    } else {
                        // 告诉城市列表config加载error
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFHAllConfigLoadErrorNotice object:nil];
                    }
                    return;
                }
                
                if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && self.isShowSwitch && !self.isShowSplashAdView) {
                    [self showCitySwitchAlert:[NSString stringWithFormat:@"是否切换到当前城市:%@",model.data.citySwitch.cityName] openUrl:model.data.citySwitch.openUrl];
                }else
                {
                    NSString *currentCityid = [FHEnvContext getCurrentSelectCityIdFromLocal];
                    
                    if (currentCityid == model.data.currentCityId || !currentCityid) {
                        //更新config
                        [wSelf updateAllConfig:model isNeedDiff:YES];
                    }
                }
                self.retryConfigCount = 3;
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

- (void)requestConfigByCityId:(NSInteger)cityId completion:(void(^)(BOOL isSuccess, FHConfigModel * _Nullable model))completion
{
    __weak typeof(self) wSelf = self;
    [FHConfigAPI requestGeneralConfig:cityId gaodeLocation:CLLocationCoordinate2DMake(0, 0) gaodeCityId:nil gaodeCityName:nil completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
        
        if (model.data && completion) {
            completion(YES, model);
        }else
        {
            completion(NO, model);
        }
    }];
}

- (void)updateAllConfig:(FHConfigModel * _Nullable) model isNeedDiff:(BOOL)needDiff
{
    if (![model isKindOfClass:[FHConfigModel class]]) {
        return ;
    }
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (needDiff && [model.data.diffCode isEqualToString:configData.diffCode])
    {
        return;
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
    
    // 告诉城市列表config加载ok
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHAllConfigLoadSuccessNotice object:nil];
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
