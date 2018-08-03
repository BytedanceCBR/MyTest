// TTUGCAttributedLabel.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TTUGCAttributedLabel.h"
#import "TTUGCEmojiTextAttachment.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kTTUGCLineBreakWordWrapTextWidthScalingFactor (M_PI / M_E)

static CGFloat const TTUGCFLOAT_MAX = 100000;

NSString * const kTTUGCStrikeOutAttributeName = @"TTUGCStrikeOutAttribute";
NSString * const kTTUGCBackgroundFillColorAttributeName = @"TTUGCBackgroundFillColor";
NSString * const kTTUGCBackgroundFillPaddingAttributeName = @"TTUGCBackgroundFillPadding";
NSString * const kTTUGCBackgroundStrokeColorAttributeName = @"TTUGCBackgroundStrokeColor";
NSString * const kTTUGCBackgroundLineWidthAttributeName = @"TTUGCBackgroundLineWidth";
NSString * const kTTUGCBackgroundCornerRadiusAttributeName = @"TTUGCBackgroundCornerRadius";

const NSTextAlignment TTUGCTextAlignmentLeft = NSTextAlignmentLeft;
const NSTextAlignment TTUGCTextAlignmentCenter = NSTextAlignmentCenter;
const NSTextAlignment TTUGCTextAlignmentRight = NSTextAlignmentRight;
const NSTextAlignment TTUGCTextAlignmentJustified = NSTextAlignmentJustified;
const NSTextAlignment TTUGCTextAlignmentNatural = NSTextAlignmentNatural;

const NSLineBreakMode TTUGCLineBreakByWordWrapping = NSLineBreakByWordWrapping;
const NSLineBreakMode TTUGCLineBreakByCharWrapping = NSLineBreakByCharWrapping;
const NSLineBreakMode TTUGCLineBreakByClipping = NSLineBreakByClipping;
const NSLineBreakMode TTUGCLineBreakByTruncatingHead = NSLineBreakByTruncatingHead;
const NSLineBreakMode TTUGCLineBreakByTruncatingMiddle = NSLineBreakByTruncatingMiddle;
const NSLineBreakMode TTUGCLineBreakByTruncatingTail = NSLineBreakByTruncatingTail;

typedef NSTextAlignment TTUGCTextAlignment;
typedef NSLineBreakMode TTUGCLineBreakMode;


static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_round(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_sqrt(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return sqrt(cgfloat);
#else
    return sqrtf(cgfloat);
#endif
}

static inline CGFloat TTUGCFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case TTUGCTextAlignmentCenter:
            return 0.5f;
        case TTUGCTextAlignmentRight:
            return 1.0f;
        case TTUGCTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

static inline NSDictionary * NSAttributedStringAttributesFromLabel(TTUGCAttributedLabel *label) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];

    [mutableAttributes setObject:label.font forKey:(NSString *)kCTFontAttributeName];
    [mutableAttributes setObject:label.textColor forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableAttributes setObject:@(label.kern) forKey:(NSString *)kCTKernAttributeName];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = label.textAlignment;
    paragraphStyle.lineSpacing = label.lineSpacing;
    paragraphStyle.minimumLineHeight = label.minimumLineHeight > 0 ? label.minimumLineHeight : label.font.lineHeight * label.lineHeightMultiple;
    paragraphStyle.maximumLineHeight = label.maximumLineHeight > 0 ? label.maximumLineHeight : label.font.lineHeight * label.lineHeightMultiple;
    paragraphStyle.lineHeightMultiple = label.lineHeightMultiple;
    paragraphStyle.firstLineHeadIndent = label.firstLineIndent;

    if (label.numberOfLines == 1) {
        paragraphStyle.lineBreakMode = label.lineBreakMode;
    } else {
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    }

    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];

    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

static inline CGColorRef CGColorRefFromColor(id color);
static inline NSDictionary * convertNSAttributedStringAttributesToCTAttributes(NSDictionary *attributes);

static inline NSAttributedString * NSAttributedStringByScalingFontSize(NSAttributedString *attributedString, CGFloat scale) {
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTFontAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, BOOL * __unused stop) {
        UIFont *font = (UIFont *)value;
        if (font) {
            NSString *fontName;
            CGFloat pointSize;

            if ([font isKindOfClass:[UIFont class]]) {
                fontName = font.fontName;
                pointSize = font.pointSize;
            } else {
                fontName = (NSString *)CFBridgingRelease(CTFontCopyName((__bridge CTFontRef)font, kCTFontPostScriptNameKey));
                pointSize = CTFontGetSize((__bridge CTFontRef)font);
            }

            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:range];
            CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, CGFloat_floor(pointSize * scale), NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }];

    return mutableAttributedString;
}

static inline NSAttributedString * NSAttributedStringBySettingColorFromContext(NSAttributedString *attributedString, UIColor *color) {
    if (!color) {
        return attributedString;
    }

    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTForegroundColorFromContextAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, __unused BOOL *stop) {
        BOOL usesColorFromContext = (BOOL)value;
        if (usesColorFromContext) {
            [mutableAttributedString setAttributes:[NSDictionary dictionaryWithObject:color forKey:(NSString *)kCTForegroundColorAttributeName] range:range];
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorFromContextAttributeName range:range];
        }
    }];

    return mutableAttributedString;
}

