//
//  SSLocationPickerController.m
//  STKitDemo
//
//  Created by SunJiangting on 15-2-27.
//  Copyright (c) 2015年 SunJiangting. All rights reserved.
//

#import "SSLocationPickerController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SSDebugViewController.h"

@interface STAnnotation : NSObject <MKAnnotation>

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@end

@implementation STAnnotation
@synthesize coordinate = _coordinate;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    return _subtitle;
}

@end

@interface SSLocationPickerController () <MKMapViewDelegate>

@property(nonatomic, strong) MKMapView *mapView;

@end

@implementation SSLocationPickerController

- (void)dealloc {
    [[self class] setCachedRegion:self.mapView.region];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"模拟当前位置";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(_finishPickLocation:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(_clearFakeLocations:)];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    MKCoordinateRegion region = [[self class] cachedRegion];
    if (region.center.longitude * region.center.latitude != 0) {
        [self.mapView setRegion:[[self class] cachedRegion] animated:YES];
    }
    
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressGestureRecognizerActionFired:)];
    gestureRecognizer.minimumPressDuration = 0.5f;
    gestureRecognizer.delaysTouchesBegan = NO;
    [self.mapView addGestureRecognizer:gestureRecognizer];
    
    CLLocationCoordinate2D coordinate2D = [[self class] cachedFakeLocationCoordinate];
    if (coordinate2D.latitude * coordinate2D.longitude != 0) {
        [self _reloadLocateAnnotationWithCoordinate:coordinate2D];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_clearFakeLocations:(id)sender {
    CLLocationCoordinate2D coordinate2D = {0.0, 0.0};
    [[self class] setCachedFakeLocationCoordinate:coordinate2D];
    NSArray *annotations = [self.mapView.annotations objectsOfClass:[STAnnotation class]];
    [self.mapView removeAnnotations:annotations];
}

- (void)_finishPickLocation:(id)sender {
    if (self.completionHandler) {
        self.completionHandler(self);
    }
}

- (void)_longPressGestureRecognizerActionFired:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPressGestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        longPressGestureRecognizer.enabled = NO;
        longPressGestureRecognizer.enabled = YES;
        [[self class] setCachedFakeLocationCoordinate:coordinate];
        [self _reloadLocateAnnotationWithCoordinate:coordinate];
    }
}

- (void)_reloadLocateAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    STAnnotation *annotation = [[self.mapView annotations] firstObjectOfClass:[STAnnotation class]];
    if (!annotation) {
        annotation = [[STAnnotation alloc] init];
    } else {
        [self.mapView removeAnnotation:annotation];
    }
    annotation.title = [NSString stringWithFormat:@"%.8f, %.8f", coordinate.longitude, coordinate.latitude];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
}

+ (void)setCachedRegion:(MKCoordinateRegion)region {
    NSDictionary *coordinate = @{@"longitude":@(region.center.longitude), @"latitude":@(region.center.latitude), @"latitudeDelta":@(region.span.latitudeDelta), @"longitudeDelta":@(region.span.longitudeDelta)};
    [[NSUserDefaults standardUserDefaults] setValue:coordinate forKey:@"STMapRegionCacheKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (MKCoordinateRegion)cachedRegion {
    NSDictionary *coordinate = [[NSUserDefaults standardUserDefaults] valueForKey:@"STMapRegionCacheKey"];
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.longitude = [coordinate[@"longitude"] doubleValue];
    coordinate2D.latitude = [coordinate[@"latitude"] doubleValue];
    
    MKCoordinateSpan span;
    span.latitudeDelta = [coordinate[@"latitudeDelta"] doubleValue];
    span.longitudeDelta = [coordinate[@"longitudeDelta"] doubleValue];
    
    MKCoordinateRegion region;
    region.center = coordinate2D;
    region.span = span;
    return region;
}

+ (void)setCachedFakeLocationCoordinate:(CLLocationCoordinate2D)coordinate2D {
    NSDictionary *coordinate = @{@"longitude":@(coordinate2D.longitude), @"latitude":@(coordinate2D.latitude)};
    [[NSUserDefaults standardUserDefaults] setValue:coordinate forKey:SSFakeLocationCoordinateCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (CLLocationCoordinate2D)cachedFakeLocationCoordinate {
    NSDictionary *coordinate = [[NSUserDefaults standardUserDefaults] valueForKey:SSFakeLocationCoordinateCacheKey];
    CLLocationCoordinate2D coordinate2D;
    coordinate2D.longitude = [coordinate[@"longitude"] doubleValue];
    coordinate2D.latitude = [coordinate[@"latitude"] doubleValue];
    return coordinate2D;
}
@end

@implementation NSArray (STAccessory)

- (NSUInteger)firstIndexOfClass:(Class)aClass {
    __block NSUInteger index = NSNotFound;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:aClass]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (id)firstObjectOfClass:(Class)aClass {
    NSUInteger idx = [self firstIndexOfClass:aClass];
    if (idx == NSNotFound) {
        return nil;
    }
    return self[idx];
}

- (NSArray *)objectsOfClass:(Class)aClass {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:aClass]) {
            [objects addObject:obj];
        }
    }];
    return objects;
}
@end

NSString *const SSFakeLocationCoordinateCacheKey = @"SSFakeLocationCoordinateCacheKey";