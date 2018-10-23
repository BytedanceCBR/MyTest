//
//  TTMoviePlayerControlLiveBottomView.m
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import "TTMoviePlayerControlLiveBottomView.h"
#import "SSThemed.h"

static const CGFloat kToolH = 40;
static const CGFloat kTimeLPadding = 14;
static const CGFloat kSliderLPadding = 12;
static const CGFloat kSliderRPadding = 12;
static const CGFloat kDurRPadding = 14;
static const CGFloat kFullRPadding = 14;
static const CGFloat kStatusLPadding = 14;
static const CGFloat kPartLPadding = 5;
static const CGFloat kReplayLPadding = 14;

@interface TTMoviePlayerControlLiveBottomView ()

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, weak) UIView *statusView;
@property (nonatomic, weak) UIView *numOfParticipantsView;

@property (nonatomic, weak) UIView *rnStatusView;
@property (nonatomic, weak) UIView* muteButton;

@end

@implementation TTMoviePlayerControlLiveBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        _backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomShadow"]];
        [self addSubview:_backImageView];
        _toolView = [[UIView alloc] init];
        _toolView.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground5] colorWithAlphaComponent:0.7];
        _toolView.userInteractionEnabled = YES;
        [self addSubview:_toolView];
        _replayLabel = [[UILabel alloc] init];
        _replayLabel.textAlignment = NSTextAlignmentCenter;
        _replayLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _replayLabel.text = @"回放";
        [_toolView addSubview:_replayLabel];
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
        UIImage *img = [UIImage imageNamed:@"Fullscreen"];
        _fullScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -22, -12, -14);
        [_fullScreenButton setImage:[UIImage imageNamed:@"Fullscreen"] forState:UIControlStateNormal];
        [_toolView addSubview:_fullScreenButton];
        self.isFull = NO;
    }
    return self;
}

- (void)updateFrame {
    _backImageView.frame = self.bounds;
    _toolView.frame = CGRectMake(0, self.height - kToolH, self.width, kToolH);
    _replayLabel.left = kReplayLPadding;
    _replayLabel.centerY = _toolView.height / 2;
    _timeLabel.left = _replayLabel.right + kTimeLPadding;
    _timeLabel.centerY = self.toolView.height / 2;
    _fullScreenButton.right = self.width - (_isFull ? kFullRPadding+2 : kFullRPadding);
    _fullScreenButton.centerY = _toolView.height / 2;
    _timeDurLabel.right = _fullScreenButton.left - kDurRPadding;
    _timeDurLabel.centerY = _timeLabel.centerY;
    _slider.width = _timeDurLabel.left - _timeLabel.right - kSliderLPadding - kSliderRPadding;
    _slider.height = _toolView.height;
    _slider.left = _timeLabel.right + kSliderLPadding;
    _slider.centerY = _timeLabel.centerY;
    [_slider updateFrame];
    [self updateRNView];
}

- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime {
    _timeLabel.text = curTime;
    _timeDurLabel.text = totalTime;
    [_timeLabel sizeToFit];
    [_timeDurLabel sizeToFit];
}

- (void)updateLiveWithStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView {
    _isLive = YES;
    if (!statusView || !numOfParticipantsView) {
        return;
    }
    self.statusView = statusView;
    self.numOfParticipantsView = numOfParticipantsView;
    [_toolView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != _fullScreenButton) {
            [obj removeFromSuperview];
        }
    }];
    [_toolView addSubview:statusView];
    [_toolView addSubview:numOfParticipantsView];
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_toolView.mas_left).offset(kStatusLPadding);
        make.centerY.mas_equalTo(_toolView.height/2);
    }];
    [numOfParticipantsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(statusView.mas_right).offset(kPartLPadding);
        make.centerY.equalTo(statusView.mas_centerY);
    }];
    [self updateFrame];
}

- (void)updateRNLiveWithStatusView:(UIView*)statusView muteButton:(UIView*)muteButton
{
    _isLive = YES;
    if (!statusView || !muteButton) {
        return;
    }
    
    [_toolView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.rnStatusView = statusView;
    self.muteButton = muteButton;
    [self updateFrame];
    [_toolView addSubview:statusView];
    [_toolView addSubview:muteButton];
    
}

- (void)updateRNReplayWithmuteButton:(UIView *)muteButton
{
    _isLive = NO;
    if (!muteButton) {
        return;
    }
    [_fullScreenButton removeFromSuperview];
    self.muteButton = muteButton;
    [self updateFrame];
    [_toolView addSubview:self.muteButton];
}

- (void)updateRNView
{
    if (_isLive == YES) {
        if (self.rnStatusView && self.muteButton) {
            [self.rnStatusView sizeToFit];
            self.rnStatusView.left = kStatusLPadding;
            self.rnStatusView.centerY = _toolView.height/2;
            [self.muteButton sizeToFit];
            self.muteButton.right = _toolView.width - kFullRPadding;
            self.muteButton.centerY = _toolView.height/2;
        }
    }
    else
    {
        if (self.muteButton) {
            [self.muteButton sizeToFit];
            self.muteButton.right = _toolView.width - kFullRPadding;
            self.muteButton.centerY = _toolView.height/2;
        }
    }
}

- (void)updateReplay {
    _isLive = NO;
}



- (void)setIsFull:(BOOL)isFull {
    _isFull = isFull;
    NSString *imgName = isFull ? @"Fullscreen_exit" : @"Fullscreen";
    UIImage *img = [UIImage imageNamed:imgName];
    CGFloat fontSize = isFull ? 14.f : 12.f;
    _replayLabel.font = [UIFont systemFontOfSize:fontSize];
    [_replayLabel sizeToFit];
    _timeLabel.font = [UIFont systemFontOfSize:fontSize];
    [_timeLabel sizeToFit];
    _timeDurLabel.font = [UIFont systemFontOfSize:fontSize];
    [_timeDurLabel sizeToFit];
    [_fullScreenButton setImage:img forState:UIControlStateNormal];
    _fullScreenButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -22, -12, -14);
    if (isFull) {
        _fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-16, -8, -12, -16);
    }
    _slider.isFull = isFull;
}

@end
