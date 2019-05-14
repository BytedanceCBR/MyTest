//
//  TTVGestureManager.m
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import "TTVGestureManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVPlayerGestureController.h"
#import "TTVPlayerStateGesture.h"
#import "TTVPlayerStateGesturePrivate.h"
#import "TTVPlayerStore.h"
#import "TTVGestureTrack.h"
#import "TTVPlayerStateFullScreen.h"

@interface TTVGestureManager ()

@property (nonatomic, strong) TTVGestureTrack *tracker;
@property (nonatomic, strong) TTVPlayerGestureController *gestureController;

@end

@implementation TTVGestureManager
@synthesize store = _store;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tracker = [[TTVGestureTrack alloc] init];
    }
    return self;
}

- (instancetype)initWithStore:(TTVPlayerStore *)store {
    self = [super init];
    if (self) {
        self.store = store;

        [self registerPartWithStore:store];

    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
//    if (store == self.store) {
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVGestureManagerActionTypeProgressViewShow]) {
                [self progressViewShow:[action.info[@"show"] boolValue]];
            }else if ([action.type isEqualToString:TTVPlaybackControlActionTypeSeekingToProgress]) {
                CGFloat progress = [action.info[@"progress"] doubleValue];
                BOOL cancel = [action.info[@"cancel"] boolValue];
                BOOL end = [action.info[@"end"] boolValue];
                [self updateGestureWithProgress:progress cacnel:cancel end:end];
            }else if ([action.type isEqualToString:TTVErrorManagerActionTypeClickRetry]) {
                if (self.isNoneFullScreenPlayerGestureEnabled) {
                    [self.gestureController enableSingleTapGesture:YES];
                    [self.gestureController enableDoubleTapGesture:YES];
                } else {
                    [self.gestureController enablePanGestures:self.store.state.fullScreen.isFullScreen];
                    [self.gestureController enableSingleTapGesture:YES];
                    [self.gestureController enableDoubleTapGesture:YES];
                }
            }
        }];
        [self ttv_bindsObserve];
        self.gestureController.videoPlayerDoubleTapEnable = self.videoPlayerDoubleTapEnable;
        self.gestureController.isNoneFullScreenPlayerGestureEnabled = self.isNoneFullScreenPlayerGestureEnabled;
//    }
}

- (void)ttv_bindsObserve {

    RAC(self.store.state.gesture, isDragging) = RACObserve(self.gestureController, progressSeeking);
    RAC(self.gestureController, locked) = RACObserve(self.store.state.control, isLocked);
    RAC(self.gestureController, isFullScreen) = RACObserve(self.store.state.fullScreen, isFullScreen);
    RAC(self.gestureController, currentPlayingTime) = RACObserve(self.store.player, currentPlaybackTime);
    RAC(self.gestureController, duration) = RACObserve(self.store.player, playbackTime.duration);
    RAC(self.gestureController, supportsPortaitFullScreen) = RACObserve(self.store.state.fullScreen, supportsPortaitFullScreen);
    RAC(self.gestureController, isPlaybackEnded) = RACObserve(self.store.player, isPlaybackEnded);
    
}

- (void)updateGestureWithProgress:(CGFloat)progress cacnel:(BOOL)cancel end:(BOOL)end
{
    self.gestureController.progressView.totalTime = self.store.player.duration;
    [self.gestureController setProgressHubShow:!end];
    [self.gestureController.progressView updateProgress:progress];
}

- (void)ttv_observe
{
    @weakify(self);
    [RACObserve(self.store.state.loading, isShowing) subscribeNext:^(NSNumber *isShowing) {
        @strongify(self);
        if ([isShowing boolValue]) {
            [self startLoading];
        }else{
            [self stopLoading];
        }
    }];
    
    
    [RACObserve(self.store.state.fullScreen, isFullScreen) subscribeNext:^(NSNumber *fullScreen) {
        @strongify(self);
        //全屏时 开启全屏手势控制
        BOOL enablePan = !self.store.state.loading.isShowing && !self.store.state.control.isLocked;
        if (!self.isNoneFullScreenPlayerGestureEnabled) {
            enablePan = enablePan && [fullScreen boolValue];
        }
        [self.gestureController enablePanGestures:enablePan];
    }];
    
    [RACObserve(self.store.state.loading, isShowing) subscribeNext:^(NSNumber *isShowing) {
        @strongify(self);
        if ([isShowing boolValue]) {
            [self.gestureController enablePanGestures:NO];
            [self.gestureController enableSingleTapGesture:NO];
            [self.gestureController enableDoubleTapGesture:NO];
        }else{
            [self.gestureController enableDoubleTapGesture:YES];
            [self.gestureController enableSingleTapGesture:YES];
        }
    }];
}

