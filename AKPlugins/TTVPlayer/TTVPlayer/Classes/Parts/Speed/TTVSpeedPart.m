//
//  TTVSpeedPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/24.
//

#import "TTVSpeedPart.h"
#import "TTVPlayer.h"
#import "TTVPlayerState.h"
#import "TTVPlayer+Engine.h"
#import "TTPlayerPlaybackSpeedView.h" // 弹层选择 view
#import "TTVIndicatorView.h"

@interface TTVSpeedPart ()

@property (nonatomic, strong) TTPlayerPlaybackSpeedView *playbackSpeedView; // 弹层
@property (nonatomic, strong) TTVIndicatorView * currentIndicatorView;      // 当前展示的

@end

@implementation TTVSpeedPart

@synthesize playerStore, player, playerAction;

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    
    if (newState.speedState.speed != lastState.speedState.speed) {
        // 更新 button UI
        [self updatePlaybackSpeedTitle:[self.playbackSpeedView titleForPlaybackSpeed:newState.speedState.speed]];
        
        // 展示提示
        NSString *content = [NSString stringWithFormat:@"已为您开启%@播放", [self.playbackSpeedView tipForPlaybackSpeed:newState.speedState.speed]];
        [self.currentIndicatorView hideAnimated:NO];
        TTVIndicatorView *indicator =  [TTVIndicatorView showIndicatorAddedToView:self.player.controlView text:content image:nil];
        indicator.stayDuration = 3.0f;
        self.currentIndicatorView = indicator;
    }
    
    // 旋转时消失
    if (newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen) {
        [self dismissFloatSelectView];
    }
    
    // 外界控制消失
    if (newState.speedState.speedSelectViewShouldShow != lastState.speedState.speedSelectViewShouldShow) {
        if (newState.speedState.speedSelectViewShouldShow) {
            if (!newState.speedState.speedSelectViewShowed) {
                [self showFloatSelectView];
            }
        }
        else {
            if (newState.speedState.speedSelectViewShowed) {
                [self dismissFloatSelectView];
            }
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
    if (key == TTVPlayerPartControlKey_SpeedChangeButton) {
        return self.speedChangeButton;
    }
    return nil;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_SpeedChangeButton) {
        self.speedChangeButton = (TTVButton *)controlView;
        _speedChangeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -7);
        [_speedChangeButton setTitle:@"倍速" forState:UIControlStateNormal];
        _speedChangeButton.titleLabel.font = [TTVPlayerUtility tt_semiboldFontOfSize:17];
        [_speedChangeButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_speedChangeButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:0.5f] forState:UIControlStateDisabled];
        
        // 设置默认 action, 但是外界可能没实现这个 action
        BOOL shouldImplementTouchupInsideBlock = false;
        if (![self.speedChangeButton respondsToSelector:@selector(setAction:)]
            && ![self.speedChangeButton respondsToSelector:@selector(action)]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        else if (![self.speedChangeButton action]) {
            shouldImplementTouchupInsideBlock = YES;
        }
        if (shouldImplementTouchupInsideBlock) {
            @weakify(self);
            self.speedChangeButton.didButtonTouchUpInside = ^{
                @strongify(self);
                // show
                if (self.playbackSpeedView.isShowing) {
                    [self.playerStore dispatch:[self.playerAction showSpeedSelectViewAction:NO]];
                } else {
                    [self.playerStore dispatch:[self.playerAction showSpeedSelectViewAction:YES]];
                }
            };
        }
    }
}

- (void)removeAllControlView {
    [self.speedChangeButton removeFromSuperview];
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Speed;
}

- (TTPlayerPlaybackSpeedView *)playbackSpeedView {
    if (!_playbackSpeedView) {
        _playbackSpeedView = [[TTPlayerPlaybackSpeedView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _playbackSpeedView.didPlaybackSpeedChanged = ^(CGFloat playbackSpeed) {
            // action
            @strongify(self);
            [self.playerStore dispatch:[self.playerAction changeSpeedToAction:playbackSpeed]];
            
        };
    }
    return _playbackSpeedView;
}

- (void)updatePlaybackSpeedTitle:(NSString *)title {
    self.speedChangeButton.enabled = YES;
    [self.speedChangeButton setTitle:title forState:UIControlStateNormal];
    BOOL isDefaultTitle = [title isEqualToString:@"倍速"];
    UIColor *color = isDefaultTitle ? [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] : [UIColor redColor];
    [self.speedChangeButton setTitleColor:color forState:UIControlStateNormal];
    UIEdgeInsets insets = isDefaultTitle ? UIEdgeInsetsZero : UIEdgeInsetsMake(3, 0, 0, 0);
    [self.speedChangeButton setTitleEdgeInsets:insets];
}

- (void)resetPlaybackSpeedTitle {
    self.speedChangeButton.enabled = YES;
    [self.speedChangeButton setTitle:@"倍速" forState:UIControlStateNormal];
    [self.speedChangeButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.speedChangeButton setTitleEdgeInsets:UIEdgeInsetsZero];
}

- (void)dismissFloatSelectView {
    [self.playbackSpeedView dismiss];
    [self.currentIndicatorView hideAnimated:NO];
//    [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_ShowControlView info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];
    [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SpeedSelectViewShowed info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];

}

- (void)showFloatSelectView {
    [self.playbackSpeedView setCurrentSpeed:[self state].speedState.speed];
    [self.playbackSpeedView showInView:self.player.controlOverlayView];
//    [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_ShowControlView info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];
    [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SpeedSelectViewShowed info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];
}

@end
