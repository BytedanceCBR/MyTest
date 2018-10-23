//
//  Thread.m
//  Article
//
//  Created by 王霖 on 3/7/16.
//
//

#import "Thread.h"
#import "NSDictionary+TTAdditions.h"
#import "NetworkUtilities.h"
#import "TTFollowManager.h"
#import "TTBlockManager.h"
#import <TTAccountBusiness.h>
#import "Article.h"
#import "TTRichSpanText.h"
#import "TTUGCDefine.h"
#import "UGCRepostCommonModel.h"
#import "TTKitchenHeader.h"
#import "TTFriendRelationService.h"
#import "TTUGCPodBridge.h"
#import <NSObject+FBKVOController.h>
#import "EXTKeyPathCoding.h"
#import "TTImageInfosModel.h"


extern NSString *const kTTEditUserInfoDidFinishNotificationName;

@interface Thread ()

@property (nullable, nonatomic, retain, readwrite) NSNumber *originGroupID;
@property (nullable, nonatomic, copy, readwrite)   NSString *originItemID;
@property (nullable, nonatomic, retain, readwrite) NSString *originThreadID;
@property (nullable, nonatomic, retain, readwrite) NSNumber *originShortVideoID;
@property (nullable, nonatomic, retain, readwrite) NSDictionary *originCommonContent;

@property (nullable, nonatomic, retain, readwrite) Article         *originGroup; //问答也用article
@property (nullable, nonatomic, retain, readwrite) Thread          *originThread;
@property (nullable, nonatomic, strong) ExploreOriginalData        *originShortVideo;
@property (nullable, nonatomic, retain, readwrite) UGCRepostCommonModel *originRepostCommonModel;

@property (atomic, assign) NSInteger updateToNotifyCount;

@end

@implementation Thread
@synthesize richContent = _richContent;
@synthesize originShortVideo = _originShortVideo;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"threadPrimaryID";
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    Thread *other = (Thread *)object;
    
    if (![self.threadPrimaryID isEqualToString: other.threadPrimaryID]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [self.threadPrimaryID hash];
//    return (NSUInteger)(self.uniqueID % NSUIntegerMax);
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        NSMutableArray *props = [NSMutableArray arrayWithArray:@[
                                                                 @"threadPrimaryID",
                                                                 @"comments",
                                                                 @"content",
                                                                 @"contentRichSpanJSONString",
                                                                 @"forum",
                                                                 @"friendDiggList",
                                                                 @"groupDict",
                                                                 @"largeImageList",
                                                                 @"position",
                                                                 @"schema",
                                                                 @"threadId",
                                                                 @"thumbImageList",
                                                                 @"ugcCutImageList",
                                                                 @"ugcU13CutImageList",
                                                                 @"title",
                                                                 @"user",
                                                                 @"isFake",
                                                                 @"filterWords",
                                                                 @"createTime",
                                                                 @"score",
                                                                 @"repostType",
                                                                 @"originGroupID",
                                                                 @"originThreadID",
                                                                 @"originShortVideoID",
                                                                 @"originCommonContent",
                                                                 @"originItemID",
                                                                 @"showTips",
                                                                 @"repostParameters",
                                                                 @"h5Extra",
                                                                 @"brandInfo",
                                                                 @"contentDecoration",
                                                                 @"maxTextLine",
                                                                 @"defaultTextLine",
                                                                 ]];
        
        NSMutableArray *superProps = [NSMutableArray arrayWithArray:[super persistentProperties]];
        [superProps removeObject:@"commentCount"];
        [superProps removeObject:@"diggCount"];
        [superProps removeObject:@"userDigg"];
        [superProps removeObject:@"hasRead"];
        
        properties = [props arrayByAddingObjectsFromArray:superProps];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"createTime":@"create_time",
                                         @"contentRichSpanJSONString":@"content_rich_span",
                                         @"filterWords":@"filter_words",
                                         @"friendDiggList":@"friend_digg_list",
                                         @"largeImageList":@"large_image_list",
                                         @"repostType":@"repost_type",
                                         @"shareURL":@"share_url",
                                         @"threadId":@"thread_id",
                                         @"thumbImageList":@"thumb_image_list",
                                         @"ugcCutImageList":@"ugc_cut_image_list",
                                         @"ugcU13CutImageList":@"ugc_u13_cut_image_list",
                                         @"showTips":@"show_tips",
                                         @"groupDict":@"group",
                                         @"originCommonContent":@"origin_common_content",
                                         @"repostParameters":@"repost_params",
                                         @"h5Extra":@"h5_extra",
                                         @"brandInfo":@"brand_info",
                                         @"maxTextLine":@"max_text_line",
                                         @"defaultTextLine":@"default_text_line",
                                         }];
        properties = [dict copy];
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserveNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeOriginThreadKVO];
    [self removeObserveNotification];
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    if (dataDict) {
        NSMutableDictionary * pretreatDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
        
        //merge user
        if ([pretreatDataDict objectForKey:@"user"]) {
            NSDictionary * user = [self mergeDictionary:[pretreatDataDict tt_dictionaryValueForKey:@"user"]
                                           toDictionary:self.user];
            [pretreatDataDict setValue:user forKey:@"user"];
            
            self.relationEntity = [GET_SERVICE(TTFriendRelationService) entityWithKnownDataUserID:[user tt_stringValueForKey:@"user_id"] certainFollowing:[user tt_boolValueForKey:@"is_following"]];
        }
        
        dataDict = pretreatDataDict.copy;
    }
    [super updateWithDictionary:dataDict];
    self.actionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:self.threadId
                                                                          type:FRActionDataModelTypeThread];
