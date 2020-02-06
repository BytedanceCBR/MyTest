//
//  TTAsyncLabel.m
//  Article
//
//  Created by zhaoqin on 11/11/2016.
//
//

#import "TTAsyncLabel.h"
#import "TTAsyncLayer.h"
#import "TTAsyncTextLayout.h"
#import "TTAsyncTextLine.h"
#import "TTDeviceHelper.h"
#import <CoreText/CoreText.h>

// 在 tt_onExitBlock##a 变量作用域结束后，将变量地址传入 blockCleanup 函数，并执行该函数
#define TT_ON_EXIT_UID2(a) \
__strong void(^tt_onExitBlock##a)(void)__attribute__((cleanup(blockCleanup), unused)) = ^

#define TT_ON_EXIT_UID(a) \
TT_ON_EXIT_UID2(a)

#define TT_ON_EXIT \
TT_ON_EXIT_UID(__LINE__)

// ARC 下函数参数默认为 autorelease 型，此处需要显式声明为 strong
static void blockCleanup(__strong void(^*block)(void)) {
    (*block)();
}

@interface TTAsyncLabel ()<TTAsyncLayerDelegate>
@property (nonatomic, strong) TTAsyncTextLayout *textLayout;
@property (nonatomic, assign) BOOL needTruncated;
@property (nonatomic, assign) CGRect textRect;
@end

@implementation TTAsyncLabel

+ (Class)layerClass {
    return [TTAsyncLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ((TTAsyncLayer *)self.layer).displaysAsynchronously = YES;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.contentMode = UIViewContentModeRedraw;
        _displaysAsynchronously = YES;
        _clearContentsBeforeAsynchronouslyDisplay = YES;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ((TTAsyncLayer *)self.layer).displaysAsynchronously = YES;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.contentMode = UIViewContentModeRedraw;
        _displaysAsynchronously = YES;
        _clearContentsBeforeAsynchronouslyDisplay = YES;
    }
    return self;
}

#pragma mark - Touches
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint location = CGPointMake(point.x, self.bounds.size.height - point.y);
    CGPoint linkLocation = CGPointMake(point.x, point.y);
    
    CGSize truncationSize = [self.attributedTruncationToken boundingRectWithSize:CGSizeMake(self.textLayout.truncatedLine.lineWidth, self.textLayout.truncatedLine.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    CGRect truncationRect = CGRectZero;
    truncationRect.size.height = self.textLayout.truncatedLine.height;
    truncationRect.size.width = self.textLayout.truncatedLine.lineWidth;
    truncationRect.origin.x = self.textLayout.truncatedLine.lineWidth - truncationSize.width;
    truncationRect.origin.y = 0;
    
    TTAsyncTextLine *line = self.textLayout.lines[0];
    CGSize prefixSize = [self.linkAttributed boundingRectWithSize:CGSizeMake(line.lineWidth, line.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    CGRect prefixRect = CGRectZero;
    CGRect prefixRectAppend = CGRectZero;
    
    if (self.linkRange.length > 0) {
        NSArray *pointsArray = [self rectForSubstringWithRange:self.linkRange copyText:[self.text copy]];
        //调整高亮范围Rect
        NSValue *val = [pointsArray objectAtIndex:0];
        CGPoint firstPoint = [val CGPointValue];
        NSValue *lastVal = [pointsArray objectAtIndex:1];
        CGPoint lastPoint = [lastVal CGPointValue];
        prefixRect.size.height = line.height + 10;
        prefixRect.size.width = prefixSize.width;
        prefixRect.origin.x = firstPoint.x;
        prefixRect.origin.y = firstPoint.y - 5;
        prefixRectAppend.size.height = line.height + 10;
        prefixRectAppend.size.width = lastPoint.x;
        prefixRectAppend.origin.x = 0;
        prefixRectAppend.origin.y = lastPoint.y - 5;
    }
    
    if (CGRectContainsPoint(truncationRect, location)) {
        if (self.truncationAction && self.needTruncated && self.attributedTruncationToken) {
            self.truncationAction();
        }
        else {
            [super touchesEnded:touches withEvent:event];
        }
    }
    else if (CGRectContainsPoint(prefixRect, linkLocation) || CGRectContainsPoint(prefixRectAppend, linkLocation)) {
        if (self.prefixAction) {
            self.prefixAction();
        }
        else {
            [super touchesEnded:touches withEvent:event];
        }
    }
    else {
        [super touchesEnded:touches withEvent:event];
    }
    
}

- (void)setText:(NSString *)text {
    _text = text;
    
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
//        [self clearContents];
    }
    
    [self setLayoutNeedRedraw];
}

- (void)setFont:(UIFont *)font {
    if (!font) {
        font = [UIFont systemFontOfSize:17];
    }
    if (_font == font || [_font isEqual:font]) {
        return;
    }
    _font = font;
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContents];
    }
    [self setLayoutNeedRedraw];
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) {
        textColor = [UIColor blackColor];
    }
    if (_textColor == textColor || [_textColor isEqual:textColor]) {
        return;
    }
    _textColor = textColor;
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContents];
    }
    [self setLayoutNeedRedraw];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) {
        return;
    }
    _textAlignment = textAlignment;
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContents];
    }
    [self setLayoutNeedRedraw];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode == lineBreakMode) {
        return;
    }
    _lineBreakMode = lineBreakMode;
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContents];
    }
    [self setLayoutNeedRedraw];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) {
        return;
    }
    _numberOfLines = numberOfLines;
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContents];
    }
    [self setLayoutNeedRedraw];
}