static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, TTUGCFLOAT_MAX);

    if (numberOfLines == 1) {
        // If there is one line, the size that fits is the full width of the line
        constraints = CGSizeMake(TTUGCFLOAT_MAX, TTUGCFLOAT_MAX);
    } else if (numberOfLines > 0) {
        // If the line count of the label more than 1, limit the range to size to the number of lines that have been set
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, TTUGCFLOAT_MAX));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);

        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);

            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }

        CFRelease(frame);
        CGPathRelease(path);
    }

    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);

    return CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
}

static inline long CTFramesetterSuggestNumberOfLinesForAttributedStringWithConstraints(CTFramesetterRef framesetter, CGFloat width) {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, width, TTUGCFLOAT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    long count = CFArrayGetCount(lines);
    CFRelease(frame);
    CGPathRelease(path);
    return count;
}

@interface TTUGCAttributedLabel ()
@property (readwrite, nonatomic, copy) NSAttributedString *inactiveAttributedText;
@property (readwrite, nonatomic, copy) NSAttributedString *renderedAttributedText;
@property (readwrite, nonatomic, strong) NSArray *linkModels;
@property (readwrite, nonatomic, strong) TTUGCAttributedLabelLink *activeLink;
@property (readwrite, nonatomic, assign) NSRange truncatedTokenRange; // 相对于 truncatedLine 的 range
@property (readwrite, nonatomic, assign) CGRect truncatedTokenRect; // 相对于 lineLine 的 rect

- (void) longPressGestureDidFire:(UILongPressGestureRecognizer *)sender;
@end

@implementation TTUGCAttributedLabel {
@private
    BOOL _needsFramesetter;
    CTFramesetterRef _framesetter;
    CTFramesetterRef _highlightFramesetter;
}

@dynamic text;
@synthesize attributedText = _attributedText;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    [self commonInit];

    return self;
}

- (void)commonInit {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;

    self.textInsets = UIEdgeInsetsZero;
    self.lineHeightMultiple = 1.0f;

    self.linkModels = [NSArray array];

    self.linkBackgroundEdgeInset = UIEdgeInsetsMake(0.0f, -1.0f, 0.0f, -1.0f);

    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];

    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];

    NSMutableDictionary *mutableInactiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableInactiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];

    if ([NSMutableParagraphStyle class]) {
        [mutableLinkAttributes setObject:[UIColor blueColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:[UIColor redColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:[UIColor grayColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    } else {
        [mutableLinkAttributes setObject:(__bridge id)[[UIColor blueColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:(__bridge id)[[UIColor redColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:(__bridge id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }

    self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    self.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    self.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableInactiveLinkAttributes];
    _extendsLinkTouchArea = NO;
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(longPressGestureDidFire:)];
    self.longPressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)dealloc {
    if (_framesetter) {
        CFRelease(_framesetter);
    }

    if (_highlightFramesetter) {
        CFRelease(_highlightFramesetter);
    }
    
    if (_longPressGestureRecognizer) {
        [self removeGestureRecognizer:_longPressGestureRecognizer];
    }
}

#pragma mark -

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString
                       withConstraints:(CGSize)size
                limitedToNumberOfLines:(NSUInteger)numberOfLines
{
    if (!attributedString || attributedString.length == 0) {
        return CGSizeZero;
    }

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);

    CGSize calculatedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, attributedString, size, numberOfLines);

    CFRelease(framesetter);

    return calculatedSize;
}

+ (long)numberOfLinesAttributedString:(NSAttributedString *)attributedString withConstraints:(CGFloat) width{
    if (!attributedString || attributedString.length == 0) {
        return 0;
    }

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);

    long number = CTFramesetterSuggestNumberOfLinesForAttributedStringWithConstraints(framesetter, width);

    CFRelease(framesetter);

    return number;
}

#pragma mark -

- (void)setAttributedText:(NSAttributedString *)text {
    if ([text isEqualToAttributedString:_attributedText]) {
        return;
    }

    _attributedText = [text copy];

    [self setNeedsFramesetter];
    [self setNeedsDisplay];

    if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
        [self invalidateIntrinsicContentSize];
    }

    [super setText:[self.attributedText string]];
}

- (NSAttributedString *)renderedAttributedText {
    if (!_renderedAttributedText) {
        self.renderedAttributedText = NSAttributedStringBySettingColorFromContext(self.attributedText, self.textColor);
    }

    return _renderedAttributedText;
}

- (NSArray *)links {
    return [_linkModels valueForKey:@"result"];
}

- (void)setNeedsFramesetter {
    // Reset the rendered attributed text so it has a chance to regenerate
    self.renderedAttributedText = nil;

    _needsFramesetter = YES;
}

- (CTFramesetterRef)framesetter {
    if (_needsFramesetter) {
        @synchronized(self) {
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.renderedAttributedText);
            [self setFramesetter:framesetter];
            [self setHighlightFramesetter:nil];
            _needsFramesetter = NO;

            if (framesetter) {
                CFRelease(framesetter);
            }
        }
    }

    return _framesetter;
}

- (void)setFramesetter:(CTFramesetterRef)framesetter {
    if (framesetter) {
        CFRetain(framesetter);
    }

    if (_framesetter) {
        CFRelease(_framesetter);
    }

    _framesetter = framesetter;
}

- (CTFramesetterRef)highlightFramesetter {
    return _highlightFramesetter;
}

- (void)setHighlightFramesetter:(CTFramesetterRef)highlightFramesetter {
    if (highlightFramesetter) {
        CFRetain(highlightFramesetter);
    }

    if (_highlightFramesetter) {
        CFRelease(_highlightFramesetter);
    }

    _highlightFramesetter = highlightFramesetter;
}

#pragma mark -

- (void)addLink:(TTUGCAttributedLabelLink *)link {
    [self addLinks:@[link]];
}

- (void)addLinks:(NSArray *)links {
    NSMutableArray *mutableLinkModels = [NSMutableArray arrayWithArray:self.linkModels];
    
    NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];

    for (TTUGCAttributedLabelLink *link in links) {
        if (link.attributes) {
            [mutableAttributedString addAttributes:link.attributes range:link.result.range];
        }
    }

    self.attributedText = mutableAttributedString;
    [self setNeedsDisplay];

    [mutableLinkModels addObjectsFromArray:links];
    
    self.linkModels = [NSArray arrayWithArray:mutableLinkModels];
}

- (TTUGCAttributedLabelLink *)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result
                                               attributes:(NSDictionary *)attributes
{
    return [self addLinksWithTextCheckingResults:@[result] attributes:attributes].firstObject;
}

- (NSArray *)addLinksWithTextCheckingResults:(NSArray *)results
                                  attributes:(NSDictionary *)attributes
{
    NSMutableArray *links = [NSMutableArray array];
    
    for (NSTextCheckingResult *result in results) {
        NSDictionary *activeAttributes = attributes ? self.activeLinkAttributes : nil;
        NSDictionary *inactiveAttributes = attributes ? self.inactiveLinkAttributes : nil;
        
        TTUGCAttributedLabelLink *link = [[TTUGCAttributedLabelLink alloc] initWithAttributes:attributes
                                                                         activeAttributes:activeAttributes
                                                                       inactiveAttributes:inactiveAttributes
                                                                       textCheckingResult:result];
        
        [links addObject:link];
    }
    
    [self addLinks:links];
    
    return links;
}

- (TTUGCAttributedLabelLink *)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    return [self addLinkWithTextCheckingResult:result attributes:self.linkAttributes];
}

