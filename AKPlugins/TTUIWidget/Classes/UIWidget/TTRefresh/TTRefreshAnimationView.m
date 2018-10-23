//
//  ZDLoadingView.m
//  PullToRefreshControlDemo
//
//  Created by Nick Yu on 126/13.
//  Copyright (c) 2013 Zhang Kai Yu. All rights reserved.
//

#import "TTRefreshAnimationView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "TTThemeConst.h"


#define kLongTextWidth 17
#define kShortTextWidth 7
#define kImageWidth 7
#define kImageHeight 6
#define kLeadingMargin 3.5f
#define kShortLeadingMargin 13.5f
#define kTopMargin 4.5f
#define kShortTopMargin 13.5f
#define kLineSpace 3.0f
#define kContentHeight 13.5f


@interface TTRefreshAnimationView()
{
    CAShapeLayer * borderLayer;
    CAShapeLayer * contentLayer;
    CAShapeLayer * imageLayer;
    CALayer * imageInnerLayer;
    
    
    CAShapeLayer * borderAnimationLayer;
    CALayer * imageAnimationLayer;
    CAShapeLayer * topContentAnimationLayer;
    CAShapeLayer * bottomContentAnimationLayer;
    CALayer * imageAnimationInnerLayer;
    CAShapeLayer * imageAnimationBorderLayer;
}

@property (nonatomic,assign) BOOL isLoading;

@end

@implementation TTRefreshAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        borderLayer = [CAShapeLayer layer];
        borderLayer.frame = CGRectMake(0,0,48,48);
        
        contentLayer = [CAShapeLayer layer];
        contentLayer.frame = CGRectMake(0,0,48,48);
        
        imageLayer = [CAShapeLayer layer];
        imageLayer.frame = CGRectMake(0,0,48,48);
        
        
        imageInnerLayer = [CALayer layer];
        imageInnerLayer.frame = CGRectMake(kLeadingMargin,kTopMargin,kImageWidth,kImageHeight);
        
        
        [self.layer addSublayer:borderLayer];
        [self.layer addSublayer:contentLayer];
        [self.layer addSublayer:imageInnerLayer];
        
        [self.layer addSublayer:imageLayer];
        
        [self addDrawAni];
        

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        borderLayer = [CAShapeLayer layer];
        borderLayer.frame = CGRectMake(0,0,48,48);
        
        contentLayer = [CAShapeLayer layer];
        contentLayer.frame = CGRectMake(0,0,48,48);
        
        imageLayer = [CAShapeLayer layer];
        imageLayer.frame = CGRectMake(0,0,48,48);
        
        imageInnerLayer = [CALayer layer];
        imageInnerLayer.frame = CGRectMake(kLeadingMargin,kTopMargin,kImageWidth,kImageHeight);
        
        
        [self.layer addSublayer:borderLayer];
        [self.layer addSublayer:contentLayer];
        [self.layer addSublayer:imageInnerLayer];
        
        [self.layer addSublayer:imageLayer];
        
        
        [self addDrawAni];
        
        
        
    }
    return self;
}

