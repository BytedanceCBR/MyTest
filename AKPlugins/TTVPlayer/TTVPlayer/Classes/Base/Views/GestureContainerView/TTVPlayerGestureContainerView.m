//
//  TTVPlayerGestureContainerView.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/2/27.
//

#import "TTVPlayerGestureContainerView.h"
#import "TTVPlayerState.h"
#import "TTVPlayer.h"
#import "TTVPlayerControlViewReducer.h"

@interface TTVPlayerGestureContainerView ()

@property (nonatomic, strong) TTVTouchIgoringView * controlUnderlayView;
@property (nonatomic, strong) TTVPlaybackControlView * playbackControlView;
@property (nonatomic, strong) TTVPlaybackControlView * playbackControlView_Lock;
@property (nonatomic, strong) TTVTouchIgoringView * controlOverlayView;

@end

@implementation TTVPlayerGestureContainerView

@synthesize playerStore, player, customBundle;

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // underlay
        self.controlUnderlayView = [[TTVTouchIgoringView alloc] initWithFrame:frame];
        self.controlUnderlayView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.controlUnderlayView];
        
        // control
        self.playbackControlView = [[TTVPlaybackControlView alloc] initWithFrame:frame];
        [self addSubview:self.playbackControlView];
        // 默认不是锁屏态，所以默认需要隐藏
        self.playbackControlView_Lock = [[TTVPlaybackControlView alloc] initWithFrame:frame];
        [self addSubview:self.playbackControlView_Lock];
        self.playbackControlView_Lock.hidden = YES;
        
        // overlay
        self.controlOverlayView = [[TTVTouchIgoringView alloc] initWithFrame:frame];
        [self addSubview:self.controlOverlayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.controlUnderlayView.frame = self.bounds;
    self.playbackControlView.frame = self.bounds;
    self.playbackControlView_Lock.frame = self.bounds;
    self.controlOverlayView.frame = self.bounds;
    
    if ([self.delegate respondsToSelector:@selector(containerViewLayoutSubviews:)]) {
        [self.delegate containerViewLayoutSubviews:self];
    }
    self.playbackControlView_Lock.topBar.frame = self.playbackControlView.topBar.frame;
    self.playbackControlView_Lock.bottomBar.frame = self.playbackControlView.bottomBar.frame;
}
#pragma mark - show & hide
- (void)showControl:(BOOL)show {
    [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_ShowControlView info:@{TTVPlayerActionInfo_isShowed:@(show)}]];
}
- (void)showControlView:(BOOL)show {
    if (self.customBundle) {
        self.playbackControlView.backgroundColor = !show ? [UIColor clearColor] : [UIColor colorWithWhite:0.0 alpha:0.12f];
    }
    self.playbackControlView.contentView.hidden = !show;
    self.playbackControlView.topBar.hidden = !show;
    self.playbackControlView.bottomBar.hidden = !show;
    self.playbackControlView.immersiveContentView.hidden = show;
    
    self.playbackControlView_Lock.contentView.hidden = !show;
    self.playbackControlView_Lock.topBar.hidden = !show;
    self.playbackControlView_Lock.bottomBar.hidden = !show;
    self.playbackControlView_Lock.immersiveContentView.hidden = show;
    
//    if (!show) {
//        ;
//    }
}

- (void)ttv_autoHidden:(BOOL)hidden {
    if (!self.player.supportPlaybackControlAutohide) {
        return;
    }
    if (hidden) {
        //3s后自动消失
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttv_setShowing:) object:nil];
        [self performSelector:@selector(ttv_setShowing:) withObject:@(NO) afterDelay:3];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttv_setShowing:) object:@(NO)];
    }
}

- (void)ttv_setShowing:(NSNumber *)show {
    // 发 action
    [self.playerStore dispatch:[TTVReduxAction actionWithType:TTVPlayerActionType_ShowControlView info:@{TTVPlayerActionInfo_isShowed:show}]];
}

#pragma mark - redux
- (void)stateDidChangedToNew:(TTVPlayerState *)newState lastState:(TTVPlayerState *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    // 展示 controlView
    if (newState.controlViewState.isShowed != lastState.controlViewState.isShowed && lastState.controlViewState) {
        [self showControlView:newState.controlViewState.isShowed];
    }
    
    // show
    // control 整体消失
    if (newState.playbackState == TTVPlaybackState_Playing
        && newState.controlViewState.isShowed
        && !newState.controlViewState.isPanning
        && !newState.seekStatus.sliderPanning
        && !newState.isSeeking
        && !newState.speedState.speedSelectViewShowed
        && !newState.controlViewState.locking && !newState.controlViewState.unlocking) { // TODO 还差清晰度和倍速等弹框出来的判断, 是否应该还要加上 iSSeeking
        [self ttv_autoHidden:YES];
    }
    else {
        [self ttv_autoHidden:NO];
    }
    
    // 如果是锁屏状态有变化
    if (newState.controlViewState.isLocked != lastState.controlViewState.isLocked) {
        if (newState.controlViewState.isLocked) {
            self.playbackControlView.hidden = YES;
            self.playbackControlView_Lock.hidden = NO;
            self.playbackControlView_Lock.topBar.hidden = YES;
            self.playbackControlView_Lock.bottomBar.hidden = YES;
            [self ttv_autoHidden:YES];
        }
        else {
            self.playbackControlView_Lock.hidden = YES;
            self.playbackControlView.hidden = NO;
            [self ttv_autoHidden:YES];
        }
    }
}

- (void)subscribedStoreSuccess:(TTVReduxStore *)store {
    [self.playerStore setSubReducer:[[TTVPlayerControlViewReducer alloc] initWithPlayer:self.player] forKey:@"TTVPlayerControlViewReducer"];
}

- (TTVPlayerState *)state {
    return (TTVPlayerState *)self.playerStore.state;
}

#pragma mark - getters & setters

@end
