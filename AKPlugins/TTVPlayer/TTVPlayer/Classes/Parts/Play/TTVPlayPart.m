//
//  TTVPlayPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/4.
//

#import "TTVPlayPart.h"
#import "TTVPlayer.h"
#import "TTVPlayerState.h"
#import "TTVPlayer+Engine.h"
#import "UIImage+TTVHelper.h"

@interface TTVPlayPart ()

// 记录原始的值
@property (nonatomic) BOOL lastCenterPlayButtonHidden;
@property (nonatomic) BOOL lastHiddenRecorded;


@end

@implementation TTVPlayPart

@synthesize playerStore, player, playerAction;

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    
    // 控制 loading 和 centerPlaybutton 的UI 展示关系
    if (lastState && newState.loadingViewState.isShowed != lastState.loadingViewState.isShowed) {
        // 这里延迟一秒执行是因为，loading 出现是1s
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCenterButton) object:nil];
        if (newState.loadingViewState.isShowed) {
            self.lastCenterPlayButtonHidden = self.centerPlayButton.hidden;
            [self hideCenterButton];
        }
        else {
            self.centerPlayButton.hidden = self.lastCenterPlayButtonHidden;
        }
    }
    
    // 当播放状态变化: 全屏或者非全屏有变化
    if (newState.playbackState != lastState.playbackState ||
        newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen) {
        // 状态变化，可以设置按钮
        if (newState.playbackState == TTVPlaybackState_Playing) {
            self.bottomPlayButton.currentToggledStatus = TTVToggledButtonStatus_Toggled;
            self.centerPlayButton.currentToggledStatus = TTVToggledButtonStatus_Toggled;
        }
        else {
            self.bottomPlayButton.currentToggledStatus = TTVToggledButtonStatus_Normal;
            self.centerPlayButton.currentToggledStatus = TTVToggledButtonStatus_Normal;
        }
    }
    
    ///////////////////////////////////////////////  中间位置展示互斥关系 ////////////////////////////////////
    // 控制 HUD 和 centerPlaybutton 的 UI 展示关系, 有bug
    if ( lastState &&  newState.seekStatus.isHudShowed != lastState.seekStatus.isHudShowed) {
        if (newState.seekStatus.isHudShowed) {
            self.lastCenterPlayButtonHidden = self.centerPlayButton.hidden;
            [self hideCenterButton];
        }
        else {
            self.centerPlayButton.hidden = self.lastCenterPlayButtonHidden;
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

- (void)hideCenterButton {
    self.centerPlayButton.hidden = YES;
}

#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_PlayCenterToggledButton) {
        return self.centerPlayButton;
    }
    if (key == TTVPlayerPartControlKey_PlayBottomToggledButton) {
        return self.bottomPlayButton;
    }
    return nil;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_PlayCenterToggledButton) {
        self.centerPlayButton = (UIView<TTVToggledButtonProtocol> *)controlView;

        // 设置默认 action, 但是外界可能没实现这个 action
        BOOL shouldImplementTouchupInsideBlock;
        if (![self.centerPlayButton respondsToSelector:@selector(setAction:forStatus:)]
            && ![self.centerPlayButton respondsToSelector:@selector(actionForStatus:)]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        else if (![self.centerPlayButton actionForStatus:TTVToggledButtonStatus_Normal] || ![self.centerPlayButton actionForStatus:TTVToggledButtonStatus_Toggled]){
            shouldImplementTouchupInsideBlock = YES;
        }
        if (shouldImplementTouchupInsideBlock) {
            @weakify(self);
            self.centerPlayButton.didToggledButtonTouchUpInside = ^{
                @strongify(self);
                if (self.centerPlayButton.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                    [self.player play];
                }
                else {
                    [self.player pause];
                }
            };
        }
    }
    else if (key == TTVPlayerPartControlKey_PlayBottomToggledButton) {
        self.bottomPlayButton = (UIView<TTVToggledButtonProtocol> *)controlView;
        
        // 设置默认 action, 但是外界可能没实现这个 action
        BOOL shouldImplementTouchupInsideBlock;
        if (![self.bottomPlayButton respondsToSelector:@selector(setAction:forStatus:)]
            && ![self.bottomPlayButton respondsToSelector:@selector(actionForStatus:)]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        else if (![self.bottomPlayButton actionForStatus:TTVToggledButtonStatus_Normal] || ![self.bottomPlayButton actionForStatus:TTVToggledButtonStatus_Toggled]){
            shouldImplementTouchupInsideBlock = YES;
        }
        if (shouldImplementTouchupInsideBlock) {
            @weakify(self);
            self.bottomPlayButton.didToggledButtonTouchUpInside = ^{
                @strongify(self);
                if (self.bottomPlayButton.currentToggledStatus == TTVToggledButtonStatus_Normal) {
                    [self.player play];
                }
                else {
                    [self.player pause];
                }
            };
        }
    }
}

- (void)removeAllControlView {
    [self.centerPlayButton removeFromSuperview];
    [self.bottomPlayButton removeFromSuperview];
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Play;
}

@end
