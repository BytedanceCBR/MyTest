//
//  TTRichSpanText+Image.h
//  TTUGCFoundation-TTUGCRichText
//
//  Created by ranny_90 on 2018/3/20.
//

#import "TTRichSpanText.h"

@interface TTRichSpanText (Image)

/**
 * 包含多少个图片链接，供统计使用
 * @return 图片链接数量
 */
- (NSUInteger)numberOfImageLinks;

/**
 * 功能：替换 richSpanText 里的图片链接，替换为 link.text（eg，替换为“查看图片”）
 * ignoreFlag：YES时，无论后端在图片的link中是否下发flag字段，都进行“查看图片”文本的替换
 * @return 替换完成之后新创建的 richSpanText
 */
- (TTRichSpanText *)replaceImageLinksWithIgnoreFlag:(BOOL)ignoreFlag ;

/**
 * 功能：还原 richSpanText 里的图片链接，还原为 content
 * 使用场景：在发布、复制等场景，将展示的文本内容替换为服务端下发的原文本内容。
 * @return 还原完成之后新创建的 richSpanText
 */
- (TTRichSpanText *)restoreImageLinksWithIgnoreFlag:(BOOL)ignoreFlag ;

@end
