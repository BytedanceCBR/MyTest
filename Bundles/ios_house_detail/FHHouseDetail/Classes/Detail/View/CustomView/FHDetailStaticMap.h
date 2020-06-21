//
// Created by zhulijun on 2019-11-27.
//

#import <Foundation/Foundation.h>
#import "MAPointAnnotation.h"
//静态地图固定宽高比例
extern const CGFloat kStaticMapHWRatio;

@interface FHStaticMapAnnotation : MAPointAnnotation
@property(nonatomic, copy) NSString *extra;
@end

@interface FHStaticMapAnnotationView : UIView
@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGSize annotationSize;

- (instancetype)initWithAnnotation:(FHStaticMapAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol FHStaticMapDelegate;

@interface FHDetailStaticMap : UIView
@property(nonatomic, weak) id <FHStaticMapDelegate> delegate;

+ (instancetype)mapWithFrame:(CGRect)frame;

- (void)loadMap:(NSString *)url center:(CLLocationCoordinate2D)center latRatio:(CGFloat)latRatio lngRatio:(CGFloat)lngRatio;

- (void)addAnnotations:(NSArray<FHStaticMapAnnotation *> *)annotations;

- (void)removeAnnotations:(NSArray<FHStaticMapAnnotation *> *)annotations;

- (void)removeAllAnnotations;

- (FHStaticMapAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;
@end

@protocol FHStaticMapDelegate <NSObject>

@optional
- (void)mapView:(FHDetailStaticMap *)mapView loadFinished:(BOOL)success message:(NSString *)message;

- (FHStaticMapAnnotationView *)mapView:(FHDetailStaticMap *)mapView viewForStaticMapAnnotation:(FHStaticMapAnnotation *)annotation;

@end
