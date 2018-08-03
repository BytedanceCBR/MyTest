//
//  TTCommentDetailModel.m
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import "TTCommentDetailModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

@implementation TTCommentDetailModel

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self = [super initWithDictionary:dict error:err];
    if (self) {
        
        NSDictionary *groupDic = [dict dictionaryValueForKey:@"group" defalutValue:nil];
        self.groupModel = [[TTGroupModel alloc] initWithGroupID:[groupDic stringValueForKey:@"group_id" defaultValue:nil] itemID:[groupDic stringValueForKey:@"item_id" defaultValue:nil] impressionID:nil aggrType:0];

        self.qutoedCommentModel = [[TTQutoedCommentModel alloc] initWithDictionary:[dict dictionaryValueForKey:@"reply_to_comment" defalutValue:nil]];
        NSDictionary *user = [dict dictionaryValueForKey:@"user" defalutValue:nil];
        self.user = [[SSUserModel alloc] initWithDictionary:user];
    }
    
    return self;
}

- (NSMutableOrderedSet *)digUsers {
    if (!_digUsers) {
        _digUsers = [[NSMutableOrderedSet alloc] init];
    }
    return _digUsers;
}

+(JSONKeyMapper*)keyMapper {
    NSDictionary *keyMapperDic = @{
        @"is_pgc_author": @"isPGCAuthor",
        @"create_time": @"createTime",
        @"user": @"user",
        @"user_digg": @"userDigg",
        @"id": @"commentID",
        @"digg_count": @"diggCount",
        @"share_url": @"shareURL",
        @"content": @"content",
        @"content_rich_span": @"contentRichSpanJSONString",
        @"comment_count": @"commentCount",
        @"delete": @"isDeleted",
        @"dongtai_id": @"dongtaiID",
        @"group.title" : @"groupTitle",
        @"group.content":@"groupContent",
        @"group.content_rich_span":@"groupContentRichSpan",
        @"group.user_name":@"groupUserName",
        @"group.user_id":@"groupUserId",
        @"group.thumb_url" : @"groupThumbURL",
        @"group.media_type" : @"groupMediaType",
        @"group.open_url" : @"groupOpenURL",
        @"log_param.author_id": @"authorID",
        @"log_param.group_source": @"groupSource"
    };
    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"digUsers"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"commentPlaceholder"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"banEmojiInput"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"banForwardToWeitoutiao"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"show_repost_weitoutiao_entrance"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"groupMediaType"]) {
        return YES;
    }
    return NO;
}
@end
