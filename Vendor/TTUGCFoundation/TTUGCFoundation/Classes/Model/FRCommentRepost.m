//
//  FRCommentRepost.m
//  FRCommentRepost
//
//  Created by 柴淞 on 9/7/17.
//
//

#import "FRCommentRepost.h"
#import "TTBlockManager.h"
#import "Thread.h"
#import <TTAccountBusiness.h>
#import <DetailActionRequestManager.h>
#import "Article.h"
#import "TTRichSpanText.h"
#import "UGCRepostCommonModel.h"
#import "TTFollowManager.h"
#import "TTUGCDefine.h"

extern NSString *const kTTEditUserInfoDidFinishNotificationName;

@interface FRCommentRepost ()
@property (nullable, nonatomic, retain) NSString *commentRepostPrimaryID;

@property (nonatomic, retain) NSString *originItemID;

@property (nonatomic, strong, readwrite) Article *originGroup;
@property (nonatomic, strong, readwrite) Thread *originThread;
@property (nonatomic, strong, readwrite) UGCRepostCommonModel *originRepostCommonModel;

@property (nonatomic, strong) TTRichSpanText *richContent;

@property (nonatomic, retain) DetailActionRequestManager *actionRequestManager;

@property (nonatomic, strong) NSDictionary *userModelDict;
@property (nonatomic, strong) NSDictionary *shareDict; //share 用于详情页分享

@end

@implementation FRCommentRepost
@synthesize userModel = _userModel;
@synthesize actionDataModel = _actionDataModel;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"commentRepostPrimaryID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"commentRepostPrimaryID",
                       @"commentId",
                       @"content",
                       @"createTime",
                       @"userModelDict",
                       @"contentRichSpanJSONString",
                       @"schema",
                       @"shareDict",
                       @"groupId",
                       @"repostParamsDict",
                       @"filterWords",
                       @"commentType",
                       @"isRepost",
                       @"showTips",
                       @"originGroupID",
                       @"originThreadID",
                       @"originItemID",
                       @"originCommonContent",
                       @"contentDecoration"
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"commentId":@"id",
                                         @"content":@"content",
                                         @"createTime":@"create_time",
                                         @"userModelDict":@"user",
                                         @"contentRichSpanJSONString":@"content_rich_span",
                                         @"schema":@"detail_schema",
                                         @"shareDict":@"share",
                                         @"groupId":@"group_id",
                                         @"repostParamsDict":@"repost_params",
                                         @"filterWords": @"filter_words",
                                         @"commentType":@"comment_type",
                                         @"isRepost":@"is_repost",
                                         @"showTips":@"show_tips",
                                         @"originCommonContent":@"origin_common_content",
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
    NSMutableDictionary *mutableDict = [dataDict mutableCopy];
    [mutableDict removeObjectForKey:@"comment_base"];
    NSDictionary *commentBase = [dataDict tt_dictionaryValueForKey:@"comment_base"];
    
    [commentBase enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mutableDict setValue:obj forKey:key];
    }];
    
    dataDict = mutableDict.copy;
    [super updateWithDictionary:dataDict];
    
    self.actionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:self.commentId
                                                                          type:FRActionDataModelTypeComment];
    // forward_count; comment_count; read_count; digg_count; bury_count; user_digg; user_repin; user_bury; play_count;
    NSDictionary *actionDict = [dataDict tt_dictionaryValueForKey:@"action"];
