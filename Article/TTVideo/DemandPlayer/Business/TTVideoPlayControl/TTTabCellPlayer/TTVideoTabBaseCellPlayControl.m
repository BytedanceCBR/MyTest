//
//  TTVideoTabBaseCellPlayControl.m
//  Article
//
//  Created by panxiang on 2017/6/5.
//
//

#import "TTVideoTabBaseCellPlayControl.h"

@implementation TTVideoTabBaseCellPlayControl
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playButtonClicked
{
}
- (void)invalideMovieView
{

}
- (void)didEndDisplaying
{
}
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
}
- (BOOL)isPlaying
{
    return NO;
}

- (BOOL)isPause
{
    return NO;
}

- (BOOL)isStopped
{
    return NO;
}

- (UIView *)detachMovieView
{
    return nil;
}

- (void)attachMovieView:(UIView *)movieView
{

}
- (BOOL)hasMovieView
{
    return NO;
}

- (BOOL)isMovieFullScreen
{
    return NO;
}
- (BOOL)exitFullScreen:(BOOL)animation completion:(void (^)(BOOL finished))completion
{
    return NO;
}
- (void)bringAdButtonToMovie:(UIView *)adButton{}
- (void)goVideoDetail{}
- (void)beforeCellReuse{};
- (void)willAppear{}
- (void)addCommodity{};
@end
