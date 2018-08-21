//
//  TTAdCanvasVideoBottomView.m
//  Article
//
//  Created by yin on 2017/9/24.
//

#import "TTAdCanvasVideoBottomView.h"
#import "SSThemed.h"
#import "UIButton+TTAdditions.h"
#import "UIViewAdditions.h"
#import "TTVPlayerSettingUtility.h"
#import "TTVPlayerControlSliderView.h"
#import "NSObject+FBKVOController.h"

static const CGFloat kToolH = 40;
static const CGFloat kTimeLPadding = 14;
static const CGFloat kSliderLPadding = 12;
static const CGFloat kSliderRPadding = 12;
static const CGFloat kDurRPadding = 20;
static const CGFloat kFullRPadding = 14;
static const CGFloat kResolutionRPadding = 20;

@interface TTAdCanvasVideoBottomView()<TTVPlayerControlSliderViewDelegate>

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) TTVPlayerControlSliderView *slider;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeDurLabel;
@property (nonatomic, strong) UIButton *resolutionButton;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UIButton *prePlayBtn; // 播放上一个 按钮
@property (nonatomic, assign) BOOL isFull;
@property (nonatomic, assign) BOOL enableResolution;

@end

@implementation TTAdCanvasVideoBottomView

@synthesize cacheProgress = _cacheProgress;
@synthesize watchedProgress = _watchedProgress;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        
        _backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomShadow"]];
        [self addSubview:_backImageView];
        _toolView = [[UIView alloc] init];
        _toolView.userInteractionEnabled = YES;
        [self addSubview:_toolView];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _timeLabel.text = @"00:00";
        [_toolView addSubview:_timeLabel];
        
        _slider = [[TTVPlayerControlSliderView alloc] init];
        _slider.delegate = self;
        [_toolView addSubview:_slider];
        _timeDurLabel = [[UILabel alloc] init];
        _timeDurLabel.textAlignment = NSTextAlignmentCenter;
        _timeDurLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _timeDurLabel.text = @"00:00";
        [_toolView addSubview:_timeDurLabel];
        
        _resolutionButton = [[UIButton alloc] init];
        [_resolutionButton setTitle:@"标清" forState:UIControlStateNormal];
        [_resolutionButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText12] forState:UIControlStateNormal];
        _resolutionButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_resolutionButton addTarget:self action:@selector(resolutionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_resolutionButton sizeToFit];
        _resolutionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -11, -12, -13);
        [_toolView addSubview:_resolutionButton];
        UIImage *img = [UIImage imageNamed:@"Fullscreen"];
        _fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -22, -12, -14);
        [_fullScreenButton setImage:[UIImage imageNamed:@"Fullscreen"] forState:UIControlStateNormal];
        
        [_toolView addSubview:_fullScreenButton];
        self.isFull = NO;
        self.resolutionString = @"标清";
        
        [self ttv_enableSlider:YES];
        
    }
    return self;
}

- (void)updateFrame {
    
    [self prePlayBtn].hidden = (!_prePlayBtn.isEnabled || _isFull); // 全屏状态或者按钮无效时 不显示
    _backImageView.frame = UIEdgeInsetsInsetRect(self.bounds, self.dimAreaEdgeInsetsWhenFullScreen);
    _toolView.frame = CGRectMake(0, self.height - kToolH, self.width, kToolH);
    CGFloat left = kTimeLPadding;
    
    // 播放上一个 按钮
    self.prePlayBtn.centerY = self.toolView.height / 2;
    self.prePlayBtn.left = left;
    
    left = (self.prePlayBtn.hidden) ? left: self.prePlayBtn.right + 10.0;
    
    _timeLabel.left = left;
    _timeLabel.centerY = self.toolView.height / 2;
    _fullScreenButton.right = self.width - (_isFull ? kFullRPadding+2 : kFullRPadding);
    _fullScreenButton.centerY = _timeLabel.centerY;
    if (!_resolutionButton.hidden) {
        _resolutionButton.right = _fullScreenButton.left - kResolutionRPadding;
        _resolutionButton.centerY = _timeLabel.centerY;
        _timeDurLabel.right = _resolutionButton.left - kDurRPadding;
        _timeDurLabel.centerY = _timeLabel.centerY;
    } else {
        _timeDurLabel.right = _fullScreenButton.left - kDurRPadding;
        _timeDurLabel.centerY = _timeLabel.centerY;
    }
    
    _slider.width = _timeDurLabel.left - _timeLabel.right - kSliderLPadding - kSliderRPadding;
    _slider.height = _toolView.height;
    _slider.left = _timeLabel.right + kSliderLPadding;
    _slider.centerY = _timeLabel.centerY;
    [_slider updateFrame];
    
}


- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime {
    _timeLabel.text = curTime;
    _timeDurLabel.text = totalTime;
    CGFloat originTimeLabelWidth = _timeLabel.width;
    CGFloat originTimeDurLabelWidth = _timeDurLabel.width;
    [_timeLabel sizeToFit];
    [_timeDurLabel sizeToFit];
    if (ceilf(originTimeLabelWidth) != ceilf(_timeLabel.width) || ceilf(originTimeDurLabelWidth) != ceilf(_timeDurLabel.width)) {
        _slider.width = _timeDurLabel.left - _timeLabel.right - kSliderLPadding - kSliderRPadding;
        _slider.left = _timeLabel.right + kSliderLPadding;
        [_slider updateFrame];
    }
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        _playerStateStore = playerStateStore;
        self.slider.playerStateStore = playerStateStore;
        self.enableResolution = playerStateStore.state.playerModel.enableResolution;
        [self setEnableResolutionClicked:playerStateStore.state.playerModel.enableResolution];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentResolution) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVPlayerResolutionType value = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        [self setResolutionString:[TTVPlayerStateModel typeStringForType:value]];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,supportedResolutionTypes) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        NSArray *value = [change valueForKey:NSKeyValueChangeNewKey];
        [self setEnableResolutionClicked:[value isKindOfClass:[NSArray class]] && value.count > 1];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.isFull = self.playerStateStore.state.isFullScreen;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self ttv_playbackState];
    }];
    
}