//    NSDictionary* remoteForwardInfo = [dataDict tt_dictionaryValueForKey:@"forward_info"];
//    if ([remoteForwardInfo objectForKey:@"forward_count"]) { //避免server未下发导致置0
//        self.actionDataModel.repostCount = [remoteForwardInfo tt_longValueForKey:@"forward_count"];
//    }
//    if ([dataDict objectForKey:@"comment_count"]) { //避免server未下发导致置0
//        self.actionDataModel.commentCount = [dataDict tt_longValueForKey:@"comment_count"];
//    }

    if ([dataDict objectForKey:@"digg_count"]) { //避免server未下发导致置0
        self.actionDataModel.diggCount = [dataDict tt_longValueForKey:@"digg_count"];
    }

    if ([dataDict objectForKey:@"user_digg"]) { //避免server未下发导致置0
        self.actionDataModel.hasDigg = [dataDict tt_boolValueForKey:@"user_digg"];
    }
    
    if ([dataDict objectForKey:@"read_count"]) { //避免server未下发导致置0
        self.actionDataModel.readCount = [dataDict tt_longValueForKey:@"read_count"];
    }
    
    if ([dataDict tt_objectForKey:@"status"]) {
        //只有0是删除，其它一律可见
        self.actionDataModel.hasDelete = ![dataDict tt_boolValueForKey:@"status"];
    }
    
    if ([dataDict objectForKey:@"content_decoration"]) { //避免server未下发导致置0
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
    
    self.actionDataModel.showOrigin = YES; //默认显示原内容
    if (self.repostOriginType != TTThreadRepostOriginTypeNone //当且仅当为转发帖时，读取showOrigin，否则该字段无意义
        || [dataDict objectForKey:@"show_origin"]) { //避免server未下发导致置0
        self.showOrigin = [dataDict objectForKey:@"show_origin"];
    }
    
    self.isPosting = @([dataDict tt_boolValueForKey:@"isPosting"]);
    
    if (self.repostType.integerValue != TTThreadRepostTypeNone) {
        if ([dataDict objectForKey:@"origin_thread"]) {
            NSMutableDictionary *originThreadDict = [[dataDict objectForKey:@"origin_thread"] mutableCopy];
            if (originThreadDict) {
                NSString *originThreadIdStr = [originThreadDict tt_stringValueForKey:@"thread_id"];
                if (originThreadIdStr) {
                    Thread *originThread = [Thread updateWithDictionary:originThreadDict threadId:originThreadIdStr parentPrimaryKey:self.threadPrimaryID];
                    [self removeOriginThreadKVO];
                    self.originThread = originThread;
                    [self addOriginThreadKVO];
                    self.originThreadID = originThread.threadId;
                }
                self.originGroupID = nil;
                self.originItemID = nil;
                self.originShortVideoID = nil;
                self.originCommonContent = nil;
                self.originGroup = nil;
                self.originShortVideo = nil;
                self.originRepostCommonModel = nil;
            }
        }
        else if (self.originCommonContent && !SSIsEmptyDictionary(self.originCommonContent)) {
            UGCRepostCommonModel *originRepostCommonModel = [[UGCRepostCommonModel alloc] initWithDictionary:self.originCommonContent error:nil];
            self.originRepostCommonModel = originRepostCommonModel;

            self.originThreadID = nil;
            self.originShortVideoID = nil;
            self.originGroupID = nil;
            self.originItemID = nil;
            [self removeOriginThreadKVO];
            self.originThread = nil;
            self.originShortVideo = nil;
            self.originGroup = nil;
        }
        else if ([dataDict objectForKey:@"origin_group"]){
            NSMutableDictionary *originArticleDict = [[dataDict objectForKey:@"origin_group"] mutableCopy];
            if (originArticleDict) {
                NSString *groupIDStr = [NSString stringWithFormat:@"%@", [originArticleDict objectForKey:@"group_id"]];
                NSNumber *groupID = @([groupIDStr longLongValue]);
                NSString *itemID = [NSString stringWithFormat:@"%@",[originArticleDict objectForKey:@"item_id"]];
                [originArticleDict setValue:groupID forKey:@"uniqueID"];
                NSString *primaryID = [Article primaryIDByUniqueID:[groupID longLongValue] itemID:itemID adID:nil];
                if (primaryID) {
                    Article *originArticle = [Article updateWithDictionary:originArticleDict forPrimaryKey:primaryID];
                    originArticle.itemID = itemID;
                    self.originGroup = originArticle;
                    self.originGroupID = @(originArticle.uniqueID);
                    self.originItemID = originArticle.itemID;
                }
                
                self.originThreadID = nil;
                self.originShortVideoID = nil;
                self.originCommonContent = nil;
                [self removeOriginThreadKVO];
                self.originThread = nil;
                self.originShortVideo = nil;
                self.originRepostCommonModel = nil;
            }
        }
        else if ([dataDict objectForKey:@"origin_ugc_video"]){
            NSMutableDictionary *originShortVideoDict = [[dataDict objectForKey:@"origin_ugc_video"] mutableCopy];
            if (originShortVideoDict) {
                NSString *uniqueID = [NSString stringWithFormat:@"%@",[originShortVideoDict objectForKey:@"id"]];
                [originShortVideoDict setValue:@([uniqueID longLongValue]) forKey:@"uniqueID"];
                
                NSNumber *primaryID = @([uniqueID longLongValue]);
                if (primaryID) {
                    NSDictionary *queryDict = @{@"uniqueID": primaryID};
                    
                    ExploreOriginalData *originShortVideo = [[[self shortVideoClass] objectsWithQuery:queryDict] firstObject];
                    
                    if (!originShortVideo) {
                        //如果原来库里没有这条小视频数据，则新建
                        originShortVideo = [[self shortVideoClass] objectWithDictionary:originShortVideoDict];
                    } else {
                        //单独更新thumbImageList，字段
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        NSArray<NSDictionary *> *thumbImageArray = [[originShortVideoDict tt_dictionaryValueForKey:@"raw_data"] tt_arrayValueForKey:@"thumb_image_list"];
                        if ([thumbImageArray isKindOfClass:[NSArray class]] && [thumbImageArray count]) {
                            if ([originShortVideo respondsToSelector:NSSelectorFromString(@"shortVideo")]) {
                                NSObject *originShortVideoModel = [originShortVideo performSelector:NSSelectorFromString(@"shortVideo")];
                                if ([originShortVideoModel respondsToSelector:NSSelectorFromString(@"setCoverImageModel:")]) {
                                    NSDictionary *firstDict = [thumbImageArray firstObject];
                                    if ([firstDict isKindOfClass:[NSDictionary class]] && [firstDict count] > 0) {
                                        TTImageInfosModel *infoModel= [[TTImageInfosModel alloc] initWithDictionary:firstDict];
                                        if (infoModel) {
                                            [originShortVideoModel performSelector:NSSelectorFromString(@"setCoverImageModel:") withObject:infoModel];
                                        }
                                    }
                                }
                            }
                        }
#pragma clang diagnostic pop
                    }

                    self.originShortVideoID = primaryID;
                    self.originShortVideo = originShortVideo;
                }
                self.originGroupID = nil;
                self.originItemID = nil;
                self.originCommonContent = nil;
                self.originGroup = nil;
                self.originThread = nil;
                self.originRepostCommonModel = nil;
            }
        }
    }
    else {
        self.originGroupID = nil;
        self.originItemID = nil;
        self.originGroup = nil;
        self.originThreadID = nil;
        [self removeOriginThreadKVO];
        self.originThread = nil;
        self.originCommonContent = nil;
    }
}

