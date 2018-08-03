//
//  Thread.h
//  Article
//
//  Created by 王霖 on 3/7/16.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"
#import "FRImageInfoModel.h"
#import "FRActionDataService.h"


@class Article, TTRichSpanText, TSVShortVideoOriginalData, UGCRepostCommonModel, TTFriendRelationEntity;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTRepostOperationItemType) {
    TTRepostOperationItemTypeNone = 0,
    TTRepostOperationItemTypeArticle = 1,
    TTRepostOperationItemTypeComment = 2,
    TTRepostOperationItemTypeReply = 3,
    TTRepostOperationItemTypeThread = 4,
    TTRepostOperationItemTypeShortVideo = 5,
    TTRepostOperationItemTypeWendaAnswer = 6,
};

typedef NS_ENUM(NSUInteger, TTThreadRepostType) {
    TTThreadRepostTypeNone = 0,                        // 当前帖子并非转发
    TTThreadRepostTypeArticle = 211,                   // 当前帖子实际转发的是一个文章
    TTThreadRepostTypeThread = 212,                    // 当前帖子实际转发的是一个帖子
    TTThreadRepostTypeShortVideo = 213,                // 当前帖子实际转发的是一个小视频
    TTThreadRepostTypeWendaAnswer = 214,               // 当前帖子实际转发的是一个问答（注：211和214的原内容都对应Thread中的originGroup）
    TTThreadRepostTypeLink = 215,                      // 内链转发
};

typedef NS_ENUM(NSUInteger, TTThreadRepostOriginType) {
    TTThreadRepostOriginTypeNone = 0,                  // 当前帖子并非转发
    TTThreadRepostOriginTypeArticle = 1,               // 当前帖子实际转发的是一个文章
    TTThreadRepostOriginTypeThread = 2,                // 当前帖子实际转发的是一个帖子
    TTThreadRepostOriginTypeShortVideo = 3,            // 当前帖子实际转发的是一个小视频
    TTThreadRepostOriginTypeCommon = 4,                // 当前帖子实际转发的是一个通用转发类型，可包含所有转发类型
};

#define kThreadOriginShortVideoDel @"kThreadOriginShortVideoDel"

@interface Thread : ExploreOriginalData

@property (nullable, nonatomic, retain) NSString *threadPrimaryID;
@property (nullable, nonatomic, retain) NSString *threadId;

@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *comments;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *contentRichSpanJSONString;
@property (nullable, nonatomic, retain) NSDictionary *forum;
@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *friendDiggList;
@property (nullable, nonatomic, retain) NSDictionary *groupDict;//group是sql的关键字，会导致sql语法错误，改成groupDict
@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *largeImageList;
@property (nullable, nonatomic, retain) NSDictionary *position;
@property (nullable, nonatomic, retain) NSString *schema;
@property (nullable, nonatomic, retain) NSString *contentDecoration;
@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *thumbImageList;
@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *ugcCutImageList; //和上面一样是缩略图，但为了显示效果比较好，后台进行了裁图，在单图时候的U12样式会使用这种优化裁图
@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *ugcU13CutImageList; //和上面一样是缩略图，但为了显示效果比较好，后台进行了裁图，在单图时候的U13样式会使用这种优化裁图
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSDictionary *user;
@property (nullable, nonatomic, retain) NSNumber *isFake;//YES:帖子是本地异步发帖构造fake thread
@property (nullable, nonatomic, retain) NSNumber *isPosting;//如果isFake是YES:isPosting为YES表示帖子正在发送，否则发送失败。不持久化

@property (nullable, nonatomic, retain) NSArray<NSDictionary *> *filterWords;
@property (nullable, nonatomic, retain) NSNumber *createTime;
@property (nullable, nonatomic, retain) NSString *score;
@property (nullable, nonatomic, retain) id<FRActionDataProtocol> actionDataModel;

@property (nullable, nonatomic, retain) NSNumber *repostType;//转发类型，数值为TTThreadRepostType

@property (nullable, nonatomic, retain, readonly) NSNumber *originGroupID; // 转发内容
@property (nullable, nonatomic, copy, readonly)   NSString *originItemID;
@property (nullable, nonatomic, retain, readonly) NSString *originThreadID;

@property (nullable, nonatomic, retain) TTFriendRelationEntity *relationEntity;
@property (nullable, nonatomic, retain, readonly) Article         *originGroup;
@property (nullable, nonatomic, retain, readonly) Thread          *originThread;
@property (nullable, nonatomic, retain, readonly) TSVShortVideoOriginalData        *originShortVideoOriginalData;
@property (nullable, nonatomic, retain, readonly) NSDictionary    *repostParameters;

@property (nullable, nonatomic, retain, readonly) UGCRepostCommonModel *originRepostCommonModel;
@property (nullable, nonatomic, retain, readonly) TTRichSpanText *richContent;

@property (nullable, nonatomic, retain) NSNumber *maxTextLine;
@property (nullable, nonatomic, retain) NSNumber *defaultTextLine;

//作为被转发的内容时候，是否需要展示(nil和1都表示展示）
@property (nonatomic, strong, nullable) NSNumber *showOrigin;

//作为被转发的内容不需要展示的时候，显示的文案
@property (nonatomic, strong, nullable) NSString *showTips;

@property (nullable, nonatomic, copy) NSString *h5Extra;

@property (nullable, nonatomic, copy) NSString *brandInfo;

- (nullable NSArray<FRImageInfoModel *> *)getThumbImageModels;
- (nullable NSArray<FRImageInfoModel *> *)getUGCU12CutImageModels;
- (nullable NSArray<FRImageInfoModel *> *)getUGCU13CutImageModels; // U13 和 U12 裁切规则不一样
- (nullable NSArray<FRImageInfoModel *> *)getLargeImageModels;
- (nullable NSArray<FRImageInfoModel *> *)getForwardedVideoU13CutImageModels;

- (TTThreadRepostOriginType)repostOriginType;

- (NSString *)userID;
- (NSString *)userDecoration;
- (NSString *)screenName;
- (NSString *)avatarURL;
- (NSString *)verifiedContent;
// 头条认证展现（全量加V）
- (NSString *)userAuthInfo;
- (BOOL)isFollowing;
- (BOOL)isFollowed;
- (BOOL)isBlocking;
- (NSString *)forumName;
- (NSUInteger)followersCount;

- (void)diggWithFinishBlock:(nullable void (^)(NSError * _Nullable))finishBlock;
- (void)cancelDiggWithFinishBlock:(nullable void (^)(NSError * _Nullable))finishBlock;

- (void)generateOriginRepostCommonWithDictionary:(NSDictionary *)commonDictionary;

+ (void)setThreadHasBeDeletedWithThreadID:(NSString *)threadID;

+ (Thread *)generateThreadWithModel:(FRThreadDataStructModel *)model;

+ (Thread *)updateWithDictionary:(NSDictionary *)dictionary
                        threadId:(NSString *)threadIdStr
                parentPrimaryKey:(nullable NSString *)parentPrimaryKey;

+ (Thread *)objectForThreadId:(NSString *)threadIdStr
             parentPrimaryKey:(nullable NSString *)parentPrimaryKey;

- (void)forceSetOriginThread:(Thread *)originThread;
- (void)forceSetOriginGroup:(Article *)originGroup;
- (void)forceSetOriginShortVideoOriginalData:(TSVShortVideoOriginalData *)originShortVideoOriginalData;

@end

NS_ASSUME_NONNULL_END

