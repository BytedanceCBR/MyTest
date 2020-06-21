//
//  TTGoogleMapService.m
//  TTLocationManager
//
//  Created by Vic on 2018/11/21.
//

#import "TTGoogleMapService.h"

#import "TTGoogleMapGeocoder.h"
#import "TTPlacemarkItem+GoogleAPI.h"

#import <TTKitchen/TTKitchen.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTUGCFoundation/TTUGCRequestManager.h>

static NSString * const kTTKGMapSearchNextPageToken = @"next_page_token";

static NSString * const kTTKGMapSearchResultName = @"name";
static NSString * const kTTKGMapSearchResultAddress = @"vicinity";
static NSString * const kTTKGMapSearchResultTypeTags = @"types";

// Doc URL:https://developers.google.com/places/web-service/search
@implementation TTGoogleMapService

+ (TTHttpTask *)requestNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock {
    return [self requestNearbyLocationWithCoordinate:coordinate radius:3000 completionBlock:completionBlock];
}

+ (TTHttpTask *)requestNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate radius:(NSInteger)radius completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock {
    
    BOOL isGMapSupported = [[TTGoogleMapGeocoder sharedGeocoder] isGMapSupported];
    NSString *googleMapKey = [[TTGoogleMapGeocoder sharedGeocoder] googleApiKey];
    if (isGMapSupported && !isEmptyString(googleMapKey)) {
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%ld&language=zh-CN&key=%@", coordinate.latitude, coordinate.longitude, radius, googleMapKey];

        return [TTUGCRequestManager requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:NO callBackWithMonitor:^(NSError *error, id jsonObj, TTHttpResponse *response) {
            if (completionBlock) {
                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                    NSString *continueToken = [jsonObj tt_stringValueForKey:kTTKGMapSearchNextPageToken];
                    completionBlock([self p_placemarkItemsWithGMApResponse:jsonObj], !isEmptyString(continueToken), continueToken, error);
                } else {
                    completionBlock(nil, NO, nil, error);
                }
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(nil, NO, nil, nil);
        }
        return nil;
    }
}

+ (TTHttpTask *)requestSearchNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate keywords:(NSString *)keywords completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock {
    return [self requestSearchNearbyLocationWithCoordinate:coordinate keywords:keywords radius:3000 completionBlock:completionBlock];
}

+ (TTHttpTask *)requestSearchNearbyLocationWithCoordinate:(CLLocationCoordinate2D)coordinate keywords:(NSString *)keywords radius:(NSInteger)radius completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock {
    
    BOOL isGMapSupported = [[TTGoogleMapGeocoder sharedGeocoder] isGMapSupported];
    NSString *googleMapKey = [[TTGoogleMapGeocoder sharedGeocoder] googleApiKey];
    if (isGMapSupported && !isEmptyString(googleMapKey)) {
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%ld&keyword=%@&language=zh-CN&key=%@", coordinate.latitude, coordinate.longitude, radius, [self encodedWithString:keywords], googleMapKey];

        return [TTUGCRequestManager requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:NO callBackWithMonitor:^(NSError *error, id jsonObj, TTHttpResponse *response) {
            if (completionBlock) {
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj tt_stringValueForKey:@"status"] isEqualToString:@"OK"]) {
                    NSString *continueToken = [jsonObj tt_stringValueForKey:kTTKGMapSearchNextPageToken];
                    completionBlock([self p_placemarkItemsWithGMApResponse:jsonObj], !isEmptyString(continueToken), continueToken, error);
                } else {
                    completionBlock(nil, NO, nil, error);
                }
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(nil, NO, nil, nil);
        }
        return nil;
    }
}

+ (NSString *)encodedWithString:(NSString *)str {
    if (![str isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)str,
                                                                                             NULL,
                                                                                             CFSTR(":/?#@!$&'(){}*+="),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

+ (TTHttpTask *)continueSearchWithContinueToken:(NSString *)continueToken completionBlock:(TTGoogleMapServiceCompletionHandler)completionBlock {
    
    BOOL isGMapSupported = [[TTGoogleMapGeocoder sharedGeocoder] isGMapSupported];
    NSString *googleMapKey = [[TTGoogleMapGeocoder sharedGeocoder] googleApiKey];
    if (isGMapSupported && !isEmptyString(googleMapKey) && !isEmptyString(continueToken)) {
        
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=%@&key=%@", continueToken, googleMapKey];

        return [TTUGCRequestManager requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:NO callBackWithMonitor:^(NSError *error, id jsonObj, TTHttpResponse *response) {
            if (completionBlock) {
                if ([jsonObj isKindOfClass:[NSDictionary class]] && [[jsonObj tt_stringValueForKey:@"status"] isEqualToString:@"OK"]) {
                    NSString *continueToken = [jsonObj tt_stringValueForKey:kTTKGMapSearchNextPageToken];
                    completionBlock([self p_placemarkItemsWithGMApResponse:jsonObj], !isEmptyString(continueToken), continueToken, error);
                } else {
                    completionBlock(nil, NO, nil, error);
                }
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(nil, NO, nil, nil);
        }
        return nil;
    }
}

+ (NSArray <TTPlacemarkItem *> *)p_placemarkItemsWithGMApResponse:(NSDictionary *)response {
    NSMutableArray *nearbyLocationResult = [NSMutableArray new];
    
    NSArray *locations = [response tt_objectForKey:@"results"];
    for (NSDictionary *itemDic in locations) {
        TTPlacemarkItem *placemark = [[TTPlacemarkItem alloc] init];
        placemark.type = PlacemarkItemTypeForeign;
        
        NSDictionary *geometryLocation = [[itemDic tt_objectForKey:@"geometry"] tt_objectForKey:@"location"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [geometryLocation tt_doubleValueForKey:@"lat"];
        coordinate.longitude = [geometryLocation tt_doubleValueForKey:@"lng"];
        placemark.coordinate = coordinate;
        
        placemark.name = [itemDic tt_stringValueForKey:kTTKGMapSearchResultName];
        placemark.address = [itemDic tt_stringValueForKey:kTTKGMapSearchResultAddress];
        
        // locality | sublocality | postal_code | country | administrative_area_level_1 | administrative_area_level_2 政治实体
        placemark.locationTags = [itemDic tt_arrayValueForKey:kTTKGMapSearchResultTypeTags];
        
        placemark.fieldName = [TTGoogleMapGeocoder fieldName];
        
        [nearbyLocationResult addObject:placemark];
    }
    return [nearbyLocationResult copy];
}

@end
