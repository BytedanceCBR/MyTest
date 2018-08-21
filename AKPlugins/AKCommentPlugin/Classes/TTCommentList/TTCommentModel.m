//
//  TTCommentModel.m
//  Article
//
//  Created by 冯靖君 on 16/3/30.
//
//

#import "TTCommentDefines.h"
#import "TTCommentModel.h"
#import "TTCommentReplyModel.h"
#import <TTPlatformUIModel/TTGroupModel.h>
#import <TTPlatformUIModel/TTForumModel.h>
#import <TTAccountBusiness.h>
#import <TTBaseLib/TTStringHelper.h>

@interface TTCommentModel ()

@property(nonatomic, assign) BOOL userVerified;
@property(nonatomic, assign) BOOL isPGCAuthor;

@property(nonatomic, strong) NSNumber * commentID;
@property(nonatomic, strong) NSNumber * commentCreateTime;
@property(nonatomic, strong) NSNumber * userID;

@property(nonatomic, copy) NSString * userName;
@property(nonatomic, copy) NSString * commentContent;
@property(nonatomic, copy) NSString * commentContentRichSpanJSONString;
@property(nonatomic, copy) NSString<Optional> * fromSite;
@property(nonatomic, copy) NSString * userAvatarURL;
@property(nonatomic, copy) NSString<Optional> * openURL;
@property(nonatomic, copy) NSString<Optional> * userProfileURL;
@property(nonatomic, copy) NSString<Optional> * userPlatform;
@property(nonatomic, copy) NSString<Optional> * mediaName;
@property(nonatomic, copy) NSString<Optional> * mediaId;
@property(nonatomic, copy) NSString<Ignore> * itemTag;
@property(nonatomic, copy) NSString<Optional> * userSignature;
@property(nonatomic, copy) NSString<Optional> * userDecorator;
@property(nonatomic, copy) NSString<Optional> * accessoryInfo;
@property(nonatomic, copy) NSString<Optional> * verifiedInfo;
@property(nonatomic, copy) NSString<Optional> * userAuthInfo;

@property(nonatomic, copy) NSArray<TTCommentReplyModel *> *replyModelArr;
@property(nonatomic, copy) NSArray<Optional> *authorBadgeList;

@property(nonatomic, strong) TTGroupModel<Ignore> *groupModel;
@property(nonatomic, strong) TTForumModel<Optional> *forumModel;

@property(nonatomic, assign) BOOL shouldShowDelete;    //该条评论是否可删除，默认NO

@end

@implementation TTCommentModel
@synthesize userRelation, isOwner, isFollowing, isFollowed, isUnFold, isStick;

- (instancetype)initWithDictionary:(NSDictionary *)dict groupModel:(TTGroupModel *)groupModel
{
    NSError *error;
    if (self = [super initWithDictionary:dict error:&error]) {
        
        NSString *fromSiteDisplayStr = [[TTPlatformAccountManager sharedManager] platformDisplayNameForKey:[dict objectForKey:@"platform"]];
        
        if ([fromSiteDisplayStr length] > 0) {
            self.fromSite = fromSiteDisplayStr;
        } else {
            self.fromSite = [self.userPlatform copy];
        }

        NSArray *replyList = [dict arrayValueForKey:@"reply_list" defaultValue:nil];
        if (replyList.count) {
            NSMutableArray *tArr = [NSMutableArray array];
            for (NSDictionary *replyDict in replyList) {
                [tArr addObject:[TTCommentReplyModel replyModelWithDict:replyDict forCommentID:[self.commentID stringValue]]];
            }
            self.replyModelArr = tArr;
        }

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

        NSDictionary *mediaInfo = [dict dictionaryValueForKey:@"media_info" defalutValue:nil];
        self.mediaName = [mediaInfo stringValueForKey:@"name" defaultValue:nil];
        self.mediaId = [mediaInfo stringValueForKey:@"media_id" defaultValue:nil];

        [self addNotification];
    }

    return self;
}

