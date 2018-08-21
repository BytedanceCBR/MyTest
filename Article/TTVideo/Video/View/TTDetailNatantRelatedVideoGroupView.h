//
//  TTDetailNatantRelatedVideoGroupView.h
//  Article
//
//  Created by Ray on 16/4/15.
//
//

#import "TTDetailNatantViewBase.h"

@class Article;
@class TTDetailNatantRelateReadView;

@protocol TTDetailNatantRelatedVideoBaseViewDelegate <NSObject>

- (void)didSelectVideoAlbum:(Article * _Nonnull)article;

@end

/*!
 @class TTDetailNatantRelatedVideoBaseView
 @abstract TTDetailNatantRelatedVideoBaseView is an abstract class;
 */
@interface TTDetailNatantRelatedVideoBaseView: TTDetailNatantViewBase

@property (nonatomic, strong, nullable) NSMutableArray<TTDetailNatantRelateReadView *> *items;
@property (nonatomic, weak, nullable) id<TTDetailNatantRelatedVideoBaseViewDelegate> delegate;
@property(nonatomic, assign) CGFloat referHeight;

- (void)enableBottomLine:(BOOL)enable;

- (NSInteger)currentShowNumberOfItems;

- (void)sendRelatedVideoImpressionWhenNatantDidLoadIfNeeded;

- (void)endRelatedVideoImpressionWhenDisappear;

@end

@interface TTDetailNatantRelatedVideoGroupView : TTDetailNatantRelatedVideoBaseView


@end
