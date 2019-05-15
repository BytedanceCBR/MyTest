//
//  TTLocationTransform.m
//  Article
//
//  Created by 王霖 on 15/8/12.
//
//

#import "TTLocationTransform.h"

@implementation TTLocationTransform

const double a = 6378245.0;
const double ee = 0.00669342162296594323;

+ (CLLocationCoordinate2D)transformToGCJ02LocationWithWGS84Location:(CLLocationCoordinate2D)location {
    CLLocationDegrees latitude = location.latitude;
    CLLocationDegrees longitude = location.longitude;
    if (longitude < 72.004 || longitude > 137.8347) {
        return location;
    }
    if (latitude < 0.8293 || latitude > 55.8271) {
        return location;
    }
    
    CLLocationDegrees dLat = [self transformLatitudeWithX:longitude - 105.0 andY:latitude - 35.0];
    CLLocationDegrees dLon = [self transformLongitudeWithX:longitude - 105.0 andY:latitude - 35.0];
    CLLocationDegrees radLat = latitude / 180.0 * M_PI;
    CLLocationDegrees magic = sin(radLat);
    magic = 1 - ee * magic *magic;
    CLLocationDegrees sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    latitude = latitude + dLat;
    longitude = longitude + dLon;
    
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(latitude, longitude);
    return coordinate2D;
}

+ (CLLocationDegrees)transformLatitudeWithX:(CLLocationDegrees)x andY:(CLLocationDegrees)y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (CLLocationDegrees)transformLongitudeWithX:(CLLocationDegrees)x andY:(CLLocationDegrees)y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}


const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
+ (CLLocationCoordinate2D)transformB09ToGCJ02WithLocation:(CLLocationCoordinate2D)location {
    CLLocationDegrees bd_lat = location.latitude;
    CLLocationDegrees bd_lon = location.longitude;
    CLLocationDegrees x = bd_lon - 0.0065, y = bd_lat - 0.006;
    CLLocationDegrees z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    CLLocationDegrees lon = z * cos(theta);
    CLLocationDegrees lat = z * sin(theta);
    
    return CLLocationCoordinate2DMake(lat, lon);
}


@end