-(void)addDrawAni
{
    //boader part
    [borderLayer removeAllAnimations];
    CGPathRef path = [self newBorderLayer];
    borderLayer.path = path;
    CGPathRelease(path);
    borderLayer.fillColor   = [UIColor clearColor].CGColor;
    borderLayer.lineCap   = kCALineCapRound;
    borderLayer.lineJoin  = kCALineJoinRound;
    borderLayer.lineWidth = 0.5f;
    
    borderLayer.strokeEnd = .0;
    borderLayer.speed = 0;
    
    // Text is drawn by stroking the path from 0% to 100%
    CABasicAnimation *drawBorder = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawBorder.fromValue = @0;
    drawBorder.toValue = @1;
    drawBorder.duration = 1;
    [borderLayer addAnimation:drawBorder forKey:@"write"];
    borderLayer.timeOffset = 0;
    
    
    //content part
    [contentLayer removeAllAnimations];
    path = [self newContentLayer];
    contentLayer.path = path;
    CGPathRelease(path);
    contentLayer.fillColor   = [UIColor clearColor].CGColor;
    contentLayer.lineCap   = kCALineCapButt;
    contentLayer.lineJoin  = kCALineJoinRound;
    contentLayer.lineWidth = 1.0f;
    
    contentLayer.strokeEnd = .0;
    contentLayer.speed = 0;
    
    // Text is drawn by stroking the path from 0% to 100%
    CABasicAnimation *writeText = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    writeText.fromValue = @0;
    writeText.toValue = @1;
    writeText.duration = 1.0f;
    
    [contentLayer addAnimation:writeText forKey:@"write"];
    contentLayer.timeOffset = 0;
    
    //content part
    [imageLayer removeAllAnimations];
    path = [self newImageLayer];
    imageLayer.path = path;
    CGPathRelease(path);
    imageLayer.fillColor   = [UIColor clearColor].CGColor;
    imageLayer.lineJoin = kCALineJoinMiter;
    imageLayer.lineCap = kCALineCapSquare;
    imageLayer.lineWidth = 0.5f;
    
    imageLayer.strokeEnd = .0;
    imageLayer.speed = 0;
    
    // Text is drawn by stroking the path from 0% to 100%
    CABasicAnimation * drawImage = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawImage.fromValue = @0;
    drawImage.toValue = @1;
    drawImage.duration = 1.0;
    
    [imageLayer addAnimation:drawImage forKey:@"write"];
    imageLayer.timeOffset = 0;
    
    imageInnerLayer.opacity = 0;
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
}

