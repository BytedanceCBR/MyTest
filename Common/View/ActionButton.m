//
//  PadActionButton.m
//  Article
//
//  Created by Dianwei on 12-10-12.
//
//

#import "ActionButton.h"
#import "SSMotionRender.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import <KVOController/KVOController.h>

@interface ActionButton()
@property(nonatomic, retain)NSMutableDictionary *textColorDictionary;
@property(nonatomic, retain)NSMutableDictionary *imageDictionary;
@property(nonatomic, retain)NSMutableDictionary *backgroundImageDictinary;
@property(nonatomic, retain)NSMutableDictionary *fontDictionary;
@property(nonatomic, retain)UIButton *button;
@end

@implementation ActionButton
{
    id _target;
    SEL _action;
}

@synthesize titleLabel, imageView, backgroundImageView;
@synthesize textColorDictionary, imageDictionary, backgroundImageDictinary, button, fontDictionary;

- (void)dealloc
{
    [self.KVOController unobserveAll];
    self.textColorDictionary = nil;
    self.imageDictionary = nil;
    self.backgroundImageDictinary = nil;
    self.button = nil;
    self.titleLabel = nil;
    self.imageView = nil;
    self.backgroundImageView = nil;
    self.fontDictionary = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColorDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        self.imageDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        self.backgroundImageDictinary = [NSMutableDictionary dictionaryWithCapacity:3];
        self.fontDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:titleLabel];
        [self addSubview:imageView];
        [self addSubview:backgroundImageView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.bounds;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:button];
        [self sendSubviewToBack:backgroundImageView];
        [self bringSubviewToFront:button];
        
        WeakSelf;
        [self.KVOController observe:button.titleLabel keyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self updateUI];
        }];
        [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [button setTitle:@"enable" forState:UIControlStateNormal];
        [button setTitle:@"highlight" forState:UIControlStateHighlighted];
        [button setTitle:@"disable" forState:UIControlStateDisabled];
        
        [self setTitleColor:[UIColor tt_defaultColorForKey:kColorText3] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHexString:@"cc0001"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithHexString:@"b5b7c2"] forState:UIControlStateDisabled];
        [self setTitleColor:[UIColor colorWithHexString:@"cc0001"] forState:UIControlStateSelected];
        
    }
    
    return self;
}

- (void)setFont:(UIFont*)font forState:(UIControlState)state
{
    [fontDictionary setValue:font forKey:[NSString stringWithFormat:@"%@", @(state)]];
}

- (void)themeChanged:(NSNotification *)notification
{
    [self updateThemes];
}

- (void)doZoomInAndDisappearMotion
{
    [SSMotionRender motionInView:self byType:SSMotionTypeZoomInAndDisappear];
}

- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)clicked:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
}

- (void)updateThemes
{
//    if(!button.enabled && _selected)
    if(_selected)
    {
        titleLabel.textColor = [self contentFromDictionary:textColorDictionary ForState:UIControlStateSelected];
        [imageView setImage:[self contentFromDictionary:imageDictionary ForState:UIControlStateSelected]];
        UIFont *font = [self contentFromDictionary:fontDictionary ForState:UIControlStateSelected];
        if(!font)
        {
            font = [self contentFromDictionary:fontDictionary ForState:UIControlStateNormal];
        }
        
        titleLabel.font = font;
        
    }
    else
    {
        titleLabel.textColor = [self contentFromDictionary:textColorDictionary ForState:UIControlStateNormal];
        [imageView setImage:[self contentFromDictionary:imageDictionary ForState:UIControlStateNormal]];
        titleLabel.font = [self contentFromDictionary:fontDictionary ForState:UIControlStateNormal];
    }
    
    [backgroundImageView setImage:[self contentFromDictionary:backgroundImageDictinary ForState:button.state]];
}

- (void)updateFrames
{
    [titleLabel sizeToFit];
    [imageView sizeToFit];
    
    CGSize tmpSize = CGSizeMake(CGRectGetWidth(titleLabel.frame) + CGRectGetWidth(imageView.frame) + 4 * 3,
                                MAX(CGRectGetHeight(titleLabel.frame), CGRectGetHeight(imageView.frame)) + 4);
    
    
    CGRect textRect = titleLabel.frame;
    CGRect imageRect = imageView.frame;
    CGRect selfRect = self.frame;
    selfRect.size.height = tmpSize.height;
    if(tmpSize.width < 60)
    {
        selfRect.size.width = tmpSize.width;
        tmpSize.width = 60;
//        float space = (tmpSize.width - CGRectGetWidth(titleLabel.frame) - CGRectGetWidth(imageView.frame) - 4) / 2;
//        imageRect.origin.x = space;
        imageRect.origin.x = 4;
        textRect.origin.x = CGRectGetMaxX(imageRect) + 4;
    }
    else
    {
        imageRect.origin.x = 4;
        textRect.origin.x = CGRectGetMaxX(imageRect) + 4;
        
    }
    
    selfRect.size.width = tmpSize.width;
    self.frame = selfRect;
    titleLabel.frame = textRect;
    imageView.frame = imageRect;
    backgroundImageView.frame = self.bounds;
    backgroundImageView.height = MAX((backgroundImageView.height), 25);
    titleLabel.center = CGPointMake(titleLabel.center.x, self.frame.size.height/2);
    imageView.center = CGPointMake(imageView.center.x, self.frame.size.height/2);
}

- (void)updateUI
{
    [self updateThemes];
    [self updateFrames];
}

- (UIButton *)innerButton
{
    return button;
}

- (BOOL)enabled
{
    return button.enabled;
}

- (void)setEnabled:(BOOL)enabled selected:(BOOL)selected
{    
    button.enabled = enabled;
    button.selected = selected;
    _selected = selected;
    [self updateUI];
}

- (void)setTitleColor:(UIColor*)color forState:(UIControlState)state
{
    [textColorDictionary setValue:color forKey:[NSString stringWithFormat:@"%@", @(state)]];
}

- (void)setTitle:(NSString*)text
{
    self.titleLabel.text = text;
    [self updateUI];
}

- (void)setImage:(UIImage*)image forState:(UIControlState)state
{
    [imageDictionary setValue:image forKey:[NSString stringWithFormat:@"%@", @(state)]];
}

- (void)setBackgroundImage:(UIImage*)image forState:(UIControlState)state
{
    [backgroundImageDictinary setValue:image forKey:[NSString stringWithFormat:@"%@", @(state)]];
}

- (id)contentFromDictionary:(NSDictionary*)dict ForState:(UIControlState)state
{
    id result = [dict objectForKey:[NSString stringWithFormat:@"%@", @(state)]];
    if(!result)
    {
        result = [dict objectForKey:[NSString stringWithFormat:@"%@", @(UIControlStateNormal)]];
    }
    
    return result;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