- (void)startLoading {
    [self.gestureController enablePanGestures:NO];
}

- (void)stopLoading {

    BOOL enable = self.isNoneFullScreenPlayerGestureEnabled || self.store.state.fullScreen.isFullScreen;
    [self.gestureController enablePanGestures:enable];
}

- (TTVPlayerGestureController *)gestureController {
    if (!_gestureController) {
        _gestureController = [[TTVPlayerGestureController alloc] initWithPlayerControlView:self.store.player.controlView];
        @weakify(self);
        _gestureController.doubleTapClick = ^{
            @strongify(self);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeDoubleTapClick info:nil];
            [self.store dispatch:action];
        };
        
        _gestureController.volumeDidChanged = ^(CGFloat volume, BOOL isSystemVolumeButton) {
            @strongify(self);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"volume"] = @(volume);
            info[@"isSystemVolumeButton"] = @(isSystemVolumeButton);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeVolumeDidChanged info:info];
            [self.store dispatch:action];
        };
        _gestureController.singleTapClick = ^{
            @strongify(self);
            void(^controlShowingBySingleTap)(void) = ^(void) {
                @strongify(self);
                if (self.store.state.control.isShowing) {
                    self.gestureController.controlShowingBySingleTap = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.gestureController.controlShowingBySingleTap = NO;
                    });
                }
            };
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"controlShowingBySingleTap"] = controlShowingBySingleTap;
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeSingleTapClick info:info];
            [self.store dispatch:action];
        };
        _gestureController.changeBrightnessClick = ^(void) {
            @strongify(self);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeChangeBrightnessClick info:nil];
            [self.store dispatch:action];
        };
        _gestureController.changeVolumeClick = ^(void) {
            @strongify(self);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeChangeVolumeClick info:nil];
            [self.store dispatch:action];
        };
        _gestureController.ProgressViewShowBlock = ^(BOOL show) {
            @strongify(self);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"show"] = @(show);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeProgressViewShow info:info];
            [self.store dispatch:action];
        };
        _gestureController.seekingToProgress = ^(CGFloat progress, CGFloat fromProgress, BOOL cancel, BOOL end) {
            @strongify(self);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"progress"] = @(progress);
            info[@"fromProgress"] = @(fromProgress);
            info[@"end"] = @(end);
            info[@"cancel"] = @(cancel);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeSeekingToProgress info:info];
            [self.store dispatch:action];
        };
        _gestureController.swipeProgressSeeking = ^(CGFloat fromProgress, CGFloat currentProgress) {
            @strongify(self);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"fromProgress"] = @(fromProgress);
            info[@"currentProgress"] = @(currentProgress);
            TTVRAction *action = [TTVRAction actionWithType:TTVGestureManagerActionTypeSwipeProgressSeeking info:info];
            [self.store dispatch:action];
        };
    }
    return _gestureController;
}

- (void)setVideoPlayerDoubleTapEnable:(BOOL)videoPlayerDoubleTapEnable
{
    _videoPlayerDoubleTapEnable = videoPlayerDoubleTapEnable;
    self.gestureController.videoPlayerDoubleTapEnable = videoPlayerDoubleTapEnable;
}

- (void)setIsNoneFullScreenPlayerGestureEnabled:(BOOL)isNoneFullScreenPlayerGestureEnabled
{
    _isNoneFullScreenPlayerGestureEnabled = isNoneFullScreenPlayerGestureEnabled;
    self.gestureController.isNoneFullScreenPlayerGestureEnabled = isNoneFullScreenPlayerGestureEnabled;
}

- (void)enableProgressHub:(BOOL)enable
{
    [self.gestureController enableProgressHub:enable];
}

- (void)progressViewShow:(BOOL)show
{
    if ((self.store.state.play.location & TTVPlayerControlsCanDisableLocation_ProgressHub)) {
        [self.gestureController enableProgressHub:!show];
    }
}

@end

@implementation TTVPlayer (GestureManager)

- (TTVGestureManager *)gestureManager
{
    return nil;

//    return [self partManagerFromClass:[TTVGestureManager class]];
}

@end
