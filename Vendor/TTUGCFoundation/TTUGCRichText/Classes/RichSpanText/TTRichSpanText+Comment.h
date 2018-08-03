//
//  TTRichSpanText+Comment.h
//  Article
//
//  Created by Jiyee Sheng on 17/11/2017.
//
//


#import "TTRichSpanText.h"


@interface TTRichSpanText (Comment)

/**
 * 增加评论回复中原评论的作者信息
 * @param userName 原评论作者用户名
 * @param userId 原评论作者 ID
 */
- (void)appendCommentQuotedUserName:(NSString *)userName userId:(NSString *)userId;

@end
