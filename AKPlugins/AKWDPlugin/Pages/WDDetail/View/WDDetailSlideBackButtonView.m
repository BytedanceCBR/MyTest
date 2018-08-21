//
//  WDDetailSlideBackButtonView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/22.
//
//

#import "WDDetailSlideBackButtonView.h"
#import "WDDefines.h"

CGRect WDDetailSlideBackButtonFrame() {
    return CGRectMake(0, 0, 68, 44);
}

@interface WDDetailSlideBackButtonView ()

@property(nonatomic, strong, readwrite)TTAlphaThemedButton *backButton;

@end

@implementation WDDetailSlideBackButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.enableHighlightAnim = YES;
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        _backButton.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_backButton];
        
        [self reloadThemeUI];

        _backButton.frame = CGRectMake(0, 0, 56 / 2, 44);
        
        [self sizeToFit];
    }
    
    return self;
}

- (void)setStyle:(WDDetailBackButtonStyle)style {
    _style = style;
    [self refreshButtonStyle];
}

- (void)refreshButtonStyle {
    if ([TTDeviceHelper isPadDevice]) {
        [_backButton setImage:[UIImage themedImageNamed:@"lefterbackicon_titlebar"] forState:UIControlStateNormal];
    }
    else if (_style == WDDetailBackButtonStyleDefault) {
        [_backButton setImage:[UIImage themedImageNamed:@"lefterbackicon_titlebar"] forState:UIControlStateNormal];
    }
    else if (_style == WDDetailBackButtonStyleLightContent) {
        [_backButton setImage:[UIImage themedImageNamed:@"white_wddetail_backicon"] forState:UIControlStateNormal];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self refreshButtonStyle];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (!self.userInteractionEnabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, UIEdgeInsetsMake(0, -15, 0, -20));
    
    return CGRectContainsPoint(hitFrame, point);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(56/2 + 4, 44);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(56/2, 44);
}

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 8.0f, 0, 0);
    return insets;
}


@end
