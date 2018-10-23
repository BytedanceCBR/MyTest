//
//  TTLocalAssetMovieControlView.m
//  Article
//
//  Created by xiangwu on 2016/12/8.
//
//

#import "TTLocalAssetMovieControlView.h"
#import "TTMoviePlayerControlSliderView.h"
#import "TTMovieAdjustView.h"
#import "SSThemed.h"

@interface TTLocalAssetMovieControlView () <TTMoviePlayerControlSliderViewDelegate>

@property (nonatomic, strong) UIView *toolBarView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeDurLabel;
@property (nonatomic, strong) TTMoviePlayerControlSliderView *slider;
@property (nonatomic, strong) TTMovieAdjustView *adjustView;
@property (nonatomic, assign) NSTimeInterval totalTime;

@end

@implementation TTLocalAssetMovieControlView

#pragma mark - life cycle

- (void)dealloc {
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat toolBarH = [TTDeviceHelper isPadDevice] ? 50 : 40;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_selftapped:)];
        [self addGestureRecognizer:tapGes];
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, toolBarH)];
        _toolBarView.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground5] colorWithAlphaComponent:0.7];
        [self addSubview:_toolBarView];
        
        UIImage *img = [UIImage themedImageNamed:@"chatroom_play_video"];
        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_playBtn setImage:img forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(p_playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:_playBtn];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
        _timeLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _timeLabel.text = @"00:00";
        [_timeLabel sizeToFit];
        [_toolBarView addSubview:_timeLabel];
        
        _timeDurLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeDurLabel.textAlignment = NSTextAlignmentCenter;
        _timeDurLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
        _timeDurLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _timeDurLabel.text = @"00:00";
        [_timeDurLabel sizeToFit];
        [_toolBarView addSubview:_timeDurLabel];
        
        _slider = [[TTMoviePlayerControlSliderView alloc] init];
        _slider.delegate = self;
        [_toolBarView addSubview:_slider];
        
        _adjustView = [[TTMovieAdjustView alloc] initWithFrame:CGRectMake(0, 0, 155, [TTMovieAdjustView heightWithMode:TTMovieAdjustViewModeFullScreen])];
        _adjustView.hidden = YES;
        [self addSubview:_adjustView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat bottomInset = self.tt_safeAreaInsets.bottom;
    CGFloat padding = 2;
    self.toolBarView.left = 0;
    self.toolBarView.bottom = self.height - bottomInset;
    self.toolBarView.width = self.width;
    self.playBtn.left = padding;
    self.playBtn.centerY = self.toolBarView.height / 2;
    self.timeLabel.left = self.playBtn.right + 8;
    self.timeLabel.centerY = self.toolBarView.height / 2;
    self.timeDurLabel.right = self.toolBarView.width - 16;
    self.timeDurLabel.centerY = self.toolBarView.height / 2;
    self.slider.frame = CGRectMake(self.timeLabel.left + self.timeDurLabel.width + padding, 0, self.timeDurLabel.left - self.timeLabel.left - self.timeDurLabel.width - padding * 2, self.toolBarView.height);
    [self.slider updateFrame];
}

#pragma mark - public method

- (void)setWatchedProgress:(CGFloat)progress {
    if (isnan(progress) || progress == NAN) {
        return;
    }
    [self.slider setWatchedProgress:progress];
}

- (void)setCachedProgress:(CGFloat)progress {
    if (isnan(progress) || progress == NAN) {
        return;
    }
    [self.slider setCacheProgress:progress];
}

- (void)setTotalTime:(NSTimeInterval)totalTime {
    _totalTime = totalTime;
}

- (void)updateTimeLabel:(NSString *)time durationLabel:(NSString *)duration {
    self.timeLabel.text = time;
    self.timeDurLabel.text = duration;
}

- (void)refreshPlayButton:(BOOL)isPlaying {
    UIImage *img = [UIImage themedImageNamed:!isPlaying?@"chatroom_play_video":@"chatroom_pause_video"];
    [self.playBtn setImage:img forState:UIControlStateNormal];
}

- (void)refreshSliderFrame {
    [self.slider setNeedsLayout];
}

#pragma mark - action

- (void)p_selftapped:(UITapGestureRecognizer *)ges {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlViewWillExitFullScreen:)]) {
        [self.delegate controlViewWillExitFullScreen:self];
    }
}

- (void)p_playBtnClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlViewDidPressPlayButton:)]) {
        [self.delegate controlViewDidPressPlayButton:self];
    }
}

#pragma mark - TTMoviePlayerControlSliderViewDelegate

- (void)sliderWatchedProgressWillChange:(TTMoviePlayerControlSliderView *)slider {
    
}

- (void)sliderWatchedProgressChanging:(TTMoviePlayerControlSliderView *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlView:isSeekingToProgress:totalTime:)]) {
        [self.delegate controlView:self isSeekingToProgress:slider.watchedProgress totalTime:self.totalTime];
    }
}

- (void)sliderWatchedProgressChanged:(TTMoviePlayerControlSliderView *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlView:didSeekToProgress:totalTime:)]) {
        [self.delegate controlView:self didSeekToProgress:slider.watchedProgress totalTime:self.totalTime];
    }
}

@end
