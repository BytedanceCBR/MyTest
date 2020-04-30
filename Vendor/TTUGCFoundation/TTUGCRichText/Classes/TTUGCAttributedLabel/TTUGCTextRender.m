//
//  TTUGCTextRender.m
//  TestCoreText
//
//  Created by zoujianfeng on 2019/11/5.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import "TTUGCTextRender.h"
#import "TTUGCEmojiTextAttachment.h"
#import <BDAssert/BDAssert.h>
#import <BDPainter/NSAttributedString+BDPainter.h>

#define kSystemDefaultTruncatedTokenLength 3 // 系统默认Truncated“...”长度为3
#define TTUGCCustomLinkAttributeName @"TTUGCCustomLinkAttributeName"

@implementation TTUGCAsyncLabelLink

//@synthesize result = _result, attributes = _attributes;
//
//- (instancetype)initWithAttributes:(NSDictionary *)attributes textCheckingResult:(NSTextCheckingResult *)result {
//    if ((self = [super init])) {
//        _result = result;
//        _attributes = [attributes copy];
//    }
//
//    return self;
//}

@end

@interface TTUGCTextRender ()

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@property (nonatomic, assign) CGRect textBound;
@property (nonatomic, strong) TTUGCAsyncLabelLink *truncatedTokenLink;
@property (nonatomic, assign) CGSize truncatedSize;
@property (nonatomic, copy) NSArray <TTUGCAsyncLabelLink *> *linkModels;

@property (nonatomic, assign) NSLineBreakMode lineBreakMode; // 默认是NSLineBreakByWordWrapping，涵盖系统默认截断(...)样式及自定义截断样式

@property (nonatomic, assign) CGFloat topPadding;

@end

@implementation TTUGCTextRender

- (instancetype)init {
    if (self = [super init]) {
        _onlySetRenderSizeWillGetTextBounds = YES;
    }
    return self;
}

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText {
    if (!attributedText) {
        return nil;
    }

    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    [textStorage addLayoutManager:self.layoutManager];
    [textStorage setAttributedString:attributedText];
    return [self initWithTextStorage:textStorage];
}

- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage {
    if (!textStorage) {
        return nil;
    }

    if (self = [self init]) {
        self.textStorage = textStorage;
    }
    return self;
}

#pragma mark - Equal

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if ([self class] != [object class]) {
        return NO;
    }

    TTUGCTextRender *otherObject = (TTUGCTextRender *)object;

    if (otherObject.textContainer.maximumNumberOfLines != self.textContainer.maximumNumberOfLines ||
        otherObject.textContainer.lineBreakMode != self.textContainer.lineBreakMode ||
        otherObject.textContainer.lineFragmentPadding != self.textContainer.lineFragmentPadding) {
        return NO;
    }

    if (otherObject.textStorage && self.textStorage) {
        if ([otherObject.textStorage isEqual:self.textStorage]) {
            return YES;
        } else {
            if (![otherObject.textStorage.string isEqualToString:self.textStorage.string]) {
                return NO;
            } else { // 如果文本相同，但是isEqual却又不同，判断attachment是否相同
                NSMutableArray *otherAttachment = [NSMutableArray array];
                [otherObject.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, otherObject.textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                    if ([value isKindOfClass:[NSTextAttachment class]]) {
                        [otherAttachment addObject:value];
                    }
                }];
                if (otherAttachment.count > 0) {
                    NSMutableArray *ownAttachment = [NSMutableArray array];
                    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                        if ([value isKindOfClass:[NSTextAttachment class]]) {
                            [ownAttachment addObject:value];
                        }
                    }];

                    if (otherAttachment.count != ownAttachment.count) {
                        return NO;
                    } else {
                        __block BOOL isAttachmentEqual = YES;
                        [otherAttachment enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (ownAttachment.count > idx) {
                                id ownAttachmentItem = [ownAttachment objectAtIndex:idx];
                                isAttachmentEqual = [obj isEqual:ownAttachmentItem];
                                if (!isAttachmentEqual) {
                                    *stop = YES;
                                }
                            } else {
                                isAttachmentEqual = NO;
                                *stop = YES;
                            }
                        }];
                        if (!isAttachmentEqual) {
                            return NO;
                        }
                    }
                } else { // attachment 没有，认为不同
                    return NO;
                }
            }
        }
    } else {
        return NO;
    }

    return YES;
}

