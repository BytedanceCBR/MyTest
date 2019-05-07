//
//  TTVSpeedPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContexts.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"
#import "TTVPlayerButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVSpeedPart : NSObject<TTVPlayerContexts, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong) TTVPlayerButton * speedChangeButton;

- (void)dismissFloatSelectView;
- (void)showFloatSelectView;

@end

NS_ASSUME_NONNULL_END
