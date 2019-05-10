//
//  TTVSeekPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/17.
//

#import "TTVSeekPart.h"
#import "TTVPlayer.h"
#import <CoreText/CoreText.h>
#import "UIImage+TTVHelper.h"
#import "TTVSeekReducer.h"
#import "TTVPlayer+Engine.h"

@interface TTVSeekPart ()

@property (nonatomic) NSTimeInterval duration; // 用户展示 label
@property (nonatomic) BOOL isSliderPanning;

@end

@implementation TTVSeekPart

@synthesize playerStore, player, customBundle;

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    if (self.player.enableNoPlaybackStatus && self.immersiveSlider.superview != self.player.containerView.playbackControlView.immersiveContentView) {
        [self.player.containerView.playbackControlView.immersiveContentView addSubview:self.immersiveSlider];
        [self.player.containerView setNeedsLayout];
    }
    // 处理沉浸态的进度条
    if (newState.controlViewState.isShowed != lastState.controlViewState.isShowed) {
        // 沉浸态到来，full 下加入到锁屏下，非 full 下加入到正常下
        if (!newState.controlViewState.isShowed) {
            if (newState.fullScreenState.isFullScreen) {
                if (self.immersiveSlider.superview != self.player.containerView.playbackControlView_Lock.immersiveContentView) {
                    [self.player.containerView.playbackControlView_Lock.immersiveContentView addSubview:self.immersiveSlider];
                    [self.player.containerView setNeedsLayout];
//                    [self viewDidLayoutSubviews:self.player];
                }
            }
            else {
                if (!newState.controlViewState.isLocked) {
                    if (self.immersiveSlider.superview != self.player.containerView.playbackControlView.immersiveContentView) {
                        [self.player.containerView.playbackControlView.immersiveContentView addSubview:self.immersiveSlider];
                        [self.player.containerView setNeedsLayout];
//                        [self viewDidLayoutSubviews:self.player];
                    }
                }
                else {
                    if (self.immersiveSlider.superview != self.player.containerView.playbackControlView_Lock.immersiveContentView) {
                        [self.player.containerView.playbackControlView_Lock.immersiveContentView addSubview:self.immersiveSlider];
                        [self.player.containerView setNeedsLayout];
//                        [self viewDidLayoutSubviews:self.player];
                    }
                }
            }
        }
    }
    
    // hud 的展示与消失, 在进图条以外的区域 panning 需要这里操作
    if (newState.seekStatus.isPanningOutOfSlider != lastState.seekStatus.isPanningOutOfSlider) {
        if (!newState.seekStatus.isPanningOutOfSlider) {
            [self hudDismiss];
        }
        else {
            if ((newState.readyForDisplay && newState.playbackTime.currentPlaybackTime > 0) ||
                (newState.playbackTime.currentPlaybackTime == newState.playbackTime.duration && newState.finishStatus != nil)) {
                [self hudShow];
            }
        }
    }
    // hud 在切换时，需要隐藏自身
    if (newState.fullScreenState.isFullScreen != lastState.fullScreenState.isFullScreen) {
        [self hudDismiss];
    }

    //
    if (newState.readyForDisplay != lastState.readyForDisplay) {
        if (newState.readyForDisplay) {
            @weakify(self);
            _slider.userInteractionEnabled = YES;
        }
        else {
            // 说明结束了，需要将 sliderpanning 设置为 NO
            
            self.slider.userInteractionEnabled = self.player.supportSeekAfterPlayerFinish?YES:NO;
        }
    }
    
    // 如果没有拖动事件和 seeking，那就正常更新 progress 和 cachedProgress
    if (!newState.seekStatus.isSliderPanning && !newState.seekStatus.isPanningOutOfSlider && !newState.isSeeking) { // 同步内核的进度
        if (newState.readyForDisplay) {
            Debug_NSLog(@"isSeeking++++++ = %d,%f", newState.readyForDisplay, newState.playbackTime.progress);
            [self.immersiveSlider setProgress:newState.playbackTime.progress animated:NO];
            [self.immersiveSlider setCacheProgress:newState.playbackTime.cachedProgress animated:NO];
            [self.slider setProgress:newState.playbackTime.progress animated:NO];
            [self.slider setCacheProgress:newState.playbackTime.cachedProgress animated:NO];
            [self.hud setProgress:newState.playbackTime.progress animated:NO];
//            [self.hud setForward:YES];
            self.hud.totalTime = newState.playbackTime.duration;
            self.duration = newState.playbackTime.duration;
            self.currentTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:newState.playbackTime.progress duration:newState.playbackTime.duration];
            self.totalTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:1 duration:newState.playbackTime.duration];
            [self setCurrentAndTotalTimeWith:newState.playbackTime.progress duration:newState.playbackTime.duration];
        }
    }
    else if (newState.seekStatus.isPanningOutOfSlider && !newState.isSeeking /*&& newState.controlViewState.isPanning*/) {   // 手势滑动中，同步控件的进度
        if (newState.playbackTime.currentPlaybackTime > 0 && newState.readyForDisplay ||
            (newState.playbackTime.currentPlaybackTime == newState.playbackTime.duration && newState.finishStatus != nil && self.player.supportSeekAfterPlayerFinish)) {
            UIGestureRecognizerState gestureState = newState.seekStatus.panSeekingOutOfSliderInfo.gestureState;
            if (gestureState == UIGestureRecognizerStateChanged ) {
                //            Debug_NSLog(@"isSeeking---- = %d,%f", newState.isSeeking,newState.seekStatus.panSeekingOutOfSliderInfo.progress);
                [self.slider setProgress:newState.seekStatus.panSeekingOutOfSliderInfo.progress animated:NO];
                [self.hud setProgress:newState.seekStatus.panSeekingOutOfSliderInfo.progress animated:NO];
//                [self.hud setForward:newState.seekStatus.panSeekingOutOfSliderInfo.isMovingForward];
                self.currentTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:newState.seekStatus.panSeekingOutOfSliderInfo.progress duration:newState.playbackTime.duration];
                self.totalTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:1 duration:newState.playbackTime.duration];
                self.hud.showCancel = newState.seekStatus.panSeekingOutOfSliderInfo.isCancelledOutArea;
                [self setCurrentAndTotalTimeWith:newState.playbackTime.progress duration:newState.playbackTime.duration];
                
                // delegate
                if ([self.player.delegate respondsToSelector:@selector(playerSliderDidProgressSeeking:)]) {
                    [self.player.delegate playerSliderDidProgressSeeking:self.slider];
                }
                
            }
            else if (newState.seekStatus.panSeekingOutOfSliderInfo.isSwipeGesture &&
                     (gestureState == UIGestureRecognizerStateEnded || gestureState == UIGestureRecognizerStateCancelled) ){//// 如果是 swipe
                if (!newState.seekStatus.panSeekingOutOfSliderInfo.isCancelledOutArea) {
                    //                Debug_NSLog(@"isSeeking---- = %d,%f", newState.isSeeking,newState.seekStatus.panSeekingOutOfSliderInfo.progress);
                    [self.slider setProgress:newState.seekStatus.panSeekingOutOfSliderInfo.progress animated:NO];
                    [self.hud setProgress:newState.seekStatus.panSeekingOutOfSliderInfo.progress animated:NO];
//                    [self.hud setForward:newState.seekStatus.panSeekingOutOfSliderInfo.isMovingForward];
                    self.currentTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:newState.seekStatus.panSeekingOutOfSliderInfo.progress duration:newState.playbackTime.duration];
                    self.totalTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:1 duration:newState.playbackTime.duration];
                    [self setCurrentAndTotalTimeWith:newState.playbackTime.progress duration:newState.playbackTime.duration];
                    
                    // delegate
                    if ([self.player.delegate respondsToSelector:@selector(playerSliderDidProgressSeeking:)]) {
                        [self.player.delegate playerSliderDidProgressSeeking:self.slider];
                    }
                }
            }
        }
    }
    
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
}

- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

#pragma mark - TTVPlayerPartProtocol

- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_Slider) {
        return self.slider;
    }
    if (key == TTVPlayerPartControlKey_SeekingHUD) {
        return self.hud;
    }
    if (key == TTVPlayerPartControlKey_TimeTotalLabel) {
        return self.totalTimeLabel;
    }
    if (key == TTVPlayerPartControlKey_TimeCurrentLabel) {
        return self.currentTimeLabel;
    }
    if (key == TTVPlayerPartControlKey_TimeCurrentAndTotalLabel) {
        return self.currentAndTotoalTimeLabel;
    }
    return nil;
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Seek;
}

- (void)setControlView:(UIView *)controlView forKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_TimeCurrentLabel) {
        self.currentTimeLabel = (UILabel *)controlView;
        _currentTimeLabel.text = @"00:00";
        UIFont * font = self.currentTimeLabel.font;
        self.currentTimeLabel.font = [UIFont fontWithDescriptor:self.fontDescriptor size:font.pointSize];
    }
    else if (key == TTVPlayerPartControlKey_TimeTotalLabel) {
        self.totalTimeLabel = (UILabel *)controlView;
        self.totalTimeLabel.text = @"00:00";
        UIFont * font = self.totalTimeLabel.font;
        self.totalTimeLabel.font = [UIFont fontWithDescriptor:self.fontDescriptor size:font.pointSize];
    }
    else if (key == TTVPlayerPartControlKey_TimeCurrentAndTotalLabel) {
        self.currentAndTotoalTimeLabel = (UILabel *)controlView;
        _currentAndTotoalTimeLabel.text = @"00:00 / 00:00";
        UIFont * font = self.currentAndTotoalTimeLabel.font;
        self.currentAndTotoalTimeLabel.font = [UIFont fontWithDescriptor:self.fontDescriptor size:font.pointSize];
    }
    else if (key == TTVPlayerPartControlKey_Slider) {
        self.slider = (UIView<TTVSliderControlProtocol> *)controlView;
        _slider.userInteractionEnabled = NO;

        @weakify(self)
        // 会不会有多次设置的问题 TODO >>>>>>>>>
        _slider.didSeekToProgress = ^(CGFloat progress, CGFloat fromProgress) {
            @strongify(self)
            self.isSliderPanning = NO;
            // 发 action 修改当前播放时间
            [self hudDismiss];
            
            NSTimeInterval currentPlaybackTime = self.player.playbackTime.duration * progress;
            [self.player setCurrentPlaybackTime:currentPlaybackTime complete:nil];
            [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SliderPan info:@{TTVPlayerActionInfo_isSliderPanning:@(NO)}]];
        };
        
        _slider.seekingToProgress = ^(CGFloat progress, BOOL cancel, BOOL end) {
            @strongify(self);
            // 如果 cancel 是 YES，将不会走到 didSeekToProgress 中，需要停止
            if (cancel) {
                self.isSliderPanning = NO;
                [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SliderPan info:@{TTVPlayerActionInfo_isSliderPanning:@(NO)}]];
                return;
            }
            // 如果是 end 会走到didSeekToProgress，不用处理
            if (end) {
                return;
            }
            
            // 避免多次发送一个 action
            if (!self.isSliderPanning) {
                [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SliderPan info:@{TTVPlayerActionInfo_isSliderPanning:@(YES)}]];
                [self hudShow];
            }
            self.isSliderPanning = YES;
            self.currentTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:progress duration:self.duration];
            self.totalTimeLabel.text = [TTVPlayerUtility transformProgressToTimeString:1 duration:self.duration];
            [self setCurrentAndTotalTimeWith:progress duration:self.duration];
            [self.hud setProgress:progress animated:NO];
            
            // delegate
            if ([self.player.delegate respondsToSelector:@selector(playerSliderDidProgressSeeking:)]) {
                [self.player.delegate playerSliderDidProgressSeeking:self.slider];
            }
        };
    }
    else if (key == TTVPlayerPartControlKey_SeekingHUD) {
        self.hud = (UIView<TTVProgressHudOfSliderProtocol> *)controlView;
    }
    else if (key == TTVPlayerPartControlKey_ImmersiveSlider) {
        self.immersiveSlider = (UIView<TTVProgressViewOfSliderProtocol> *)controlView;
    }
}

