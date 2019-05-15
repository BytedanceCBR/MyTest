//
//  TTVideoEmbededAdButton.h
//  Article
//
//  Created by 刘廷勇 on 16/6/8.
//
//

#import "ExploreActionButton.h"
#import "ExploreMovieView.h"

#define kCornerButtonInsetLeft 10
#define kCornerButtonHeight 20

/**
 *  用于cell上的广告button
 */
@interface TTVideoEmbededAdButton : ExploreActionButton

@property (nonatomic, weak) ExploreMovieView *attachedMovie;

@end
