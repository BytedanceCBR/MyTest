//
//  Comment.m
//  Article
//
//  Created by 王双华 on 16/11/10.
//
//

#import "Comment.h"
#import "FriendDataManager.h"
#import "TTBlockManager.h"
#import "TTUGCDefine.h"
//#import "Thread.h"
#import "TTCommentDataManager.h"
#import <TTAccountBusiness.h>
#import <DetailActionRequestManager.h>

extern NSString *const kTTEditUserInfoDidFinishNotificationName;

@interface Comment ()

@property (nullable, nonatomic, retain) DetailActionRequestManager * actionRequestManager;

@end

@implementation Comment
+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"commentDict",
                       @"commentExtra",
                       @"title",
                       @"filterWords",
                       @"source",
                       @"cellLayoutStyle",
                       @"actionList",
                       @"aggrType",
                       @"groupID",
                       @"itemID",
                       @"hasVideo",
                       @"articleUserInfo",
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"aggrType":@"aggr_type",
                                         @"cellLayoutStyle":@"cell_layout_style",
                                         @"groupID":@"group_id",
                                         @"hasVideo":@"has_video",
                                         @"sourceOpenUrl":@"source_open_url",
                                         @"articleUserInfo":@"user_info",
                                         @"itemID":@"item_id",
                                       }];
        properties = [dict copy];
    }
    return properties;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserveNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeObserveNotification];
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    [super updateWithDictionary:dataDict];
    
    if ([dataDict objectForKey:@"comment"]) {
        self.commentDict = [dataDict tt_dictionaryValueForKey:@"comment"];
    }
    
    if ([dataDict objectForKey:@"comment_extra"]) {
        self.commentExtra = [dataDict tt_dictionaryValueForKey:@"comment_extra"];
    }
    
    if ([dataDict objectForKey:@"filter_words"]) {
        self.filterWords = [dataDict tt_arrayValueForKey:@"filter_words"];
    }
    
    if ([dataDict objectForKey:@"action_list"]) {
        self.actionList = [dataDict tt_arrayValueForKey:@"action_list"];
    }
}

#pragma make - Notification
#pragma make - Notification
- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentForwardSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentRepostSuccess:) name:kCommentRepostSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserInfoDidFinish:) name:kTTEditUserInfoDidFinishNotificationName object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)followNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    if (!isEmptyString(userID) && [userID isEqualToString:self.userID]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        if (actionType == FriendActionTypeFollow) {
            [self setIsFollowed:YES];
        }else if (actionType == FriendActionTypeUnfollow) {
            [self setIsFollowed:NO];
        }
        [self save];
    }
}

- (void)blockNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    if (!isEmptyString(userID) && [userID isEqualToString:self.userID]) {
        BOOL isBlocking = [notify.userInfo[kIsBlockingKey] boolValue];
        if (isBlocking) {
            [self setIsFollowed:NO];
        }
        [self save];
    }
}

- (void)commentForwardSuccess:(NSNotification *)notification {
//    if ([notification.userInfo[@"repostOperationItemType"] integerValue] == TTRepostOperationItemTypeComment && [notification.userInfo[@"repostOperationItemID"] isEqualToString:[self commentID]]) {
//        [self repostSuccess];
//    }
}

- (void)commentRepostSuccess:(NSNotification *)notification {
    NSString *optID = [notification.userInfo tt_stringValueForKey:kCommentRepostOptID];
    if ([optID isEqualToString:[self commentID]]) {
        [self repostSuccess];
    }
}

- (void)repostSuccess {
    NSMutableDictionary* dictionary = nil;
    NSUInteger count = 1;
    if (self.forwardInfo) {
        dictionary = self.forwardInfo.mutableCopy;
        count = [dictionary[@"forward_count"] integerValue] + 1;
    } else {
        dictionary = @{}.mutableCopy;
    }
    dictionary[@"forward_count"] = @(count);
    self.forwardInfo = dictionary;
}

