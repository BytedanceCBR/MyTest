//
//  TTVResolutionTipManager.h
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"
#import "TTVPlayerContext.h"

@interface TTVResolutionTipManager : NSObject<TTVPlayerContext>
- (void)customTracker:(NSObject <TTVPlayerTracker> *)tracker;
@end

@interface TTVPlayer (ResolutionTip)
- (TTVResolutionTipManager *)resolutionTipManager;
@end

