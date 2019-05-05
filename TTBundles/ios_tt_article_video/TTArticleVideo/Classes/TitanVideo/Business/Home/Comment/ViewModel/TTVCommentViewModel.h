//
//  TTVCommentViewModel.h
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import <Foundation/Foundation.h>
//#import "TTTableViewModel.h"
#import "TTVideoCommentService.h"
#import "SSImpressionModel.h"
#import "TTVCommentDefine.h"

@class TTVCommentListItem, Article;
@protocol TTVCommentDataSource;
NS_ASSUME_NONNULL_BEGIN
@interface TTVCommentViewModel : NSObject

@property(nonatomic, weak) id<TTVCommentDataSource> datasource;

/**
 *  评论状态
 */
@property(nonatomic, assign)BOOL isLoading;
@property(nonatomic, assign)BOOL isLoadingMore;
@property(nonatomic, assign)TTVCommentLoadResult loadResult;
/**
 *  评论数据
 */
@property(nonatomic, assign)NSInteger commentTotalNum;
@property(nonatomic, assign)BOOL bannComment;   //禁言
@property(nonatomic, assign)BOOL banEmojiInput; //禁表情
@property(nonatomic, assign)BOOL goTopicDetail; //added 4.6:是否允许查看评论的动态详情页
@property(nonatomic, assign, readonly)BOOL detailNoComment; //详情页不显示评论
@property(nonatomic, assign) CGFloat containViewWidth;
@property(nonatomic, assign) BOOL hasFoldComment;

- (id<TTVArticleProtocol>)getArticle;

- (nullable NSArray <TTVCommentListItem *> *)curCommentItems;

- (TTVCommentListItem *)commentItemAtIndex:(NSUInteger)index;

- (TTVCommentListItem *)commentItemWithCommentID:(NSString *)commentID;

- (BOOL)removeCommentItem:(TTVCommentListItem *)item;

- (BOOL)removeCommentItemWithCommentID:(NSString *)CommentID;

- (void)addToTopWithCommentItem:(TTVCommentListItem *)item;

- (void)startLoadCommentsForMode:(TTVCommentLoadMode)loadMode
              completionHandler:(nullable TTVLoadCommentsCompletionHandler)handler;

- (TTVCommentListItem *) defaultReplyCommentItem;

- (void)clearDefaultReplyCommentItem;

//数据状态
- (BOOL)needLoadingUpdate;
- (BOOL)needLoadingMore;
- (void)refreshLayout:(void(^)())completion;

- (BOOL)isFooterCellWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)needShowFooterCell;
@end

#pragma mark - TTVCommentTrack
/**
 *  统计
 */
@interface TTVCommentViewModel (TTVCommentTrack)

- (void)sendCommentClickTrackWithTagIndex:(NSInteger)index;
- (void)sendShowTrackForEmbeddedCell:(UITableViewCell *)cell
                            atIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - TTVCommentImpression
/**
 *  impression
 */
@interface TTVCommentViewModel (TTVCommentImpression)

- (void)registerToImpressionManager:(id)object;
- (void)unregisterFromImpressionManager:(id)object;
- (void)enterCommentImpression;
- (void)leaveCommentImpression;
- (void)recordForComment:(TTVCommentListItem *)commentItem
                     status:(SSImpressionStatus)status;

@end
NS_ASSUME_NONNULL_END
