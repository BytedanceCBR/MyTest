//
//  TTVGesturePart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/4.
//

#import "TTVGesturePart.h"
#import "TTVPlayer.h"
#import "TTVGestureReducer.h"
#import "TTVPlayer+Engine.h"

@interface TTVGesturePart ()

@property (nonatomic, strong) TTVPlayerGestureManager * gestureVC;

@end

@implementation TTVGesturePart

@synthesize playerStore, player, customBundle, playerAction;

- (void)attachGestureVC {
    /// 是否需要把 action 写入 gesture 中
    // gesture
    if (_gestureVC) {
        return;
    }
    _gestureVC = [[TTVPlayerGestureManager alloc] initWithPlayerControlView:self.player.containerView];
    
    @weakify(self);
    _gestureVC.singleTapClick = ^{
        @strongify(self);
        // 发单击的 action
        [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_SingleTap]];
    };
    
    _gestureVC.doubleTapClick = ^{
        @strongify(self);
        // 否则会出现识别单击手势引起的闪烁
        if ([self state].gestureState.doubleTapEnabled) {
            // 发送双击的 action
            [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_DoubleTap]];
            
            // 发送暂停或者取消的action, 需要有外界控制此段代码是否执行？？？？？TODO
            if ([self state].playbackState != TTVPlaybackState_Playing) {
                [self.player play];
            }
            else {
                [self.player pause];
            }
        }
    };
    
    // 滑动
    _gestureVC.pan = ^(UIPanGestureRecognizer * gestureRecogizer, UIView * viewAddedPanGesture,TTVPlayerPanGestureDirection direction, BOOL isSwiped) {
        @strongify(self);
        
        /// pan 事件
        [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_Pan info:@{TTVPlayerActionInfo_Pan_Direction:@(direction),
                                                                                                 TTVPlayerActionInfo_Pan_GestureRecogizer:gestureRecogizer,
                                                                                                 TTVPlayerActionInfo_Pan_ViewAddedPanGesture:viewAddedPanGesture,
                                                                                                 TTVPlayerActionInfo_IsSwiped:@(isSwiped)}]];
    };
}

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    [self.gestureVC enablePanGestures:newState.gestureState.panGestureEnabled];
    [self.gestureVC enableDoubleTapGesture:newState.gestureState.doubleTapEnabled];
    [self.gestureVC enableSingleTapGesture:newState.gestureState.singleTapEnabled];
    self.gestureVC.supportedPanDirection = newState.gestureState.supportPanDirection;
    
    // 当 playErrorView Show 出来，不能支持任何手势
    if (newState.finishViewState.playerErrorViewShowed != lastState.finishViewState.playerErrorViewShowed) {
        if (newState.finishViewState.playerErrorViewShowed) {
            [self.playerStore dispatch:[self.playerAction enableGesture:TTVPlayerGestureOn_None mergeWithSetting:NO]];
        }
        else {
            [self.playerStore dispatch:[self.playerAction enableGesture:TTVPlayerGestureOn_All mergeWithSetting:YES]];
        }
    }
    
    // 当 netTip show出来，不能支持任何手势
    if (newState.networkState.flowTipViewShowed != lastState.networkState.flowTipViewShowed) {
        if (newState.networkState.flowTipViewShowed) {
            [self.playerStore dispatch:[self.playerAction enableGesture:TTVPlayerGestureOn_None mergeWithSetting:NO]];
        }
        else {
            [self.playerStore dispatch:[self.playerAction enableGesture:TTVPlayerGestureOn_All mergeWithSetting:YES]];
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
    [self attachGestureVC];
    [self.gestureVC _buildGestures];
    
    TTVGestureReducer * reducer = [[TTVGestureReducer alloc] initWithPlayer:self.player];
    [self.playerStore setSubReducer:reducer forKey:NSStringFromClass(reducer.class)];
}

- (void)unsubcribedStoreSuccess:(TTVReduxStore *)store {
    [self.gestureVC removeAllGesture];
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}
#pragma mark - TTVPlayerPartProtocol
- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Gesture;
}



@end