- (void)save {
    [super save];
    [self.originThread save];
    [self.originGroup save];
    [self.originShortVideo save];
}

- (void)setUser:(NSDictionary *)user {
    if (_user != user) {
        _user = user;
    }
    
    if (![[_user tt_stringValueForKey:@"user_id"] isEqualToString:self.relationEntity.userID]) {
        self.relationEntity = [GET_SERVICE(TTFriendRelationService) entityWithUnknownDataUserID:[_user tt_stringValueForKey:@"user_id"]];
    }
}

- (void)setCommentCount:(int)commentCount {
    self.actionDataModel.commentCount = commentCount;
}

- (void)setDiggCount:(int)diggCount {
    self.actionDataModel.diggCount = diggCount;
}

- (void)setUserDigg:(BOOL)userDigg {
    self.actionDataModel.hasDigg = userDigg;
}

- (void)setHasRead:(NSNumber *)hasRead {
    self.actionDataModel.hasRead = hasRead.boolValue;
}

- (long)commentCount {
    return self.actionDataModel.commentCount;
}

- (long)diggCount {
    return self.actionDataModel.diggCount;
}

- (BOOL)userDigg {
    return self.actionDataModel.hasDigg;
}

- (NSNumber *)hasRead {
    return @(self.actionDataModel.hasRead);
}

