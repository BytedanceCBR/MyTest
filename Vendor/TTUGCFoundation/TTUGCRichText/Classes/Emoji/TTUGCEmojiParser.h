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
extern NSString *const kTTUGCEmojiImageReplacementText;
//extern NSString *const kTTUGCEmojiMicroAppReplacementText;
#define kTTUGCEmojiMicroAppReplacementText [NSString stringWithFormat:@"%@%@", @"[小程", @"序]"]
extern NSString *const kTTUGCEmojiDiggReplacementText;
extern NSString *const kTTUGCEmojiGoldVipReplacementText;
extern NSString *const kTTUGCEmojiYellowVipReplacementText;
extern NSString *const kTTUGCEmojiBlueVipReplacementText;
extern NSString *const kTTUGCEmojiShowMoreReplacementText;
extern NSString *const kTTUGCEmojiManyPeopleReplacementText;
//extern NSString *const kTTUGCEmojiInactiveMicroAppReplacementText;
#define kTTUGCEmojiInactiveMicroAppReplacementText [NSString stringWithFormat:@"%@%@", @"[小程", @"序2]"]

@class TTUGCEmojiTextAttachment;

@interface TTUGCEmojiParser : NSObject

+ (NSArray <TTUGCEmojiTextAttachment *> *)top4EmojiTextAttachments;

+ (NSArray <TTUGCEmojiTextAttachment *> *)emojiTextAttachments;

/**
 * 将包含 Emoji 小表情的 NSAttributedString 转成 [微笑] 这样的纯文本
 * @param attributedText 原富文本
 * @return text
 */
+ (NSString *)stringify:(NSAttributedString *)attributedText;

/**
 * 将包含 Emoji 小表情的 NSAttributedString 转成 [微笑] 这样的纯文本
 * @param attributedText 原富文本
 * @param ignoreCustomEmojis 是否忽略自定义表情
 * @return text
 */
+ (NSString *)stringify:(NSAttributedString *)attributedText ignoreCustomEmojis:(BOOL)ignoreCustomEmojis;

/**
 * 将包含 [微笑] 这样的纯文本转成 Emoji 小表情的 NSAttributedString
 * NSTextAttachment 方式实现，用于 TextKit
 * @param text 未转前的富文本 里面有[微笑]样式
 * @param fontSize 正文文本字体大小
 * @return attributedText
 */
+ (NSAttributedString *)parseInTextKitContext:(NSString *)text fontSize:(CGFloat)fontSize;

/**
 * 将包含 [微笑] 这样的纯文本转成 Emoji 小表情的 NSAttributedString
 * 0xFFFC 占位符方式实现，用于 CoreText
 * @param text 未转前的富文本 里面有[微笑]样式
 * @param fontSize 正文文本字体大小
 * @return attributedText
 */
+ (NSAttributedString *)parseInCoreTextContext:(NSString *)text fontSize:(CGFloat)fontSize;

/**
 * 解析纯文本中包含的 Emoji 小表情的 Range
 * @param text 未转前的富文本 里面有[微笑]样式
 * @return emojis
 */
+ (NSArray <NSValue *> *)parseEmojiRangeValues:(NSString *)text;

/**
 * 解析纯文本中包含的 Emoji 小表情
 * @param text 未转前的富文本 里面有[微笑]样式
 * @return emojis
 */
+ (NSDictionary <NSString *, NSString *> *)parseEmojis:(NSString *)text;

/**
 * 记录已发布的表情，作为常用表情排序用
 * @param emojis emojis
 */
+ (void)markEmojisAsUsed:(NSDictionary <NSString *, NSString *> *)emojis;


/**
 设置请求“后台表情排序”的间隔时间

 @param timeInterval 以秒为单位
 */
+ (void)setUserExpressionConfigTimeInterval:(NSTimeInterval)timeInterval;

+ (BOOL)isCustomEmojiTextAttachment:(TTUGCEmojiTextAttachment *)attachment;
@end
