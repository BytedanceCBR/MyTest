//
//  TTUGCAsyncLabel.m
//  TestCoreText
//
//  Created by zoujianfeng on 2019/11/5.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import "TTUGCAsyncLabel.h"
#import "TTUGCTextRender.h"
#import "TTUGCEmojiParser.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Image.h"

#import <BDPainter/NSAttributedString+BDPainter.h>
#import <BDPainter/BDPainterAsyncLayer.h>

#define kTTUGCAsyncFadeDuration 0.08 // Time in seconds for async display fadeout animation.

@interface TTUGCAsyncLabel () <BDPainterAsyncLayerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSTextStorage *textStorageOnRender;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) TTUGCAsyncLabelLink *activeLink;

@end

@implementation TTUGCAsyncLabel

+ (Class)layerClass {
    return [BDPainterAsyncLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.fadeOnAsynchronouslyDisplay = YES;
        self.clearContentsBeforeAsynchronouslyDisplay = YES;
        self.ignoreCommonProperties = YES;
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textAlignment = NSTextAlignmentLeft;
        self.opaque = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.isAccessibilityElement = YES;

        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureDidFire:)];
        _longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
    return self;
}

- (NSString *)accessibilityLabel {
    return [self pureText];
}

#pragma mark - Priavte

- (NSString *)pureText {
    if (self.text) {
        return self.text;
    }
    if (self.richSpanText) {
        TTRichSpanText *richSpanText = [[self.richSpanText restoreWhitelistLinks] restoreImageLinksWithIgnoreFlag:NO];
        return richSpanText.text;
    }

    return self.textRender.textStorage.string;
}

#pragma mark - Display

- (void)setDisplayNeedUpdate {
    [self clearTextRender];
    [self clearContents];
    [self setLayoutNeedRedraw];
}

- (void)setLayoutNeedRedraw {
    [self.layer setNeedsDisplay];
}

- (void)setLayoutNeedUpdate {
    [self clearContents];
    [self setLayoutNeedRedraw];
}

- (void)clearContents {
    if (_clearContentsBeforeAsynchronouslyDisplay && self.displaysAsynchronously) {
        CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
        self.layer.contents = nil;
        if (image) {
            dispatch_async(BDPainterAsyncLayerGetReleaseQueues(), ^{
                CFRelease(image);
            });
        }
    }
}

- (void)clearTextRender {
    _textRender = nil;
}

- (void)forceRedraw {
    [self clearContents];
    [self setLayoutNeedRedraw];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Layout Size

- (CGSize)sizeThatFits:(CGSize)size {
    return [self contentSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = CGRectGetWidth(self.frame);
    return [self contentSizeWithWidth:width > 0 ? width : 10000];
}

- (CGSize)contentSizeWithWidth:(CGFloat)width {
    if (_textRender) {
        if (ABS(_textRender.size.width - width) > 0.01 || _textRender.size.height == 0 || _textRender.size.width == 0) {
            return [_textRender textSizeWithRenderWidth:width];
        }
        return _textRender.size;
    }
    BOOL ignoreAboveRenderRelatePropertys = _ignoreCommonProperties && _textRender;
    NSMutableAttributedString *string = [_textStorageOnRender mutableCopy];
    TTUGCTextRender *textRender = [[TTUGCTextRender alloc] initWithAttributedText:string];
    if (!ignoreAboveRenderRelatePropertys) {
        textRender.maximumNumberOfLines = _numberOfLines;
    }
    return [textRender textSizeWithRenderWidth:width];
}

#pragma mark - BDPainterAsyncLayerDelegate

- (BDPainterAsyncLayerDisplayTask *)newAsyncDisplayTask {
    __block TTUGCTextRender *textRender = _textRender;
    __block NSTextStorage *textStorage = _textStorageOnRender;

    BOOL fadeForAsync = self.displaysAsynchronously && _fadeOnAsynchronouslyDisplay;
    BOOL ignoreAboveRenderRelatePropertys = _ignoreCommonProperties && textRender;

    BDPainterAsyncLayerDisplayTask *task = [BDPainterAsyncLayerDisplayTask new];

    __weak typeof(self) weakSelf = self;
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        [layer removeAnimationForKey:@"contents"];
    };
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void), int32_t drawCount) {
        if (!textRender) {
            textRender = [[TTUGCTextRender alloc] initWithTextStorage:textStorage];
            if (isCancelled()) return;
        }
        if (!textStorage) {
            return;
        }
        if (!ignoreAboveRenderRelatePropertys) {
            textRender.maximumNumberOfLines = weakSelf.numberOfLines;
        }
        textRender.size = size;
        if (isCancelled()) return;
        [textRender drawTruncatedTokenIsCanceled:isCancelled];
        [textRender drawTextAtPoint:CGPointZero isCanceled:isCancelled];
    };
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        [layer removeAnimationForKey:@"contents"];
        if (fadeForAsync) {
            CATransition *transition = [CATransition animation];
            transition.duration = kTTUGCAsyncFadeDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [layer addAnimation:transition forKey:@"contents"];
        }
    };

    return task;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(__unused id)sender {
    return (action == @selector(copy:));
}

