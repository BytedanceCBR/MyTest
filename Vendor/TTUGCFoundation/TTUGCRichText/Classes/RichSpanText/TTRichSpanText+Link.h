//
//  TTRichSpanText+Link.h
//  Article
//  用于替换网络链接，源数据仍然保存在 TTRichSpanText 实例
//
//  Created by Jiyee Sheng on 26/10/2017.
//
//


#import "TTRichSpanText.h"


@interface TTRichSpanText (Link)

/**
 * 包含多少个白名单的链接，供统计使用
 * @return 白名单链接数量
 */
- (NSUInteger)numberOfWhitelistLinks;

/**
 * 替换 richSpanText 里属于白名单的链接，替换为 link.text
 * @return 替换完成之后新创建的 richSpanText
 */
- (TTRichSpanText *)replaceWhitelistLinks;

/**
 * 替换 richSpanText 里属于白名单的链接，替换为 link.text，链接样式置灰不可点
 * @return 替换完成之后新创建的 richSpanText
 */
- (TTRichSpanText *)replaceWhitelistLinksAsInactiveLinks;

/**
 * 还原 richSpanText 里属于白名单的链接，还原为 content
 * @return 还原完成之后新创建的 richSpanText
 */
- (TTRichSpanText *)restoreWhitelistLinks;

@end
