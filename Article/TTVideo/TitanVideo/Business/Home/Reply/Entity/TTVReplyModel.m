//
//  TTVReplyModel.m
//  Article
//
//  Created by lijun.thinker on 2017/6/2.
//
//

#import "TTVReplyModel.h"

@implementation TTVReplyModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        self.user = [[SSUserModel alloc] initWithDictionary:[dict dictionaryValueForKey:@"user" defalutValue:nil]];
        self.qutoedCommentModel = [[TTQuotedCommentStructModel alloc] initWithDictionary:[dict dictionaryValueForKey:@"reply_to_comment" defalutValue:nil] error:nil];
    }
    return self;
}

- (NSString *)userRelationDescription {
    NSString *result = nil;
    if (self.user.isFollowing && self.user.isFollowed) {
        result = @"(互相关注)";
    }
    if (self.user.isFollowing && !self.user.isFollowed) {
        result = @"(已关注)";
    }
    return result;
}

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *keyMapperDic = @{
        @"id": @"commentID",
        @"digg_count": @"diggCount",
        @"content": @"content",
        @"content_rich_span": @"contentRichSpanJSONString",
        @"create_time": @"createTime",
        @"user_digg": @"userDigg",
        @"is_pgc_author": @"isPGCAuthor",
        @"is_owner": @"isOwner",
        @"reply_to_comment": @"qutoedCommentModel"
    };
    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"isOwner"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isPgcAuthor"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"diggCount"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"userDigg"]) {
        return YES;
    }
    return NO;
}

- (TTQuotedCommentStructModel *)tt_qutoedCommentStructModel
{
    return self.qutoedCommentModel;
}

#pragma mark - TTCommentDetailReplyCommentModelProtocol

- (NSString *)qutoedCommentModel_commentID {
    return [self.qutoedCommentModel.id stringValue];
}

- (NSString *)qutoedCommentModel_userID
{
    return [self.qutoedCommentModel.user_id stringValue];
}

- (NSString *)qutoedCommentModel_userName
{
    return self.qutoedCommentModel.user_name;
}

- (NSString *)qutoedCommentModel_commentContent
{
    return self.qutoedCommentModel.text;
}

- (NSString *)qutoedCommentModel_commentContentRichSpan{
    return self.qutoedCommentModel.content_rich_span;
}

@end
