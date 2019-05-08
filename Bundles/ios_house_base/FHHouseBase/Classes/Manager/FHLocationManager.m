//
//  FHLocationManager.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHLocationManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "FHHouseBridgeManager.h"

@interface FHLocationManager ()<AMapLocationManagerDelegate>

@property(nonatomic , assign) CLAuthorizationStatus authorizationStatus;
@property(nonatomic , strong) AMapLocationReGeocode *locationRegeocode;
@property(nonatomic , assign) CLLocationCoordinate2D centerLocation;

@end

@implementation FHLocationManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(CLLocationCoordinate2D)currentLocation
{
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    return [contextBridge currentLocation];
}

-(CLAuthorizationStatus)currentAuthorizationStatus
{
    return _authorizationStatus;
}

/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

/**
 *  @brief 连续定位回调函数.注意：本方法已被废弃，如果实现了amapLocationManager:didUpdateLocation:reGeocode:方法，则本方法将不会回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    
}

/**
 *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 *  @param reGeocode 逆地理信息。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    self.locationRegeocode = reGeocode;
    self.centerLocation = location.coordinate;
    
}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

@end
