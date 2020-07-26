//
//  FHLynxRichTextShadow.m
//  Pods
//
//  Created by fupeidong on 2020/6/30.
//

#import "FHLynxRichTextShadow.h"
#import "LynxComponentRegistry.h"
#import "LynxPropsProcessor.h"
#import "FRichSpanModel.h"
#import "FHMainApi.h"
#import "FHCommonDefines.h"
#import <Lynx/LynxTextRendererCache.h>

@interface FLineSpacingAdaptation : NSObject <NSLayoutManagerDelegate>
@property(nonatomic) CGFloat calculatedLineSpacing;
@property(nonatomic) BOOL adjustBaseLineOffsetForVerticalAlignCenter;
@end

// This is an adaptaion for one of the bug of line spacing in TextKit that
// the last line will disappeare when both maxNumberOfLines and lineSpacing are set.
//
// FIXME(yxping): there still another bug that both height and lineSpacing are set,
// the last line in the visible area will disappeare.
@implementation FLineSpacingAdaptation

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager
    shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect
         lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect
               baselineOffset:(inout CGFloat *)baselineOffset
              inTextContainer:(NSTextContainer *)textContainer
                forGlyphRange:(NSRange)glyphRange {
  if (_adjustBaseLineOffsetForVerticalAlignCenter) {
    *baselineOffset = (*lineFragmentRect).size.height;
  }
  if (ABS(_calculatedLineSpacing) < FLT_EPSILON) {
    return NO;
  }
  CGRect rect = *lineFragmentRect;
  // We add lineSpacing to lineFragmentRect instead of adding to lineFragmentUsedRect
  // to avoid last sentance have a extra lineSpacing pading.
  CGFloat lineSpacing = 10;
  rect.size.height += lineSpacing;
  *lineFragmentRect = rect;
  return YES;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager
    lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex
    withProposedLineFragmentRect:(CGRect)rect {
  // Do not include lineSpacing in lineFragmentUsedRect to avoid last line disappearing
  return 0;
}

@end

@interface FHLynxRichTextShadow()

@property(nonatomic, strong) NSMutableAttributedString *attrStr;
@property(nonatomic) LynxTextRenderer *textRenderer;
@property(nonatomic) FLineSpacingAdaptation *lineSpacingAdaptation;

@property(readwrite, nonatomic, assign) LynxTextOverflow textOverflow;
@property(readwrite, nonatomic, assign) LynxWhiteSpace whiteSpace;
@property(readwrite, nonatomic, assign) NSInteger maxLineNum;

@end

@implementation FHLynxRichTextShadow

LYNX_REGISTER_SHADOW_NODE("f-rich-text")

- (instancetype)initWithSign:(NSInteger)sign tagName:(NSString *)tagName {
  self = [super initWithSign:sign tagName:tagName];
  if (self) {
    _lineSpacingAdaptation = [FLineSpacingAdaptation new];
  }
  return self;
}

- (void)adoptNativeLayoutNode:(int64_t)ptr {
  [super adoptNativeLayoutNode:ptr];
  [self setMeasureDelegate:self];
}

- (CGSize)measureNode:(LynxLayoutNode *)node
            withWidth:(CGFloat)width
            widthMode:(LynxMeasureMode)widthMode
               height:(CGFloat)height
           heightMode:(LynxMeasureMode)heightMode {
    LynxLayoutSpec *spec = [[LynxLayoutSpec alloc] initWithWidth:width height:height widthMode:widthMode heightMode:heightMode textOverflow:self.textOverflow overflow:LynxNoOverflow whiteSpace:self.whiteSpace maxLineNum:self.maxLineNum textStyle:self.textStyle];
//  LynxLayoutSpec *spec = [[LynxLayoutSpec alloc] initWithWidth:width
//                                                        height:height
//                                                     widthMode:widthMode
//                                                    heightMode:heightMode
//                                                  textOverflow:self.textOverflow
//                                                    whiteSpace:self.whiteSpace
//                                                    maxLineNum:self.maxLineNum
//                                                     textStyle:self.textStyle];
  spec.layoutManagerDelegate = _lineSpacingAdaptation;
  self.textRenderer = [[LynxTextRendererCache cache] rendererWithString:self.attrStr
                                                             layoutSpec:spec];
    
  NSRange range = NSMakeRange(0, _attrStr.length);

  //获取指定位置上的属性信息，并返回与指定位置属性相同并且连续的字符串的范围信息。
  NSDictionary* dic = [_attrStr attributesAtIndex:0 effectiveRange:&range];
  //不存在段落属性，则存入默认值
  NSMutableParagraphStyle *paragraphStyle = dic[NSParagraphStyleAttributeName];
  if (!paragraphStyle || nil == paragraphStyle) {
       paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
       paragraphStyle.lineSpacing = 0.0;//增加行高
       paragraphStyle.headIndent = 0;//头部缩进，相当于左padding
       paragraphStyle.tailIndent = 0;//相当于右padding
       paragraphStyle.lineHeightMultiple = 0;//行间距是多少倍
       paragraphStyle.alignment = NSTextAlignmentLeft;//对齐方式
       paragraphStyle.firstLineHeadIndent = 0;//首行头缩进
       paragraphStyle.paragraphSpacing = 0;//段落后面的间距
       paragraphStyle.paragraphSpacingBefore = 0;//段落之前的间距
//       [_attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
   }

  //设置默认字体属性
  UIFont *font = dic[NSFontAttributeName];
  if (!font || nil == font) {
       font = [UIFont systemFontOfSize:self.textStyle.fontSize];
       [_attrStr addAttribute:NSFontAttributeName value:font range:range];
   }

  NSMutableDictionary *attDic = [NSMutableDictionary dictionaryWithDictionary:dic];
  [attDic setObject:font forKey:NSFontAttributeName];
  [attDic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];

  CGSize strSize = [[_attrStr string] boundingRectWithSize:CGSizeMake(width, height)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attDic
                                             context:nil].size;
  CGSize size = self.textRenderer.size;
  CGFloat letterSpacing = self.textStyle.letterSpacing;
  if (!isnan(letterSpacing) && letterSpacing < 0) {
    size.width -= letterSpacing;
  }
//    strSize.height = 100;
  return strSize;
}

- (void)determineLineSpacing:(NSMutableAttributedString *)attributedString {
  __block CGFloat calculatedLineSpacing = 0;
  [attributedString enumerateAttribute:NSParagraphStyleAttributeName
                               inRange:NSMakeRange(0, attributedString.length)
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(NSParagraphStyle *paragraphStyle, __unused NSRange range,
                                         __unused BOOL *stop) {
                              if (paragraphStyle) {
                                calculatedLineSpacing =
                                    MAX(paragraphStyle.lineSpacing, calculatedLineSpacing);
                              }
                            }];
  _lineSpacingAdaptation.calculatedLineSpacing = calculatedLineSpacing;
}

- (void)modifyLineHeightForStorage:(NSMutableAttributedString *)storage {
  if (storage.length == 0) {
    return;
  }
  __block CGFloat minimumLineHeight = 0;
  __block CGFloat maximumLineHeight = 0;

  // Check max line-height
  [storage enumerateAttribute:NSParagraphStyleAttributeName
                      inRange:NSMakeRange(0, storage.length)
                      options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                   usingBlock:^(NSParagraphStyle *paragraphStyle, __unused NSRange range,
                                __unused BOOL *stop) {
                     if (paragraphStyle) {
                       minimumLineHeight = MAX(paragraphStyle.minimumLineHeight, minimumLineHeight);
                       maximumLineHeight = MAX(paragraphStyle.maximumLineHeight, maximumLineHeight);
                     }
                   }];

  if (minimumLineHeight == 0 && maximumLineHeight == 0) {
    return;
  }
  if ([storage attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil] == nil) {
    NSMutableParagraphStyle *newStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    newStyle.minimumLineHeight = minimumLineHeight;
    newStyle.maximumLineHeight = maximumLineHeight;
    [storage addAttribute:NSParagraphStyleAttributeName value:newStyle range:NSMakeRange(0, 1)];
  }

  [storage enumerateAttribute:NSParagraphStyleAttributeName
                      inRange:NSMakeRange(0, storage.length)
                      options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                   usingBlock:^(NSParagraphStyle *paragraphStyle, __unused NSRange range,
                                __unused BOOL *stop) {
                     if (paragraphStyle) {
                       NSMutableParagraphStyle *style = [paragraphStyle mutableCopy];
                       style.minimumLineHeight = minimumLineHeight;
                       style.maximumLineHeight = maximumLineHeight;
                       [storage addAttribute:NSParagraphStyleAttributeName value:style range:range];
                     }
                   }];
}

/**
 * Vertical align center in line
 */
- (void)addVerticalAlignCenterInline:(NSMutableAttributedString *)attributedString {
  __block CGFloat maximumLineHeight = 0;

  // Check max line-height
  [attributedString enumerateAttribute:NSParagraphStyleAttributeName
                               inRange:NSMakeRange(0, attributedString.length)
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(NSParagraphStyle *paragraphStyle, __unused NSRange range,
                                         __unused BOOL *stop) {
                              if (paragraphStyle) {
                                maximumLineHeight =
                                    MAX(paragraphStyle.maximumLineHeight, maximumLineHeight);
                              }
                            }];

  if (maximumLineHeight == 0) {
    return;
  }

  __block CGFloat maximumLineHeightOfFont = 0;
  __block CGFloat maxiumXheight = 0;

  [attributedString enumerateAttribute:NSFontAttributeName
                               inRange:NSMakeRange(0, attributedString.length)
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(UIFont *font, NSRange range, __unused BOOL *stop) {
                              if (font && maximumLineHeightOfFont <= font.lineHeight) {
                                maximumLineHeightOfFont = font.lineHeight;
                                if (maxiumXheight <= font.xHeight) {
                                  maxiumXheight = font.xHeight;
                                }
                              }
                            }];

  if (maximumLineHeight < maximumLineHeightOfFont) {
    return;
  }

  _lineSpacingAdaptation.adjustBaseLineOffsetForVerticalAlignCenter = YES;

  CGFloat baseLineOffset = 0;
  baseLineOffset = maximumLineHeight * 1 / 2 - maxiumXheight / 2;

  [attributedString addAttribute:NSBaselineOffsetAttributeName
                           value:@(baseLineOffset)
                           range:NSMakeRange(0, attributedString.length)];
}

- (void)layoutDidStart {
  [super layoutDidStart];
  NSMutableAttributedString *attrString = _attrStr ?: [[self generateAttributedString:nil] mutableCopy];
  [self determineLineSpacing:attrString];
  [self modifyLineHeightForStorage:attrString];
  [self addVerticalAlignCenterInline:attrString];
  self.attrStr = attrString;
  self.textRenderer = nil;
}

- (void)layoutDidUpdate {
  [super layoutDidUpdate];
  if (self.textRenderer == nil) {
    [self measureNode:self
            withWidth:self.frame.size.width
            widthMode:LynxMeasureModeDefinite
               height:self.frame.size.height
           heightMode:LynxMeasureModeDefinite];
  }
  // As TextShadowNode has custom layout, we have to handle children layout
  // after layout updated.
  [self updateNonVirtualOffspringLayout];
  if (self.textRenderer != nil) {
    [self postExtraDataToUI:self.textRenderer];
  }
}

/**
 * Update layout info for those non-virtual shadow node which will not layout
 * by native layout system.
 */
- (void)updateNonVirtualOffspringLayout {
  if (!self.hasNonVirtualOffspring) {
    return;
  }
  NSTextStorage *textStorage = self.textRenderer.textStorage;
  NSLayoutManager *layoutManager = textStorage.layoutManagers.firstObject;
  NSTextContainer *textContainer = layoutManager.textContainers.firstObject;
  NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
  NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange
                                                     actualGlyphRange:NULL];

  // Update child node layout info
  [textStorage
      enumerateAttribute:LynxInlineViewAttributedStringKey
                 inRange:characterRange
                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
              usingBlock:^(LynxShadowNode *node, NSRange range, BOOL *stop) {
                if (!node) {
                  return;
                }

                CGRect glyphRect = [layoutManager boundingRectForGlyphRange:range
                                                            inTextContainer:textContainer];

                // Get current line rect
                NSRange lineRange = NSMakeRange(0, 0);
                CGRect lineFragment = [layoutManager lineFragmentRectForGlyphAtIndex:range.location
                                                                      effectiveRange:&lineRange];

                // Get attachment size
                NSTextAttachment *attachment = [textStorage attribute:NSAttachmentAttributeName
                                                              atIndex:range.location
                                                       effectiveRange:nil];
                CGSize attachmentSize = attachment.bounds.size;

                // Determin final rect, make attachment center in line
                CGRect frame = {{glyphRect.origin.x + node.style.computedMarginLeft,
                                 //                 (glyphRect.origin.y + glyphRect.size.height -
                                 //                 attachmentSize.height + font.descender) / 2
                                 lineFragment.origin.y +
                                     (lineFragment.size.height - attachmentSize.height) / 2},
                                {attachmentSize.width - node.style.computedMarginLeft -
                                     node.style.computedMarginRight,
                                 attachmentSize.height}};

                [node updateLayoutWithFrame:frame];
                [node postFrameToUI:frame];
              }];
}

