//
//  TTVResolutionManager.h
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayer.h"
@interface TTVResolutionManager : NSObject<TTVPlayerContext>
- (void)enableResolution:(BOOL)enable;
- (void)customTracker:(NSObject <TTVPlayerTracker> *)tracker;
@end

@interface TTVPlayer (Resolution)
- (TTVResolutionManager *)resolutionManager;
@end

