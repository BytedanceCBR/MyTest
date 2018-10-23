//
//  TTPlacemarkItemProtocol.h
//  TTUGCFoundation
//
//  Created by ranny_90 on 2018/1/30.
//

#ifndef TTPlacemarkItemProtocol_h
#define TTPlacemarkItemProtocol_h

#import <MapKit/MapKit.h>

@protocol TTPlacemarkItemProtocol <NSObject>

@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic) NSTimeInterval  timestamp;
@property(nonatomic, copy) NSString  *address;
@property(nonatomic, copy) NSString  *province;
@property(nonatomic, copy) NSString  *city;
@property(nonatomic, copy) NSString  *district;

@end


#endif /* TTPlacemarkItemProtocol_h */
