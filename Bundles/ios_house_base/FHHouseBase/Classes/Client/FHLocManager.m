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
#import "FHHomeConfigManager.h"
#import "TTSandBoxHelper.h"
#import "FHConfigApi.h"
#import "FHEnvContext.h"

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

- (void)showLocationGuideAlert
{
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"无定位权限，请前往系统设置开启" message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        
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

- (void)requestCurrentLocation:(BOOL)showAlert
{
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locManager setLocationTimeout:2];
    
    [self.locManager setReGeocodeTimeout:2];
    
    [self.locManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (showAlert)
        {
            [self checkUserLocationStatus];
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
        
        
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance setUpLocationInfo:amapInfo];
        
        if (regeocode) {
            self.currentReGeocode = regeocode;
        }
        
        if (location) {
            self.currentLocaton = location;
        }
        
        [FHConfigAPI requestGeneralConfig:0 gaodeLocation:location.coordinate gaodeCityId:regeocode.citycode gaodeCityName:regeocode.city completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
            
            if (![model isKindOfClass:[FHConfigModel class]]) {
                
                return ;
            }
            
            [[FHEnvContext sharedInstance] saveGeneralConfig:model];
            
            [FHEnvContext saveCurrentUserCityId:model.data.currentCityId];
            
            [FHEnvContext saveCurrentUserDeaultCityName:model.data.currentCityName];
            
            [[FHEnvContext sharedInstance] updateRequestCommonParams];
            
            
 
            if (model.data) {
                [[FHHomeConfigManager sharedInstance] acceptConfigDataModel:model.data];
            }
        }];
        
        NSLog(@"regeocode = %d city = %@",regeocode.citycode,regeocode.city);
        
    }];
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
