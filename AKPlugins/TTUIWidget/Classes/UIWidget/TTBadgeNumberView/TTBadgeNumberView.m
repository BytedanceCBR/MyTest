//
//  TTBadgeNumberView.m
//  Zhidao
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//


#import "TTBadgeNumberView.h"
#import "FBKVOController.h"
#import "TTThemeManager.h"
#import "SSThemed.h"

const NSInteger TTBadgeNumberWidthInset = 6;
const NSInteger TTBadgeNumberHeightInset = 4;


@interface TTBadgeNumberView ()
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, strong) UIColor * badgeBackgroundColor;
@property (nonatomic, strong) UIView * redBgView;
@property (nonatomic, strong) CAShapeLayer * borderLayer;

@end

@implementation TTBadgeNumberView

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
    
    [self setNeedsLayout];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    if ( !isEmptyString(self.backgroundColorThemeKey)) {
        self.badgeBackgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundColorThemeKey);
    }
    if ( !isEmptyString(self.badgeTextColorThemeKey)) {
        self.label.textColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeTextColorThemeKey);
    }
    if ( !isEmptyString(self.badgeBorderColorThemeKey)) {
        self.borderLayer.strokeColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeBorderColorThemeKey).CGColor;
    }
    
    [self setNeedsLayout];
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    if (_backgroundColorThemeKey != backgroundColorThemeKey) {
        _backgroundColorThemeKey = backgroundColorThemeKey;
        self.badgeBackgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundColorThemeKey);
    }
}

- (void)setBadgeTextColorThemeKey:(NSString *)badgeTextColorThemeKey {
    if (_badgeTextColorThemeKey != badgeTextColorThemeKey) {
        _badgeTextColorThemeKey = badgeTextColorThemeKey;
        self.label.textColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeTextColorThemeKey);
    }
}

