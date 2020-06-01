//
//  TTVLockPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/10.
//

#import "TTVLockPart.h"
#import "TTVPlayer.h"
#import "TTVPlayerState.h"
#import "UIImage+TTVHelper.h"

@implementation TTVLockPart

@synthesize playerStore, player, playerAction;

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    if (newState.controlViewState.isLocked != lastState.controlViewState.isLocked) {
        if (newState.controlViewState.isLocked) {
            self.lockToggledButton.currentToggledStatus = TTVToggledButtonStatus_Toggled;
            // 并且移动superview, 移动到 contentViewLock上
            [self.player.containerView.playbackControlView_Lock.contentView addSubview:self.lockToggledButton];
            [self.player.view setNeedsLayout];
        }
        else {
            self.lockToggledButton.currentToggledStatus = TTVToggledButtonStatus_Normal;
            [self.player.controlView.contentView addSubview:self.lockToggledButton];
           
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}
#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_LockToggledButton) {
        return self.lockToggledButton;
    }
    return nil;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_LockToggledButton) {
        self.lockToggledButton = (UIView<TTVToggledButtonProtocol> *)controlView;

        // 设置默认 action, 但是外界可能没实现这个 action
        BOOL shouldImplementTouchupInsideBlock;
        if (![self.lockToggledButton respondsToSelector:@selector(setAction:forStatus:)]
            && ![self.lockToggledButton respondsToSelector:@selector(actionForStatus:)]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        else if (![self.lockToggledButton actionForStatus:TTVToggledButtonStatus_Normal] || ![self.lockToggledButton actionForStatus:TTVToggledButtonStatus_Toggled]){
            shouldImplementTouchupInsideBlock = YES;
        }
        if (shouldImplementTouchupInsideBlock) {
            @weakify(self);
            self.lockToggledButton.didToggledButtonTouchUpInside = ^{
                @strongify(self);
                if (self.lockToggledButton.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                    [self.playerStore dispatch:[self.playerAction actionForKey:TTVPlayerActionType_Lock]];
                }
                else {
                    [self.playerStore dispatch:[self.playerAction actionForKey:TTVPlayerActionType_UnLock]];
                }
            };
        }
    }
}

- (void)removeAllControlView {
    [self.lockToggledButton removeFromSuperview];
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Lock;
}

@end
