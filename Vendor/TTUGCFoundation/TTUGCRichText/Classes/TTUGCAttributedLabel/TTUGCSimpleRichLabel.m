//
//  TTUGCSimpleRichLabel.m
//  TTUGCFoundation
//
//  Created by SongChai on 2018/1/12.
//

#import "TTUGCSimpleRichLabel.h"
#import "TTThemeManager.h"
#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"
#import "SSThemed.h"
#import "TTRoute.h"
#import "UIViewAdditions.h"

#define TTUGCSimpleRichLabelLineHeightScale 1.25

@interface TTUGCSimpleRichLabel()<TTUGCAttributedLabelDelegate>

@end

@implementation TTUGCSimpleRichLabel {
    BOOL _needsRedraw;
    TTRichSpanText *_richSpanText;
    UITapGestureRecognizer *_tapGesture;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ss_didInitialize {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDidFire:)];
    _tapGesture.delegate = self;
    _tapGesture.enabled = NO;
    [self addGestureRecognizer:_tapGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
}

- (void)_customThemeChanged:(NSNotification *)notification {
    [self ugc_setNeedsRedraw];
}

- (void)setTextColors:(NSArray *)textColors {
    if (_textColors != textColors) {
        _textColors = textColors;
        [self ugc_setNeedsRedraw];
    }
}

- (void)setLinkColors:(NSArray *)linkColors {
    if (_linkColors != linkColors) {
        _linkColors = linkColors;
        [self ugc_setNeedsRedraw];
    }
}

- (void)setTextColorThemeKey:(NSString *)textColorThemeKey {
    if (_textColorThemeKey != textColorThemeKey) {
        _textColorThemeKey = textColorThemeKey;
        [self ugc_setNeedsRedraw];
    }
}

- (void)setLinkColorThemeKey:(NSString *)linkColorThemeKey {
    if (_linkColorThemeKey != linkColorThemeKey) {
        _linkColorThemeKey = linkColorThemeKey;
        [self ugc_setNeedsRedraw];
    }
}

- (void)ugc_setNeedsRedraw {
    _needsRedraw = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_needsRedraw) {
            _needsRedraw = NO;
            if (_richSpanText.text.length > 0) {
                [self setupAttributedText];
            }
        }
    });
}

- (void)setRichSpanText:(TTRichSpanText *)richSpanText {
    if (richSpanText.text.length == 0) {
        self.text = nil;
        self.attributedText = nil;
    }
    if (richSpanText != _richSpanText) {
        _richSpanText = richSpanText;
        _richSpanText = [_richSpanText replaceWhitelistLinks];
        if (_autoDetectLinks) {
            [_richSpanText detectAndAddLinks];
        }
        [self setupAttributedText];
    }
}

- (void)setText:(NSString *)text textRichSpans:(NSString *)textRichSpans {
    TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpansJSONString:textRichSpans];
    [self setRichSpanText:richSpanText];
}

- (void)setupAttributedText {
    _tapGesture.enabled = NO;
    if (_richSpanText.text.length == 0) {
        return;
    }
    
    UIColor *textColor = SSGetThemedColorUsingArrayOrKey(self.textColors, self.textColorThemeKey);
    if (textColor == nil) {
        textColor = self.textColor;
    }
    
    NSMutableDictionary *attributeDictionary = @{}.mutableCopy;
    [attributeDictionary setValue:self.font forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.minimumLineHeight = self.font.pointSize * TTUGCSimpleRichLabelLineHeightScale;
    paragraphStyle.maximumLineHeight = self.font.pointSize * TTUGCSimpleRichLabelLineHeightScale;
    paragraphStyle.lineSpacing = 0;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributeDictionary setValue:textColor
                           forKey:NSForegroundColorAttributeName];
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:_richSpanText.text fontSize:self.font.pointSize];
    if (!attrStr) {
        return;
    }
    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attributeDictionary range:NSMakeRange(0, attrStr.length)];
    self.text = [mutableAttributedString copy];
    self.extendsLinkTouchArea = NO;
    
    UIColor *linkColor = SSGetThemedColorUsingArrayOrKey(self.linkColors, self.linkColorThemeKey);
    if (linkColor == nil) {
        linkColor = [UIColor tt_themedColorForKey:kColorText5];
    }
    self.linkAttributes = @{NSForegroundColorAttributeName : linkColor};
    self.activeLinkAttributes = self.linkAttributes;
    self.delegate = self;
    
    NSArray <TTRichSpanLink *> *richSpanLinks = [_richSpanText richSpanLinksOfAttributedString];
    if (richSpanLinks.count > 0) {
        _tapGesture.enabled = YES;
        for (TTRichSpanLink *current in richSpanLinks) {
            NSRange linkRange = NSMakeRange(current.start, current.length);
            if (linkRange.location + linkRange.length <= attrStr.length) {
                [self addLinkToURL:[NSURL URLWithString:current.link] withRange:linkRange];
            }
        }
    }
}

#pragma mark - UITapGestureRecognizer

- (void)tapGestureDidFire:(UITapGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateEnded: {
            CGPoint touchPoint = [sender locationInView:self];
            TTUGCAttributedLabelLink *link = [self linkAtPoint:touchPoint];
            
            if (link) {
                NSTextCheckingResult *result = link.result;
                
                if (!result) {
                    return;
                }
                
                switch (result.resultType) {
                    case NSTextCheckingTypeLink:
                        if (self.clickDelegate && [self.clickDelegate respondsToSelector:@selector(ugcDefaultRichLabel:didClickURL:)]) {
                            [self.clickDelegate ugcDefaultRichLabel:self didClickURL:result.URL];
                        } else {
                            if ([[TTRoute sharedRoute] canOpenURL:result.URL]) {
                                [[TTRoute sharedRoute] openURLByPushViewController:result.URL];
                            } else {
                                NSString *linkStr = result.URL.absoluteString;
                                if (!isEmptyString(linkStr)) {
                                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"]
                                                                              userInfo:TTRouteUserInfoWithDict(@{@"url":linkStr})];
                                }
                            }
                        }
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        default:
            break;
    }
}


+ (CGSize)heightWithWidth:(CGFloat)width
             richSpanText:(TTRichSpanText *)richSpanText
                     font:(UIFont *)font
            numberOfLines:(int)numberOfLines {
    
    richSpanText = [richSpanText replaceWhitelistLinks];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.minimumLineHeight = font.pointSize * TTUGCSimpleRichLabelLineHeightScale;
    paragraphStyle.maximumLineHeight = font.pointSize * TTUGCSimpleRichLabelLineHeightScale;
    paragraphStyle.lineSpacing = 0;
    
    NSMutableDictionary *attributeDictionary = @{}.mutableCopy;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributeDictionary setValue:font forKey:NSFontAttributeName];
    
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:richSpanText.text fontSize:font.pointSize];
    if (!attrStr) {
        return CGSizeZero;
    }
    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attributeDictionary range:NSMakeRange(0, attrStr.length)];
    
    CGSize size = [TTUGCAttributedLabel sizeThatFitsAttributedString:mutableAttributedString
                                                     withConstraints:CGSizeMake(width, FLT_MAX)
                                              limitedToNumberOfLines:numberOfLines];
    return size;
}
@end
