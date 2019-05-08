//
//  TTMovieAdjustView.m
//  Article
//
//  Created by songxiangwu on 16/9/20.
//
//

#import "TTMovieAdjustView.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"

@interface TTMovieAdjustView ()

@end

static const CGFloat kSliderPaddingHorizontal = 24;
static const CGFloat kSliderPaddingBottom = 20;
static const CGFloat kProgressLabelPaddingTop = 12;
static const CGFloat kProgressLabelFont = 16;

@implementation TTMovieAdjustView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *color = [UIColor tt_defaultColorForKey:kColorBackground11];
        self.backgroundColor = [color colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        
        _logoImageView = [[UIImageView alloc] init];
        [self addSubview:_logoImageView];
        _progressLabel = [[SSThemedLabel alloc] init];
        _progressLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:kProgressLabelFont];
        [self addSubview:_progressLabel];
        _sliderView = [[TTMovieProgressSliderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 2 * kSliderPaddingHorizontal, 3)];
        [self addSubview:_sliderView];
    }
    return self;
}

- (void)setProgressPercentage:(CGFloat)progressPercentage isIncrease:(BOOL)isIncrease type:(TTMovieAdjustViewType)type {
    _type = type;
    if (progressPercentage < 0) {
        progressPercentage = 0;
    }
    if (progressPercentage > 1) {
        progressPercentage = 1;
    }
    [self p_refreshUI:progressPercentage isIncrease:isIncrease];
    [self setNeedsLayout];
}

- (void)setMode:(TTMovieAdjustViewMode)mode {
    _mode = mode;
    [self p_refreshUIStyle];
}

+ (CGFloat)heightWithMode:(TTMovieAdjustViewMode)mode {
    if (mode == TTMovieAdjustViewModeFullScreen) {
        return 120;
    } else {
        UIImage *img = [UIImage themedImageNamed:@"brightness_video"];
        return img.size.height + kProgressLabelPaddingTop + kProgressLabelFont;
    }
}

- (void)p_refreshUIStyle {
    if (_mode == TTMovieAdjustViewModeFullScreen) {
        UIColor *color = [UIColor tt_defaultColorForKey:kColorBackground11];
        self.backgroundColor = [color colorWithAlphaComponent:0.8];
        _progressLabel.font = [UIFont systemFontOfSize:kProgressLabelFont];
        _progressLabel.layer.shadowColor = nil;
        _sliderView.hidden = NO;
    } else {
        self.backgroundColor = [UIColor clearColor];
        _progressLabel.font = [UIFont boldSystemFontOfSize:kProgressLabelFont];
        _progressLabel.layer.shadowOpacity = 0.9;
//        _progressLabel.layer.shadowOffset = CGSizeMake(0, 2.5);
        _progressLabel.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        _sliderView.hidden = YES;
    }
}

- (void)p_refreshUI:(CGFloat)progressPercentage isIncrease:(BOOL)isIncrease {
    UIImage *img = nil;
    switch (_type) {
        case TTMovieAdjustViewTypeProgress:
        {
            img = isIncrease ? [UIImage themedImageNamed:@"forward_video"] : [UIImage themedImageNamed:@"back_video"];
        }
            break;
        case TTMovieAdjustViewTypeBrightness:
        {
            img = [UIImage themedImageNamed:@"brightness_video"];
        }
            break;
        default:
            break;
    }
    _logoImageView.image = img;
    _logoImageView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    if (_type == TTMovieAdjustViewTypeProgress) {
        NSInteger curTime = _totalTime * progressPercentage;
        NSInteger curHour = curTime / 3600;
        NSInteger curMinute = curTime % 3600 / 60;
        NSInteger curSecond = curTime % 60;
        NSInteger totalHour = _totalTime / 3600;
        NSInteger totalMinute = _totalTime % 3600 / 60;
        NSInteger totalSecond = _totalTime % 60;
        NSString *curTimeStr, *totalTimeStr;
        if (_totalTime > 3600) {
            curTimeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", curHour, curMinute, curSecond];
            totalTimeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", totalHour, totalMinute, totalSecond];
        } else {
            curTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", curMinute, curSecond];
            totalTimeStr = [NSString stringWithFormat:@"%02ld:%02ld", totalMinute, totalSecond];
        }
        NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", curTimeStr, totalTimeStr] attributes:@{NSForegroundColorAttributeName:[UIColor tt_defaultColorForKey:kColorText12]}];
        if (_mode == TTMovieAdjustViewModeFullScreen) {
            [aStr setAttributes:@{NSForegroundColorAttributeName:[UIColor tt_defaultColorForKey:kColorText4]} range:NSMakeRange(0, curTimeStr.length)];
        }
        _progressLabel.attributedText = aStr;
    } else {
        NSInteger progress = 100 * progressPercentage;
        _progressLabel.text = [NSString stringWithFormat:@"%ld%%", progress];
    }
    [_progressLabel sizeToFit];
    [_sliderView setProgressPercentage:progressPercentage];
}

- (void)p_hideSelf {
    self.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_mode == TTMovieAdjustViewModeFullScreen) {
        _logoImageView.top = 20;
        _logoImageView.centerX = self.width / 2;
        _progressLabel.top = _logoImageView.bottom + kProgressLabelPaddingTop;
        _progressLabel.centerX = _logoImageView.centerX;
        _sliderView.width = self.width - 2 * kSliderPaddingHorizontal;
        _sliderView.bottom = self.height - kSliderPaddingBottom;
        _sliderView.centerX = _logoImageView.centerX;
    } else {
        _logoImageView.top = 0;
        _logoImageView.centerX = self.width / 2;
        _progressLabel.top = _logoImageView.bottom + kProgressLabelPaddingTop;
        _progressLabel.centerX = _logoImageView.centerX;
    }
}

@end
