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
#import <NSDictionary+TTAdditions.h>
#import <NSTimer+NoRetain.h>
#import <TTUIResponderHelper.h>
#import <HMDTTMonitor.h>
#import <TTInstallIDManager.h>
#import <TTArticleCategoryManager.h>
#import "FHHouseUGCAPI.h"
#import <BDUGLocationKit/BDUGAmapGeocoder.h>
#import <BDUGLocationKit/BDUGLocationManager.h>
#import <BDUGLocationKit/BDUGSystemGeocoder.h>


NSString * const kFHAllConfigLoadSuccessNotice = @"FHAllConfigLoadSuccessNotice"; //通知名称
NSString * const kFHAllConfigLoadErrorNotice = @"FHAllConfigLoadErrorNotice"; //通知名称
#define kFHHomeHouseMixedCategoryID   @"f_house_news" // 推荐频道

@interface FHLocManager ()

@property (nonatomic, strong) YYCache       *locationCache;
@property (nonatomic, assign) BOOL isHasSendPermissionTrace;
@property(nonatomic , strong) NSTimer *messageTimer;

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
    if (![self.currentReGeocode isKindOfClass:[BDUGAmapPlacemark class]]) {
        self.currentReGeocode = nil;
    }
    self.currentLocaton = [self.locationCache objectForKey:@"fh_currentLocaton"];
    self.isLocationSuccess = [(NSNumber *)[self.locationCache objectForKey:@"fh_isLocationSuccess"] boolValue];
    self.retryConfigCount = 3;
    self.isShowSwitch = YES;
    self.isShowSplashAdView = NO;
    self.isShowHomeViewController = YES;
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
        NSDictionary *params = @{@"click_type":@"cancel",
                                 @"enter_from":@"default"};
        [FHEnvContext recordEvent:params andEventKey:@"city_click"];
    }];
    
    
    [alertVC addActionWithTitle:@"切换" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
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
        [alertVC showFrom:topVC animated:YES];
    }
    
    NSString *stringCurrentDate = [FHUtils stringFromNSDate:[NSDate date]];
    
    [FHUtils setContent:stringCurrentDate forKey:@"f_save_switch_local_time"];
    
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
    [BDUGAmapGeocoder sharedGeocoder].apiKey = apiKeyString;
    
//    [AMapServices sharedServices].apiKey = apiKeyString;
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].crashReportEnabled = false;
}

- (void)requestCurrentLocation:(BOOL)showAlert completion:(void(^)(AMapLocationReGeocode * reGeocode))completion
{
    NSMutableArray *geocoders = [[NSMutableArray alloc] init];
//    [BDUGAmapGeocoder sharedGeocoder].apiKey = kAmapKey;
    [geocoders addObject:[BDUGAmapGeocoder sharedGeocoder]];
    [geocoders addObject:[BDUGSystemGeocoder sharedGeocoder]];
    
    BDUGLocationAuthorizationStatus status =  [BDUGLocationManager  currentLocationAuthorizationStatus];
    if (status >= BDUGLocationAuthorizationStatusNotDetermined) {
        //没有定位权限
        [[BDUGLocationManager sharedManager] requestWhenInUseAuthorizationWithCompletion:^(BOOL isGranted) {
            if (isGranted) {
                [self requestCurrentLocation:showAlert completion:completion];
            }else if(completion){
                completion(nil);
            }
        }];
        return;
    }
    
    __weak typeof(self) wSelf = self;
    [[BDUGLocationManager sharedManager]requestLocationWithDesiredAccuracy:BDUGLocationAccuracyHundredMeters geocoders:geocoders timeout:4 completion:^(BDUGLocationInfo * _Nullable locationInfo, NSError * _Nullable error) {
                
        BDUGAmapPlacemark *location = (BDUGAmapPlacemark*) locationInfo.placemarkMap[BDUGPlacemarkAmapKey];
        
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
            if (location) {
                [[HMDTTMonitor defaultManager] hmdTrackService:@"home_location_error" status:0 extra:paramsExtra];
            }
        }
        
        NSMutableDictionary * amapInfo = [NSMutableDictionary new];
        
        amapInfo[@"sub_locality"] = location.district;
        amapInfo[@"locality"] = location.city;
        if (locationInfo.coordinate.latitude) {
            amapInfo[@"latitude"] = @(locationInfo.coordinate.latitude);
        }
        
        if (locationInfo.coordinate.longitude) {
            amapInfo[@"longitude"] = @(locationInfo.coordinate.longitude);
        }
        
        [[[FHHouseBridgeManager sharedInstance] envContextBridge] setUpLocationInfo:amapInfo];
        
        if (location) {
            wSelf.currentReGeocode = location;
        }
        
        if (locationInfo) {
            wSelf.currentLocaton = [[CLLocation alloc] initWithLatitude:locationInfo.coordinate.latitude longitude:locationInfo.coordinate.longitude];
        }
        
        // 存储当前定位信息
        [wSelf saveCurrentLocationData];
        
        if (completion) {
            // 城市选择重新定位需回调
            completion(location);
            [[FHEnvContext sharedInstance] updateRequestCommonParams];
        } else {
            NSInteger cityId = 0;
            if ([[FHEnvContext getCurrentSelectCityIdFromLocal] respondsToSelector:@selector(integerValue)]) {
                cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
            }
            [FHConfigAPI requestGeneralConfig:cityId gaodeLocation:locationInfo.coordinate gaodeCityId:location.cityCode gaodeCityName:location.city completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
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
                
                if ([model.data.citySwitch.enable respondsToSelector:@selector(boolValue)] && [model.data.citySwitch.enable boolValue] && self.isShowSwitch && !self.isShowSplashAdView && hasSelectedCity) {
                    [self showCitySwitchAlert:[NSString stringWithFormat:@"是否切换到当前城市:%@",model.data.citySwitch.cityName] openUrl:model.data.citySwitch.openUrl];
                }
                
                [FHEnvContext sharedInstance].isSendConfigFromFirstRemote = YES;
                [wSelf updateAllConfig:model isNeedDiff:NO];
                
                
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


@end
