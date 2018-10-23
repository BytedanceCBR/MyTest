//
//  TTAmapGeocoder.m
//  Article
//
//  Created by SunJiangting on 15-5-27.
//
//

#import "TTAmapGeocoder.h"
#import "TTLocationTransform.h"

@interface TTAmapGeocoder () <AMapSearchDelegate>

@property(nonatomic, strong) AMapSearchAPI *searchAPI;
@property(nonatomic) CLLocationCoordinate2D coordinate2D;
@property(nonatomic, strong) TTGeocodeHandler completionHandler;

@end

@implementation TTAmapGeocoder

static TTAmapGeocoder *_sharedGeocoder;
+ (instancetype)sharedGeocoder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGeocoder = [[self alloc] init];
    });
    return _sharedGeocoder;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (AMapSearchAPI *)searchAPI {
    if (!_searchAPI && [self isGeocodeSupported]) {
        // f100
        //[AMapSearchServices sharedServices].apiKey = [SSCommonLogic amapKey];
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}

- (void)reverseGeocodeLocation:(CLLocation *)location timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(TTGeocodeHandler)completionHandler {
    timeoutInterval = MAX(timeoutInterval, 15);
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    self.completionHandler = completionHandler;
    
    if (self.searchAPI) {
        [self performSelector:@selector(didTriggerTimeout) withObject:nil afterDelay:timeoutInterval];
        
        //保存原始coordinate
        self.coordinate2D = location.coordinate;
        
        CLLocationCoordinate2D coordinate = [TTLocationTransform transformToGCJ02LocationWithWGS84Location:location.coordinate];
        AMapGeoPoint *geoPoint = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.location = geoPoint;
        [self.searchAPI AMapReGoecodeSearch:request];
    } else {
        [self performSelector:@selector(didTriggerTimeout) withObject:nil afterDelay:0.0];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    [self _geoGeocodeSearchRequest:request didFinishWithResponse:nil error:error];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    [self _geoGeocodeSearchRequest:request didFinishWithResponse:response error:nil];
}

- (void)_geoGeocodeSearchRequest:(AMapReGeocodeSearchRequest *)request didFinishWithResponse:(AMapReGeocodeSearchResponse *)response error:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    if (self.completionHandler) {
        if (error) {
            self.completionHandler(self, nil, error);
        } else {
            TTPlacemarkItem *item = [self _placemarkItemWithAMapResponse:response];

            //AMapGeoPoint *point = response.regeocode.addressComponent.streetNumber.location;
          
            //回传原始coordinate
            item.coordinate = self.coordinate2D;
            
            self.completionHandler(self, item, error);
        }
    }
    self.completionHandler = nil;
}


- (void)didTriggerTimeout {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    if (self.completionHandler) {
        NSError *error = [NSError errorWithDomain:@"com.ss.article" code:NSURLErrorTimedOut userInfo:@{@"description":@"baidu reverse failed"}];
        self.completionHandler(self, nil, error);
    }
    self.completionHandler = nil;
}

- (TTPlacemarkItem *)_placemarkItemWithAMapResponse:(AMapReGeocodeSearchResponse *)response {
    if (![response isKindOfClass:[AMapReGeocodeSearchResponse class]]) {
        return nil;
    }
    TTPlacemarkItem *placemarkItem = [[TTPlacemarkItem alloc] init];
    placemarkItem.address = response.regeocode.formattedAddress;
    placemarkItem.province = response.regeocode.addressComponent.province;
    placemarkItem.city = response.regeocode.addressComponent.city;
    placemarkItem.district = response.regeocode.addressComponent.district;
    return placemarkItem;
}

- (void)cancel {
    self.completionHandler = nil;
}

- (BOOL)isGeocodeSupported {
    return [[self class] isGeocodeSupported];
}

+ (BOOL)isGeocodeSupported {
    return !isEmptyString([SSCommonLogic amapKey]);
}

- (NSString *)uploadFieldName {
    return @"amap_location";
}

@end