//    if ([actionDict tt_objectForKey:@"forward_count"]) {
//        self.actionDataModel.repostCount = [actionDict tt_integerValueForKey:@"forward_count"];
//    }
//    if ([actionDict tt_objectForKey:@"comment_count"]) {
//        self.actionDataModel.commentCount = [actionDict tt_integerValueForKey:@"comment_count"];
//    }
    if ([actionDict tt_objectForKey:@"read_count"]) {
        self.actionDataModel.readCount = [actionDict tt_integerValueForKey:@"read_count"];
    }
    if ([actionDict tt_objectForKey:@"digg_count"]) {
        self.actionDataModel.diggCount = [actionDict tt_integerValueForKey:@"digg_count"];
    }
    if ([actionDict tt_objectForKey:@"user_digg"]) {
        self.actionDataModel.hasDigg = [actionDict tt_boolValueForKey:@"user_digg"];
    }
    if ([dataDict tt_objectForKey:@"show_origin"]) {
        self.showOrigin = [dataDict tt_boolValueForKey:@"show_origin"];
    }
    if ([dataDict tt_objectForKey:@"status"]) {
        //只有0是删除，其它一律可见
        self.actionDataModel.hasDelete = ![dataDict tt_boolValueForKey:@"status"];
    }
    
    if ([dataDict objectForKey:@"content_decoration"]) {
        NSData *jsonData = [[dataDict tt_stringValueForKey:@"content_decoration"] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        if (jsonData) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
            self.contentDecoration = [dic tt_stringValueForKey:@"url"];
        } else {
            self.contentDecoration = nil;
        }
    } else {
        self.contentDecoration = nil;
    }
    
    if (self.originCommonContent && !SSIsEmptyDictionary(self.originCommonContent)) {
        UGCRepostCommonModel *originRepostCommonModel = [[UGCRepostCommonModel alloc] initWithDictionary:self.originCommonContent error:nil];
        self.originRepostCommonModel = originRepostCommonModel;

        self.originGroupID = nil;
        self.originItemID = nil;
        self.originGroup = nil;
        self.originThreadID = nil;
        self.originThread = nil;
    } else if (self.commentType == FRCommentTypeCodeTHREAD) {
        NSMutableDictionary *originThreadDict = [[dataDict tt_objectForKey:@"origin_thread"] mutableCopy];
        if (originThreadDict) {
            NSString *originThreadID = [originThreadDict tt_stringValueForKey:@"thread_id"];
            if (!isEmptyString(originThreadID)) {
                Thread *originThread = [Thread updateWithDictionary:originThreadDict threadId:originThreadID parentPrimaryKey:self.commentRepostPrimaryID];
                self.originThread = originThread;
                self.originThreadID = @([originThread.threadId longLongValue]);
            }
        }
        self.originRepostCommonModel = nil;
        self.originGroupID = nil;
        self.originItemID = nil;
        self.originGroup = nil;
    } else if (self.commentType == FRCommentTypeCodeARTICLE) {
        NSMutableDictionary *originArticleDict = [[dataDict tt_objectForKey:@"origin_group"] mutableCopy];
        if (originArticleDict) {
            NSString *groupIDStr = [NSString stringWithFormat:@"%@", [originArticleDict tt_objectForKey:@"group_id"]];
            NSNumber *groupID = @([groupIDStr longLongValue]);
            NSString *itemID = [NSString stringWithFormat:@"%@", [originArticleDict tt_objectForKey:@"item_id"]];
            [originArticleDict setValue:groupID forKey:@"uniqueID"];
            NSString *primaryID = [Article primaryIDByUniqueID:[groupID longLongValue] itemID:itemID adID:nil];
            if (primaryID) {
                Article *originArticle = [Article updateWithDictionary:originArticleDict forPrimaryKey:primaryID];
                originArticle.itemID = itemID;
                self.originGroup = originArticle;
                self.originGroupID = @(originArticle.uniqueID);
                self.originItemID = itemID;
            }
        }
        

        self.originRepostCommonModel = nil;
        self.originThreadID = nil;
        self.originThread = nil;
    } else {
        self.originRepostCommonModel = nil;
        self.originGroupID = nil;
        self.originItemID = nil;
        self.originGroup = nil;
        self.originThreadID = nil;
        self.originThread = nil;
    }
}

- (void)save {
    if (_userModel) {
        _userModelDict = [_userModel toDictionary];
    }
    [super save];
    [self.originThread save];
    [self.originGroup save];
}

+ (FRCommentRepost *)updateWithDictionary:(NSDictionary *)dictionary commentId:(NSString *)commentID parentPrimaryKey:(NSString *)parentPrimaryKey {
    if (isEmptyString(parentPrimaryKey)) {
        parentPrimaryKey = @"unknow"; //详情页没有，feed一定要加
    }
    NSString *primaryKey = [NSString stringWithFormat:@"%@_%@", commentID, parentPrimaryKey];
    NSMutableDictionary *mutableDict = dictionary.mutableCopy;
    [mutableDict setValue:primaryKey forKey:@"commentRepostPrimaryID"];
    FRCommentRepost *commentRepost = [FRCommentRepost updateWithDictionary:mutableDict forPrimaryKey:primaryKey];
    return commentRepost;
}

+ (FRCommentRepost *)objectForCommentId:(NSString *)commentID parentPrimaryKey:(NSString *)parentPrimaryKey {
    if (isEmptyString(parentPrimaryKey)) {
        parentPrimaryKey = @"unknow"; //详情页没有，feed一定要加
    }
    NSString *primaryKey = [NSString stringWithFormat:@"%@_%@", commentID, parentPrimaryKey];
    return [FRCommentRepost objectForPrimaryKey:primaryKey];
}

- (void)setShowOrigin:(BOOL)showOrigin {
    self.actionDataModel.showOrigin = showOrigin;
}

- (BOOL)showOrigin {
    return self.actionDataModel.showOrigin;
}

