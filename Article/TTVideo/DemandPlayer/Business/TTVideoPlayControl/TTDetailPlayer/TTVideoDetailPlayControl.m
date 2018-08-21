//
//  TTVideoDetailPlayControl.m
//  Article
//
//  Created by panxiang on 2017/6/6.
//
//

#import "TTVideoDetailPlayControl.h"

@implementation TTVideoDetailPlayControl
- (void)releatedVideoCliced{}
- (void)viewDidLoad{}
- (void)invalideMovieView{}
- (void)viewWillAppear{}
- (void)viewDidAppear{}
- (void)viewWillDisappear{}
- (void)viewDidDisappear{}
- (BOOL)shouldLayoutSubviews{return NO;}
- (void)layoutSubViews{}
- (void)playButtonClicked{}
- (float)watchPercent{return 0;}
- (void)updateFrame{};
- (BOOL)isMovieFullScreen{return NO;}
- (void)showDetailButtonIfNeeded{}
- (BOOL)isFirstPlayMovie{return NO;}
- (void)pauseMovieIfNeeded{};
- (void)playMovieIfNeededAndRebindToMovieShotView:(BOOL)rebindToMovieShotView{};
- (void)playMovieIfNeeded
{
    [self playMovieIfNeededAndRebindToMovieShotView:YES];
}
- (void)setToolBarHidden:(BOOL)hidden{};
- (void)addCommodity{};
@end
