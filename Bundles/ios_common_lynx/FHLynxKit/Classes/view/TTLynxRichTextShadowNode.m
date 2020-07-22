//
//  TTLynxRichTextShadowNode.m
//  TTLynxAdapter
//
//  Created by ranny_90 on 2020/4/29.
//

#import "TTLynxRichTextShadowNode.h"
#import "LynxComponentRegistry.h"
#import "LynxPropsProcessor.h"
#import "TTLynxRichTextStyle.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import "TTThreadCellHelper.h"
#import "FHUGCCellHelper.h"
#import <TTThemed/TTThemeConst.h>
#import "TTUGCEmojiParser.h"
#import <ByteDanceKit/UIDevice+BTDAdditions.h>
#import <TTKitchen/TTKitchen.h>
#import "TTRichSpanText.h"
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "UIColor+Theme.h"

@interface TTLynxRichTextShadowNode ()

@property (nonatomic, strong) TTLynxRichTextStyle *textStyle;

@property (nonatomic, assign) CGFloat expectedWidth;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) NSString *textRichSpan;

@property (nonatomic, copy) NSString *textColor;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) CGFloat lineSpace;

@property (nonatomic, assign) NSInteger maxLineCount;

@property (nonatomic, copy) NSString *truncationText;

@property (nonatomic, copy) NSString *truncationUrl;

@property (nonatomic, strong) TTRichSpans *richSpans;

@property (nonatomic, strong) TTRichSpanText *richSpanText;

@property (nonatomic, strong) NSAttributedString *truncationToken;

@property (nonatomic, strong) NSAttributedString *attributeString;

@property (nonatomic, assign) CGFloat originalFontSize;

@end

@implementation TTLynxRichTextShadowNode

LYNX_REGISTER_SHADOW_NODE("f-pre-layout-text")

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithSign:(NSInteger)sign tagName:(NSString *)tagName {
  self = [super initWithSign:sign tagName:tagName];
  if (self) {
      self.textStyle = [[TTLynxRichTextStyle alloc] init];
      _fontSize = [self defaultFontSize];
      _textColor = @"222222";
      _maxLineCount = 3;
      _expectedWidth = [UIScreen mainScreen].bounds.size.width -  kUGCPaddingLeft - kUGCPaddingRight;
      _truncationText = @"...全文";
      [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(fontSettingsHasChangedWithNotification:)
                                                   name:kSettingFontSizeChangedAheadNotification
        object:nil];
  }
  return self;
}

- (CGSize)measureNode:(LynxLayoutNode *)node
            withWidth:(CGFloat)width
            widthMode:(LynxMeasureMode)widthMode
               height:(CGFloat)height
           heightMode:(LynxMeasureMode)heightMode {
    NSUInteger numberOfLines = self.maxLineCount;
    CGSize size = [FHUGCCellHelper sizeThatFitsAttributedString:self.attributeString
                                                      withConstraints:CGSizeMake(self.expectedWidth, FLT_MAX)
                                                     maxNumberOfLines:self.maxLineCount
                                               limitedToNumberOfLines:&numberOfLines];
    self.textStyle.numberOfLines = numberOfLines;
    return size;
}

- (void)adoptNativeLayoutNode:(int64_t)ptr {
  [super adoptNativeLayoutNode:ptr];
  [self setMeasureDelegate:self];
}

- (void)layoutDidStart {
    [super layoutDidStart];
    [self configureRichText];
    [self configureAttributeString];
    [self configureTruncationToken];
}

- (void)layoutDidUpdate {
    [super layoutDidUpdate];
    [self postExtraDataToUI:self.textStyle];

}

LYNX_PROP_SETTER("text", setText, NSString*) {
    if (![_text isEqualToString:value]) {
        _text = value;
        [self setNeedsLayout];
    }
}

LYNX_PROP_SETTER("textRichSpan", setTextRichSpan, NSString*) {
    if (![_textRichSpan isEqualToString:value]) {
        _textRichSpan = value;
        [self setNeedsLayout];
    }
}

LYNX_PROP_SETTER("fontSize", setFontSize, CGFloat) {
    if (requestReset) {
        value = NAN;
    }
    self.originalFontSize = value;
    CGFloat matchedFontSize = [self properFontSize];

    if (fabs(_fontSize - matchedFontSize) > CGFLOAT_MIN) {
        self.fontSize = matchedFontSize;
        [self setNeedsLayout];
    }
}


LYNX_PROP_SETTER("textColor", setTextColor, NSString*) {
    if (requestReset) {
      value = @"222222";
    }
    if (![_textColor isEqualToString:value]) {
        _textColor = value;
        [self setNeedsLayout];
    }
}

