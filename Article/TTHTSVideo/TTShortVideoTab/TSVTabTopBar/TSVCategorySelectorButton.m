//
//  TSVCategorySelectorButton.m
//  Article
//
//  Created by 王双华 on 2017/10/27.
//

#import "TSVCategorySelectorButton.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface TSVCategorySelectorButton()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, copy)   NSArray<NSString *> *textColors;
@property (nonatomic, copy)   NSArray<NSString *> *textGlowColors;
@property (nonatomic, assign) CGFloat textGlowSize;
@property (nonatomic, assign) BOOL selected;

@end

@implementation TSVCategorySelectorButton

- (instancetype)initWithFrame:(CGRect)frame
                   textColors:(NSArray<NSString *> *)textColors
               textGlowColors:(NSArray<NSString *> *)textGlowColors
                 textGlowSize:(CGFloat)glowSize
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:self.tapRecognizer];
        
        self.titleLabel = ({
            TTGlowLabel *label = [[TTGlowLabel alloc] initWithFrame:self.bounds];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithHexString:@"383838"];
            label.font = [[self class] channelFont];
            [self addSubview:label];
            label;
        });
        
        self.maskTitleLabel = ({
            TTGlowLabel *label = [[TTGlowLabel alloc] initWithFrame:self.titleLabel.frame];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.alpha = 0;
            label.font = [UIFont boldSystemFontOfSize:[[self class] channelFontSize]];
            [self addSubview:label];
            label;
        });
        
        self.textColors = textColors;
        self.textGlowColors = textGlowColors;
        self.textGlowSize = glowSize;
        
        [self themeReload];
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             [self themeReload];
         }];
    }
    
    return self;
}

- (void)setText:(NSString*)text 
{
    self.titleLabel.text = text;
    self.maskTitleLabel.text = text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.bounds = self.bounds;
    self.maskTitleLabel.bounds = self.bounds;
}

- (void)tapped:(UITapGestureRecognizer *)recognizer
{
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _selected = selected;
    if (selected) {
        [self setButtonHighlightColorAnimated:animated];
    } else {
        [self setButtonNormalColorAnimated:animated];
    }
}

- (void)setButtonNormalColorAnimated:(BOOL)animated
{
    void (^animationBlock)(void) = ^{
        self.titleLabel.alpha = 1;
        self.maskTitleLabel.alpha = 0;
//        self.titleLabel.transform = CGAffineTransformIdentity;
//        self.maskTitleLabel.transform = CGAffineTransformIdentity;
    };
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            animationBlock();
        }];
    } else {
        animationBlock();
    }
}

- (void)setButtonHighlightColorAnimated:(BOOL)animated
{
    void (^animationBlock)(void) = ^{
        self.titleLabel.alpha = 0;
        self.maskTitleLabel.alpha = 1;
//        CGFloat scale = [[self class] channelSelectedFontSize] / [[self class] channelFontSize];
//        self.titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
//        self.maskTitleLabel.transform = CGAffineTransformMakeScale(scale, scale);
    };
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            animationBlock();
        }];
    } else {
        animationBlock();
    }
    
}
#pragma mark -- Notification

- (void)themeReload
{
    if (self.textColors.count == 4) {
        UIColor *normalColor = [UIColor colorWithDayColorName:self.textColors[0] nightColorName:self.textColors[1]];
        UIColor *hightlightedColor = [UIColor colorWithDayColorName:self.textColors[2] nightColorName:self.textColors[3]];
        self.titleLabel.textColor = normalColor;
        self.maskTitleLabel.textColor = hightlightedColor;
    }
    
    if (self.textGlowColors.count == 4 && self.textGlowSize > 0) {
        UIColor *normalColor = [UIColor colorWithDayColorName:self.textGlowColors[0] nightColorName:self.textGlowColors[1]];
        UIColor *hightlightedColor = [UIColor colorWithDayColorName:self.textGlowColors[2] nightColorName:self.textGlowColors[3]];
        self.titleLabel.glowColor = normalColor;
        self.maskTitleLabel.glowColor = hightlightedColor;
        self.titleLabel.glowSize = self.textGlowSize;
        self.maskTitleLabel.glowSize = self.textGlowSize;
    }
}

+ (CGFloat)buttonWidthForText:(NSString *)text buttonCount:(NSInteger)buttonCount
{
    if (isEmptyString(text)) {
        return 0;
    } else {
        if (buttonCount == 2) {
            CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : [self channelFont]}];
            CGFloat width = ceil(size.width) + 50;
            return width;
        } else if (buttonCount == 3) {
            CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : [self channelFont]}];
            CGFloat width = ceil(size.width) + 40;
            return width;
        } else {
            CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : [self channelFont]}];
            CGFloat width = ceil(size.width) + [self paddingForLayoutLeft];
            return width;
        }
    }
}

+ (UIFont *)channelFont
{
    return [UIFont systemFontOfSize:[self channelFontSize]];
}

+ (CGFloat)channelFontSize
{
    CGFloat fontSize = 0;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 17.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 17.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 17.f;
    } else {
        fontSize = 16.f;
    }
    return fontSize;
}

+ (UIFont *)channelSelectedFont
{
    return [UIFont systemFontOfSize:[self channelSelectedFontSize]];
}

+ (CGFloat)channelSelectedFontSize
{
    CGFloat fontSize = 0;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 19.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 19.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 19.f;
    } else {
        fontSize = 17.f;
    }
    return fontSize;
}

+ (CGFloat)paddingForLayoutLeft
{
    CGFloat padding = 0;
    if ([TTDeviceHelper isPadDevice]) {
        padding = 25;
    } else if ([TTDeviceHelper is736Screen] ||
               [TTDeviceHelper is667Screen] ||
               [TTDeviceHelper isIPhoneXDevice]) {
        padding = 20;
    } else {
        padding = 16;
    }
    return padding;
}

@end