- (void)editUserInfoDidFinish:(NSNotification *)notification {
    if ([[self userID] isEqualToString:[TTAccountManager userID]]) {
        NSString * screenName = [self userName];
        if (![screenName isEqualToString:[TTAccountManager userName]]) {
            NSMutableDictionary * commentDic = nil;
            if (self.commentDict) {
                commentDic = [NSMutableDictionary dictionaryWithDictionary:self.commentDict];
            }else {
                commentDic = [NSMutableDictionary dictionary];
            }
            [commentDic setValue:[TTAccountManager userName]
                          forKey:@"user_name"];
            self.commentDict = commentDic.copy;
            [self save];
        }
        
        NSString * avatarUrl = [self userAvatarURL];
        if (![avatarUrl isEqualToString:[TTAccountManager avatarURLString]]) {
            NSMutableDictionary * commentDic = nil;
            if (self.commentDict) {
                commentDic = [NSMutableDictionary dictionaryWithDictionary:self.commentDict];
            }else {
                commentDic = [NSMutableDictionary dictionary];
            }
            [commentDic setValue:[TTAccountManager avatarURLString]
                          forKey:@"user_profile_image_url"];
            self.commentDict = commentDic.copy;
            [self save];
        }
    }
}

///////// commentDict

- (NSDictionary *)forwardInfo {
    NSDictionary *result = nil;
    if ([self.commentExtra objectForKey:@"forward_info"]) {
        result = [self.commentExtra tt_dictionaryValueForKey:@"forward_info"];
    }
    return result;
}

- (void)setForwardInfo:(NSDictionary *)forwardInfo {
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:self.commentExtra];
    [muDict setValue:forwardInfo forKey:@"forward_info"];
    self.commentExtra = [muDict copy];
    [self save];
}

/**
 *  评论用户的id
 */
- (nullable NSString *)userID
{
    NSString *result = nil;
    if ([self.commentDict objectForKey:@"user_id"]) {
        result = [self.commentDict tt_stringValueForKey:@"user_id"];
    }
    return result;
}

- (DetailActionRequestManager *)actionRequestManager {
    if (!_actionRequestManager) {
        _actionRequestManager = [DetailActionRequestManager new];
        [_actionRequestManager setContext:({
            TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
            context.groupModel = [[TTGroupModel alloc] initWithGroupID:self.groupID
                                                                itemID:self.itemID
                                                          impressionID:nil
                                                              aggrType:self.aggrType.integerValue];
            context.itemCommentID = self.commentID;
            context;
        })];
    }
    return _actionRequestManager;
}

- (nullable NSString *)articleUserID {
    NSString *result = nil;
    if ([self.articleUserInfo objectForKey:@"user_id"]) {
        result = [self.articleUserInfo tt_stringValueForKey:@"user_id"];
    }
    return result;
}

- (nullable NSString *)articleUserName {
    NSString *result = nil;
    if ([self.articleUserInfo objectForKey:@"name"]) {
        result = [self.articleUserInfo tt_stringValueForKey:@"name"];
    }
    return result;
}

- (nullable NSString *)articleUserAvatar {
    NSString *result = nil;
    if ([self.articleUserInfo objectForKey:@"avatar_url"]) {
        result = [self.articleUserInfo tt_stringValueForKey:@"avatar_url"];
    }
    return result;
}

- (BOOL)articleUserVerified {
//    BOOL result = NO;
//    if ([self.articleUserInfo objectForKey:@"user_verified"]) {
//        result = [self.articleUserInfo tt_boolValueForKey:@"user_verified"];
//    }
    return NO;
}

/**
 *  评论内容
 */
- (nonnull NSString *)commentContent
{
    NSString *result = nil;
    if ([self.commentDict objectForKey:@"text"]) {
        result = [self.commentDict tt_stringValueForKey:@"text"];
    }
    return result;
}
/**
 *  评论用户头条展现信息
 */
- (NSString *)userAuthInfo
{
    return [self.commentDict tt_stringValueForKey:@"user_auth_info"];
}

- (NSString *)userDecoration
{
    return [self.commentDict tt_stringValueForKey:@"user_decoration"];
}
/**
 *  评论用户认证信息
 */
- (nullable NSString *)userVerifiedContent
{
    NSString *result = nil;
    if ([self.commentExtra objectForKey:@"verified_content"]) {
        result = [self.commentExtra tt_stringValueForKey:@"verified_content"];
    }
    return result;
}
/**
 *  顶的数量
 */
- (int)diggCount
{
    int result = 0;
    if ([self.commentDict objectForKey:@"digg_count"]) {
        result = [self.commentDict tt_intValueForKey:@"digg_count"];
    }
    return result;
}
/**
 *  是否已顶
 */
- (BOOL)userDigg
{
    BOOL result = NO;
    if ([self.commentDict objectForKey:@"user_digg"]) {
        result = [self.commentDict tt_boolValueForKey:@"user_digg"];
    }
    return result;
}
/**
 *  评论数
 */
- (int)commentCount
{
    int result = 0;
    if ([self.commentDict objectForKey:@"reply_count"]) {
        result = [self.commentDict tt_intValueForKey:@"reply_count"];
    }
    return result;
}
/**
 *  评论用户头像
 */
