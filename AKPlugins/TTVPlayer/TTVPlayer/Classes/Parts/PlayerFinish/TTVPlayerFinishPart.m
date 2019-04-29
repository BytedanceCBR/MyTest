//
//  TTVTipPart.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/11.
//

#import "TTVPlayerFinishPart.h"
#import "TTVPlayerErrorView.h"
#import "TTVPlayer.h"
#import "TTVPlayer+Engine.h"

@interface TTVPlayerFinishPart ()

@property (nonatomic, strong) UIView <TTVPlayerErrorViewProtocol> *errorView;
@property (nonatomic, copy)   NSString *commonErrorText;

@end

@implementation TTVPlayerFinishPart

@synthesize playerStore, player, controlViewFactory;

#pragma mark - TTVReduxStateObserver
- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    // 展示错误提示
    if (newState.finishViewState.playerErrorViewShouldShow != lastState.finishViewState.playerErrorViewShouldShow) {
        if (newState.finishViewState.playerErrorViewShouldShow) {
            if (newState.finishStatus.playError) { // 有错误，需要展示重试
                [self.errorView setErrorText:self.commonErrorText];
                [self.errorView showRetry:YES];
                [self show];
            }
            else if (newState.finishStatus.sourceErrorStatus != 0) { // 不需要展示重试，视频源出问题
                NSString *text = self.commonErrorText;
                if (newState.finishStatus.sourceErrorStatus == 1002) {//视频被删除
                    text = @"视频已被删除";
                }
                [self.errorView setErrorText:text];
                [self.errorView showRetry:NO];
                [self show];
            }
        }
        else {
            [self dismiss];
        }
    }

    // full screen 布局有问题
    if (lastState.fullScreenState.isFullScreen != newState.fullScreenState.isFullScreen) {
        [self.errorView setNeedsLayout];
    }
    
    // 如果处于非结束状态，但是错误 view 还在, 比如被打断
//    if (!newState.finishStatus && self.errorView.superview) {
//        [self dismiss];
//    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
}

- (void)unsubcribedStoreSuccess:(id<TTVReduxStoreProtocol>)store {
    [self dismiss];
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

- (void)show {

    if (self.errorView.isShowed) {
        [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_PlayerErrorViewShowed info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];
        return;
    }
    if (!self.errorView.superview) {
        [self.player addViewOverlayPlaybackControls:self.errorView];
    }
    [self.errorView show];
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_PlayerErrorViewShowed info:@{TTVPlayerActionInfo_isShowed:@(YES)}]];

}

- (void)dismiss {
    if (!self.errorView.isShowed) {
        [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_PlayerErrorViewShowed info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];
        return;
    }
    [self.errorView dismiss];
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_PlayerErrorViewShowed info:@{TTVPlayerActionInfo_isShowed:@(NO)}]];

}
#pragma mark - TTVPlayerPartProtocol
- (UIView *)viewForKey:(NSUInteger)key {
    if (key == TTVPlayerPartControlKey_PlayerErrorStayView) {
        return self.errorView;
    }
    return nil;
}

- (TTVPlayerPartKey)key {
    return TTVPlayerPartKey_PlayerFinish;
}

- (void)removeAllControlView {
    [self.errorView removeFromSuperview];
}
#pragma mark - getter & setter
- (UIView<TTVPlayerErrorViewProtocol>*)errorView {
    if (!_errorView) {
        _errorView = [self.controlViewFactory createPlayerErrorFinishView];
        @weakify(self);
        _errorView.didClickRetry = ^{
            @strongify(self);
            // 点击重试相当于重新请求，但是这里不根据内核来合适么？
            TTVPlayerAction * action = [[TTVPlayerAction alloc] initWithPlayer:self.player];
            [self.playerStore dispatch:[action retryStartPlayAction]];
            [self.player play];
        };
        
        _errorView.didClickBack = ^{
            UIViewController * topVC = [TTUIResponderHelper visibleTopViewController];//[TTUIResponderHelper topViewControllerFor:self];
            if ([topVC isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController *)topVC) popViewControllerAnimated:YES];
            }
            else {
                if (topVC.navigationController) {
                    [topVC.navigationController popViewControllerAnimated:YES];
                }
                else {
                    [topVC dismissViewControllerAnimated:YES completion:nil];
                }
            }
        };
        
    }
    return _errorView;
}

- (NSString *)commonErrorText {
    if (isEmptyString(_commonErrorText)) {
        _commonErrorText = @"加载失败";
    }
    return _commonErrorText;
}

@end