-(IBAction)loadingAnimation
{
    CGFloat animationDuration = 2.0f;
    
    //外框图片
    if (!borderAnimationLayer) {
        borderAnimationLayer = [CAShapeLayer layer];
        borderAnimationLayer.frame = CGRectMake(0,0,48,48);
        CGPathRef path = [self newBorderLayer];
        borderAnimationLayer.path = path;
        CGPathRelease(path);
        borderAnimationLayer.fillColor   = [UIColor clearColor].CGColor;
        borderAnimationLayer.lineCap   = kCALineCapRound;
        borderAnimationLayer.lineJoin  = kCALineJoinRound;
        borderAnimationLayer.lineWidth = 0.5f;
        [self.layer addSublayer:borderAnimationLayer];
    }
    borderAnimationLayer.strokeColor = [UIColor tt_themedColorForKey:kColorLine1Disabled].CGColor;
    borderAnimationLayer.hidden = NO;
    
    
    //移动图片
    if (!imageAnimationLayer) {
        imageAnimationLayer = [CALayer layer];
        imageAnimationLayer.frame = CGRectMake(0,0,48,48);
        imageAnimationLayer.anchorPoint = CGPointMake(0,0);
        
        [borderAnimationLayer addSublayer:imageAnimationLayer];
        
        imageAnimationInnerLayer = [CALayer layer];
        imageAnimationInnerLayer.frame = CGRectMake(0,0,kImageWidth,kImageHeight);
        [imageAnimationLayer addSublayer:imageAnimationInnerLayer];
        
        
        imageAnimationBorderLayer = [CAShapeLayer layer];
        imageAnimationBorderLayer.frame = CGRectMake(0,0,48,48);
        CGPathRef path = [self newImageAnimationLayer];
        imageAnimationBorderLayer.path = path;
        CGPathRelease(path);
        imageAnimationBorderLayer.fillColor   = [UIColor clearColor].CGColor;
        imageAnimationBorderLayer.lineWidth = 0.5f;
        imageAnimationBorderLayer.lineJoin = kCALineJoinMiter;
        imageAnimationBorderLayer.lineCap = kCALineCapSquare;
        [imageAnimationLayer addSublayer:imageAnimationBorderLayer];
        
        
        
    }
    
    
    //移动图片的动画
    {
        if ([[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"]) {
            imageAnimationInnerLayer.backgroundColor = [UIColor colorWithHexString:@"353535"].CGColor;
            imageAnimationBorderLayer.strokeColor = [UIColor colorWithHexString:@"707070"].CGColor;
            
            
        }
        else {
            
            imageAnimationBorderLayer.strokeColor = [UIColor tt_themedColorForKey:kColorLine1Disabled].CGColor;
            
            imageAnimationInnerLayer.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1].CGColor;
        }
        
        
        imageAnimationLayer.hidden = NO;
        imageAnimationLayer.frame = CGRectMake(kLeadingMargin,kTopMargin+0.5, kImageWidth,kImageHeight);
        
        //phase 1
        CABasicAnimation * baseAnimation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin+0.5)] ;
        baseAnimation1.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin+kLongTextWidth-kImageWidth,kTopMargin+0.5)] ;
        
        CAAnimationGroup * group1 =[CAAnimationGroup animation];
        group1.animations =[NSArray arrayWithObjects:baseAnimation1, nil];
        group1.duration = animationDuration * 0.05;
        group1.beginTime = 0.065 * animationDuration;
        group1.fillMode = kCAFillModeForwards;
        
        //phase 2
        CABasicAnimation * baseAnimation2 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin+kLongTextWidth-kImageWidth, kTopMargin)] ;
        baseAnimation2.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin+kLongTextWidth-kImageWidth, kTopMargin+1 + kContentHeight - kImageHeight)] ;
        
        CAAnimationGroup * group2 =[CAAnimationGroup animation];
        group2.animations =[NSArray arrayWithObjects:baseAnimation2, nil];
        group2.duration = animationDuration * 0.05;
        group2.beginTime = animationDuration * 0.315;
        group2.fillMode = kCAFillModeForwards;
        
        //phase 3
        CABasicAnimation * baseAnimation3 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation3.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin+kLongTextWidth-kImageWidth, kTopMargin+1 + kContentHeight - kImageHeight)] ;
        baseAnimation3.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin+1 + kContentHeight - kImageHeight)] ;
        
        CAAnimationGroup * group3 =[CAAnimationGroup animation];
        group3.animations =[NSArray arrayWithObjects:baseAnimation3, nil];
        group3.duration = animationDuration*0.05;
        group3.beginTime = animationDuration * 0.565;
        group3.fillMode = kCAFillModeForwards;
        
        //phase 4
        CABasicAnimation * baseAnimation4 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation4.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin+1 + kContentHeight - kImageHeight)] ;
        baseAnimation4.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin+0.5)] ;
        
        CAAnimationGroup * group4 =[CAAnimationGroup animation];
        group4.animations =[NSArray arrayWithObjects:baseAnimation4, nil];
        group4.duration = animationDuration *0.05;
        group4.beginTime = animationDuration * 0.815;
        group4.fillMode = kCAFillModeForwards;
        
        
        //final sequance
        CAAnimationGroup * sequance =[CAAnimationGroup animation];
        sequance.animations =[NSArray arrayWithObjects: group1,group2,group3,group4,nil];
        sequance.duration = animationDuration;
        sequance.repeatCount = NSUIntegerMax;
        sequance.fillMode = kCAFillModeForwards;
        
        
        
        [imageAnimationLayer addAnimation:sequance forKey:@"move"];
    }
    //上面的文字
    {
        if (!topContentAnimationLayer) {
            topContentAnimationLayer = [CAShapeLayer layer];
            topContentAnimationLayer.frame = CGRectMake(0,0,48,48);
            CGPathRef path = [self newAnimationContentLayer];
            topContentAnimationLayer.path = path;
            CGPathRelease(path);
            topContentAnimationLayer.fillColor   = [UIColor clearColor].CGColor;
            topContentAnimationLayer.lineCap   = kCALineCapRound;
            topContentAnimationLayer.lineJoin  = kCALineJoinRound;
            topContentAnimationLayer.lineWidth = 1.0f;
            topContentAnimationLayer.masksToBounds = YES;
            topContentAnimationLayer.anchorPoint = CGPointMake(0,0);
            [borderAnimationLayer addSublayer:topContentAnimationLayer];
        }
        topContentAnimationLayer.strokeColor = [UIColor tt_themedColorForKey:kColorBackground6].CGColor;
        topContentAnimationLayer.hidden = NO;
        
        topContentAnimationLayer.frame = CGRectMake(kShortLeadingMargin,kTopMargin, kShortTextWidth,12);
        
        //phase 1
        CABasicAnimation * baseAnimation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(kShortLeadingMargin, kTopMargin)] ;
        baseAnimation1.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kShortTopMargin-1)] ;
        
        CABasicAnimation * boundsAnimation1 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation1.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0,kShortTextWidth, 12)];
        boundsAnimation1.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kLongTextWidth, 12)] ;
        
        CAAnimationGroup * group1 =[CAAnimationGroup animation];
        group1.animations =[NSArray arrayWithObjects:baseAnimation1, boundsAnimation1, nil];
        group1.duration = animationDuration * 0.12f;
        group1.fillMode = kCAFillModeForwards;
        group1.beginTime = 0.075*animationDuration;
        
        //phase 2
        CABasicAnimation * baseAnimation2 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kShortTopMargin-1)] ;
        baseAnimation2.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kShortTopMargin-1)] ;
        
        CABasicAnimation * boundsAnimation2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation2.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kLongTextWidth, 12)];
        boundsAnimation2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kShortTextWidth, 12)];
        
        CAAnimationGroup * group2 =[CAAnimationGroup animation];
        group2.animations =[NSArray arrayWithObjects:baseAnimation2, boundsAnimation2, nil];
        group2.duration = animationDuration * 0.07f;
        group2.beginTime = animationDuration * 0.325f;
        group2.fillMode = kCAFillModeForwards;
        
        //phase 3
        CABasicAnimation * baseAnimation3 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation3.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kShortTopMargin-1)] ;
        baseAnimation3.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin)] ;
        
        CABasicAnimation * boundsAnimation3 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation3.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kShortTextWidth, 12)] ;
        boundsAnimation3.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0,kLongTextWidth, 12)] ;
        
        CAAnimationGroup * group3 =[CAAnimationGroup animation];
        group3.animations =[NSArray arrayWithObjects:baseAnimation3, boundsAnimation3, nil];
        group3.duration = animationDuration * 0.12f;
        group3.beginTime = animationDuration *0.575;
        group3.fillMode = kCAFillModeForwards;
        
        //phase 4
        CABasicAnimation * baseAnimation4 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation4.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin,kTopMargin)] ;
        baseAnimation4.toValue = [NSValue valueWithCGPoint:CGPointMake(kShortLeadingMargin, kTopMargin)] ;
        
        CABasicAnimation * boundsAnimation4 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation4.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kLongTextWidth, 12)];
        boundsAnimation4.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kShortTextWidth, 12)];
        
        CAAnimationGroup * group4 =[CAAnimationGroup animation];
        group4.animations =[NSArray arrayWithObjects:baseAnimation4, boundsAnimation4, nil];
        group4.duration = animationDuration*0.07f;
        group4.beginTime = animationDuration*0.825;
        group4.fillMode = kCAFillModeForwards;
        
        //final sequance
        CAAnimationGroup * sequance =[CAAnimationGroup animation];
        sequance.animations =[NSArray arrayWithObjects:group1, group2, group3, group4, nil];
        sequance.duration = animationDuration;
        sequance.repeatCount = NSUIntegerMax;
        sequance.fillMode = kCAFillModeForwards;
        
        [topContentAnimationLayer addAnimation:sequance forKey:@"move"];
    }
    
    //下面的文字
    {
        if (!bottomContentAnimationLayer) {
            bottomContentAnimationLayer = [CAShapeLayer layer];
            bottomContentAnimationLayer.frame = CGRectMake(0,0,48,48);
            CGPathRef path = [self newAnimationContentLayer];
            bottomContentAnimationLayer.path = path;
            CGPathRelease(path);
            bottomContentAnimationLayer.fillColor   = [UIColor clearColor].CGColor;
            bottomContentAnimationLayer.lineCap   = kCALineCapRound;
            bottomContentAnimationLayer.lineJoin  = kCALineJoinRound;
            bottomContentAnimationLayer.lineWidth = 1.0f;
            bottomContentAnimationLayer.masksToBounds = YES;
            bottomContentAnimationLayer.anchorPoint = CGPointMake(0,0);
            [borderAnimationLayer addSublayer:bottomContentAnimationLayer];
        }
        bottomContentAnimationLayer.strokeColor = [UIColor tt_themedColorForKey:kColorBackground6].CGColor;
        
        bottomContentAnimationLayer.hidden = NO;
        bottomContentAnimationLayer.frame = CGRectMake(kLeadingMargin,kShortTopMargin-1, kLongTextWidth,12);
        
        
        //phase 1
        CABasicAnimation * baseAnimation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kShortTopMargin-1)] ;
        baseAnimation1.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin)] ;
        
        CABasicAnimation * boundsAnimation1 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation1.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kLongTextWidth, 12)];
        boundsAnimation1.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kShortTextWidth, 12)];
        
        CAAnimationGroup * group1 =[CAAnimationGroup animation];
        group1.animations =[NSArray arrayWithObjects:baseAnimation1, boundsAnimation1, nil];
        group1.duration = animationDuration * 0.07f;
        group1.beginTime = 0.075 * animationDuration;
        group1.fillMode = kCAFillModeForwards;
        
        //phase 2
        CABasicAnimation * baseAnimation2 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin)] ;
        baseAnimation2.toValue = [NSValue valueWithCGPoint:CGPointMake((kLeadingMargin), kTopMargin)] ;
        
        CABasicAnimation * boundsAnimation2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation2.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kShortTextWidth, 12)] ;
        boundsAnimation2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kLongTextWidth, 12)] ;
        
        CAAnimationGroup * group2 =[CAAnimationGroup animation];
        group2.animations =[NSArray arrayWithObjects:baseAnimation2, boundsAnimation2, nil];
        group2.duration = animationDuration * 0.12f;
        group2.beginTime = 0.325 * animationDuration;
        group2.fillMode = kCAFillModeForwards;
        
        //phase 3
        CABasicAnimation * baseAnimation3 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation3.fromValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kTopMargin)] ;
        baseAnimation3.toValue = [NSValue valueWithCGPoint:CGPointMake(kShortLeadingMargin, kShortTopMargin-1)] ;
        
        CABasicAnimation * boundsAnimation3 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation3.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kLongTextWidth, 12)];
        boundsAnimation3.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, kShortTextWidth, 12)];
        
        CAAnimationGroup * group3 =[CAAnimationGroup animation];
        group3.animations =[NSArray arrayWithObjects:baseAnimation3, boundsAnimation3, nil];
        group3.duration = animationDuration * 0.07f;
        group3.beginTime = 0.575 * animationDuration;
        group3.fillMode = kCAFillModeForwards;
        
        //phase 4
        CABasicAnimation * baseAnimation4 = [CABasicAnimation animationWithKeyPath:@"position"];
        baseAnimation4.fromValue = [NSValue valueWithCGPoint:CGPointMake(kShortLeadingMargin, kShortTopMargin-1)] ;
        baseAnimation4.toValue = [NSValue valueWithCGPoint:CGPointMake(kLeadingMargin, kShortTopMargin-1)] ;
        
        CABasicAnimation * boundsAnimation4 = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation4.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0,  kShortTextWidth, 12)];
        boundsAnimation4.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0,  kLongTextWidth, 12)] ;
        
        CAAnimationGroup * group4 =[CAAnimationGroup animation];
        group4.animations =[NSArray arrayWithObjects:baseAnimation4, boundsAnimation4, nil];
        group4.duration = animationDuration * 0.12f;
        group4.beginTime = 0.825 * animationDuration;
        group4.fillMode = kCAFillModeForwards;
        
        
        
        //final sequance
        CAAnimationGroup * sequance =[CAAnimationGroup animation];
        sequance.animations =[NSArray arrayWithObjects: group1,group2,group3,group4,nil];
        sequance.duration = animationDuration;
        sequance.repeatCount = NSUIntegerMax;
        sequance.fillMode = kCAFillModeForwards;
        
        [bottomContentAnimationLayer addAnimation:sequance forKey:@"move"];
    }
}

