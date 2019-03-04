//
//  TTPanorama3DView.m
//  TTAdModule
//
//  Created by rongyingjie on 2017/11/7.
//
//  https://github.com/robbykraft/Panorama.git
//  整个类使用的上面的开源库，修改了旋转的方式，删除了里面多余的旋转逻辑
//

//
//  PanoramaView.m
//  Panorama
//
//  Created by Robby Kraft on 8/24/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <OpenGLES/ES1/gl.h>
#import "TTPanorama3DView.h"
#import "TTThemeManager.h"
#import "MJRefreshConst.h"
#import "CADisplayLink+TTBlockSupport.h"
#import "KVOController.h"

#define FPS 60
#define FOV_MIN 1
#define FOV_MAX 155
#define Z_NEAR 0.1f
#define Z_FAR 100.0f

// LINEAR for smoothing, NEAREST for pixelized
#define IMAGE_SCALING GL_LINEAR  // GL_NEAREST, GL_LINEAR

// this appears to be the best way to grab orientation. if this becomes formalized, just make sure the orientations match
#define SENSOR_ORIENTATION [[UIApplication sharedApplication] statusBarOrientation] //enum  1(NORTH)  2(SOUTH)  3(EAST)  4(WEST)
static const CGFloat CRMotionViewRotationMinimumTreshold = 0.1f;
static const CGFloat kRecognizePanMinimumTreshold = 100.0f;

static const CGFloat kGyroTipViewWidth = 30.0f;
static const CGFloat kGyroTipViewHeight = 30.0f;
static const CGFloat kGyroTipViewMargin = 8.0f;
static const CGFloat kRefreshThreshold = 20.0f;

@interface Sphere : NSObject

-(bool) execute;
-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius textureFile:(NSString *)textureFile;
-(void) swapTexture:(NSString*)textureFile;
-(BOOL) swapTextureWithImage:(UIImage*)image;
-(CGSize) getTextureSize;

@end

@interface TTPanorama3DView (){
    Sphere *sphere, *meridians;
    CMMotionManager *motionManager;
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *panGesture;
    GLKMatrix4 _projectionMatrix, _attitudeMatrix, _offsetMatrix;
    float _aspectRatio;
    float x_radius;
    float y_radius;
    CMAttitude *currentAttitude;
    GLfloat circlePoints[64*3];  // meridian lines
    BOOL isShowing;
}

@property (nonatomic, strong) UIView *gyroTipView;
@property (nonatomic, strong) CAShapeLayer *triangelLayer; //陀螺仪上的小三角
@property (nonatomic, strong) UIImageView  *fullViewGuideView;

@end

@implementation TTPanorama3DView

- (id)initWithFrame:(CGRect)frame{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    // GLKViewDelegate自己来控制刷新逻辑
    self.delegate = self;
    [self registNotification];
    [self createDisplayLink];

    return [self initWithFrame:frame context:context];
}

- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

-(id) initWithFrame:(CGRect)frame context:(EAGLContext *)context{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDevice];
        [self initOpenGL:context];
        sphere = [[Sphere alloc] init:48 slices:48 radius:10.0 textureFile:nil];
        x_radius = y_radius = 0.0f;
        
        [self initGyroTipView];
        self.fullViewGuideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ad_3D_guide"]];
        self.fullViewGuideView.frame = CGRectMake(0, 0, 44, 44);
        self.fullViewGuideView.hidden = YES;
        self.fullViewGuideView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.fullViewGuideView];
    }
    return self;
}

- (void)createDisplayLink {
    __weak typeof(self) wself = self;
    self.displayLink = [CADisplayLink ttDisplayLinkWithBlock:^{
        __strong typeof(wself) self = wself;
        [self display];
    }];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.displayLink setPaused:NO];
}

-(void) initDevice{
    motionManager = [[CMMotionManager alloc] init];
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    [pinchGesture setEnabled:NO];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setEnabled:NO];
    panGesture.delegate = self;
    self.multipleTouchEnabled = YES;
    [self addGestureRecognizer:panGesture];
}

#pragma mark- GLKViewDelegate
-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self draw];
}

