//
//  TTLayOutLargePicCell.h
//  Article
//
//  Created by 王双华 on 16/10/12.
//
//

#import "ExploreCellBase.h"
#import "TTLayOutCellViewBase.h"
#import "TTVAutoPlayManager.h"
#import "TTVFeedPlayMovie.h"

@interface TTLayOutNewLargePicCell : ExploreCellBase <TTVAutoPlayingCell/*,TTSharedViewTransitionFrom*/>

@end

@interface TTLayOutNewLargePicCellView : TTLayOutCellViewBase <TTVFeedPlayMovie, TTVAutoPlayingCell /*,TTSharedViewTransitionFrom*/>
@property (nonatomic, weak) TTLayOutNewLargePicCell *cell;
- (void)willDisplay;
- (void)didEndDisplaying;
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

- (void)ttv_autoPlayVideo;
- (CGRect)ttv_logoViewFrame;
- (TTVPlayVideo *)ttv_movieView;
- (TTVPlayVideo *)movieView;
- (void)ttv_autoPlayingAttachMovieView:(UIView *)movieView;

@end