LYNX_PROP_SETTER("background-color", setBackgroundColor, UIColor *) {
  // Do nothing as background-color will be handle by ui
}

LYNX_PROP_SETTER("text-maxline", setMaxeLine, NSInteger) {
  if (requestReset) {
    value = LynxMaxLineNumNotSet;
  }
  if (self.maxLineNum != value) {
    if (value > 0) {
      self.maxLineNum = value;
    } else {
      self.maxLineNum = LynxMaxLineNumNotSet;
    }
    [self setNeedsLayout];
  }
}

LYNX_PROP_SETTER("white-space", setWhiteSpace, LynxWhiteSpace) {
  if (requestReset) {
    value = LynxWhiteSpaceNormal;
  }
  if (self.whiteSpace != value) {
    self.whiteSpace = value;
    [self setNeedsLayout];
  }
}

LYNX_PROP_SETTER("text-overflow", setTextOverflow, LynxTextOverflow) {
  if (requestReset) {
    value = LynxTextOverflowClip;
  }
  if (self.textOverflow != value) {
    self.textOverflow = value;
    [self setNeedsLayout];
  }
}


LYNX_PROP_SETTER("richData", setRichData, NSString*)
{
    NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
    Class cls = [FRichSpanModel class];
    __block NSError *backError = nil;
    FRichSpanModel *spanModel = [FHMainApi generateModel:jsonData class:cls error:&backError];
    if (spanModel != nil) {
            if (!IS_EMPTY_STRING(spanModel.text)) {
                self.attrStr = [[NSMutableAttributedString alloc] initWithString:spanModel.text];
                [spanModel.richText enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[FRichSpanRichTextModel class]]) {
                        FRichSpanRichTextModel *span = (FRichSpanRichTextModel *)obj;
                        if (span.highlightRange.count == 2) {
                            NSNumber* start = (NSNumber *)span.highlightRange.firstObject;
                            NSNumber* end = (NSNumber *)span.highlightRange.lastObject;
                            NSUInteger length = end.intValue - start.intValue;
                            NSRange range = NSMakeRange(start.intValue, length);
    //                        [_attrStr addAttribute:NSForegroundColorAttributeName value:_spanColor range:range];
                            [_attrStr addAttribute:NSLinkAttributeName value:span.linkUrl range:range];
                            
                        }
                    }
                }];
                [self.attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.textStyle.fontSize] range:NSMakeRange(0, spanModel.richText.count)];
                [self setNeedsLayout];
            }
        }
    
}

