//
//  TTVVideoPlayerView.m
//  Article
//
//  Created by panxiang on 2017/9/13.
//
//

#import "TTVVideoPlayerView.h"
#import "TTVCommodityFloatView.h"
#import "TTVCommodityView.h"
#import "NSObject+FBKVOController.h"
#import "TTVVideoPlayerViewShareCointainerView.h"
#import "TTVCommodityButtonView.h"

@implementation TTVVideoPlayerView
@dynamic playerStateStore;

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
        if (self.commodityButton) {
            [self.controlView addSubview:self.commodityButton];
        }
    }
    if (self.waveView) {
        [self addSubview:self.waveView];
    }
    if (self.tipView) {
        [self addSubview:self.tipView];
    }
    if (self.midInsertADView) {
        [self addSubview:self.midInsertADView];
    }
    if (self.pasterAdView) {
        [self addSubview:self.pasterAdView];
    }
    if (self.trafficView) {
        [self addSubview:self.trafficView];
    }
    if (self.commodityFloatView) {
        [self.controlView addSubview:self.commodityFloatView];
    }
    if (self.commodityView) {
        [self addSubview:self.commodityView];
    }
    if (self.shareCointainerView) {
        [self.controlView addSubview:self.shareCointainerView];
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

    _pasterAdView.frame = self.bounds;
    _midInsertADView.frame = self.bounds;
    _commodityFloatView.frame = self.bounds;
    _commodityView.frame = self.bounds;
    if (self.controlView.playerStateStore.state.enableRotate) {
        self.shareCointainerView.bottom = self.controlView.height - 55;
    }else{
        self.shareCointainerView.bottom = self.controlView.height - 75;
    }
    self.shareCointainerView.centerX = self.controlView.width / 2;
    NSInteger commodityButtonHeight = 52;
    _commodityButton.frame = CGRectMake(self.controlView.width - commodityButtonHeight, self.controlView.height - 42 - commodityButtonHeight, commodityButtonHeight, commodityButtonHeight);
}
    
- (void)ttv_kvo
{
    [super ttv_kvo];
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,pasterADIsPlaying) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.pasterAdView.hidden = !self.playerStateStore.state.pasterADIsPlaying;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,midADIsPlaying) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.midInsertADView.hidden = (!self.playerStateStore.state.midADIsPlaying && !self.playerStateStore.state.iconADIsPlaying);
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,iconADIsPlaying) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.midInsertADView.hidden = (!self.playerStateStore.state.midADIsPlaying && !self.playerStateStore.state.iconADIsPlaying);
    }];
}

- (void)setCommodityFloatView:(TTVCommodityFloatView *)commodityFloatView
{
    if (_commodityFloatView != commodityFloatView) {
        [_commodityFloatView removeFromSuperview];
        _commodityFloatView = commodityFloatView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setCommodityButton:(TTVCommodityButtonView *)commodityButton
{
    if (_commodityButton != commodityButton) {
        [_commodityButton removeFromSuperview];
        _commodityButton = commodityButton;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setCommodityView:(TTVCommodityView *)commodityView {
    
    if (_commodityView != commodityView) {
        [_commodityView removeFromSuperview];
        _commodityView = commodityView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setPasterAdView:(UIView *)pasterAdView
{
    if (_pasterAdView != pasterAdView) {
        [_pasterAdView removeFromSuperview];
        _pasterAdView = pasterAdView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setMidInsertADView:(UIView *)midInsertADView {
    
    if (_midInsertADView != midInsertADView) {
        [_midInsertADView removeFromSuperview];
        _midInsertADView = midInsertADView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

- (void)setShareCointainerView:(TTVVideoPlayerViewShareCointainerView *)shareCointainerView
{
    if (_shareCointainerView != shareCointainerView) {
        [_shareCointainerView removeFromSuperview];
        _shareCointainerView = shareCointainerView;
        [self reorderViews];
        [self setNeedsLayout];
    }
}

@end


