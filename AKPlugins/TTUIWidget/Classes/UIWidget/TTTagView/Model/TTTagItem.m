//
//  TTTagItem.m
//  Article
//
//  Created by 王霖 on 4/19/16.
//
//

#import "TTTagItem.h"
#import "TTThemeConst.h"
#import "TTDeviceHelper.h"

@interface TTTagItem ()

@property (nonatomic, copy, readwrite) NSString *text;

@end

@implementation TTTagItem

- (instancetype _Nonnull)initWithText:(NSString * _Nonnull)text action:(void(^ _Nullable)(void))action {
    self = [super init];
    if (self) {
        _text = text;
        _textColorThemedKey = kColorText2;
        _highlightedTextColorThemedKey = kColorText2Highlighted;
        _bgColorThemedKey = kColorBackground3;
        _highlightedBgColorThemedKey = kColorBackground3Highlighted;
        _borderColorThemedKey = kColorLine1;
        _borderWidth = [TTDeviceHelper ssOnePixel];
        _cornerRadius = 6.f;
        _font = [UIFont systemFontOfSize:14.f];
        _action = action;
        _textImageInterval = 5.0f;
        _selectedTextColorKey = kColorText12;
        _isSelected = NO;
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    if ([_font isEqual:font]) {
        _font = font;
        _fontSize = font.pointSize;
    }
}

- (void)setFontSize:(CGFloat)fontSize {
    if (_fontSize != fontSize) {
        _fontSize = fontSize;
        _font = [UIFont systemFontOfSize:fontSize];
    }
}

@end
