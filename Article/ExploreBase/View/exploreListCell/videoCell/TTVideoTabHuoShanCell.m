//
//  TTVideoTabHuoShanCell.m
//  Article
//
//  Created by xuzichao on 16/6/12.
//
//

#import "TTVideoTabHuoShanCell.h"
#import "TTVideoTabHuoShanCellView.h"

@interface TTVideoTabHuoShanCell()
@property(nonatomic, strong) TTVideoTabHuoShanCellView * playVideoCellView;
@end

@implementation TTVideoTabHuoShanCell

+ (Class)cellViewClass
{
    return [TTVideoTabHuoShanCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_playVideoCellView) {
        self.playVideoCellView = [[TTVideoTabHuoShanCellView alloc] initWithFrame:self.bounds];
    }
    return _playVideoCellView;
}

- (void)didEndDisplaying
{
    [_playVideoCellView didEndDisplaying];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    [_playVideoCellView cellInListWillDisappear:context];
}

- (BOOL)isPlayingMovie
{
    return NO;
}

- (BOOL)isMovieFullScreen
{
    return NO;
}

- (BOOL)hasMovieView {
    return NO;
}

- (ExploreMovieView *)movieView
{
    return nil;
}

- (ExploreMovieView *)detachMovieView {
    return nil;
}

- (void)attachMovieView:(ExploreMovieView *)movieView {

}

- (CGRect)logoViewFrame
{
    return [_playVideoCellView logoViewFrame];
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:[_playVideoCellView movieViewFrameRect] fromView:_playVideoCellView];
}

@end