- (nullable NSString *)userAvatarURL
{
    NSString *result = nil;
    if ([self.commentDict objectForKey:@"user_profile_image_url"]) {
        result = [self.commentDict tt_stringValueForKey:@"user_profile_image_url"];
    }
    return result;
}
/**
 *  用户名
 */
- (nullable NSString *)userName
{
    NSString *result = nil;
    if ([self.commentDict objectForKey:@"user_name"]) {
        result = [self.commentDict tt_stringValueForKey:@"user_name"];
    }
    return result;
}
/**
 *  评论id
 */
- (nullable NSString *)commentID
{
    NSString *result = nil;
    if ([self.commentDict objectForKey:@"id"]) {
        result = [self.commentDict tt_stringValueForKey:@"id"];
    }
    return result;
}

///////// commentExtra
/**
 *  评论显示最大行数
 */
- (NSUInteger)maxLineNumber
{
    NSUInteger result = 0;
    if ([self.commentExtra objectForKey:@"reply_max_line"]) {
        result = [self.commentExtra tt_intValueForKey:@"reply_max_line"];
    }
    return result;
}
/**
 *  点击评论用户头像跳转url
 */
- (nullable NSString *)sourceOpenURL
{
    NSString *result = nil;
    if ([self.commentExtra objectForKey:@"source_open_url"]) {
        result = [self.commentExtra tt_stringValueForKey:@"source_open_url"];
    }
    return result;
}
/**
 *  文章缩略图url
 */
- (nullable NSString *)articleImageUrl
{
    NSString *result = nil;
    if ([self.commentExtra objectForKey:@"article_thumb_image_url"]) {
        result = [self.commentExtra tt_stringValueForKey:@"article_thumb_image_url"];
    }
    return result;
}
/**
 *  评论跳转url
 */
- (nullable NSString *)commentOpenURL
{
    NSString *result = nil;
    if ([self.commentExtra objectForKey:@"comment_open_url"]) {
        result = [self.commentExtra tt_stringValueForKey:@"comment_open_url"];
    }
    return result;
}
///**
// *  动态id
// */
//- (nullable NSString *)dongtaiID
//{
//    NSString *result = nil;
//    if ([self.commentExtra objectForKey:@"dongtai_id"]) {
//        result = [self.commentExtra tt_stringValueForKey:@"dongtai_id"];
//    }
//    return result;
//}

/**
 *  推荐原因类型
 */
- (nullable NSNumber *)recommendReasonType
{
    NSNumber *result = nil;
    if ([self.commentExtra objectForKey:@"recommend_reason_type"]) {
        result = @([self.commentExtra tt_intValueForKey:@"recommend_reason_type"]);
    }
    return result;
}
/**
 *  点击文章跳转url
 */
- (nullable NSString *)articleOpenURL
{
    NSString *result = nil;
    if ([self.commentExtra objectForKey:@"article_open_url"]) {
        result = [self.commentExtra tt_stringValueForKey:@"article_open_url"];
    }
    return result;
}
/**
 *  是否已关注
 */
- (BOOL)isFollowed
{
    BOOL result = NO;
    if ([self.commentExtra objectForKey:@"follow"]) {
        result = [self.commentExtra tt_boolValueForKey:@"follow"];
    }
    return result;
}

- (BOOL)userIsFollowed
{
    BOOL result = NO;
    if ([self.commentExtra objectForKey:@"is_followed"]) {
        result = [self.commentExtra tt_boolValueForKey:@"is_followed"];
    }
    return result;
}

- (void)setIsFollowed:(BOOL)followed
{
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:self.commentExtra];
    [muDict setValue:@(followed) forKey:@"follow"];
    self.commentExtra = [muDict copy];
    [self save];
}

- (void)updateDictWithUserDigg:(BOOL)userDigg
{
    if (self.userDigg == userDigg){
        return;
    }
    if ([self.commentDict count] > 0){
        NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:self.commentDict];
        [muDict setValue:@(userDigg) forKey:@"user_digg"];
        self.commentDict = [muDict copy];
        [self save];
    }
}

- (void)updateDictWithDiggCount:(NSNumber *)diggCount
{
    if (self.diggCount == [diggCount intValue]){
        return;
    }
    
    if ([self.commentDict count] > 0) {
        NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:self.commentDict];
        [muDict setValue:diggCount forKey:@"digg_count"];
        self.commentDict = [muDict copy];
        [self save];
    }
}
@end
