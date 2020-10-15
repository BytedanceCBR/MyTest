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
#import "FHUtils.h"
#import "FHHouseEnvContextBridge.h"
#import "FHHouseBridgeManager.h"
#import "NSDictionary+TTAdditions.h"
#import "NSTimer+NoRetain.h"
#import "TTUIResponderHelper.h"
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
#import "TTArticleCategoryManager.h"
#import "FHHouseUGCAPI.h"
#import "FHIntroduceManager.h"
#import "FHPopupViewManager.h"
#import "TTSettingsManager.h"

#import <BDUGLocationKit/BDUGAmapGeocoder.h>
#import <BDUGLocationKit/BDUGLocationManager.h>
#import <BDUGLocationKit/BDUGAmapAdapter.h>
#import "TTAccountLoginManager.h"
#import "TTAccountManager.h"

NSString * const kFHAllConfigLoadSuccessNotice = @"FHAllConfigLoadSuccessNotice"; //通知名称
NSString * const kFHAllConfigLoadErrorNotice = @"FHAllConfigLoadErrorNotice"; //通知名称
NSString * const kFHTopSwitchCityLocalKey = @"f_switch_city_top_time_local_key"; //本地持久化显示时间
#define kFHHomeHouseMixedCategoryID   @"f_house_news" // 推荐频道

@interface FHLocManager ()

@property (nonatomic, strong) YYCache       *locationCache;
@property (nonatomic, assign) BOOL isHasSendPermissionTrace;
@property (nonatomic , strong) NSTimer *messageTimer;
@property (nonatomic, assign) CLAuthorizationStatus currentStatus;
@property (nonatomic, assign) NSTimeInterval lastRequestLocTimestamp;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    self.currentReGeocode = [self.locationCache objectForKey:@"fh_currentReGeocode"];
    if (![self.currentReGeocode isKindOfClass:[BDUGBasePlacemark class]]) {
           self.currentReGeocode = nil;
    }
    
    if ([self isHaveLocationAuthorization]) {
        self.currentLocaton = [self.locationCache objectForKey:@"fh_currentLocaton"];
    }else{
        [self cleanLocationData];
    }

    self.isLocationSuccess = [(NSNumber *)[self.locationCache objectForKey:@"fh_isLocationSuccess"] boolValue];
    self.retryConfigCount = 3;
    self.isShowSwitch = YES;
    self.isShowSplashAdView = NO;
    self.isShowHomeViewController = YES;
}

#pragma mark -- notification

- (void)_willEnterForeground:(NSNotification *)notification
{
    self.currentStatus = CLLocationManager.authorizationStatus;
    if (![self isHaveLocationAuthorization]) {
        [self cleanLocationData];
        NSMutableDictionary *commonParams =  (NSMutableDictionary *)[[FHEnvContext sharedInstance] getRequestCommonParams];
        if ([commonParams isKindOfClass:[NSMutableDictionary class]]) {
            commonParams[@"gaode_lng"] = @(0);
            commonParams[@"gaode_lat"] = @(0);
            commonParams[@"longitude"] = @(0);
            commonParams[@"latitude"] = @(0);
        }
    }
}

- (void)saveCurrentLocationData {
//    if (self.currentReGeocode) {
//        [self.locationCache setObject:self.currentReGeocode forKey:@"fh_currentReGeocode"];
//    }
    if (self.currentLocaton) {
        [self.locationCache setObject:self.currentLocaton forKey:@"fh_currentLocaton"];
    }
}

- (void)cleanLocationData{
    [self.locationCache removeObjectForKey:@"fh_currentLocaton"];
    [self.locationCache removeObjectForKey:@"fh_currentReGeocode"];
}


- (void)setIsLocationSuccess:(BOOL)isLocationSuccess {
    _isLocationSuccess = isLocationSuccess;
    [self.locationCache setObject:@(self.isLocationSuccess) forKey:@"fh_isLocationSuccess"];
}