#pragma mark - Private

- (NSRange)visibleGlyphRange {
    return [self.layoutManager glyphRangeForTextContainer:self.textContainer];
}

- (void)updateTruncatedTokenLinkWithAttributes:(NSDictionary *)attributes {
    NSRange linkRange;
    if ([self.truncatedToken attribute:TTUGCCustomLinkAttributeName atIndex:0 effectiveRange:&linkRange]) {
        NSURL *url = [self.truncatedToken attribute:TTUGCCustomLinkAttributeName atIndex:0 effectiveRange:&linkRange];
        TTUGCAsyncLabelLink *link = [[TTUGCAsyncLabelLink alloc] initWithAttributes:nil textCheckingResult:nil];
        link.linkURL = url;
        self.truncatedTokenLink = link;
    }
}

- (void)updateTruncatedSize {
    if (self.font && self.truncatedToken) {
        self.truncatedSize = [self.truncatedToken.string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName : self.font}
                                                                      context:nil].size;
    }
}

#pragma mark - Public

- (void)setFont:(UIFont *)font {
    _font = font;
    [self updateTruncatedSize];
}

- (void)setTruncatedToken:(NSAttributedString *)truncatedToken {
    NSRange linkRange;
    if ([truncatedToken attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange]) {
        NSURL *url = [truncatedToken attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange];
        NSMutableArray *linksAttribute = [NSMutableArray array];
        [truncatedToken enumerateAttribute:NSLinkAttributeName inRange:NSMakeRange(0, truncatedToken.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            NSValue *rangeValue = [NSValue valueWithRange:range];
            if (rangeValue) {
                [linksAttribute addObject:rangeValue];
            }
        }];
        NSMutableAttributedString *mutableTruncatedToken = [truncatedToken mutableCopy];
        [linksAttribute enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableTruncatedToken removeAttribute:NSLinkAttributeName range:obj.rangeValue];
            [mutableTruncatedToken addAttribute:TTUGCCustomLinkAttributeName value:url range:obj.rangeValue];
        }];
        _truncatedToken = [mutableTruncatedToken copy];
        [self updateTruncatedTokenLinkWithAttributes:nil];
    } else {
        _truncatedToken = [truncatedToken copy];
    }
    [self updateTruncatedSize];
}

- (TTUGCAsyncLabelLink *)setTruncatedText:(NSString *)truncatedText attributes:(NSDictionary *)attributes {
    if ([truncatedText isKindOfClass:[NSString class]] && truncatedText.length > 0) {
        self.truncatedToken = [[[NSMutableAttributedString alloc] initWithString:truncatedText attributes:attributes] copy];
        return self.truncatedTokenLink;
    }
    return nil;
}

- (NSRange)visibleCharacterRange {
    return [self.layoutManager characterRangeForGlyphRange:[self visibleGlyphRange] actualGlyphRange:nil];
}

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange {
    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    return [self boundingRectForGlyphRange:glyphRange];
}

- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange {
    return [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
}

- (CGRect)textBound {
    if (_onlySetRenderSizeWillGetTextBounds && !CGRectIsEmpty(_textBound)) {
        return _textBound;
    }
    CGRect textRect = [self boundingRectForGlyphRange:[self visibleGlyphRange]];
    return CGRectMake(textRect.origin.x, textRect.origin.y, ceilf(textRect.size.width), ceilf(textRect.size.height));
}

- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth {
    if (!self.textStorage) {
        return CGSizeZero;
    }
    CGSize size = self.textContainer.size;
    self.textContainer.size = CGSizeMake(renderWidth, MAXFLOAT);
    CGSize textSize = [self boundingRectForGlyphRange:[self visibleGlyphRange]].size;
    self.textContainer.size = size;
    return CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
}

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString
                       constraintsSize:(CGSize)size
                limitedToNumberOfLines:(NSUInteger)numberOfLines {
    if (!attributedString || attributedString.length == 0) {
        return CGSizeZero;
    }
    if (size.width < 0) {
        return CGSizeZero;
    }

    CGSize constraintsSize = CGSizeMake(size.width, MAXFLOAT);
    if (numberOfLines == 1) {
        constraintsSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    }

    TTUGCTextRender *textRender = [[TTUGCTextRender alloc] initWithAttributedText:attributedString];
    textRender.maximumNumberOfLines = numberOfLines;
    textRender.lineBreakMode = NSLineBreakByWordWrapping; // 得用默认NSLineBreakByWordWrapping，用tail算不准确
    textRender.size = constraintsSize;

    return textRender.textBound.size;
}

+ (CGSize)sizeThatFitsForTextViewAttributedString:(NSAttributedString *)attributedString constraintsSize:(CGSize)size limitedToNumberOfLines:(NSUInteger)numberOfLines {
    if (!attributedString || attributedString.length == 0) {
        return CGSizeZero;
    }
    if (size.width < 0) {
        return CGSizeZero;
    }

    CGSize constraintsSize = CGSizeMake(size.width, MAXFLOAT);
    if (numberOfLines == 1) {
        constraintsSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    }

    TTUGCTextRender *textRender = [[TTUGCTextRender alloc] initWithAttributedText:attributedString];
    textRender.maximumNumberOfLines = numberOfLines;
    textRender.lineBreakMode = NSLineBreakByWordWrapping; // 得用默认NSLineBreakByWordWrapping，用tail算不准确

    // 有系统插入的 NSOriginalFont 算高不准
    // https://stackoverflow.com/questions/22826943/nsattributedstring-reporting-incorrect-sizes-for-uitextview-sizethatfits-and-bou
    [textRender.textStorage removeAttribute:@"NSOriginalFont" range:NSMakeRange( 0, textRender.textStorage.length)];
    textRender.size = constraintsSize;

    return textRender.textBound.size;
}

+ (long)numberOfLinesAttributedString:(NSAttributedString *)attributedString constraintsWidth:(CGFloat)width {
    if (!attributedString || attributedString.length == 0) {
        return 0;
    }

    TTUGCTextRender *textRender = [[TTUGCTextRender alloc] initWithAttributedText:attributedString];
    textRender.maximumNumberOfLines = 0;
    textRender.size = CGSizeMake(width, MAXFLOAT);

    return [textRender numberOfLines];
}

#pragma mark - Link

- (void)addLink:(TTUGCAsyncLabelLink *)link {
    [self addLinks:@[link]];
}

- (void)addLinks:(NSArray *)links {
    if (!links || links.count == 0) {
        return;
    }
    
    NSMutableArray *mutableLinkModels = [NSMutableArray arrayWithArray:self.linkModels];

    NSMutableAttributedString *mutableAttributedString = [self.textStorage mutableCopy];

    for (TTUGCAsyncLabelLink *link in links) {
        if (link.attributes && NSMaxRange(link.result.range) <= mutableAttributedString.length) {
            [mutableAttributedString addAttributes:link.attributes range:link.result.range];
        }
    }

    self.textStorage = [[NSTextStorage alloc] initWithAttributedString:mutableAttributedString];

    [mutableLinkModels addObjectsFromArray:links];

    self.linkModels = [NSArray arrayWithArray:mutableLinkModels];
}

- (BOOL)containsLinkAtPoint:(CGPoint)point {
    return [self linkAtPoint:point] != nil;
}

- (TTUGCAsyncLabelLink *)linkAtPoint:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectInset(CGRectMake(0, 0, self.size.width, self.size.height), -15.f, -15.f), point) || self.linkModels.count == 0) {
        return nil;
    }

    return [self linkAtCharacterIndex:[self characterIndexForPoint:point]];
}

