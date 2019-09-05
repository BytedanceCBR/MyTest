//
//  FHUGCProgressView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/8/26.
//

#import "FHUGCProgressView.h"

@interface FHUGCProgressView ()

@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation FHUGCProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.height/2;
        
        //初始化变量
        [self initVars];
    }
    return self;
}

- (void)initVars {
    self.offset = 0;
    self.progress = 0;
    
    self.isLeftGradient = NO;
    self.isRightGradient = NO;
    
    self.leftColor = [UIColor clearColor];
    self.rightColor = [UIColor clearColor];
}

- (UIImageView *)imageView {
    if(!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)drawRect:(CGRect)rect {
    if(rect.size.width == 0 || rect.size.height == 0){
        return;
    }
    
    CGFloat leftWidth = self.frame.size.width * _progress;
    CGFloat offset = _offset;
    if(leftWidth <= 0 || leftWidth >= self.frame.size.width){
        offset = 0;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    [_leftColor set]; //设置线条颜色
    
    UIBezierPath* leftPath = [UIBezierPath bezierPath];
    leftPath.lineWidth = 1.0;
    
    leftPath.lineCapStyle = kCGLineCapRound; //线条拐角
    leftPath.lineJoinStyle = kCGLineJoinRound; //终点处理
    
    [leftPath moveToPoint:CGPointMake(0.0, 0.0)];//起点
    
    // Draw the lines
    [leftPath addLineToPoint:CGPointMake(leftWidth, 0)];
    [leftPath addLineToPoint:CGPointMake(leftWidth - offset, self.frame.size.height)];
    [leftPath addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [leftPath closePath];//第五条线通过调用closePath方法得到的

    [leftPath fill];//颜色填充
    
    [_rightColor set]; //设置线条颜色
    
    UIBezierPath* rightPath = [UIBezierPath bezierPath];
    rightPath.lineWidth = 1.0;
    
    rightPath.lineCapStyle = kCGLineCapRound; //线条拐角
    rightPath.lineJoinStyle = kCGLineJoinRound; //终点处理
    
    [rightPath moveToPoint:CGPointMake(self.frame.size.width, 0.0)];//起点
    
    // Draw the lines
    [rightPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [rightPath addLineToPoint:CGPointMake(leftWidth, self.frame.size.height)];
    [rightPath addLineToPoint:CGPointMake(leftWidth + offset, 0)];
    [rightPath closePath];//第五条线通过调用closePath方法得到的
    
    [rightPath fill];//颜色填充
    
    if(_isLeftGradient){
        [self drawLinearGradient:gc path:leftPath.CGPath startColor:[UIColor blueColor].CGColor endColor:[UIColor yellowColor].CGColor];
    }
    
    if(_isRightGradient){
        [self drawLinearGradient:gc path:rightPath.CGPath startColor:[UIColor blueColor].CGColor endColor:[UIColor yellowColor].CGColor];
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //设置渐变图像
    self.imageView.image = img;
}

- (void)drawLinearGradient:(CGContextRef)context path:(CGPathRef)path startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    //单向，从左到右
    startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
    endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));
    
    UIGraphicsPushContext(context);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    UIGraphicsPopContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)setProgress:(CGFloat)progress {
    progress = [self roundFloat:progress];
    if(progress > 1){
        progress = 1;
    }
    
    if(progress < 0){
        progress = 0;
    }
    
    _progress = progress;
    [self setNeedsDisplay];
}

-(float)roundFloat:(float)price{
    return roundf(price*100)/100;
}

@end
