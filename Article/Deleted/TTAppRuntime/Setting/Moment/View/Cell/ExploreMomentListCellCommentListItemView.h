//
//  ExploreMomentListCellCommentListItemView.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//  动态cell中的元素， 用于显示评论列表

#import "ExploreMomentListCellItemBase.h"

@protocol ExploreMomentListCellCommentListItemViewDelegate;

@interface ExploreMomentListCellCommentListItemView : ExploreMomentListCellItemBase

@property(nonatomic, weak)id<ExploreMomentListCellCommentListItemViewDelegate> delegate;


+ (BOOL)needShowHasMoreView:(ArticleMomentModel *)model;

@end

@protocol ExploreMomentListCellCommentListItemViewDelegate <NSObject>

@optional

- (void)momentCellCommentView:(ExploreMomentListCellCommentListItemView *)view commentButtonClicked:(ArticleMomentCommentModel *)commentModel rectInKeyWindow:(CGRect)rect;
- (void)momentCellCommentViewShowMoreLabelClicked:(ExploreMomentListCellCommentListItemView *)view;
- (void)momentCellCommentViewWriteCommentButtonClicked:(ExploreMomentListCellCommentListItemView *)view rectInKeyWindow:(CGRect)rect;

@end