- (void)forceSetOriginThread:(Thread *)originThread
{
    self.originThreadID = originThread.threadId;
    [self removeOriginThreadKVO];
    self.originThread = originThread;
    [self addOriginThreadKVO];
}
- (void)forceSetOriginGroup:(Article *)originGroup
{
    self.originGroup = originGroup;
    self.originGroupID = @(originGroup.uniqueID);
    self.originItemID = originGroup.itemID;
}

- (void)forceSetOriginShortVideoOriginalData:(TSVShortVideoOriginalData *)originShortVideoOriginalData
{
    self.originShortVideo = originShortVideoOriginalData;
    self.originShortVideoID = @(self.originShortVideo.uniqueID);
}

- (void)setShowOrigin:(NSNumber *)showOrigin {
    if (showOrigin) {
        self.actionDataModel.showOrigin = [showOrigin boolValue];
    }
}

- (NSNumber *)showOrigin {
    if (self.repostOriginType != TTThreadRepostOriginTypeNone) { //当且仅当为转发帖时，读取showOrigin，否则该字段无意义
        return @(self.actionDataModel.showOrigin);
    }
    return nil;
}

- (TTThreadRepostOriginType)repostOriginType{
    TTThreadRepostOriginType repostOriginType = TTThreadRepostOriginTypeNone;
    
    if (self.originGroup || (self.originGroupID && self.originGroupID.longLongValue > 0)) {
        repostOriginType = TTThreadRepostOriginTypeArticle;
    }
    else if (self.originThread || !isEmptyString(self.originThreadID)  ){
        repostOriginType = TTThreadRepostOriginTypeThread;
    }
    else if (self.originShortVideo || (self.originShortVideoID && self.originShortVideoID.longLongValue > 0)){
        repostOriginType = TTThreadRepostOriginTypeShortVideo;
    }
    else if (self.originRepostCommonModel || !SSIsEmptyDictionary(self.originCommonContent)){
        repostOriginType = TTThreadRepostOriginTypeCommon;
    }
    
    return repostOriginType;
}

- (NSString *)userID{
    return [self.user tt_stringValueForKey:@"user_id"];
}

- (NSString *)screenName{
    return [self.user tt_stringValueForKey:@"screen_name"];
}

- (NSString *)avatarURL {
    return [self.user tt_stringValueForKey:@"avatar_url"];
}

- (NSString *)verifiedContent{
    return [self.user tt_stringValueForKey:@"verified_content"];
}

- (NSString *)userAuthInfo{
    return [self.user tt_stringValueForKey:@"user_auth_info"];
}

- (NSString *)userDecoration {
    return [self.user tt_stringValueForKey:@"user_decoration"];
}

- (BOOL)isFollowing{
    return self.relationEntity.isFollowing;
}

- (BOOL)isFollowed{
    return [self.user tt_boolValueForKey:@"is_followed"];
}

- (BOOL)isBlocking {
    return [self.user tt_boolValueForKey:@"is_blocking"];
}

- (NSString *)forumName {
    return [self.forum tt_stringValueForKey:@"forum_name"];
}

- (NSUInteger)followersCount {
    return [self.user tt_unsignedIntegerValueForKey:@"followers_count"];
}

- (nullable NSArray<FRImageInfoModel *> *)getThumbImageModels {
    if ([self.thumbImageList isKindOfClass:[NSArray class]]) {
        NSMutableArray<FRImageInfoModel *> *thumbImageModels = [NSMutableArray array];
        [self.thumbImageList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                FRImageInfoModel *model = [[FRImageInfoModel alloc] initWithDictionary:obj];
                if (model) {
                    [thumbImageModels addObject:model];
                }
            }
        }];
        if (thumbImageModels.count > 0) {
            return thumbImageModels;
        }
    }
    return nil;
}

