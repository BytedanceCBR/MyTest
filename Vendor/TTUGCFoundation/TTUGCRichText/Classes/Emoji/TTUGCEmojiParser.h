//
//  TTUGCEmojiParser.h
//  Emoji 文本解析器，提供 NSString <-> NSAttributedString 之间相互转换
//  Emoji 映射表
//
//  Created by Jiyee Sheng on 5/15/17.
//
//

#import <UIKit/UIKit.h>

extern NSString *const kTTUGCEmojiLinkReplacementText;
extern NSString *const kTTUGCEmojiInactiveLinkReplacementText;


@class TTUGCEmojiTextAttachment;

@interface TTUGCEmojiParser : NSObject

+ (NSArray <TTUGCEmojiTextAttachment *> *)top4EmojiTextAttachments;

+ (NSArray <TTUGCEmojiTextAttachment *> *)emojiTextAttachments;

/**
 * 将包含 Emoji 小表情的 NSAttributedString 转成 [微笑] 这样的纯文本
 * @param attributedText
 * @return text
 */
+ (NSString *)stringify:(NSAttributedString *)attributedText;

/**
 * 将包含 Emoji 小表情的 NSAttributedString 转成 [微笑] 这样的纯文本
 * @param attributedText
 * @param ignoreCustomEmojis 是否忽略自定义表情
 * @return text
 */
+ (NSString *)stringify:(NSAttributedString *)attributedText ignoreCustomEmojis:(BOOL)ignoreCustomEmojis;

/**
 * 将包含 [微笑] 这样的纯文本转成 Emoji 小表情的 NSAttributedString
 * NSTextAttachment 方式实现，用于 TextKit
 * @param text
 * @param fontSize 正文文本字体大小
 * @return attributedText
 */
+ (NSAttributedString *)parseInTextKitContext:(NSString *)text fontSize:(CGFloat)fontSize;

/**
 * 将包含 [微笑] 这样的纯文本转成 Emoji 小表情的 NSAttributedString
 * 0xFFFC 占位符方式实现，用于 CoreText
 * @param text
 * @param fontSize 正文文本字体大小
 * @return attributedText
 */
+ (NSAttributedString *)parseInCoreTextContext:(NSString *)text fontSize:(CGFloat)fontSize;

/**
 * 解析纯文本中包含的 Emoji 小表情的 Range
 * @param text
 * @return emojis
 */
+ (NSArray <NSValue *> *)parseEmojiRangeValues:(NSString *)text;

/**
 * 解析纯文本中包含的 Emoji 小表情
 * @param text
 * @return emojis
 */
+ (NSDictionary <NSString *, NSString *> *)parseEmojis:(NSString *)text;

/**
 * 记录已发布的表情，作为常用表情排序用
 * @param emojis
 */
+ (void)markEmojisAsUsed:(NSDictionary <NSString *, NSString *> *)emojis;


/**
 设置请求“后台表情排序”的间隔时间

 @param timeInterval 以秒为单位
 */
+ (void)setUserExpressionConfigTimeInterval:(NSTimeInterval)timeInterval;
@end
