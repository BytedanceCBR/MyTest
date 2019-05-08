//
//  FHMainManger.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import <Foundation/Foundation.h>
#import "FHLocationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMainManager : NSObject

@property(nonatomic , strong , readonly) FHLocationManager *locationManager;

+(instancetype)sharedInstance;


-(BOOL)locationSameAsChooseCity;

-(CLLocationCoordinate2D)currentLocation;

@end

NS_ASSUME_NONNULL_END