- (void)setActionDataModel:(id<FRActionDataProtocol>)actionDataModel {}

- (id<FRActionDataProtocol>)actionDataModel {
    if (_actionDataModel == nil) {
        _actionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:self.commentId type:FRActionDataModelTypeComment];
    }
    return _actionDataModel;
}

- (void)setShareDict:(NSDictionary *)shareDict {
    _shareDict = shareDict;
    self.shareInfoModel = [[FRShareInfoStructModel alloc] initWithDictionary:_shareDict error:nil];
}

- (void)setUserModelDict:(NSDictionary *)userModelDict {
    _userModelDict = userModelDict;
    self.userModel = [[FRCommonUserStructModel alloc] initWithDictionary:_userModelDict error:nil];
}

+ (void)setCommentRepostDeletedWithID:(NSString *)CommentRepostID {
    if (isEmptyString(CommentRepostID)) {
        return;
    }
    NSArray <FRCommentRepost *> * commentReposts = [FRCommentRepost objectsWithQuery:@{@"commentId":CommentRepostID}];

    [commentReposts enumerateObjectsUsingBlock:^(FRCommentRepost * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.actionDataModel.hasDelete = YES;
        [obj save];
    }];
}

- (void)setContent:(NSString *)content
{
    if (![_content isEqualToString:content]) {
        _content = content;
        if (_richContent) {
            TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
            _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
        }
    }
}

- (void)setContentRichSpanJSONString:(NSString *)contentRichSpanJSONString
{
    if (![_contentRichSpanJSONString isEqualToString:contentRichSpanJSONString]) {
        _contentRichSpanJSONString = contentRichSpanJSONString;
        if (_richContent) {
            TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
            _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
        }
    }
}


- (TTRichSpanText *)getRichContent {
    if (_richContent == nil) {
        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
        _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
    }
    return _richContent;
}

- (Article *)originGroup {
    if (self.commentType == FRCommentTypeCodeARTICLE) {
        if (self.originGroupID && !_originGroup) {
            NSString *primaryID = [Article primaryIDByUniqueID:[self.originGroupID longLongValue]
                                                        itemID:self.originItemID
                                                          adID:nil];
            _originGroup = [Article objectForPrimaryKey:primaryID];
        }
    } else {
        _originGroup = nil;
        _originGroupID = nil;
        _originItemID = nil;
    }
    return _originGroup;
}

- (Thread *)originThread {
    if (self.commentType == FRCommentTypeCodeTHREAD) {
        if (self.originThreadID && !_originThread) {
            NSString *originThreadIDStr = [NSString stringWithFormat:@"%@",self.originThreadID];
            Thread *thread = [Thread objectForThreadId:originThreadIDStr parentPrimaryKey:self.commentRepostPrimaryID];
            if (thread == nil) {
                //如果主键查不到 随便copy一份用于展示
                NSDictionary *queryDict = @{@"threadId": originThreadIDStr};
                thread = [[Thread objectsWithQuery:queryDict] firstObject];
                if (thread) {
                    NSDictionary *dict = [thread toDictionary];
                    thread = [Thread updateWithDictionary:dict threadId:originThreadIDStr parentPrimaryKey:self.commentRepostPrimaryID];
                }
            }
            _originThread = thread;
        }
    } else {
        _originThread = nil;
        _originThreadID = nil;
    }
    return _originThread;
}

- (UGCRepostCommonModel *)originRepostCommonModel {
    if (!SSIsEmptyDictionary(self.originCommonContent) && !_originRepostCommonModel) {
        _originRepostCommonModel =  [[UGCRepostCommonModel alloc] initWithDictionary:self.originCommonContent error:nil];
    }

    return _originRepostCommonModel;
}

- (nullable NSArray<FRImageInfoModel *> *)getForwardedVideoU13CutImageModels
{
    Article *article = self.originGroup;
    TTImageInfosModel *thumbImage = nil;
    if (article && [article hasVideo].boolValue) {
        if ([article.ugcVideoCover isKindOfClass:[NSDictionary class]]) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:article.ugcVideoCover];
        } else if ([article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"].count > 0) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"]];
        } else if ([[article largeImageDict] count] > 0) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article largeImageDict]];
        } else if ([[article middleImageDict] count] > 0) {
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:[article middleImageDict]];
        } else if ([[article listGroupImgDicts] count] > 0 && [[article gallaryFlag] isEqual:@1]) {
            NSDictionary *imageInfo = [[article listGroupImgDicts] firstObject];
            thumbImage = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
        }
        FRImageInfoModel *frModel = [[FRImageInfoModel alloc] initWithTTImageInfosModel:thumbImage];
        
        return @[frModel];
    }
    return nil;
    
}

