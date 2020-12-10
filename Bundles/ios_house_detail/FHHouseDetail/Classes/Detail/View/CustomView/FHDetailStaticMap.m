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

// 兼容之前的版本
//NSNotificationName kReachabilityChangedNotification = @"TTReachabilityChangedNotification";
const CGFloat kStaticMapHWRatio  = 7.0f / 16.0f;

@interface FHStaticMapAnnotation ()
@property(nonatomic, weak) FHStaticMapAnnotationView *annotationView;
@end

@implementation FHStaticMapAnnotation

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end

@interface FHStaticMapAnnotationView ()
@property(nonatomic, strong) FHStaticMapAnnotation *annotation;
@property(nonatomic, copy) NSString *reuseIdentifier;
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
@property(atomic, strong) NSError *error;
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
    NSUInteger expectedHeight = (NSUInteger) (widthPixel * kStaticMapHWRatio);
    if (expectedHeight != heightPixel) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"bad_picture[imageSize:%@,imageSacle:%f,targetSize:%@]", NSStringFromCGSize(image.size),image.scale,NSStringFromCGSize(CGSizeMake(self.targetWidth, self.targetHeight))]};
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

+ (NSString *)keyWordConver:(NSString *)category{
    if([category isEqualToString:@"交通"]){
        return @"公交地铁";
    }else if([category isEqualToString:@"教育"]){
        return @"学校";
    }else if([category isEqualToString:@"医疗"]){
        return @"医院";
    }else if([category isEqualToString:@"生活"]){
        return @"购物|银行";
    }else if([category isEqualToString:@"休闲"]){
        return @"电影院|咖啡厅|影剧院";
    }else{
        return @"公交地铁";
    }
}

+ (NSString *)keyWordConverReverse:(NSString *)category{
    if([category isEqualToString:@"公交地铁"]){
        return @"交通";
    }else if([category isEqualToString:@"学校"]){
        return @"教育";
    }else if([category isEqualToString:@"医院"]){
        return @"医疗";
    }else if([category isEqualToString:@"购物|银行"]){
        return @"生活";
    }else if([category isEqualToString:@"电影院|咖啡厅|影剧院"]){
        return @"休闲";
    }else{
        return @"交通";
    }
}

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
        //如果是网络错误，直接返回，网络重连后会重试，但是不回调加载失败
        if(error && !transformer.error){
            self.loaded = NO;
            return;
        }
        
        if(transformer.error || image.size.width <= 0.0f || myWidth <= 0.0f){
            self.loaded = NO;
            NSString *message = transformer.error.userInfo[NSLocalizedDescriptionKey];
            if(self.delegate){
                [self.delegate mapView:self loadFinished:NO message:message];
            }
            return;
        }
        
        self.bitmapScaleRatio = myWidth / image.size.width;
        self.loaded = YES;
        [self loadAnnotations:self.annotations];
        if(self.delegate){
            [self.delegate mapView:self loadFinished:YES message:@"ok"];
        }
    };

    [self.backLayerImageView bd_setImageWithURL:URL
                                    placeholder:[UIImage imageNamed:@"static_map_empty"]
                                        options:BDImageRequestDefaultOptions
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
        [self loadBackLayerImage];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