-(void)setPercent:(CGFloat)precent
{
    
    precent = MAX(0, precent);
    precent = MIN(precent, 1);
    if(_percent == precent) return;
    
    _percent = precent;
    
    if (!self.isLoading) {
        if ([imageLayer animationForKey:@"write"] == nil) {
            [self addDrawAni];
        }
        else
        {
            borderLayer.timeOffset = self.percent;
            contentLayer.timeOffset = self.percent;
            imageLayer.timeOffset = self.percent;
            imageInnerLayer.opacity = self.percent;
            
            borderLayer.strokeColor = [UIColor tt_themedColorForKey:kColorLine1Disabled].CGColor;
            contentLayer.strokeColor = [UIColor tt_themedColorForKey:kColorBackground6].CGColor;
            imageLayer.strokeColor = [UIColor tt_themedColorForKey:kColorLine1Disabled].CGColor;
            
            
            if ([[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"]) {
                imageInnerLayer.backgroundColor = [UIColor colorWithHexString:@"353535"].CGColor;
                
                borderLayer.strokeColor = [UIColor colorWithHexString:@"707070"].CGColor;
                contentLayer.strokeColor = [UIColor colorWithHexString:@"707070"].CGColor;
                imageLayer.strokeColor = [UIColor colorWithHexString:@"707070"].CGColor;
                
            }
            else
            {
                imageInnerLayer.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1].CGColor;
                borderLayer.strokeColor = [UIColor tt_themedColorForKey:kColorLine1Disabled].CGColor;
                contentLayer.strokeColor = [UIColor tt_themedColorForKey:kColorBackground6].CGColor;
                imageLayer.strokeColor = [UIColor tt_themedColorForKey:kColorLine1Disabled].CGColor;
                
            }
            
        }
    }
}
-(void)startLoading
{
    self.isLoading = YES;
    
    borderLayer.timeOffset = 0;
    contentLayer.timeOffset = 0;
    imageLayer.timeOffset = 0;
    imageInnerLayer.opacity = 0;
    
    [self loadingAnimation];
}

-(void)stopLoading
{
    self.isLoading = NO;
    
    borderAnimationLayer.hidden = YES;
    
    [imageAnimationLayer removeAllAnimations];
    imageAnimationLayer.hidden = YES;
    
    [topContentAnimationLayer removeAllAnimations];
    topContentAnimationLayer.hidden = YES;
    
    [bottomContentAnimationLayer removeAllAnimations];
    bottomContentAnimationLayer.hidden = YES;
    
}

- (CGPathRef)newBorderLayer
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(38.13/2.0f, -0/2.0f)];
    [bezierPath addLineToPoint: CGPointMake(9.87/2.0f, -0/2.0f)];
    [bezierPath addCurveToPoint: CGPointMake(0/2.0f, 9.87/2.0f) controlPoint1: CGPointMake(4.39/2.0f, -0/2.0f) controlPoint2: CGPointMake(0/2.0f, 4.39/2.0f)];
    [bezierPath addLineToPoint: CGPointMake(0/2.0f, 38.13/2.0f)];
    [bezierPath addCurveToPoint: CGPointMake(9.87/2.0f, 48/2.0f) controlPoint1: CGPointMake(0/2.0f, 43.61/2.0f) controlPoint2: CGPointMake(4.39/2.0f, 48/2.0f)];
    [bezierPath addLineToPoint: CGPointMake(38.13/2.0f, 48/2.0f)];
    [bezierPath addCurveToPoint: CGPointMake(48/2.0f, 38.13/2.0f) controlPoint1: CGPointMake(43.61/2.0f, 48/2.0f) controlPoint2: CGPointMake(48/2.0f, 43.61/2.0f)];
    [bezierPath addLineToPoint: CGPointMake(48/2.0f, 9.87/2.0f)];
    [bezierPath addCurveToPoint: CGPointMake(38.13/2.0f, -0/2.0f) controlPoint1: CGPointMake(48/2.0f, 4.39/2.0f) controlPoint2: CGPointMake(43.61/2.0f, -0/2.0f)];
    [bezierPath addLineToPoint: CGPointMake(38.13/2.0f, -0/2.0f)];
    [bezierPath closePath];
    CGPathAddPath(path, NULL, bezierPath.CGPath);
    
    
    return path;
}

