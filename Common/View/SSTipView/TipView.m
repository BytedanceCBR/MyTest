//
//  TipView.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TipView.h"

#define PADDING 10.f
#define TIP_LABLE_FONT_SIZE 17.f
#define TIP_LABEL_WIDTH 120.f
#define VISIBEL_FRAME CGRectMake(0, 0, 160, 160)

@interface TipView () {
    
    id _hideTarget;
    SEL _hideSelector;
}

@property (nonatomic, retain) UIView      *bgView;
@property(nonatomic, retain)NSTimer *timer;
@end

@implementation TipView

@synthesize bgView   =_bgView;
@synthesize tipImage =_tipImage;
@synthesize tipLabel =_tipLabel;
@synthesize timer;
@synthesize autoLayout;
- (void)dealloc
{
	self.bgView   = nil;
	self.tipImage = nil;
	self.tipLabel = nil;
    [timer invalidate];
    self.timer = nil;
    
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    	self.backgroundColor = [UIColor clearColor];
        
        // bgView
    	self.bgView = [[[UIView alloc] init] autorelease];
    	_bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.7f;
        _bgView.layer.cornerRadius = 5.f;
    	[self addSubview:_bgView];
        
        // tipImage
    	self.tipImage = [[[UIImageView alloc] init] autorelease];
    	_tipImage.backgroundColor = [UIColor clearColor];
    	[self addSubview:_tipImage];
        
    	// tipLabel
    	self.tipLabel = [[[UILabel alloc] init] autorelease];
    	_tipLabel.backgroundColor = [UIColor clearColor];
    	_tipLabel.font = FONT_DEFAULT(TIP_LABLE_FONT_SIZE);
        _tipLabel.textAlignment = UITextAlignmentCenter;
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.numberOfLines = 0;
    	[self addSubview:_tipLabel];
        self.autoLayout = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(NSString *)imageName message:(NSString *)message
{
    self = [self initWithFrame:frame];
    if (self) {
        
        _tipImage.image = [UIImage resourceImageNamed:imageName];
        _tipLabel.text = message;
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews
{

    
    CGRect vFrame = self.frame;
    
    if (!_tipImage.image) {
//        vFrame.size.height /= 2;
        
        _bgView.frame = vFrame;
        _bgView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        
        vFrame = _bgView.frame;
        
        CGRect tlFrame = _tipLabel.frame;
        CGFloat height = heightOfContent(_tipLabel.text, TIP_LABEL_WIDTH, TIP_LABLE_FONT_SIZE);
        
        tlFrame.size.width = TIP_LABEL_WIDTH;
        tlFrame.size.height = height;
        tlFrame.origin.y = CGRectGetMaxY(vFrame) - PADDING - height;
        tlFrame.origin.x = CGRectGetMinX(vFrame) + (vFrame.size.width - tlFrame.size.width) / 2;
        
        if(autoLayout)
        {
            _tipLabel.frame = tlFrame;
        }
        
        _tipLabel.center = _bgView.center;
    }
    else {
        _bgView.frame = vFrame;
        _bgView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        
        vFrame = _bgView.frame;
        
        [_tipImage sizeToFit];
        CGRect tiFrame = _tipImage.frame;
        tiFrame.origin.y = CGRectGetMinY(vFrame) + PADDING;
        tiFrame.origin.x = CGRectGetMinX(vFrame) + (vFrame.size.width - _tipImage.frame.size.width) / 2;
        
        _tipImage.frame = tiFrame;
        
        CGRect tlFrame = _tipLabel.frame;
        CGFloat height = heightOfContent(_tipLabel.text, TIP_LABEL_WIDTH, TIP_LABLE_FONT_SIZE);
        
        tlFrame.size.width = TIP_LABEL_WIDTH;
        tlFrame.size.height = height;
        tlFrame.origin.y = CGRectGetMaxY(vFrame) - PADDING - height;
        tlFrame.origin.x = CGRectGetMinX(vFrame) + (vFrame.size.width - tlFrame.size.width) / 2;
        
        if(autoLayout)
        {
            _tipLabel.frame = tlFrame;
        }
    }
}


- (void)invalidate
{
    [timer invalidate];
}

- (void)startWaitToDismiss:(float)secs
{
    [timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:secs target:self selector:@selector(dismiss:) userInfo:nil repeats:NO];
}

- (void)dismiss:(NSTimer*)timer
{
    [self removeFromSuperview];
}

#pragma mark - private

- (void)reportSingleTapGesture
{
    if(_hideTarget)
    {
        NSMethodSignature *signature = [_hideTarget methodSignatureForSelector:_hideSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:_hideTarget];
        [invocation setSelector:_hideSelector];
        [invocation invoke];
    }
}

#pragma mark - public

- (void)setHideTarget:(id)target selector:(SEL)selector
{
    _hideTarget = target;
    _hideSelector = selector;
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self reportSingleTapGesture];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self reportSingleTapGesture];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self reportSingleTapGesture];
}

- (UIImage*)image
{
return _tipImage.image;
}

- (void)setImage:(UIImage *)image
{
_tipImage.image = image;
}

- (NSString*)message
{
return _tipLabel.text;
}

- (void)setMessage:(NSString *)message
{
_tipLabel.text = message;
}


@end