@end

@implementation LynxConverter (LynxWhiteSpace)

+ (LynxWhiteSpace)toLynxWhiteSpace:(id)value {
  if (!value || [value isEqual:[NSNull null]]) {
    return LynxWhiteSpaceNormal;
  }
  NSString *valueStr = [self toNSString:value];
  if ([valueStr isEqualToString:@"nowrap"]) {
    return LynxWhiteSpaceNowrap;
  } else if ([valueStr isEqualToString:@"normal"]) {
    return LynxWhiteSpaceNormal;
  }
  @throw [NSException exceptionWithName:@"LynxConverterException"
                                 reason:@"error when converting white-space"
                               userInfo:nil];
}

@end

@implementation LynxConverter (LynxTextOverflow)

+ (LynxTextOverflow)toLynxTextOverflow:(id)value {
  if (!value || [value isEqual:[NSNull null]]) {
    return LynxTextOverflowClip;
  }
  NSString *valueStr = [self toNSString:value];
  if ([valueStr isEqualToString:@"ellipsis"]) {
    return LynxTextOverflowEllipsis;
  } else if ([valueStr isEqualToString:@"clip"]) {
    return LynxTextOverflowClip;
  }
  @throw [NSException exceptionWithName:@"LynxConverterException"
                                 reason:@"error when converting text-overflow"
                               userInfo:nil];
}

@end

