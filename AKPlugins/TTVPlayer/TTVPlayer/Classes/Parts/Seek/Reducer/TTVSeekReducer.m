//
//  TTVPlayerGestureReducer.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/29.
//

#import "TTVSeekReducer.h"
#import "TTVPlayerState.h"
#import "TTVPlayerGestureManager.h"
#import "TTVPlayerControlViewState.h"
#import "TTVPlayer.h"
#import "TTVSeekStatePrivate.h"
#import "TTVPlayer+Engine.h"

#define kCancelThreshold 40

@interface TTVSeekReducer () {
    CGFloat _startTime;
    CGPoint _lastTranslation;
}

@property (nonatomic) CGFloat fromProgress; // 只是为了记录， 不能用于计算
@property (nonatomic) CGFloat toProgress;
@property (nonatomic, weak) TTVPlayer * player;
@end

@implementation TTVSeekReducer

- (instancetype)initWithPlayer:(TTVPlayer *)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)action
                                 state:(TTVPlayerState *)state {
    
    // 已经识别为pan 手势
    if ([action.type isEqualToString:TTVPlayerActionType_Pan]) {
        state.seekStatus.panningOutOfSlider = YES; // 只要是接收到这个手势
        
        if (!state.readyForDisplay && state.playbackTime.currentPlaybackTime == 0) {
            return state;
        }
        
        // action.info
        UIPanGestureRecognizer * gestureRecognizer = action.info[TTVPlayerActionInfo_Pan_GestureRecogizer];
        UIView * controlView = action.info[TTVPlayerActionInfo_Pan_ViewAddedPanGesture];
        TTVPlayerPanGestureDirection panDirection = [action.info[TTVPlayerActionInfo_Pan_Direction] integerValue];
        CGPoint translation = [gestureRecognizer translationInView:controlView];

        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan: {
                /// 设置状态
                TTVPanSeekInfo info = state.seekStatus.panSeekingOutOfSliderInfo;
                info.gestureState = gestureRecognizer.state;
                state.seekStatus.panSeekingOutOfSliderInfo = info;
             
                // 解决进度条会往前走一段的 bug
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self->_startTime = state.playbackTime.currentPlaybackTime;
                    self.fromProgress = state.playbackTime.progress;
                });
                }
                break;
            case UIGestureRecognizerStateChanged: {

                TTVPanSeekInfo info = state.seekStatus.panSeekingOutOfSliderInfo;
                info.gestureState = gestureRecognizer.state;
                info.fromProgress = self.fromProgress;

                if (panDirection == TTVPlayerPanGestureDirection_Horizontal) {

                    // 计算 ToProgress
                    CGFloat threshold = 10 * 60;//10min
                    CGFloat maxSeekingTime = state.playbackTime.duration <= threshold ? state.playbackTime.duration : (state.playbackTime.duration - threshold) * .2f + threshold;
                    CGFloat validWidth = (controlView.width - kCancelThreshold * 2) * 0.8;
                    CGFloat normalizedX = translation.x / validWidth * maxSeekingTime;
                    CGFloat progress = (_startTime + normalizedX) / state.playbackTime.duration;
                    progress = MIN(1, MAX(0, progress));

                    info.progress = progress;
                    self.toProgress = progress;
                    
                    if (translation.x > _lastTranslation.x) {
                        info.isMovingForward = YES;
                        
                    } else if (translation.x < _lastTranslation.x) {
                        info.isMovingForward = NO;
                    }

                    // 计算是否超过区域
                    info.isCancelledOutArea = [self _panInCancelArea:gestureRecognizer viewAddedToGesture:controlView];                    
                    _lastTranslation = translation;

                }
                else {
                    state.seekStatus.panningOutOfSlider = NO;
                }
                state.seekStatus.panSeekingOutOfSliderInfo = info;
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                TTVPanSeekInfo info = state.seekStatus.panSeekingOutOfSliderInfo;
                info.gestureState = gestureRecognizer.state;
                info.fromProgress = self.fromProgress;

                /// 如果识别为 swipe 手势
                if ([action.info[TTVPlayerActionInfo_IsSwiped] boolValue]) {
                    CGPoint velocity = [gestureRecognizer velocityInView:controlView];
                    
                    info.isSwipeGesture = YES;
                    
                    if (fabs(velocity.x) > fabs(velocity.y) && fabs(velocity.x) > 500) {
                        CGFloat progress = .0f;
                        if (velocity.x > 0) {
                            progress = MIN(1.f, (state.playbackTime.currentPlaybackTime + 10.f) / state.playbackTime.duration);
                            info.progress = progress;
                            info.isMovingForward = YES;
                        } else if (velocity.x < 0) {

                            progress = MAX(0, (state.playbackTime.currentPlaybackTime - 10.f) / state.playbackTime.duration);
                            info.progress = progress;
                            info.isMovingForward = NO;
                        }
                        NSTimeInterval currentPlaybackTime = self.player.playbackTime.duration * progress;
                        [self.player setCurrentPlaybackTime:currentPlaybackTime complete:nil];
                    }
                    else {
                        info.isCancelledOutArea = YES;
                    }
                }
                else {
                    BOOL isCancelledOutArea = [self _panInCancelArea:gestureRecognizer viewAddedToGesture:controlView];
                    
                    if (panDirection == TTVPlayerPanGestureDirection_Horizontal) {
                        TTVPanSeekInfo info = state.seekStatus.panSeekingOutOfSliderInfo;
                        info.progress = self.toProgress;
                        info.isCancelledOutArea = isCancelledOutArea;
                        state.seekStatus.panSeekingOutOfSliderInfo = info;
                        
                        if (!isCancelledOutArea) {
                            NSTimeInterval currentPlaybackTime = self.player.playbackTime.duration * self.toProgress;
                            [self.player setCurrentPlaybackTime:currentPlaybackTime complete:nil];
                        }
                    }
                }
               
                state.seekStatus.panningOutOfSlider = NO;
                state.seekStatus.panSeekingOutOfSliderInfo = info;
            }
                break;
            default: {
                state.seekStatus.panningOutOfSlider = NO;

                TTVPanSeekInfo info = state.seekStatus.panSeekingOutOfSliderInfo;
                info.gestureState = gestureRecognizer.state;
                state.seekStatus.panSeekingOutOfSliderInfo = info;
            }
                break;
        }
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_SliderPan]) {
        BOOL isPanning = [action.info[TTVPlayerActionInfo_isSliderPanning] boolValue];
        state.seekStatus.sliderPanning = isPanning;
    }
    else if ([action.type isEqualToString:TTVPlayerActionType_SliderHudShowed]) {
        // 如果真的有 seekView
        BOOL showed = [action.info[TTVPlayerActionInfo_isShowed] boolValue];
        if (showed/* && [self.player partControlForKey:TTVPlayerPartControlKey_SeekingHUD]*/) {
            state.seekStatus.hudShowed = YES;
        }
        else {
            state.seekStatus.hudShowed = NO;
        }
    }

    return state;
}

- (BOOL)_panInCancelArea:(UIPanGestureRecognizer *)panGesture viewAddedToGesture:(UIView *)controlView {
    CGPoint location = [panGesture locationInView:controlView];
    CGFloat leftArea = kCancelThreshold;
    CGFloat rightArea = controlView.width - kCancelThreshold;
    if (location.x < leftArea || location.x > rightArea) {
        return YES;
    }
    return NO;
}

@end