#pragma mark UIResponderStandardEditActions

- (void)copy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:[self pureText]];
}

#pragma mark Link

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.activeLink = [self.textRender linkAtPoint:[touch locationInView:self]];
    if (!self.activeLink) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.activeLink) {
        UITouch *touch = [touches anyObject];
        if (self.activeLink != [self.textRender linkAtPoint:[touch locationInView:self]]) {
            self.activeLink = nil;
        }
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.activeLink) {
        if (self.activeLink.tapBlock) {
            self.activeLink.tapBlock(self, self.activeLink);
            self.activeLink = nil;
            return;
        }

        NSTextCheckingResult *result = self.activeLink.result;
        NSURL *url = result.URL ?: self.activeLink.linkURL;
        self.activeLink = nil;

        switch (result.resultType) {
            case NSTextCheckingTypeLink:
                if ([self.delegate respondsToSelector:@selector(asyncLabel:didSelectLinkWithURL:)]) {
                    [self.delegate asyncLabel:self didSelectLinkWithURL:url];
                    return;
                }
                break;
            default:
                break;
        }

        if ([self.delegate respondsToSelector:@selector(asyncLabel:didSelectLinkWithTextCheckingResult:)]) {
            [self.delegate asyncLabel:self didSelectLinkWithTextCheckingResult:result];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.activeLink) {
        self.activeLink = nil;
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self.textRender containsLinkAtPoint:[touch locationInView:self]];
}

#pragma mark - UILongPressGestureRecognizer

- (void)longPressGestureDidFire:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint touchPoint = [sender locationInView:self];
            TTUGCAsyncLabelLink *link = [self.textRender linkAtPoint:touchPoint];
            if (link) {
                if (link.longPressBlock) {
                    link.longPressBlock(self, link);
                    return;
                }

                NSTextCheckingResult *result = link.result;
                if (!result) {
                    return;
                }

                switch (result.resultType) {
                    case NSTextCheckingTypeLink:
                        if ([self.delegate respondsToSelector:@selector(asyncLabel:didLongPressLinkWithURL:atPoint:)]) {
                            [self.delegate asyncLabel:self didLongPressLinkWithURL:result.URL ?: link.linkURL atPoint:touchPoint];
                            return;
                        }
                        break;
                    default:
                        break;
                }

                if ([self.delegate respondsToSelector:@selector(asyncLabel:didLongPressLinkWithTextCheckingResult:atPoint:)]) {
                    [self.delegate asyncLabel:self didLongPressLinkWithTextCheckingResult:result atPoint:touchPoint];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Getter && Setter

- (BOOL)displaysAsynchronously {
    return ((BDPainterAsyncLayer *)self.layer).displaysAsynchronously;
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    ((BDPainterAsyncLayer *)self.layer).displaysAsynchronously = displaysAsynchronously;
}

- (void)setText:(NSString *)text {
    _text = text;
    _textStorageOnRender = [[NSTextStorage alloc] initWithString:text];
    _attributedText = nil;
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    _textStorageOnRender = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    _text = nil;
    [self clearContents];
    [self setLayoutNeedRedraw];
    [self setDisplayNeedUpdate];
    [self invalidateIntrinsicContentSize];
}

- (void)setTextRender:(TTUGCTextRender *)textRender {
    _text = nil;
    if ([_textRender isEqual:textRender]) {
        textRender.size = _textRender.size;
        _textRender = textRender;
        _textStorageOnRender = textRender.textStorage;
    } else {
        _textRender = textRender;
        _textStorageOnRender = textRender.textStorage;
        [self clearContents];
        [self setLayoutNeedRedraw];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (_text.length && !_ignoreCommonProperties) {
        _textStorageOnRender.bdp_font = font;
        [self setLayoutNeedUpdate];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_text.length && !_ignoreCommonProperties) {
        _textStorageOnRender.bdp_color = textColor;
        [self setLayoutNeedUpdate];
    }
}

- (void)setShadow:(NSShadow *)shadow {
    _shadow = shadow;
    if (_text.length && !_ignoreCommonProperties) {
        _textStorageOnRender.bdp_shadow = shadow;
        [self setLayoutNeedUpdate];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    if (_text.length && !_ignoreCommonProperties) {
        _textStorageOnRender.bdp_lineSpacing = lineSpacing;
        [self setLayoutNeedUpdate];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    if (_text.length && !_ignoreCommonProperties) {
        _textStorageOnRender.bdp_alignment = textAlignment;
        [self setLayoutNeedUpdate];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    if (_text.length && !_ignoreCommonProperties) {
        [self setLayoutNeedUpdate];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    if (_text.length && !_ignoreCommonProperties) {
        [self setLayoutNeedUpdate];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(self.frame.size, oldSize)) {
        [self clearContents];
        [self setLayoutNeedRedraw];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    if (!CGSizeEqualToSize(self.bounds.size, oldSize)) {
        [self clearContents];
        [self setLayoutNeedRedraw];
    }
}

- (void)setDelegate:(id<TTUGCAsyncLabelDelegate>)delegate {
    _delegate = delegate;
}

@end
