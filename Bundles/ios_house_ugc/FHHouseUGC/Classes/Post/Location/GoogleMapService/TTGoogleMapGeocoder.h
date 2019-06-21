//
//  TTGoogleMapGeocoder.h
//  TTLocationManager
//
//  Created by Vic on 2018/11/20.
//

#import <Foundation/Foundation.h>
#import "TTGeocodeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTGoogleMapGeocoder : NSObject <TTGeocodeProtocol>

+ (instancetype)sharedGeocoder;

/** Google Map 是否可用（Settings控制） */
- (BOOL)isGMapSupported;

/** 获取Google Api Key */
- (NSString *)googleApiKey;

+ (BOOL)ifInChina:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
