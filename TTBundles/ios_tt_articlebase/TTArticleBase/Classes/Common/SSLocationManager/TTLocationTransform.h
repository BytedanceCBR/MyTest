//
//  TTLocationTransform.h
//  Article
//
//  Created by 王霖 on 15/8/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TTLocationTransform : NSObject

/**
 *  WGS-84坐标转成GCJ-02坐标
 *
 *  @param location WGS-84坐标
 *
 *  @return GCJ-02坐标
 */
+ (CLLocationCoordinate2D)transformToGCJ02LocationWithWGS84Location:(CLLocationCoordinate2D)location;

/**
 *  BD-09坐标转成GCJ-02坐标
 *
 *  @param location BD-09坐标
 *
 *  @return GCJ-02坐标
 */
+ (CLLocationCoordinate2D)transformB09ToGCJ02WithLocation:(CLLocationCoordinate2D)location;

@end
