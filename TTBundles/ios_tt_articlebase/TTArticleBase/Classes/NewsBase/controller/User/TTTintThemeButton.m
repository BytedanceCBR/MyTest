//
//  TTTintThemeButton.m
//  Article
//
//  Created by 王双华 on 15/8/26.
//
//

#import "TTTintThemeButton.h"
#import "UIImageAdditions.h"
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@interface TTTintThemeButton ()
@property (nonatomic, assign) UIControlState controlState;
@end

@implementation TTTintThemeButton

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
    UIColor *imageColor = nil;
    if (self.controlState == UIControlStateSelected) {
        imageColor = SSGetThemedColorUsingArrayOrKey(self.selectedImageColors, self.selectedImageColorThemeKey);
    }
    else if (self.controlState == UIControlStateDisabled) {
        imageColor = SSGetThemedColorUsingArrayOrKey(self.disabledImageColors, self.disabledImageColorThemeKey);
    }
    else{
        imageColor = SSGetThemedColorUsingArrayOrKey(self.imageColors, self.imageColorThemeKey);
    }
    
    if (imageColor) {
        [self setTintColor:imageColor];
    }
}

- (void)setImageColorThemeKey:(NSString *)imageColorThemeKey
{
    if (_imageColorThemeKey != imageColorThemeKey) {
        _imageColorThemeKey = imageColorThemeKey;
        [self themeChanged:nil];
    }
}

- (void)setSelectedImageColorThemeKey:(NSString *)selectedImageColorThemeKey
{
    if (_selectedImageColorThemeKey != selectedImageColorThemeKey){
        _selectedImageColorThemeKey = selectedImageColorThemeKey;
        [self themeChanged:nil];
    }
}

- (void)setDisabledImageColorThemeKey:(NSString *)disabledImageColorThemeKey
{
    if (_disabledImageColorThemeKey != disabledImageColorThemeKey) {
        _disabledImageColorThemeKey = disabledImageColorThemeKey;
        [self themeChanged:nil];
    }
}

- (void)setImageColors:(NSArray *)imageColors
{
    if (_imageColors != imageColors) {
        _imageColors = imageColors;
        [self themeChanged:nil];
    }
}

- (void)setSelectedImageColors:(NSArray *)selectedImageColors
{
    if (_selectedImageColors != selectedImageColors) {
        _selectedImageColors = selectedImageColors;
        [self themeChanged:nil];
    }
}

- (void)setDisabledImageColors:(NSArray *)disabledImageColors
{
    if (_disabledImageColors != disabledImageColors) {
        _disabledImageColors = disabledImageColors;
        [self themeChanged:nil];
    }
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

- (void)setSelected:(BOOL)selected
{
    if (!self.enabled) {
        self.controlState = UIControlStateDisabled;
    }
    else if(selected) {
        self.controlState = UIControlStateSelected;
    }
    else{
        self.controlState = UIControlStateNormal;
    }
    [super setSelected:selected];
}

- (void)setEnabled:(BOOL)enabled
{
    if (!enabled) {
        self.controlState = UIControlStateDisabled;
    }
    else if(self.selected){
        self.controlState = UIControlStateSelected;
    }
    else{
        self.controlState = UIControlStateNormal;
    }
    [super setEnabled:enabled];
}

- (void)setControlState:(UIControlState)controlState
{
    if (_controlState != controlState){
        _controlState = controlState;
        [self themeChanged:nil];
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
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [super setImage:image forState:state];
    [self themeChanged:nil];
}

@end
