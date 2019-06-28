    //
//  TTLocationManager.m
//  Article
//
//  Created by SunJiangting on 15-4-22.
//
//

#import "TTLocationManager.h"
#import "TTNetworkManager.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "SSCommonLogic.h"
#import "TTThemedAlertController.h"

#import "TTArticleCategoryManager.h"
#import "SSDebugViewController.h"

#import "SSLocationPickerController.h"
#import "TTAuthorizeManager.h"
#import "NewsUserSettingManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTFastCoding.h"
#import "TTLocator.h"
#import "TTGeocoder.h"
#import "TTModuleBridge.h"
#import "TTAmapGeocoder.h"
#import "NSDataAdditions.h"
#import "TTArticleTabBarController.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTTabBarProvider.h"
#import "TTLocationTransform.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "CommonURLSetting.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTBaseLib/TTSandBoxHelper.h>

@implementation TTLocationManagerAmapInfo

+ (instancetype)sharedInstance {
    static TTLocationManagerAmapInfo *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[TTLocationManagerAmapInfo alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end


@implementation TTLocationManager (FHHouse)

- (void)setUpAmapInfo:(NSDictionary *)locationDict
{
    [TTLocationManagerAmapInfo sharedInstance].locationDictInfo = locationDict;
}

- (NSDictionary *)getAmapInfo
{
    return [TTLocationManagerAmapInfo sharedInstance].locationDictInfo;
}

@end


@implementation TTLocationManager (TTConvinceAccess)

//有位置服务的请求，通过TTAuthorizeLocationObj判断是否可以
- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler{
    [[TTAuthorizeManager sharedManager].locationObj filterAuthorizeStrategyWithCompletionHandler:completionHandler authCompleteBlock:^(TTAuthorizeLocationArrayParamBlock arrayParamBlock) {
       [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:arrayParamBlock];
    } sysAuthFlag:0];//显示系统弹窗前显示自有弹窗的逻辑下掉，0代表直接显示系统弹窗，1代表先自有弹窗，再系统弹窗
}

//授权完成后调用
- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void (^)(NSArray *))completionHandler{
    [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:completionHandler];
}

- (TTPlacemarkItem *)placemarkItem {
    return [self _placemarkItemWithFieldName:@"sys_location"];
}

- (TTPlacemarkItem *)baiduPlacemarkItem {
    return [self _placemarkItemWithFieldName:@"baidu_location"];
}

- (TTPlacemarkItem *)amapPlacemarkItem {
    return [self _placemarkItemWithFieldName:@"amap_location"];
}


- (TTPlacemarkItem *)getPlacemarkItem {

    TTPlacemarkItem *placemarkItem = nil;
    if ([self amapPlacemarkItem]) {

        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:[[self amapPlacemarkItem] coordinate]];
        placemarkItem = [[TTPlacemarkItem alloc] init];
        placemarkItem.coordinate = coordinate2D;
        placemarkItem.timestamp = [[self amapPlacemarkItem] timestamp];
        placemarkItem.address = [[self amapPlacemarkItem] address];
        placemarkItem.province = [[self amapPlacemarkItem] province];
        placemarkItem.city = [[self amapPlacemarkItem] city];
        placemarkItem.district = [[self amapPlacemarkItem] district];

    } else if ([self baiduPlacemarkItem]) {

        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformB09ToGCJ02WithLocation:[[self baiduPlacemarkItem] coordinate]];
        placemarkItem = [[TTPlacemarkItem alloc] init];
        placemarkItem.coordinate = coordinate2D;
        placemarkItem.timestamp = [[self baiduPlacemarkItem] timestamp];
        placemarkItem.address = [[self baiduPlacemarkItem] address];
        placemarkItem.province = [[self baiduPlacemarkItem] province];
        placemarkItem.city = [[self baiduPlacemarkItem] city];
        placemarkItem.district = [[self baiduPlacemarkItem] district];

    } else if ([self placemarkItem]) {
        CLLocationCoordinate2D coordinate2D = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:[[self placemarkItem] coordinate]];
        placemarkItem = [[TTPlacemarkItem alloc] init];
        placemarkItem.coordinate = coordinate2D;
        placemarkItem.timestamp = [[self placemarkItem] timestamp];
        placemarkItem.address = [[self placemarkItem] address];
        placemarkItem.province = [[self placemarkItem] province];
        placemarkItem.city = [[self placemarkItem] city];
        placemarkItem.district = [[self placemarkItem] district];
    }

    if (placemarkItem == nil) {
        return nil;
    }

    if (isEmptyString(placemarkItem.city) && isEmptyString(placemarkItem.province)) {
        return nil;
    }

    return placemarkItem;
}

