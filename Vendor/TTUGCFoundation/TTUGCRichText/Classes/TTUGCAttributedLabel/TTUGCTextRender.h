//
//  TTUGCTextRender.h
//  负责处理富文本绘制
//
//  Created by zoujianfeng on 2019/11/5.
//  Copyright © 2019 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTUGCAttributedLabel.h"

@class TTUGCAsyncLabel;

NS_ASSUME_NONNULL_BEGIN

@interface TTUGCAsyncLabelLink : TTUGCAttributedLabelLink

typedef void (^TTUGCAsyncLabelLinkBlock) (TTUGCAsyncLabel *asyncLabel, TTUGCAsyncLabelLink *link);

//@property (nonatomic, strong) NSURL *linkURL;
//@property (nonatomic, strong) NSTextCheckingResult *result;
//@property (nonatomic, copy, readonly) NSDictionary *attributes; // 暂时保留，预期不继承TTUGCAttributedLabelLink，单独存在，此处继承是为了使代码中能开关切换两套方案而无警告等
@property (nonatomic, copy) TTUGCAsyncLabelLinkBlock tapBlock;
@property (nonatomic, copy) TTUGCAsyncLabelLinkBlock longPressBlock;

//- (instancetype)initWithAttributes:(NSDictionary * _Nullable)attributes
//                textCheckingResult:(NSTextCheckingResult * _Nullable)result;

@end

@interface TTUGCTextRender : NSObject

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText;
- (instancetype)initWithTextStorage:(NSTextStorage *)textStorage;

//- (TTUGCAsyncLabelLink *)setTruncatedText:(NSString *)truncatedText attributes:(NSDictionary *)attributes;
//@property (nonatomic, strong, readonly) TTUGCAsyncLabelLink *truncatedTokenLink; // 方便设置block，而不通过delegate拿。
@property (nonatomic, strong) NSAttributedString *truncatedToken;
//@property (nonatomic, strong) NSDictionary *linkAttributes;

@property (nonatomic, strong, readonly) NSTextStorage *textStorage;
@property (nonatomic, strong, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, strong, readonly) NSTextContainer *textContainer;

@property (nonatomic, assign) CGFloat lineFragmentPadding; // 默认0；The layout padding at the beginning and end of the line fragment rects insetting the layout width available for the contents.
@property (nonatomic, assign) NSUInteger maximumNumberOfLines;
@property (nonatomic, strong) UIFont *font; // 指定字体算字高估算行数，处理truncated

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL onlySetRenderSizeWillGetTextBounds; // 默认YES，设置了绘制Size后才更新文本bounds，YES下会缓存textBound
@property (nonatomic, assign, readonly) CGRect textBound; // 可见的文本区域

- (CGSize)textSizeWithRenderWidth:(CGFloat)renderWidth; // 根据最大宽度，计算文本size，与maximumNumberOfLines有关（0or非0）
- (NSRange)visibleCharacterRange; // 可见文本range，必须设置了size才有效
- (NSInteger)numberOfLines; // text行数

- (CGRect)boundingRectForCharacterRange:(NSRange)characterRange; // 字符range的bound
- (CGRect)boundingRectForGlyphRange:(NSRange)glyphRange; // 字形range的bound
- (NSInteger)characterIndexForPoint:(CGPoint)point; // 获取某点对应的字符index

+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString
                       constraintsSize:(CGSize)size
                limitedToNumberOfLines:(NSUInteger)numberOfLines;

+ (CGSize)sizeThatFitsForTextViewAttributedString:(NSAttributedString *)attributedString
                                  constraintsSize:(CGSize)size
                           limitedToNumberOfLines:(NSUInteger)numberOfLines;

+ (long)numberOfLinesAttributedString:(NSAttributedString *)attributedString
                     constraintsWidth:(CGFloat)width;

- (void)addLink:(TTUGCAsyncLabelLink *)link; // 添加一个link
- (void)addLinks:(NSArray <TTUGCAsyncLabelLink *> *)links; // 添加多个link
- (BOOL)containsLinkAtPoint:(CGPoint)point;
- (TTUGCAsyncLabelLink * _Nullable)linkAtPoint:(CGPoint)point;
- (NSArray<TTUGCAsyncLabelLink *> *)links;

- (void)drawTruncatedTokenIsCanceled:(BOOL (^__nullable)(void))isCanceled; // 处理truncated
- (void)drawTextAtPoint:(CGPoint)point isCanceled:(BOOL (^__nullable)(void))isCanceled; // 在指定point绘制，根据block判断是否取消绘制

@end

NS_ASSUME_NONNULL_END
