//
//  TTRichSpanText+Emoji.h
//  Article
//
//  Created by Jiyee Sheng on 12/11/2017.
//
//



#import "TTRichSpanText.h"


@interface TTRichSpanText (Emoji)

/**
 * 计算经过 TTUGCEmojiParser 解析之后的 attributedString 里对应的 richSpanLinks
 * @return link 偏移之后的 richSpanLinks
 */
- (NSArray <TTRichSpanLink *> *)richSpanLinksOfAttributedString;

@end
