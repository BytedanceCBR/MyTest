//
//  TTVPasterPlayer.h
//  Article
//
//  Created by panxiang on 2017/6/12.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVVideoPlayerStateStore.h"
typedef void (^ReplayOriginalVideoAction) ();
typedef void  (^RotateScreenAction)(BOOL fullScreen, BOOL animationed, void (^completionBlock)(BOOL finish));

@class TTVVideoPlayerStateStore;
@class TTVPasterADURLRequestInfo;
@interface TTVPasterPlayer : UIView<TTVPlayerContext>
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@property(nonatomic, strong) TTVPasterADURLRequestInfo *pasterAdRequestInfo;

@property (nonatomic, copy) ReplayOriginalVideoAction replayAction; // reply the original video
@property (nonatomic, copy) RotateScreenAction rotateScreenAction;
@property (nonatomic, copy) void (^fadePlayerLastFrameAction)(void (^finished)(void));
           
- (BOOL)hasPasterAd;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)shouldPasterADPause;
@end
