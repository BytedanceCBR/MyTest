//
//  TTVPlayManager.h
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"

@interface TTVPlayManager : NSObject<TTVPlayerContext>
- (void)setPlayControlsDisabled:(BOOL)disabled location:(TTVPlayerControlsCanDisableLocation)location;
- (void)insertBackgoundViewBeforePlayingWithView:(UIView *)view;
- (void)setIsIndetail:(BOOL)isIndetail;
@end

@interface TTVPlayer (TTVPlayManager)
- (TTVPlayManager *)playManager;
@end
