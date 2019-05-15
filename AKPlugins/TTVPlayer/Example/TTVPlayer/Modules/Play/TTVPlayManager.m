//
//  TTVPlayManager.m
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import "TTVPlayManager.h"
#import "TTVPlayerState.h"
#import "TTVPlayerStatePlayPrivate.h"
#import "UIView+TTVViewKey.h"
#import "UIView+TTVPlayerSortPriority.h"
#import <Lottie/Lottie.h>
#import <ReactiveObjC/ReactiveObjC.h>

static void *TTVPlayManagerPlayButtonAnimatedBlockKey = &TTVPlayManagerPlayButtonAnimatedBlockKey;

@interface TTVPlayManager ()
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *playNextButton;
@property (nonatomic, strong) UIButton *playPreviousButton;

@property (nonatomic, strong) UIButton *fullPlayButton;
@property (nonatomic, strong) UIButton *fullPlayNextButton;
@property (nonatomic, strong) UIButton *fullPlayPreviousButton;

@property (nonatomic, strong) RACSubject *clickedNextButtonSubject;
@property (nonatomic, strong) RACSubject *clickedPreviousButtonSubject;
@property (nonatomic, strong) RACDisposable *isFullscreenObserver;
@end

@implementation TTVPlayManager
@synthesize store = _store;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVGestureManagerActionTypeDoubleTapClick]) {
                [self playButtonClicked:nil];
            }else if ([action.type isEqualToString:TTVPlayerActionTypeVideoEngineDidFinish] ||
                 [action.type isEqualToString:TTVPlayerActionTypeVideoEngineUserStopped]) {
                self.store.state.play.showPlayButton = YES;
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeProgressViewShow]) {
                [self progressViewShow:[action.info[@"show"] boolValue]];
            } else if ([action.type isEqualToString:TTVPlayerActionType_PlaybackStateDidChanged]) {
//                self.store.state.play.showPlayButton = [action.info[@"playbackState"] integerValue] != TTVideoEnginePlaybackStatePlaying;
            }
        }];        
        self.fullPlayButton.ttvPlayerSortContainerPriority = 1;
        self.fullPlayPreviousButton.ttvPlayerSortContainerPriority = 0;
        self.fullPlayNextButton.ttvPlayerSortContainerPriority = 2;
        self.fullPlayButton.ttvPlayerLayoutViewKey = TTVPlayerStatePlay_fullPlayButton;
        self.fullPlayPreviousButton.ttvPlayerLayoutViewKey = TTVPlayerStatePlay_fullPlayPreviousButton;
        self.fullPlayNextButton.ttvPlayerLayoutViewKey = TTVPlayerStatePlay_fullPlayNextButton;
        if (self.fullPlayButton) {
            [self.store.player.controlView.containerView.bottomView.fullScreenLeftContainerView addView:self.fullPlayButton];
        }
        if (self.fullPlayNextButton) {
            [self.store.player.controlView.containerView.bottomView.fullScreenLeftContainerView addView:self.fullPlayNextButton];
        }
        if (self.fullPlayPreviousButton) {
            [self.store.player.controlView.containerView.bottomView.fullScreenLeftContainerView addView:self.fullPlayPreviousButton];
        }
        if (self.playButton) {
            [self.store.player.controlView.containerView addSubview:self.playButton];
            [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(self.store.player.controlView.containerView);
            }];
        }

        [self ttv_observePlayStatus];
    }
}

- (void)setIsIndetail:(BOOL)isIndetail
{
    self.store.state.play.isIndetail = isIndetail;
}

- (void)ttv_observePlayStatus {
    @weakify(self);
    //play 状态变化时，更新icon
    [RACObserve(self.store.state.play, showPlayButton).distinctUntilChanged subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self);
        [self.fullPlayButton setImage:[UIImage imageNamed:self.store.state.play.showPlayButton ? @"player_play" : @"player_pause"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:self.store.state.play.showPlayButton ? @"player_play_list" : @"player_pause_list"] forState:UIControlStateNormal];
        [self.playButton sizeToFit];
        [self.fullPlayButton sizeToFit];
    }];
}

