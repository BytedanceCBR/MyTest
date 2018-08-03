//
//  ExploreCommentView.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-21.
//
//

#import <Foundation/Foundation.h>
#import "SSViewBase.h"
#import "SSCommentManager.h"
#import "SSCommentModel.h"
#import "SSImpressionProtocol.h"
#import "TTGroupModel.h"

#define kPadFlipCommentRightFlipViewRemainKey @"kPadFlipCommentRightFlipViewRemainKey"


@protocol ExploreCommentViewDelegate;

@interface ExploreCommentView : SSViewBase<SSImpressionProtocol>

@property (nonatomic, strong) SSCommentManager *commentManager;
@property (nonatomic, weak) id <ExploreCommentViewDelegate> delegate;
@property (nonatomic, strong, readonly) UITableView *commentTableView;
@property (nonatomic, assign) BOOL enableInputedScrollToComment;  //默认关闭， 开启后，发表完评论，会自动混动到最新评论
@property (nonatomic, assign) BOOL banEmojiInput; // 禁用表情输入
@property (nonatomic, assign) BOOL isShowRepostEntrance;

/*
 *  浮层是否处于display状态
 */
@property(nonatomic, assign)BOOL hasSelfShown;

- (id)initWithFrame:(CGRect)frame enableImpressionRecording:(BOOL)enable;
- (id)initWithFrame:(CGRect)frame commentManager:(SSCommentManager *)manager;
- (id)initWithFrame:(CGRect)frame commentManager:(SSCommentManager *)manager fromEssay:(BOOL)isEssay;

- (void)openReplyInputViewWithGroupModel:(TTGroupModel *)groupModel
                         commentModel:(SSCommentModel *)model
                          bannComment:(BOOL)bann
                              itemTag:(NSString *)tag;

- (void)openInputViewWithContent:(NSString *)content
                      inputTitle:(NSString *)title
                         groupModel:(TTGroupModel *)groupModel
                       commentID:(NSString *)cID
                         itemTag:(NSString *)iTag
                 itemBannComment:(BOOL)bann;

/*
 *  添加顶部的view
 */
- (void)addHeaderView:(UIView *)headerView;

- (void)setScrollToTopEnable:(BOOL)enable;

- (void)reloadData;
//强制显示因为detail_no_comments参数隐藏的评论，并且reload列表
- (void)tryForceShowAndReload;

- (void)scrollToTopCommentAnimated:(BOOL)animated;
- (void)scrollToTopHeaderAnimated:(BOOL)animated;
- (void)scrollToRecentCommentAnimated:(BOOL)animated;
- (void)scrollToOriginY:(CGFloat)originY animated:(BOOL)animated;

//目前用于头条
//头条中评论在浮层上，实例化之后可能没有真正的展示给用户
//用户可见的时候会调用isShowing = YES,否则相反
- (void)showStatusChanged:(BOOL)isShowing;

// unregister from impression manager
- (void)unregisterFromImpressionManager;

//评论区嵌入式cell的show事件统计,外部调用
- (void)sendShowTrackForVisibleCellsIfNeeded;

@end

@protocol ExploreCommentViewDelegate <NSObject>

@optional

- (void)commentView:(ExploreCommentView *)view avatarTappedWithCommentModel:(SSCommentModel *)model;
- (void)commentView:(ExploreCommentView *)view scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)commentView:(ExploreCommentView *)view scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)commentView:(ExploreCommentView *)view scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)commentView:(ExploreCommentView *)view scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)commentView:(ExploreCommentView *)view scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)commentView:(ExploreCommentView *)view didFetchCommentsWithManager:(SSCommentManager *)manager;

//下拉列表超过指定高度
- (void)commentViewPullToActionDone:(ExploreCommentView *)view;

- (void)commentViewWillLoadMore:(ExploreCommentView *)view;

- (void)commentViewShouldShowWriteCommentView;

@end

 