- (void)removeAllControlView {
    [self.currentTimeLabel removeFromSuperview];
    [self.totalTimeLabel removeFromSuperview];
    [self.currentAndTotoalTimeLabel removeFromSuperview];
    [self.slider removeFromSuperview];
    [self.hud removeFromSuperview];
    [self.immersiveSlider removeFromSuperview];
}
- (void)hudShow {
    if (!self.hud) {
        return;
    }
    if (!self.hud.superview) {
        [self.player addViewOverlayPlaybackControls:self.hud];
    }
    
    if (self.hud.isShowing) {
        return;
    }
    
    self.hud.frame = self.player.containerView.bounds;
    [self.hud showWithCompletion:^(BOOL finished) {
        [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SliderHudShowed info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];
    }];
}

- (void)hudDismiss {
    if (!self.hud) {
        return;
    }
    if (!self.hud.isShowing) {
        return;
    }
    [self.hud dismissWithCompletion:^(BOOL finished) {
        [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_SliderHudShowed info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];
    }];
}

#pragma mark - getter & setter
- (void)setCurrentAndTotalTimeWith:(NSTimeInterval)process duration:(NSTimeInterval)duration {
    [self.player.view setNeedsLayout];
    if (duration <= 0) {
        return;
    }
    NSString * currentString = [TTVPlayerUtility transformProgressToTimeString:process duration:duration];
    NSString * duratitonString = [TTVPlayerUtility transformProgressToTimeString:1 duration:duration];
    self.currentAndTotoalTimeLabel.text = [[currentString stringByAppendingString:@" / "] stringByAppendingString:duratitonString];
}

- (UIFontDescriptor *)fontDescriptor {
    NSArray *monospacedSetting = @[@{UIFontFeatureTypeIdentifierKey :  @(kNumberSpacingType),
                                     UIFontFeatureSelectorIdentifierKey :  @(kMonospacedNumbersSelector)}];
    UIFont *font = [UIFont systemFontOfSize:0];
    UIFontDescriptor *newDescriptor = [[font fontDescriptor] fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute : monospacedSetting}];
    return newDescriptor;
}

- (void)viewDidLayoutSubviews:(TTVPlayer *)playerVC {
    self.immersiveSlider.height = 2;
    self.immersiveSlider.width = playerVC.controlView.width;
    if (self.immersiveSlider.superview == self.player.containerView.playbackControlView_Lock.bottomBar) {
        self.immersiveSlider.top = playerVC.controlView.bottomBar.height - self.immersiveSlider.height;
    }
    else {
        self.immersiveSlider.top = playerVC.containerView.height - self.immersiveSlider.height;
    }
}


@end
