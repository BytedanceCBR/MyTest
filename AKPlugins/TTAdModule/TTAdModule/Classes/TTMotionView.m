//
//  TTMotionView.m
//  Article
//
//  Created by yin on 2017/1/22.
//
//

#import "TTMotionView.h"
#import "TTThemeManager.h"
#import "MJRefreshConst.h"
#import "CADisplayLink+TTBlockSupport.h"
#import "KVOController.h"

#define isLandscape UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])

@import CoreMotion;

static const CGFloat CRMotionViewRotationMinimumTreshold = 0.1f;
static const CGFloat CRMotionGyroUpdateInterval = 1 / 100;
static const CGFloat CRMotionViewRotationFactor = 3.0f;

static const CGFloat kGyroTipViewWidth = 30.0f;
static const CGFloat kGyroTipViewHeight = 30.0f;
static const CGFloat kGyroTipViewMargin = 8.0f;
static const CGFloat kRefreshThreshold = 20.0f;

@interface TTMotionView () <UIScrollViewDelegate>

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UIImageView  *fullViewGuideView;
@property (nonatomic, assign) CGFloat motionXRate;
@property (nonatomic, assign) CGFloat motionYRate;
@property (nonatomic, assign) NSInteger minimumXOffset;
@property (nonatomic, assign) NSInteger maximumXOffset;
@property (nonatomic, assign) NSInteger minimumYOffset;
@property (nonatomic, assign) NSInteger maximumYOffset;

@property (nonatomic, strong) UIView *gyroTipView;
@property (nonatomic, strong) CAShapeLayer *triangelLayer; //陀螺仪上的小三角
@property (nonatomic, assign) BOOL isShowing;

@end

@implementation TTMotionView

- (void)setIsShowGyroTipView:(BOOL)isShowGyroTipView
{
    if (_isShowGyroTipView == isShowGyroTipView) {
        return;
    }
    _isShowGyroTipView = isShowGyroTipView;
    if (isShowGyroTipView) {
        self.gyroTipView.hidden = NO;
        self.triangelLayer.hidden = NO;
    } else {
        self.gyroTipView.hidden = YES;
        self.triangelLayer.hidden = YES;
    }
}

- (void)setTableView:(UITableView *)tableView {
    if (!tableView || _tableView == tableView) {
        return;
    }
    
    _tableView = tableView;
    __weak typeof(self) wself = self;
    [self.KVOController observe:_tableView keyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        [self didScroll:self.tableView];
    }];
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (instancetype)init
{
    return [self initWithType:TTMotionViewTypeImmersion];
}

- (instancetype)initWithType:(TTMotionViewType)type
{
    self = [super init];
    if (self) {
        _minimumXOffset = 0;
        self.motionEnabled = YES;
        _scrollBounceEnabled = NO;
        _type = type;
        [self createDisplayLink];
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    [self.scrollView setScrollEnabled:NO];
    [self.scrollView setBounces:NO];
    [self.scrollView setContentSize:CGSizeZero];
    [self.scrollView setExclusiveTouch:YES];
    self.scrollView.userInteractionEnabled = NO; // 不然点击事件会被scrollView吃掉。。。
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setClipsToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    self.fullViewGuideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ad_fullview_guide"]];
    self.fullViewGuideView.frame = CGRectMake(0, 0, 44, 44);
    self.fullViewGuideView.hidden = YES;
    self.fullViewGuideView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.fullViewGuideView];
    
    [self updateBackgroundColor];
}

- (void)createDisplayLink
{
    WeakSelf;
    self.displayLink = [CADisplayLink ttDisplayLinkWithBlock:^{
        StrongSelf;
        [self updateMonitoring];
    }];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.displayLink setPaused:YES];
}

