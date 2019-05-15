//
//  TTGeocoder.h
//  Article
//
//  Created by SunJiangting on 15-6-2.
//
//

#import <Foundation/Foundation.h>
#import "TTLocationManager.h"

@interface TTGeocoder : NSObject <TTGeocodeProtocol>

+ (instancetype)sharedGeocoder;

@end