- (void)showLocationGuideAlert
{
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"您还没有开启定位权限" message:@"请前往系统设置开启，以便我们更好地为您推荐房源及丰富信息推荐维度" preferredType:TTThemedAlertControllerTypeAlert];
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
    
    if (![FHEnvContext isNetworkConnected]) {
        return;
    }
    
    //服务端配置频控
    if (![[[FHHouseBridgeManager sharedInstance] envContextBridge] isNeedSwitchCityCompare]) {
        return;
    }
    
    //无定位权限不弹切换城市alert
    if (![self isHaveLocationAuthorization]) {
        return;
    }
    
    id<FHHouseEnvContextBridge> bridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    //如果不在第一个tab
    if (![bridge isCurrentTabFirst]) {
        return;
    }
    
    //如果不在首页
    if (!self.isShowHomeViewController) {
        return;
    }
    
    NSDictionary *params = @{@"page_type":@"city_switch",
                             @"enter_from":@"default"};
    [FHEnvContext recordEvent:params andEventKey:@"city_switch_show"];
    
    
    NSString *titleStr = [NSString stringWithFormat:@"%@",cityName];
    
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:titleStr message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithGrayTitle:@"暂不" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        [[FHPopupViewManager shared] outerPopupViewHide];
        NSDictionary *params = @{@"click_type":@"cancel",
                                 @"enter_from":@"default"};
        [FHEnvContext recordEvent:params andEventKey:@"city_click"];
    }];
    
    
    [alertVC addActionWithTitle:@"切换" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        [[FHPopupViewManager shared] outerPopupViewHide];
        if (openUrl) {
            [FHEnvContext sharedInstance].refreshConfigRequestType = @"switch_alert";
            
            [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = YES;
            [FHEnvContext openSwitchCityURL:openUrl completion:^(BOOL isSuccess) {
                // 进历史
                if (isSuccess) {
                    [[[FHHouseBridgeManager sharedInstance] cityListModelBridge] switchCityByOpenUrlSuccess];
                }
            }];
            NSDictionary *params = @{@"click_type":@"switch",
                                     @"enter_from":@"default"};
            [FHEnvContext recordEvent:params andEventKey:@"city_click"];
        }
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [[FHPopupViewManager shared] outerPopupViewShow];
        [alertVC showFrom:topVC animated:YES];
    }
    
    NSString *stringCurrentDate = [FHUtils stringFromNSDate:[NSDate date]];
    
    [FHUtils setContent:stringCurrentDate forKey:@"f_save_switch_local_time"];
    
    self.isShowSwitch = NO;
}