- (void)updateMonitoring
{
    if (self.motionManager && [self.motionManager isGyroActive] && [self.motionManager isGyroAvailable]) {
        
        CMGyroData * gyroData  = self.motionManager.gyroData;
        CGFloat rotationXRate = isLandscape ? gyroData.rotationRate.x : gyroData.rotationRate.y;
        CGFloat rotationYRate = isLandscape ? gyroData.rotationRate.y : gyroData.rotationRate.x;
        
        CGFloat offsetX = 0, offsetY = 0;
        if (fabs(rotationXRate) >= CRMotionViewRotationMinimumTreshold) {
            offsetX = self.scrollView.contentOffset.x - rotationXRate * self.motionXRate;
            if (offsetX > self.maximumXOffset) {
                offsetX = self.maximumXOffset;
            } else if (offsetX < self.minimumXOffset) {
                offsetX = self.minimumXOffset;
            }
        }
        
        if (fabs(rotationYRate) >= CRMotionViewRotationMinimumTreshold) {
            offsetY = self.scrollView.contentOffset.y - rotationYRate * self.motionYRate;
            if (offsetY > self.maximumYOffset) {
                offsetY = self.maximumYOffset;
            } else if (offsetY < self.minimumXOffset) {
                offsetY = self.minimumYOffset;
            }
        }
        
        if (offsetX || offsetY) {
            if (!offsetX) {
                offsetX = self.scrollView.contentOffset.x;
            } else {
            }
            if (!offsetY) {
                offsetY = self.scrollView.contentOffset.y;
            }
            
            if (self.type == TTMotionViewTypeFullView && self.isShowGyroTipView) {
                // 陀螺仪动画
                CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                pathAnimation.duration = 0.3;//设置绘制动画持续的时间
                pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                pathAnimation.fromValue = [NSNumber numberWithFloat: - M_PI/2  + M_PI * self.scrollView.contentOffset.x / self.maximumXOffset];
                pathAnimation.toValue = [NSNumber numberWithFloat: - M_PI/2 + M_PI * offsetX / self.maximumXOffset];
                pathAnimation.autoreverses = NO;//是否翻转绘制
                pathAnimation.fillMode = kCAFillModeForwards;
                pathAnimation.repeatCount = 1;
                pathAnimation.removedOnCompletion = NO;
                [self.gyroTipView.layer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
            } else if (self.type == TTMotionViewTypeImmersion) {
                offsetY = 0;
            }
            
            WeakSelf;
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 StrongSelf;
                                 
                                 [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:NO];
                                 
                             }
                             completion:nil];
        }
    }
}

#pragma mark - Core Motion

- (void)startMonitoring
{
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.gyroUpdateInterval = CRMotionGyroUpdateInterval;
    }
    
    if (![self.motionManager isGyroActive] && [self.motionManager isGyroAvailable] ) {
        [self.motionManager startGyroUpdates];
        if (self.displayLink) {
            [self.displayLink setPaused:NO];
        }
    }
    
}

- (void)stopMonitoring
{
    [self.motionManager stopGyroUpdates];
    if (self.displayLink) {
        [self.displayLink setPaused:YES];
    }
}

- (void)layoutSubviews
{
    self.scrollView.frame = self.bounds;
    
    if (self.type == TTMotionViewTypeImmersion) {
        if (self.imageView.bounds.size.height > 0) {
            CGFloat width = self.imageView.bounds.size.width *((CGFloat)self.bounds.size.height/self.imageView.bounds.size.height);
            CGRect frame = CGRectMake(0, 0, width, self.bounds.size.height);
            self.imageView.frame = frame;
        }
        
    } else if (self.type == TTMotionViewTypeFullView) {
        if (self.imageView.bounds.size.height > 0 && self.imageView.bounds.size.height < self.bounds.size.height) {
            CGFloat width = self.imageView.bounds.size.width *((CGFloat)self.bounds.size.height/self.imageView.bounds.size.height);
            CGRect frame = CGRectMake(0, 0, width, self.bounds.size.height);
            self.imageView.frame = frame;
        }
        if (!self.gyroTipView) {
            [self initGyroTipView];
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.imageView.bounds.size.width, self.imageView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake((self.scrollView.contentSize.width - self.scrollView.frame.size.width) / 2, (self.scrollView.contentSize.height - self.scrollView.frame.size.height) / 2);
    
    self.motionXRate = (self.imageView.bounds.size.width / self.bounds.size.width) * CRMotionViewRotationFactor;
    self.maximumXOffset = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    self.motionYRate = (self.imageView.bounds.size.height / self.bounds.size.height) * CRMotionViewRotationFactor;
    self.maximumYOffset = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    // 陀螺仪的位置
    self.gyroTipView.frame = CGRectMake(self.bounds.size.width - kGyroTipViewWidth - kGyroTipViewMargin, self.bounds.size.height - kGyroTipViewHeight - kGyroTipViewMargin, kGyroTipViewWidth, kGyroTipViewHeight);
//    [self drawTriangle];
    
}

#pragma mark - fullview guide

- (void)fullviewGuide
{
    self.fullViewGuideView.hidden = NO;
    self.fullViewGuideView.center = CGPointMake(self.center.x, self.center.y);
    self.isShowGyroTipView = NO;
    
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StrongSelf;
        [self showFullviewGuide];
    });
}

