//
//  TTVFullScreenManager.h
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"
@interface TTVFullScreenManager : NSObject<TTVPlayerContext>
- (void)setFullScreen:(BOOL)fullScreen animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)setSupportsPortaitFullScreen:(BOOL)supportsPortaitFullScreen;
- (void)customFullButton:(UIButton *)fullButton;
@end

@interface TTVPlayer (FullScreenManager)
- (TTVFullScreenManager *)fullScreenManager;
@end

