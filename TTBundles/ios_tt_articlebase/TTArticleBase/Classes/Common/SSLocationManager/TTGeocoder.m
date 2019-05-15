//
//  TTGeocoder.m
//  Article
//
//  Created by SunJiangting on 15-6-2.
//
//

#import "TTGeocoder.h"
#import <objc/runtime.h>
#import "TTBaseMacro.h"

@interface CLGeocoder (TTCompletionBlock)

@property(nonatomic, strong) TTGeocodeHandler geocodeHandler;
@property(nonatomic, strong) void(^ timeoutHandler)(CLGeocoder *);

@end

@implementation CLGeocoder (TTCompletionBlock)

static NSString *const TTHandlerKey = @"TTHandlerKey";
static NSString *const TTTimeoutHandlerKey = @"TTTimeoutHandlerKey";

- (void)setGeocodeHandler:(TTGeocodeHandler)geocodeHandler {
    objc_setAssociatedObject(self, (__bridge const void *)(TTHandlerKey), geocodeHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TTGeocodeHandler)geocodeHandler {
    return objc_getAssociatedObject(self, (__bridge const void *)(TTHandlerKey));
}

- (void)setTimeoutHandler:(void (^)(CLGeocoder *))timeoutHandler {
    objc_setAssociatedObject(self, (__bridge const void *)(TTTimeoutHandlerKey), timeoutHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(CLGeocoder *))timeoutHandler {
    return objc_getAssociatedObject(self, (__bridge const void *)(TTTimeoutHandlerKey));
}

- (void)didTriggerTimeout {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTriggerTimeout) object:nil];
    if (self.timeoutHandler) {
        self.timeoutHandler(self);
    }
}

@end

@interface TTGeocoder ()

@property(nonatomic, strong) CLLocation *location;

@property(nonatomic, strong) NSMutableArray     *geocoders;

@end

@implementation TTGeocoder

static TTGeocoder *_sharedGeocoder;
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
        self.geocoders = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

- (void)reverseGeocodeLocation:(CLLocation *)location
               timeoutInterval:(NSTimeInterval)timeoutInterval
             completionHandler:(TTGeocodeHandler)completionHandler {
    timeoutInterval = MAX(15, timeoutInterval);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    geocoder.geocodeHandler = completionHandler;
    [self.geocoders addObject:geocoder];
    __weak TTGeocoder *weakSelf = self;
    [geocoder performSelector:@selector(didTriggerTimeout) withObject:nil afterDelay:timeoutInterval];
    geocoder.timeoutHandler = ^(CLGeocoder *coder) {
        if (coder.geocodeHandler) {
            NSError *error = [NSError errorWithDomain:@"com.ss.article" code:NSURLErrorTimedOut userInfo:@{@"description":@"System reverse failed"}];
            coder.geocodeHandler(weakSelf, nil, error);
        }
        coder.geocodeHandler = nil;
        [weakSelf.geocoders removeObject:coder];
    };
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLGeocoder *coder = geocoder;
        [[coder class] cancelPreviousPerformRequestsWithTarget:coder selector:@selector(didTriggerTimeout) object:nil];
        TTPlacemarkItem *placemarkItem = [self _placemarkItemWithPlacemark:placemarks.firstObject];
        placemarkItem.coordinate = location.coordinate;
        if (coder.geocodeHandler) {
            coder.geocodeHandler(weakSelf, placemarkItem, error);
        }
        coder.geocodeHandler = nil;
        [weakSelf.geocoders removeObject:coder];
    }];
}

- (void)cancel {
    [self.geocoders enumerateObjectsUsingBlock:^(CLGeocoder *geocoder, NSUInteger idx, BOOL *stop) {
        if ([geocoder isKindOfClass:[CLGeocoder class]]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:geocoder selector:@selector(didTriggerTimeout) object:nil];
            geocoder.geocodeHandler = nil;
            geocoder.timeoutHandler = nil;
//            [geocoder cancelGeocode];
        }
    }];
    [self.geocoders removeAllObjects];
}

+ (BOOL)isGeocodeSupported {
    return YES;
}

- (BOOL)isGeocodeSupported {
    return [[self class] isGeocodeSupported];
}

- (TTPlacemarkItem *)_placemarkItemWithPlacemark:(CLPlacemark *)placemark {
    if (!placemark) {
        return nil;
    }
    TTPlacemarkItem *placemarkItem = [[TTPlacemarkItem alloc] init];
    placemarkItem.address = placemark.name;
    placemarkItem.province = placemark.administrativeArea;
    placemarkItem.city = [self _cityFromPlacemark:placemark];
    placemarkItem.district = [self _districtFromPlacemark:placemark];
    return placemarkItem;
}


- (NSString*)_cityFromPlacemark:(CLPlacemark*)placemark {
    if(!isEmptyString(placemark.locality)) {
        return placemark.locality;
    }
    if(!isEmptyString(placemark.administrativeArea)) {
        return placemark.administrativeArea;
    }
    return nil;
}

- (NSString*)_districtFromPlacemark:(CLPlacemark*)placemark {
    if (!isEmptyString(placemark.subLocality)) {
        return placemark.subLocality;
    }
    if (!isEmptyString(placemark.subAdministrativeArea)) {
        return placemark.subAdministrativeArea;
    }
    return nil;
}

- (NSString *)uploadFieldName {
    return @"sys_location";
}
@end
