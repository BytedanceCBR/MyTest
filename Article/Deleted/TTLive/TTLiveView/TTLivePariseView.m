//
//  TTLivePariseView.m
//  Article
//
//  Created by 杨心雨 on 2016/10/23.
//
//

#import "TTLivePariseView.h"
#import "TTImageView.h"

#define kLiveImageSize (32 * 0.85)

/** 点赞效果类型 */
typedef NS_ENUM(NSUInteger, TTLivePariseType) {
    /** 他人点赞 */
    TTLivePariseTypeOther = 0,
    /** 用户点赞 */
    TTLivePariseTypeUser = 1
};

@interface TTLivePariseDigView : SSThemedView <CAAnimationDelegate>

@property (nonatomic) BOOL isUsing;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGPoint startPosition;

- (void)setCommonImage:(NSString * _Nonnull)commonImage;
- (void)setUserImage:(NSString * _Nonnull)userImage;

- (nonnull instancetype)initWithCommonImage:(NSString * _Nonnull)commonImage maxHeight:(CGFloat)height maxWidth:(CGFloat)width startPosition:(CGPoint)position;
- (nonnull instancetype)initWithUserImage:(NSString * _Nullable)userImage commonImage:(NSString * _Nonnull)commonImage maxHeight:(CGFloat)height maxWidth:(CGFloat)width  startPosition:(CGPoint)position;

@property (nonatomic, strong) TTImageView *imageView;
@property (nonatomic, strong) TTImageView *commonImageView;
@property (nonatomic) TTLivePariseType type;

@end

@implementation TTLivePariseDigView {
    NSMutableArray<CAShapeLayer *> *lines;
    /** 用户的第二段位移，普通的全位移 */
    CAKeyframeAnimation *moveAnimation;
    CAKeyframeAnimation *scaleAnimation;
    CAKeyframeAnimation *opacityAnimation;

    CAKeyframeAnimation *userMoveAnimation;
    CAKeyframeAnimation *imageAnimation;
    CAKeyframeAnimation *lineStrokeStart;
    CAKeyframeAnimation *lineStrokeEnd;
    CAKeyframeAnimation *lineOpacity;
}

- (instancetype)initWithCommonImage:(NSString *)commonImage maxHeight:(CGFloat)height maxWidth:(CGFloat)width startPosition:(CGPoint)position {
    self = [super initWithFrame:CGRectMake(0, height + kLiveImageSize / 2, kLiveImageSize, kLiveImageSize)];
    if (self) {
        self.maxHeight = round(height);
        self.maxWidth = round(width);
        self.type = TTLivePariseTypeOther;
        self.backgroundColor = [UIColor clearColor];
        self.startPosition = position;
        _imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        _imageView.layer.cornerRadius = kLiveImageSize / 2;
        _imageView.clipsToBounds = YES;
        _imageView.enableNightCover = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        [_imageView setImageWithURLString:commonImage placeholderImage:[UIImage imageNamed:@"chatroom_icon_bless"]];
        [self addSubview:_imageView];
        [self setupOthersAnimation];
    }
    return self;
}

- (instancetype)initWithUserImage:(NSString *)userImage commonImage:(NSString *)commonImage maxHeight:(CGFloat)height maxWidth:(CGFloat)width startPosition:(CGPoint)position{
    self = [super initWithFrame:CGRectMake(0, height + kLiveImageSize / 2, kLiveImageSize, kLiveImageSize)];
    if (self) {
        _commonImageView = [[TTImageView alloc] initWithFrame:self.bounds];
        [_commonImageView setImageWithURLString:commonImage placeholderImage:[UIImage imageNamed:@"chatroom_icon_bless"]];
        
        self.maxHeight = round(height);
        self.maxWidth = round(width);
        self.type = TTLivePariseTypeUser;
        self.backgroundColor = [UIColor clearColor];
        self.startPosition = position;
        lines = [[NSMutableArray<CAShapeLayer *> alloc] init];
        
        _imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        _imageView.layer.cornerRadius = kLiveImageSize / 2;
        _imageView.clipsToBounds = YES;
        _imageView.enableNightCover = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        [_imageView setImageWithURLString:userImage placeholderImage:[UIImage imageNamed:@"head-1"]];
        [self addSubview:_imageView];
        [self setupUserAnimation];
    }
    return self;
}

