//
//  FHMapDrawMaskView.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import "FHMapDrawMaskView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHHouseBase/UIImage+FIconFont.h>

#define MIN_POINTS 20
#define CLOSE_WIDTH 58

@interface FHMapDrawMaskView ()

@property(nonatomic , strong) NSMutableArray *xcoords;
@property(nonatomic , strong) NSMutableArray *ycoords;
@property(nonatomic , strong) UIBezierPath *bezierPath;
@property(nonatomic , strong) UIButton *closeButton;

@end

@implementation FHMapDrawMaskView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SAFE_AREA
        CGFloat top = 27;
        if (safeInsets.top > 0) {
            top = safeInsets.top + 7;
        }
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(18, top, 24, 24);
        UIImage * img = ICON_FONT_IMG(18, @"\U0000e673",[UIColor themeGray1]);
        [_closeButton setImage:img forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(onCloseAction) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_closeButton];
    }
    return self;
}

-(NSMutableArray *)xcoords
{
    if (!_xcoords) {
        _xcoords = [NSMutableArray new];
    }
    return _xcoords;
}

-(NSMutableArray *)ycoords
{
    if (!_ycoords) {
        _ycoords = [NSMutableArray new];
    }
    return _ycoords;
}


-(UIBezierPath *)bezierPath
{
    if (!_bezierPath) {
        _bezierPath = [UIBezierPath bezierPath];
        _bezierPath.lineWidth = 10;
        
    }
    return _bezierPath;
}

-(void)onCloseAction
{
    [self.delegate userExit:self];
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [_bezierPath removeAllPoints];
        [_xcoords removeAllObjects];
        [_ycoords removeAllObjects];
        [self setNeedsDisplay];
    }
    [super willMoveToSuperview:newSuperview];
}

-(void)clear
{
    [self.xcoords removeAllObjects];
    [self.ycoords removeAllObjects];
    [self.bezierPath removeAllPoints];
    [self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.xcoords removeAllObjects];
    [self.ycoords removeAllObjects];
    [self.bezierPath removeAllPoints];
    
    if (touches.count > 1) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    [_bezierPath moveToPoint:loc];
    [self appendTouch:loc];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (touches.count > 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    [self appendTouch:loc];
    [_bezierPath addLineToPoint:loc];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (touches.count > 1) {
        return;
    }
    if (self.xcoords.count < MIN_POINTS) {
        [self.bezierPath removeAllPoints];
    }else{
        UITouch *touch = [touches anyObject];
        CGPoint loc = [touch locationInView:self];
        [self appendTouch:loc];
        [_bezierPath addLineToPoint:loc];
        [_bezierPath closePath];
        if (self.delegate) {
            [self.delegate userDrawWithXcoords:self.xcoords ycoords:self.ycoords inView:self];
        }
    }
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.bezierPath removeAllPoints];
    [self.xcoords removeAllObjects];
    [self setNeedsDisplay];
}

-(void)appendTouch:(CGPoint )loc
{
    [self.xcoords addObject:@(loc.x)];
    [self.ycoords addObject:@(loc.y)];
}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    CGFloat bottomSafeInset = 0;
//    if (@available(iOS 11.0 , *)) {
//        bottomSafeInset = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
//    }
//    _closeButton.frame = CGRectMake(14, CGRectGetHeight(self.bounds) - 31 - bottomSafeInset - CLOSE_WIDTH, CLOSE_WIDTH, CLOSE_WIDTH);
//}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor themeOrange1] setStroke];
    [self.bezierPath stroke];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