- (TTUGCAttributedLabelLink *)addLinkToURL:(NSURL *)url
                               withRange:(NSRange)range
{
    return [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:range URL:url]];
}

#pragma mark -

- (BOOL)containsLinkAtPoint:(CGPoint)point {
    return [self linkAtPoint:point] != nil;
}

- (TTUGCAttributedLabelLink *)linkAtPoint:(CGPoint)point {
    
    // Stop quickly if none of the points to be tested are in the bounds.
    if (!CGRectContainsPoint(CGRectInset(self.bounds, -15.f, -15.f), point) || self.links.count == 0) {
        return nil;
    }
    
    TTUGCAttributedLabelLink *result = [self linkAtCharacterIndex:[self characterIndexAtPoint:point]];
    
    if (!result && self.extendsLinkTouchArea) {
        result = [self linkAtRadius:2.5f aroundPoint:point]
              ?: [self linkAtRadius:5.f aroundPoint:point]
              ?: [self linkAtRadius:7.5f aroundPoint:point]
              ?: [self linkAtRadius:12.5f aroundPoint:point]
              ?: [self linkAtRadius:15.f aroundPoint:point];
    }
    
    return result;
}

- (TTUGCAttributedLabelLink *)linkAtRadius:(const CGFloat)radius aroundPoint:(CGPoint)point {
    const CGFloat diagonal = CGFloat_sqrt(2 * radius * radius);
    const CGPoint deltas[] = {
        CGPointMake(0, -radius), CGPointMake(0, radius), // Above and below
        CGPointMake(-radius, 0), CGPointMake(radius, 0), // Beside
        CGPointMake(-diagonal, -diagonal), CGPointMake(-diagonal, diagonal),
        CGPointMake(diagonal, diagonal), CGPointMake(diagonal, -diagonal) // Diagonal
    };
    const size_t count = sizeof(deltas) / sizeof(CGPoint);
    
    TTUGCAttributedLabelLink *link = nil;
    
    for (NSUInteger i = 0; i < count && link.result == nil; i ++) {
        CGPoint currentPoint = CGPointMake(point.x + deltas[i].x, point.y + deltas[i].y);
        link = [self linkAtCharacterIndex:[self characterIndexAtPoint:currentPoint]];
    }
    
    return link;
}