- (NSArray<FRImageInfoModel *> *)getUGCU12CutImageModels {
    if ([self.ugcCutImageList isKindOfClass:[NSArray class]]) {
        NSMutableArray<FRImageInfoModel *> *cutImageModels = [NSMutableArray array];
        [self.ugcCutImageList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                FRImageInfoModel *model = [[FRImageInfoModel alloc] initWithDictionary:obj];
                if (model) {
                    [cutImageModels addObject:model];
                }
            }
        }];
        if (cutImageModels.count > 0) {
            return cutImageModels;
        }
    }
    return nil;
}

- (NSArray<FRImageInfoModel *> *)getUGCU13CutImageModels {
    if ([self.ugcU13CutImageList isKindOfClass:[NSArray class]]) {
        NSMutableArray<FRImageInfoModel *> *cutImageModels = [NSMutableArray array];
        [self.ugcU13CutImageList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                FRImageInfoModel *model = [[FRImageInfoModel alloc] initWithDictionary:obj];
                if (model) {
                    [cutImageModels addObject:model];
                }
            }
        }];
        if (cutImageModels.count > 0) {
            return cutImageModels;
        }
    }
    return nil;
}

- (nullable NSArray<FRImageInfoModel *> *)getLargeImageModels {
    if ([self.largeImageList isKindOfClass:[NSArray class]]) {
        NSMutableArray<FRImageInfoModel *> *thumbImageModels = [NSMutableArray array];
        [self.largeImageList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                FRImageInfoModel *model = [[FRImageInfoModel alloc] initWithDictionary:obj];
                if (model) {
                    [thumbImageModels addObject:model];
                }
            }
        }];
        if (thumbImageModels.count > 0) {
            return thumbImageModels;
        }
    }
    return nil;
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

- (void)setContent:(NSString *)content {
    if (![_content isEqualToString:content]) {
        _content = content;
        if (_richContent) {
            TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
            _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
        }
    }
}

- (void)setContentRichSpanJSONString:(NSString *)contentRichSpanJSONString {
    if (![_contentRichSpanJSONString isEqualToString:contentRichSpanJSONString]) {
        _contentRichSpanJSONString = contentRichSpanJSONString;
        if (_richContent) {
            TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
            _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
        }
    }
}

- (TTRichSpanText *)richContent {
    if (!_richContent) {
        TTRichSpans *richSpans = [TTRichSpans richSpansForJSONString:self.contentRichSpanJSONString];
        _richContent = [[TTRichSpanText alloc] initWithText:self.content richSpans:richSpans];
    }
    return _richContent;
}

- (Article *)originGroup {
    if ([self.repostType integerValue] == TTThreadRepostTypeArticle) {
        if (self.originGroupID && !_originGroup) {
            NSString *primaryID = [Article primaryIDByUniqueID:[self.originGroupID longLongValue]
                                                        itemID:self.originItemID
                                                          adID:nil];
            _originGroup = [Article objectForPrimaryKey:primaryID];
        }
    }
    else {
        _originGroup = nil;
        _originGroupID = nil;
        _originItemID = nil;
    }
    return _originGroup;
}

- (Thread *)originThread {
    if ([self.repostType integerValue] == TTThreadRepostTypeThread) {
        if (!isEmptyString(self.originThreadID) && !_originThread) {
            [self removeOriginThreadKVO];
            Thread *thread = [Thread objectForThreadId:self.originThreadID parentPrimaryKey:self.threadPrimaryID];
            if (thread == nil) {
                //如果主键查不到 随便copy一份用于展示
                NSDictionary *queryDict = @{@"threadId": self.originThreadID};
                thread = [[Thread objectsWithQuery:queryDict] firstObject];
                if (thread) {
                    NSDictionary *dict = [thread toDictionary];
                    thread = [Thread updateWithDictionary:dict threadId:self.originThreadID parentPrimaryKey:self.threadPrimaryID];
                }
            }
            _originThread = thread;
            [self addOriginThreadKVO];
        }
    }
    else {
        [self removeOriginThreadKVO];
        _originThread = nil;
        _originThreadID = nil;
    }
    return _originThread;
}

#pragma  -- mark 四个方法trick解依赖ShortVideo
- (ExploreOriginalData *)originShortVideo{
    if ([self.repostType integerValue] == TTThreadRepostTypeShortVideo) {
        if (self.originShortVideoID && !_originShortVideo) {
            NSDictionary *queryDict = @{@"uniqueID": @([self.originShortVideoID longLongValue])};
            _originShortVideo = [[[self shortVideoClass] objectsWithQuery:queryDict] firstObject];
        }
    }
    else{
        _originShortVideoID = nil;
        _originShortVideo = nil;
    }
    return _originShortVideo;
}

