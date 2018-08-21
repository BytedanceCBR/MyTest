//
//  WDDetailSlideMoreButtonView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/22.
//
//

#import "WDDetailSlideMoreButtonView.h"
#import "WDDefines.h"

CGRect WDDetailSlideMoreButtonFrame() {
    return CGRectMake(0, 0, 68, 44);
}

@interface WDDetailSlideMoreButtonView ()

@property(nonatomic, strong, readwrite)TTAlphaThemedButton *moreButton;

@end

@implementation WDDetailSlideMoreButtonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _moreButton.enableHighlightAnim = YES;
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        _moreButton.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_moreButton];
        
        [self reloadThemeUI];
        
        _moreButton.frame = CGRectMake(0, 0, 56 / 2, 44);
        
        [self sizeToFit];
    }
    return self;
}

- (void)setStyle:(WDDetailMoreButtonStyle)style {
    _style = style;
    [self refreshButtonStyle];
}

- (void)refreshButtonStyle {
    if ([TTDeviceHelper isPadDevice]) {
        [_moreButton setImage:[UIImage themedImageNamed:@"new_more_titlebar"] forState:UIControlStateNormal];
    }
    else if (_style == WDDetailMoreButtonStyleDefault) {
        [_moreButton setImage:[UIImage themedImageNamed:@"new_more_titlebar"] forState:UIControlStateNormal];
    }
    else if (_style == WDDetailMoreButtonStyleLightContent) {
        [_moreButton setImage:[UIImage themedImageNamed:@"ask_more_title"] forState:UIControlStateNormal];
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