- (TTUGCAttributedLabelLink *)linkAtCharacterIndex:(CFIndex)idx {
    // Do not enumerate if the index is outside of the bounds of the text.
    if (!NSLocationInRange((NSUInteger)idx, NSMakeRange(0, self.attributedText.length))) {
        return nil;
    }
    
    NSEnumerator *enumerator = [self.linkModels reverseObjectEnumerator];
    TTUGCAttributedLabelLink *link = nil;
    while ((link = [enumerator nextObject])) {
        if (NSLocationInRange((NSUInteger)idx, link.result.range)) {
            return link;
        }
    }

    return nil;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)p {
    if (!CGRectContainsPoint(self.bounds, p)) {
        return NSNotFound;
    }

    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    if (!CGRectContainsPoint(textRect, p)) {
        return NSNotFound;
    }

    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, textRect.size.height - p.y);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame([self framesetter], CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);
    if (frame == NULL) {
        CGPathRelease(path);
        return NSNotFound;
    }

    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CGPathRelease(path);
        return NSNotFound;
    }

    CFIndex idx = NSNotFound;

    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);

    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);

        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = TTUGCFlushFactorForTextAlignment(self.textAlignment);
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
        lineOrigin.x = penOffset;

        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
            }
        }

        // EXCEPTION: determine point in truncation token rect. (high priority)
        if (!CGRectIsNull(self.truncatedTokenRect) && self.truncatedTokenRange.location != NSNotFound) {
            if (CGRectContainsPoint(self.truncatedTokenRect, p)) {
                idx = self.truncatedTokenRange.location;
                break;
            }
        }

        if (idx != NSNotFound) {
            // sometimes, point in truncation token rect, but return wrong idx value in CTLineGetStringIndexForPosition method call.
            // because last truncated line drown on the label, are not the same line in enumerator.
            // case, setText of one hundred "👍" characters.
            break;
        }
    }

    CFRelease(frame);
    CGPathRelease(path);

    return idx;
}

#pragma mark - draw

- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c
{
    // here, rect is textRect, including textInsets
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);

    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    BOOL truncateLastLine = (self.lineBreakMode == TTUGCLineBreakByTruncatingHead || self.lineBreakMode == TTUGCLineBreakByTruncatingMiddle || self.lineBreakMode == TTUGCLineBreakByTruncatingTail);

    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);

    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

        CGFloat descent = 0.0f;
        CTLineGetTypographicBounds((CTLineRef)line, NULL, &descent, NULL);

        // Adjust pen offset for flush depending on text alignment
        CGFloat flushFactor = TTUGCFlushFactorForTextAlignment(self.textAlignment);

        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);

            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                CTLineTruncationType truncationType;
                CFIndex truncationAttributePosition = lastLineRange.location;
                TTUGCLineBreakMode lineBreakMode = self.lineBreakMode;

                // Multiple lines, only use UILineBreakModeTailTruncation
                if (numberOfLines != 1) {
                    lineBreakMode = TTUGCLineBreakByTruncatingTail;
                }

                switch (lineBreakMode) {
                    case TTUGCLineBreakByTruncatingHead:
                        truncationType = kCTLineTruncationStart;
                        break;
                    case TTUGCLineBreakByTruncatingMiddle:
                        truncationType = kCTLineTruncationMiddle;
                        truncationAttributePosition += (lastLineRange.length / 2);
                        break;
                    case TTUGCLineBreakByTruncatingTail:
                    default:
                        truncationType = kCTLineTruncationEnd;
                        truncationAttributePosition += (lastLineRange.length - 1);
                        break;
                }

                NSAttributedString *attributedTruncationString = self.attributedTruncationToken;
                if (!attributedTruncationString) {
                    NSString *truncationTokenString = @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)

                    NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];

                    attributedTruncationString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                }
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTruncationString);

                // Append truncationToken to the string
                // because if string isn't too long, CT won't add the truncationToken on its own.
                // There is no chance of a double truncationToken because CT only adds the
                // token if it removes characters (and the one we add will go first)
                NSMutableAttributedString *truncationString = [[NSMutableAttributedString alloc] initWithAttributedString:
                                                               [attributedString attributedSubstringFromRange:
                                                                NSMakeRange((NSUInteger)lastLineRange.location,
                                                                            (NSUInteger)lastLineRange.length)]];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTruncationString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);

                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }

                CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);

                CTLineDraw(truncatedLine, c);

                NSRange linkRange;
                if ([attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange]) {
                    /**
                     * CASE: truncatedString: @"亮不，傻B，回答的这牛头不对马嘴\U0000fffc...全文"
                     * In iPhone 6, rendered text is @"亮不，傻B，回答的这牛头不对...全文"
                     * NOTICE: CTLineGetStringRange(truncatedLine).count returns 22, but CTLineGetGlyphCount(truncatedLine) returns 19.
                     * It seems like CTLineGetStringRange return value according to truncatedString length, but CTLineGetGlyphCount as rendered text length.
                     * So, using CTLineGetGlyphCount to calculate the truncationTokenRange, and drawAttachments method also using glyph runs to calculate the range to avoid drawing.
                     **/
                    CFIndex truncatedLineGlyphCount = CTLineGetGlyphCount(truncatedLine);
                    CFIndex truncationTokenGlyphCount = CTLineGetGlyphCount(truncationToken);
                    NSRange truncationTokenRange = NSMakeRange((NSUInteger)(lastLineRange.location+truncatedLineGlyphCount)-(NSUInteger)truncationTokenGlyphCount, (NSUInteger)truncationTokenGlyphCount);

                    /**
                     * EXCEPTION. truncated text length is less than truncationToken length.
                     * CASE: the last attributedString: @"\U0000fffc\U0000fffc\U0000fffc\U0000fffc\U0000fffc\U0000fffc"
                     * append truncationToken at the third \U0000fffc. So, the truncationTokenRange will exceed the original attributedText length.
                     **/
                    if (NSMaxRange(truncationTokenRange) > self.attributedText.length) {
                        truncationTokenRange.length = self.attributedText.length - truncationTokenRange.location;
                    }

                    if (NSMaxRange(truncationTokenRange) <= self.attributedText.length) {
                        self.truncatedTokenRange = truncationTokenRange;

                        CGRect truncationTokenRect = CTLineGetBoundsWithOptions(truncationToken, 0);
                        double truncatedLineWidth = CTLineGetTypographicBounds(truncatedLine, NULL, NULL, NULL);
                        self.truncatedTokenRect = CGRectMake(lineOrigin.x + truncatedLineWidth - truncationTokenRect.size.width, lineOrigin.y - descent - self.font.descender - self.font.lineHeight + self.font.pointSize, truncationTokenRect.size.width, truncationTokenRect.size.height + self.font.lineHeight - self.font.pointSize);

                        // addLinks will reset attributedText and render again, but have no influence on attributedTruncationToken style.
                        [self addLinkToURL:[attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange] withRange:truncationTokenRange]; 
                    }
                }

                CFRelease(truncatedLine);
                CFRelease(truncationLine);
                CFRelease(truncationToken);
            } else {
                CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
                CTLineDraw(line, c);
            }
        } else {
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
            CTLineDraw(line, c);
        }
    }

    [self drawAttachments:frame inRect:rect context:c];

    CFRelease(frame);
    CGPathRelease(path);
}

