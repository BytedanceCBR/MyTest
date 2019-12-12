//
// Created by zhulijun on 2019-11-27.
//

#import <CoreLocation/CoreLocation.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHDetailStaticMap.h"
#import "BDWebImageRequest.h"
#import "FHCommonDefines.h"
#import "TTReachability.h"
#import "TTBaseMacro.h"
#import "MAMapKit.h"

@interface FHStaticMapAnnotation ()
@property(nonatomic, weak) FHStaticMapAnnotationView *annotationView;
@end

@implementation FHStaticMapAnnotation
@end

@interface FHStaticMapAnnotationView ()
@property(nonatomic, strong) FHStaticMapAnnotation *annotation;
@property(nonatomic, strong) NSString *reuseIdentifier;
@end

@implementation FHStaticMapAnnotationView

- (instancetype)initWithAnnotation:(FHStaticMapAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.annotation = annotation;
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}
@end

@interface FHStaticMapTransformer : BDBaseTransformer
@property(nonatomic, assign) CGFloat targetWidth;
@property(nonatomic, assign) CGFloat targetHeight;
@property(nonatomic, strong) NSString *cacheKey;
@property(nonatomic, strong) NSError *error;
@end

@implementation FHStaticMapTransformer
- (instancetype)initWithTargetWidth:(CGFloat)targetWidth targetHeight:(CGFloat)targetHeight cacheKey:(NSString *)cacheKey {
    self = [super init];
    if (self) {
        self.targetWidth = targetWidth;
        self.targetHeight = targetHeight;
        self.cacheKey = cacheKey;
    }
    return self;
}

- (nonnull NSString *)appendingStringForCacheKey {
    return self.cacheKey;
}

- (nullable UIImage *)transformImageBeforeStoreWithImage:(nullable UIImage *)image {
    NSUInteger widthPixel = (NSUInteger) (image.size.width * image.scale);
    NSUInteger heightPixel = (NSUInteger) (image.size.height * image.scale);
    NSUInteger expectedHeight = (NSUInteger) round(widthPixel * self.targetHeight / self.targetWidth);
    if (expectedHeight != heightPixel) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"bad_picture[width:%tu,height:%tu]", widthPixel, heightPixel]};
        self.error = [NSError errorWithDomain:@"transformer" code:1 userInfo:userInfo];
        return nil;
    }

    //居中裁剪
    if (self.targetWidth < widthPixel && self.targetHeight < heightPixel) {
        CGFloat hOffset = round((widthPixel - self.targetWidth) * 0.5f);
        CGFloat vOffset = round((heightPixel - self.targetHeight) * 0.5f);
        CGRect targetRect = CGRectMake(hOffset, vOffset, round(self.targetWidth), round(self.targetHeight));
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], targetRect);
        UIImage *targetImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return targetImage;
    }
    return image;
}
@end

@interface FHDetailStaticMap ()
@property(nonatomic, strong) UIImageView *backLayerImageView;
@property(nonatomic, strong) UIView *markerLayerView;
@property(nonatomic, strong) NSMutableArray<FHStaticMapAnnotation *> *annotations;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<FHStaticMapAnnotationView *> *> *pool;


@property(nonatomic, assign) BOOL loaded;
@property(nonatomic, strong) NSString *backLayerUrl;
@property(nonatomic, assign) CGFloat bitmapScaleRatio;
@property(nonatomic, assign) CGFloat latRatio;
@property(nonatomic, assign) CGFloat lngRatio;
@property(nonatomic, assign) CLLocationCoordinate2D centerPoint;
@end


@implementation FHDetailStaticMap

+ (instancetype)mapWithFrame:(CGRect)frame; {
    return [[FHDetailStaticMap alloc] initWithFrame:frame];
}

- (void)loadMap:(NSString *)url center:(CLLocationCoordinate2D)center latRatio:(CGFloat)latRatio lngRatio:(CGFloat)lngRatio {
    self.backLayerUrl = url;
    self.centerPoint = center;
    self.latRatio = latRatio;
    self.lngRatio = lngRatio;
    self.loaded = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionChanged:)
                                                 name:TTReachabilityChangedNotification
                                               object:nil];
    [self loadBackLayerImage];
}

- (void)addAnnotations:(NSArray<FHStaticMapAnnotation *> *)annotations {
    [self.annotations addObjectsFromArray:annotations];
    if (self.loaded) {
        [self loadAnnotations:annotations];
    }
}

- (void)removeAnnotations:(NSArray<FHStaticMapAnnotation *> *)annotations {
    [self.annotations removeObjectsInArray:annotations];
    FHStaticMapAnnotationView *annotationView = nil;
    for (FHStaticMapAnnotation *annotation in annotations) {
        annotationView = annotation.annotationView;
        if (!annotationView || isEmptyString(annotationView.reuseIdentifier)) {
            [annotation.annotationView removeFromSuperview];
            continue;
        }
        NSMutableArray<FHStaticMapAnnotationView *> *poolForIdentifier = self.pool[annotationView.reuseIdentifier];
        if (!poolForIdentifier) {
            poolForIdentifier = [NSMutableArray array];
            self.pool[annotationView.reuseIdentifier] = poolForIdentifier;
        }
        [poolForIdentifier addObject:annotationView];
        annotationView.annotation = nil;
        [annotationView removeFromSuperview];
    }
}

