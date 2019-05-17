//
//  NewsTrendsManager.h
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMomentDefine.h"

//对外同步 动态的评论数 点赞数. 当页面willDisappear时发送.
extern NSString *const kArticleMomentSyncNotification;
extern NSString *const kArticleMomentModelUserInfoKey;
extern NSString *const kArticleMomentModelCommentCountKey;

extern NSString *const kArticleMomentGetUpdateNumberNotification;
extern NSString *const kArticleMomentUpdateNumberKey;
extern NSString *const kArticleMomentUserInfoChangeListKey;
extern NSString *const kArticleMomentUserInfoHasMoreKey;
extern NSString *const kArticleMomentUserTipDataKey;

extern NSString *const kArticleMomentUpdateUserKey;



@class ArticleMomentModel;

typedef void(^MomentFinishBlock)(NSArray *moments, NSDictionary* userInfo, NSError *error);

@interface ArticleMomentManager : NSObject

@property(nonatomic, assign, readonly, getter = isLoading)BOOL loading;
/**
 目前，只能一个manager用cache, 一旦设置不要变化
 */
@property(nonatomic, assign, getter = isCacheEnabled)BOOL cacheEnabled;


+ (instancetype)sharedManager;

/**
 当前在内存中的动态，如果没有从服务端拉取，即为cachedMoments
 */
- (NSArray*)moments;

- (BOOL)containMomentForID:(NSString *)mID;
- (ArticleMomentModel *)momentInListForID:(NSString *)mID;
/**
 *  根据ID返回列表中的动态
 *
 *  @param mID     动态ID
 *  @param contain 是否包含转发的item
 *
 *  @return 符合要求的moment
 */
- (NSArray *)momentsInManagerForID:(NSString *)mID containForwardOriginItem:(BOOL)contain;

/**
 清除所有动态，包括缓存
 */
- (void)removeAllMoments;
- (void)removeMoment:(ArticleMomentModel *)model;
- (void)removeMoments:(NSArray *)models;

/**
 *  删除动态cache数据
 */
+ (void)clearMomentCache;


/**
 * 对外同步 动态的评论数 点赞数

 @param model 需要同步到外部的动态
 */
+ (void)postSyncNotificationWithMoment:(ArticleMomentModel *)model commentCount:(NSNumber *)commentCount;

@end

////////////////////////////////////////////////////////////////////////

@interface ArticleMomentManager(ExploreMomentListManagerCategory)
/**
 *  在index 位置插入model
 *
 *  @param model 动态model
 *  @param index 需要插入的位置， 如果index大于列表长度， 则插入到列表尾部
 *  @return YES：插入成功， NO：插入失败， 或者列表已经存在这条
 */
- (BOOL)insertModel:(ArticleMomentModel *)model toIndex:(NSUInteger)index;

/**
 *  获取更多
 *
 *  @param listID 对于动态是USER ID， 对于讨论区是forum的ID
 *  @param type   来源类型
 *  @param count  请求数量
 *  @param block  回掉block
 */
- (void)startLoadMoreWithID:(NSString*)listID listType:(ArticleMomentSourceType)type count:(int)count finishBlock:(MomentFinishBlock)block;

/**
 *  请求列表
 *
 *  @param listID 对于动态是USER ID， 对于讨论区是forum的ID
 *  @param type   来源类型
 *  @param count  请求数量
 *  @param block  回掉block
 */
- (void)startRefreshWithID:(NSString*)listID talkID:(NSString *)talkID listType:(ArticleMomentSourceType)type count:(int)count finishBlock:(MomentFinishBlock)block;

@end

////////////////////////////////////////////////////////////////////////

@interface ArticleMomentManager(ExploreMomentBadgeManagerCategory)
/**
 开始周期性的获取更新数，获取成功发出notification
 */
+ (void)startPeriodicalGetUpdateNumber;
+ (void)stopPeriodicalGetUpdateNumber;
@end

////////////////////////////////////////////////////////////////////////

@interface ArticleMomentManager(ExploreMomentDetailManagerCategory)
/**
 获取详情, 若在moments列表中，则会更新相应内容
 */
- (void)startGetMomentDetailWithIDs:(NSArray*)momentIDs finishBlock:(MomentFinishBlock)block;

/**
 获取详情, 若在moments列表中，则会更新相应内容
 sourceType不同则传入的ID表示不同含义，ArticleMomentSourceTypeArticleDetail时传入commentID
 modifyTime没有时传0
 */
- (void)startGetMomentDetailWithID:(NSString*)ID sourceType:(ArticleMomentSourceType)sourceType modifyTime:(NSTimeInterval)modifyTime finishBlock:(void(^)(ArticleMomentModel *model, NSError *error))block;
@end

@interface ArticleMomentManager(ExploreCommentModelCategory)
- (void)tryCacheMomentModelWithCommentId:(NSNumber *)commentId;
- (ArticleMomentModel *)getMomentModelWithCommentId:(NSNumber *)commentId;
@end