#pragma mark- gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
        [otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)otherGestureRecognizer velocityInView:otherGestureRecognizer.view];
        if (fabs(velocity.y) > kRecognizePanMinimumTreshold) {
            gestureRecognizer.enabled = NO;
            gestureRecognizer.enabled = YES;
            return YES;
        }
    } else if([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
              [otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        // 如果识别出UICollectionView的横滑将事件禁掉
        otherGestureRecognizer.enabled = NO;
        otherGestureRecognizer.enabled = YES;
    }
    return NO;
}

-(void)appWillResignActive:(NSNotification*)note {
    [self setOrientToDevice:NO];
    [self.displayLink setPaused:YES];
}

-(void)appWillBecomeActive:(NSNotification*)note {
    [self setOrientToDevice:YES];
    [self.displayLink setPaused:NO];
}

#pragma mark- setters

- (void)setTableView:(UIScrollView *)tableView {
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

-(void)setFieldOfView:(float)fieldOfView{
    _fieldOfView = fieldOfView;
    [self rebuildProjectionMatrix];
}
-(void) setImageWithName:(NSString*)fileName{
    [sphere swapTexture:fileName];
}
-(void) setImage:(UIImage *)image {
    if ([sphere swapTextureWithImage:image]) {
        _image = image;
        [self fullviewGuide];
    }
}
-(void) setTouchToPan:(BOOL)touchToPan{
    _touchToPan = touchToPan;
    [panGesture setEnabled:_touchToPan];
}
-(void) setPinchToZoom:(BOOL)pinchToZoom{
    _pinchToZoom = pinchToZoom;
    [pinchGesture setEnabled:_pinchToZoom];
}
-(void) setOrientToDevice:(BOOL)orientToDevice{
    _orientToDevice = orientToDevice;
    if(motionManager.isDeviceMotionAvailable){
        if(_orientToDevice) {
            [motionManager startGyroUpdates];
        } else {
            [motionManager stopGyroUpdates];
        }
    }
}

- (void)setIsShowGyroTipView:(BOOL)isShowGyroTipView
{
    _isShowGyroTipView = isShowGyroTipView;
    if (isShowGyroTipView) {
        self.gyroTipView.hidden = NO;
        self.triangelLayer.hidden = NO;
    } else {
        self.gyroTipView.hidden = YES;
        self.triangelLayer.hidden = YES;
    }
}

#pragma mark- OPENGL
-(void)initOpenGL:(EAGLContext*)context{
    [(CAEAGLLayer*)self.layer setOpaque:NO];
    _aspectRatio = self.frame.size.width/self.frame.size.height;
    _fieldOfView = 45 + 45 * atanf(_aspectRatio); // hell ya
    [self rebuildProjectionMatrix];
    _attitudeMatrix = GLKMatrix4Identity;
    _offsetMatrix = GLKMatrix4Identity;
    [self customGL];
    [self makeLatitudeLines];
}
-(void)rebuildProjectionMatrix{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = Z_NEAR * tanf(_fieldOfView*0.00872664625997);  // pi/180/2
    _projectionMatrix = GLKMatrix4MakeFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    glMultMatrixf(_projectionMatrix.m);
    glMatrixMode(GL_MODELVIEW);
}
-(void) customGL{
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}
-(void)draw{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self renderScene];
}

-(void) renderScene{
    static GLfloat whiteColor[] = {1.0f, 1.0f, 1.0f, 1.0f};
    static GLfloat clearColor[] = {0.0f, 0.0f, 0.0f, 0.0f};
    glPushMatrix(); // begin device orientation
    
    CMGyroData *gyroData = motionManager.gyroData;
    CGFloat rotationXRate = [[UIDevice currentDevice] orientation] ? gyroData.rotationRate.x : gyroData.rotationRate.y;
    CGFloat rotationYRate = [[UIDevice currentDevice] orientation] ? gyroData.rotationRate.y : gyroData.rotationRate.x;
    
    if (_numberOfTouches && ![self touchInRect:self.frame]) {
        //修正一下，有一定概率会出现touchend没有执行的情况
        _numberOfTouches = 0;
    }
    
    if (fabs(rotationXRate) >= CRMotionViewRotationMinimumTreshold) {
        if (!_numberOfTouches) {
            y_radius = y_radius - rotationXRate * 1;
        }
        if (y_radius > 90) {
            y_radius = 90;
        } else if (y_radius < -90) {
            y_radius = -90;
        }
    }
    
    if (fabs(rotationYRate) >= CRMotionViewRotationMinimumTreshold) {
        if (!_numberOfTouches) {
            x_radius = x_radius - rotationYRate * 1;
        }
        if (x_radius > 360) {
            x_radius -= 360;
        } else if (x_radius < -360) {
            x_radius += 360;
        }
    }
    
    glRotatef(y_radius, 1, 0, 0);
    glRotatef(x_radius, 0, 1, 0);
    
    //    GLKMatrix4Identity
    glMultMatrixf(GLKMatrix4Identity.m);
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, whiteColor);  // panorama at full color
    [sphere execute];
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, clearColor);
    
    //TODO: add any objects here to make them a part of the virtual reality
    //        glPushMatrix();
    //            // object code
    //        glPopMatrix();
    
    glPopMatrix(); // end device orientation
    
    if (self.isShowGyroTipView) {
        // 陀螺仪动画
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        pathAnimation.duration = 0.3;//设置绘制动画持续的时间
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pathAnimation.fromValue = [NSNumber numberWithFloat: M_PI *(x_radius + rotationYRate * 1) / 180];
        pathAnimation.toValue   = [NSNumber numberWithFloat:  M_PI * x_radius / 180];
        pathAnimation.autoreverses = NO;//是否翻转绘制
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.repeatCount = 1;
        pathAnimation.removedOnCompletion = NO;
        [self.gyroTipView.layer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    }
}

