//
//  TTVPlayerSpeedManager.m
//  TTVPlayer
//
//  Created by lisa on 2018/12/26.
//

#import "TTVPlayerSpeedPart.h"
#import "TTVPlayer.h"
#import "TTPlayerPlaybackSpeedView.h" // 弹层选择 view
#import "TTVPlayerSpeedState.h"
#import "TTVIndicatorView.h"

// TODO 全屏时待添加，tracker，error，提示
@interface TTVPlayerSpeedPart ()

@property (nonatomic, strong) UIButton * speedChangeButton; // 倍速播放按钮
@property (nonatomic, strong) TTPlayerPlaybackSpeedView *playbackSpeedView; // 弹层
@property (nonatomic, strong) TTVIndicatorView * currentIndicatorView;      // 当前展示的


@end

@implementation TTVPlayerSpeedPart
@synthesize playerStore, player;

#pragma mark - TTVReduxStateObserver

- (void)newState:(TTVRPlayerState *)state store:(TTVReduxStore *)store {
    
    if (self.player.playbackSpeed == state.speedState.currentSpeed) {
        return;
    }
    
    // player 的倍速修改, 这里其实修改了数据，并非展示 todo？
    self.player.playbackSpeed = state.speedState.currentSpeed;
    
    // 更新 button UI
    [self updatePlaybackSpeedTitle:[self.playbackSpeedView titleForPlaybackSpeed:state.speedState.currentSpeed]];
    
    // 展示提示
    NSString *content = [NSString stringWithFormat:@"已为您开启%@播放", [self.playbackSpeedView tipForPlaybackSpeed:state.speedState.currentSpeed]];
    
    [self.currentIndicatorView hideAnimated:NO];
    TTVIndicatorView *indicator =  [TTVIndicatorView showIndicatorAddedToView:self.player.controlView text:content image:nil];
    indicator.stayDuration = 3.0f;
    self.currentIndicatorView = indicator;
    
    // tracker 是干啥的
//    [self.playerViewController.tracker sendPlaybackSpeedSelectTrack:speed];

    
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
    // add bottom to player, 全屏时才有
    [self.player.controlView.containerView.bottomView.fullScreenRightContainerView addView:self.speedChangeButton];

}

#pragma mark - UI
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

#pragma mark - action
- (void)speedChangeButtonClicked:(UIButton *)button {
    // show
    if (self.playbackSpeedView.isShowing) {
        [self.playbackSpeedView dismiss];
        [self.currentIndicatorView hideAnimated:NO];
        
    } else {
//        self.showing = NO;
        [self.playbackSpeedView setCurrentSpeed:((TTVRPlayerState *)playerStore.state).speedState.currentSpeed];
        [self.playbackSpeedView showInView:self.player.controlView]; // ????
                                            }
}

#pragma mark - getters & setters
- (UIButton *)speedChangeButton {
    if (!_speedChangeButton) {
        _speedChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _speedChangeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -7);
        [_speedChangeButton setTitle:@"倍速" forState:UIControlStateNormal];
        _speedChangeButton.titleLabel.font = [TTVPlayerUtility tt_semiboldFontOfSize:17];
        [_speedChangeButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_speedChangeButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:0.5f] forState:UIControlStateDisabled];
        [_speedChangeButton addTarget:self action:@selector(speedChangeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedChangeButton;
}

- (TTPlayerPlaybackSpeedView *)playbackSpeedView {
    if (!_playbackSpeedView) {
        _playbackSpeedView = [[TTPlayerPlaybackSpeedView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _playbackSpeedView.didPlaybackSpeedChanged = ^(CGFloat playbackSpeed) {
            // action
            @strongify(self);
            [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_ChangeSpeed info:@{TTVPlayerActionInfo_Speed:@(playbackSpeed)}]];
            
        };
    }
    return _playbackSpeedView;
}


@end
