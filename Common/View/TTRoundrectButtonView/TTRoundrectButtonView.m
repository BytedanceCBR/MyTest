//
//  TTRoundrectButtonView.m
//  Article
//
//  Created by 冯靖君 on 15/6/10.
//
//

#import "TTRoundrectButtonView.h"
#import "TTDeviceHelper.h"
 
#import "TTLabelTextHelper.h"


#define kTextMaxLength      10
#define kHorizentalMargin   10
#define kButtonViewRadius   15.f
#define kButtonViewMinWidth 60.f
#define kElementSpace       2.f

@interface TTRoundrectButtonView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SSThemedButton *button;
@property (nonatomic, strong) UILabel *label;

@end

@implementation TTRoundrectButtonView

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label.text = [[self class] displayForText:text];
        [self.label sizeToFit];
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeCenter;
        [self reloadThemeUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame text:nil image:nil];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self sendSubviewToBack:self.button];
//    self.width = [[self class] widthForSelfWithText:_label.text imageWidth:_imageView.image.size.width];
    CGSize imageSize = _imageView.image.size;
    self.imageView.frame = CGRectMake([self imageViewLeft], (self.height - imageSize.height) / 2, imageSize.width, imageSize.height);
    self.label.frame = CGRectMake(self.imageView.right + kElementSpace, (self.height - self.label.height) / 2, self.label.width, self.label.height);
    
    self.button.frame = CGRectMake(0, 0, self.width, self.height);
    self.button.layer.cornerRadius = self.height/2;
    self.layer.cornerRadius = self.height/2;
}

- (CGFloat)imageViewLeft
{
    CGFloat elementWidth = _imageView.image.size.width + kElementSpace + self.label.width;
    return (self.width - elementWidth)/2;
}

#pragma mark - Action
- (void)addAction:(SEL)action forTarget:(id)target
{
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshImageViewWithImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)refreshLabelWithText:(NSString *)text
{
    self.label.text = [[self class] displayForText:text];
    [self.label sizeToFit];
    [self setNeedsLayout];
}

- (void)refreshLabelWithTextColorString:(NSString *)newTextColorKey
{
    self.label.textColor = SSGetThemedColorWithKey(newTextColorKey);
}

- (void)refreshLabelWithTextColor:(UIColor *)newTextColor
{
    self.label.textColor = newTextColor;
}

#pragma mark - Getter
- (UIButton *)button
{
    if (!_button) {
        _button = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        UIColor *borderColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1], [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1]]);
        [_button setBackgroundColor:[UIColor clearColor]];
        
        [_button setBorderColors:@[borderColor]];
        [_button setHighlightedBackgroundColors:@[borderColor]];
        [self addSubview:_button];
    }
    return _button;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:[[self class] labelFontSize]];
        _label.textColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1], [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1]]);
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_label];
    }
    return _label;
}


#pragma mark - Themed

- (void)themeChanged:(NSNotification *)notification
{
    _label.textColor = SSGetThemedColorWithKey(kColorText3);
    UIColor *borderColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1], [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1]]);
    _button.borderColors = SSThemedColors(@"dddddd", @"303030");
    _button.highlightedBackgroundColors = SSThemedColors(@"dddddd", @"363636");
    [_button setHighlightedBackgroundColors:@[borderColor]];
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

#pragma mark - Helper
+ (NSString *)displayForText:(NSString *)text
{
    NSString *displayText = text;
    if ([displayText length] > kTextMaxLength) {
        NSRange range = [displayText rangeOfComposedCharacterSequencesForRange:(NSRange){0, kTextMaxLength}];
        displayText = [displayText substringWithRange:range];
        displayText = [displayText stringByAppendingString:@"…"];
    }
    return displayText;
}

+ (CGFloat)widthForSelfWithText:(NSString *)text imageWidth:(CGFloat)imageWidth
{
    CGFloat textWidth = [TTLabelTextHelper sizeOfText:text fontSize:[[self class] labelFontSize] forWidth:9999.0 forLineHeight:[UIFont systemFontOfSize:[[self class] labelFontSize]].lineHeight constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentLeft].width;
    CGFloat contentWidth = kHorizentalMargin + imageWidth + 3 + textWidth + kHorizentalMargin + 4;
    return MAX(contentWidth, kButtonViewMinWidth);
}

+ (CGFloat)labelFontSize
{
    if ([TTDeviceHelper isPadDevice]) {
        return 18.0f;
    }
    return 12.0f;
}

- (UILabel*)getLabel
{
    return self.label;
}

- (UIImageView *)getImageView
{
    return self.imageView;
}

@end
