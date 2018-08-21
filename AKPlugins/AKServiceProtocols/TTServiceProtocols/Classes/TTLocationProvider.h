//
//  TTLocationProvider.h
//  Pods
//
//  Created by 王双华 on 17/3/9.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@protocol TTLocationProvider <NSObject>

@required

/**
 获取定位服务的城市名称
 
 @return 城市名称
 */
- (NSString *)getLocationCityName;

/**
 获取定位服务服务端返回的命令id
 
 @return 命令id
 */
- (NSString *)getLocationCommandIdentifier;

/**
 获取定位服务是否开启
 
 @return 开启/关闭
 */
- (BOOL)getLocationServiceEnable;

/**
 获取定位服务状态
 
 @return 状态字符串
 */
- (NSString *)getLocationServiceStatus;

/**
 获取定位精度
 
 @return best 最高精度
 */
- (CLLocationAccuracy)getLocationDesiredAccuracy;
@end
