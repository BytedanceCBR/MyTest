//
//  FHCommuteSlider.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import "FHCommuteSlider.h"
#import <FHCommonUI/UIColor+Theme.h>

#define THUMB_IMAGE_WIDTH 50
#define LINE_HEIGHT  4


@interface FHCommuteSlider ()<UIGestureRecognizerDelegate>

@property(nonatomic , strong) CALayer *minLineLayer;
@property(nonatomic , strong) CALayer *maxLineLayer;
@property(nonatomic , strong) UIImageView *trackerImageView;
@property(nonatomic , assign) BOOL inMove;

@end

@implementation FHCommuteSlider

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minLineLayer = [CALayer layer];
        _minLineLayer.cornerRadius = 2;
        _minLineLayer.bounds = CGRectMake(0, 0, 0, 4);
        _minLineLayer.backgroundColor = [[UIColor themeOrange4] CGColor];
        
        _maxLineLayer = [CALayer layer];
        _maxLineLayer.cornerRadius = 2;
        _maxLineLayer.bounds = CGRectMake(0, 0, 0, 4);
        _maxLineLayer.backgroundColor = [[UIColor themeGray7] CGColor];
        
        
        _type = FHCommuteTypeDrive;
        _trackerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - THUMB_IMAGE_WIDTH/2, THUMB_IMAGE_WIDTH, THUMB_IMAGE_WIDTH)];
        _trackerImageView.image = [self thumbForType:_type];
        
        [self.layer addSublayer:_minLineLayer];
        [self.layer addSublayer:_maxLineLayer];
        [self addSubview:_trackerImageView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
    
}

-(void)setType:(FHCommuteType)type
{
    if (type != _type) {
        _type = type;
        _trackerImageView.image = [self thumbForType:type];
    }
}


-(void)panAction:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [panGesture locationInView:_trackerImageView];
            if (CGRectContainsPoint(_trackerImageView.bounds, location)) {
                _inMove = YES;
            }else{
                _inMove = NO;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (_inMove) {
                CGPoint location = [panGesture locationInView:self];
                [self tryUpdateValue:location];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _inMove = NO;
            [self updateValue:NO];
        }
            break;
        default:
            break;
    }
}

-(void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state) {
        case UIGestureRecognizerStateEnded: {
            CGPoint location = [tapGesture locationInView:self];
            [self tryUpdateValue:location];
            [self updateValue:NO];
        }
            break;
            
        default:
            break;
    }
}

-(void)tryUpdateValue:(CGPoint)location
{
    CGFloat value = (location.x/CGRectGetWidth(self.bounds))*(_maxValue - _minValue) + _minValue;
    if (value < _minValue) {
        value = _minValue;
    }else if (value > _maxValue){
        value = _maxValue;
    }
    self.value = value;
    [self updateValue:YES];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offsetx = ((_value- _minValue)/(_maxValue-_minValue))*CGRectGetWidth(self.frame)-THUMB_IMAGE_WIDTH/2 ;
    if (offsetx < 1) {
        offsetx = -6;
    }else if (offsetx + THUMB_IMAGE_WIDTH/2 > CGRectGetWidth(self.frame)){
        offsetx = CGRectGetWidth(self.frame) - THUMB_IMAGE_WIDTH/2;
    }
    
    CGRect frame = CGRectMake(offsetx, (CGRectGetHeight(self.frame) - THUMB_IMAGE_WIDTH)/2, THUMB_IMAGE_WIDTH, THUMB_IMAGE_WIDTH);
    _trackerImageView.frame = frame;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    _minLineLayer.frame = CGRectMake(0, (CGRectGetHeight(frame)-LINE_HEIGHT)/2, offsetx+THUMB_IMAGE_WIDTH/2, LINE_HEIGHT);
    _maxLineLayer.frame = CGRectMake(offsetx+THUMB_IMAGE_WIDTH/2,(CGRectGetHeight(frame)-LINE_HEIGHT)/2 , CGRectGetWidth(self.frame) - offsetx-THUMB_IMAGE_WIDTH/2, LINE_HEIGHT);
    [CATransaction commit];
}

-(void)setValue:(CGFloat)value
{
    if (value != _value) {
        _value = value;
        [self setNeedsLayout];
    }
}


-(void)updateValue:(BOOL)isDragging
{
    if (self.updateValue) {
        self.updateValue(_value, isDragging);
    }
}

-(UIImage *)thumbForType:(FHCommuteType)type // todo zjing UI
{
    NSString *name = nil;
    switch (type) {
        case FHCommuteTypeBus:
            name = @"commute_bus";
            break;
        case FHCommuteTypeRide:
            name = @"commute_ride";
            break;
        case FHCommuteTypeWalk:
            name = @"commute_walk";
            break;
        default:
            name = @"commute_drive";
    }
    
    return [UIImage imageNamed:name];
    
}

#pragma gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)gestureRecognizer;
        CGPoint location = [tapGesture locationInView:_trackerImageView];
        if (CGRectContainsPoint(_trackerImageView.bounds, location)) {
            return NO;
        }
    }
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
