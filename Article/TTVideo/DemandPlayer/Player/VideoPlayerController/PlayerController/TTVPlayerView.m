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
}

- (void)layoutSubviews {
    _playerLayer.frame = self.bounds;
    _logoImageView.frame = self.bounds;
    CGRect targetFrame = self.bounds;
    CGFloat paddingToAvoidConflictHomeIndicatorInteract = 20;
    if ([TTDeviceHelper isIPhoneXDevice] && self.playerStateStore.state.isFullScreen) {
        if (self.playerStateStore.state.enableRotate) {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(0, 0, 21 + paddingToAvoidConflictHomeIndicatorInteract, 0));
        } else {
            targetFrame = UIEdgeInsetsInsetRect(targetFrame, UIEdgeInsetsMake(0, 0, 21 + paddingToAvoidConflictHomeIndicatorInteract, 0));
        }
    }
    _controlView.frame = targetFrame;
    if ([_controlView respondsToSelector:@selector(setDimAreaEdgeInsetsWhenFullScreen:)]) {
        [_controlView setDimAreaEdgeInsetsWhenFullScreen:UIEdgeInsetsMake(-targetFrame.origin.y, -targetFrame.origin.x, - self.bounds.size.height + targetFrame.origin.y + targetFrame.size.height, - self.bounds.size.width + targetFrame.origin.x + targetFrame.size.width)];
    }
    _trafficView.frame = self.bounds;
    _snapView.frame = self.bounds;
    _waveView.frame = self.bounds;
    _tipView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        _playerStateStore = playerStateStore;
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

- (void)setPlayerLayer:(UIView *)playerLayer
{
    if (_playerLayer != playerLayer) {
        [_playerLayer removeFromSuperview];
        _playerLayer = playerLayer;
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