- (BOOL)isTopCitySwitchTimeCompare
{
    
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    NSInteger topInterger = [fhSettings tt_integerValueForKey:@"f_switch_city_top_time"];
    
    if (topInterger == 0) {
        return YES;
    }
    
    NSString *stringDate = (NSString *)[FHUtils contentForKey:kFHTopSwitchCityLocalKey];
    if(stringDate)
    {
        NSDate *saveDate = [FHUtils dateFromString:stringDate];
        
        NSInteger timeCount = [FHUtils numberOfDaysWithFromDate:saveDate toDate:[NSDate date]];
        
        if (timeCount >= topInterger) {
            return YES;
        }else
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)checkUserLocationStatus
{
    if (![self isHaveLocationAuthorization]) {
        [self showLocationGuideAlert];
    }
}

- (BOOL)isHaveLocationAuthorization
{
    if (!self.currentStatus) {
        self.currentStatus = CLLocationManager.authorizationStatus;
    }
    switch (self.currentStatus) {
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

+ (NSString *)amapAPIKey
{
    if ([[TTSandBoxHelper bundleIdentifier] isEqualToString:@"com.bytedance.fp1"]) {
        return @"003c8c31d052f8882bfb2a1d712dea84";
    } else {
        return @"69c1887b8d0d2d252395c58e3da184dc";
    }
}

- (void)setUpLocManagerLocalInfo
{    
    [AMapServices sharedServices].apiKey = [FHLocManager amapAPIKey];
    [BDUGAmapGeocoder sharedGeocoder].apiKey = [FHLocManager amapAPIKey];
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].crashReportEnabled = false;
}

- (void)configLocationManager
{
    [BDUGLocationManager sharedManager].baseUrl = [FHMainApi host];
    BDUGLocationAppConfig *config = [[BDUGLocationAppConfig alloc] init];
    config.oversea = NO;
    config.appID = @"1370";
    config.deviceID = [[TTInstallIDManager sharedInstance] deviceID];
    config.appVersion =  [FHEnvContext getToutiaoVersionCode];
    config.devicePlatform = @"iPhone";
    [BDUGLocationManager sharedManager].hostAppConfig = config;
}

- (void)requestCurrentLocation:(BOOL)showAlert completion:(void(^)(AMapLocationReGeocode * reGeocode))completion
{
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    BOOL f_bduglocation_sdk = [fhSettings tt_boolValueForKey:@"f_bduglocation_sdk_enable"];
    
    if (!f_bduglocation_sdk) {
        [self requestCurrentLocationPrevious:showAlert completion:completion];
        return;
    }
    
    [self configLocationManager];
    
    __weak typeof(self) wSelf = self;
    [[BDUGLocationManager sharedManager] requestLocationWithDesiredAccuracy:BDUGLocationAccuracyBest geocoders:@[[BDUGAmapGeocoder sharedGeocoder]] timeout:4 completion:^(BDUGLocationInfo * _Nullable locationInfo, NSError * _Nullable error) {
        
        BDUGBasePlacemark *location = locationInfo.placeMark;
        
        //如果无权限
        if (![self isHaveLocationAuthorization]) {
            location = nil;
        }
        
        if (!error && location.city && location.aoiList.count > 0) {
            AMapLocationReGeocode *locationAmap = [AMapLocationReGeocode new];
            locationAmap.city = location.city;
            locationAmap.province = location.administrativeArea;
            locationAmap.citycode = location.cityCode;
            locationAmap.formattedAddress = location.address;
            if ([location.aoiList.firstObject isKindOfClass:[NSDictionary class]]) {
                locationAmap.AOIName = [(NSDictionary *)location.aoiList.firstObject objectForKey:@"name"];
            }
            self.currentAmpReGeocode = locationAmap;
        }
        
        if (showAlert)
        {
            BOOL isLocationEnabled = [CLLocationManager locationServicesEnabled];
            if (!isLocationEnabled && [TTSandBoxHelper isAPPFirstLaunch]) {
                return;
            }
            
            [wSelf checkUserLocationStatus];
        }
        
        [wSelf sendLocationAuthorizedTrace];
        
        NSMutableDictionary *paramsExtra = [NSMutableDictionary new];
        
        [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        
        NSInteger statusNum = 1;
        if (![self isHaveLocationAuthorization]) {
            statusNum = 2;
        }else if (![FHEnvContext isNetworkConnected])
        {
            statusNum = 3;
        }
        
        if (error) {
            
            NSNumber *statusNumber = [NSNumber numberWithInteger:[self isHaveLocationAuthorization] ? 1 : 0];
            
            NSNumber *netStatusNumber = [NSNumber numberWithInteger:[FHEnvContext isNetworkConnected] ? 1 : 0];
            
            NSMutableDictionary *uploadParams = [NSMutableDictionary new];
            [uploadParams setValue:@"定位错误" forKey:@"desc"];
            [uploadParams setValue:statusNumber forKey:@"location_status"];
            [uploadParams setValue:netStatusNumber forKey:@"network_status"];
            
            
            [[HMDTTMonitor defaultManager] hmdTrackService:@"home_location_error" status:statusNum extra:paramsExtra];
            
            NSLog(@"定位错误:%@",error.localizedDescription);
        }else
        {
            if (location) {
                [[HMDTTMonitor defaultManager] hmdTrackService:@"home_location_error" status:0 extra:paramsExtra];
            }
        }
        
        NSMutableDictionary * amapInfo = [NSMutableDictionary new];
        
        amapInfo[@"sub_locality"] = location.district;
        amapInfo[@"locality"] = location.city;
        if (locationInfo.location.coordinate.latitude) {
            amapInfo[@"latitude"] = @(locationInfo.location.coordinate.latitude);
        }
        
        if (locationInfo.location.coordinate.longitude) {
            amapInfo[@"longitude"] = @(locationInfo.location.coordinate.longitude);
        }
        
        [[[FHHouseBridgeManager sharedInstance] envContextBridge] setUpLocationInfo:amapInfo];
        
        if (location && [self isHaveLocationAuthorization] && locationInfo.location.coordinate.latitude != 0) {
            wSelf.currentReGeocode = location;
        }else{
            location = nil;
        }
        
        if (locationInfo) {
            
            CLLocationCoordinate2D gcjLoc = [BDUGAmapAdapter convertWGSCoordinateToGCJ:locationInfo.location.coordinate];
            
            wSelf.currentLocaton = [[CLLocation alloc] initWithLatitude:gcjLoc.latitude longitude:gcjLoc.longitude];
        }
        
        // 存储当前定位信息
        [wSelf saveCurrentLocationData];
        wSelf.lastRequestLocTimestamp = [[NSDate date] timeIntervalSince1970];
        
        if (completion) {
            // 城市选择重新定位需回调
            completion(self.currentAmpReGeocode);
            [[FHEnvContext sharedInstance] updateRequestCommonParams];
        } else {
            NSInteger cityId = 0;
            if ([[FHEnvContext getCurrentSelectCityIdFromLocal] respondsToSelector:@selector(integerValue)]) {
                cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
            }
            [FHConfigAPI requestGeneralConfig:cityId gaodeLocation:wSelf.currentLocaton.coordinate gaodeCityId:location.cityCode gaodeCityName:location.city completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
                if (!model || error) {
                    wSelf.retryConfigCount -= 1;
                    if (wSelf.retryConfigCount >= 0)
                    {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [wSelf requestCurrentLocation:NO];
                            });
                        });
                    } else {
                        // 告诉城市列表config加载error
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFHAllConfigLoadErrorNotice object:nil];
                    }
                    return;
                }
                
                BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
                BOOL isShowIntoduceView = [FHIntroduceManager sharedInstance].isShowing;
                
                
                
                // 拉取小端运营窗口弹窗配置信息
                [[FHPopupViewManager shared] fetchDataForCityId:cityId];
                
                [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = YES;
                [wSelf updateAllConfig:model isNeedDiff:NO];
                
                
                NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
                BOOL boolOffline = [fhSettings tt_boolValueForKey:@"f_switch_city_top_close"];
                
                //setting控制开关
                if(boolOffline)
                {
                    // 城市切换弹窗
                    if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && self.isShowSwitch && !self.isShowSplashAdView && hasSelectedCity && !isShowIntoduceView) {
                        [self showCitySwitchAlert:[NSString stringWithFormat:@"是否切换到当前城市:%@",model.data.citySwitch.cityName] openUrl:model.data.citySwitch.openUrl];
                    }
                }else
                {
                    if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && hasSelectedCity && [self isTopCitySwitchTimeCompare] &&(![FHEnvContext canShowLoginTip] || [TTAccount sharedAccount].isLogin)) {
                        NSString *stringCurrentDate = [FHUtils stringFromNSDate:[NSDate date]];
                        [FHUtils setContent:stringCurrentDate forKey:kFHTopSwitchCityLocalKey];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeInitSwitchCityTopView" object:nil];
                    }
                }
                
                //                BOOL isHasFindHouseCategory = [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]];
                //
                //                if (!isHasFindHouseCategory && [[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                //                    [[TTArticleCategoryManager sharedManager] startGetCategoryWithCompleticon:^(BOOL isSuccessed){
                //
                //                    }];
                //                }
                
                wSelf.retryConfigCount = 3;
            }];
        }
    }];
}