#pragma mark- TOUCHES
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _touches = event.allTouches;
    _numberOfTouches = event.allTouches.count;
    //将事件往下传递，不然tableview无法接受到点击事件
    [self.nextResponder touchesBegan:touches withEvent:event];
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    _touches = event.allTouches;
    _numberOfTouches = event.allTouches.count;
    [self.nextResponder touchesMoved:touches withEvent:event];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _touches = event.allTouches;
    _numberOfTouches = 0;
    [self.nextResponder touchesEnded:touches withEvent:event];
}
-(BOOL)touchInRect:(CGRect)rect{
    if(_numberOfTouches){
        bool found = false;
        for(int i = 0; i < [[_touches allObjects] count]; i++){
            CGPoint touchPoint = CGPointMake([(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].x,
                                             [(UITouch*)[[_touches allObjects] objectAtIndex:i] locationInView:self].y);
            CGRect rectToWindow = [self convertRect:rect toView:[[[UIApplication sharedApplication] delegate] window]];
            CGPoint pointToWindow = [self convertPoint:touchPoint toView:[[[UIApplication sharedApplication] delegate] window]];
            found |= CGRectContainsPoint(rectToWindow, pointToWindow);
        }
        return found;
    }
    return false;
}
-(void)pinchHandler:(UIPinchGestureRecognizer*)sender{
    _numberOfTouches = sender.numberOfTouches;
    static float zoom;
    if([sender state] == 1)
        zoom = _fieldOfView;
    if([sender state] == 2){
        CGFloat newFOV = zoom / [sender scale];
        if(newFOV < FOV_MIN) newFOV = FOV_MIN;
        else if(newFOV > FOV_MAX) newFOV = FOV_MAX;
        [self setFieldOfView:newFOV];
    }
    if([sender state] == 3){
        _numberOfTouches = 0;
    }
}
-(void) panHandler:(UIPanGestureRecognizer*)sender{
    static CGPoint touchPoint;
    if([sender state] == 1){
        CGPoint location = [sender locationInView:sender.view];
        touchPoint = location;
    }
    else if([sender state] == 2){
        CGPoint location = [sender locationInView:sender.view];
        if (!self.frame.size.width) {
            return;
        }
        x_radius += (touchPoint.x - location.x) / self.frame.size.width * 150;
        y_radius += (touchPoint.y - location.y) / self.frame.size.width * 150;
        if (y_radius > 90) {
            y_radius = 90;
        } else if (y_radius < -90) {
            y_radius = -90;
        }
        touchPoint = location;
    }
    else{
        _numberOfTouches = 0;
    }
}
#pragma mark- MERIDIANS
-(void) makeLatitudeLines{
    for(int i = 0; i < 64; i++){
        circlePoints[i*3+0] = -sinf(M_PI*2/64.0f*i);
        circlePoints[i*3+1] = 0.0f;
        circlePoints[i*3+2] = cosf(M_PI*2/64.0f*i);
    }
}

-(void) dealloc{
    [EAGLContext setCurrentContext:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)willDisplaying {
    [self setOrientToDevice:YES];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self.displayLink setPaused:NO];
    }
}

- (void)didEndDisplaying {
    [self setOrientToDevice:NO];
    [self.displayLink setPaused:YES];
    //有一定概率touchEnd回调不会走导致_numberOfTouches的值不对
    _numberOfTouches = 0;
}

- (void)resumeDisplay {
    [self setOrientToDevice:YES];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self.displayLink setPaused:NO];
    }
    if (self.image) {
        [self fullviewGuide];
    }
    [self reset];
}

