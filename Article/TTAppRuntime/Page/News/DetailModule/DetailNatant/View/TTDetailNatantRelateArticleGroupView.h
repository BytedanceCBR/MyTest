//
//  TTDerailNatantRelateArticleGroupView.h
//  Article
//
//  Created by Ray on 16/4/5.
//
//

#import "TTDetailNatantViewBase.h"

@class TTDetailNatantRelateArticleGroupViewModel;
@class ArticleInfoManager;
@interface TTDetailNatantRelateArticleGroupView : TTDetailNatantViewBase

@property(nonatomic, strong, nullable) NSMutableArray<UIView *> *items;
@property(nonatomic, strong, nullable) TTDetailNatantRelateArticleGroupViewModel * viewModel;
/*
 *  wrapper中item的高度，要求wrapper中item高度一致
 */
- (CGFloat)heightOfItemInWrapper;
/*
 *  返回第index个item
 */
- (nullable UIView *)itemInWrapperAtIndex:(NSInteger)index;

- (void)setRelatedItems:(NSArray<NSDictionary *> * _Nullable)relatedItems;

- (CGFloat)relatedItemDistantFromTopToNantantTopAtIndex:(NSInteger)index;

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)newBuildRelatedArticleViewsWithData:(ArticleInfoManager * _Nullable)infoManager;

- (void)resetAllRelatedItemsWhenNatantDisappear;

@end
