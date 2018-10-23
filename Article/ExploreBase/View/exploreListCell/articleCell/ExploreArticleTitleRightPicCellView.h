//
//  ExploreArticleTitleRightPicCellView.h
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleCellView.h"

#define kVideoPGCCellTopInset 10.0f

@class TTImageView;

@interface ExploreArticleTitleRightPicCellView : ExploreArticleCellView/*<TTSharedViewTransitionFrom>*/

+ (CGSize)picSizeWithCellWidth:(CGFloat)cellWidth;

//@property(nonatomic,strong)TTImageView* pic;

@end