- (void)didScroll:(UIScrollView *)scrollView {
    CGRect rect = [self convertRect:self.frame toView:scrollView];
    CGRect interRect = CGRectIntersection(rect, scrollView.bounds);

    if (scrollView.contentOffset.y <= -MJRefreshHeaderHeight && isShowing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateIsShowingForRefresh) object:nil];
        [self performSelector:@selector(updateIsShowingForRefresh) withObject:nil afterDelay:0.25];
    }
    
    if (interRect.size.height > self.frame.size.height / 2 && !isShowing) {
        if (self.image) {
            [self fullviewGuide];
        }
        [self reset];
        isShowing = YES;
    } else if (!interRect.size.height){
        isShowing = NO;
    }
}

- (void)updateIsShowingForRefresh
{
    isShowing = NO;
}

- (void)reset {
    x_radius = 0;
    y_radius = 0;
    self.fieldOfView = 45 + 45 * atanf(_aspectRatio);
}

#pragma mark - fullview guide

- (void)fullviewGuide
{
    self.fullViewGuideView.hidden = NO;
    self.fullViewGuideView.center = CGPointMake(self.center.x, self.center.y);
    self.isShowGyroTipView = NO;
    
    __weak typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(wself) self = wself;
        [self showFullviewGuide];
    });
}

