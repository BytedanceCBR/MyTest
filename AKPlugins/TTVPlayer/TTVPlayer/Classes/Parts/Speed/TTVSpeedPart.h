//
//  TTVSpeedPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"
#import "TTVPlayerCustomViewDelegate.h"
#import "TTVButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVSpeedPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

@property (nonatomic, strong) TTVButton * speedChangeButton;

- (void)dismissFloatSelectView;
- (void)showFloatSelectView;

@end

NS_ASSUME_NONNULL_END
