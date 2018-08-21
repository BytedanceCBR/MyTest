//
//  TTCommentViewControllerProtocol.h
//  Article
//
//  Created by 延晋 张 on 16/5/25.
//
//

#import <Foundation/Foundation.h>
#import <TTThemed/SSThemed.h>
#import "TTCommentDefines.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - TTCommentViewControllerDelegate

@protocol TTCommentViewControllerProtocol;
@protocol TTCommentModelProtocol;

@protocol TTCommentViewControllerDelegate <NSObject>

@optional

//评论列表在没有网络情况下，请求数据刷新自己
- (void)tt_commentViewControllerRefreshDataInNoNetWorkCondition;

// 已经获取到评论列表数据
- (void)tt_commentViewControllerDidFetchCommentsWithError:(nullable NSError *)error;

// 评论操作行为
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController digCommentWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController startWriteComment:(nullable id<TTCommentModelProtocol>)model;
- (BOOL)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController shouldPresentCommentDetailViewControllerWithCommentModel:(nullable id<TTCommentModelProtocol>)model indexPath:(NSIndexPath *)indexPath showKeyBoard:(BOOL)showKeyBoard;
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController tappedWithUserID:(nonnull NSString*)userID;
- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(nullable NSDictionary *)info;

// 评论列表UI行为
- (void)tt_commentViewControllerScrollViewDidScrollToTop;

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController scrollViewDidScroll:(nonnull UIScrollView *)scrollView;

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController scrollViewDidEndDecelerating:(nonnull UIScrollView *)scrollView;

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController scrollViewDidEndDragging:(nonnull UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView;

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController scrollViewDidEndScrollAnimation:(nonnull UIScrollView *)scrollView;

- (void)tt_commentViewControllerDidShow:(nonnull id<TTCommentViewControllerProtocol>)ttController;

//展示个人信息补全
- (void)tt_commentViewControllerDidShowProfileFill;

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController refreshCommentCount:(int)count;

- (void)tt_commentViewControllerFooterCellClicked:(nonnull id<TTCommentViewControllerProtocol>)ttController;

@end

#pragma mark - TTCommentViewControllerProtocol

@protocol TTCommentViewControllerProtocol <NSObject>

@property (nonatomic, weak, nullable) id <TTCommentViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL enableImpressionRecording; // 是否开启评论列表 Impression 统计
@property (nonatomic, assign) BOOL hasSelfShown;              // 标识评论VC是否出现在页面上
@property (nonatomic, strong, readonly) SSThemedTableView *commentTableView;
@property (nonatomic, strong) NSString *serviceID;            // 评论服务所属 serviceID, 评论接口使用

@required

- (nonnull instancetype)initWithViewFrame:(CGRect)frame
                               dataSource:(nullable id<TTCommentDataSource>)dataSource
                                 delegate:(nullable id<TTCommentViewControllerDelegate>)delegate;

/**
 * 发布评论后插入列表
 */
- (void)tt_insertCommentWithDict:(nonnull NSDictionary *)dict;

/**
 * 外部控制发送评论列表 show 统计
 * @param shown 当前评论列表是否被展示
 */
- (void)tt_sendShowStatusTrackForCommentShown:(BOOL)shown;

/**
 * 发送可见评论 cell 的 show 统计
 */
- (void)tt_sendShowTrackForVisibleCells;

/**
 * 评论列表作为 WebView 的 footer 时，处于 Half 状态下的相对位移
 */
- (void)tt_sendHalfStatusFooterImpressionsForViableCellsWithOffset:(CGFloat)rOffset;

@optional

/**
 * 发送评论回复
 * @param content 评论回复内容
 * @param replyCommentID 评论源 CommentID
 * @param replyUserID 评论源 UserID
 * @param finishBlock 回调方法
 */
- (void)tt_sendCommentWithContent:(nullable NSString *)content replyCommentID:(nullable NSString *)replyCommentID replyUserID:(nullable NSString *)replyUserID finishBlock:(void(^)(NSError *error))finishBlock;

/**
 * 刷新评论列表
 */
- (void)tt_reloadData;

/**
 * 获取默认回复的评论 Model，获取到是置顶评论 Model
 * @return 评论 Model
 */
- (nullable id<TTCommentModelProtocol>)tt_defaultReplyCommentModel;

/**
 * 清除默认回复的评论 Model
 */
- (void)tt_clearDefaultReplyCommentModel;

/**
 * 是否禁用表情输入
 */
- (BOOL)tt_banEmojiInput;

/**
 * 评论输入框 placeholder
 */
- (NSString *)tt_writeCommentViewPlaceholder;

/**
 * 标记需要对置顶 Cell 高亮动画
 */
- (void)tt_markStickyCellNeedsAnimation;

/**
 * 评论列表滚动到首条评论
 */
- (void)tt_commentTableViewScrollToTop;

/**
 * 更新约束宽度，重新 Layout
 * @param width 宽度
 */
- (void)tt_updateConstraintWidth:(CGFloat)width;

/**
 * 更新 Cell 的回复数
 * @param indexPath Cell 所在 indexPath
 * @param replyCount 外部回复数
 */
- (void)tt_updateCommentCellLayoutAtIndexPath:(NSIndexPath *)indexPath replyCount:(NSInteger)replyCount;

@end

NS_ASSUME_NONNULL_END
