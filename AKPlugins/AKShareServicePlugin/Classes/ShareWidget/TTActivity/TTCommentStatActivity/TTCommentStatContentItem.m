//
//  TTCommentStatContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import "TTCommentStatContentItem.h"

NSString * const TTActivityContentItemTypeCommentStat        =
@"com.toutiao.ActivityContentItem.CommentStat";

@implementation TTCommentStatContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeCommentStat;
}

- (NSString *)contentTitle
{
    if (self.stat == TTCommentStatAllow) {
        return @"允许评论";
    } else if (self.stat == TTCommentStatForbid) {
        return @"禁止评论";
    } else {
        return @"。。。";
    }
}

- (NSString *)activityImageName
{
    if (self.stat == TTCommentStatAllow) {
        return @"allow_comments_allshare";
    } else if (self.stat == TTCommentStatForbid) {
        return @"unlike_allshare";
    } else {
        return nil;
    }
}

@end
