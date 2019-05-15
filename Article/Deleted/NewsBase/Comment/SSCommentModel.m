//
//  SSCommentModel.m
//  Article
//
//  Created by Zhang Leonardo on 13-1-15.
//
//

#import "SSCommentModel.h"
#import "TTGroupModel.h"
#import "TTForumModel.h"
#import "TTCommentReplyModel.h"
#import "TTStringHelper.h"
#import <TTAccountBusiness.h>



@interface SSCommentModel ()

@property(nonatomic, assign) BOOL isPGCAuthor;

@property(nonatomic, strong) NSNumber * commentID;
@property(nonatomic, strong) NSNumber * commentCreateTime;
@property(nonatomic, strong) NSNumber * userID;

@property(nonatomic, copy) NSString * userName;
@property(nonatomic, copy) NSString * commentContent;
@property(nonatomic, copy) NSString * fromSite;
@property(nonatomic, copy) NSString * userAvatarURL;
@property(nonatomic, copy) NSString * openURL;
@property(nonatomic, copy) NSString * userProfileURL;
@property(nonatomic, copy) NSString * userPlatform;
@property(nonatomic, copy) NSString * mediaName;
@property(nonatomic, copy) NSString * mediaId;
@property(nonatomic, copy) NSString * itemTag;
@property(nonatomic, copy) NSString * userSignature;
@property(nonatomic, copy) NSString * accessoryInfo;
@property(nonatomic, copy) NSString * verifiedInfo;
@property(nonatomic, copy) NSString * userAuthInfo;

@property(nonatomic, copy) NSArray <TTCommentReplyModel *> *replyModelArr;
@property(nonatomic, copy) NSArray *authorBadgeList;

@property(nonatomic, strong) TTGroupModel *groupModel;
@property(nonatomic, strong) TTForumModel *forumModel;

@end

@implementation SSCommentModel
@synthesize quotedComment, userRelation;

- (instancetype)init
{
    return [self initWithDictionary:nil groupModel:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict groupModel:(TTGroupModel *)groupModel
{
    if (self = [super init]) {
        self.userSignature = [dict objectForKey:@"description"];
        self.commentID = @([[dict objectForKey:@"id"] longLongValue]);
        self.userName = [dict objectForKey:@"user_name"];
        self.commentContent = [dict objectForKey:@"text"];
        self.openURL = [dict objectForKey:@"open_url"];
        
        NSString *fromSiteDisplayStr = [[TTPlatformAccountManager sharedManager] platformDisplayNameForKey:[dict objectForKey:@"platform"]];
        
        if ([fromSiteDisplayStr length] > 0) {
            self.fromSite = fromSiteDisplayStr;
        }
        else {
            self.fromSite = [dict objectForKey:@"platform"];
        }
        self.commentCreateTime =  @([[dict objectForKey:@"create_time"] longValue]);
        self.userAvatarURL = [dict objectForKey:@"user_profile_image_url"];
        self.userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
        self.userDigged = [[dict objectForKey:@"user_digg"] boolValue];
        self.userBuried = [[dict objectForKey:@"user_bury"] boolValue];
        self.userID = @([[dict objectForKey:@"user_id"] longLongValue]);
        self.digCount = @([[dict objectForKey:@"digg_count"] intValue]);
        self.buryCount = @([[dict objectForKey:@"bury_count"] intValue]);
        self.replyCount = @([[dict objectForKey:@"reply_count"] intValue]);
        self.userProfileURL = [dict objectForKey:@"user_profile_url"];
        self.userPlatform = [dict objectForKey:@"platform"];
        self.verifiedInfo = [dict objectForKey:@"verified_reason"];
        self.userRelation = @([dict[@"user_relation"] intValue]);
        if (dict[@"reply_to_comment"]) {
            self.quotedComment = [[TTQutoedCommentModel alloc] initWithDictionary:dict[@"reply_to_comment"]];
        }
        self.accessoryInfo = [dict objectForKey:@"additional_info"];
        
        self.isPGCAuthor = [[dict objectForKey:@"is_pgc_author"] boolValue];
        
        self.groupModel = groupModel;
        
        if ([[dict allKeys] containsObject:@"forum_link"]) {
            TTForumModel *simpleForumModel = [[TTForumModel alloc] init];
            NSDictionary *forumLink = [dict objectForKey:@"forum_link"];
            NSString *forumID = [forumLink objectForKey:@"forum_id"];
            NSString *forumURL = [forumLink objectForKey:@"url"];
            if (isEmptyString(forumID)) {
                if (!isEmptyString(forumURL)) {
                    forumID = [[TTStringHelper parametersOfURLString:[NSURL URLWithString:forumURL].query] objectForKey:@"id"];
                }
            }
            simpleForumModel.forumID = forumID;
            simpleForumModel.desc = forumURL;    //用于scheme跳转
            simpleForumModel.name = [forumLink objectForKey:@"text"];
            self.forumModel = simpleForumModel;
        }
        
        self.isBlocking = [[dict objectForKey:@"is_blocking"] boolValue];
        self.isBlocked = [[dict objectForKey:@"is_blocked"] boolValue];
        NSArray *replyList = [dict arrayValueForKey:@"reply_list" defaultValue:nil];
        if (replyList.count) {
            NSMutableArray *tArr = [NSMutableArray array];
            for (NSDictionary * replyDict in replyList) {
                [tArr addObject:[TTCommentReplyModel replyModelWithDict:replyDict
                                                           forCommentID:[self.commentID stringValue]]];
            }
            self.replyModelArr = tArr;
        }
        
        self.authorBadgeList = [dict arrayValueForKey:@"author_badge" defaultValue:nil];
        
        // 只有头条号账号有media_info
        NSDictionary *mediaInfo = [dict tt_dictionaryValueForKey:@"media_info"];
        self.mediaName = [mediaInfo tt_stringValueForKey:@"name"];
        //model.mediaName = @"人人都是产品经理";
        self.mediaId = [mediaInfo tt_stringValueForKey:@"media_id"];
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SSCommentModel * model = [[SSCommentModel allocWithZone:zone] init];
    model.userSignature = self.userSignature;
    model.itemTag = self.itemTag;
    model.groupModel = self.groupModel;
    model.forumModel = self.forumModel;
    model.replyModelArr = self.replyModelArr;
    model.digCount = self.digCount;
    model.buryCount = self.buryCount;
    model.replyCount = self.replyCount;
    model.commentID = self.commentID;
    model.userName = self.userName;
    model.commentContent = self.commentContent;
    model.fromSite = self.fromSite;
    model.commentCreateTime = self.commentCreateTime;
    model.userAvatarURL = self.userAvatarURL;
    model.userID = self.userID;
    model.userProfileURL = self.userProfileURL;
    model.userPlatform = self.userPlatform;
    model.accessoryInfo = self.accessoryInfo;
    model.isPGCAuthor = self.isPGCAuthor;
    model.verifiedInfo = self.verifiedInfo;
    
    model.isBlocked = self.isBlocked;
    model.isBlocking = self.isBlocking;
    model.openURL = self.openURL;
    model.authorBadgeList = self.authorBadgeList;
    model.mediaName = self.mediaName;
    return model;
}

- (BOOL)isAvailable
{
    if (self.commentID == nil) {
        return NO;
    }
    return YES;
}

- (BOOL)hasReply
{
    return !![self.replyCount longLongValue] && !!self.replyModelArr.count;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"_groupID: %@, _commentID %@, forumID:%@, _userAvatarURL %@, badgeList:%@", _groupModel.groupID, _commentID, _forumModel.forumID, _userAvatarURL, _authorBadgeList];
}

@end