- (void)drawAttachments:(CTFrameRef)frame inRect:(__unused CGRect)rect context:(CGContextRef)context {
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, lines.count) : lines.count;
    CGPoint origins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), origins);

    CFIndex lineIndex = 0;
    for (id line in lines) {
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat) CTLineGetTypographicBounds((__bridge CTLineRef) line, &ascent, &descent, &leading);

        for (id glyphRun in (__bridge NSArray *) CTLineGetGlyphRuns((__bridge CTLineRef) line)) {
            NSDictionary *runAttributes = (__bridge NSDictionary *) CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) continue;

            TTUGCEmojiTextAttachment *refCon = (TTUGCEmojiTextAttachment *) CTRunDelegateGetRefCon(delegate);
            if (!refCon || ![refCon isKindOfClass:[TTUGCEmojiTextAttachment class]]) {
                continue;
            }

            TTUGCEmojiTextAttachment *attachment = refCon;
            if (attachment) {
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);

                if (self.truncatedTokenRange.location != NSNotFound && glyphRange.location >= self.truncatedTokenRange.location) {
                    continue;
                }

                UIImage *coreTextImage = attachment.coreTextImage;
                if (!coreTextImage) continue;

                UIImage *image = nil;
                if ([coreTextImage isKindOfClass:[UIImage class]]) {
                    image = coreTextImage;
                }

                if (!image) continue;

                CGPoint runPosition = CGPointZero;
                CTRunGetPositions((__bridge CTRunRef) glyphRun, CFRangeMake(0, 1), &runPosition);

                CGRect runBounds = CGRectZero;
                CGFloat runWidth = coreTextImage.size.width / coreTextImage.size.height * attachment.emojiSize;
                CGFloat runHeight = attachment.emojiSize;

                runPosition.x += origins[lineIndex].x;
                runPosition.y += origins[lineIndex].y;
                runPosition.y += (ascent + descent - runHeight) / 2 - descent;

                runBounds = CGRectMake(runPosition.x, runPosition.y, runWidth, runHeight);

                // Don't draw strikeout too far to the right
                if (CGRectGetWidth(runBounds) > width) {
                    runBounds.size.width = width;
                }

                CGImageRef ref = image.CGImage;
                if (ref) {
//                    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
//                    CGContextFillRect(context, runBounds);
                    CGContextDrawImage(context, runBounds, ref);
                }
            }
        }

        lineIndex++;
    }
}

#pragma mark - TTUGCAttributedLabel

- (void)setText:(id)text {
    NSParameterAssert(!text || [text isKindOfClass:[NSAttributedString class]] || [text isKindOfClass:[NSString class]]);

    if ([text isKindOfClass:[NSString class]]) {
        [self setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
        return;
    }

    self.attributedText = text;
    self.activeLink = nil;
    self.truncatedTokenRange = NSMakeRange(NSNotFound, 0);
    self.truncatedTokenRect = CGRectNull;

    self.linkModels = [NSArray array];

    [self.attributedText enumerateAttribute:NSLinkAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(id value, __unused NSRange range, __unused BOOL *stop) {
        if (value) {
            NSURL *URL = [value isKindOfClass:[NSString class]] ? [NSURL URLWithString:value] : value;
            [self addLinkToURL:URL withRange:range];
        }
    }];
}

- (void)setText:(id)text
afterInheritingLabelAttributesAndConfiguringWithBlock:(NSMutableAttributedString * (^)(NSMutableAttributedString *mutableAttributedString))block
{
    NSMutableAttributedString *mutableAttributedString = nil;
    if ([text isKindOfClass:[NSString class]]) {
        mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:NSAttributedStringAttributesFromLabel(self)];
    } else {
        mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [mutableAttributedString addAttributes:NSAttributedStringAttributesFromLabel(self) range:NSMakeRange(0, [mutableAttributedString length])];
    }

    if (block) {
        mutableAttributedString = block(mutableAttributedString);
    }

    [self setText:mutableAttributedString];
}