- (void)setAttributedTruncationToken:(NSAttributedString *)attributedTruncationToken {
    if ([_attributedTruncationToken isEqualToAttributedString:attributedTruncationToken]) {
        return;
    }
    _attributedTruncationToken = attributedTruncationToken;
    if (_displaysAsynchronously && _clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContents];
    }
    [self setLayoutNeedRedraw];
}

- (void)setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (TTAsyncLayerDisplayTask *)asyncLayerDisplayTask {
    
    if (!_text) {
        return nil;
    }
    
    NSString *string = [_text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *decoding = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:decoding attributes:nil];
    

    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, text.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    if (_lineSpacing > 0) {
        style.lineSpacing = _lineSpacing;
    }
    if (_lineHeight > 0) {
        CGFloat lineHeightMultiple = _lineHeight / _font.lineHeight;
        style.lineHeightMultiple = lineHeightMultiple;
        style.minimumLineHeight = _font.lineHeight * lineHeightMultiple;
        style.maximumLineHeight = _font.lineHeight * lineHeightMultiple;
    }
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    if (_linkRange.length > 0 && _linkColor) {
        [text addAttribute:NSForegroundColorAttributeName value:_linkColor range:_linkRange];
    }
    
    TTAsyncLayerDisplayTask *task = [[TTAsyncLayerDisplayTask alloc] init];
    task.willDisplay = ^(CALayer *layer){
        [layer removeAnimationForKey:@"contents"];
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL (^isCancelled)(void)) {
        if (isCancelled()) {
            return;
        }
        if (text.length == 0) {
            return;
        }
        
        NSMutableArray *lines = [[NSMutableArray alloc] init];
        self.textLayout = [[TTAsyncTextLayout alloc] init];
        
        CGContextSaveGState(context);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        
        TT_ON_EXIT{
            CGContextRestoreGState(context);
            if (path) {
                CFRelease(path);
            }
        };
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
        if (!framesetter) {
            return;
        }
        
        TT_ON_EXIT{
            CFRelease(framesetter);
        };
    
        CGRect cgPathBox = {0};
        CGPathRef cgPath = nil;
        CGRect rect = (CGRect) {CGPointZero, size};
        self.textRect = rect;
        rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsZero);
        rect = CGRectStandardize(rect);
        cgPathBox = rect;
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
        cgPath = CGPathCreateWithRect(rect, NULL);
        
        if (!cgPath) {
            return;
        }
        
        TT_ON_EXIT{
            CFRelease(cgPath);
        };
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
        if (!frame) {
            return;
        }
        
        TT_ON_EXIT{
            CFRelease(frame);
        };
        
        CFArrayRef ctLines = CTFrameGetLines(frame);
        NSInteger lineCount = CFArrayGetCount(ctLines);
        CGPoint *lineOrigins = nil;
        if (lineCount > 0) {
            lineOrigins = malloc(lineCount * sizeof(CGPoint));
            if (lineOrigins == NULL) return;
            CTFrameGetLineOrigins(frame, CFRangeMake(0, lineCount), lineOrigins);
        }
        
        TT_ON_EXIT{
            if (lineOrigins) {
                free(lineOrigins);
            }
        };
        
        self.needTruncated = NO;
        
        for (int i = 0; i < lineCount; i++) {
            TTAsyncTextLine *line = [[TTAsyncTextLine alloc] init];
            CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
            CGPoint ctLineOrigin = lineOrigins[i];
            CGPoint position;
            position.x = cgPathBox.origin.x + ctLineOrigin.x;
            position.y = cgPathBox.origin.y + ctLineOrigin.y;
            [line setCTLine:CFArrayGetValueAtIndex(ctLines, i) position:lineOrigins[i]];
            line.index = @(i);
            CFRange range = CTLineGetStringRange(ctLine);
            line.range = NSMakeRange(range.location, range.length);
            [lines addObject:line];
        }

        if (_numberOfLines > 0) {
            if (lineCount > _numberOfLines) {
                self.needTruncated = YES;
                while(lineCount > _numberOfLines) {
                    [lines removeLastObject];
                    lineCount--;
                }
            }
        }
        TTAsyncTextLine *lastLine = lines.lastObject;
        if (!self.needTruncated && lastLine.range.location + lastLine.range.length < text.length) {
            self.needTruncated = YES;
        }
        
        
        if (self.needTruncated) {
            TTAsyncTextLine *lastLine = lines.lastObject;
            if (!lastLine) {
                return;
            }
            self.textLayout.lines = lines;
            TTAsyncTextLine *lastTextLine = [lines lastObject];
            
            NSMutableAttributedString *lastLineText = [text attributedSubstringFromRange:lastTextLine.range].mutableCopy;
            NSAttributedString *attributedTruncationToken = [[NSAttributedString alloc] init];
            if (!_attributedTruncationToken) {
                CFArrayRef runs = CTLineGetGlyphRuns(lastLine.CTLine);
                NSUInteger runCount = CFArrayGetCount(runs);
                NSMutableDictionary *attrs = nil;
                if (runCount > 0) {
                    CTRunRef run = CFArrayGetValueAtIndex(runs, runCount - 1);
                    attrs = (id)CTRunGetAttributes(run);
                    attrs = attrs ? attrs.mutableCopy : [NSMutableArray new];
                    NSMutableArray *keys = [[NSMutableArray alloc] init];
                    keys = @[(id)kCTSuperscriptAttributeName,
                             (id)kCTRunDelegateAttributeName].mutableCopy;
                    if ([TTDeviceHelper OSVersionNumber] > 8.f) {
                        [keys addObject:(id)kCTRubyAnnotationAttributeName];
                    }
                    if ([TTDeviceHelper OSVersionNumber] > 7.f) {
                        [keys addObject:NSAttachmentAttributeName];
                    }
                    [attrs removeObjectsForKeys:keys];
                    CTFontRef font = (__bridge CFTypeRef)attrs[(id)kCTFontAttributeName];
                    CGFloat fontSize = font ? CTFontGetSize(font) : 12.0;
                    UIFont *uiFont = [UIFont systemFontOfSize:fontSize * 0.9];
                    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)uiFont.fontName, uiFont.pointSize, NULL);
                    font = fontRef;
                    if (font) {
                        attrs[(id)kCTFontAttributeName] = (__bridge id)(font);
                        uiFont = nil;
                        CFRelease(font);
                    }
                    CGColorRef color = (__bridge CGColorRef)(attrs[(id)kCTForegroundColorAttributeName]);
                    if (color && CFGetTypeID(color) == CGColorGetTypeID() && CGColorGetAlpha(color) == 0) {
                        // ignore clear color
                        [attrs removeObjectForKey:(id)kCTForegroundColorAttributeName];
                    }
                    if (!attrs) attrs = [NSMutableDictionary new];
                }
                attributedTruncationToken = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:attrs];
            }
            else {
                attributedTruncationToken = _attributedTruncationToken;
            }
            
            CTLineRef truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedTruncationToken);
            if (truncationTokenLine) {
                TT_ON_EXIT{
                    CFRelease(truncationTokenLine);
                };
                [lastLineText appendAttributedString:attributedTruncationToken];
                CTLineRef ctLastLineExtend = CTLineCreateWithAttributedString((CFAttributedStringRef)lastLineText);
                if (ctLastLineExtend) {
                    TT_ON_EXIT{
                        CFRelease(ctLastLineExtend);
                    };
                    CGFloat truncatedWidth = size.width;
                    CTLineTruncationType type = kCTLineTruncationEnd;
                    CGRect cgPathRect = CGRectZero;
                    if (CGPathIsRect(cgPath, &cgPathRect)) {
                        truncatedWidth = cgPathRect.size.width;
                    }
                    CTLineRef ctTruncatedLine = CTLineCreateTruncatedLine(ctLastLineExtend, truncatedWidth, type, truncationTokenLine);
                    if (ctTruncatedLine) {
                        TT_ON_EXIT{
                            CFRelease(ctTruncatedLine);
                        };
                        TTAsyncTextLine *truncatedLine = [[TTAsyncTextLine alloc] init];
                        [truncatedLine setCTLine:ctTruncatedLine position:lastLine.position];
                        truncatedLine.index = lastLine.index;
                        truncatedLine.range = lastLine.range;
                        self.textLayout.truncatedLine = truncatedLine;
                        if (isCancelled && isCancelled()) {
                            return;
                        }
                        [self.textLayout drawInTextWithContext:context size:size cancel:isCancelled];
                    }
                }
            }
        }
        else {
            self.textLayout.lines = lines;
            if (isCancelled && isCancelled()) {
                return;
            }
            [self.textLayout drawInTextWithContext:context size:size cancel:isCancelled];
        }
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        if (!finished) {
            return;
        }
        [layer removeAnimationForKey:@"contents"];
        
    };
    
    return task;
    
}