- (AMapLocationManager *)locManager
{
    if (!_locMgr) {
        _locMgr = [[AMapLocationManager alloc] init];
    }
    return _locMgr;
}

- (void)requestCurrentLocationPrevious:(BOOL)showAlert completion:(void(^)(AMapLocationReGeocode * reGeocode))completion
{
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locManager setLocationTimeout:2];
    
    [self.locManager setReGeocodeTimeout:2];
    __weak typeof(self) wSelf = self;
    //由于BDUGLocation 无法提供定位AOI等数据，目前先使用高德sdk的定位
    [self.locManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (showAlert)
        {
            BOOL isLocationEnabled = [CLLocationManager locationServicesEnabled];
            if (!isLocationEnabled && [TTSandBoxHelper isAPPFirstLaunch]) {
                return;
            }
            
            [wSelf checkUserLocationStatus];
        }
        
        [wSelf sendLocationAuthorizedTrace];
        
        NSMutableDictionary *paramsExtra = [NSMutableDictionary new];
        
        [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        
        NSInteger statusNum = 1;
        if (![wSelf isHaveLocationAuthorization]) {
            statusNum = 2;
        }else if (![FHEnvContext isNetworkConnected])
        {
            statusNum = 3;
        }
        
        if (error.code == AMapLocationErrorLocateFailed) {
            
            NSNumber *statusNumber = [NSNumber numberWithInteger:[self isHaveLocationAuthorization] ? 1 : 0];
            
            NSNumber *netStatusNumber = [NSNumber numberWithInteger:[FHEnvContext isNetworkConnected] ? 1 : 0];
            
            NSMutableDictionary *uploadParams = [NSMutableDictionary new];
            [uploadParams setValue:@"定位错误" forKey:@"desc"];
            [uploadParams setValue:statusNumber forKey:@"location_status"];
            [uploadParams setValue:netStatusNumber forKey:@"network_status"];
            
            
            [[HMDTTMonitor defaultManager] hmdTrackService:@"home_location_error" status:statusNum extra:paramsExtra];
            
            NSLog(@"定位错误:%@",error.localizedDescription);
        }else if (error.code == AMapLocationErrorReGeocodeFailed || error.code == AMapLocationErrorTimeOut || error.code == AMapLocationErrorCannotFindHost || error.code == AMapLocationErrorBadURL || error.code == AMapLocationErrorNotConnectedToInternet || error.code == AMapLocationErrorCannotConnectToHost)
        {
            NSLog(@"逆地理错误:%@",error.localizedDescription);
        }else
        {
            if (regeocode) {
                [[HMDTTMonitor defaultManager] hmdTrackService:@"home_location_error" status:0 extra:paramsExtra];
            }
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
        
        [[[FHHouseBridgeManager sharedInstance] envContextBridge] setUpLocationInfo:amapInfo];
        
        if (regeocode) {
            BDUGBasePlacemark *currentRe = [BDUGBasePlacemark new];
            currentRe.district = regeocode.district;
            currentRe.cityCode = regeocode.citycode;
            currentRe.administrativeArea = regeocode.province;
            currentRe.city = regeocode.city;
            currentRe.address = regeocode.formattedAddress;
            currentRe.street = regeocode.street;
            wSelf.currentReGeocode = currentRe;
            wSelf.currentAmpReGeocode = regeocode;
        }
        
        if (location) {
            wSelf.currentLocaton = location;
        }
        
        // 存储当前定位信息
        [wSelf saveCurrentLocationData];
        
        if (completion) {
            // 城市选择重新定位需回调
            completion(regeocode);
            [[FHEnvContext sharedInstance] updateRequestCommonParams];
        } else {
            NSInteger cityId = 0;
            if ([[FHEnvContext getCurrentSelectCityIdFromLocal] respondsToSelector:@selector(integerValue)]) {
                cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
            }
            [FHConfigAPI requestGeneralConfig:cityId gaodeLocation:location.coordinate gaodeCityId:regeocode.citycode gaodeCityName:regeocode.city completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
                if (!model || error) {
                    wSelf.retryConfigCount -= 1;
                    if (wSelf.retryConfigCount >= 0)
                    {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [wSelf requestCurrentLocation:NO];
                            });
                        });
                    } else {
                        // 告诉城市列表config加载error
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFHAllConfigLoadErrorNotice object:nil];
                    }
                    return;
                }
                
                BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
                BOOL isShowIntoduceView = [FHIntroduceManager sharedInstance].isShowing;
                
            
                
                // 拉取小端运营窗口弹窗配置信息
                [[FHPopupViewManager shared] fetchDataForCityId:cityId];
                
                [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = YES;
                [wSelf updateAllConfig:model isNeedDiff:NO];
                
                
                NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
                BOOL boolOffline = [fhSettings tt_boolValueForKey:@"f_switch_city_top_close"];
                
                //setting控制开关
                if(boolOffline)
                {
                    // 城市切换弹窗
                     if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && self.isShowSwitch && !self.isShowSplashAdView && hasSelectedCity && !isShowIntoduceView) {
                         [self showCitySwitchAlert:[NSString stringWithFormat:@"是否切换到当前城市:%@",model.data.citySwitch.cityName] openUrl:model.data.citySwitch.openUrl];
                     }
                }else
                {
                    if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && [self isTopCitySwitchTimeCompare] && (![FHEnvContext canShowLoginTip] || [TTAccount sharedAccount].isLogin)) {
                        NSString *stringCurrentDate = [FHUtils stringFromNSDate:[NSDate date]];
                        [FHUtils setContent:stringCurrentDate forKey:kFHTopSwitchCityLocalKey];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeInitSwitchCityTopView" object:nil];
                    }
                }
             
                //                BOOL isHasFindHouseCategory = [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]];
                //
                //                if (!isHasFindHouseCategory && [[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue) {
                //                    [[TTArticleCategoryManager sharedManager] startGetCategoryWithCompleticon:^(BOOL isSuccessed){
                //
                //                    }];
                //                }
                
                wSelf.retryConfigCount = 3;
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
            [[FHPopupViewManager shared] fetchDataForCityId:cityId];
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
    
    if (model.data.cityAvailability) {
        [FHUtils setContent:@(model.data.cityAvailability.enable.boolValue) forKey:kFHCityIsOpenKey];
    }
    
    configData.originDict = nil;
    [FHEnvContext sharedInstance].generalBizConfig.configCache = model.data;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[FHEnvContext sharedInstance] saveGeneralConfig:model];
        
    });
    [FHEnvContext saveCurrentUserCityId:model.data.currentCityId];
    
    if (model.data.currentCityName) {
        [FHEnvContext saveCurrentUserDeaultCityName:model.data.currentCityName];
    }
    
    [[FHEnvContext sharedInstance] updateRequestCommonParams];
    
    if (model.data) {
        [[FHEnvContext sharedInstance] acceptConfigDataModel:model.data];
    }
    
    // config 加载完成，请求参数更新完成，请求UGC Config
    [FHHouseUGCAPI loadUgcConfigEntrance];
    
    // 告诉城市列表config加载ok
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHAllConfigLoadSuccessNotice object:nil];
}


