//
//  SSWebViewBackButtonView.m
//  Article
//
//  Created by Zhang Leonardo on 14-7-9.
//
//

#import "SSWebViewBackButtonView.h"
#import "UIButton+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"

#define kButtonPadding 12.f
#define kSSWebViewBackButtonViewWidth 56
#define kSSWebViewBackButtonViewHeight 44


@interface SSWebViewBackButtonView()

@property(nonatomic, retain, readwrite)TTAlphaThemedButton * closeButton;
@property(nonatomic, retain, readwrite)TTAlphaThemedButton * backButton;

@end

@implementation SSWebViewBackButtonView

- (void)dealloc
{
    self.closeButton = nil;
    self.backButton = nil;
}

- (id)init
{
    CGRect frame = CGRectMake(0, 0, kSSWebViewBackButtonViewWidth + kButtonPadding, kSSWebViewBackButtonViewHeight);
    self = [self initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.enableHighlightAnim = YES;
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -15, 0, -8);
        _backButton.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_backButton];
        
        self.closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.enableHighlightAnim = YES;
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.hidden = YES;
        [self addSubview:_closeButton];
        
        [self reloadThemeUI];
        
//        if ([TTDeviceHelper is736Screen]) {
//            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -11, 0, 11)];
//        }
//        else {
//            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -11, 0, 6)];
//        }
        
//        CGFloat leftPadding = [TTDeviceHelper isPadDevice] ? 12.5f : 0;
        _backButton.frame = CGRectMake(0, 0, kSSWebViewBackButtonViewWidth / 2, kSSWebViewBackButtonViewHeight);
        _closeButton.frame = CGRectMake(kSSWebViewBackButtonViewWidth / 2 + kButtonPadding, 0, kSSWebViewBackButtonViewWidth / 2, kSSWebViewBackButtonViewHeight);
        
        [self sizeToFit];
    }

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void)setStyle:(SSWebViewBackButtonStyle)style
{
    _style = style;
    [self refreshButtonStyle];
}

- (void)refreshButtonStyle {
    if (_style == SSWebViewBackButtonStyleDefault) {
        [_backButton setImage:[UIImage themedImageNamed:@"lefterbackicon_titlebar"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage themedImageNamed:@"titlebar_close"] forState:UIControlStateNormal];
    }
    else if (_style == SSWebViewBackButtonStyleLightContent) {
        [_backButton setImage:[UIImage themedImageNamed:@"white_lefterbackicon_titlebar"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage themedImageNamed:@"titlebar_close_white"] forState:UIControlStateNormal];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self refreshButtonStyle];
}

- (void)showCloseButton:(BOOL)show
{
    _closeButton.hidden = !show;
    
    [self sizeToFit];
}

- (BOOL)isCloseButtonShowing
{
    return !_closeButton.hidden;
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
    if (_closeButton.hidden) {
        return CGSizeMake(kSSWebViewBackButtonViewWidth/2 + 4, kSSWebViewBackButtonViewHeight);
    } else {
        return CGSizeMake(kSSWebViewBackButtonViewWidth + kButtonPadding, kSSWebViewBackButtonViewHeight);
    }
}

- (CGSize)intrinsicContentSize {
    if (_closeButton.hidden) {
        return CGSizeMake(kSSWebViewBackButtonViewWidth/2, kSSWebViewBackButtonViewHeight);
    } else {
        return CGSizeMake(kSSWebViewBackButtonViewWidth, kSSWebViewBackButtonViewHeight);
    }
}

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 8.0f, 0, 0);
    return insets;
}

@end