- (void)setIsFull:(BOOL)isFull {
    _isFull = isFull;
    _resolutionButton.hidden = !isFull;
    _prePlayBtn.hidden = (!_prePlayBtn.isEnabled || isFull); // 全屏状态或者按钮无效时 不显示
    NSString *imgName = @"video_voice_ad";
    UIImage *img = [UIImage imageNamed:imgName];
    CGFloat fontSize = isFull ? 14.f : 12.f;
    _timeLabel.font = [UIFont systemFontOfSize:fontSize];
    [_timeLabel sizeToFit];
    _timeDurLabel.font = [UIFont systemFontOfSize:fontSize];
    [_timeDurLabel sizeToFit];
    [_fullScreenButton setImage:img forState:UIControlStateNormal];
    _fullScreenButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    if (_isFull && _enableResolution) {
        _resolutionButton.hidden = NO;
    } else {
        _resolutionButton.hidden = YES;
    }
    _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -22, -12, -14);
    if (isFull) {
        _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-16, -8, -12, -16);
    }
    _slider.isFull = isFull;
    [self updateFrame];
}

- (void)ttv_enableSlider:(BOOL)enable {
    self.slider.enableDrag = enable;
    self.playerStateStore.state.sliderEnableDrag = enable;
}

- (void)ttv_playbackState
{
    TTVVideoPlaybackState state = self.playerStateStore.state.playbackState;
    switch (state) {
        case TTVVideoPlaybackStateError:{
            [self ttv_enableSlider:NO];
        }
            break;
        case TTVVideoPlaybackStatePaused:{
            [self ttv_enableSlider:YES];
        }
            break;
        case TTVVideoPlaybackStatePlaying:{
            [self ttv_enableSlider:YES];
        }
            break;
        case TTVVideoPlaybackStateFinished:{
            [self ttv_enableSlider:NO];
        }
            break;
        default:
            break;
    }
}

- (void)setResolutionString:(NSString *)resolutionString {
    [_resolutionButton setTitle:resolutionString forState:UIControlStateNormal];
}

- (void)setEnableResolution:(BOOL)enableResolution {
    _enableResolution = enableResolution;
    if (_isFull && _enableResolution) {
        _resolutionButton.hidden = NO;
    } else {
        _resolutionButton.hidden = YES;
    }
}

- (void)setCacheProgress:(CGFloat)cacheProgress
{
    _cacheProgress = cacheProgress;
    self.slider.cacheProgress = cacheProgress;
}

- (CGFloat)cacheProgress
{
    return self.slider.cacheProgress;
}

- (void)setWatchedProgress:(CGFloat)watchedProgress
{
    _watchedProgress = watchedProgress;
    self.slider.watchedProgress = watchedProgress;
}

- (void)setFullScreenButtonLogoName:(NSString *)name
{
    if (!isEmptyString(name)) {
        [_fullScreenButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    }
}

- (CGFloat)watchedProgress
{
    return self.slider.watchedProgress;
}

- (void)setEnableResolutionClicked:(BOOL)enableResolutionClicked {
    _resolutionButton.enabled = enableResolutionClicked;
    UIColor *color = [UIColor tt_defaultColorForKey:kColorText12];
    if (!enableResolutionClicked) {
        color = [UIColor tt_defaultColorForKey:kColorText11];
    }
    [_resolutionButton setTitleColor:color forState:UIControlStateNormal];
}

- (UIButton *)prePlayBtn {
    
    if (![TTVPlayerSettingUtility tt_video_detail_playlast_enable]) {
        
        return nil;
    }
    return _prePlayBtn;
}

- (void)resolutionButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(bottomViewResolutionButtonClicked)]) {
        [self.delegate bottomViewResolutionButtonClicked];
    }
}

- (void)fullScreenButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(bottomViewFullScreenButtonClicked)]) {
        [self.delegate bottomViewFullScreenButtonClicked];
    }
}

- (void)sliderWatchedProgressWillChange:(TTVPlayerControlSliderView *)slider
{
    if ([self.delegate respondsToSelector:@selector(bottomViewWatchedProgressWillChange:cacedProgress:)]) {
        [self.delegate bottomViewWatchedProgressWillChange:slider.watchedProgress cacedProgress:slider.cacheProgress];
    }
}

- (void)sliderWatchedProgressChanging:(TTVPlayerControlSliderView *)slider
{
    if ([self.delegate respondsToSelector:@selector(bottomViewWatchedProgressChanging:cacedProgress:)]) {
        [self.delegate bottomViewWatchedProgressChanging:slider.watchedProgress cacedProgress:slider.cacheProgress];
    }
}

- (void)sliderWatchedProgressChanged:(TTVPlayerControlSliderView *)slider
{
    if ([self.delegate respondsToSelector:@selector(bottomViewWatchedProgressChanged:cacedProgress:)]) {
        [self.delegate bottomViewWatchedProgressChanged:slider.watchedProgress cacedProgress:slider.cacheProgress];
    }
}

@end