- (void)showFullviewGuide
{
    self.gyroTipView.alpha = 0;
    self.triangelLayer.hidden = YES;
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         __strong typeof(wself) self = wself;
                         self.fullViewGuideView.alpha = 0;
                         self.gyroTipView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         __strong typeof(wself) self = wself;
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

#pragma mark - Themed Change

- (void)themeChanged:(NSNotification *)notification
{
    [self updateBackgroundColor];
}

- (void)updateBackgroundColor
{
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    
    if (!isDayModel) {
        self.alpha = 0.5f;
    } else {
        self.alpha = 1.0f;
    }
}

@end

@interface Sphere (){
    //  from Touch Fighter by Apple
    //  in Pro OpenGL ES for iOS
    //  by Mike Smithwick Jan 2011 pg. 78
    GLKTextureInfo *m_TextureInfo;
    GLfloat *m_TexCoordsData;
    GLfloat *m_VertexData;
    GLfloat *m_NormalData;
    GLint m_Stacks, m_Slices;
    GLfloat m_Scale;
}
-(GLKTextureInfo *) loadTextureFromBundle:(NSString *) filename;
-(GLKTextureInfo *) loadTextureFromPath:(NSString *) path;
-(GLKTextureInfo *) loadTextureFromImage:(UIImage *) image;
@end
@implementation Sphere
-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius textureFile:(NSString *)textureFile{
    // modifications:
    //   flipped(inverted) texture coords across the Z
    //   vertices rotated 90deg
    if(textureFile != nil) m_TextureInfo = [self loadTextureFromBundle:textureFile];
    m_Scale = radius;
    if((self = [super init])){
        m_Stacks = stacks;
        m_Slices = slices;
        m_VertexData = nil;
        m_TexCoordsData = nil;
        // Vertices
        GLfloat *vPtr = m_VertexData = (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));
        // Normals
        GLfloat *nPtr = m_NormalData = (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));
        GLfloat *tPtr = nil;
        tPtr = m_TexCoordsData = (GLfloat*)malloc(sizeof(GLfloat) * 2 * ((m_Slices*2+2) * (m_Stacks)));
        unsigned int phiIdx, thetaIdx;
        // Latitude
        for(phiIdx = 0; phiIdx < m_Stacks; phiIdx++){
            //starts at -pi/2 goes to pi/2
            //the first circle
            float phi0 = M_PI * ((float)(phiIdx+0) * (1.0/(float)(m_Stacks)) - 0.5);
            //second one
            float phi1 = M_PI * ((float)(phiIdx+1) * (1.0/(float)(m_Stacks)) - 0.5);
            float cosPhi0 = cos(phi0);
            float sinPhi0 = sin(phi0);
            float cosPhi1 = cos(phi1);
            float sinPhi1 = sin(phi1);
            float cosTheta, sinTheta;
            //longitude
            for(thetaIdx = 0; thetaIdx < m_Slices; thetaIdx++){
                float theta = -2.0*M_PI * ((float)thetaIdx) * (1.0/(float)(m_Slices - 1));
                cosTheta = cos(theta+M_PI*.5);
                sinTheta = sin(theta+M_PI*.5);
                //get x-y-x of the first vertex of stack
                vPtr[0] = m_Scale*cosPhi0 * cosTheta;
                vPtr[1] = m_Scale*sinPhi0;
                vPtr[2] = m_Scale*(cosPhi0 * sinTheta);
                //the same but for the vertex immediately above the previous one.
                vPtr[3] = m_Scale*cosPhi1 * cosTheta;
                vPtr[4] = m_Scale*sinPhi1;
                vPtr[5] = m_Scale*(cosPhi1 * sinTheta);
                nPtr[0] = cosPhi0 * cosTheta;
                nPtr[1] = sinPhi0;
                nPtr[2] = cosPhi0 * sinTheta;
                nPtr[3] = cosPhi1 * cosTheta;
                nPtr[4] = sinPhi1;
                nPtr[5] = cosPhi1 * sinTheta;
                if(tPtr!=nil){
                    GLfloat texX = (float)thetaIdx * (1.0f/(float)(m_Slices-1));
                    tPtr[0] = 1.0-texX;
                    tPtr[1] = (float)(phiIdx + 0) * (1.0f/(float)(m_Stacks));
                    tPtr[2] = 1.0-texX;
                    tPtr[3] = (float)(phiIdx + 1) * (1.0f/(float)(m_Stacks));
                }
                vPtr += 2*3;
                nPtr += 2*3;
                if(tPtr != nil) tPtr += 2*2;
            }
            //Degenerate triangle to connect stacks and maintain winding order
            vPtr[0] = vPtr[3] = vPtr[-3];
            vPtr[1] = vPtr[4] = vPtr[-2];
            vPtr[2] = vPtr[5] = vPtr[-1];
            nPtr[0] = nPtr[3] = nPtr[-3];
            nPtr[1] = nPtr[4] = nPtr[-2];
            nPtr[2] = nPtr[5] = nPtr[-1];
            if(tPtr != nil){
                tPtr[0] = tPtr[2] = tPtr[-2];
                tPtr[1] = tPtr[3] = tPtr[-1];
            }
        }
    }
    return self;
}
-(void) dealloc{
    GLuint name = m_TextureInfo.name;
    glDeleteTextures(1, &name);
    
    if(m_TexCoordsData != nil){
        free(m_TexCoordsData);
    }
    if(m_NormalData != nil){
        free(m_NormalData);
    }
    if(m_VertexData != nil){
        free(m_VertexData);
    }
}
-(bool) execute{
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    if(m_TexCoordsData != nil){
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        if(m_TextureInfo != 0)
            glBindTexture(GL_TEXTURE_2D, m_TextureInfo.name);
        glTexCoordPointer(2, GL_FLOAT, 0, m_TexCoordsData);
    }
    glVertexPointer(3, GL_FLOAT, 0, m_VertexData);
    glNormalPointer(GL_FLOAT, 0, m_NormalData);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_Slices +1) * 2 * (m_Stacks-1)+2);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    return true;
}
-(GLKTextureInfo *) loadTextureFromBundle:(NSString *) filename{
    if(!filename) return nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:NULL];
    return [self loadTextureFromPath:path];
}
-(GLKTextureInfo *) loadTextureFromPath:(NSString *) path{
    if(!path) return nil;
    NSError *error;
    GLKTextureInfo *info;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    info=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    glBindTexture(GL_TEXTURE_2D, info.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, IMAGE_SCALING);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, IMAGE_SCALING);
    return info;
}
-(GLKTextureInfo *) loadTextureFromImage:(UIImage *) image {
    if(!image) return nil;
    NSError *error;
    GLKTextureInfo *info;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil];
    info = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:&error];
    if (!info) {
        /***
         *  有image load失败的情况
         *  https://stackoverflow.com/questions/8976383/crop-a-uiimage-to-use-with-glktextureloader
         */
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage,(CGRect){.size = image.size});
        image = [UIImage imageWithData:UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef])];
        
        info = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:&error];
    }
    glBindTexture(GL_TEXTURE_2D, info.name);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, IMAGE_SCALING);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, IMAGE_SCALING);
    return info;
}
-(void)swapTexture:(NSString*)textureFile{
    GLuint name = m_TextureInfo.name;
    glDeleteTextures(1, &name);
    if ([[NSFileManager defaultManager] fileExistsAtPath:textureFile]) {
        m_TextureInfo = [self loadTextureFromPath:textureFile];
    }
    else {
        m_TextureInfo = [self loadTextureFromBundle:textureFile];
    }
}
-(BOOL)swapTextureWithImage:(UIImage*)image {
    GLuint name = m_TextureInfo.name;
    glDeleteTextures(1, &name);
    m_TextureInfo = [self loadTextureFromImage:image];
    if (m_TextureInfo) {
        return YES;
    } else {
        return NO;
    }
}
-(CGSize)getTextureSize{
    if(m_TextureInfo){
        return CGSizeMake(m_TextureInfo.width, m_TextureInfo.height);
    }
    else{
        return CGSizeZero;
    }
}

@end