- (void)setActiveLink:(TTUGCAttributedLabelLink *)activeLink {
    _activeLink = activeLink;

    NSDictionary *activeAttributes = activeLink.activeAttributes ?: self.activeLinkAttributes;

    if (_activeLink && activeAttributes.count > 0) {
        if (!self.inactiveAttributedText) {
            self.inactiveAttributedText = [self.attributedText copy];
        }

        NSMutableAttributedString *mutableAttributedString = [self.inactiveAttributedText mutableCopy];
        if (self.activeLink.result.range.length > 0 && NSLocationInRange(NSMaxRange(self.activeLink.result.range) - 1, NSMakeRange(0, [self.inactiveAttributedText length]))) {
            [mutableAttributedString addAttributes:activeAttributes range:self.activeLink.result.range];
        }

        self.attributedText = mutableAttributedString;
        [self setNeedsDisplay];

        [CATransaction flush];
    } else if (self.inactiveAttributedText) {
        self.attributedText = self.inactiveAttributedText;
        self.inactiveAttributedText = nil;

        [self setNeedsDisplay];
    }
}

- (void)setLinkAttributes:(NSDictionary *)linkAttributes {
    _linkAttributes = convertNSAttributedStringAttributesToCTAttributes(linkAttributes);
}

- (void)setActiveLinkAttributes:(NSDictionary *)activeLinkAttributes {
    _activeLinkAttributes = convertNSAttributedStringAttributesToCTAttributes(activeLinkAttributes);
}

- (void)setInactiveLinkAttributes:(NSDictionary *)inactiveLinkAttributes {
    _inactiveLinkAttributes = convertNSAttributedStringAttributesToCTAttributes(inactiveLinkAttributes);
}

#pragma mark - UILabel

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

// Fixes crash when loading from a UIStoryboard
- (UIColor *)textColor {
	UIColor *color = [super textColor];
	if (!color) {
		color = [UIColor blackColor];
	}

	return color;
}

