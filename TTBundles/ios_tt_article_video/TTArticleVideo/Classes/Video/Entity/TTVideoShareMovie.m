//
//  TTVideoShareMovie.m
//  Article
//
//  Created by panxiang on 16/11/24.
//
//

#import "TTVideoShareMovie.h"
#import "TTVideoTabBaseCellPlayControl.h"
#import "ExploreMovieView.h"

@implementation TTVideoShareMovie
@synthesize movieView = _movieView;
- (void)setMovieView:(UIView *)movieView
{
    if (movieView != _movieView) {
        _movieView = movieView;
    }
    if (!movieView) {
        if ([_movieView isKindOfClass:[ExploreMovieView class]]) {
            ExploreMovieView *movie = (ExploreMovieView *)movieView;
            if ([movie isStoped]) {
                [movie stopMovie];
            }
        }
    }
}

@end
