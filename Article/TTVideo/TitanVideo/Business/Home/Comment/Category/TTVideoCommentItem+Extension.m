//
//  TTVideoCommentItem+Extension.m
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVideoCommentItem+Extension.h"
#import "TTVCommentListReplyModel.h"
#import "TTAccountManager.h"

@implementation TTVideoCommentItem(Extension)


- (TTVideoCommentStructModel *)comment {
    
    return self.originItem.comment;
}

- (NSString *)userProfileURL {
    
    return self.comment.user_profile_url;
}

- (NSString *)accessoryInfo {
    
    return self.comment.additional_info;
}

- (ExploreForumModel *)forumModel {
    
    return nil;// 视频评论没有用到
}

- (NSString *)userPlatform {
    
    return self.comment.platform;
}

- (NSString *)fromSite {
    
    NSString *fromSiteDisplayStr = [[TTPlatformAccountManager sharedManager] platformDisplayNameForKey:self.userPlatform];
    
    return (!isEmptyString(fromSiteDisplayStr)) ? fromSiteDisplayStr: self.userPlatform;
}

- (NSNumber *)buryCount {
    
    return self.comment.bury_count;
}

- (void)setBuryCount:(NSNumber *)buryCount {
    
    if ([buryCount isKindOfClass:[NSNumber class]]) {
        
        self.comment.bury_count = buryCount;
    }
}

- (BOOL)isBlocked {
    
    return self.comment.is_blocked.boolValue;
}

- (void)setIsBlocked:(BOOL)isBlocked {
    
    self.comment.is_blocked = @(isBlocked);
}

- (BOOL)isBlocking {
    
    return self.comment.is_blocking.boolValue;
}

- (void)setIsBlocking:(BOOL)isBlocking {
    
     self.comment.is_blocking = @(isBlocking);
}

- (NSString *)userSignature {
    
    return self.comment.description_text;
}

- (BOOL)isAvailable {
    
    return (self.commentIDNum)? YES: NO;
}

- (BOOL)isPGCAuthor {
    
    return self.comment.is_pgc_author.boolValue;
}

- (NSNumber *)commentIDNum {
    
    return self.comment.id;
}

- (NSString *)commentID
{
    return [[self commentIDNum] stringValue];
}

- (NSString *)mediaName {

    return self.comment.media_info.name;
}

- (NSString *)mediaId {
    
    return self.comment.media_info.media_id;
}

- (NSString *)userName {
    
    return self.comment.user_name;
}

- (NSNumber *)userID {
 
    return self.comment.user_id;
}

- (BOOL)hasReply {
    
    return self.comment.reply_count.integerValue && self.comment.reply_list.count;
}

- (NSNumber *)commentCreateTime {
    
    return self.comment.create_time;
}

- (NSString *)commentContent {
    
    return self.comment.text;
}

- (NSString *)commentContentRichSpanJSONString {

    return self.comment.content_rich_span;
}

- (NSString *)userAvatarURL {

    
    return self.comment.user_profile_image_url;
}

- (NSString *)userAuthInfo {
    
    return self.comment.user_auth_info;
}

- (BOOL)userDigged {
    
    return self.comment.user_digg.boolValue;
}

- (void)setUserDigged:(BOOL)userDigged {
    
    self.comment.user_digg = @(userDigged);
}

- (BOOL)userBuried {
    
    return self.comment.user_bury.boolValue;
}

- (void)setUserBuried:(BOOL)userBuried {
    
    self.comment.user_bury = @(userBuried);
}

- (NSString *)verifiedInfo {
    
    return self.comment.verified_reason;
}

- (BOOL)isFollowed {
    
    return self.comment.is_followed.boolValue;
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    self.comment.is_following = @(isFollowing);
}

- (BOOL)isFollowing {
    
    return self.comment.is_following.boolValue;
}

- (NSArray *)authorBadgeList {
    
    NSArray<TTAuthorBadgeStructModel> *authorBadge = self.comment.author_badge;
    
    if (![authorBadge isKindOfClass:[NSArray class]]) {
        
        return nil;
    }
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:authorBadge.count];
    for (TTAuthorBadgeStructModel *model in authorBadge) {
        
       NSDictionary *dict = [model toDictionary];
       
        if (dict) {
            
            [list addObject:dict];
        }
    }
    
    return list;
}

- (NSNumber *)digCount {
    
    return self.comment.digg_count;
}

- (void)setDigCount:(NSNumber *)digCount {
    
    self.comment.digg_count = digCount;
}

- (TTQuotedCommentStructModel *)quotedComment {
    
    return self.comment.reply_to_comment;
}

- (NSNumber *)userRelation {
    
    return self.comment.user_relation;
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

- (NSString *)userInfoStr {
    
    NSString *result = @"";
    if (!isEmptyString(self.mediaName)) {
        result = [result stringByAppendingString:self.mediaName];
    }
    if (!isEmptyString(self.mediaName) && !isEmptyString(self.verifiedInfo)) {
        result = [result stringByAppendingString:@", "];
    }
    if (!isEmptyString(self.verifiedInfo)) {
        result = [result stringByAppendingString:self.verifiedInfo];
    }
    return result;
}

//- (NSString *)description {
//    
//    return [NSString stringWithFormat:@"_groupID: %@, _commentID %@, forumID:%@, _userAvatarURL %@, badgeList:%@", self.groupModel.groupID, self.comment.commentID, _forumModel.forumID, _userAvatarURL, _authorBadgeList];
//}


- (BOOL)isOwner {
    
    return self.comment.is_owner.boolValue;
}

- (NSArray<TTVCommentListReplyModel *> *)replyList {
    
    return ([self.comment.reply_list isKindOfClass:[NSArray class]]) ? self.comment.reply_list: nil;
}

- (TTReplyListStructModel *)replyStructModelAtIndex:(NSUInteger)index {
    
    if (index >= self.replyList.count) {
        
        return nil;
    }
    
    return self.replyList[index];
}

- (NSNumber *)replyCount {
    
    return self.comment.reply_count;
}

- (void)setReplyCount:(NSNumber *)replyCountForCurCommment {

    self.comment.reply_count = replyCountForCurCommment;
}

- (NSString *)openURL {

    return self.comment.open_url;
}

- (BOOL)banEmojiInput
{
    return NO;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict groupModel:(TTGroupModel *)groupModel {
    
    if (self = [super init]) {
        self.originItem = [[TTCommentDataStructModel alloc] init];
        self.originItem.comment = [[TTVideoCommentStructModel alloc] initWithDictionary:dict error:nil];
        self.groupModel = groupModel;
    }
    
    return self;
}

#pragma mark - TTCommentDetailModelProtocol

- (NSString *)userDecoration
{
    return self.originItem.comment.user_decoration;
}


- (NSString *)userIDStr
{
    return [self.userID stringValue];
}

- (NSString *)content
{
    return self.commentContent;
}

- (NSString *)contentRichSpanJSONString{
    return self.comment.content_rich_span;
}

- (NSString *)qutoedCommentModel_commentID {
    return [self.quotedComment.id stringValue];
}

- (NSString *)qutoedCommentModel_userID
{
    return [self.quotedComment.user_id stringValue];
}

- (NSString *)qutoedCommentModel_userName
{
    return self.quotedComment.user_name;
}

- (NSString *)qutoedCommentModel_commentContent
{
    return self.quotedComment.text;
}

- (NSString *)qutoedCommentModel_commentContentRichSpan{
    return self.quotedComment.content_rich_span;
}

@end
