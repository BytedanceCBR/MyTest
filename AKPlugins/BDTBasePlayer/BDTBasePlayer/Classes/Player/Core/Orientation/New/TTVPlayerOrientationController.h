//
//  TTVPlayerOrientationController.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStateStore.h"
#import "TTVPlayerOrientation.h"
#import "TTVPlayerControllerProtocol.h"

@interface TTVPlayerOrientationController : NSObject<TTVPlayerContext,TTVPlayerOrientation>
@property (nonatomic, weak) id<TTVOrientationDelegate> delegate;
@property (nonatomic, weak) UIView *rotateView;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;

@end
