//
//  TTMovieLandscapeTransitionDelegate.h
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import <UIkit/UIKit.h>
#import "TTMovieFullscreenProtocol.h"

extern NSString *const TTMovieDidEnterFullscreenNotification;

@interface TTMovieEnterFullscreenAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithSmallMovieView:(UIView<TTMovieFullscreenProtocol> *)movieView;

@end
