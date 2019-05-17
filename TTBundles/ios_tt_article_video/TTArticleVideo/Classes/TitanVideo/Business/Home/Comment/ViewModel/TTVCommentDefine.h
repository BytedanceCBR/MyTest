//
//  TTVCommentDefine.h
//  Article
//
//  Created by lijun.thinker on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "TTVCommentListItem.h"
#import "TTVArticleProtocol.h"

#define TTVCommentDefaultLoadMoreFetchCount 20
#define TTVCommentDefaultLoadMoreOffsetCount 20

NS_ASSUME_NONNULL_BEGIN

/**
 *  评论列表加载结果
 */
typedef NS_ENUM(NSInteger, TTVCommentLoadResult) {
    TTVCommentLoadResultSuccess,
    TTVCommentLoadResultFailed
};

typedef NS_ENUM(NSInteger, TTVCommentCategory) {
    TTVCommentCategoryHot = 0,
    TTVCommentCategoryTimeLine
};

typedef NS_ENUM(NSInteger, TTVCommentLoadMode) {
    TTVCommentLoadModeRefresh,
    TTVCommentLoadModeLoadMore
};

typedef NS_OPTIONS(NSUInteger, TTVCommentLoadOptions) {
    
    TTVCommentLoadOptionsFold = 1 << 0,
    TTVCommentLoadOptionsStick = 1 << 1
};

/**
 *  更新列表后的UI操作，如loadMore之后停止动画
 */
typedef void (^TTVLoadCommentsCompletionHandler)(NSError* _Nullable error);

#pragma mark - TTVCommentDataSource
@protocol TTVCommentViewControllerProtocol;
@protocol TTVCommentDataSource <NSObject>

/**
 *  评论列表header，如浮层
 *
 */
- (SSThemedView *)commentHeaderView;

/**
 *  评论所属的article
 *
 */
- (id <TTVArticleProtocol>)serveArticle;

- (NSString *)msgId;

@end

#pragma mark - TTVCommentDelegate

/**
 *  评论组件需要传给业务方的事件
 */
@protocol TTVCommentDelegate <NSObject>

@optional

//评论列表在没有网络情况下，请求数据刷新自己
- (void)tt_commentViewControllerRefreshDataInNoNetWorkCondition;

// 已经获取到评论列表数据
- (void)commentViewControllerDidFetchCommentsWithError:(nullable NSError *)error;

// 评论操作行为
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(nonnull id<TTVCommentModelProtocol>)model;
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTVCommentModelProtocol>)model;
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(nonnull id<TTVCommentModelProtocol>)model position:(NSString *)position;
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(nonnull id<TTVCommentModelProtocol>)model;
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController startWriteComment:(nullable id<TTVCommentModelProtocol>)model;
- (BOOL)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController shouldPresentCommentDetailViewControllerWithCommentModel:(nullable id<TTVCommentModelProtocol>)model indexPath:(NSIndexPath *)indexPath showKeyBoard:(BOOL)showKeyBoard;
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController tappedWithUserID:(nonnull NSString*)userID;
// 评论列表UI行为
- (void)commentViewControllerScrollViewDidScrollToTop;
- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController
             scrollViewDidScroll:(nonnull UIScrollView *)scrollView;

- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController
    scrollViewDidEndDecelerating:(nonnull UIScrollView *)scrollView;

- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController
        scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate;

- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController
     scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView;

- (void)commentViewController:(nonnull id<TTVCommentViewControllerProtocol>)ttController
 scrollViewDidEndScrollAnimation:(nonnull UIScrollView *)scrollView;
- (void)commentViewControllerDidShowProfileFill;

@end

#pragma mark - TTVCommentViewControllerProtocol

@protocol TTVCommentViewControllerProtocol <NSObject>

@required

@property(nonatomic, weak, nullable) id<TTVCommentDelegate> delegate;
@property(nonatomic, assign) BOOL enableImpressionRecording;
@property(nonatomic, assign) BOOL hasSelfShown;

/**
 *  发布评论后插入列表
 */
- (void)insertCommentWithDict:(nonnull NSDictionary *)dict;

/**
 *  评论列表滚动到首条评论
 */
- (void)commentViewWillScrollToTopCommentCell;

/**
 *  评论列表滚动到首条评论，不考虑浮层
 *
 */
- (void)commentViewWillScrollToTopCommentCellSimple;

- (nonnull UITableView *)commentTableView;

/**
 *  外部控制发送评论列表show统计
 *
 *  @param shown 当前评论列表是否被展示
 */
- (void)sendShowStatusTrackForCommentShown:(BOOL)shown;

/**
 *  发送评论cell的show统计
 */
- (void)sendShowTrackForVisibleCells;

/**
 *  评论列表作为webView的footer时，处于Half状态下的相对位移
 */
- (void)sendHalfStatusFooterImpressionsForViableCellsWithOffset:(CGFloat)rOffset;

@optional

- (nonnull instancetype)initWithViewFrame:(CGRect)frame
                               dataSource:(nullable id<TTVCommentDataSource>)datasource
                                 delegate:(nullable id<TTVCommentDelegate>)delegate;

- (void)sendCommentWithContent:(nullable NSString *)content replyCommentID:(nullable NSString *)replyCommentID replyUserID:(nullable NSString *)replyUserID finishBlock:(void(^)(NSError *error))finishBlock;

/**
 刷新评论列表
 */
- (void)reloadData;

/**
 获取需要默认回复的评论model
 
 @return 评论model
 */
- (nullable TTVCommentListItem *)defaultReplyCommentModel;

/**
 清除默认回复model
 */
- (void)clearDefalutReplyCommentModel;

/**
 * 禁用表情输入
 */
- (BOOL)tt_banEmojiInput;

@end

#pragma mark - TTVCommentCellDelegate

@protocol TTVCommentCellDelegate <NSObject>

@optional

- (void)commentCell:(nonnull UITableViewCell *)view replyButtonClickedWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view avatarTappedWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view deleteCommentWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view digCommentWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view showMoreButtonClickedWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view replyListClickedWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view replyListAvatarClickedWithUserID:(nonnull NSString *)userID commentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view nameViewonClickedWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view quotedNameViewonClickedWithCommentItem:(nonnull TTVCommentListItem *)item;
- (void)commentCell:(nonnull UITableViewCell *)view contentUnfoldWithCommentItem:(nonnull TTVCommentListItem *)item;

- (void)commentCell:(nonnull UITableViewCell *)view tappedWithUserID:(nonnull NSString *)userID;

- (void)commentCell:(nonnull UITableViewCell *)view superUserNameTappedWithCommentItem:(nonnull TTVCommentListItem *)item withSchema:(nullable NSString *)schema;
@end

NS_ASSUME_NONNULL_END
