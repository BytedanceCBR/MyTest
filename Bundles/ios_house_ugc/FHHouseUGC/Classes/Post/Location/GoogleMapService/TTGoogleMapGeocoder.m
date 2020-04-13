//
//  TTGoogleMapGeocoder.m
//  TTLocationManager
//
//  Created by Vic on 2018/11/20.
//

#import "TTGoogleMapGeocoder.h"

#import "TTPlacemarkItem+GoogleAPI.h"

#import "TTPostThreadKitchenConfig.h"

#import <TTBaseLib/TTBaseMacro.h>
#import <TTKitchen/TTKitchenManager.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <AMapFoundationKit/AMapUtility.h>
#import <TTUGCFoundation/TTUGCRequestManager.h>

// address key
static NSString * const kTTKGMapLocationAddressComponent = @"address_components";
static NSString * const kTTKGMapLocationFormattedAddress = @"formatted_address";
static NSString * const kTTKGMapLocationComponentLongName = @"long_name";

// type key
static NSString * const kTTKGMapLocationCountry = @"country";
static NSString * const kTTKGMapLocationAdministrative_1 = @"administrative_area_level_1";
static NSString * const kTTKGMapLocationAdministrative_2 = @"administrative_area_level_2";
static NSString * const kTTKGMapLocationLocality = @"locality";

@interface TTGoogleMapGeocoder ()

@property (nonatomic, copy) NSString *googleMapKey;

@property (nonatomic, strong) TTGeocodeHandler geocodeHandler;

@property (nonatomic, strong) TTHttpTask *httpTask;

@end

@implementation TTGoogleMapGeocoder

static TTGoogleMapGeocoder *_sharedGeocoder;
+ (instancetype)sharedGeocoder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGeocoder = [[self alloc] init];
    });
    return _sharedGeocoder;
}

- (void)reverseGeocodeLocation:(CLLocation *)location timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(TTGeocodeHandler)completionHandler {
    
    // 原则上仅在Amap返回AMapDataAvailableForCoordinate非大陆地区并且高德返回失败的情况下使用GoogleMap
    // 相关Doc：https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding
    self.googleMapKey = [self googleApiKey];
    if (!isEmptyString(self.googleMapKey) && [self isGeocodeSupported] && ![[self class] ifInChina:location.coordinate]) {
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&language=zh-CN&key=%@", location.coordinate.latitude, location.coordinate.longitude, self.googleMapKey];
        
        [self.httpTask cancel];
        
        __weak TTGoogleMapGeocoder *weakSelf = self;
        self.httpTask = [TTUGCRequestManager requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:NO callBackWithMonitor:^(NSError *error, id jsonObj, TTHttpResponse *response) {
            if (completionHandler) {
                if ([jsonObj isKindOfClass:[NSDictionary class]] && completionHandler && [[jsonObj tt_stringValueForKey:@"status"] isEqualToString:@"OK"]) {
                    completionHandler(weakSelf, [weakSelf _placemarkItemWithGMapResponse:jsonObj], error);
                } else {
                    completionHandler(weakSelf, nil, error);
                }
            }
        }];
    } else {
        if (completionHandler) {
            completionHandler(self, nil, nil);
        }
    }
}

- (TTPlacemarkItem *)_placemarkItemWithGMapResponse:(NSDictionary *)response {
    NSArray *geocodeResult = [response tt_objectForKey:@"results"];
    if (geocodeResult && [geocodeResult count] > 0) {
        NSDictionary *bestGeocodeResultDic = [geocodeResult firstObject];
        NSArray *addressComponents = [bestGeocodeResultDic tt_objectForKey:kTTKGMapLocationAddressComponent];
        
        TTPlacemarkItem *bestGeocodeResult = [[TTPlacemarkItem alloc] init];
        bestGeocodeResult.type = PlacemarkItemTypeForeign;
        
        bestGeocodeResult.country = [[self _searchAddressComponentsWithArray:addressComponents keyword:kTTKGMapLocationCountry] tt_stringValueForKey:kTTKGMapLocationComponentLongName];
        bestGeocodeResult.address = [bestGeocodeResultDic tt_stringValueForKey:kTTKGMapLocationFormattedAddress];
        
        NSDictionary *cityData = [self _searchAddressComponentsWithArray:addressComponents keyword:kTTKGMapLocationLocality];
        
        // 城市选择策略
        if (cityData) {
            bestGeocodeResult.city = [cityData tt_stringValueForKey:kTTKGMapLocationComponentLongName];
        } else {
            cityData = [self _searchAddressComponentsWithArray:addressComponents keyword:kTTKGMapLocationAdministrative_1];
            bestGeocodeResult.city = [cityData tt_stringValueForKey:kTTKGMapLocationComponentLongName];
        }
        
        NSDictionary *geometryLocation = [[bestGeocodeResultDic tt_objectForKey:@"geometry"] tt_objectForKey:@"location"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [geometryLocation tt_doubleValueForKey:@"lat"];
        coordinate.longitude = [geometryLocation tt_doubleValueForKey:@"lng"];
        bestGeocodeResult.coordinate = coordinate;
        
        return bestGeocodeResult;
    } else {
        return nil;
    }
}

- (NSDictionary *)_searchAddressComponentsWithArray:(NSArray *)addreassComponents keyword:(NSString *)keyword {
    if (isEmptyString(keyword) || !addreassComponents) {
        return nil;
    }
    
    for (NSDictionary *subComponent in addreassComponents) {
        NSArray *types = [subComponent tt_arrayValueForKey:@"types"];
        
        for (NSString *typeWord in types) {
            if ([typeWord isEqualToString:keyword]) {
                return subComponent;
            }
        }
    }
    return nil;
}

- (void)cancel {
    [self.httpTask cancel];
}

- (BOOL)isGeocodeSupported {
    return [self isGMapSupported];
}

- (BOOL)isGMapSupported {
    return [TTKitchen getBOOL:kTTKGMapServiceAvailable];
}

- (NSString *)googleApiKey {
    return [self isGMapSupported] ? [TTKitchen getString:kTTKGMapKey] : @"";
}

- (NSString *)uploadFieldName {
    return [[self class] fieldName];
}

+ (NSString *)fieldName {
    return @"gmap_location";
}

+ (BOOL)ifInChina:(CLLocationCoordinate2D)coordinate {
    return AMapDataAvailableForCoordinate(AMapCoordinateConvert(coordinate, AMapCoordinateTypeGPS));
}

@end
