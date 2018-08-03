//
//  ExploreArticleEssayCellCommentItemView.h
//  Article
//
//  Created by Chen Hong on 14-10-23.
//
//

#import "SSViewBase.h"

#pragma mark - ExploreArticleEssayCellCommentItemView
@protocol ExploreArticleEssayCellCommentItemViewDelegate;

@interface ExploreArticleEssayCellCommentItemView : SSViewBase

@property(nonatomic,weak)id<ExploreArticleEssayCellCommentItemViewDelegate> delegate;
@property(nonatomic,assign)NSUInteger orderIndex;
@property(nonatomic,assign)BOOL hideBottomLine;

- (void)reset;

- (void)refreshWithUserName:(NSString *)userName userComment:(NSString *)commentStr cellWidth:(CGFloat)width;

+ (CGFloat)heightForUserName:(NSString *)userName userComment:(NSString *)commentStr cellWidth:(CGFloat)width;

- (void)updateContentWithNormalColor;
- (void)updateContentWithHighlightColor;

@end

#pragma mark - ExploreArticleEssayCellCommentItemViewDelegate
@protocol ExploreArticleEssayCellCommentItemViewDelegate <NSObject>

@optional
- (void)commentItemDidTouchBegan:(ExploreArticleEssayCellCommentItemView *)item;
- (void)commentItemDidTouchEnded:(ExploreArticleEssayCellCommentItemView *)item;
- (void)commentItemDidTouchCancelled:(ExploreArticleEssayCellCommentItemView *)item;

- (void)commentItemDidSeletedNameButton:(ExploreArticleEssayCellCommentItemView *)item;
- (void)commentItemDidSeletedCommentButton:(ExploreArticleEssayCellCommentItemView *)item;

@end
