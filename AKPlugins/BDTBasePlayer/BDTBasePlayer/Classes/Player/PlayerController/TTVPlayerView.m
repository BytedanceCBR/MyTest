//
//  TTVPlayerView.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerView.h"
#import "KVOController.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerSettingUtility.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
@implementation TTVPlayerView

- (void)dealloc
{
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)reorderViews
{
    if (self.backgroundView) {
        [self addSubview:self.backgroundView];
    }
    if (self.playerLayer) {
        [self addSubview:self.playerLayer];
    }
    if (self.logoImageView) {
        [self addSubview:self.logoImageView];
    }
    if (self.controlView) {
        [self addSubview:self.controlView];
    }
    if (self.waveView) {
        [self addSubview:self.waveView];
    }
    if (self.tipView) {
        [self addSubview:self.tipView];
    }
    if (self.trafficView) {
        [self addSubview:self.trafficView];
    }
    if (self.changeResolutionView) {
        [self addSubview:self.changeResolutionView];
    }
    if (self.changeResolutionAlertView) {
        [self addSubview:self.changeResolutionAlertView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _playerLayer.frame = self.bounds;
    _logoImageView.frame = self.bounds;
    CGRect targetFrame = self.bounds;
    CGFloat paddingToAvoidConflictHomeIndicatorInteract = 0;
    if ([TTDeviceHelper isIPhoneXDevice] && self.playerStateStore.state.isFullScreen) {
        if (self.playerStateStore.state.enableRotate) {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(0, 0, 21 + paddingToAvoidConflictHomeIndicatorInteract, 0));
        } else {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(0, 0, 21 + paddingToAvoidConflictHomeIndicatorInteract, 0));
        }
    }
    _controlView.frame = targetFrame;
    _changeResolutionView.frame = targetFrame;
    _changeResolutionAlertView.frame = targetFrame;
    if ([_changeResolutionView respondsToSelector:@selector(layoutWithSuperViewFrame:)]) {
        [_changeResolutionView layoutWithSuperViewFrame:targetFrame];
    }
    if ([_changeResolutionAlertView respondsToSelector:@selector(layoutWithSuperViewFrame:)]) {
        [_changeResolutionAlertView layoutWithSuperViewFrame:targetFrame];
    }
    if ([_controlView respondsToSelector:@selector(setDimAreaEdgeInsetsWhenFullScreen:)]) {
        [_controlView setDimAreaEdgeInsetsWhenFullScreen:UIEdgeInsetsMake(-targetFrame.origin.y, -targetFrame.origin.x, - self.bounds.size.height + targetFrame.origin.y + targetFrame.size.height, - self.bounds.size.width + targetFrame.origin.x + targetFrame.size.width)];
    }
    _trafficView.frame = self.bounds;
    _snapView.frame = self.bounds;
    _waveView.frame = self.bounds;
    if ([_tipView respondsToSelector:@selector(setSuperViewFrame:)]) {
        _tipView.superViewFrame = targetFrame;
    }
    _tipView.frame = self.bounds;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore {
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,showVideoFirstFrame) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        BOOL beginPlay = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        if (beginPlay) {
            self.logoImageView.hidden = beginPlay;
        }
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVVideoPlaybackState state = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        switch (state) {
            case TTVVideoPlaybackStateError:
            {

            }
                break;
            case TTVVideoPlaybackStatePaused:
            {
                self.logoImageView.hidden = YES;
            }
                break;
            case TTVVideoPlaybackStatePlaying:
            {
                self.logoImageView.hidden = YES;
            }
                break;
            case TTVVideoPlaybackStateFinished:
            case TTVVideoPlaybackStateBreak:
            {
                self.logoImageView.hidden = NO;
            }
                break;
            default:
                break;
        }
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,resolutionState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVResolutionState value = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        switch (value) {
            case TTVResolutionStateEnd:
                [self.snapView removeFromSuperview];
                self.snapView = nil;
                break;
            case TTVResolutionStateError:
                [self.snapView removeFromSuperview];
                self.snapView = nil;
                break;
            case TTVResolutionStateChanging:
                break;
            default:
                [self.snapView removeFromSuperview];
                self.snapView = nil;
                break;
        }
    }];
}

- (void)actionChangeCallbackWithAction:(TTVFluxAction *)action state:(id)state
{
    
}

- (void)setPlayerLayer:(UIView *)playerLayer
{
    if (_playerLayer != playerLayer) {
        [_playerLayer removeFromSuperview];
        _playerLayer = playerLayer;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (_backgroundView != backgroundView) {
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setChangeResolutionView:(UIView<TTVViewLayout> *)changeResolutionView
{
    if (_changeResolutionView != changeResolutionView) {
        [_changeResolutionView removeFromSuperview];
        _changeResolutionView = changeResolutionView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setChangeResolutionAlertView:(UIView<TTVViewLayout> *)changeResolutionAlertView
{
    if (_changeResolutionAlertView != changeResolutionAlertView) {
        [_changeResolutionAlertView removeFromSuperview];
        _changeResolutionAlertView = changeResolutionAlertView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setWaveView:(UIView *)waveView
{
    if (_waveView != waveView) {
        [_waveView removeFromSuperview];
        _waveView = waveView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setLogoImageView:(UIView *)logoImageView {
    [_logoImageView removeFromSuperview];
    _logoImageView = logoImageView;
    if (logoImageView) {
        logoImageView.frame = self.bounds;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setSnapView:(UIView *)snapView {
    if (snapView) {
        snapView.frame = self.bounds;
        [_snapView removeFromSuperview];
        _snapView = snapView;
        [self reorderViews];
        [self setNeedsLayout];
    } else {
        [_snapView removeFromSuperview];
        _snapView = nil;
    }
}

- (void)setControlView:(UIView<TTVPlayerViewControlView ,TTVPlayerContext> *)controlView {

    if (_controlView != controlView) {
        [_controlView removeFromSuperview];
        _controlView = controlView;
        controlView.userInteractionEnabled = YES;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setTrafficView:(UIView<TTVPlayerViewTrafficView ,TTVPlayerContext> *)trafficView {

    if (trafficView != _trafficView) {
        [_trafficView removeFromSuperview];
        _trafficView = trafficView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setTipView:(UIView<TTVPlayerControlTipView,TTVPlayerContext> *)tipView
{
    if (_tipView != tipView) {
        [_tipView removeFromSuperview];
        _tipView = tipView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

@end