- (void)clearContents {
    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            CFRelease(image);
        });
    }
}

- (NSArray *)rectForSubstringWithRange:(NSRange)range copyText:(NSString *)copyText {
    
    if (range.location + range.length  > copyText.length) {
        return [NSArray arrayWithObjects:
                [NSValue valueWithCGPoint:CGPointZero],
                [NSValue valueWithCGPoint:CGPointZero],
                nil];;
    }
    
    NSString *string = [copyText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *decoding = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:decoding attributes:nil];
    
    
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, text.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    if (_lineSpacing > 0) {
        style.lineSpacing = _lineSpacing;
    }
    if (_lineHeight > 0) {
        CGFloat lineHeightMultiple = _lineHeight / _font.lineHeight;
        style.lineHeightMultiple = lineHeightMultiple;
        style.minimumLineHeight = _font.lineHeight * lineHeightMultiple;
        style.maximumLineHeight = _font.lineHeight * lineHeightMultiple;
    }
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    if (_linkRange.length > 0 && _linkColor) {
        [text addAttribute:NSForegroundColorAttributeName value:_linkColor range:_linkRange];
    }
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFTypeRef)text);
    
    CGRect textRect = self.textRect;
	   
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
    if (frame == NULL) {
        CFRelease(frame);
        CFRelease(framesetter);
        CFRelease(path);
        return [NSArray arrayWithObjects:
                [NSValue valueWithCGPoint:CGPointZero],
                [NSValue valueWithCGPoint:CGPointZero],
                nil];;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = 0;
    if (lines) {
        numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) :    CFArrayGetCount(lines);
    }
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(framesetter);
        CFRelease(path);
        return [NSArray arrayWithObjects:
                [NSValue valueWithCGPoint:CGPointZero],
                [NSValue valueWithCGPoint:CGPointZero],
                nil];;
    }
    
    CGRect returnRect = CGRectZero;
    CGRect returnRectAppend = CGRectZero;
    
    CFIndex firstIndex = 0;
    CFIndex lastIndex = 0;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    if (lines) {
        //查找高亮字段首尾字符的位置
        for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
            if (!lines) {
                break;
            }
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            CFRange lineRange = CFRangeMake(0, 0);
            if (line) {
                lineRange = CTLineGetStringRange(line);
            }
            
            if (lineRange.location <= range.location && lineRange.location + lineRange.length >= range.location) {
                if (lineRange.location + lineRange.length < range.location + range.length) {
                    firstIndex = range.location;
                    lastIndex = firstIndex + range.length;
                }
                else {
                    firstIndex = range.location;
                }
                break;
            }
        }
        
        //查找高亮字段首尾字符的坐标
        for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
            CGPoint lineOrigin = lineOrigins[lineIndex];
            if (!lines) {
                break;
            }
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            CFRange lineRange = CFRangeMake(0, 0);
            if (line) {
                lineRange = CTLineGetStringRange(line);
            }
            
            if (lineRange.location <= range.location && lineRange.location + lineRange.length >= range.location) {
                
                CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                
                CFIndex glyphCount = 0;
                if (glyphRuns) {
                    glyphCount = CFArrayGetCount(glyphRuns);
                }
                CTRunRef foundRun;
                BOOL runFound = NO;
                
                for (CFIndex glyphIndex = 0; glyphIndex < glyphCount; glyphIndex++) {
                    if (glyphRuns) {
                        CTRunRef tempRun = CFArrayGetValueAtIndex(glyphRuns, glyphIndex);
                        CFRange tempRunRange = CTRunGetStringRange(tempRun);
                        if (tempRunRange.location == firstIndex) {
                            foundRun = tempRun;
                            runFound = YES;
                        }
                    }
                }
                
                if (runFound) {
                    CGFloat ascent;
                    CGFloat descent;
                    returnRect.size.width = CTRunGetTypographicBounds(foundRun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                    returnRect.size.height = ascent + descent;
                    returnRect.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(foundRun).location, NULL);
                    returnRect.origin.y = self.frame.size.height - lineOrigin.y - returnRect.size.height;
                    returnRect = returnRect;
                }
                
                if (lastIndex > 0) { //lastIndex>0 代表高亮词换行了 @zengruihuan
                    if (lineIndex + 1 >= numberOfLines) {
                        break;
                    }
                    lineOrigin = lineOrigins[lineIndex + 1];
                    if (!lines) {
                        break;
                    }
                    line = CFArrayGetValueAtIndex(lines, lineIndex + 1);
                    if (line) {
                        lineRange = CTLineGetStringRange(line);
                        glyphRuns = CTLineGetGlyphRuns(line);
                    }
                    
                    if (glyphRuns) {
                        glyphCount = CFArrayGetCount(glyphRuns);
                    }
                    runFound = NO;
                    
                    for (CFIndex glyphIndex = 0; glyphIndex < glyphCount; glyphIndex++) {
                        if (glyphRuns) {
                            CTRunRef tempRun = CFArrayGetValueAtIndex(glyphRuns, glyphIndex);
                            CFRange tempRunRange = CTRunGetStringRange(tempRun);
                            if (tempRunRange.location == lastIndex) {
                                foundRun = tempRun;
                                runFound = YES;
                            }
                        }
                    }
                    
                    if (runFound) {
                        CGFloat ascent;
                        CGFloat descent;
                        returnRect.size.width = CTRunGetTypographicBounds(foundRun, CFRangeMake(0, 0), &ascent, &descent, NULL);
                        returnRectAppend.size.height = ascent + descent;
                        returnRectAppend.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(foundRun).location, NULL);
                        returnRectAppend.origin.y = self.frame.size.height - lineOrigin.y - returnRectAppend.size.height;
                        returnRectAppend = returnRectAppend;
                    }
                }
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
    
    return [NSArray arrayWithObjects:
            [NSValue valueWithCGPoint:CGPointMake(returnRect.origin.x, returnRect.origin.y)],
            [NSValue valueWithCGPoint:CGPointMake(returnRectAppend.origin.x, returnRectAppend.origin.y)],
            nil];;
}


@end
