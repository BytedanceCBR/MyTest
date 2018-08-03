//
//  ArticleMomentCommentModel.m
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import "ArticleMomentCommentModel.h"
#import "SSUserModel.h"

@interface ArticleMomentCommentModel()
@end

@implementation ArticleMomentCommentModel

+ (NSArray*)commentsWithArray:(NSArray*)array
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for(NSDictionary *data in array)
    {
        ArticleMomentCommentModel *model = [[ArticleMomentCommentModel alloc] initWithDictionary:data];
        [result addObject:model];
    }
    
    return result;
}

- (void)dealloc
{
    self.content = nil;
    self.replyID = nil;
    self.replyUser = nil;
    self.user = nil;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if(self)
    {
        if([dict objectForKey:@"id"])
        {
            self.ID = [dict tt_stringValueForKey:@"id"];
        }
        
        self.content = [dict tt_stringValueForKey:@"content"];
        self.createTime = [dict tt_doubleValueForKey:@"create_time"];
        self.replyID = [dict tt_stringValueForKey:@"reply_id"];
        
        id userData = [dict objectForKey:@"user"];
        if ([userData isKindOfClass:[NSDictionary class]]) {
            self.user = [[SSUserModel alloc] initWithDictionary:userData];
        } else if ([userData isKindOfClass:[SSUserModel class]]) {
            self.user = userData;
        }
        
        if ([dict objectForKey:@"reply_user"]) {
            self.replyUser = [[SSUserModel alloc] initWithDictionary:[dict objectForKey:@"reply_user"]];
        }
        
        self.diggCount = [dict tt_intValueForKey:@"digg_count"];
        self.userDigged = [dict tt_boolValueForKey:@"user_digg"];
        self.isPgcAuthor = [dict tt_boolValueForKey:@"is_pgc_author"];
        
        if (dict[@"reply_to_comment"]) {
            self.qutoedComment = [[TTQutoedCommentModel alloc] initWithDictionary:dict[@"reply_to_comment"]];
        }
        self.isOwner = [[dict objectForKey:@"is_owner"] boolValue];

        self.height = 0.0;
        self.descHeight = 0.0;
    }
    
    return self;
}

- (NSDictionary *)toDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.ID forKey:@"id"];
    [dict setValue:self.content forKey:@"content"];
    [dict setValue:@(self.createTime) forKey:@"create_time"];
    [dict setValue:self.replyID forKey:@"reply_id"];
    [dict setValue:[self.user toDict] forKey:@"user"];
    [dict setValue:[self.replyUser toDict] forKey:@"reply_user"];
    [dict setValue:@(self.diggCount) forKey:@"digg_count"];
    [dict setValue:@(self.userDigged) forKey:@"user_digg"];
    [dict setValue:@(self.isPgcAuthor) forKey:@"is_pgc_author"];
    [dict setValue:@(self.isLocal) forKey:@"is_local"];
    return [dict copy];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"ID:%@, content:%@, createTime:%@, replyID:%@, user:%@, replyUser:%@ diggCount:%d, isPgcAuthor:%d, isLocal:%d", self.ID, _content, @(_createTime), _replyID, _user, _replyUser, _diggCount, self.isPgcAuthor, self.isLocal];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.createTime = [[aDecoder decodeObjectForKey:@"create_time"] doubleValue];
        self.replyID = [aDecoder decodeObjectForKey:@"reply_id"];
        self.user = [aDecoder decodeObjectForKey:@"user"];
        self.replyUser = [aDecoder decodeObjectForKey:@"reply_user"];
        self.diggCount = [[aDecoder decodeObjectForKey:@"digg_count"] intValue];
        self.isPgcAuthor = [aDecoder decodeBoolForKey:@"is_pgc_author"];
        self.isLocal = [aDecoder decodeBoolForKey:@"is_local"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:@(_createTime) forKey:@"create_time"];
    [aCoder encodeObject:_replyID forKey:@"reply_id"];
    [aCoder encodeObject:_user forKey:@"user"];
    [aCoder encodeObject:_replyUser forKey:@"reply_user"];
    [aCoder encodeObject:@(_diggCount) forKey:@"digg_count"];
    [aCoder encodeBool:_isPgcAuthor forKey:@"is_pgc_author"];
    [aCoder encodeBool:_isLocal forKey:@"is_local"];
}

@end
