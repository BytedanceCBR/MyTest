//
//  FHMyItemAnnView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/7/30.
//

#import "FHMyItemAnnView.h"
static CGFloat rRadii = 8.0f;//默认圆角大小

@implementation FHMyItemAnnView
-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)setAnnotation:(id<MAAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    [self addCornersAndShadow];
//    CGRect frame = self.frame;
//    frame.size = CGSizeMake(self.annotation.title.length * 16 + 5, 30);
//    self.frame = frame;
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.annotation.title.length * 16 + 5, 30);
}

- (void)addCornersAndShadow {
    [self addCorners:UIRectCornerAllCorners rRadii:rRadii shadowLayer:NULL];
}

- (void)addCorners:(UIRectCorner)corners
       shadowLayer:(void (^)(CALayer * shadowLayer))shadowLayer{
    
    [self addCorners:corners rRadii:rRadii shadowLayer:shadowLayer];
}
- (void)addCorners:(UIRectCorner)corners
            rRadii:(CGFloat)rRadii{
    
    [self addCorners:corners rRadii:rRadii shadowLayer:^(CALayer * shadowLayer) {
        shadowLayer.shadowOpacity = 0.25;
        shadowLayer.shadowOffset = CGSizeZero;
        shadowLayer.shadowRadius = 10;
    }];
}

- (void)addCorners:(UIRectCorner)corners
            rRadii:(CGFloat)rRadii
       shadowLayer:(nullable void (^)(CALayer * shadowLayer))shadowLayer{
    
    UIView * aview = self;
    CGSize cornerRadii = CGSizeMake(rRadii, rRadii);
    
    //前面的裁剪
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = [UIBezierPath bezierPathWithRoundedRect:aview.bounds
    byRoundingCorners:corners cornerRadii:cornerRadii].CGPath;
    aview.layer.mask = mask;
   
    //后面的那个
    if(!aview.superview) return;
    UIView * draftView = [[UIView alloc] initWithFrame:aview.frame];
    draftView.backgroundColor = aview.backgroundColor;
    [aview.superview insertSubview:draftView belowSubview:aview];
    
    if(shadowLayer){
        shadowLayer(draftView.layer);
    }else{
        draftView.layer.shadowOpacity = 0.25;
        draftView.layer.shadowOffset = CGSizeZero;
        draftView.layer.shadowRadius = 10;
    }
    
    draftView.backgroundColor = nil;
    draftView.layer.masksToBounds = NO;
    
    CALayer *cornerLayer = [CALayer layer];
    cornerLayer.frame = draftView.bounds;
    cornerLayer.backgroundColor = aview.backgroundColor.CGColor;

    CAShapeLayer *lay = [CAShapeLayer layer];
    lay.path = [UIBezierPath bezierPathWithRoundedRect:aview.bounds
    byRoundingCorners:corners cornerRadii:cornerRadii].CGPath;
    cornerLayer.mask = lay;
    [draftView.layer addSublayer:cornerLayer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//   return YES;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