- (void)setBadgeBorderColorThemeKey:(NSString *)badgeBorderColorThemeKey {
    if (_badgeBorderColorThemeKey != badgeBorderColorThemeKey) {
        _badgeBorderColorThemeKey = badgeBorderColorThemeKey;
        self.borderLayer.strokeColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeBorderColorThemeKey).CGColor;
    }
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    _badgeNumber = badgeNumber;
    self.label.text = TTBadgeValueStringFromInteger(_badgeNumber);
    [self sizeToFit];
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)setBadgeViewStyle:(NSUInteger)badgeViewStyle {
    self.lastBadgeViewStyle = _badgeViewStyle;
    _badgeViewStyle = badgeViewStyle;
    if(_badgeViewStyle == TTBadgeNumberViewStyleProfile){
        self.label.font = [UIFont systemFontOfSize:12];
    }
    [self sizeToFit];
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    _badgeNumber = -1;
    self.label.text = badgeValue;
    [self sizeToFit];
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (NSString *)badgeValue
{
    return self.label.text;
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    [self.label setTextColor:badgeTextColor];
}

- (UIColor *)badgeTextColor
{
    return [self.label textColor];
}

- (void)setBadgeLabelFontSize:(CGFloat)sizeNum
{
    self.label.font = [UIFont systemFontOfSize:sizeNum];
}

- (void)setupDefaultPropertyValues
{
    UILabel *label = [UILabel new];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:10];
    label.frame = self.bounds;
    [self addSubview:label];
    self.label = label;
    self.userInteractionEnabled = NO;
    
    self.backgroundColorThemeKey = kColorBackground7;
    self.badgeTextColorThemeKey = kColorText12;
    self.badgeBorderColorThemeKey = kColorBackground20;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultPropertyValues];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupDefaultPropertyValues];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat fixedWidth = 0.f;
    CGFloat fixedHeight = 0.f;
    if(self.badgeViewStyle == TTBadgeNumberViewStyleDefaultWithBorder) {
        fixedWidth = 2.f;
        fixedHeight = 2.f;
    }
    else if(self.badgeViewStyle == TTBadgeNumberViewStyleProfile){
        fixedWidth = 4.f;
        fixedHeight = 4.f;
    }
    [self.label sizeToFit];
    size = [self.label sizeThatFits:size];
    
    if ([self.label.text isEqualToString:@""]) {
        return (CGSize){8 + fixedWidth,8 + fixedHeight};
    }
    else if (size.width == 0) {
        return size;
    }
    else {
        
        //数字的按给的值 文字的按sizeToFit来
        if (_badgeNumber > 0) {
            if(_badgeNumber<10){
                return (CGSize){14 + fixedWidth,14 + fixedHeight};
            }
            else if (_badgeNumber<100){
                return (CGSize){20 + fixedWidth,14 + fixedHeight};
            }
            else if (_badgeNumber == TTBadgeNumberMore){
                return (CGSize){18 + fixedWidth,14 + fixedHeight};
            }
            else{
                return (CGSize){24 + fixedWidth,14 + fixedHeight};
            }
            
        }
        else {
            if (size.height > 14) {
                size.height = 14;
            }
            if (size.width < size.height) {
                return (CGSize){size.height+TTBadgeNumberHeightInset >= 14 ? 14 + fixedWidth :size.height+TTBadgeNumberHeightInset + fixedWidth, size.height+TTBadgeNumberHeightInset >= 14 ? 14 + fixedHeight : size.height+TTBadgeNumberHeightInset + fixedHeight};
            }
            return (CGSize){size.width+TTBadgeNumberWidthInset + fixedWidth, size.height+TTBadgeNumberHeightInset >= 14 ? 14 + fixedHeight :size.height+TTBadgeNumberHeightInset + fixedHeight};
        }
    }
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:CGSizeZero];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.badgeNumber == TTBadgeNumberHidden || self.label.text == nil) {
        self.hidden = YES;
    }
    else{
        self.hidden = NO;
    }
    if (self.badgeViewStyle == TTBadgeNumberViewStyleWhite && self.badgeNumber != TTBadgeNumberPoint) {
        
        if ( !isEmptyString(self.backgroundColorThemeKey)) {
            self.label.textColor  = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundColorThemeKey);
            
        }
        if ( !isEmptyString(self.badgeTextColorThemeKey)) {
            self.badgeBackgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeTextColorThemeKey);
        }
        
    }
    else {
        
        if ( !isEmptyString(self.backgroundColorThemeKey)) {
            self.badgeBackgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundColorThemeKey);
            
        }
        if ( !isEmptyString(self.badgeTextColorThemeKey)) {
            self.label.textColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeTextColorThemeKey);
        }
        
    }
    
    if (((self.badgeViewStyle == TTBadgeNumberViewStyleWhite && self.badgeNumber == TTBadgeNumberPoint) || self.badgeViewStyle == TTBadgeNumberViewStyleDefaultWithBorder)) {
        self.layer.borderColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeBorderColorThemeKey).CGColor;
        
        CGFloat padding = 1.f / ([UIScreen mainScreen].scale);
        if (!self.borderLayer) {
            self.borderLayer = [CAShapeLayer new];
            self.borderLayer.lineWidth = 1 + padding;
            self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        }
        self.borderLayer.strokeColor = SSGetThemedColorUsingArrayOrKey(nil, self.badgeBorderColorThemeKey).CGColor;
        self.borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.5, 0.5, self.frame.size.width - 1,self.frame.size.height - 1)
                                                           cornerRadius:self.frame.size.height/2.f].CGPath;
        
        if (![self.layer.sublayers containsObject:self.borderLayer]) {
            [self.layer addSublayer:self.borderLayer];
        }
    } else{
        [self.borderLayer removeFromSuperlayer];
    }
    
    
    self.backgroundColor = self.badgeBackgroundColor;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.clipsToBounds = YES;
    [self.label sizeToFit];
    self.label.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
}

@end

const NSInteger TTBadgeNumberPoint = -1000; //magic number
const NSInteger TTBadgeNumberHidden = 0;
const NSInteger TTBadgeNumberMore = NSIntegerMax;

NSString *TTBadgeValueStringFromInteger(NSInteger number)
{
    if (number == TTBadgeNumberHidden) {
        return nil;
    }
    if (number == TTBadgeNumberPoint) {
        return @"";
    }
    if (number == TTBadgeNumberMore) {
        return @"···";
    }
    if (number > 99) {
        return @"99+";
    }
    return @(number).stringValue;
}

