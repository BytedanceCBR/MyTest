//
//  TTMovieExitFullscreenAnimatedTransitioning.h
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import <UIKit/UIKit.h>
#import "TTMovieFullscreenProtocol.h"

extern NSString *const TTMovieDidExitFullscreenNotification;

@interface TTMovieExitFullscreenAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithFullscreenMovieView:(UIView<TTMovieFullscreenProtocol> *)movieView;

@end