- (instancetype)initWithCommentRepostDictionary:(nullable NSDictionary *)dict {
    if (SSIsEmptyDictionary(dict)) {
        return nil;
    }

    NSString *commentID = [dict tt_stringValueForKey:@"id"];
    if (isEmptyString(commentID)) {
        return nil;
    }

    NSDictionary *originThreadDict = [dict tt_dictionaryValueForKey:@"origin_thread"];
    NSDictionary *originGroupDict = [dict tt_dictionaryValueForKey:@"origin_group"];
    NSDictionary *commentBaseDict = [dict tt_dictionaryValueForKey:@"comment_base"];
    if (SSIsEmptyDictionary(commentBaseDict)) {
        return nil;
    }

    NSDictionary *userDict = [commentBaseDict tt_dictionaryValueForKey:@"user"];
    NSDictionary *actionDict = [commentBaseDict tt_dictionaryValueForKey:@"action"];

    self = [super init];
    if (self) {
        self.commentID = @([dict tt_stringValueForKey:@"id"].longLongValue);
        self.commentContent = [commentBaseDict tt_stringValueForKey:@"content"];
        self.commentContentRichSpanJSONString = [commentBaseDict tt_stringValueForKey:@"content_rich_span"];
        self.commentCreateTime = @([commentBaseDict tt_longlongValueForKey:@"create_time"]);
        self.quotedComment = nil;
        self.replyModelArr = nil;
        if (!SSIsEmptyDictionary(originThreadDict)) {
            self.groupModel = [[TTGroupModel alloc] initWithGroupID:[originThreadDict tt_stringValueForKey:@"thread_id"]];
        } else if (!SSIsEmptyDictionary(originGroupDict)) {
            self.groupModel = [[TTGroupModel alloc] initWithGroupID:[originGroupDict tt_stringValueForKey:@"group_id"]];
        }
        self.forumModel = nil;

        self.userID = @([[userDict tt_dictionaryValueForKey:@"info"] tt_longValueForKey:@"user_id"]);
        self.userName = [[userDict tt_dictionaryValueForKey:@"info"] tt_stringValueForKey:@"name"];
        self.userAuthInfo = [[userDict tt_dictionaryValueForKey:@"info"] tt_stringValueForKey:@"user_auth_info"];
        self.verifiedInfo = [[userDict tt_dictionaryValueForKey:@"info"] tt_stringValueForKey:@"verified_content"];
        self.userAvatarURL = [[userDict tt_dictionaryValueForKey:@"info"] tt_stringValueForKey:@"avatar_url"];
        self.isPGCAuthor = NO;
        self.authorBadgeList = nil;

        self.isFollowed = [[userDict tt_dictionaryValueForKey:@"relation"] tt_boolValueForKey:@"is_followed"];
        self.isFollowing = [[userDict tt_dictionaryValueForKey:@"relation"] tt_boolValueForKey:@"is_following"];

        self.isBlocking = [[userDict tt_dictionaryValueForKey:@"block"] tt_boolValueForKey:@"is_blocking"];
        self.isBlocked = [[userDict tt_dictionaryValueForKey:@"block"] tt_boolValueForKey:@"is_blocked"];

        self.buryCount = @([actionDict tt_intValueForKey:@"bury_count"]);
        self.userBuried = [actionDict tt_boolValueForKey:@"user_bury"];
        self.userDigged = [actionDict tt_boolValueForKey:@"user_digg"];
        self.digCount = @([actionDict tt_intValueForKey:@"digg_count"]);
        self.replyCount = @(0);

        [self addNotification];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TTCommentModel * model = [[TTCommentModel allocWithZone:zone] init];
    model.userSignature = self.userSignature;
    model.itemTag = self.itemTag;
    model.groupModel = self.groupModel;
    model.forumModel = self.forumModel;
    model.replyModelArr = (NSArray<TTCommentReplyModel> *)self.replyModelArr;
    model.digCount = self.digCount;
    model.buryCount = self.buryCount;
    model.replyCount = self.replyCount;
    model.commentID = self.commentID;
    model.userName = self.userName;
    model.commentContent = self.commentContent;
    model.commentContentRichSpanJSONString = self.commentContentRichSpanJSONString;
    model.fromSite = self.fromSite;
    model.commentCreateTime = self.commentCreateTime;
    model.userAvatarURL = self.userAvatarURL;
    model.userID = self.userID;
    model.userProfileURL = self.userProfileURL;
    model.userPlatform = self.userPlatform;
    model.accessoryInfo = self.accessoryInfo;
    model.verifiedInfo = self.verifiedInfo;
    model.isPGCAuthor = self.isPGCAuthor;
    model.isOwner = self.isOwner;
    model.isBlocked = self.isBlocked;
    model.isBlocking = self.isBlocking;
    model.openURL = self.openURL;
    model.authorBadgeList = self.authorBadgeList;
    model.mediaName = self.mediaName;
    model.mediaId = self.mediaId;
    model.isFollowing = self.isFollowing;
    model.isFollowed = self.isFollowed;
    model.isOwner = self.isOwner;
    model.shouldShowDelete = self.shouldShowDelete;
    model.userDecorator = self.userDecorator;
    
    return model;
}

- (void)dealloc {
    [self removeNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editUserInfoDidFinish:)
                                                 name:@"kTTEditUserInfoDidFinishNotificationName"
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)editUserInfoDidFinish:(NSNotification *)notification {
    if ([self.userID.stringValue isEqual:[TTAccountManager userID]]) {
        if (![self.userName isEqualToString:[TTAccountManager userName]]) {
            self.userName = [TTAccountManager userName];
        }
        if (![self.userAvatarURL isEqualToString:[TTAccountManager avatarURLString]]) {
            self.userAvatarURL = [TTAccountManager avatarURLString];
        }
    }
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

- (NSString *)userRelationStr {
    NSString *result = nil;
    if (self.isFollowing && self.isFollowed) {
        result = @"(互相关注)";
    }
    if (self.isFollowing && !self.isFollowed) {
        result = @"(已关注)";
    }
    return result;
}

- (NSString *)userDecoration {
    return self.userDecorator;
}

- (NSString *)userInfoStr {
    NSString *result = @"";
    if (self.mediaName) {
        result = [result stringByAppendingString:self.mediaName];
    }
    if (self.mediaName && self.verifiedInfo) {
        result = [result stringByAppendingString:@", "];
    }
    if (self.verifiedInfo) {
        result = [result stringByAppendingString:self.verifiedInfo];
    }
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"_groupID: %@, _commentID %@, forumID:%@, _userAvatarURL %@, badgeList:%@", _groupModel.groupID, _commentID, _forumModel.forumID, _userAvatarURL, _authorBadgeList];
}

#pragma mark - JSONModel
+(JSONKeyMapper*)keyMapper {
    NSDictionary *keyMapperDic = @{@"id": @"commentID",
                                   @"create_time": @"commentCreateTime",
                                   @"user_id": @"userID",
                                   @"user_name": @"userName",
                                   @"text":  @"commentContent",
                                   @"content_rich_span":  @"commentContentRichSpanJSONString",
                                   @"user_profile_image_url": @"userAvatarURL",
                                   @"user_profile_url": @"userProfileURL",
                                   @"platform": @"userPlatform",
                                   @"description": @"userSignature",
                                   @"additional_info": @"accessoryInfo",
                                   @"open_url": @"openURL",
                                   @"verified_reason": @"verifiedInfo",
                                   @"author_badge": @"authorBadgeList",
                                   @"digg_count": @"digCount",
                                   @"reply_count": @"replyCount",
                                   @"bury_count": @"buryCount",
                                   @"user_digg": @"userDigged",
                                   @"user_bury": @"userBuried",
                                   @"user_decoration" : @"userDecorator",
                                   @"is_blocking": @"isBlocking",
                                   @"is_blocked": @"isBlocked",
                                   @"is_owner": @"isOwner",
                                   @"is_following": @"isFollowing",
                                   @"is_followed": @"isFollowed",
                                   @"is_pgc_author": @"isPGCAuthor",
                                   @"user_auth_info": @"userAuthInfo",
                                   @"reply_to_comment": @"quotedComment"
                                   };
    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"shouldShowDelete"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isUnFold"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isStick"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"commentContentRichSpanJSONString"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"replyModelArr"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"userVerified"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isPGCAuthor"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isFollowing"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isFollowed"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isOwner"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isBlocked"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"isBlocking"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"userRelation"]) {
        return YES;
    }
    if ([propertyName isEqualToString:@"userDecoration"]) {
        return YES;
    }
    return NO;
    
}
@end
