//
//  NSString+UGCUtils.h
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//



@interface NSString (UGCUtils)

/**
 * 字符串根据宽度手动处理 ellipsis 问题
 * @param font 字符串显示字体
 * @param constraintsWidth 约束宽度
 * @return 如果超出 constraintsWidth 返回包含 ... 的字符串
 */
- (NSString *)ellipsisStringWithFont:(UIFont *)font constraintsWidth:(CGFloat)constraintsWidth;

/**
 * 包含多字节字符（例如 Emoji 字符），计算 codePoint 对于的 location
 * 使用场景: 服务端返回高亮文字的 index (Emoji 字符按照单个字符处理)
 * 例如 "Hello😀😀😀World", codePoint: 8 -> range: {11, 0}
 * @param codePoint cursor 索引
 * @return
 */
- (NSRange)rangeOfComposedCharacterSequenceAtCodePoint:(NSUInteger)codePoint;

- (NSDictionary *)attributedInfoWithFontSize:(CGFloat)fontSize colorName:(NSString *)colorName;
@end
