//
//  TTBackButtonView.m
//  Article
//
//  Created by Zhang Leonardo on 14-7-9.
//
//

#import "TTBackButtonView.h"
#import "UIButton+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"

#define kTTBackButtonPadding 12.f
#define kTTBackButtonViewWidth 56
#define kTTBackButtonViewHeight 44


@interface TTBackButtonView()

@property(nonatomic, retain, readwrite)TTAlphaThemedButton * closeButton;
@property(nonatomic, retain, readwrite)TTAlphaThemedButton * backButton;

@end

@implementation TTBackButtonView

+ (NSBundle *)resourceBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"TTBackButtonView.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

- (void)dealloc
{
    self.closeButton = nil;
    self.backButton = nil;
}

- (id)init
{
    CGRect frame = CGRectMake(0, 0, kTTBackButtonViewWidth + kTTBackButtonPadding, kTTBackButtonViewHeight);
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
        _backButton.accessibilityLabel = @"返回";
        [self addSubview:_backButton];
        
        self.closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.enableHighlightAnim = YES;
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
        _closeButton.backgroundColor = [UIColor clearColor];
        _closeButton.hidden = YES;
        _closeButton.accessibilityLabel = @"关闭";
        [self addSubview:_closeButton];
        
        [self reloadThemeUI];
        
//        if ([TTDeviceHelper is736Screen]) {
//            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -11, 0, 11)];
//        }
//        else {
//            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -11, 0, 6)];
//        }
        
//        CGFloat leftPadding = [TTDeviceHelper isPadDevice] ? 12.5f : 0;
        _backButton.frame = CGRectMake(0, 0, kTTBackButtonViewWidth / 2, kTTBackButtonViewHeight);
        _closeButton.frame = CGRectMake(kTTBackButtonViewWidth / 2 + kTTBackButtonPadding, 0, kTTBackButtonViewWidth / 2, kTTBackButtonViewHeight);
        
        [self sizeToFit];
    }

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void)setStyle:(TTBackButtonStyle)style
{
    _style = style;
    [self refreshButtonStyle];
}

- (void)refreshButtonStyle {
    if (_style == TTBackButtonStyleDefault) {
        [_backButton setImage:[UIImage themedImageNamed:@"lefterbackicon_titlebar" inBundle:self.class.resourceBundle] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage themedImageNamed:@"titlebar_close" inBundle:self.class.resourceBundle] forState:UIControlStateNormal];
    }
    else if (_style == TTBackButtonStyleLightContent) {
        [_backButton setImage:[UIImage themedImageNamed:@"white_lefterbackicon_titlebar" inBundle:self.class.resourceBundle] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage themedImageNamed:@"titlebar_close_white" inBundle:self.class.resourceBundle] forState:UIControlStateNormal];
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
        return CGSizeMake(kTTBackButtonViewWidth/2 + 4, kTTBackButtonViewHeight);
    } else {
        return CGSizeMake(kTTBackButtonViewWidth + kTTBackButtonPadding, kTTBackButtonViewHeight);
    }
}

- (CGSize)intrinsicContentSize {
    if (_closeButton.hidden) {
        return CGSizeMake(kTTBackButtonViewWidth/2, kTTBackButtonViewHeight);
    } else {
        return CGSizeMake(kTTBackButtonViewWidth, kTTBackButtonViewHeight);
    }
}

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 8.0f, 0, 0);
    return insets;
}

@end