- (void)setCommonImage:(NSString *)commonImage {
    switch (self.type) {
        case TTLivePariseTypeUser:
            [_commonImageView setImageWithURLString:commonImage placeholderImage:[UIImage imageNamed:@"chatroom_icon_bless"]];
            break;
        case TTLivePariseTypeOther:
            [_imageView setImageWithURLString:commonImage placeholderImage:[UIImage imageNamed:@"chatroom_icon_bless"]];
            break;
    }
}

- (void)setUserImage:(NSString *)userImage {
    switch (self.type) {
        case TTLivePariseTypeUser:
            [_imageView setImageWithURLString:userImage placeholderImage:[UIImage imageNamed:@"head-1"]];
            break;
        case TTLivePariseTypeOther:
            break;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    switch (self.type) {
        case TTLivePariseTypeUser:
            [self startUserAnimation];
            break;
        case TTLivePariseTypeOther:
            [self startOthersAnimation];
            break;
    }
}

- (void)setupUserAnimation {
    CGFloat tempTime = 2 + (CGFloat)(arc4random() % 100) / 100;
    CGFloat explosionTime = 0.2;
    CGFloat explosionScale = 0.2 + (CGFloat)(arc4random() % 10) / 100;
    CGFloat firstMoveTime = 0.2 + (CGFloat)(arc4random() % 10) / 100;
    CGFloat secondMoveTime = tempTime * (1 - explosionScale);
    CGFloat exchangeTime = 0.05;
    CGFloat stayTime = 0.2;
    CGFloat totalTime = firstMoveTime + explosionTime + stayTime + secondMoveTime;
    
    //移动动画1
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint beginPoint = self.startPosition;
    CGPoint endPoint = [self randomXWithMaxWidth:_maxWidth height:_maxHeight * (1 - explosionScale) constWidthOffset:_maxWidth / 6];//CGPointMake(beginPoint.x, (_maxHeight * (1 - explosionScale)));
    self.center = endPoint;
    [bezierPath moveToPoint:beginPoint];
    [bezierPath addLineToPoint:endPoint];
    
    userMoveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    userMoveAnimation.duration = firstMoveTime;
    userMoveAnimation.path = bezierPath.CGPath;
    userMoveAnimation.fillMode = kCAFillModeForwards;
    userMoveAnimation.removedOnCompletion = NO;
    userMoveAnimation.delegate = self;
    [userMoveAnimation setValue:@"firstMoveAnimation" forKey:@"animationType"];
    
    //移动动画2
    UIBezierPath *bezierPath2 = [UIBezierPath bezierPath];
    CGPoint endPoint2 = [self randomXWithMaxWidth:_maxWidth height:0];
    CGPoint firstPoint2 = [self randomXWithMaxWidth:_maxWidth height:(_maxHeight * (1 - explosionScale) * 3 / 4)];
    CGPoint secondPoint2 = [self randomXWithMaxWidth:_maxWidth height:(_maxHeight * (1 - explosionScale) / 4)];
    [bezierPath2 moveToPoint:endPoint];
    [bezierPath2 addCurveToPoint:endPoint2 controlPoint1:firstPoint2 controlPoint2:secondPoint2];
    
    moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnimation.duration = secondMoveTime;
    moveAnimation.beginTime = CACurrentMediaTime() + firstMoveTime + explosionTime + stayTime;
    moveAnimation.path = bezierPath2.CGPath;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.delegate = self;
    [moveAnimation setValue:@"moveAnimation" forKey:@"animationType"];
    
    //缩放动画 0.6后进行大小缩放
    scaleAnimation = [CAKeyframeAnimation animation];
    scaleAnimation.duration = totalTime;
    scaleAnimation.keyTimes = @[@(0), @(firstMoveTime / totalTime), @((firstMoveTime + explosionTime) / totalTime), @(1)];
    scaleAnimation.values = @[@(0.5), @(0.5), @(1), @(1)];
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [scaleAnimation setValue:@"scale" forKey:@"animationType"];
    
    imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    CGImageRef userImage = self.imageView.imageView.image.CGImage ?: [UIImage imageNamed:@"head-1"].CGImage;
    CGImageRef commonImage = self.commonImageView.imageView.image.CGImage ?: [UIImage imageNamed:@"chatroom_icon_bless"].CGImage;
    imageAnimation.duration = stayTime + secondMoveTime;
    imageAnimation.beginTime = CACurrentMediaTime() + firstMoveTime + explosionTime;
    imageAnimation.keyTimes = @[@(0), @(stayTime / (stayTime + secondMoveTime)), @((stayTime + exchangeTime) / (stayTime + secondMoveTime)), @(1)];
    imageAnimation.values = @[(__bridge id)(userImage),
                              (__bridge id)(userImage),
                              (__bridge id)(commonImage),
                              (__bridge id)(commonImage)];
    imageAnimation.fillMode = kCAFillModeForwards;
    
    opacityAnimation = [CAKeyframeAnimation animation];
    opacityAnimation.duration = totalTime;
    opacityAnimation.keyTimes = @[@(0), @((totalTime - tempTime * 0.6) / totalTime), @((totalTime - tempTime * 0.1) / totalTime), @(1)];
    opacityAnimation.values = @[@(1), @(1), @(0), @(0)];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.keyPath = @"opacity";
    
    //擦的
    lineStrokeStart = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    lineStrokeStart.duration = explosionTime;
    lineStrokeStart.beginTime = CACurrentMediaTime() + firstMoveTime;
    lineStrokeStart.values = @[@(0), @(0.6), @(0.6), @(1)];
    lineStrokeStart.keyTimes = @[@(0.0), @(0.35), @(0.75), @(1.0)];
    
    //画的
    lineStrokeEnd = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    lineStrokeEnd.duration = explosionTime;
    lineStrokeEnd.beginTime = CACurrentMediaTime() + firstMoveTime;
    lineStrokeEnd.values = @[@(0), @(1.0), @(1.0)];
    lineStrokeEnd.keyTimes = @[@(0.0), @(0.5), @(1.0)];
    
    lineOpacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    lineOpacity.duration = explosionTime;
    lineOpacity.beginTime = CACurrentMediaTime() + firstMoveTime;
    lineOpacity.values = @[@(1.0), @(1.0), @(0.0)];
    lineOpacity.keyTimes = @[@(0.0), @(0.99), @(1)];    
}

- (void)startUserAnimation {
    [self.layer addAnimation:userMoveAnimation forKey:@"moveAnimation"];
    [self.layer addAnimation:moveAnimation forKey:@"moveAnimation2"];

    scaleAnimation.keyPath = @"transform.scale.x";
    [self.imageView.layer addAnimation:scaleAnimation forKey:@"scaleXAnimation"];
    
    scaleAnimation.keyPath = @"transform.scale.y";
    [self.imageView.layer addAnimation:scaleAnimation forKey:@"scaleYAnimation"];

    CGImageRef userImage = self.imageView.imageView.image.CGImage ?: [UIImage imageNamed:@"head-1"].CGImage;
    CGImageRef commonImage = self.commonImageView.imageView.image.CGImage ?: [UIImage imageNamed:@"chatroom_icon_bless"].CGImage;
    imageAnimation.values = @[(__bridge id)(userImage),
                              (__bridge id)(userImage),
                              (__bridge id)(commonImage),
                              (__bridge id)(commonImage)];
    [self.imageView.imageView.layer addAnimation:imageAnimation forKey:nil];

    [self.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    
    for (NSUInteger i = 0; i < 12; i++) {
        CAShapeLayer *line = [[CAShapeLayer alloc] init];
        CGRect frame = CGRectMake(- self.width / 2, - self.height / 2, self.width * 2, self.height * 2);
        line.bounds = frame;
        line.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        line.masksToBounds = YES;
        line.strokeColor = [[UIColor tt_themedColorForKey:kColorLine2] CGColor];
        line.lineWidth = 1.35;
        line.miterLimit = 5;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
        CGPathAddLineToPoint(path, nil, frame.origin.x + frame.size.width / 2, frame.origin.y);
        line.path = path;
        line.lineCap = kCALineCapRound;
        line.lineJoin = kCALineJoinRound;
        line.strokeStart = 0.0;
        line.strokeEnd = 0.0;
        line.opacity = 0.0;
        line.transform = CATransform3DMakeRotation(M_PI / 12 * ((CGFloat)(i) * 2 + 1), 0.0, 0.0, 1.0);
        
        [line addAnimation:lineStrokeStart forKey:@"strokeStart"];
        [line addAnimation:lineStrokeEnd forKey:@"strokeEnd"];
        [line addAnimation:lineOpacity forKey:@"opacity"];
        [self.layer insertSublayer:line atIndex:0];
        [lines addObject:line];
    }
}

- (void)setupOthersAnimation {
    CGFloat totalTime = 2 + (CGFloat)(arc4random() % 150) / 100;
    
    //移动动画
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint beginPoint = [self startPosition];
    CGPoint endPoint = [self randomXWithMaxWidth:_maxWidth height:0];
    CGPoint firstPoint = [self randomXWithMaxWidth:_maxWidth height:_maxHeight * 3 / 4];
    CGPoint secondPoint = [self randomXWithMaxWidth:_maxWidth height:_maxHeight / 4];
    [bezierPath moveToPoint:beginPoint];
    [bezierPath addCurveToPoint:endPoint controlPoint1:firstPoint controlPoint2:secondPoint];
    
    moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnimation.duration = totalTime;
    moveAnimation.path = bezierPath.CGPath;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.delegate = self;
    [moveAnimation setValue:@"moveAnimation" forKey:@"animationType"];

    //缩放动画 0.65后进行大小缩放
    scaleAnimation = [CAKeyframeAnimation animation];
    scaleAnimation.duration = totalTime;
    scaleAnimation.keyTimes = @[@(0), @(0.1), @(1)];
    scaleAnimation.values = @[@(0.2), @(1), @(1)];
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [scaleAnimation setValue:@"scale" forKey:@"animationType"];
    
    opacityAnimation = [CAKeyframeAnimation animation];
    opacityAnimation.duration = totalTime;
    opacityAnimation.keyTimes = @[@(0), @(0.4), @(0.9), @(1)];
    opacityAnimation.values = @[@(1), @(1), @(0), @(0)];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.keyPath = @"opacity";
}

- (void)startOthersAnimation {
    [self.layer addAnimation:moveAnimation forKey:@"moveAnimation"];
    
    scaleAnimation.keyPath = @"transform.scale.x";
    [self.imageView.layer addAnimation:scaleAnimation forKey:@"scaleXAnimation"];
    
    scaleAnimation.keyPath = @"transform.scale.y";
    [self.imageView.layer addAnimation:scaleAnimation forKey:@"scaleYAnimation"];
    
    [self.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"animationType"] isEqualToString:@"moveAnimation"]) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.layer removeAllAnimations];
            for (CAShapeLayer *layer in lines) {
                [layer removeAllAnimations];
            }
            [self removeFromSuperview];
            self.isUsing = NO;
        }];
        [CATransaction commit];
    }
}