#pragma mark - Notification
- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserInfoDidFinish:) name:kTTEditUserInfoDidFinishNotificationName object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)followNotification:(NSNotification *)notify {
    NSString * userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    if (!isEmptyString(userID) && [self.userModel.info.user_id isEqualToString:userID]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        if (actionType == FriendActionTypeFollow) {
            self.userModel.relation.is_following = @(YES);
        }else if (actionType == FriendActionTypeUnfollow) {
            self.userModel.relation.is_following = @(NO);
        }
        [self save];
    }
}

- (void)blockNotification:(NSNotification *)notify {
    NSString * userID = notify.userInfo[kBlockedUnblockedUserIDKey];
    if (!isEmptyString(userID) && [self.userModel.info.user_id isEqualToString:userID]) {
        BOOL isBlocking = [notify.userInfo[kIsBlockingKey] boolValue];
        
        self.userModel.block.is_blocking = @(isBlocking);
        if (isBlocking) {
            self.userModel.relation.is_following = @(NO);
        }
        [self save];
    }
}

- (void)editUserInfoDidFinish:(NSNotification *)notification {
    NSString *selfUserId = self.userModel.info.user_id;
    if (!isEmptyString(selfUserId) && [[TTAccountManager userID] isEqualToString:selfUserId]) {
        NSString * screenName = self.userModel.info.name;
        if (![screenName isEqualToString:[TTAccountManager userName]]) {
            self.userModel.info.name = [TTAccountManager userName];
            [self save];
        }
        
        NSString * avatarUrl = self.userModel.info.avatar_url;
        if (![avatarUrl isEqualToString:[TTAccountManager avatarURLString]]) {
            self.userModel.info.avatar_url = [TTAccountManager avatarURLString];
            [self save];
        }
    }
}

- (DetailActionRequestManager *)actionRequestManager {
    if (!_actionRequestManager) {
        
        _actionRequestManager = [DetailActionRequestManager new];
        WeakSelf;
        [_actionRequestManager setContext:({
            StrongSelf;
            TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];

            if (self.originRepostCommonModel) {

                NSString *groupID = [self.repostParamsDict tt_stringValueForKey:@"fw_id"]; //优先读fw_id
                if (isEmptyString(groupID)) {
                    groupID = self.originRepostCommonModel.group_id;
                }
                context.groupModel = [[TTGroupModel alloc] initWithGroupID:groupID];
                context.itemCommentID = self.commentId;

            } else {
                switch (self.commentType) {
                    case FRCommentTypeCodeTHREAD:
                        context.groupModel = [[TTGroupModel alloc] initWithGroupID:self.originThread.threadId ];
                        context.itemCommentID = self.commentId;
                        break;
                    case FRCommentTypeCodeARTICLE:
                    {
                        NSString *groupID = [self.repostParamsDict tt_stringValueForKey:@"fw_id"]; //优先读fw_id
                        if (isEmptyString(groupID)) {
                            groupID = [@(self.originGroup.uniqueID) stringValue];
                        }
                        context.groupModel = [[TTGroupModel alloc] initWithGroupID:groupID
                                                                            itemID:groupID
                                                                      impressionID:nil
                                                                          aggrType:self.originGroup.aggrType.integerValue];
                        context.itemCommentID = self.commentId;
                    }
                        break;
                    default:
                        break;
                }
            }
            
            context;
        })];
    }
    return _actionRequestManager;
}

- (void)diggWithFinishBlock:(void (^)(NSError *))finishBlock {
    long likeCount = self.actionDataModel.diggCount;
    likeCount = likeCount + 1;
    self.actionDataModel.diggCount = likeCount;
    self.actionDataModel.hasDigg = YES;
    [self.actionRequestManager startItemActionByType:DetailActionCommentDigg];

    if (self.commentId.longLongValue > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFRCommentEntityDigNotification
                                                            object:nil
                                                          userInfo:@{kFRCommentIDKey : self.commentId}];
    }
}

- (void)cancelDiggWithFinishBlock:(void (^)(NSError *))finishBlock {
    long likeCount = self.actionDataModel.diggCount;
    likeCount = likeCount - 1;
    if (likeCount < 0) {
        likeCount = 0;
    }
    self.actionDataModel.diggCount = likeCount;
    self.actionDataModel.hasDigg = NO;
    [self.actionRequestManager startItemActionByType:DetailActionCommentUnDigg];

    if (self.commentId.longLongValue > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFRCommentEntityCancelDigNotification
                                                            object:nil
                                                          userInfo:@{kFRCommentIDKey : self.commentId}];
    }
}
@end
