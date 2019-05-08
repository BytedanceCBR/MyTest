//
//  TTMoviePlayerControlBottomView.m
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import "TTMoviePlayerControlBottomView.h"
#import "SSThemed.h"
#import "UIButton+TTAdditions.h"
#import "UIViewAdditions.h"
#import "TTVPlayerSettingUtility.h"
static const CGFloat kToolH = 40;
static const CGFloat kTimeLPadding = 14;
static const CGFloat kSliderLPadding = 12;
static const CGFloat kSliderRPadding = 12;
static const CGFloat kDurRPadding = 20;
static const CGFloat kFullRPadding = 14;
static const CGFloat kResolutionRPadding = 20;
static const CGFloat kPlayLPadding = 14;

@interface TTMoviePlayerControlBottomView ()

@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation TTMoviePlayerControlBottomView

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
        _slider = [[TTMoviePlayerControlSliderView alloc] init];
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
        [_resolutionButton sizeToFit];
        _resolutionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -11, -12, -13);
        [_toolView addSubview:_resolutionButton];
        UIImage *img = [UIImage imageNamed:@"Fullscreen"];
        _fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -22, -12, -14);
        [_fullScreenButton setImage:[UIImage imageNamed:@"Fullscreen"] forState:UIControlStateNormal];
        [_toolView addSubview:_fullScreenButton];
        self.isFull = NO;
        // 播放上一个视频按钮
        [_toolView addSubview:self.prePlayBtn];
    }
    return self;
}

- (void)updateFrame {
    
    [self prePlayBtn].hidden = (!_prePlayBtn.isEnabled || _isFull); // 全屏状态或者按钮无效时 不显示
    _backImageView.frame = UIEdgeInsetsInsetRect(self.bounds, self.dimAreaEdgeInsetsWhenFullScreen);
    _toolView.frame = CGRectMake(0, self.height - kToolH, self.width, kToolH);
    CGFloat left = kTimeLPadding;
    if (_playButton.superview == _toolView) {
        _playButton.left = kPlayLPadding;
        _playButton.centerY = self.toolView.height / 2;
        left += _playButton.right;
    }
    
    // 播放上一个 按钮
    self.prePlayBtn.centerY = self.toolView.height / 2;
    self.prePlayBtn.left = left;
    
    left = (self.prePlayBtn.hidden) ? left: self.prePlayBtn.right + 10.0;
    
    _timeLabel.left = left;
    _timeLabel.centerY = self.toolView.height / 2;
    _fullScreenButton.right = self.width - (_isFull ? kFullRPadding+2 : kFullRPadding);
    _fullScreenButton.centerY = _timeLabel.centerY;
    if (_playButton.superview == _toolView) {
        _timeDurLabel.right = self.width - kDurRPadding;
        _timeDurLabel.centerY = _timeLabel.centerY;
    } else {
        if (!_resolutionButton.hidden) {
            _resolutionButton.right = _fullScreenButton.left - kResolutionRPadding;
            _resolutionButton.centerY = _timeLabel.centerY;
            _timeDurLabel.right = _resolutionButton.left - kDurRPadding;
            _timeDurLabel.centerY = _timeLabel.centerY;
        } else {
            _timeDurLabel.right = _fullScreenButton.left - kDurRPadding;
            _timeDurLabel.centerY = _timeLabel.centerY;
        }
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

- (void)setIsFull:(BOOL)isFull {
    _isFull = isFull;
    _resolutionButton.hidden = !isFull;
    _prePlayBtn.hidden = (!_prePlayBtn.isEnabled || isFull); // 全屏状态或者按钮无效时 不显示
    NSString *imgName = isFull ? @"Fullscreen_exit" : @"Fullscreen";
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

- (void)setResolutionString:(NSString *)resolutionString {
    _resolutionString = [resolutionString copy];
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

- (void)setEnableResolutionClicked:(BOOL)enableResolutionClicked {
    _enableResolutionClicked = enableResolutionClicked;
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
    
    if (!_prePlayBtn) {
        
        UIImage *img = [UIImage imageNamed:@"pre_play"];
        _prePlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _prePlayBtn.enabled = NO;
        _prePlayBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_prePlayBtn setImage:img forState:UIControlStateNormal];
        NSString *text = ([TTVPlayerSettingUtility tt_video_detail_playlast_showtext]) ? NSLocalizedString(@"上一个", nil): @"";
        [_prePlayBtn setTitle:text forState:UIControlStateNormal];
        [_prePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText12] forState:UIControlStateNormal];
        [_prePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText12Highlighted] forState:UIControlStateHighlighted];
        _prePlayBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [_prePlayBtn layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2.f];
        
        [_prePlayBtn sizeToFit];
    }
    
    return _prePlayBtn;
}

@end

