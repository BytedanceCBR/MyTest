    //
//  TTVideoTabBaseCell.m
//  Article
//
//  Created by 王双华 on 15/10/10.
//
//

#import "TTVideoTabBaseCell.h"
#import "TTVideoTabBaseCellView.h"

@interface TTVideoTabBaseCell()
@property(nonatomic, strong)TTVideoTabBaseCellView * playVideoCellView;
@end

@implementation TTVideoTabBaseCell

+ (Class)cellViewClass
{
    return [TTVideoTabBaseCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_playVideoCellView) {
        self.playVideoCellView = [[TTVideoTabBaseCellView alloc] initWithFrame:self.bounds];
    }
    return _playVideoCellView;
}


- (void)willAppear
{
    [_playVideoCellView willAppear];
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
    return [_playVideoCellView isPlayingMovie];
}

- (BOOL)isMovieFullScreen
{
    return [_playVideoCellView isMovieFullScreen];
}

- (BOOL)hasMovieView {
    return [_playVideoCellView hasMovieView];
}

- (UIView *)movieView
{
    return [_playVideoCellView movieView];
}

- (UIView *)detachMovieView {
    return [_playVideoCellView detachMovieView];
}

- (void)attachMovieView:(ExploreMovieView *)movieView {
    [_playVideoCellView attachMovieView:movieView];
}

- (CGRect)logoViewFrame
{
    return [_playVideoCellView logoViewFrame];
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:[_playVideoCellView movieViewFrameRect] fromView:_playVideoCellView];
}

- (UIView *)ttv_playerSuperView
{
    return [_playVideoCellView ttv_playerSuperView];
}

- (BOOL)ttv_canUseNewPlayer
{
    return [_playVideoCellView ttv_canUseNewPlayer];
}

- (id)ttv_playerController
{
    return [_playVideoCellView ttv_playerController];
}
@end