- (CGPathRef)newContentLayer
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    //// Group
    {
        UIBezierPath* linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint: CGPointMake(kShortLeadingMargin, kTopMargin)];
        [linePath addLineToPoint: CGPointMake(kShortLeadingMargin+kShortTextWidth, kTopMargin)];
        
        [linePath moveToPoint: CGPointMake(kShortLeadingMargin, kTopMargin+kLineSpace)];
        [linePath addLineToPoint: CGPointMake(kShortLeadingMargin+kShortTextWidth, kTopMargin+kLineSpace)];
        
        [linePath moveToPoint: CGPointMake(kShortLeadingMargin, kTopMargin+kLineSpace*2)];
        [linePath addLineToPoint: CGPointMake(kShortLeadingMargin+kShortTextWidth, kTopMargin+kLineSpace*2)];
        
        [linePath moveToPoint: CGPointMake(kLeadingMargin, kTopMargin+kLineSpace*3)];
        [linePath addLineToPoint: CGPointMake(kLeadingMargin+kLongTextWidth, kTopMargin+kLineSpace*3)];
        
        [linePath moveToPoint: CGPointMake(kLeadingMargin, kTopMargin+kLineSpace*4)];
        [linePath addLineToPoint: CGPointMake(kLeadingMargin+kLongTextWidth, kTopMargin+kLineSpace*4)];
        
        [linePath moveToPoint: CGPointMake(kLeadingMargin, kTopMargin+kLineSpace*5)];
        [linePath addLineToPoint: CGPointMake(kLeadingMargin+kLongTextWidth, kTopMargin+kLineSpace*5)];
        
        CGPathAddPath(path, NULL, linePath.CGPath);
        
    }
    
    return path;
}

