//
//  TTVMidInsertADPlayer.h
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVVideoPlayerStateStore.h"
#import "TTVADGuideCountdownViewProtocol.h"

/**
 *  视频贴片广告控制器
 1. 需求 https://wiki.bytedance.net/pages/viewpage.action?pageId=88679439
 2. API文档：https://wiki.bytedance.net/pages/viewpage.action?pageId=91197990
 */

typedef void  (^TTVMidInsertADRotateScreenAction)(BOOL fullScreen, BOOL animationed, void (^completionBlock)(BOOL finish));

@class TTVPasterADURLRequestInfo;
@interface TTVMidInsertADPlayer : UIView<TTVPlayerContext>
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@property(nonatomic, strong) NSDictionary *midInsertAdRequestInfo;
@property (nonatomic, assign, readonly) BOOL playingADGuide;
@property (nonatomic, copy) TTVMidInsertADRotateScreenAction rotateScreenAction;
@property (nonatomic, copy) void (^fadePlayerLastFrameAction)(void (^finished)(void));
@property (nonatomic, copy) void (^guideCountdownViewNeedShow)(UIView<TTVADGuideCountdownViewProtocol> *guideCountdownView);

- (BOOL)hasPasterAd;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)shouldPasterADPause;
@end