LYNX_PROP_SETTER("maxLineCount", setMaxLineCount, NSInteger) {
    if (requestReset) {
      value = 3;
    }
    if (_maxLineCount != value) {
        _maxLineCount = value;
        [self setNeedsLayout];
    }
}

LYNX_PROP_SETTER("expectedWidth", setExpectedWidth, CGFloat) {
    if (requestReset) {
      value = [UIScreen mainScreen].bounds.size.width -  kUGCPaddingLeft - kUGCPaddingRight;
    }
    if (fabs(_expectedWidth - value) > CGFLOAT_MIN) {
        _expectedWidth = value;
        [self setNeedsLayout];
    }
}

LYNX_PROP_SETTER("truncationText", setTruncationText, NSString *) {
    if (requestReset) {
      value = @"...全文";
    }
    if (![_truncationText isEqualToString:value]) {
        _truncationText = value;
        [self setNeedsLayout];
    }
}

LYNX_PROP_SETTER("truncationUrl", setTruncationUrl, NSString *) {
    if (requestReset) {
      value = kTTUGCLynxRichLabelTruncationLinkString;
    }
    if (![_truncationUrl isEqualToString:value]) {
        _truncationUrl = value;
        [self setNeedsLayout];
    }
}

- (void)fontSettingsHasChangedWithNotification:(NSNotification *)notification {
    CGFloat matchedFontSize = [self properFontSize];

    if (fabs(_fontSize - matchedFontSize) > CGFLOAT_MIN) {
        self.fontSize = matchedFontSize;
        [self setNeedsLayout];
    }
}

- (void)configureRichText {
    if (!isEmptyString(self.textRichSpan)) {
        self.richSpans = [TTRichSpans richSpansForJSONString:_textRichSpan];
    } else {
        self.richSpans = nil;
    }
    self.richSpanText = [[TTRichSpanText alloc] initWithText:self.text richSpans:self.richSpans];
    self.textStyle.richSpans = self.richSpans;
    self.textStyle.richSpanText = self.richSpanText;
}

- (void)configureTruncationToken {
    self.truncationToken = [TTThreadCellHelper truncationString:self.truncationText font:[UIFont systemFontOfSize:self.fontSize] contentColor:[UIColor colorWithHexString:self.textColor] color:[UIColor themeRed3] linkUrl:kTTUGCLynxRichLabelTruncationLinkString];
    self.textStyle.truncationToken = self.truncationToken;
    self.textStyle.truncationTokenUrl = self.truncationUrl;
}

- (void)configureAttributeString {
    NSString *content = self.richSpanText.text;

    if (isEmptyString(content)) {
        return;
    }
    NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:content fontSize:self.fontSize];

    NSMutableDictionary *attributes = @{}.mutableCopy;
    CGFloat lineHeight = ceil(self.fontSize * 1.4f);
    [attributes setValue:[UIFont systemFontOfSize:self.fontSize] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if ([UIDevice btd_OSVersionNumber] < 9) {
        paragraphStyle.minimumLineHeight = lineHeight;
        paragraphStyle.maximumLineHeight = lineHeight;
        paragraphStyle.lineHeightMultiple = lineHeight - self.fontSize;
    } else {
        paragraphStyle.minimumLineHeight = lineHeight;
        paragraphStyle.maximumLineHeight = lineHeight;
        paragraphStyle.lineSpacing = 0;
    }

    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributes setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setValue:[UIColor colorWithHexString:self.textColor] forKey:NSForegroundColorAttributeName];

    NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
    [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, attrStr.length)];

    self.attributeString = [mutableAttributedString copy];
    self.textStyle.attributeString = self.attributeString;
}

- (CGFloat)defaultFontSize {
    CGFloat size = 0;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
        case TTDeviceMode736:
        case TTDeviceMode812:
        case TTDeviceMode896:
        case TTDeviceMode667: size = 17; break;
        case TTDeviceMode568:
        case TTDeviceMode480: size = 15; break;
    }
    return 17;
}

- (CGFloat)properFontSize {
    CGFloat matchedFontSize = self.originalFontSize;
    switch ([TTUserSettingsManager settingFontSize]) {
        case TTFontSizeSettingTypeMin:
            matchedFontSize -= 2.f;
            break;
        case TTFontSizeSettingTypeNormal:
            break;
        case TTFontSizeSettingTypeBig:
            matchedFontSize += 2.f;
            break;
        case TTFontSizeSettingTypeLarge:
            matchedFontSize += 5.f;
            break;
        default:
            break;
    }
    return matchedFontSize;
}

@end
