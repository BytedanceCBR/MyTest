//
//  TTGoogleMapService.h
//  TTLocationManager
//
//  Created by Vic on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <TTNetworkManager/TTNetworkManager.h>

@class TTPlacemarkItem;

NS_ASSUME_NONNULL_BEGIN

/** Pass the value of the continueToken to -continueSearchWithContinueToken:completionBlock: to see the next set of results. */
typedef void (^TTGoogleMapServiceCompletionHandler)(NSArray <TTPlacemarkItem *> *placemarkItems, BOOL hasMore, NSString *continueToken, NSError *error);

@interface TTGoogleMapService : NSObject

/**
 load nearby location. The default radius is 3 000 meters, follow AMap's default rule

 @param coordinate current Coordinate
 */
+ (TTHttpTask *)requestNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock;

/**
 load nearby location. Radius defines the distance (in meters) within which to return place results. The maximum allowed radius is 50 000 meters
 
 @param coordinate current Coordinate
 @param radius range in circle
 */
+ (TTHttpTask *)requestNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(NSInteger)radius completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock;

/**
 search restricted nearby location. The default radius is 3 000 meters, follow AMap's default rule

 @param coordinate current Coordinate
 @param keywords keyword input
 */
+ (TTHttpTask *)requestSearchNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate keywords:(NSString *)keywords completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock;

/**
 search restricted nearby location. Radius defines the distance (in meters) within which to return place results. The maximum allowed radius is 50 000 meters
 
 @param coordinate current Coordinate
 @param keywords keyword input
 @param radius range in circle
 */
+ (TTHttpTask *)requestSearchNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate keywords:(NSString *)keywords radius:(NSInteger)radius completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock;

/**
 continue search

 @param continueToken continueToken get during last request completion block
 */
+ (TTHttpTask *)continueSearchWithContinueToken:(NSString *)continueToken completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock;

@end

NS_ASSUME_NONNULL_END
