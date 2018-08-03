//
//  WDDetailNatantRelateArticleGroupView.h
//  Article
//
//  Created by 延晋 张 on 16/4/26.
//
//

#import "WDDetailNatantViewBase.h"

@class WDDetailModel;
@class WDDetailNatantRelateArticleGroupViewModel;

@interface WDDetailNatantRelateArticleGroupView : WDDetailNatantViewBase

@property(nonatomic, strong, nullable) NSMutableArray<UIView *> *items;
@property(nonatomic, strong, nullable) WDDetailNatantRelateArticleGroupViewModel * viewModel;
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

- (void)newBuildRelatedArticleViewsWithData:(WDDetailModel * _Nullable)infoManager;

- (void)resetAllRelatedItemsWhenNatantDisappear;

@end
