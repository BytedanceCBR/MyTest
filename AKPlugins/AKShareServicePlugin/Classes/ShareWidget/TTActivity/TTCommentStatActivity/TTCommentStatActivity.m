//
//  TTCommentStatActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import "TTCommentStatActivity.h"
#import "TTShareManager.h"

NSString * const TTActivityTypeCommentStat = @"com.toutiao.UIKit.activity.CommentStat";
@implementation TTCommentStatActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTCommentStatActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeCommentStat;
}

- (NSString *)activityType
{
    return TTActivityTypeCommentStat;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        return [self.contentItem contentTitle];
    } else {
        return @"允许评论";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"allow_comments_allshare";
    }
}

- (NSString *)shareLabel
{
    return nil;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    if (self.contentItem.customAction) {
        self.contentItem.customAction();
    }
    
    if (completion) {
        completion(self, nil, nil);
    }
}

@end
