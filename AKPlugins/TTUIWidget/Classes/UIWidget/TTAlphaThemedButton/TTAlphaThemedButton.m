//
//  TTAlphaThemedButton.m
//  Article
//
//  Created by 王双华 on 15/10/22.
//
//

#import "TTAlphaThemedButton.h"
#import "UIImageAdditions.h"
#import <Masonry/Masonry.h>
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@interface TTNightMaskView : SSThemedView

@property (nonatomic, strong) SSThemedImageView *maskImage;
@property (nonatomic, assign) BOOL enableRounded;

@end

@implementation TTNightMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self themeChanged:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    if([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight)
    {
        UIImage *image = [UIImage imageWithSize:self.bounds.size backgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
        self.maskImage.image = self.enableRounded ? [image imageByRoundCornerRadius:image.size.width / 2] : image;
    } else {
        UIImage *image = [UIImage imageWithSize:self.bounds.size backgroundColor:[UIColor colorWithWhite:0 alpha:0]];
        self.maskImage.image = self.enableRounded ? [image imageByRoundCornerRadius:image.size.width / 2] : image;
    }
}

- (SSThemedImageView *)maskImage
{
    if (!_maskImage) {
        _maskImage = [[SSThemedImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_maskImage];
        [_maskImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _maskImage;
}

@end


@interface TTAlphaThemedButton ()

@property (nonatomic, strong) UIImage *originNormalImage;
@property (nonatomic, strong) TTNightMaskView *nightMask;

@end

@implementation TTAlphaThemedButton

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableHighlightAnim = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _enableHighlightAnim = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [self setImage:self.originNormalImage forState:UIControlStateNormal];
}

- (void)setEnableNightMask:(BOOL)enableNightMask
{
    if (_enableNightMask != enableNightMask) {
        _enableNightMask = enableNightMask;
        self.nightMask.hidden = !enableNightMask;
    }
}

- (TTNightMaskView *)nightMask
{
    if (!_nightMask) {
        _nightMask = [[TTNightMaskView alloc] initWithFrame:self.bounds];
        _nightMask.enableRounded = self.enableRounded;
        _nightMask.userInteractionEnabled = NO;
        [self addSubview:_nightMask];
        [_nightMask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _nightMask.hidden = YES;
    }
    return _nightMask;
}

- (void)setHighlighted:(BOOL)highlighted
{
    UIColor *backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    if (_enableHighlightAnim) {
        [UIView transitionWithView:self duration:.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (highlighted) {
                self.alpha = 0.5f;
            }
            else{
                self.alpha = 1.f;
            }
        } completion:nil];
    }
}

- (void)setBackgroundColors:(NSArray *)backgroundColors {
    [super setBackgroundColors:backgroundColors];
    self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    [super setBackgroundColorThemeKey:backgroundColorThemeKey];
    self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        self.originNormalImage = image;
    }
    if (self.enableRounded) {
        UIImage *roundedImage = [image imageByRoundCornerRadius:image.size.width / 2 borderWidth:self.borderWidth borderColor:[UIColor tt_themedColorForKey:self.borderColorThemeKey]];
        [super setImage:roundedImage forState:state];
    } else {
        [super setImage:image forState:state];
    }
    if(self.enableNightMask){
        UIImageView* newImageView = [[UIImageView alloc] initWithImage:image];
        newImageView.frame = self.imageView.frame;
        CALayer* layer = newImageView.layer;
        self.nightMask.layer.mask = layer;
    }
}

@end