- (CGPoint)randomXWithMaxWidth:(CGFloat)width height:(CGFloat)height {
    CGPoint randomPoint = CGPointZero;
    randomPoint.x = kLiveImageSize / 2 + (CGFloat)(arc4random() % (int)(width - kLiveImageSize));
    randomPoint.y = height;
    return randomPoint;
}

- (CGPoint)randomXWithMaxWidth:(CGFloat)width height:(CGFloat)height constWidthOffset:(CGFloat)offset {
    CGPoint p = [self randomXWithMaxWidth:width - offset * 2 height:height];
    p.x = p.x + offset;
    return p;
}

@end

@interface TTLivePariseView ()

@property (nonatomic, strong) NSMutableArray<TTLivePariseDigView *> *commonViewList;

@end

@implementation TTLivePariseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.commonViewList = [[NSMutableArray<TTLivePariseDigView *> alloc] init];
    }
    return self;
}

- (void)userPariseWithUserImage:(NSString *)userImage commonImage:(NSString *)commonImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        TTLivePariseDigView *digView = [[TTLivePariseDigView alloc] initWithUserImage:userImage commonImage:commonImage maxHeight:self.height maxWidth:self.width startPosition:CGPointMake(self.width - self.startOffsetX, self.height)];
        digView.isUsing = YES;
        digView.tag = 10000;
        [self addSubview:digView];
    });
}

- (void)otherPariseWithCommonImage:(NSString *)commonImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        TTLivePariseDigView *digView = [self getCommonViewWithCommonImage:commonImage];
        digView.isUsing = YES;
        [self addSubview:digView];
    });
}

- (TTLivePariseDigView *)getCommonViewWithCommonImage:(NSString *)commonImage {
    for (TTLivePariseDigView *view in _commonViewList) {
        if (!view.isUsing && view.maxHeight == self.height) {
            [view setCommonImage:commonImage];
            return view;
        }
    }
    TTLivePariseDigView *digView = [[TTLivePariseDigView alloc] initWithCommonImage:commonImage maxHeight:self.height maxWidth:self.width startPosition:CGPointMake(self.width - self.startOffsetX, self.height)];
    digView.tag = 1;
    [_commonViewList addObject:digView];
    return digView;
}

@end
