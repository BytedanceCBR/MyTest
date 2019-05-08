//
//  TTVExitFullscreenAnimatedTransitioning.h
//  Article
//
//  Created by 徐霜晴 on 16/9/26.
//
//

#import <UIKit/UIKit.h>
#import "TTVFullscreenProtocol.h"
extern NSString *const TTVDidExitFullscreenNotification;
typedef void(^TTVFullScreenExitFinished)(void);
@interface TTVExitFullscreenAnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithMovieView:(UIView *)movieView controller:(NSObject<TTVFullscreenPlayerProtocol> *)controller exitFinished:(TTVFullScreenExitFinished)finished;
@end