- (NSInteger)characterIndexForPoint:(CGPoint)point {
    CGRect textRect = _textBound;
    if (!CGRectContainsPoint(textRect, point)) {
        return -1;
    }
    CGPoint realPoint = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    CGFloat distanceToPoint = 1.0;
    NSUInteger index = [self.layoutManager characterIndexForPoint:realPoint inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&distanceToPoint];
    return distanceToPoint < 1 ? index : -1;
}

- (TTUGCAsyncLabelLink *)linkAtCharacterIndex:(CFIndex)idx {
    if (!NSLocationInRange((NSUInteger)idx, NSMakeRange(0, self.textStorage.length))) {
        return nil;
    }

    NSEnumerator *enumerator = [self.linkModels reverseObjectEnumerator];
    TTUGCAsyncLabelLink *link = nil;
    while ((link = [enumerator nextObject])) {
        if (NSLocationInRange((NSUInteger)idx, link.result.range)) {
            return link;
        }
    }

    return nil;
}

- (NSArray<TTUGCAsyncLabelLink *> *)links {
    return [self.linkModels copy];
}

#pragma mark - Truncated

- (void)drawTruncatedTokenIsCanceled:(BOOL (^)(void))isCanceled {
    if (!self.truncatedToken) {
        self.textContainer.lineBreakMode = NSLineBreakByWordWrapping; // 改为默认，若为NSLineBreakByTruncatingTail，当截断行是空行时（只有换行符），系统会将下一行内容显示在当前空行
        NSMutableAttributedString *customTruncatedToken = [[NSMutableAttributedString alloc] initWithString:@"\u2026"]; // 自定义...截断（模拟系统截断）
        BDAssert(self.font, @"TTUGCTextRender font is needed");
        if (!self.font) {
            return;
        }
        customTruncatedToken.bdp_font = self.font;
        self.truncatedToken = customTruncatedToken;
    }
    [self appendTokenIfNeededIsCanceled:isCanceled];
}