- (CGPathRef)newImageLayer
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    //// Group
    {
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = [UIBezierPath bezierPathWithRect:CGRectMake(kLeadingMargin, kTopMargin, kImageWidth, kImageHeight)];
        CGPathAddPath(path, NULL, bezier2Path.CGPath);
    }
    
    return path;
}

- (CGPathRef)newImageAnimationLayer
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    //// Group
    {
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kImageWidth, kImageHeight)];
        CGPathAddPath(path, NULL, bezier2Path.CGPath);
    }
    
    return path;
}

- (CGPathRef)newAnimationContentLayer
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    //// Group
    {
        //// Rectangle Drawing
        UIBezierPath* linePath = [UIBezierPath bezierPath];
        
        [linePath moveToPoint: CGPointMake(0, 1)];
        [linePath addLineToPoint: CGPointMake(kLongTextWidth, 1)];
        
        [linePath moveToPoint: CGPointMake(0, 1+2.5)];
        [linePath addLineToPoint: CGPointMake(kLongTextWidth, 1+2.5)];
        
        [linePath moveToPoint: CGPointMake(0, 1+2.5*2)];
        [linePath addLineToPoint: CGPointMake(kLongTextWidth, 1+2.5*2)];
        
        CGPathAddPath(path, NULL, linePath.CGPath);
        
    }
    
    return path;
}


