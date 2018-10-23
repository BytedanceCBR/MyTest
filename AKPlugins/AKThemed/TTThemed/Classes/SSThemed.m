//
//  SSThemed.m
//  Article
//
//  Created by 苏瑞强 on 17/3/10.
//  Copyright © 2017年 苏瑞强. All rights reserved.
//

#import "SSThemed.h"
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import <objc/runtime.h>
#import "TTUIResponderHelper.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "UITextView+TTAdditions.h"


const int iPadSplitViewLeftSpace = 100;

UIWindow *SSGetMainWindow(void) {
    UIWindow *window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

extern UIColor *SSGetDayColorInThemeArray(NSArray *themeColors) {
    if (themeColors.count == 0) {
        return nil;
    }
    UIColor *dayColor = themeColors[0];
    if (![dayColor isKindOfClass:[UIColor class]]) {
        if ([dayColor isKindOfClass:[NSString class]]) {
            dayColor = [UIColor colorWithHexString:(NSString *)dayColor];
        } else {
            dayColor = nil;
        }
    }
    return dayColor;
}

extern UIColor *SSGetNightColorInThemeArray(NSArray *themeColors) {
    if (themeColors.count <= 1) {
        return SSGetDayColorInThemeArray(themeColors);
    }
    UIColor *nightColor = themeColors[1];
    if (![nightColor isKindOfClass:[UIColor class]]) {
        if ([nightColor isKindOfClass:[NSString class]]) {
            nightColor = [UIColor colorWithHexString:(NSString *)nightColor];
        } else {
            nightColor = nil;
        }
    }
    return nightColor;
}

extern UIColor *SSGetThemedColorInArray(NSArray *themeArray){
    BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
    if (!isDayMode) {
        return SSGetNightColorInThemeArray(themeArray);
    }
    return SSGetDayColorInThemeArray(themeArray);
}

extern UIColor *SSGetThemedColorWithKey(NSString *key) {
    return [UIColor tt_themedColorForKey:key];
}

extern UIColor *SSGetThemedColorUsingArrayOrKey(NSArray *themeArray, NSString *key) {
    if ([themeArray isKindOfClass:[NSArray class]] && themeArray.count > 0) {
        return SSGetThemedColorInArray(themeArray);
    }
    return SSGetThemedColorWithKey(key);
}


@interface UIView (SSThemed)

@property(nonatomic, assign, getter=hasRegisterThemeObserver) BOOL   registerThemeObserver;
@property(nonatomic, assign, getter=hasExchangeInitialMethod) BOOL exchangeInitialMethod;

@end

@implementation UIView (SSThemed)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithFrame:)), class_getInstanceMethod(self, @selector(ss_initWithFrame:)));
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithCoder:)), class_getInstanceMethod(self, @selector(ss_initWithCoder:)));
}

- (instancetype)ss_initWithFrame:(CGRect)frame {
    
    id instance = [self ss_initWithFrame:frame];
    if ([instance respondsToSelector:@selector(ss_didInitialize)]) {
        [instance ss_didInitialize];
    }
    return instance;
}

- (instancetype)ss_initWithCoder:(NSCoder *)coder {
    id instance = [self ss_initWithCoder:coder];
    if ([instance respondsToSelector:@selector(ss_didInitialize)]) {
        [instance ss_didInitialize];
    }
    return instance;
}

- (void)ss_didInitialize {
    
}

static NSString *const SSRegisterThemeObserverKey = @"SSRegisterThemeObserverKey";
- (BOOL)hasRegisterThemeObserver {
    NSNumber *value = objc_getAssociatedObject(self, (__bridge const void *)(SSRegisterThemeObserverKey));
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

- (void)setRegisterThemeObserver:(BOOL)registerThemeObserver {
    objc_setAssociatedObject(self, (__bridge const void *)(SSRegisterThemeObserverKey), @(registerThemeObserver), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static NSString *const SSExchangeInitialMethodKey = @"SSExchangeInitialMethodKey";
- (BOOL)hasExchangeInitialMethod {
    NSNumber *value = objc_getAssociatedObject(self, (__bridge const void *)(SSExchangeInitialMethodKey));
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

- (void)setExchangeInitialMethod:(BOOL)exchangeInitialMethod {
    objc_setAssociatedObject(self, (__bridge const void *)(SSExchangeInitialMethodKey), @(exchangeInitialMethod), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark - SSThemedView
@interface SSThemedView ()

@property (nonatomic,strong) UIView * topSepartorView;
@property (nonatomic,strong) UIView * bottomSepartorView;

@property (nonatomic,strong) UIView * leftSepartorView;
@property (nonatomic,strong) UIView * rightSepartorView;

@end

@implementation SSThemedView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self _customThemeChanged:nil];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (!isEmptyString(_borderColorThemeKey) && !self.separatorAtTOP && !self.separatorAtBottom) {
        self.layer.borderColor = [UIColor tt_themedColorForKey:_borderColorThemeKey].CGColor;
    }
    
    if (SSIsEmptyArray(_backgroundColors) && isEmptyString(_backgroundColorThemeKey)) {
        return;
    }
    self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    
    //nick yu add for top and bottom border (separator)
    if (self.separatorAtTOP && !isEmptyString(self.borderColorThemeKey)) {
        
        if (_topSepartorView == nil) {
            _topSepartorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [TTDeviceHelper ssOnePixel])];
            _topSepartorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:_topSepartorView];
        }
        _topSepartorView.hidden = NO;
        _topSepartorView.backgroundColor = [UIColor tt_themedColorForKey:_borderColorThemeKey];
    }
    
    if (self.separatorAtBottom && !isEmptyString(self.borderColorThemeKey)) {
        
        if (!self.bottomSepartorView) {
            self.bottomSepartorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-[TTDeviceHelper ssOnePixel], self.frame.size.width, [TTDeviceHelper ssOnePixel])];
            self.bottomSepartorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self addSubview:self.bottomSepartorView];
        }
        self.bottomSepartorView.hidden = NO;
        self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.borderColorThemeKey);
    }
    
    if (self.separatorAtLeft && !isEmptyString(self.borderColorThemeKey)) {
        
        if (!self.leftSepartorView) {
            self.leftSepartorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[TTDeviceHelper ssOnePixel], self.frame.size.height)];
            
            [self addSubview:self.leftSepartorView];
        }
        self.leftSepartorView.hidden = NO;
        self.leftSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.borderColorThemeKey);
    }
    
    if (self.separatorAtRight && !isEmptyString(self.borderColorThemeKey)) {
        
        if (!self.rightSepartorView) {
            self.rightSepartorView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-[TTDeviceHelper ssOnePixel],0, [TTDeviceHelper ssOnePixel],self.frame.size.height)];
            [self addSubview:self.rightSepartorView];
        }
        self.rightSepartorView.hidden = NO;
        self.rightSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.borderColorThemeKey);
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

