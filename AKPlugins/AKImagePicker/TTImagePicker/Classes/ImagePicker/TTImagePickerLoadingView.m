//
//  TTImagePickerLoadingView.m
//  LoadingIcon
//
//  Created by tyh on 2017/7/5.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import "TTImagePickerLoadingView.h"
#import "UIViewAdditions.h"
#import "SSThemed.h"
#import "TTThemeManager.h"

static const float TTImagePickerLoadingCylcleWidthDefault = 1.0;
static const float TTImagePickerLoadingCylcleInsetDefault = 0;

#define TTImagePickerLoadingCylcleBorderColorDefault  [UIColor whiteColor]
#define TTImagePickerLoadingCylcleFillColorDefault  [UIColor whiteColor]

@interface TTImagePickerLoadingView()<CAAnimationDelegate>


@property (nonatomic,strong)CAShapeLayer *shapeLayer;
@property (nonatomic,strong)CAShapeLayer *circleLayer;
@property (nonatomic,strong)SSThemedButton *failedBtn;
@property (nonatomic,strong)SSThemedLabel *failedLabel;
@property (nonatomic,assign)float initProgress;

@end

@implementation TTImagePickerLoadingView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderWidth = TTImagePickerLoadingCylcleWidthDefault;
        self.inset = TTImagePickerLoadingCylcleInsetDefault;
        self.borderColor = TTImagePickerLoadingCylcleBorderColorDefault;
        self.fillColor = TTImagePickerLoadingCylcleFillColorDefault;
        self.backgroundColor = [UIColor clearColor];
        self.autoDismissWhenCompleted = YES;
        
        self.initProgress = ((arc4random() % 10) /10.0 )* 0.2;
        //最小初始值
        if (self.initProgress == 0) {
            self.initProgress = 0.1 * 0.2;
        }
        
    }
    return self;
}

- (void)setProgress:(float)progress
{
    if (progress != 1) {
        self.hidden = NO;
    }
    
    if (progress < self.initProgress) {
        progress = self.initProgress;
    }else if (progress > 1){
        progress = 1;
    }
    
    
    if (_progress != progress) {
        _progress = progress;
        [self drawProgress];
    }
    
    
}

/// 复写这些set方法，为了设置就生效
- (void)setInset:(CGFloat)inset
{
    _inset = inset;
    [self drawProgress];
}
- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self drawProgress];
}
- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self drawProgress];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self drawProgress];
}

- (void)drawProgress
{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_circleLayer];
        
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
    }
    /*让半径等于期望半径的一半  lineWidth等于期望半径 就可以画圆*/
    
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    
    
    //    UIColor *color = [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1];
    
    //外界可设置
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.width/2.0 - self.inset startAngle:- M_PI_2 endAngle:3 * M_PI /2.0 clockwise:YES];
    _circleLayer.path = circlePath.CGPath;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(self.width/2.0, self.height/2.0) radius:self.width/4.0 - self.inset/2.0 startAngle:- M_PI_2 endAngle:3 * M_PI /2.0 clockwise:YES];
    _shapeLayer.path = bezierPath.CGPath;
    
    _circleLayer.strokeColor = self.borderColor.CGColor;
    _circleLayer.borderWidth = self.borderWidth;
    _shapeLayer.strokeColor = self.fillColor.CGColor;
    _shapeLayer.strokeEnd = self.progress;
    _shapeLayer.lineWidth = self.width/2.0 - self.inset;
    
    if (self.autoDismissWhenCompleted && self.progress == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hidden = YES;
        });
    }
    
}

- (void)setIsFailed:(BOOL)isFailed
{
    _isFailed = isFailed;
    if (_isFailed) {
        if (!self.failedBtn) {
            self.failedBtn = [SSThemedButton buttonWithType:UIButtonTypeRoundedRect];
            self.failedBtn.frame = self.frame;
            [self.failedBtn setImage:[[UIImage imageNamed:@"ImgPic_icloud_failed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:0];
            [self.failedBtn addTarget:self action:@selector(failedAction) forControlEvents:UIControlEventTouchUpInside];
            self.failedBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        }
        self.failedBtn.tintColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorBackground7];
        [self removeLayer];
        [self.superview addSubview:self.failedBtn];
        
        if (self.isShowFailedLabel) {
            if (!self.failedLabel ) {
                self.failedLabel = [[SSThemedLabel alloc]initWithFrame:CGRectMake(self.failedBtn.right + 5, self.failedBtn.top, 50, self.failedBtn.height)];
                self.failedLabel.text = @"重试";
                self.failedLabel.textColorThemeKey = kColorBackground4;
            }
            self.failedBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -65);
            [self.superview addSubview:self.failedLabel];
        }
    }else{
        [self.failedBtn removeFromSuperview];
        [self.failedLabel removeFromSuperview];
    }
}

- (void)removeLayer
{
    self.hidden = YES;
    [_shapeLayer removeFromSuperlayer];
    _shapeLayer = nil;
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
}


- (void)failedAction
{
    //重置状态
    self.isFailed = NO;
    self.progress = 0;
    if (self.retry) {
        self.retry();
    }
}


- (void)removeViews
{
    [self.failedBtn removeFromSuperview];
    [self.failedLabel removeFromSuperview];
    [self removeFromSuperview];
}
@end