@end


@interface TTRefreshAnimationContainerView()
{
    NSString *_initText;
    NSString *_pullText;
    NSString *_loadingText;
    NSString *_noMoreText;
    CGFloat _pullRefreshLoadingHeight;
    
}

@property(nonatomic,strong)TTRefreshAnimationView *refreshAnimationView;

@property(nonatomic,strong)SSThemedLabel *titleLabel;



@end

@implementation TTRefreshAnimationContainerView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame WithLoadingHeight:0 WithinitText:nil WithpullText:nil WithloadingText:nil WithnoMoreText:nil];
}



-(id)initWithFrame:(CGRect)frame WithLoadingHeight:(CGFloat)loadingHeight WithinitText:(NSString *)initText WithpullText:(NSString *)pullText
   WithloadingText:(NSString *)loadingText WithnoMoreText:(NSString *)noMoreText{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _pullRefreshLoadingHeight = loadingHeight;
        _initText = initText;
        _pullText = pullText;
        _loadingText = loadingText;
        _noMoreText = noMoreText;
        
        self.refreshAnimationView = [[TTRefreshAnimationView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [self addSubview:self.refreshAnimationView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:9.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColors = @[@"5D5D5D", @"707070"];
        [self addSubview:self.titleLabel];
        
    }
    
    return self;
    
}


-(void)startLoading{
    
    [self.refreshAnimationView startLoading];
}

-(void)stopLoading{
    
    [self.refreshAnimationView stopLoading];
    
}

- (void)updateAnimationWithScrollOffset:(CGFloat)offset{
    
    offset += 30;
    CGFloat fractionDragged = MIN(1, -offset / (kTTPullRefreshHeight - 30));
    self.refreshAnimationView.percent = fractionDragged;
}

-(void)updateViewWithPullState:(PullDirectionState)state{
    
    NSString *tmp;
    
    switch (state) {
        case PULL_REFRESH_STATE_INIT:
            
            if (_loadingText.length == 0) {
                tmp = @"";
            } else {
                tmp = _initText;
            }
            break;
        case PULL_REFRESH_STATE_PULL:
            
            tmp = _initText;
            break;
        case PULL_REFRESH_STATE_PULL_OVER:
            
            tmp = _pullText;
            break;
            
        case PULL_REFRESH_STATE_LOADING:
            
            tmp = _loadingText;
            break;
        case PULL_REFRESH_STATE_NO_MORE:
            
            self.refreshAnimationView.hidden = YES;
            tmp = _noMoreText;
            break;
        default:
            break;
    }
    
    self.titleLabel.text = tmp;
    [self.titleLabel sizeToFit];
    
    [self adjustSubviewFrame];
}

- (void)adjustSubviewFrame
{
    if (self.titleLabel.text == nil || [self.titleLabel.text isEqualToString:@""]) {
        self.titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+10);
        self.refreshAnimationView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - _pullRefreshLoadingHeight/2);
    }
    else {
        self.titleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height - self.titleLabel.frame.size.height/2 - 8);
        self.refreshAnimationView.center = CGPointMake(self.frame.size.width/2, self.titleLabel.frame.origin.y - 6 - self.refreshAnimationView.frame.size.height/2);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustSubviewFrame];
}

- (void)configurePullRefreshLoadingHeight:(CGFloat)pullRefreshLoadingHeight{
    _pullRefreshLoadingHeight = pullRefreshLoadingHeight;
}




@end
