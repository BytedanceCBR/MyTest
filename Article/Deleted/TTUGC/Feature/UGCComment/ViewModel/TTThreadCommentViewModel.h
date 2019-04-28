//
//  TTThreadCommentViewModel.h
//  Article
//
//  Created by chenjiesheng on 2017/1/18.
//
//

#import <Foundation/Foundation.h>
#import "SSImpressionModel.h"
#import "TTCommentViewModel.h"

@class TTThreadCommentEntity;
@class TTUGCCommentEntity;
@protocol TTThreadCommentViewModelDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface TTThreadCommentViewModel : NSObject
@property(nonatomic, weak) id<TTCommentDataSource> datasource;
@property(nonatomic, weak) id<TTThreadCommentViewModelDelegate> delegate;
/**
 *  评论状态
 */
@property(nonatomic, assign)BOOL isLoading;
@property(nonatomic, assign)BOOL isLoadingMore;
@property(nonatomic, assign)TTCommentLoadResult loadResult;
/**
 *  评论数据
 */
@property(nonatomic, assign)NSInteger commentTotalNum;
@property(nonatomic, assign)BOOL bannComment;   //禁言
@property(nonatomic, assign)BOOL banEmojiInput; //禁表情
@property(nonatomic, assign)BOOL goTopicDetail; //added 4.6:是否允许查看评论的动态详情页
@property(nonatomic, assign, readonly)BOOL detailNoComment; //详情页不显示评论
@property(nonatomic, assign) CGFloat containViewWidth;
@property(nonatomic, assign)BOOL hasFoldComment;
@property(nonatomic, assign) BOOL hasMoreStickComment;

// UGC
@property(nonatomic, assign) int64_t tid; //帖子ID
@property(nonatomic, assign) int64_t fid; //话题ID
@property(nonatomic, strong, nullable) TTThreadCommentEntity *defaultReplyCommentModel;

- (instancetype)initWithAuthorID:(NSString *)authorID; //原内容作者id

- (void)tt_startLoadCommentsForMode:(TTCommentLoadMode)loadMode withCompletionHandler:(TTLoadCommentsCompletionHandler)handler;
- (NSArray <id<TTCommentModelProtocol>> *)tt_curCommentModels;
- (NSArray *)tt_curCommentLayoutArray;
- (NSString *)tt_primaryID;
- (void)tt_addToTopWithCommentModel:(id <TTCommentModelProtocol>)commentModel;
- (void)tt_removeCommentInTableWithCommentID:(NSString *)commentID;
- (void)tt_removeCommentWithCommentID:(NSString *)commentID;

- (void)monitorWithTotalConsume:(uint64_t)totalConsume;

- (BOOL)isFooterCellWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)needShowFooterCell;
- (BOOL)isFooterPlainCellIndexPath:(NSIndexPath *)indexPath;

/**
 *  发表评论
 *
 *  @param comment      评论内容
 *  @param replyComment 被回复的评论
 *  @param callback     callback
 */
- (void)publishComment:(nonnull NSString *)comment
          replyComment:(nullable TTUGCCommentEntity *)replyComment
              callback:(nullable void(^)(TTUGCCommentEntity * _Nullable comment, NSError * _Nullable error, NSString * _Nullable tips))callback;

//数据状态
- (BOOL)tt_needLoadingUpdate;
- (BOOL)tt_needLoadingMore;
- (void)tt_refreshLayout:(void(^)())completion;
@end

/**
 *  统计
 */
@interface TTThreadCommentViewModel (TTCommentTrack)

- (void)tt_sendShowTrackForEmbeddedCell:(UITableViewCell *)cell
                            atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  impression
 */
@interface TTThreadCommentViewModel (TTCommentImpression)

- (void)tt_registerToImpressionManager:(id)object;
- (void)tt_unregisterFromImpressionManager:(id)object;
- (void)tt_enterCommentImpression;
- (void)tt_leaveCommentImpression;
- (void)tt_recordForComment:(id<TTCommentModelProtocol>)commentModel status:(SSImpressionStatus)status;

@end

@protocol TTThreadCommentViewModelDelegate <NSObject>

- (void)commentViewModel:(TTThreadCommentViewModel *)viewModel refreshCommentCount:(int)commentCount;

@end
NS_ASSUME_NONNULL_END
