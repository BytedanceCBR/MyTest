//
//  TTVideoTabLiveCell.m
//  Article
//
//  Created by xuzichao on 16/5/25.
//
//

#import "TTVideoTabLiveCell.h"
#import "TTVideoTabLiveCellView.h"

@interface TTVideoTabLiveCell ()

@property (nonatomic,strong) TTVideoTabLiveCellView *liveVideoCellView;

@end

@implementation TTVideoTabLiveCell

+ (Class)cellViewClass
{
    return [TTVideoTabLiveCellView class];
}


- (ExploreCellViewBase *)createCellView
{
    if (!_liveVideoCellView) {
        _liveVideoCellView = [[TTVideoTabLiveCellView alloc] initWithFrame:self.bounds];
    }
    
    return _liveVideoCellView;
}

- (void)didEndDisplaying
{
    [_liveVideoCellView didEndDisplaying];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    [_liveVideoCellView cellInListWillDisappear:context];
}

- (BOOL)isPlayingMovie
{
    return [_liveVideoCellView isPlayingMovie];
}

- (BOOL)isMovieFullScreen
{
    return [_liveVideoCellView isMovieFullScreen];
}

- (BOOL)hasMovieView {
    return [_liveVideoCellView hasMovieView];
}

- (ExploreMovieView *)movieView
{
    return [_liveVideoCellView movieView];
}

- (ExploreMovieView *)detachMovieView {
    return [_liveVideoCellView detachMovieView];
}

- (void)attachMovieView:(ExploreMovieView *)movieView {
    [_liveVideoCellView attachMovieView:movieView];
}

- (CGRect)logoViewFrame
{
    return [_liveVideoCellView logoViewFrame];
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:[_liveVideoCellView movieViewFrameRect] fromView:_liveVideoCellView];
}

@end
