//
//  TTVideoDetailOldPlayControl.h
//  Article
//
//  Created by panxiang on 2017/6/6.
//
//

#import "TTVideoDetailPlayControl.h"
@class ArticleVideoPosterView;
@class ExploreMovieView;
@interface TTVideoDetailOldPlayControl : TTVideoDetailPlayControl
@property (nonatomic, strong) ArticleVideoPosterView * _Nullable movieShotView;
@property (nonatomic, strong, nullable) ExploreMovieView *movieView;
@end
