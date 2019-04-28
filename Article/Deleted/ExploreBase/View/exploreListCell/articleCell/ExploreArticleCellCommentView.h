//
//  ExploreCellCommentView.h
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "SSViewBase.h"
#import "ExploreOrderedData+TTBusiness.h"

@class ExploreArticleCellCommentView;

@protocol ExploreArticleCellCommentViewDelegate <NSObject>
- (void)exploreArticleCellCommentViewSelected:(ExploreArticleCellCommentView*)commentView;
@end


@interface ExploreArticleCellCommentView : SSViewBase

@property(nonatomic, strong)UILabel *contentLabel;
@property(nonatomic, strong)NSDictionary *currentCommentData;
@property(nonatomic, weak)id<ExploreArticleCellCommentViewDelegate> delegate;

- (void)updateContentWithNormalColor;
- (void)updateContentWithHighlightColor;
- (void)updateBackgroundWithHighlightedColor:(BOOL)highlighted;

- (void)reloadCommentDict:(NSDictionary *)commentDict cellWidth:(CGFloat)cellWidth;

+ (NSAttributedString *)commentAttributedStrFromCommentDict:(NSDictionary *)commentDic highlighted:(BOOL)highlighted;

//+ (CGFloat)heightOfCommentView:(NSDictionary *)commentDic width:(CGFloat)width;

@end
