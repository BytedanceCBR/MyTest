//
//  TTMovieLandscapeTransitionDelegate.h
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import <UIkit/UIKit.h>
#import "TTVFullscreenProtocol.h"

extern NSString *const TTVPlayerDidEnterFullscreenNotification;

@interface TTVEnterFullscreenAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithMovieView:(UIView *)movieView;

@end