- (void)setLocManager:(AMapLocationManager *)locManager
{
    _locMgr = locManager;
}


- (void)fetchCategoryRefreshTip{
    id<FHHouseEnvContextBridge> bridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    NSString *urlStr = [bridge getRefreshTipURLString];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlStr
                                                     params:nil
                                                     method:@"GET"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       if (nil == error) {
                                                           StrongSelf;
                                                           if (![[bridge getCurrentSelectCategoryId] isEqualToString:kFHHomeHouseMixedCategoryID]) {
                                                               
                                                               NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
                                                               NSInteger count = [data tt_intValueForKey:@"count"];
                                                               if (count > 0) {
                                                                   [bridge updateNotifyBadgeNumber:kFHHomeHouseMixedCategoryID isShow:YES];
                                                               }
                                                               
                                                           }
                                                       }
                                                   }];
}

- (void)startCategoryRedDotRefresh
{
    if (self.messageTimer) {
        [self.messageTimer invalidate];
        self.messageTimer = nil;
    }
    
    NSInteger timeInterval = [[[FHHouseBridgeManager sharedInstance] envContextBridge] getCategoryBadgeTimeInterval];
    
    self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerSelecter) userInfo:nil repeats:YES];
    
}

- (void)timerSelecter
{
    [self fetchCategoryRefreshTip];
}

- (void)stopCategoryRedDotRefresh
{
    if (self.messageTimer) {
        [self.messageTimer invalidate];
        self.messageTimer = nil;
    }
    
    [[[FHHouseBridgeManager sharedInstance] envContextBridge] updateNotifyBadgeNumber:kFHHomeHouseMixedCategoryID isShow:NO];
}


-(void)tryRefreshLocation
{
    //尝试刷新位置
    NSTimeInterval now =[[NSDate date] timeIntervalSince1970];
    if ( _lastRequestLocTimestamp < 1 || now - _lastRequestLocTimestamp < 5 * 60) {
        //五分钟内不进行请求
        return;
    }
    
    [self requestCurrentLocation:NO completion:^(AMapLocationReGeocode * _Nonnull reGeocode) {
        
    }];
}

@end