- (TTFriendRelationEntity *)relationEntity {
    if (!_relationEntity) {
        _relationEntity = [GET_SERVICE(TTFriendRelationService) entityWithUnknownDataUserID:[_user tt_stringValueForKey:@"user_id"]];
    }
    return _relationEntity;
}

- (void)setOriginShortVideo:(ExploreOriginalData *)originShortVideo {
    [self willChangeValueForKey:@keypath(self, originShortVideoOriginalData)];
    _originShortVideo = originShortVideo;
    if (!originShortVideo) {
        _originShortVideoID = nil;
    }
    [self didChangeValueForKey:@keypath(self, originShortVideoOriginalData)];
}

- (TSVShortVideoOriginalData *)originShortVideoOriginalData {
    return (TSVShortVideoOriginalData *)self.originShortVideo;
}

- (Class)shortVideoClass {
    return [[TTUGCPodBridge sharedInstance] threadOriginShortVideoType];
}

- (UGCRepostCommonModel *)originRepostCommonModel {
    if (!SSIsEmptyDictionary(self.originCommonContent) && !_originRepostCommonModel) {
         _originRepostCommonModel =  [[UGCRepostCommonModel alloc] initWithDictionary:self.originCommonContent error:nil];
    }
    
    return _originRepostCommonModel;
}

- (id<FRActionDataProtocol>)actionDataModel {
    if (_actionDataModel == nil) {
        _actionDataModel = [GET_SERVICE(FRActionDataService) modelWithUniqueID:self.threadId
                                                                          type:FRActionDataModelTypeThread];
    }
    return _actionDataModel;
}
#pragma mark - KVO
- (void)addOriginThreadKVO {
    if (!_originThread) {
        return;
    }
    WeakSelf;
    [self.KVOController observe:_originThread
                        keyPath:@keypath(self, actionDataModel.hasDelete)
                        options:NSKeyValueObservingOptionNew
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kExploreOriginalDataUpdateNotification
                                                                                      object:nil
                                                                                    userInfo:@{@"uniqueID":@(wself.uniqueID).stringValue}];
                              });

    }];
}

- (void)removeOriginThreadKVO {
    if (!_originThread) {
        return;
    }
    [self.KVOController unobserve:_originThread keyPath:@keypath(self, actionDataModel.hasDelete)];
}

#pragma mark - Notification

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentDeleteNotification:) name:@"kDeleteCommentNotificationKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockedUnblockedUserNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserInfoDidFinish:) name:kTTEditUserInfoDidFinishNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteShortVideoNotification:) name:@"kTSVShortVideoDeleteNotification" object:nil];
    // 下面这个没有人用到，要不要删了？
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteShortVideoNotification:) name:kThreadOriginShortVideoDel object:nil];
    
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commentDeleteNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if (![userInfo[@"thread_id"] isEqualToString:self.threadId]) {
        return;
    }
    
    //评论删除
    if ([userInfo[@"id"] isKindOfClass:[NSString class]]) {
        NSMutableArray <NSDictionary *> * comments = [NSMutableArray arrayWithArray:self.comments];
        [comments enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!SSIsEmptyDictionary(obj) && [obj[@"comment_id"] isKindOfClass:[NSNumber class]] && [obj[@"comment_id"] longLongValue] == [userInfo[@"id"] longLongValue]) {
                [comments removeObject:obj];
                *stop = YES;
            }
        }];
        if (comments.count == 0) {
            self.comments = nil;
        }else {
            self.comments = [NSArray arrayWithArray:comments];
        }
    }
    [self save];
}

- (void) deleteShortVideoNotification:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    int64_t groupID = [dic tt_longlongValueForKey:@"kTSVShortVideoDeleteUserInfoKeyGroupID"];
    if (groupID != 0 && groupID == self.originShortVideoID.longLongValue) { //小视频删除
        self.showOrigin = @(NO);
        [self save];
    }
    //下面这个逻辑有用吗？没有找到场景
    int64_t threadID = [dic tt_longlongValueForKey:@"thread_id"];
    if (threadID != 0 && threadID == self.threadId.longLongValue) { //小视频删除
        self.showOrigin = @(NO);
        [self save];
    }
}