#pragma mark - Set & Get

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        @weakify(self);
        void (^animatedBlock)(BOOL) = ^(BOOL pause) {
            @strongify(self);
            LOTAnimationView *animation = [LOTAnimationView animationNamed:pause ? @"play_to_pause_list.json" : @"pause_to_play_list.json"];
            animation.userInteractionEnabled = NO;
            animation.size = CGSizeMake(animation.size.width / 3.f, animation.size.height / 3.f);
            animation.loopAnimation = NO;
            [self.playButton addSubview:animation];
            self.playButton.imageView.transform = CGAffineTransformMakeScale(0, 0);
            __weak __typeof(animation) weakAnimation = animation;
            [animation playWithCompletion:^(BOOL animationFinished) {
                @strongify(self);
                [weakAnimation removeFromSuperview];
                self.playButton.imageView.transform = CGAffineTransformIdentity;
            }];
        };
        objc_setAssociatedObject(_playButton, TTVPlayManagerPlayButtonAnimatedBlockKey, animatedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return _playButton;
}

- (UIButton *)fullPlayButton {
    if (!_fullPlayButton) {
        _fullPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullPlayButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        @weakify(self);
        void (^animatedBlock)(BOOL) = ^(BOOL pause) {
            @strongify(self);
            LOTAnimationView *animation = [LOTAnimationView animationNamed:pause ? @"play_to_pause.json" : @"pause_to_play.json"];
            animation.userInteractionEnabled = NO;
            animation.size = CGSizeMake(animation.size.width / 3.f, animation.size.height / 3.f);
            animation.loopAnimation = NO;
            [self.fullPlayButton addSubview:animation];
            self.fullPlayButton.imageView.transform = CGAffineTransformMakeScale(0, 0);
            
            __weak __typeof(animation) weakAnimation = animation;
            [animation playWithCompletion:^(BOOL animationFinished) {
                @strongify(self);
                [weakAnimation removeFromSuperview];
                self.fullPlayButton.imageView.transform = CGAffineTransformIdentity;
            }];
        };
        objc_setAssociatedObject(_fullPlayButton, TTVPlayManagerPlayButtonAnimatedBlockKey, animatedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return _fullPlayButton;
}

- (UIButton *)playNextButton {
    if (!_playNextButton) {
        _playNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playNextButton setImage:[UIImage imageNamed:@"player_next"] forState:UIControlStateNormal];
        @weakify(self);
        [[_playNextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.clickedNextButtonSubject sendNext:x];
        }];
    }
    return _playNextButton;
}

- (UIButton *)fullPlayNextButton {
    if (!_fullPlayNextButton) {
        _fullPlayNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullPlayNextButton setImage:[UIImage imageNamed:@"player_next"] forState:UIControlStateNormal];
        @weakify(self);
        [[_fullPlayNextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.clickedNextButtonSubject sendNext:x];
        }];
    }
    return _fullPlayNextButton;
}

- (UIButton *)playPreviousButton {
    if (!_playPreviousButton) {
        _playPreviousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPreviousButton setImage:[UIImage imageNamed:@"player_last"] forState:UIControlStateNormal];
        @weakify(self);
        [[_playPreviousButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.clickedPreviousButtonSubject sendNext:x];
        }];
    }
    return _playPreviousButton;
}

- (UIButton *)fullPlayPreviousButton {
    if (!_fullPlayPreviousButton) {
        _fullPlayPreviousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullPlayPreviousButton setImage:[UIImage imageNamed:@"player_last"] forState:UIControlStateNormal];
        @weakify(self);
        [[_fullPlayPreviousButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self.clickedPreviousButtonSubject sendNext:x];
        }];
    }
    return _fullPlayPreviousButton;
}

