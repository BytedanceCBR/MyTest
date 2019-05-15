//
//  TTVNetworkMonitorPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/12.
//

#import "TTVNetworkMonitorSimplePart.h"
#import "TTVNetFlowTipView.h"
#import "UIImage+TTVHelper.h"
#import "TTVIndicatorView.h"
#import "TTVPlayer.h"
#import "TTVPlayer+Engine.h"
#import "TTVNetworkMonitorReducer.h"

static BOOL _currentMovieHasTouchedContinue = NO;


@interface TTVNetworkMonitorSimplePart ()

@property (nonatomic, copy)   NSString * cellularNetworkText;

@end

@implementation TTVNetworkMonitorSimplePart

@synthesize playerStore, player, controlViewFactory;

#pragma mark - TTVReduxStateObserver
- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    if (newState.networkState.pausingBycellularNetwork != lastState.networkState.pausingBycellularNetwork) {
        if (newState.networkState.pausingBycellularNetwork) {
            NSString *tipText = self.cellularNetworkText;
            
            if ([tipText containsString:@"%"]) {
                CGFloat videoSize = [self.player videoSizeForType:self.player.currentResolution] / 1024.f / 1024.f;
                tipText = [NSString stringWithFormat:self.cellularNetworkText, videoSize];
            }
            [self addFreeFlowTipViewWithTipText:tipText];
        }
        else {
            [self removeFreeTipView];
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
    [self.player.playerStore setSubReducer:[[TTVNetworkMonitorReducer alloc] initWithPlayer:self.player] forKey:@"TTVNetworkMonitorReducer"];
}

- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    
}
- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_FlowTipView) {
        return self.freeFlowTipView;
    }
    return nil;
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_NetworkMonitor;
}
- (void)removeAllControlView {
    [self.freeFlowTipView removeFromSuperview];
}
#pragma mark - function
- (BOOL)_shouldResumeCurrentPlayer {
    if (TTVPlaybackState_Paused != [self state].playbackState) {
        return NO;
    }
    
    if (!self.player.view.superview) {
        return NO;
    }
    
    return YES;
}

- (void)addFreeFlowTipViewWithTipText:(NSString *)tipText {
    if (!self.freeFlowTipView.superview) {
        [self.player addViewOverlayPlaybackControls:self.freeFlowTipView];
        self.freeFlowTipView.frame = self.player.containerView.bounds;
    }
    [self.freeFlowTipView setTipLabelText:tipText];
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_CellularNetTipViewShowed info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];
}

- (void)removeFreeTipView {
    [self.freeFlowTipView removeFromSuperview];
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_CellularNetTipViewShowed info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];
}

#pragma mark - getter & setter
- (UIView <TTVFlowTipViewProtocol> *)freeFlowTipView {
    if (!_freeFlowTipView) {
        _freeFlowTipView = [self.controlViewFactory createCellularNetTipView];
        @weakify(self);
        
        if ([_freeFlowTipView respondsToSelector:@selector(setContinuePlayBlock:)]) {
            
            _freeFlowTipView.continuePlayBlock = ^{
                @strongify(self);
                _currentMovieHasTouchedContinue = NO;
                [self.player play];
            };
        }
        
        if ([_freeFlowTipView respondsToSelector:@selector(setQuitBlock:)]) {
            _freeFlowTipView.quitBlock = ^{
                [TTVPlayerUtility quitCurrentViewController];
            };
        }
    }
    return _freeFlowTipView;
}

- (NSString *)cellularNetworkText {
    if (isEmptyString(_cellularNetworkText)) {
        _cellularNetworkText = @"正在使用非WiFi网络\n「继续播放」将消耗%.2fMB流量";
    }
    return _cellularNetworkText;
}

@end
