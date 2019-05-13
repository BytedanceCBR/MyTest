//
//  TTVPlayerStore.h
//  Article
//
//  Created by panxiang on 2018/7/22.
//

#import "TTVRStore.h"
#import "TTVPlayerState.h"
#import "TTVPlayerContext.h"

@class TTVPlayerStore;
@class TTVPlayer;

// 把类去掉，留下 action 宏定义
// 宏定义的位置？ 


#define TTVPlayerActionTypePlay     @"TTVPlayerActionTypePlay"
#define TTVPlayerActionTypePause    @"TTVPlayerActionTypePause"
#define TTVPlayerActionTypeResume   @"TTVPlayerActionTypeResume"
#define TTVPlayerActionTypeStop     @"TTVPlayerActionTypeStop"
#define TTVPlayerActionTypeRetry    @"TTVPlayerActionTypeRetry"

/**
 NSNumber currentPlaybackTime NSNumber result
 */
#define TTVPlayerActionTypeSeekEnd  @"TTVPlayerActionTypeSeekEnd"

/**
 NSNumber currentPlaybackTime
 */
#define TTVPlayerActionTypeSeekBegin  @"TTVPlayerActionTypeSeekBegin"

#define TTVPlayerActionTypeFetchedVideoModel @"TTVPlayerActionTypeFetchedVideoModel"
#define TTVPlayerActionTypeSuggestReduceResolution @"TTVPlayerActionTypeSuggestReduceResolution"
#define TTVPlayerActionTypeVideoEngineDidFinish @"TTVPlayerActionTypeVideoEngineDidFinish"
/*
 info[@"showRetry"] = @(0);
 info[@"error"] = NSError;
 */
#define TTVPlayerActionTypeVideoEngineUserStopped @"TTVPlayerActionTypeVideoEngineUserStopped"

@interface TTVPlayerStore : TTVRStore
@property (nonatomic ,weak)TTVPlayer *player;

@property (nonatomic, strong) TTVPlayerState *state;
//待考虑  模块到底需不需要对TTVPlayer进行弱持有
/*
 持有, 使用方便 , state的就专门来维护处理 模块之间的状态 ,不持有是鉴于模块的复用性. 个人觉得没有复用的必要.
 不持有, dispatchMessage 去使用player里面的方法和状态 , state的维护 player状态 + 模块之间的状态
 */
@end







