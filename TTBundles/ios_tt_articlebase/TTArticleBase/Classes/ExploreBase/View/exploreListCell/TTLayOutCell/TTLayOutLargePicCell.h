//
//  TTLayOutLargePicCell.h
//  Article
//
//  Created by 王双华 on 16/10/12.
//
//

#import "ExploreCellBase.h"
#import "TTLayOutCellViewBase.h"

@interface TTLayOutLargePicCell : ExploreCellBase <ExploreMovieViewCellProtocol /*,TTSharedViewTransitionFrom*/>

@end

@interface TTLayOutLargePicCellView : TTLayOutCellViewBase <ExploreMovieViewCellProtocol /*,TTSharedViewTransitionFrom*/>

- (void)willDisplay;
- (void)didEndDisplaying;
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

@end