- (void)followNotification:(NSNotification *)notification {
    NSString * userID = notification.userInfo[kRelationActionSuccessNotificationUserIDKey];
    if ([userID isEqualToString:[self.user tt_stringValueForKey:@"user_id"]] && self.user) {
        NSInteger actionType = [(NSNumber *)notification.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        NSMutableDictionary * user = nil;
        if (self.user) {
            user = [NSMutableDictionary dictionaryWithDictionary:self.user];
        }else {
            user = [NSMutableDictionary dictionary];
        }
        if (actionType == FriendActionTypeFollow) {
            [user setValue:@(YES) forKey:@"is_following"];
            self.relationEntity.isFollowing = YES;
        }else if (actionType == FriendActionTypeUnfollow) {
            [user setValue:@(NO) forKey:@"is_following"];
            self.relationEntity.isFollowing = NO;
        }
        self.user = user.copy;
        [self save];
    }
}

- (void)blockedUnblockedUserNotification:(NSNotification *)notification {
    NSString * userID = notification.userInfo[kBlockedUnblockedUserIDKey];
    if ([userID isEqualToString:[self.user tt_stringValueForKey:@"user_id"]] && self.user) {
        BOOL isBlocking = [notification.userInfo tt_boolValueForKey:kIsBlockingKey];
        NSMutableDictionary * user = nil;
        if (self.user) {
            user = [NSMutableDictionary dictionaryWithDictionary:self.user];
        }else {
            user = [NSMutableDictionary dictionary];
        }
        [user setValue:@(isBlocking) forKey:@"is_blocking"];
        if (isBlocking) {
            [user setValue:@(NO) forKey:@"is_following"];
            self.relationEntity.isFollowing = NO;
        }
        self.user = user.copy;
        [self save];
    }
}

- (void)editUserInfoDidFinish:(NSNotification *)notification {
    if ([self.userID isEqualToString:[TTAccountManager userID]]) {
        NSString * screenName = [self.user tt_stringValueForKey:@"screen_name"];
        if (![screenName isEqualToString:[TTAccountManager userName]]) {
            NSMutableDictionary * user = nil;
            if (self.user) {
                user = [NSMutableDictionary dictionaryWithDictionary:self.user];
            }else {
                user = [NSMutableDictionary dictionary];
            }
            [user setValue:[TTAccountManager userName] forKey:@"screen_name"];
            self.user = user.copy;
            [self save];
        }
        
        NSString * avatarUrl = [self.user tt_stringValueForKey:@"avatar_url"];
        if (![avatarUrl isEqualToString:[TTAccountManager avatarURLString]]) {
            NSMutableDictionary * user = nil;
            if (self.user) {
                user = [NSMutableDictionary dictionaryWithDictionary:self.user];
            }else {
                user = [NSMutableDictionary dictionary];
            }
            [user setValue:[TTAccountManager avatarURLString] forKey:@"avatar_url"];
            self.user = user.copy;
            [self save];
        }
    }
}

- (void)diggWithFinishBlock:(void (^)(NSError *))finishBlock {
    //digg query
    if (TTNetworkConnected()) {
        FRTtdiscussV1CommitThreaddiggRequestModel * model = [[FRTtdiscussV1CommitThreaddiggRequestModel alloc] init];
        model.thread_id = self.threadId;
        
        [[TTNetworkManager shareInstance] requestModel:model callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            if (finishBlock) {
                finishBlock(error);
            }
        }];
    }else {
        NSError *error = [NSError errorWithDomain:kTTNetworkErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil];
        if (finishBlock) {
            finishBlock(error);
        }
    }
    
    //modify model
    if (self.userDigg) {
        return;
    }
    
    self.userDigg = YES;
    self.diggCount =  self.diggCount + 1;
    
    [self save];
    
    if (self.threadId.longLongValue > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFRThreadEntityDigNotification
                                                            object:nil
                                                          userInfo:@{kFRThreadIDKey : self.threadId}];
    }
}

- (void)cancelDiggWithFinishBlock:(void (^)(NSError *))finishBlock {
    if (TTNetworkConnected()) {
        FRTtdiscussV1CommitCancelthreaddiggRequestModel * model = [[FRTtdiscussV1CommitCancelthreaddiggRequestModel alloc] init];
        model.thread_id = self.threadId;
        
        [[TTNetworkManager shareInstance] requestModel:model callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            if (finishBlock) {
                finishBlock(error);
            }
        }];
    } else {
        NSError *error = [NSError errorWithDomain:kTTNetworkErrorDomain code:TTNetworkErrorCodeNoNetwork userInfo:nil];
        if (finishBlock) {
            finishBlock(error);
        }
    }
    
    //modify model
    if (!self.userDigg) {
        return;
    }
    
    self.userDigg = NO;
    self.diggCount = self.diggCount - 1 < 0?0:self.diggCount - 1;
    
    [self save];
    
    if (self.threadId.longLongValue > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFRThreadEntityCancelDigNotification
                                                            object:nil
                                                          userInfo:@{kFRThreadIDKey : self.threadId}];
    }
}

