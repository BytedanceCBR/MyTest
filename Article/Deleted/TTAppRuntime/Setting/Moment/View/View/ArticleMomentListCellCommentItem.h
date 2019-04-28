//
//  ArticleMomentListCellCommentItem.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-23.
//
//  动态列表上的每一项评论的view

#import "SSViewBase.h"
#import "ArticleMomentCommentModel.h"
#import "ExploreMomentDefine.h"

@protocol ArticleMomentListCellCommentItemDelegate;

@interface ArticleMomentListCellCommentItem : SSViewBase
@property(nonatomic, weak)id<ArticleMomentListCellCommentItemDelegate>delegate;
@property(nonatomic, assign)NSUInteger orderIndex;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;

- (void)refreshWithCommentModel:(ArticleMomentCommentModel *)commentModel cellWidth:(CGFloat)width;

+ (CGFloat)heightForCommentModel:(ArticleMomentCommentModel *)commentModel cellWidth:(CGFloat)width;

@end

@protocol ArticleMomentListCellCommentItemDelegate <NSObject>

@optional

- (void)commentItemDidSeletedReplyNameButton:(ArticleMomentListCellCommentItem *)item;
- (void)commentItemDidSeletedNameButton:(ArticleMomentListCellCommentItem *)item;
- (void)commentItemDidSeletedCommentButton:(ArticleMomentListCellCommentItem *)item;

@end