#pragma mark Property
- (void)setSeparatorAtTOP:(BOOL)separatorAtTOP {
    _separatorAtTOP = separatorAtTOP;
    if (!separatorAtTOP) {
        self.topSepartorView.hidden = YES;
    }
}

- (void)setSeparatorAtBottom:(BOOL)separatorAtBottom {
    _separatorAtBottom = separatorAtBottom;
    if (!separatorAtBottom) {
        self.bottomSepartorView.hidden = YES;
    }
}

- (void)setSeparatorAtLeft:(BOOL)separatorAtLeft {
    _separatorAtLeft = separatorAtLeft;
    if (!separatorAtLeft) {
        self.leftSepartorView.hidden = YES;
    }
}

- (void)setSeparatorAtRight:(BOOL)separatorAtRight {
    _separatorAtRight = separatorAtRight;
    if (!separatorAtRight) {
        self.rightSepartorView.hidden = YES;
    }
}

- (void)setBackgroundColors:(NSArray *)backgroundColors {
    if (backgroundColors != _backgroundColors) {
        _backgroundColors = backgroundColors;
        self.backgroundColor = SSGetThemedColorInArray(backgroundColors);
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (backgroundColorThemeKey != _backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.backgroundColor = SSGetThemedColorWithKey(backgroundColorThemeKey);
    }
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey {
    if (borderColorThemeKey != _borderColorThemeKey) {
        _borderColorThemeKey = borderColorThemeKey;
        if (!isEmptyString(self.borderColorThemeKey) && (!self.separatorAtTOP && !self.separatorAtBottom)) {
            self.layer.borderColor = SSGetThemedColorWithKey(self.borderColorThemeKey).CGColor;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.leftSepartorView.frame = CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], self.frame.size.height);
    self.rightSepartorView.frame = CGRectMake(self.frame.size.width - [TTDeviceHelper ssOnePixel], 0, [TTDeviceHelper ssOnePixel], self.frame.size.height);
}

@end

#pragma mark - SSThemedScrollView
@implementation SSThemedScrollView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (!isEmptyString(_backgroundColorThemeKey)) {
        self.backgroundColor = [UIColor tt_themedColorForKey:_backgroundColorThemeKey];
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

#pragma mark <Property>
- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.backgroundColor = [UIColor tt_themedColorForKey:backgroundColorThemeKey];
    }
}

@end

#pragma mark - SSThemedImageView
@interface SSThemedImageView ()

@property (nonatomic,strong) UIView * coverView;

@end
@implementation SSThemedImageView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.imageName = nil;
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)setEnableNightCover:(BOOL)enableNightCover {
    if (_enableNightCover != enableNightCover) {
        _enableNightCover = enableNightCover;
        [self refreshCoverView];
    }
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (self.imageName) {
        if (self.tintColorThemeKey) {
            self.image = [[UIImage themedImageNamed:self.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else {
            self.image = [UIImage themedImageNamed:self.imageName];
        }
    }
    if (self.highlightedImageName) {
        if (self.hightlightedTintColorThemeKey) {
            self.highlightedImage = [[UIImage themedImageNamed:self.highlightedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else {
            self.highlightedImage = [UIImage themedImageNamed:self.highlightedImageName];
        }
    }
    
    [self refreshTintColor];
    [self refreshCoverView];
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (void)refreshCoverView
{
    if (_enableNightCover && [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        if (!_coverView) {
            self.coverView = [[UIView alloc] initWithFrame:self.bounds];
            _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _coverView.backgroundColor = [UIColor colorWithHexString:@"00000099"];
            _coverView.userInteractionEnabled = NO;
            [self addSubview:_coverView];
        }
        _coverView.hidden = NO;
    }
    else {
        _coverView.hidden = YES;
    }
}


- (CGSize)intrinsicContentSize {
    if (self.preferredContentSize.width * self.preferredContentSize.height == 0) {
        return [super intrinsicContentSize];
    }
    return self.preferredContentSize;
}

- (void)setImageName:(NSString *)imageName {
    if (imageName != _imageName) {
        _imageName = imageName;
        if (self.tintColorThemeKey) {
            self.image = [[UIImage themedImageNamed:self.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else {
            self.image = [UIImage themedImageNamed:self.imageName];
        }
        [self refreshTintColor];
    }
}

- (void)setTintColorThemeKey:(NSString *)tintColorThemeKey {
    if (![tintColorThemeKey isEqualToString:_tintColorThemeKey]) {
        _tintColorThemeKey = [tintColorThemeKey copy];
        if (self.image) {
            self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        [self refreshTintColor];
    }
}

- (void)setHighlightedImageName:(NSString *)highlightedImageName {
    if (highlightedImageName != _highlightedImageName) {
        _highlightedImageName = highlightedImageName;
        if (self.hightlightedTintColorThemeKey) {
            self.highlightedImage = [[UIImage themedImageNamed:self.highlightedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else {
            self.highlightedImage = [UIImage themedImageNamed:self.highlightedImageName];
        }
        [self refreshTintColor];
    }
}

- (void)setHighlightedTintColorThemeKey:(NSString *)highlightedTintColorThemeKey {
    if (![highlightedTintColorThemeKey isEqualToString:_hightlightedTintColorThemeKey]) {
        _hightlightedTintColorThemeKey = [highlightedTintColorThemeKey copy];
        if (self.highlightedImage) {
            self.highlightedImage = [self.highlightedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        [self refreshTintColor];
    }
}

- (void)refreshTintColor {
    if (self.isHighlighted && !isEmptyString(_hightlightedTintColorThemeKey)) {
        self.tintColor = [UIColor tt_themedColorForKey:_hightlightedTintColorThemeKey];
    }
    else if (!self.isHighlighted && !isEmptyString(_tintColorThemeKey)) {
        self.tintColor = [UIColor tt_themedColorForKey:_tintColorThemeKey];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self refreshTintColor];
}

@end

#pragma mark - SSThemedTextField
@implementation SSThemedTextField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.keyboardAppearance = UIKeyboardAppearanceLight;
        } else {
            self.keyboardAppearance = UIKeyboardAppearanceDark;
        }
    }
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (!isEmptyString(_backgroundColorThemeKey)) {
        self.backgroundColor = [UIColor tt_themedColorForKey:_backgroundColorThemeKey];
    }
    if (!isEmptyString(_textColorThemeKey)) {
        self.textColor = [UIColor tt_themedColorForKey:_textColorThemeKey];
    }
    if (!isEmptyString(_borderColorThemeKey)) {
        self.layer.borderColor = [UIColor tt_themedColorForKey:_borderColorThemeKey].CGColor;
    }
    
    if (!isEmptyString(self.placeholder) && !isEmptyString(_placeholderColorThemeKey)) {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes setValue:[UIColor tt_themedColorForKey:_placeholderColorThemeKey] forKey:NSForegroundColorAttributeName];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (void)setTextColorThemeKey:(NSString *)textColorThemeKey {
    if (_textColorThemeKey != textColorThemeKey) {
        _textColorThemeKey = textColorThemeKey;
        self.textColor = [UIColor tt_themedColorForKey:textColorThemeKey];
    }
}

- (void)setPlaceholderColorThemeKey:(NSString *)placeholderColorThemeKey {
    if (_placeholderColorThemeKey != placeholderColorThemeKey) {
        _placeholderColorThemeKey = placeholderColorThemeKey;
        if (!isEmptyString(self.placeholder) && !isEmptyString(_placeholderColorThemeKey)) {
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            [attributes setValue:[UIColor tt_themedColorForKey:_placeholderColorThemeKey] forKey:NSForegroundColorAttributeName];
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
        }
    }
}

- (void)setPlaceholderAttributedDict:(NSDictionary *)placeholderAttributedDict
{
    _placeholderAttributedDict = placeholderAttributedDict;
    if (SSIsEmptyDictionary(placeholderAttributedDict)) {
        self.attributedPlaceholder = nil;
    } else if(!isEmptyString(self.placeholder)){
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:placeholderAttributedDict];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    if (self.placeholder != placeholder) {
        [super setPlaceholder:placeholder];
        if (!isEmptyString(placeholder) && !isEmptyString(_placeholderColorThemeKey)) {
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            [attributes setValue:[UIColor tt_themedColorForKey:_placeholderColorThemeKey] forKey:NSForegroundColorAttributeName];
            self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
        }
        if (!SSIsEmptyDictionary(_placeholderAttributedDict)) {
            //触发富文本
            self.placeholderAttributedDict = _placeholderAttributedDict;
        }
    }
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey {
    if (_borderColorThemeKey != borderColorThemeKey) {
        _borderColorThemeKey = borderColorThemeKey;
        self.layer.borderColor = [UIColor tt_themedColorForKey:borderColorThemeKey].CGColor;
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.backgroundColor = [UIColor tt_themedColorForKey:backgroundColorThemeKey];
    }
}

@end

#pragma mark - SSThemedTextView
@implementation SSThemedTextView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidBeginEditing:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidEndEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.keyboardAppearance = UIKeyboardAppearanceLight;
        } else {
            self.keyboardAppearance = UIKeyboardAppearanceDark;
        }
    }
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (!isEmptyString(_backgroundColorThemeKey)) {
        self.backgroundColor = [UIColor tt_themedColorForKey:_backgroundColorThemeKey];
    }
    if (!isEmptyString(_textColorThemeKey)) {
        self.textColor = [UIColor tt_themedColorForKey:_textColorThemeKey];
    }
    if ([self respondsToSelector:@selector(setPlaceHolderColor:)] && !isEmptyString(_placeholderColorThemeKey)) {
        self.placeHolderColor = [UIColor tt_themedColorForKey:_placeholderColorThemeKey];
    }
    if (!isEmptyString(_borderColorThemeKey)) {
        self.layer.borderColor = [UIColor tt_themedColorForKey:_borderColorThemeKey].CGColor;
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self showOrHidePlaceHolderTextView];
}

- (void)textDidBeginEditing:(id)notification {
    [self showOrHidePlaceHolderTextView];
}

- (void)textDidEndEditing:(id)notification {
    [self showOrHidePlaceHolderTextView];
}

- (void)textDidChanged:(id)notification {
    [self showOrHidePlaceHolderTextView];
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey {
    if (_borderColorThemeKey != borderColorThemeKey) {
        _borderColorThemeKey = borderColorThemeKey;
        self.layer.borderColor = [UIColor tt_themedColorForKey:borderColorThemeKey].CGColor;
    }
}

- (void)setTextColorThemeKey:(NSString *)textColorThemeKey {
    if (_textColorThemeKey != textColorThemeKey) {
        _textColorThemeKey = textColorThemeKey;
        self.textColor = [UIColor tt_themedColorForKey:textColorThemeKey];
    }
}

- (void)setPlaceholderColorThemeKey:(NSString *)placeholderColorThemeKey {
    if (_placeholderColorThemeKey != placeholderColorThemeKey) {
        _placeholderColorThemeKey = placeholderColorThemeKey;
        if ([self respondsToSelector:@selector(setPlaceHolderColor:)]) {
            self.placeHolderColor = [UIColor tt_themedColorForKey:_placeholderColorThemeKey];
        }
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.backgroundColor = [UIColor tt_themedColorForKey:backgroundColorThemeKey];
    }
}

@end

#pragma mark - SSThemedLabel
NSString * const kSSThemedLabelText = @"kSSThemedLabelText";

@implementation SSThemedLabel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    self.verticalAlignment = ArticleVerticalAlignmentMiddle;
}

- (void)setVerticalAlignment:(ArticleVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect newBounds = bounds;
    newBounds.origin.y += self.contentInset.top;
    newBounds.size.height -= (self.contentInset.top + self.contentInset.bottom);
    newBounds.origin.x += self.contentInset.left;
    newBounds.size.width -= (self.contentInset.left + self.contentInset.right);
    
    CGRect rect = [super textRectForBounds:newBounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case ArticleVerticalAlignmentTop:
            rect.origin.y = bounds.origin.y + self.contentInset.top;
            break;
        case ArticleVerticalAlignmentBottom:
            rect.origin.y = CGRectGetMaxY(bounds) - self.contentInset.bottom - rect.size.height;
            break;
        default:
            rect.origin.y = (CGRectGetHeight(bounds) - self.contentInset.bottom - CGRectGetHeight(rect)) / 2;
            break;
    }
    switch (self.textAlignment) {
        case NSTextAlignmentLeft:
            rect.origin.x = bounds.origin.x + self.contentInset.left;
            break;
        case NSTextAlignmentRight:
            rect.origin.x = CGRectGetMaxX(bounds) - self.contentInset.right - rect.size.width;
            break;
        case NSTextAlignmentCenter:
            rect.origin.x = (CGRectGetWidth(bounds) + self.contentInset.left - self.contentInset.right - CGRectGetWidth(rect)) / 2;
            break;
        default:
            break;
    }
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect textRect = CGRectZero;
    if (self.verticalAlignment == ArticleVerticalAlignmentMiddle && UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero)) {
        //如果和UILabel的默认对齐方式一致，则不需要重复计算textRectForBounds
        textRect = rect;
    }
    else {
        textRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    }
    [super drawTextInRect:textRect];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (self.textColors.count > 0 || !isEmptyString(self.textColorThemeKey)) {
        self.textColor = SSGetThemedColorUsingArrayOrKey(self.textColors, self.textColorThemeKey);
        self.highlightedTextColor = SSGetThemedColorWithKey([NSString stringWithFormat:@"%@Disabled", self.textColorThemeKey]);
    }
    if (self.backgroundColors.count > 0 || !isEmptyString(self.backgroundColorThemeKey)) {
        self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    }
    
    if (self.borderColors.count > 0 || !isEmptyString(self.borderColorThemeKey)) {
        self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey).CGColor;
    }
    
    if (self.attributedTextInfo) {
        [self setupAttributedText];
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (void)setAttributedTextInfo:(NSDictionary *)attributedTextInfo {
    if (_attributedTextInfo != attributedTextInfo) {
        _attributedTextInfo = attributedTextInfo;
        [self setupAttributedText];
    }
}

- (void)setupAttributedText
{
    if (!_attributedTextInfo) {
        return;
    }
    
    id value = _attributedTextInfo[kSSThemedLabelText];
    NSMutableAttributedString *attributedString = nil;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *text = (NSString *)value;
        if (isEmptyString(text)) {
            return;
        }
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    } else if ([value isKindOfClass:[NSAttributedString class]]){
        NSAttributedString *text = (NSAttributedString *)value;
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
    } else {
        return;
    }
    
    [_attributedTextInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        if (![key isEqualToString:kSSThemedLabelText]) {
            NSRange range = NSRangeFromString(key);
            [attributedString addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(value) range:range];
        }
    }];
    self.attributedText = attributedString;
    // [self setNeedsDisplay];
}

- (void)setTextColors:(NSArray *)textColors {
    if (_textColors != textColors) {
        _textColors = textColors;
        self.textColor = SSGetThemedColorUsingArrayOrKey(self.textColors, self.textColorThemeKey);
        self.highlightedTextColor = SSGetThemedColorWithKey([NSString stringWithFormat:@"%@Disabled", self.textColorThemeKey]);
    }
}

- (void)setTextColorThemeKey:(NSString *)textColorThemeKey {
    if (_textColorThemeKey != textColorThemeKey) {
        _textColorThemeKey = textColorThemeKey;
        self.textColor = SSGetThemedColorUsingArrayOrKey(self.textColors, self.textColorThemeKey);
        self.highlightedTextColor = SSGetThemedColorWithKey([NSString stringWithFormat:@"%@Disabled", self.textColorThemeKey]);
    }
}

- (void)setBackgroundColors:(NSArray *)backgroundColors {
    if (_backgroundColors != backgroundColors) {
        _backgroundColors = backgroundColors;
        self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    }
}

- (void)setBorderColors:(NSArray *)borderColors {
    if (_borderColors != borderColors) {
        _borderColors = borderColors;
        self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey).CGColor;
    }
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey {
    if (_borderColorThemeKey != borderColorThemeKey) {
        _borderColorThemeKey = borderColorThemeKey;
        self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey).CGColor;
    }
}

@end

#pragma mark - SSThemedButton
@interface SSThemedButton () {
    UIColor *_privateBackgroundColor;
}

@end

@implementation SSThemedButton

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    UIColor *titleColor = SSGetThemedColorUsingArrayOrKey(self.titleColors, self.titleColorThemeKey);
    UIColor *highlightedColor = SSGetThemedColorUsingArrayOrKey(self.highlightedTitleColors, self.highlightedTitleColorThemeKey);
    UIColor *selectedColor = [UIColor tt_themedColorForKey:self.selectedTitleColorThemeKey];
    UIColor *disabledColor = [UIColor tt_themedColorForKey:self.disabledTitleColorThemeKey];
    UIColor *borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey);
    if (titleColor) {
        [self setTitleColor:titleColor forState:UIControlStateNormal];
    }
    if (highlightedColor) {
        [self setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    }
    if (selectedColor) {
        [self setTitleColor:selectedColor forState:UIControlStateSelected];
    }
    if (disabledColor) {
        [self setTitleColor:disabledColor forState:UIControlStateDisabled];
    }
    if (borderColor) {
        self.layer.borderColor = borderColor.CGColor;
    }
    if (self.imageName) {
        if (self.tintColorThemeKey) {
            [self setImage:[[UIImage themedImageNamed:self.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
        else {
            [self setImage:[UIImage themedImageNamed:self.imageName] forState:UIControlStateNormal];
        }
    }
    if (self.selectedImageName) {
        if (self.selectedTintColorThemeKey) {
            [self setImage:[[UIImage themedImageNamed:self.selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        }
        else {
            [self setImage:[UIImage themedImageNamed:self.selectedImageName] forState:UIControlStateSelected];
        }
    }
    if (self.highlightedImageName) {
        if (self.highlightedTintColorThemeKey) {
            [self setImage:[[UIImage themedImageNamed:self.highlightedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        }
        else {
            [self setImage:[UIImage themedImageNamed:self.highlightedImageName] forState:UIControlStateHighlighted];
        }
    }
    if (self.backgroundImageName) {
        [self setBackgroundImage:[UIImage themedImageNamed:self.backgroundImageName] forState:UIControlStateNormal];
    }
    if (self.highlightedBackgroundImageName) {
        [self setBackgroundImage:[UIImage themedImageNamed:self.highlightedBackgroundImageName] forState:UIControlStateHighlighted];
    }
    /// 需要重新设置borderColor
    self.enabled = self.enabled;
    /// 重新设置背景颜色
    self.highlighted = self.highlighted;
    
    [self refreshTintColor];
    
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _privateBackgroundColor = backgroundColor;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
}

- (CGSize)intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    
    return CGSizeMake(s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if ((self.highlightedBackgroundColors.count > 0 || !isEmptyString(self.highlightedBackgroundColorThemeKey)) && highlighted) {
        super.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.highlightedBackgroundColors, self.highlightedBackgroundColorThemeKey);
    } else {
        if ((self.disabledBackgroundColors.count > 0 || !isEmptyString(self.disabledBackgroundColorThemeKey)) && !self.enabled) {
            super.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.disabledBackgroundColors, self.disabledBackgroundColorThemeKey);
        } else if (self.backgroundColors.count > 0 || !isEmptyString(self.backgroundColorThemeKey)) {
            super.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
        } else {
            super.backgroundColor = _privateBackgroundColor;
        }
    }
    
    if (self.enabled) {
        if ((self.highlightedBorderColors.count > 0 || !isEmptyString(self.highlightedBorderColorThemeKey)) && highlighted) {
            self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.highlightedBorderColors, self.highlightedBorderColorThemeKey).CGColor;
        } else {
            self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey).CGColor;
        }
    } else {
        if (self.disabledBorderColorThemeKey) {
            self.layer.borderColor = [UIColor tt_themedColorForKey:self.disabledBorderColorThemeKey].CGColor;
        } else {
            self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey).CGColor;
        }
    }
    
    for (UIView *subview in self.subviews) {
        if ([subview respondsToSelector:@selector(setHighlighted:)]) {
            [subview setValue:@(highlighted) forKey:@"highlighted"];
        }
    }
    
    [self refreshTintColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self refreshTintColor];
}

- (void)setTitleColors:(NSArray *)titleColors {
    if (_titleColors != titleColors) {
        _titleColors = titleColors;
        [self setTitleColor:SSGetThemedColorUsingArrayOrKey(self.titleColors, self.titleColorThemeKey) forState:UIControlStateNormal];
    }
}

- (void)setTitleColorThemeKey:(NSString *)titleColorThemeKey {
    if (_titleColorThemeKey != titleColorThemeKey) {
        _titleColorThemeKey = titleColorThemeKey;
        [self setTitleColor:SSGetThemedColorUsingArrayOrKey(self.titleColors, self.titleColorThemeKey) forState:UIControlStateNormal];
    }
}

- (void)setHighlightedTitleColors:(NSArray *)highlightedTitleColors {
    if (_highlightedTitleColors != highlightedTitleColors) {
        _highlightedTitleColors = highlightedTitleColors;
        [self setTitleColor:SSGetThemedColorUsingArrayOrKey(self.highlightedTitleColors, self.highlightedTitleColorThemeKey) forState:UIControlStateHighlighted];
    }
}

- (void)setHighlightedTitleColorThemeKey:(NSString *)highlightedTitleColorThemeKey {
    if (_highlightedTitleColorThemeKey != highlightedTitleColorThemeKey) {
        _highlightedTitleColorThemeKey = highlightedTitleColorThemeKey;
        [self setTitleColor:SSGetThemedColorUsingArrayOrKey(self.highlightedTitleColors, self.highlightedTitleColorThemeKey) forState:UIControlStateHighlighted];
    }
}

- (void)setSelectedTitleColorThemeKey:(NSString *)selectedTitleColorThemeKey {
    if (_selectedTitleColorThemeKey != selectedTitleColorThemeKey) {
        _selectedTitleColorThemeKey = selectedTitleColorThemeKey;
        [self setTitleColor:[UIColor tt_themedColorForKey:selectedTitleColorThemeKey] forState:UIControlStateSelected];
    }
}

- (void)setDisabledTitleColorThemeKey:(NSString *)disabledTitleColorThemeKey {
    if (_disabledTitleColorThemeKey != disabledTitleColorThemeKey) {
        _disabledTitleColorThemeKey = disabledTitleColorThemeKey;
        [self setTitleColor:[UIColor tt_themedColorForKey:disabledTitleColorThemeKey] forState:UIControlStateDisabled];
    }
}

- (void)setBorderColors:(NSArray *)borderColors {
    if (_borderColors != borderColors) {
        _borderColors = borderColors;
        self.enabled = self.enabled;
    }
}

- (void)setBorderColorThemeKey:(NSString *)borderColorThemeKey {
    if (_borderColorThemeKey != borderColorThemeKey) {
        _borderColorThemeKey = borderColorThemeKey;
        self.enabled = self.enabled;
    }
}

- (void)setDisabledBorderColorThemeKey:(NSString *)disabledBorderColorThemeKey {
    if (_disabledBorderColorThemeKey != disabledBorderColorThemeKey) {
        _disabledBorderColorThemeKey = disabledBorderColorThemeKey;
        self.enabled = self.enabled;
    }
}

- (void)setHighlightedBorderColors:(NSArray *)highlightedBorderColors {
    if (_highlightedBorderColors != highlightedBorderColors) {
        _highlightedBorderColors = highlightedBorderColors;
        self.enabled = self.enabled;
    }
}

- (void)setHighlightedBorderColorThemeKey:(NSString *)highlightedBorderColorThemeKey {
    if (_highlightedBorderColorThemeKey != highlightedBorderColorThemeKey) {
        _highlightedBorderColorThemeKey = highlightedBorderColorThemeKey;
        self.enabled = self.enabled;
    }
}

- (void)setBackgroundColors:(NSArray *)backgroundColors {
    if (_backgroundColors != backgroundColors) {
        _backgroundColors = backgroundColors;
        self.highlighted = self.highlighted;
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.highlighted = self.highlighted;
    }
}

- (void)setDisabledBackgroundColors:(NSArray *)disabledBackgroundColors {
    if (_disabledBackgroundColors != disabledBackgroundColors) {
        _disabledBackgroundColors = disabledBackgroundColors;
        self.highlighted = self.highlighted;
    }
}

- (void)setDisabledBackgroundColorThemeKey:(NSString *)disabledBackgroundColorThemeKey {
    if (_disabledBackgroundColorThemeKey != disabledBackgroundColorThemeKey) {
        _disabledBackgroundColorThemeKey = disabledBackgroundColorThemeKey;
        self.highlighted = self.highlighted;
    }
}

- (void)setHighlightedBackgroundColors:(NSArray *)highlightedBackgroundColors {
    if (_highlightedBackgroundColors != highlightedBackgroundColors) {
        _highlightedBackgroundColors = highlightedBackgroundColors;
        self.highlighted = self.highlighted;
    }
}

- (void)setHighlightedBackgroundColorThemeKey:(NSString *)highlightedBackgroundColorThemeKey {
    if (_highlightedBackgroundColorThemeKey != highlightedBackgroundColorThemeKey) {
        _highlightedBackgroundColorThemeKey = highlightedBackgroundColorThemeKey;
        self.highlighted = self.highlighted;
    }
}

- (void)setImageName:(NSString *)imageName {
    if (_imageName != imageName) {
        _imageName = imageName;
        if (self.tintColorThemeKey) {
            [self setImage:[[UIImage themedImageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        }
        else {
            [self setImage:[UIImage themedImageNamed:imageName] forState:UIControlStateNormal];
        }
        [self refreshTintColor];
    }
}

- (void)setSelectedImageName:(NSString *)selectedImageName {
    if (_selectedImageName != selectedImageName) {
        _selectedImageName = selectedImageName;
        if (self.selectedTintColorThemeKey) {
            [self setImage:[[UIImage themedImageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        }
        else {
            [self setImage:[UIImage themedImageNamed:selectedImageName] forState:UIControlStateSelected];
        }
        [self refreshTintColor];
    }
}

- (void)setHighlightedImageName:(NSString *)highlightedImageName {
    if (_highlightedImageName != highlightedImageName) {
        _highlightedImageName = highlightedImageName;
        if (self.highlightedTintColorThemeKey) {
            [self setImage:[[UIImage themedImageNamed:highlightedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        }
        else {
            [self setImage:[UIImage themedImageNamed:highlightedImageName] forState:UIControlStateHighlighted];
        }
        [self refreshTintColor];
    }
}

- (void)setBackgroundImageName:(NSString *)backgroundImageName {
    if (_backgroundImageName != backgroundImageName) {
        _backgroundImageName = backgroundImageName;
        [self setBackgroundImage:[UIImage themedImageNamed:backgroundImageName] forState:UIControlStateNormal];
    }
}

- (void)setHighlightedBackgroundImageName:(NSString *)highlightedBackgroundImageName {
    if (_highlightedBackgroundImageName != highlightedBackgroundImageName) {
        _highlightedBackgroundImageName = highlightedBackgroundImageName;
        [self setBackgroundImage:[UIImage themedImageNamed:highlightedBackgroundImageName] forState:UIControlStateHighlighted];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if ((!isEmptyString(self.disabledBorderColorThemeKey)) && !enabled) {
        self.layer.borderColor = [UIColor tt_themedColorForKey:self.disabledBorderColorThemeKey].CGColor;
    } else {
        self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(self.borderColors, self.borderColorThemeKey).CGColor;
    }
    
    if ((self.disabledBackgroundColors.count > 0 || !isEmptyString(self.disabledBackgroundColorThemeKey)) && !enabled) {
        super.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.disabledBackgroundColors, self.disabledBackgroundColorThemeKey);
    } else if (self.backgroundColors.count > 0 || !isEmptyString(self.backgroundColorThemeKey)) {
        super.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    } else {
        super.backgroundColor = _privateBackgroundColor;
    }
}

- (void)refreshTintColor {
    if (self.highlighted && !isEmptyString(self.highlightedTintColorThemeKey)) {
        self.tintColor = [UIColor tt_themedColorForKey:self.highlightedTintColorThemeKey];
    }
    else if (self.selected && !isEmptyString(self.selectedTintColorThemeKey)) {
        self.tintColor = [UIColor tt_themedColorForKey:self.selectedTintColorThemeKey];
    }
    else if (!self.selected && !self.highlighted && !isEmptyString(self.tintColorThemeKey)) {
        self.tintColor = [UIColor tt_themedColorForKey:self.tintColorThemeKey];
    }
}

- (void)setTintColorThemeKey:(NSString *)TintColorThemeKey {
    if (![TintColorThemeKey isEqualToString:_tintColorThemeKey]) {
        _tintColorThemeKey = TintColorThemeKey;
        UIImage *image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forState:UIControlStateNormal];
        [self refreshTintColor];
    }
}

- (void)setSelectedTintColorThemeKey:(NSString *)selectedTintColorThemeKey {
    if (![selectedTintColorThemeKey isEqualToString:_selectedTintColorThemeKey]) {
        _selectedTintColorThemeKey = selectedTintColorThemeKey;
        UIImage *image = [[self imageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forState:UIControlStateSelected];
        [self refreshTintColor];
    }
}

- (void)setHighlightedTintColorThemeKey:(NSString *)highlightedTintColorThemeKey {
    if (![highlightedTintColorThemeKey isEqualToString:_highlightedTintColorThemeKey]) {
        _highlightedTintColorThemeKey = highlightedTintColorThemeKey;
        UIImage *image = [[self imageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forState:UIControlStateHighlighted];
        [self refreshTintColor];
    }
}

@end

#pragma mark - SSThemedTableView
@implementation SSThemedTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.estimatedRowHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.insetsContentViewsToSafeArea = NO;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.estimatedRowHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.insetsContentViewsToSafeArea = NO;
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if (self.backgroundColors.count > 0 || !isEmptyString(self.backgroundColorThemeKey)) {
        self.backgroundColor = SSGetThemedColorUsingArrayOrKey(self.backgroundColors, self.backgroundColorThemeKey);
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (void)setBackgroundColors:(NSArray *)backgroundColors {
    if (_backgroundColors != backgroundColors) {
        _backgroundColors = backgroundColors;
        self.backgroundColor = SSGetThemedColorUsingArrayOrKey(_backgroundColors, _backgroundColorThemeKey);
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.backgroundColor = SSGetThemedColorUsingArrayOrKey(_backgroundColors, _backgroundColorThemeKey);
    }
}

@end

@implementation TTThemedSplitView

- (void)_addContentView
{
    self.contentView = [[SSThemedView alloc] initWithFrame:self.bounds];
    [self addSubview:self.contentView];
}

- (void)_commonInit
{
    self.needMargin = YES;
    [self _addContentView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.needMargin) {
        CGRect rect = self.frame;
        rect.origin.y = 0;
        rect.size.height = CGRectGetHeight(self.frame);
        self.contentView.frame = rect;
    }
    
    
}
@end

@interface SSThemedTableViewCell ()

@property (nonatomic,strong) UIView * selectedContentView;
@property (nonatomic,strong) UIView * separtorView;
@property (nonatomic,strong) UIView * bottomSepartorView;

@end

@implementation  SSThemedTableViewCell

// 兼容项目中cell的父类从原SSUITableViewCellBase变为此类，增加默认背景色为clearColor的逻辑
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    
    if (!isEmptyString(self.backgroundColorThemeKey)) {
        self.contentView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundColorThemeKey);
        self.backgroundColor = self.contentView.backgroundColor;
    }
    
    if (!isEmptyString(self.backgroundSelectedColorThemeKey)) {
        self.selectedContentView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundSelectedColorThemeKey);
    }
    
    if(!self.tableView.enableTTStyledSeparator) {
        if (!isEmptyString(self.separatorColorThemeKey)) {
            
            self.separtorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.separatorColorThemeKey);
            self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.separatorColorThemeKey);
        }
    }
    if ([self respondsToSelector:@selector(themeChanged:)]) {
        [self performSelector:@selector(themeChanged:) withObject:notification];
    }
}

- (UIView *)selectedContentView {
    if (_selectedContentView == nil) {
        _selectedContentView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _selectedContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self.contentView insertSubview:_selectedContentView atIndex:0];
    }
    return _selectedContentView;
}

- (void)themeChanged:(NSNotification*)notification {
    //sub class reload
}

- (void)setSeparatorAtTOP:(BOOL)separatorAtTOP{
    _separatorAtTOP = separatorAtTOP;
    if (!separatorAtTOP) {
        self.separtorView.hidden = YES;
    }
}

- (void)setSeparatorAtBottom:(BOOL)separatorAtBottom{
    _separatorAtBottom = separatorAtBottom;
    if (!separatorAtBottom) {
        self.bottomSepartorView.hidden = YES;
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (nil == self.selectedContentView) {
        [super setSelected:selected animated:animated];
    }
    else {
        [self showSelected:selected animation:animated];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self showSelected:highlighted animation:animated];
    if (nil == self.selectedContentView) {
        [super setHighlighted:highlighted animated:animated];
    }
    else {
        [self showSelected:highlighted animation:animated];
    }
}

-(void)showSelected:(BOOL)selected animation:(BOOL)animation{
    if (selected != self.selectedContentView.hidden) {
        return;
    }
    if (animation) {
        if (selected) {
            self.selectedContentView.alpha = 0;
            self.selectedContentView.hidden = !selected;
            [UIView animateWithDuration:0.25 animations:^{
                self.selectedContentView.alpha = 1;
            }];
        }else {
            self.selectedContentView.alpha = 1;
            self.selectedContentView.hidden = NO;
            [UIView animateWithDuration:0.25 animations:^{
                self.selectedContentView.alpha = 0;
            }completion:^(BOOL finished) {
                self.selectedContentView.hidden = !selected;
            }];
        }
    }else {
        if (selected) {
            self.selectedContentView.alpha = 1;
            self.selectedContentView.hidden = !selected;
        }else {
            self.selectedContentView.alpha = 0;
            self.selectedContentView.hidden = !selected;
        }
    }
}

- (void)fixIOS9BugOnIPad
{
    if ([TTDeviceHelper isPadDevice] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {//在iPad上 ios9的bug,accessoryView的frame不对
        
        int space = 20;
        CGRect frame = self.accessoryView.frame;
        frame.origin.x = self.frame.size.width - space - frame.size.width;
        self.accessoryView.frame = frame;
        
        if (self.accessoryView) {
            
            CGRect frame = self.detailTextLabel.frame;
            frame.origin.x = self.accessoryView.frame.origin.x - space - frame.size.width;
            self.detailTextLabel.frame = frame;
        }
        else
        {
            CGRect frame = self.detailTextLabel.frame;
            frame.origin.x = self.frame.size.width - space - frame.size.width;
            self.detailTextLabel.frame = frame;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self fixIOS9BugOnIPad];
    if(self.tableView.enableTTStyledSeparator){
        if (!self.separtorView) {
            self.separtorView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, self.frame.size.width, [TTDeviceHelper ssOnePixel])];
            self.separtorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
            self.separtorView.hidden = YES;
            [self.contentView addSubview:self.separtorView];
        }
        
        if (!self.bottomSepartorView) {
            self.bottomSepartorView = [[UIView alloc] initWithFrame:CGRectMake(0,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width, [TTDeviceHelper ssOnePixel])];
            self.bottomSepartorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            self.bottomSepartorView.hidden = YES;
            [self.contentView addSubview:self.bottomSepartorView];
            
        }
        if ([self.tableView numberOfRowsInSection:self.cellIndex.section] == 1 && !self.tableView.disableTTStyledSeparatorEdge){
            
            self.separtorView.hidden = NO;
            self.separtorView.backgroundColor = [UIColor redColor];
            self.separtorView.frame = CGRectMake(0, 0, self.frame.size.width, [TTDeviceHelper ssOnePixel]);
            self.bottomSepartorView.hidden = NO;
            self.bottomSepartorView.frame = CGRectMake(0,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width, [TTDeviceHelper ssOnePixel]);
            self.separtorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.tableView.separatorColorThemeKey);
            self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.tableView.separatorColorThemeKey);
        }
        else {
            if (self.cellIndex.row == 0) {
                self.separtorView.hidden = self.tableView.disableTTStyledSeparatorEdge;
                self.separtorView.backgroundColor = [UIColor redColor];
                self.separtorView.frame = CGRectMake(0,  0, self.frame.size.width, [TTDeviceHelper ssOnePixel]);
                self.bottomSepartorView.hidden = NO;
                self.bottomSepartorView.frame = CGRectMake(self.tableView.separatorInsetLeft,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width-self.tableView.separatorInsetLeft, [TTDeviceHelper ssOnePixel]);
                self.separtorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.tableView.separatorColorThemeKey);
                self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.tableView.separatorSecondColorThemeKey);
            }
            if (self.cellIndex.row >0 ) {
                self.separtorView.hidden = YES;
                self.bottomSepartorView.hidden = NO;
                self.bottomSepartorView.frame = CGRectMake(self.tableView.separatorInsetLeft,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width-self.tableView.separatorInsetLeft, [TTDeviceHelper ssOnePixel]);
                self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.tableView.separatorSecondColorThemeKey);
            }
            if (self.cellIndex.row == [self.tableView numberOfRowsInSection:self.cellIndex.section]-1) {
                self.separtorView.hidden = YES;
                self.bottomSepartorView.hidden = self.tableView.disableTTStyledSeparatorEdge;
                self.bottomSepartorView.frame = CGRectMake(0,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width, [TTDeviceHelper ssOnePixel]);
                self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.tableView.separatorColorThemeKey);
            }
        }
    }
    else {
        if (!isEmptyString(self.separatorColorThemeKey)) {
            
            if (self.separatorAtTOP) {
                if (!self.separtorView) {
                    self.separtorView = [[UIView alloc] initWithFrame:CGRectMake(self.separatorThemeInsetLeft,  0, self.frame.size.width - self.separatorThemeInsetLeft -self.separatorThemeInsetRight, [TTDeviceHelper ssOnePixel])];
                    [self.contentView addSubview:self.separtorView];
                }
                self.separtorView.frame = CGRectMake(self.separatorThemeInsetLeft,  0, self.frame.size.width - self.separatorThemeInsetLeft -self.separatorThemeInsetRight, [TTDeviceHelper ssOnePixel]);
            }
            if (self.separatorAtBottom) {
                if (!self.bottomSepartorView) {
                    self.bottomSepartorView = [[UIView alloc] initWithFrame:CGRectMake(self.separatorThemeInsetLeft,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width - self.separatorThemeInsetLeft - self.separatorThemeInsetRight, [TTDeviceHelper ssOnePixel])];
                    [self.contentView addSubview:self.bottomSepartorView];
                }
                self.bottomSepartorView.frame = CGRectMake(self.separatorThemeInsetLeft,   self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width - self.separatorThemeInsetLeft - self.separatorThemeInsetRight, [TTDeviceHelper ssOnePixel]);
            }
            self.separtorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.separatorColorThemeKey);
            self.bottomSepartorView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.separatorColorThemeKey);
        }
    }
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.contentView.backgroundColor = [UIColor tt_themedColorForKey:backgroundColorThemeKey];
        self.backgroundColor = self.contentView.backgroundColor;
    }
}

- (void)setBackgroundSelectedColorThemeKey:(NSString *)backgroundSelectedColorThemeKey {
    if (_backgroundSelectedColorThemeKey != backgroundSelectedColorThemeKey) {
        _backgroundSelectedColorThemeKey = backgroundSelectedColorThemeKey;
        self.selectedContentView.backgroundColor = [UIColor tt_themedColorForKey:backgroundSelectedColorThemeKey];
    }
}

- (void)setSeparatorColorThemeKey:(NSString *)separatorColorThemeKey {
    if (_separatorColorThemeKey != separatorColorThemeKey) {
        _separatorColorThemeKey = separatorColorThemeKey;
        if (!self.tableView.enableTTStyledSeparator) {
            self.separtorView.backgroundColor = [UIColor tt_themedColorForKey:separatorColorThemeKey];
            self.bottomSepartorView.backgroundColor = self.separtorView.backgroundColor;
        }
    }
}

@end

@implementation UIResponder (SSNextResponder)

- (UIResponder *)ss_nextResponderWithClass:(Class)aClass {
    UIResponder *nextResponder = self;
    while (nextResponder) {
        nextResponder = nextResponder.nextResponder;
        if ([nextResponder isKindOfClass:aClass]) {
            return nextResponder;
        }
    }
    return nil;
}

@end
