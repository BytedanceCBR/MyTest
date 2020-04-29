//
//  TTUGCAsyncLabel.h
//  Base On YYLabel support emoji and links
//
//  Created by zoujianfeng on 2019/11/5.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TTUGCAsyncLabel, TTRichSpanText, TTUGCTextRender;
@protocol TTUGCAsyncLabelDelegate <NSObject>

@optional

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url;
- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;

- (void)asyncLabel:(TTUGCAsyncLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point;
- (void)asyncLabel:(TTUGCAsyncLabel *)label didLongPressLinkWithTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point;

@end

@interface TTUGCAsyncLabel : UIView

@property (nonatomic, weak, nullable) id<TTUGCAsyncLabelDelegate> delegate;

@property (nonatomic, assign) BOOL displaysAsynchronously; // 默认YES，View的layer异步绘制

/**
 clear layer'content,before asynchronously display. default YES
 */
@property (nonatomic, assign) BOOL clearContentsBeforeAsynchronouslyDisplay;
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;
@property (nonatomic, strong, nullable) TTUGCTextRender *textRender; // 通过textRender异步绘制

@property (nonatomic, strong, nullable) UIFont *font;       // default nil
@property (nonatomic, strong, nullable) UIColor *textColor; // default nil
@property (nonatomic, strong, nullable) NSShadow *shadow;   // default nil
@property (nonatomic, assign) NSTextAlignment textAlignment;   // default is STextAlignmentLeft
@property (nonatomic, assign) CGFloat lineSpacing;     // deault 0
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;   // default is NSLineBreakByTruncatingTail.
@property (nonatomic, assign) NSInteger numberOfLines; // default 0
/**
 Ignore above common properties (such as text, font, textColor, attributedText...) and
 only use "textRender" to display content.

 The default value is `YES`.
 @discussion If you control the label content only through "textRender", then
 you may set this value to YES for higher performance.
 */
@property (nonatomic) BOOL ignoreCommonProperties;
/**
 If the value is YES, and the layer is rendered asynchronously, then it will add
 a fade animation on layer when the contents of layer changed.

 The default value is `YES`.
 */
@property (nonatomic) BOOL fadeOnAsynchronouslyDisplay;

@property (nonatomic, weak) TTRichSpanText *richSpanText; // 为copy和accessibility用

- (void)forceRedraw;

@end

NS_ASSUME_NONNULL_END