+ (void)setThreadHasBeDeletedWithThreadID:(NSString *)threadID {
    if (isEmptyString(threadID)) {
        return;
    }
    //改为用threadId查找
    NSArray <Thread *> * threads = [Thread objectsWithQuery:@{@"threadId":threadID}];
    [threads enumerateObjectsUsingBlock:^(Thread * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.actionDataModel.hasDelete = YES;
        [obj save];
    }];
}

+ (Thread *)generateThreadWithModel:(FRThreadDataStructModel *)model {
    NSDictionary * modelDic = [model toDictionary];
    if (0 == modelDic.count) {
        return nil;
    }
    NSString * threadID = nil;
    if ([[modelDic objectForKey:@"thread_id"] isKindOfClass:[NSString class]]) {
        threadID = [modelDic objectForKey:@"thread_id"];
    }else if ([[modelDic objectForKey:@"thread_id"] isKindOfClass:[NSNumber class]]) {
        threadID = ((NSNumber *)[modelDic objectForKey:@"thread_id"]).stringValue;
    }
    
    if (isEmptyString(threadID)) {
        return nil;
    }
    
    
    NSArray <NSString *> * keys;
    keys = [NSArray arrayWithObjects:
            @"thread_id",
            @"cursor",
            @"reason",
            @"digg_count",
            @"friend_digg_list",
            @"content",
            @"create_time",
            @"share_url",
            @"large_image_list",
            @"thumb_image_list",
            @"group",
            @"user",
            @"user_digg",
            @"position",
            @"status",
            @"title",
            @"score",
            @"repost_params",
            @"read_count",
            @"show_origin",
            @"show_tips",
            nil];
    
    NSMutableDictionary * insertDic = @{}.mutableCopy;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [insertDic setValue:[modelDic valueForKey:obj]
                     forKey:obj];
    }];
    //帖子话题字段的key不一致，特殊处理
    [insertDic setValue:[modelDic valueForKey:@"talk_item"]
                 forKey:@"forum"];
    
    return [Thread updateWithDictionary:insertDic threadId:threadID parentPrimaryKey:nil];
}

+ (Thread *)updateWithDictionary:(NSDictionary *)dictionary
                        threadId:(NSString *)threadIdStr
                parentPrimaryKey:(NSString *)parentPrimaryKey {
    if (isEmptyString(parentPrimaryKey)) {
        parentPrimaryKey = @"unknow"; //详情页没有，feed和转发的originThread一定要加
    }
    NSString *primaryKey = [NSString stringWithFormat:@"%@_%@", threadIdStr, parentPrimaryKey];
    NSMutableDictionary *mutableDict = dictionary.mutableCopy;
    [mutableDict setValue:primaryKey forKey:@"threadPrimaryID"];
    Thread *thread = [Thread updateWithDictionary:mutableDict forPrimaryKey:primaryKey];
    return thread;
}

+ (Thread *)objectForThreadId:(NSString *)threadIdStr
             parentPrimaryKey:(NSString *)parentPrimaryKey {
    if (isEmptyString(parentPrimaryKey)) {
        parentPrimaryKey = @"unknow"; //详情页没有，feed和转发的originThread一定要加
    }
    NSString *primaryKey = [NSString stringWithFormat:@"%@_%@", threadIdStr, parentPrimaryKey];
    return [Thread objectForPrimaryKey:primaryKey];
}

- (void) generateOriginRepostCommonWithDictionary:(NSDictionary *)commonDictionary{
    NSDictionary * modelDic = [commonDictionary copy];
    if (!SSIsEmptyDictionary(modelDic)) {
        self.originCommonContent = modelDic;
        self.originRepostCommonModel =  [[UGCRepostCommonModel alloc] initWithDictionary:self.originCommonContent error:nil];
    }
}

#pragma mark - Utils

- (NSDictionary *)mergeDictionary:(NSDictionary *)dictionary
                     toDictionary:(NSDictionary *)toDictionary {
    if (0 == dictionary.count) {
        return toDictionary;
    }
    NSMutableDictionary * resultDictionary = [NSMutableDictionary dictionary];
    if (toDictionary.count > 0) {
        [resultDictionary addEntriesFromDictionary:toDictionary];
    }
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [resultDictionary setValue:obj forKey:key];
    }];
    return resultDictionary.copy;
}

@end
