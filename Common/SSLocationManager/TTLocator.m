//
//  TTLocator.m
//  Article
//
//  Created by SunJiangting on 15-4-29.
//
//

#import "TTLocator.h"


@interface TTLocator () <CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSMutableArray    *locateHandlers;
@property(nonatomic, getter=isLoadingUserLocation) BOOL loadingUserLocation;

//保存是否需要上报定位系统弹窗授权通过状态
@property(nonatomic, assign) BOOL shouldReportSSTrack;
@end

@implementation TTLocator

static TTLocator *_sharedLocator;
+ (instancetype)sharedLocator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocator = [[self alloc] init];
    });
    return _sharedLocator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = [TTLocationManager desiredAccuracy];
        
        self.locateHandlers = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}


- (void)locateWithTimeoutInterval:(NSTimeInterval)timeInterval
                completionHandler:(TTLocateHandler)completionHandler {
    if (completionHandler) {
        [self.locateHandlers addObject:completionHandler];
    }
    if (!self.loadingUserLocation) {
        [self startUpdatingLocation];
        timeInterval = MAX(15, timeInterval);
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(didTriggerTimeout) withObject:nil afterDelay:timeInterval];
    }
}

- (void)didTriggerTimeout {
    NSError *error = [NSError errorWithDomain:@"com.ss.article" code:-10001 userInfo:@{@"description":@"Locate Timeout"}];
    [self _updateUserLocation:nil error:error];
}

- (void)startUpdatingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        wrapperTrackEvent(@"pop", @"location_permission_show");
        _shouldReportSSTrack = YES;
    }
    self.locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.loadingUserLocation = YES;
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.loadingUserLocation = NO;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(_shouldReportSSTrack){
        _shouldReportSSTrack = NO;
        wrapperTrackEvent(@"pop",@"location_permission_confirm");
    }
    [self _updateUserLocation:locations.lastObject error:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(_shouldReportSSTrack){
        _shouldReportSSTrack = NO;
        wrapperTrackEvent(@"pop", @"location_permission_cancel");
    }
    [self _updateUserLocation:nil error:error];
}

- (CLLocation *)otherCity
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:32.08 longitude:112.20];
    return location;
}

- (CLLocation *)beijingCity
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:39.97426316 longitude:116.33224726];
    return location;
}


- (void)_updateUserLocation:(CLLocation *)userLocation error:(NSError *)error {
    
    if ([TTLocationManager isValidLocation:userLocation]) {
        [self _notifyLocation:userLocation error:error];
    } else if (error) {
        [self _notifyLocation:userLocation error:error];
    }
}

- (void)_notifyLocation:(CLLocation *)location error:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self stopUpdatingLocation];
    if (self.locateHandlers) {
        [self.locateHandlers enumerateObjectsUsingBlock:^(TTLocateHandler obj, NSUInteger idx, BOOL *stop) {
            if (obj) {
                obj(location, error);
            }
        }];
    }
    [self.locateHandlers removeAllObjects];
}

- (void)cancel {
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self.locateHandlers removeAllObjects];
    [self stopUpdatingLocation];
}

@end