- (TTPlacemarkItem *)_placemarkItemWithFieldName:(NSString *)fieldName {
    if (SSIsEmptyArray(self.placemarks) || isEmptyString(fieldName)) {
        return nil;
    }
    __block TTPlacemarkItem *item = nil;
    [self.placemarks enumerateObjectsUsingBlock:^(TTPlacemarkItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TTPlacemarkItem class]]) {
            if ([obj.fieldName isEqualToString:fieldName]) {
                item = obj;
                *stop = YES;
            }
        }
    }];
    return item;
}

@end

@implementation TTLocationManager (TTCityUpload)

- (void)uploadUserCityWithName:(NSString *)name completionHandler:(void(^)(NSError *))completionHandler {
    NSMutableDictionary *parameters = [[TTNetworkUtilities commonURLParameters] mutableCopy];
    NSMutableDictionary *cityParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (!isEmptyString(name)) {
        cityParameters[@"city_name"] = name;
    }
    cityParameters[@"submit_time"] = @([[NSDate date] timeIntervalSince1970]);
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:cityParameters options:NSJSONWritingPrettyPrinted error:&error];
    if (!error && JSONData.length > 0) {
        NSString *csinfo = [[JSONData tt_dataWithFingerprintType:(TTFingerprintTypeXOR)] ss_base64EncodedString];
        if (!isEmptyString(csinfo)) {
            parameters[@"csinfo"] = csinfo;
        }
    }
    
    NSString * url = [[NSURL tt_URLWithString:[CommonURLSetting uploadUserCityURLString] parameters:@{@"timestamp": @([[NSDate date] timeIntervalSince1970])}] absoluteString];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameters method:@"POST" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

@end

@implementation TTLocationManager (TTStatus)

+ (BOOL)isLocationServiceEnabled {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined ||
        status == kCLAuthorizationStatusRestricted ||
        status == kCLAuthorizationStatusDenied) {
        return NO;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        if (status == kCLAuthorizationStatusAuthorizedAlways ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            return YES;
        }
    } else {
        if (status == kCLAuthorizationStatusAuthorizedAlways) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)currentLBSStatus {
    NSString *LBSStatus = @"unknown";
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            LBSStatus = @"not_determine";
            break;
        case kCLAuthorizationStatusDenied:
            LBSStatus = @"deny";
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            LBSStatus = @"authroize";
            break;
        case kCLAuthorizationStatusRestricted:
            LBSStatus = @"restrict";
            break;
        default:
            break;
    }
    if([TTDeviceHelper OSVersionNumber] >= 8.0) {
        if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            LBSStatus = @"authroize";
        }
    }
    return LBSStatus;
}

+ (CLLocationAccuracy)desiredAccuracy {
    //采用best, 3km的精度可能只用基站定位, best时会综合多种定位方式, 同时delegate的调用是逼近式的, 会通过多次回调来逼近best精度, 不用担心定位速度.
    return kCLLocationAccuracyBest;
}

+ (BOOL)isValidLocation:(CLLocation *)location {
    if (!location) {
        return NO;
    }
    //检测时间是为了屏蔽缓存位置点, 系统为了快速给出点, 往往头两个点是系统缓存点, 可能存在问题, 比如从A地移动到B地, 初始的两个点很大可能依旧在A地;
    NSTimeInterval locationDuration = fabs([location.timestamp timeIntervalSinceNow]);
    return (locationDuration < 10.0 && location.horizontalAccuracy < 3000.0);
}

@end