- (void)setTextColor:(UIColor *)textColor {
    UIColor *oldTextColor = self.textColor;
    [super setTextColor:textColor];

    // Redraw to allow any ColorFromContext attributes a chance to update
    if (textColor != oldTextColor) {
        [self setNeedsFramesetter];
        [self setNeedsDisplay];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
     limitedToNumberOfLines:(NSInteger)numberOfLines
{
    bounds = UIEdgeInsetsInsetRect(bounds, self.textInsets);
    if (!self.attributedText) {
        return [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    }

    CGRect textRect = bounds;

    // Calculate height with a minimum of double the font pointSize, to ensure that CTFramesetterSuggestFrameSizeWithConstraints doesn't return CGSizeZero, as it would if textRect height is insufficient.
    textRect.size.height = MAX(self.font.lineHeight * MAX(2, numberOfLines), bounds.size.height);

    // Adjust the text to be in the center vertically, if the text size is smaller than bounds
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints([self framesetter], CFRangeMake(0, (CFIndex)[self.attributedText length]), NULL, textRect.size, NULL);
    textSize = CGSizeMake(CGFloat_ceil(textSize.width), CGFloat_ceil(textSize.height)); // Fix for iOS 4, CTFramesetterSuggestFrameSizeWithConstraints sometimes returns fractional sizes

    if (textSize.height < bounds.size.height) {
        CGFloat yOffset = 0.0f;
        switch (self.verticalAlignment) {
            case TTUGCAttributedLabelVerticalAlignmentCenter:
                yOffset = CGFloat_floor((bounds.size.height - textSize.height) / 2.0f);
                break;
            case TTUGCAttributedLabelVerticalAlignmentBottom:
                yOffset = bounds.size.height - textSize.height;
                break;
            case TTUGCAttributedLabelVerticalAlignmentTop:
            default:
                break;
        }

        textRect.origin.y += yOffset;
    }

    return textRect;
}

- (void)drawTextInRect:(CGRect)rect {
    [self drawTextInRect:rect context:nil];
}

- (void)drawTextInRect:(CGRect)rect context:(CGContextRef)context {
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    if (!self.attributedText) {
        [super drawTextInRect:insetRect];
        return;
    }

    NSAttributedString *originalAttributedText = nil;

    // Adjust the font size to fit width, if necessary
    if (self.adjustsFontSizeToFitWidth && self.numberOfLines > 0) {
        // Framesetter could still be working with a resized version of the text;
        // need to reset so we start from the original font size.
        // See #393.
        [self setNeedsFramesetter];
        [self setNeedsDisplay];
        
        if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
            [self invalidateIntrinsicContentSize];
        }
        
        // Use infinite width to find the max width, which will be compared to availableWidth if needed.
        CGSize maxSize = (self.numberOfLines > 1) ? CGSizeMake(TTUGCFLOAT_MAX, TTUGCFLOAT_MAX) : CGSizeZero;

        CGFloat textWidth = [self sizeThatFits:maxSize].width;
        CGFloat availableWidth = self.frame.size.width * self.numberOfLines;
        if (self.numberOfLines > 1 && self.lineBreakMode == TTUGCLineBreakByWordWrapping) {
            textWidth *= kTTUGCLineBreakWordWrapTextWidthScalingFactor;
        }

        if (textWidth > availableWidth && textWidth > 0.0f) {
            originalAttributedText = [self.attributedText copy];

            CGFloat scaleFactor = availableWidth / textWidth;
            if ([self respondsToSelector:@selector(minimumScaleFactor)] && self.minimumScaleFactor > scaleFactor) {
                scaleFactor = self.minimumScaleFactor;
            }

            self.attributedText = NSAttributedStringByScalingFontSize(self.attributedText, scaleFactor);
        }
    }

    CGContextRef c;
    if (context) {
        c = context;
    } else {
        c = UIGraphicsGetCurrentContext();
    }

    CGContextSaveGState(c);
    {
        CGContextSetTextMatrix(c, CGAffineTransformIdentity);

        // Inverts the CTM to match iOS coordinates (otherwise text draws upside-down; Mac OS's system is different)
        CGContextTranslateCTM(c, 0.0f, insetRect.size.height);
        CGContextScaleCTM(c, 1.0f, -1.0f);

        CFRange textRange = CFRangeMake(0, (CFIndex)[self.attributedText length]);

        // First, get the text rect (which takes vertical centering into account)
        CGRect textRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];

        // CoreText draws its text aligned to the bottom, so we move the CTM here to take our vertical offsets into account
        CGContextTranslateCTM(c, insetRect.origin.x, insetRect.size.height - textRect.origin.y - textRect.size.height);

        // Second, trace the shadow before the actual text, if we have one
        if (self.shadowColor && !self.highlighted) {
            CGContextSetShadowWithColor(c, self.shadowOffset, self.shadowRadius, [self.shadowColor CGColor]);
        } else if (self.highlightedShadowColor) {
            CGContextSetShadowWithColor(c, self.highlightedShadowOffset, self.highlightedShadowRadius, [self.highlightedShadowColor CGColor]);
        }

        // Finally, draw the text or highlighted text itself (on top of the shadow, if there is one)
        if (self.highlightedTextColor && self.highlighted) {
            NSMutableAttributedString *highlightAttributedString = [self.renderedAttributedText mutableCopy];
            [highlightAttributedString addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(id)[self.highlightedTextColor CGColor] range:NSMakeRange(0, highlightAttributedString.length)];

            if (![self highlightFramesetter]) {
                CTFramesetterRef highlightFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)highlightAttributedString);
                [self setHighlightFramesetter:highlightFramesetter];
                CFRelease(highlightFramesetter);
            }

            [self drawFramesetter:[self highlightFramesetter] attributedString:highlightAttributedString textRange:textRange inRect:textRect context:c];
        } else {
            [self drawFramesetter:[self framesetter] attributedString:self.renderedAttributedText textRange:textRange inRect:textRect context:c];
        }

        // If we adjusted the font size, set it back to its original size
        if (originalAttributedText) {
            // Use ivar directly to avoid clearing out framesetter and renderedAttributedText
            _attributedText = originalAttributedText;
        }
    }
    CGContextRestoreGState(c);
}

#pragma mark - UIView

- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.attributedText) {
        return [super sizeThatFits:size];
    } else {
        NSAttributedString *string = [self renderedAttributedText];
        
        CGSize labelSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints([self framesetter], string, size, (NSUInteger)self.numberOfLines);
        labelSize.width += self.textInsets.left + self.textInsets.right;
        labelSize.height += self.textInsets.top + self.textInsets.bottom;

        return labelSize;
    }
}

- (CGSize)intrinsicContentSize {
    // There's an implicit width from the original UILabel implementation
    return [self sizeThatFits:[super intrinsicContentSize]];
}

- (void)tintColorDidChange {
    if (!self.inactiveLinkAttributes || [self.inactiveLinkAttributes count] == 0) {
        return;
    }

    BOOL isInactive = (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed);

    NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
    for (TTUGCAttributedLabelLink *link in self.linkModels) {
        NSDictionary *attributesToRemove = isInactive ? link.attributes : link.inactiveAttributes;
        NSDictionary *attributesToAdd = isInactive ? link.inactiveAttributes : link.attributes;
        
        [attributesToRemove enumerateKeysAndObjectsUsingBlock:^(NSString *name, __unused id value, __unused BOOL *stop) {
            if (NSMaxRange(link.result.range) <= mutableAttributedString.length) {
                [mutableAttributedString removeAttribute:name range:link.result.range];
            }
        }];

        if (attributesToAdd) {
            if (NSMaxRange(link.result.range) <= mutableAttributedString.length) {
                [mutableAttributedString addAttributes:attributesToAdd range:link.result.range];
            }
        }
    }

    self.attributedText = mutableAttributedString;

    [self setNeedsDisplay];
}

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    if (![self linkAtPoint:point] || !self.userInteractionEnabled || self.hidden || self.alpha < 0.01) {
        return [super hitTest:point withEvent:event];
    }

    return self;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(__unused id)sender
{
    return (action == @selector(copy:));
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    self.activeLink = [self linkAtPoint:[touch locationInView:self]];

    if (!self.activeLink) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        UITouch *touch = [touches anyObject];

        if (self.activeLink != [self linkAtPoint:[touch locationInView:self]]) {
            self.activeLink = nil;
        }
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        if (self.activeLink.linkTapBlock) {
            self.activeLink.linkTapBlock(self, self.activeLink);
            self.activeLink = nil;
            return;
        }
        
        NSTextCheckingResult *result = self.activeLink.result;
        self.activeLink = nil;

        switch (result.resultType) {
            case NSTextCheckingTypeLink:
                if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithURL:)]) {
                    [self.delegate attributedLabel:self didSelectLinkWithURL:result.URL];
                    return;
                }
                break;
            default:
                break;
        }

        // Fallback to `attributedLabel:didSelectLinkWithTextCheckingResult:` if no other delegate method matched.
        if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectLinkWithTextCheckingResult:)]) {
            [self.delegate attributedLabel:self didSelectLinkWithTextCheckingResult:result];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        self.activeLink = nil;
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self containsLinkAtPoint:[touch locationInView:self]];
}

