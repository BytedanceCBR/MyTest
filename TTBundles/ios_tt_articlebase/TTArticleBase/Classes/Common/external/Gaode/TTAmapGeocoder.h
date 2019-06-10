//
//  TTAmapGeocoder.h
//  Article
//
//  Created by SunJiangting on 15-5-27.
//
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "TTLocationManager.h"

@interface TTAmapGeocoder : NSObject <TTGeocodeProtocol>

+ (instancetype)sharedGeocoder;

@end