- (void)removeAllAnnotations {
    [self removeAnnotations:[self.annotations copy]];
}

- (FHStaticMapAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier {
    if (isEmptyString(identifier)) {
        return nil;
    }
    NSMutableArray<FHStaticMapAnnotationView *> *poolForIdentifier = self.pool[identifier];
    if (poolForIdentifier.count > 0) {
        FHStaticMapAnnotationView *firstObject = [poolForIdentifier firstObject];
        [poolForIdentifier removeObject:firstObject];
        return firstObject;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.annotations = [NSMutableArray array];
        self.pool = [NSMutableDictionary dictionary];
        [self initViews];
    }
    return self;
}

- (void)initViews {
    _backLayerImageView = [[UIImageView alloc] init];
    _markerLayerView.layer.masksToBounds = YES;
    _markerLayerView = [[UIView alloc] init];
    _markerLayerView.layer.masksToBounds = YES;

    [self addSubview:_backLayerImageView];
    [self addSubview:_markerLayerView];
    _backLayerImageView.frame = self.bounds;
    _markerLayerView.frame = self.bounds;
}

- (void)loadBackLayerImage {
    if (self.loaded) {
        return;
    }
    NSURL *URL = [NSURL URLWithString:self.backLayerUrl];

    CGFloat scale = SCREEN_SCALE;
    CGFloat myWidth = CGRectGetWidth(self.bounds) * scale;
    CGFloat myHeight = CGRectGetHeight(self.bounds) * scale;
    NSString *cacheKey = [NSString stringWithFormat:@"%@[%.2fx%.2f]", self.backLayerUrl, myWidth, myHeight];
    FHStaticMapTransformer *transformer = [[FHStaticMapTransformer alloc] initWithTargetWidth:myWidth targetHeight:myHeight cacheKey:cacheKey];

    WeakSelf;
    id block = ^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        StrongSelf;
        BOOL success = !error;
        self.loaded = success;
        if (success) {
            self.bitmapScaleRatio = image.size.width < myWidth ? 1.0f : myWidth / image.size.width;
            [self loadAnnotations:self.annotations];
        }

        if (self.delegate) {
            if (success) {
                [self.delegate mapView:self loadFinished:YES message:@"ok"];
            } else {
                //普通的下载错误不算是加载失败，不回调
                if (transformer.error) {
                    NSString *message = transformer.error.userInfo[NSLocalizedDescriptionKey];
                    [self.delegate mapView:self loadFinished:NO message:message];
                }
            }
        }
    };

    [self.backLayerImageView bd_setImageWithURL:URL
                                    placeholder:[UIImage imageNamed:@"static_map_empty"]
                                        options:BDImageRequestIgnoreCache
                                    transformer:transformer
                                       progress:nil
                                     completion:block];
}

- (void)loadAnnotations:(NSArray<FHStaticMapAnnotation *> *)annotations {
    NSArray<FHStaticMapAnnotation *> *annotationsCopy = [annotations copy];
    FHStaticMapAnnotationView *annotationView;
    for (FHStaticMapAnnotation *annotation in annotationsCopy) {
        if (self.delegate) {
            annotationView = [self.delegate mapView:self viewForStaticMapAnnotation:annotation];
            annotation.annotationView = annotationView;
            annotationView.annotation = annotation;
            [self calculatePosition:annotationView];
            [self.markerLayerView addSubview:annotationView];
        }
    }
}

- (void)calculatePosition:(FHStaticMapAnnotationView *)annotationView {
    if (!annotationView) {
        return;
    }
    CLLocationCoordinate2D location = annotationView.annotation.coordinate;

    CGFloat dx = round(((location.longitude - self.centerPoint.longitude) * self.lngRatio * self.bitmapScaleRatio) / SCREEN_SCALE);
    CGFloat dy = round(((location.latitude - self.centerPoint.latitude) * self.latRatio * self.bitmapScaleRatio) / SCREEN_SCALE);

    CGFloat centerX = round(CGRectGetWidth(self.markerLayerView.frame) * 0.5);
    CGFloat centerY = round(CGRectGetHeight(self.markerLayerView.frame) * 0.5);

    CGFloat offsetX = -annotationView.annotationSize.width * 0.5 + annotationView.centerOffset.x;
    CGFloat offsetY = -annotationView.annotationSize.height * 0.5 + annotationView.centerOffset.y;

    CGFloat left = centerX + offsetX + dx;
    CGFloat top = centerY + offsetY - dy;

    annotationView.frame = CGRectMake(left, top, CGRectGetWidth(annotationView.frame), CGRectGetHeight(annotationView.frame));
}

- (void)connectionChanged:(NSNotification *)notification {
    if (![TTReachability isNetworkConnected]) {
        return;
    }
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongSelf;
        if (!self.loaded) {
            return;
        }
        [self loadBackLayerImage];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