#pragma mark - UILongPressGestureRecognizer

- (void)longPressGestureDidFire:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint touchPoint = [sender locationInView:self];
            TTUGCAttributedLabelLink *link = [self linkAtPoint:touchPoint];
            
            if (link) {
                if (link.linkLongPressBlock) {
                    link.linkLongPressBlock(self, link);
                    return;
                }
                
                NSTextCheckingResult *result = link.result;
                
                if (!result) {
                    return;
                }
                
                switch (result.resultType) {
                    case NSTextCheckingTypeLink:
                        if ([self.delegate respondsToSelector:@selector(attributedLabel:didLongPressLinkWithURL:atPoint:)]) {
                            [self.delegate attributedLabel:self didLongPressLinkWithURL:result.URL atPoint:touchPoint];
                            return;
                        }
                        break;
                    default:
                        break;
                }
                
                // Fallback to `attributedLabel:didLongPressLinkWithTextCheckingResult:atPoint:` if no other delegate method matched.
                if ([self.delegate respondsToSelector:@selector(attributedLabel:didLongPressLinkWithTextCheckingResult:atPoint:)]) {
                    [self.delegate attributedLabel:self didLongPressLinkWithTextCheckingResult:result atPoint:touchPoint];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
}

@end

@implementation TTUGCAttributedLabelLink

- (instancetype)initWithAttributes:(NSDictionary *)attributes
                  activeAttributes:(NSDictionary *)activeAttributes
                inactiveAttributes:(NSDictionary *)inactiveAttributes
                textCheckingResult:(NSTextCheckingResult *)result {
    
    if ((self = [super init])) {
        _result = result;
        _attributes = [attributes copy];
        _activeAttributes = [activeAttributes copy];
        _inactiveAttributes = [inactiveAttributes copy];
    }
    
    return self;
}

- (instancetype)initWithAttributesFromLabel:(TTUGCAttributedLabel *)label
                         textCheckingResult:(NSTextCheckingResult *)result {
    
    return [self initWithAttributes:label.linkAttributes
                   activeAttributes:label.activeLinkAttributes
                 inactiveAttributes:label.inactiveLinkAttributes
                 textCheckingResult:result];
}

@end

#pragma mark - 

static inline CGColorRef CGColorRefFromColor(id color) {
    return [color isKindOfClass:[UIColor class]] ? [color CGColor] : (__bridge CGColorRef)color;
}

static inline CTFontRef CTFontRefFromUIFont(UIFont * font) {
    CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    return CFAutorelease(ctfont);
}

static inline NSDictionary * convertNSAttributedStringAttributesToCTAttributes(NSDictionary *attributes) {
    if (!attributes) return nil;

    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];

    NSDictionary *NSToCTAttributeNamesMap = @{
        NSFontAttributeName:            (NSString *)kCTFontAttributeName,
        NSBackgroundColorAttributeName: (NSString *)kTTUGCBackgroundFillColorAttributeName,
        NSForegroundColorAttributeName: (NSString *)kCTForegroundColorAttributeName,
        NSUnderlineColorAttributeName:  (NSString *)kCTUnderlineColorAttributeName,
        NSUnderlineStyleAttributeName:  (NSString *)kCTUnderlineStyleAttributeName,
        NSStrokeWidthAttributeName:     (NSString *)kCTStrokeWidthAttributeName,
        NSStrokeColorAttributeName:     (NSString *)kCTStrokeWidthAttributeName,
        NSKernAttributeName:            (NSString *)kCTKernAttributeName,
        NSLigatureAttributeName:        (NSString *)kCTLigatureAttributeName
    };

    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        key = [NSToCTAttributeNamesMap objectForKey:key] ? : key;

        if (![NSMutableParagraphStyle class]) {
            if ([value isKindOfClass:[UIFont class]]) {
                value = (__bridge id)CTFontRefFromUIFont(value);
            } else if ([value isKindOfClass:[UIColor class]]) {
                value = (__bridge id)((UIColor *)value).CGColor;
            }
        }

        [mutableAttributes setObject:value forKey:key];
    }];

    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}
