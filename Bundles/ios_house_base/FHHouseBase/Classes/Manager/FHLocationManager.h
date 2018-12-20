//
//  FHLocationManager.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLocationManager : NSObject

-(CLLocationCoordinate2D)currentLocation;

-(CLAuthorizationStatus)currentAuthorizationStatus;

@end

NS_ASSUME_NONNULL_END
