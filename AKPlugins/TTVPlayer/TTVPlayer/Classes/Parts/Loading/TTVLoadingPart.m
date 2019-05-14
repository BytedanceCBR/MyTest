//
//  TTVLoadingPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/11.
//

#import "TTVLoadingPart.h"
#import "TTVLPlayerLoadingView.h"
#import "TTVPlayer.h"
#import "TTVLoadingReducer.h"

@interface TTVLoadingPart ()
@property (nonatomic, strong) UIView <TTVPlayerLoadingViewProtocol> *loadingView;

@end

@implementation TTVLoadingPart

@synthesize playerStore, player, controlViewFactory;

#pragma mark - TTVReduxStateObserver

- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(TTVReduxStore *)store {
    if (newState.loadingViewState.shouldShow != lastState.loadingViewState.shouldShow) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startLoading) object:nil];
        if (newState.loadingViewState.shouldShow) {
            [self performSelector:@selector(startLoading) withObject:nil afterDelay:1];
        }
        else {
            [self stopLoading];
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
}

- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startLoading) object:nil];
    [self stopLoading];
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

- (void)startLoading {
    if (!self.loadingView.superview) {
        [self.player addViewOverlayPlaybackControls:self.loadingView];
    }
    [self.loadingView startLoading];
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_LoadingShowed info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];
}

- (void)stopLoading {
    [self.loadingView stopLoading];
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_LoadingShowed info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];
}

#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_LoadingView) {
        return self.loadingView;
    }
    return nil;
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_Loading;
}

- (void)removeAllControlView {
    [self.loadingView removeFromSuperview];
}

#pragma mark - getter & setter
- (UIView<TTVPlayerLoadingViewProtocol>*)loadingView {
    if (!_loadingView) {
        _loadingView = [self.controlViewFactory createLoadingView];
    }
    return _loadingView;
}

@end
