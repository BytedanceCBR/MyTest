//
//  TTLabel.m
//  Article
//
//  Created by 杨心雨 on 16/8/19.
//
//

#import "TTLabel.h"
#import "UIView-Extension.h"
#import "NSString-Extension.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"

@implementation TTLabel

/** 字体颜色 */
- (void)setTextColorKey:(NSString *)textColorKey {
    NSString *oldValue = _textColorKey;
    _textColorKey = textColorKey;
    if (_textColorKey && oldValue != _textColorKey) {
        self.textColor = [UIColor tt_themedColorForKey:_textColorKey];
        self.highlightedTextColor = [UIColor tt_themedColorForKey:[_textColorKey tt_suffixHighlighted]];
    }
}

/** 背景色 */
- (void)setBackgroundColorKey:(NSString *)backgroundColorKey {
    NSString *oldValue = _backgroundColorKey;
    _backgroundColorKey = backgroundColorKey;
    if (_backgroundColorKey && oldValue != _backgroundColorKey) {
        self.backgroundColor = [UIColor tt_themedColorForKey:_backgroundColorKey];
    }
}

/** 描边色 */
- (void)setBorderColorKey:(NSString *)borderColorKey {
    NSString *oldValue = _borderColorKey;
    _borderColorKey = borderColorKey;
    if (_borderColorKey && oldValue != _borderColorKey) {
        self.layer.borderColor = [[UIColor tt_themedColorForKey:_borderColorKey] CGColor];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self refreshText];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self tt_addThemeNotification];
    return self;
}

- (void)dealloc {
    [self tt_removeThemeNotification];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self tt_selfThemeChanged:nil];
}

- (void)tt_selfThemeChanged:(NSNotification *)notification {
    if (_textColorKey) {
        self.textColor = [UIColor tt_themedColorForKey:_textColorKey];
        self.highlightedTextColor = [UIColor tt_themedColorForKey:[_textColorKey tt_suffixHighlighted]];
    }
    if (_backgroundColorKey) {
        self.backgroundColor = [UIColor tt_themedColorForKey:_backgroundColorKey];
    }
    if (_borderColorKey) {
        self.layer.borderColor = [[UIColor tt_themedColorForKey:_borderColorKey] CGColor];
    }
    [self themeChanged:notification];
}

/** 更新属性文字 */
- (void)refreshText {
    if (self.text) {
        self.attributedText = [self.text tt_attributedStringWithFont:self.font lineHeight:self.lineHeight lineBreakMode:self.lineBreakMode firstLineIndent:self.firstLineIndent alignment:self.textAlignment];
    }
}

/**
 Frame大小自适应
 
 - parameter width: 最大宽度
 */
- (void)sizeToFit:(CGFloat)width {
    if (self.text) {
        CGSize size = [self.text tt_sizeWithMaxWidth:width font:self.font lineHeight:self.lineHeight  numberOfLines:self.numberOfLines firstLineIndent:_firstLineIndent alignment:self.textAlignment];
        self.size = size;
    }
}


- (CGFloat)lineHeight {
    return _lineHeight == 0 ? ceil(self.font.lineHeight) : _lineHeight;
}

- (CGFloat)lineOffset {
    return self.lineHeight - ceil(self.font.pointSize);
}

- (CGPoint)origin {
    CGPoint origin = self.frame.origin;
    origin.y = self.top;
    return origin;
}

- (void)setOrigin:(CGPoint)origin {
    self.left = origin.x;
    self.top = origin.y;
}

- (CGFloat)top {
    return self.frame.origin.y + ([self lineOffset] / 2);
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top - ([self lineOffset] / 2);
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height - ([self lineOffset] / 2);
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom + ([self lineOffset] / 2) - self.frame.size.height;
    self.frame = frame;
}

- (CGSize)size {
    CGSize size = self.frame.size;
    size.height = self.height;
    return size;
}

- (void)setSize:(CGSize)size {
    self.width = size.width;
    self.height = size.height;
}

- (CGFloat)height {
    return self.frame.size.height - [self lineOffset];
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height + [self lineOffset];
    self.frame = frame;
}

@end

