//
// Created by zhulijun on 2019-12-02.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class MAMapView;
@class MAMapView;
@protocol MAAnnotation;
@protocol MAMapViewDelegate;


@interface FHDetailMapSnapTask : NSObject
@property(nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property(nonatomic, copy) NSArray<id <MAAnnotation>> *annotations;
@property(nonatomic, weak) id <MAMapViewDelegate> delegate;
@property(nonatomic, assign) CGRect frame;
@property(nonatomic, assign) CGRect targetRect;
@property(nonatomic, assign) NSUInteger maxTryCount;
@property(nonatomic, assign) NSUInteger slop;

//- (void)cancel;
@end

typedef void (^FHDetailMapSnapTaskBlk)(FHDetailMapSnapTask *task, UIImage *image, BOOL success);

@interface FHDetailMapViewSnapService : NSObject

+ (instancetype)sharedInstance;

//必须在主线程

- (FHDetailMapSnapTask *)takeSnapWith:(CLLocationCoordinate2D)center frame:(CGRect)frame targetRect:(CGRect)targetRect annotations:(NSArray<id <MAAnnotation>> *)annotations delegate:(id <MAMapViewDelegate>)delegate block:(FHDetailMapSnapTaskBlk)block;

- (FHDetailMapSnapTask *)takeSnapWith:(CLLocationCoordinate2D)center frame:(CGRect)frame targetRect:(CGRect)targetRect annotations:(NSArray<id <MAAnnotation>> *)annotations maxTryCount:(NSUInteger)maxTryCount delegate:(id <MAMapViewDelegate>)delegate block:(FHDetailMapSnapTaskBlk)block;

//- (void)cancelTask:(FHDetailMapSnapTask *)task;
@end