- (void)showFullviewGuide
{
    self.gyroTipView.alpha = 0;
    self.triangelLayer.hidden = YES;
    
    WeakSelf;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         StrongSelf;
                         self.fullViewGuideView.alpha = 0;
                         self.gyroTipView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         StrongSelf;
                         self.fullViewGuideView.hidden = YES;
                         self.fullViewGuideView.alpha = 1;
                         self.isShowGyroTipView = YES;
                         self.triangelLayer.hidden = NO;
                     }];
    
}

#pragma mark - gyroTip
//  初始化陀螺仪
- (void)initGyroTipView
{
    self.gyroTipView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - kGyroTipViewWidth - kGyroTipViewMargin, self.bounds.size.height - kGyroTipViewHeight - kGyroTipViewMargin, kGyroTipViewWidth, kGyroTipViewHeight)];
    self.gyroTipView.hidden = YES;
    self.gyroTipView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    self.gyroTipView.clipsToBounds = YES;
    [self addSubview:self.gyroTipView];
    
    // 圆形背景mask
    CGMutablePathRef cieclePathRef = CGPathCreateMutable();
    CGPathAddArc(cieclePathRef, &CGAffineTransformIdentity,
                 CGRectGetWidth(self.gyroTipView.frame)/2, CGRectGetHeight(self.gyroTipView.frame)/2, kGyroTipViewWidth / 2, 0, M_PI * 2, NO);
    CAShapeLayer *circleLine;
    circleLine.path = cieclePathRef;
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    // Set the path to the mask layer.
    maskLayer.path = cieclePathRef;
    // Set the mask of the view.
    self.gyroTipView.layer.mask = maskLayer;
    CGPathRelease(cieclePathRef);
    
    // 外侧的园
    [self drawCircleWithR:11 width:1];
    // 圆心
    [self drawCircleWithR:0.75 width:1.5];
    
    // 扇形
    CAShapeLayer *circleShape;
    circleShape = [CAShapeLayer layer];
    circleShape.lineWidth = 5.5;//这里设置填充线的宽度，这个参数很重要
    circleShape.lineCap = kCALineCapButt;//设置线端点样式，这个也是非常重要的一个参数
    circleShape.strokeColor = [[UIColor colorWithWhite:1 alpha:0.6] CGColor];//绘制的线的颜色
    circleShape.fillColor = nil;
    
    [self.gyroTipView.layer addSublayer:circleShape];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddArc(pathRef, &CGAffineTransformIdentity,
                 CGRectGetWidth(self.gyroTipView.frame)/2, CGRectGetHeight(self.gyroTipView.frame)/2, 6.25, -M_PI/5 - M_PI/2, M_PI/5 - M_PI/2, NO);
    circleShape.path = pathRef;
    CGPathRelease(pathRef);
    
    // 小三角
    [self drawTriangle];
}

// 画圆的辅助方法
- (void)drawCircleWithR:(CGFloat)r width:(CGFloat)w
{
    CAShapeLayer *chartLine = [CAShapeLayer layer];
    chartLine.lineWidth = w;//这里设置填充线的宽度，这个参数很重要
    chartLine.lineCap = kCALineCapButt;//设置线端点样式，这个也是非常重要的一个参数
    chartLine.strokeColor = [[UIColor colorWithWhite:1 alpha:0.6] CGColor];//绘制的线的颜色
    chartLine.fillColor = nil;
    
    [self.gyroTipView.layer addSublayer:chartLine];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddArc(pathRef, &CGAffineTransformIdentity,
                 CGRectGetWidth(self.gyroTipView.frame)/2, CGRectGetHeight(self.gyroTipView.frame)/2, r, 0, M_PI * 2, NO);
    chartLine.path = pathRef;
    CGPathRelease(pathRef);
}