- (RACSubject *)clickedNextButtonSubject {
    if (!_clickedNextButtonSubject) {
        _clickedNextButtonSubject = [RACSubject subject];
        self.store.state.play.clickedPlayNextButtonSignal = _clickedNextButtonSubject;
    }
    return _clickedNextButtonSubject;
}

- (RACSubject *)clickedPreviousButtonSubject {
    if (!_clickedPreviousButtonSubject) {
        _clickedPreviousButtonSubject = [RACSubject subject];
        self.store.state.play.clickedPlayPreviousButtonSignal = _clickedPreviousButtonSubject;
    }
    return _clickedPreviousButtonSubject;
}
- (void)progressViewShow:(BOOL)show
{
    if (show) {
        [self setPlayControlsDisabled:YES location:TTVPlayerControlsCanDisableLocation_CenterPlay];
    } else {
        [self setPlayControlsDisabled:NO location:TTVPlayerControlsCanDisableLocation_CenterPlay];
    }
}

- (void)setPlayControlsDisabled:(BOOL)disabled location:(TTVPlayerControlsCanDisableLocation)location;
{
    self.store.state.play.playControlsDisabled = disabled;
    self.store.state.play.location = location;
    if ((location & TTVPlayerControlsCanDisableLocation_CenterPlay)) {
        [UIView animateWithDuration:disabled ? .0f : .3f animations:^{
            self.playButton.alpha = disabled ? 0 : 1;
        } completion:^(BOOL finished) {
            self.playButton.hidden = disabled || self.store.state.fullScreen.isFullScreen;
        }];
    }
}

- (void)playButtonClicked:(UIButton *)sender {
    self.store.state.play.showPlayButton = !self.store.state.play.showPlayButton;
    self.store.state.play.changePlayStatusByTapWidget = YES;
    NSUInteger playerChangeStatus = 0;
    NSArray *playerChangeStatusArray = @[
                                         @(TTVPlayTriggerActionTypePlayerDoubleClick),//小屏双击 0b00
                                         @(TTVPlayTriggerActionTypePlayerButton),//小屏点击按钮 0b01
                                         @(TTVPlayTriggerActionTypeFullPlayerDoubleClick),//全屏双击 0b10
                                         @(TTVPlayTriggerActionTypeFullPlayerButton)//全屏点按钮 0b11
                                         ];
    playerChangeStatus |= sender != nil ? 0b01 : playerChangeStatus;
    playerChangeStatus |= self.store.state.fullScreen.isFullScreen ? 0b10 : playerChangeStatus;
    playerChangeStatus = MIN([playerChangeStatusArray count] - 1, MAX(0, playerChangeStatus));
    self.store.state.play.triggerActionType = [playerChangeStatusArray[playerChangeStatus] integerValue];
    if (self.store.state.play.showPlayButton) {
        [self.store.player pause];
    } else {
        [self.store.player play];
    }
    
    if (sender) {
        void (^animatedBlock)(BOOL) = objc_getAssociatedObject(sender, TTVPlayManagerPlayButtonAnimatedBlockKey);
        if (animatedBlock) {
            animatedBlock(self.store.state.play.showPlayButton);
        }
    }
}

- (void)insertBackgoundViewBeforePlayingWithView:(UIView *)view {
    if (view && self.store.player.controlView.controlsOverlayView) {
        [self.store.player.controlView.controlsOverlayView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.store.player.controlView.controlsOverlayView);
        }];
        [RACObserve(self.store.player, readyForRender) subscribeNext:^(NSNumber *readyToPlay) {
            if ([readyToPlay boolValue]) {
                [UIView animateWithDuration:0.1 animations:^{
                    view.alpha = 0;
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                }];
            }
        }];
    }
}

@end

@implementation TTVPlayer (TTVPlayManager)

- (TTVPlayManager *)playManager
{
    return nil;

//    return [self partManagerFromClass:[TTVPlayManager class]];
}

@end
