//
//  TTCommentReplyModel.m
//  Article
//
//  Created by 冯靖君 on 15/12/3.
//
//

#import "TTCommentReplyModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>


@implementation TTCommentReplyModel

+ (instancetype)replyModelWithDict:(NSDictionary *)dict forCommentID:(NSString *)commentID
{
    TTCommentReplyModel *replyModel = [TTCommentReplyModel new];
    replyModel.commentID = commentID;
    replyModel.replyID = dict[@"id"];
    replyModel.userID = [dict[@"user_id"] stringValue];
    replyModel.replyUserName = dict[@"user_name"];
    replyModel.replyContent = dict[@"text"];
    replyModel.replyContentRichSpanJSONString = dict[@"content_rich_span"];
    replyModel.isArticleAuthor = [dict[@"is_pgc_author"] boolValue];
    replyModel.userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
    replyModel.authorBadge = [dict tt_arrayValueForKey:@"author_badge"];

    return replyModel;
}

- (BOOL)isUserReplyModel
{
    return !isEmptyString(self.commentID) && !isEmptyString(self.userID);
}

- (NSURL *)highlightedSelectURL
{
    NSString *urlString = nil;
    if (!isEmptyString(self.userID)) {
        urlString = [NSString stringWithFormat:@"sslocal://profile?uid=%@", self.userID];
    } else if (!isEmptyString(self.commentID)) {
        urlString = [NSString stringWithFormat:@"sslocal://moment?commentid=%@", self.commentID];
    }

    return [NSURL URLWithString:urlString];
}

#pragma mark - JSONModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *keyMapperDic = @{
        @"id": @"replyID",
        @"user_id": @"userID",
        @"user_name": @"replyUserName",
        @"text": @"replyContent",
        @"content_rich_span": @"replyContentRichSpanJSONString",
        @"is_pgc_author": @"isArticleAuthor",
        @"user_auth_info": @"userAuthInfo",
        @"author_badge" : @"authorBadge"
    };

    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName
{
    return [propertyName isEqualToString:@"notReplyMsg"];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"isArticleAuthor"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"userAuthInfo"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"authorBadge"]) {
        return YES;
    }

    return NO;
}
@end