- (void)appendTokenIfNeededIsCanceled:(BOOL (^__nullable)(void))isCanceled {
    if ([self shouldAppendTruncatedToken] && ![self isTruncatedTokenAppended]) {
        BDAssert(self.font, @"TTUGCTextRender font is needed");
        if (!self.font) {
            return;
        }

        NSInteger numberOfLines, index, numberOfGlyphs = [self.layoutManager numberOfGlyphs];
        NSRange lineRange = NSMakeRange(NSNotFound, 0);
        NSInteger approximateNumberOfLines = [self numberOfLines];

        if (self.maximumNumberOfLines > 0 && approximateNumberOfLines > self.maximumNumberOfLines) {
            approximateNumberOfLines = self.maximumNumberOfLines;
        }

        for (numberOfLines = 0, index = 0; index < numberOfGlyphs && approximateNumberOfLines > 0; numberOfLines++) {
            [self.layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
            if (numberOfLines == approximateNumberOfLines - 1) {
                break;
            }
            index = NSMaxRange(lineRange);
        }

        if (lineRange.location == NSNotFound ||
            self.textStorage.length < NSMaxRange(lineRange) ||
            (isCanceled && isCanceled())) { // lineRange 合法性校验
            return;
        }

        // 处理表情，不占文本长度
        NSMutableDictionary *attachmentDict = [NSMutableDictionary dictionary];
        __block CGFloat attachmentsWidth = 0.f; // attachment的总宽度
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:lineRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (value) {
                if ([value isKindOfClass:[TTUGCEmojiTextAttachment class]]) {
                    TTUGCEmojiTextAttachment *tempAttachment = (TTUGCEmojiTextAttachment *)value;
                    [attachmentDict setValue:@([tempAttachment renderWidth]) forKey:@(range.location).stringValue];
                    attachmentsWidth += [tempAttachment renderWidth];
                } else if ([value isKindOfClass:[NSTextAttachment class]]) {
                    NSTextAttachment *tempAttachment = (NSTextAttachment *)value;
                    [attachmentDict setValue:@(tempAttachment.bounds.size.width) forKey:@(range.location).stringValue];
                    attachmentsWidth += tempAttachment.bounds.size.width;
                }
            }
        }];

        if (isCanceled && isCanceled()) return;

        NSString *truncatedLineStr = [self.textStorage.string substringWithRange:lineRange];
        CGSize truncatedLineStrSize = [truncatedLineStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName : self.font}
                                                                     context:nil].size;

        NSAttributedString *tempTotalNumberAttr = [self.textStorage copy];
        NSInteger totalNumberLines = [TTUGCTextRender numberOfLinesAttributedString:tempTotalNumberAttr constraintsWidth:self.size.width];
        if (self.textStorage.string.length == NSMaxRange(lineRange) ||
            (truncatedLineStrSize.width + attachmentsWidth <= self.size.width &&
             totalNumberLines == approximateNumberOfLines) || (isCanceled && isCanceled())) { // 已经显示全了
            return;
        }

        // 换行去掉
        while (truncatedLineStr.length > 0 && [truncatedLineStr rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch].location != NSNotFound) {
            truncatedLineStr = [truncatedLineStr substringToIndex:truncatedLineStr.length - 1];
        }

        NSInteger truncatedLocation = index + truncatedLineStr.length;
        while (truncatedLineStr.length > 0 && truncatedLocation > index && truncatedLineStrSize.width + attachmentsWidth > self.size.width - self.truncatedSize.width - 5) {
            truncatedLocation--;
            // 表情
            if (attachmentDict.count > 0 && [attachmentDict objectForKey:@(truncatedLocation).stringValue]) {
                attachmentsWidth -= [[attachmentDict objectForKey:@(truncatedLocation).stringValue] floatValue];
                continue;
            }

            // text
            truncatedLineStr = [truncatedLineStr substringToIndex:truncatedLineStr.length - 1];
            truncatedLineStrSize = [truncatedLineStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName : self.font}
                                                                  context:nil].size;
            if (isCanceled && isCanceled()) return;
        }


        NSRange tokenRange = NSMakeRange(truncatedLocation, self.textStorage.length - truncatedLocation);
        NSTextStorage *tempTextStorage = [self.textStorage mutableCopy];
        if (NSMaxRange(tokenRange) <= tempTextStorage.length) {
            [tempTextStorage replaceCharactersInRange:tokenRange withAttributedString:self.truncatedToken]; // replace with truncated
            if (isCanceled && isCanceled()) return;
            
            self.textStorage = [[NSTextStorage alloc] initWithAttributedString:[tempTextStorage copy]];
            [self addTruncatedTokenLinkRange:[self.textStorage.string rangeOfString:self.truncatedToken.string]]; // truncatedLink
        }
    }
}

- (BOOL)shouldAppendTruncatedToken {
    return (self.textStorage.length > 0 && self.truncatedToken.length > 0);
}

- (BOOL)isTruncatedTokenAppended {
    NSString *contentString = self.textStorage.string;
    NSString *truncatedString = self.truncatedToken.string;
    return contentString.length > 0 && truncatedString.length > 0 && [contentString rangeOfString:truncatedString].length != 0;
}

- (void)addTruncatedTokenLinkRange:(NSRange)range {
    if (self.truncatedToken && !self.truncatedTokenLink) {
        [self updateTruncatedTokenLinkWithAttributes:nil];
    }
    if (self.truncatedTokenLink) {
        NSTextCheckingResult *result = [NSTextCheckingResult linkCheckingResultWithRange:range URL:self.truncatedTokenLink.linkURL];
        self.truncatedTokenLink.result = result; // 更新result
        [self addLink:self.truncatedTokenLink];
    }
}

#pragma mark - Draw

- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^)(void))isCanceled {
    if (isCanceled && isCanceled()) return;

    NSRange glyphRange = [self visibleGlyphRange];
    CGRect textRect = [self textRectForGlyphRange:glyphRange atPiont:point];
    _textBound = textRect;

    // 绘制
    if (isCanceled && isCanceled()) return;
    [self.layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:textRect.origin];

    CGFloat padding = (self.textContainer.size.height - textRect.size.height) / 2.f;
    padding += self.topPadding;
    if (isCanceled && isCanceled()) return;
    [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:CGPointMake(textRect.origin.x, textRect.origin.y + padding)];
}

- (CGRect)textRectForGlyphRange:(NSRange)glyphRange atPiont:(CGPoint)point {
    if (glyphRange.length == 0) {
        return CGRectZero;
    }
    CGPoint textOffset = point;
    CGRect textBound = _textBound;
    if (!_onlySetRenderSizeWillGetTextBounds || CGRectIsEmpty(textBound)) {
        textBound = [self boundingRectForGlyphRange:glyphRange];
    }
    CGSize textSize = CGSizeMake(ceilf(textBound.size.width), ceilf(textBound.size.height));
    textBound.origin = textOffset;
    textBound.size = textSize;
    return textBound;
}

#pragma mark - Getter && Setter

- (void)setTextStorage:(NSTextStorage *)textStorage {
    @synchronized (self) {
        if (_textStorage && _textStorage.layoutManagers.count > 0) {
            NSArray *layoutManagers = [_textStorage.layoutManagers copy];
            [layoutManagers enumerateObjectsUsingBlock:^(NSLayoutManager * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [_textStorage removeLayoutManager:obj];
            }];
        }
        _textStorage = textStorage;
        if (_textStorage && _textStorage.layoutManagers.count == 0) {
            [_textStorage addLayoutManager:self.layoutManager];
        }

        self.topPadding = 0;
        if (textStorage) {
            UIFont *font = textStorage.bdp_font;
            NSParagraphStyle *style = textStorage.bdp_paragraphStyle;
            if (style && style.maximumLineHeight > font.pointSize && font.pointSize > 0) {
                self.topPadding = (font.pointSize - style.maximumLineHeight) / 4.f;
            }
        }
    }
}

- (void)setSize:(CGSize)size {
    _size = size;
    if (!CGSizeEqualToSize(self.textContainer.size, size)) {
        self.textContainer.size = size;
        if (_onlySetRenderSizeWillGetTextBounds) {
            CGRect rect = [self.layoutManager usedRectForTextContainer:self.textContainer];
            _textBound = CGRectMake(rect.origin.x, rect.origin.y, ceilf(rect.size.width), ceilf(rect.size.height));
        }
    }
}

- (NSInteger)numberOfLines {
    __block NSInteger lineCount = 0;
    NSRange glyphRange = [self visibleGlyphRange];
    [self.layoutManager enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        ++lineCount;
    }];
    return lineCount;
}

- (CGFloat)lineFragmentPadding {
    return self.textContainer.lineFragmentPadding;
}

- (void)setLineFragmentPadding:(CGFloat)lineFragmentPadding {
    self.textContainer.lineFragmentPadding = lineFragmentPadding;
}

- (NSLineBreakMode)lineBreakMode {
    return self.textContainer.lineBreakMode;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (self.textContainer.lineBreakMode == lineBreakMode) {
        return;
    }
    self.textContainer.lineBreakMode = lineBreakMode;
}

- (NSUInteger)maximumNumberOfLines {
    return self.textContainer.maximumNumberOfLines;
}

- (void)setMaximumNumberOfLines:(NSUInteger)maximumNumberOfLines {
    if (self.textContainer.maximumNumberOfLines == maximumNumberOfLines) {
        return;
    }
    self.textContainer.maximumNumberOfLines = maximumNumberOfLines;
}

- (NSArray *)linkModels {
    if (!_linkModels) {
        _linkModels = [NSArray array];
    }
    return _linkModels;
}

- (NSLayoutManager *)layoutManager {
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc] init];
        _layoutManager.usesFontLeading = NO;
        [_layoutManager addTextContainer:self.textContainer];
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer {
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc] init];
        _textContainer.lineFragmentPadding = 0;
    }
    return _textContainer;
}

@end
