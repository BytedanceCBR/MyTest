//
//  ExploreArticleEssayCellCommentView.h
//  Article
//
//  Created by Chen Hong on 14-10-23.
//
//

#import "SSViewBase.h"
#import "ExploreArticleEssayCommentObject.h"

#pragma mark - ExploreArticleEssayCellCommentView

@protocol ExploreArticleEssayCellCommentViewDelegate;

@interface ExploreArticleEssayCellCommentView : SSViewBase

@property(nonatomic, weak)id<ExploreArticleEssayCellCommentViewDelegate> delegate;

- (void)refreshWithComments:(NSArray *)commentItems viewWidth:(CGFloat)width;
+ (CGFloat)heightForComments:(NSArray *)commentItems viewWidth:(CGFloat)width;

- (void)updateBackgroudColorWithHighlighted:(BOOL)bHighlighted;

@end


@protocol ExploreArticleEssayCellCommentViewDelegate <NSObject>
@optional
- (void)exploreArticleEssayCellCommentView:(ExploreArticleEssayCellCommentView *)view commentClicked:(ExploreArticleEssayCommentObject *)commentObj;

@end