- (void)drawTriangle
{
    CGPoint point1 = CGPointMake(self.bounds.size.width - kGyroTipViewWidth/2 - kGyroTipViewMargin, self.bounds.size.height - kGyroTipViewHeight - kGyroTipViewMargin + 2);
    CGPoint point2 = CGPointMake(self.bounds.size.width - kGyroTipViewWidth/2 - kGyroTipViewMargin - 2, self.bounds.size.height - kGyroTipViewHeight - kGyroTipViewMargin + 4);
    CGPoint point3 = CGPointMake(self.bounds.size.width - kGyroTipViewWidth/2 - kGyroTipViewMargin + 2, self.bounds.size.height - kGyroTipViewHeight - kGyroTipViewMargin + 4);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path closePath];
    
    self.triangelLayer = [CAShapeLayer layer];
    self.triangelLayer.path = path.CGPath;
    self.triangelLayer.hidden = YES;
    self.triangelLayer.fillColor = [[UIColor colorWithWhite:1 alpha:0.6] CGColor];//绘制的线的颜色
    [self.layer addSublayer:self.triangelLayer];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
}

- (void)setImage:(UIImage *)image
{
    BOOL firstTimeSet = self.imageView.image ? NO : YES;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, image.size.width / 2, image.size.height / 2);
    if (self.type == TTMotionViewTypeFullView) {  // 全景提示逻辑
        // 如果不在可视范围内不刷新
        if (firstTimeSet) {
            [self fullviewGuide];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setMotionEnabled:(BOOL)motionEnabled
{
    if (motionEnabled != _motionEnabled) {
        _motionEnabled = motionEnabled;
        if (self.motionEnabled) {
            [self startMonitoring];
        } else {
            [self stopMonitoring];
        }
    }
}

- (void)setScrollIndicatorEnabled:(BOOL)scrollIndicatorEnabled
{
    _scrollIndicatorEnabled = scrollIndicatorEnabled;
}


- (void)setScrollBounceEnabled:(BOOL)scrollBounceEnabled
{
    _scrollBounceEnabled = scrollBounceEnabled;
    
    [self.scrollView setBounces:scrollBounceEnabled];
}

- (void)resetContentOffset
{
    self.scrollView.contentOffset = CGPointMake((self.scrollView.contentSize.width - self.scrollView.frame.size.width) / 2, (self.scrollView.contentSize.height - self.scrollView.frame.size.height) / 2);
}

- (void)willDisplaying
{
    
}

- (void)didEndDisplaying
{
    [self setMotionEnabled:NO];
}

- (void)resumeDisplay
{
    [self fullviewGuide];
}

- (void)didScroll:(UIScrollView *)scrollView
{
    CGRect rect = [self convertRect:self.frame toView:scrollView];
    CGRect interRect = CGRectIntersection(rect, scrollView.bounds);
    
    if (scrollView.contentOffset.y <= -MJRefreshHeaderHeight && _isShowing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateIsShowingForRefresh) object:nil];
        [self performSelector:@selector(updateIsShowingForRefresh) withObject:nil afterDelay:0.25];
    }
    
    if (interRect.size.height > self.frame.size.height / 2 && !_isShowing) {
        [self fullviewGuide];
        _isShowing = YES;
    } else if (!interRect.size.height){
        _isShowing = NO;
    }
}

- (void)updateIsShowingForRefresh
{
    _isShowing = NO;
}

#pragma mark - Themed Change

- (void)themeChanged:(NSNotification *)notification
{
    [self updateBackgroundColor];
}

- (void)updateBackgroundColor
{
    if ((self.type == TTMotionViewTypeImmersion)) {
        return;
    }
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    
    if (!isDayModel) {
        self.alpha = 0.5f;
    } else {
        self.alpha = 1.0f;
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(motionViewScrollViewDidScrollToOffset:)]) {
        [self.delegate motionViewScrollViewDidScrollToOffset:self.scrollView.contentOffset];
    }
}
@end

