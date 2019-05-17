//
//  TTVBackgroundManager.h
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"

@protocol TTVBackgroundManagerDelegate <NSObject>

- (BOOL)playerViewControllerShouldPlay;

@end

@interface TTVBackgroundManager : NSObject<TTVPlayerContext>
@property (nonatomic ,weak)id <TTVBackgroundManagerDelegate> delegate;
@property (nonatomic ,assign)BOOL isAllowPlayWhenDidBecomeActive;
- (void)customTracker:(NSObject <TTVPlayerTracker> *)tracker;
@end

@interface TTVPlayer (Background)
- (TTVBackgroundManager *)resolutionManager;
@end

