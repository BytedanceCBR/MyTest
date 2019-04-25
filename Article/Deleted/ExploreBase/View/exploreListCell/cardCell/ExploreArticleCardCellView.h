//
//  ExploreArticleCardCellView.h
//  Article
//
//  Created by Chen Hong on 14/11/21.
//
//

#import "ExploreCellViewBase.h"

@interface ExploreArticleCardCellView : ExploreCellViewBase
@property(nonatomic, strong)id selectedSubCellData;
@property(nonatomic, assign)NSInteger selectedSubCellIndex;
@property(nonatomic, strong)id selectedSubCellView;

//- (ExploreCellViewBase *)selectedCellView;

- (void)willDisplay;
- (void)didEndDisplaying;


@end
