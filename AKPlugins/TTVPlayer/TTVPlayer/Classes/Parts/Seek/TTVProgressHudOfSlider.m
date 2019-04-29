//
//  TTVProgressHudOfSlider.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/22.
//

#import "TTVProgressHudOfSlider.h"
#import "TTVProgressViewOfSlider.h"
#import "UIImage+TTVHelper.h"
#import <CoreText/CoreText.h>

@interface TTVProgressHudOfSlider ()
@end

@implementation TTVProgressHudOfSlider

@synthesize progressView = _progressView, showCancel = _showCancel, timeLabel = _timeLabel, currentTimeTextColorString = _currentTimeTextColorString, totalTimeTextColorString = _totalTimeTextColorString, textSize = _textSize, isShowing = _isShowing, totalTime = _totalTime, progress, cacheProgress, backgroundView = _backgroundView;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.12f];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.alpha = 0;
        self.isShowing = NO;
        [self _buildViewHierarchy];
    }
    return self;
}

#pragma mark -
- (void)showWithCompletion:(void (^)(BOOL finished))completion {
    
    if (self.isShowing)  {
        if (completion) {
            completion(YES);
        }
        return;
    };
    self.isShowing = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)dismissWithCompletion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.isShowing = NO;
        if (finished) {
            [self setShowCancel:NO];
        }
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    self.timeLabel.attributedText = [self _timeStringForProgress:progress];
    [self setNeedsLayout];
    [self.progressView setProgress:progress animated:animated];
}

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setCacheProgress:progress animated:animated];
}

- (CGFloat)progress {
    return self.progressView.progress;
}

- (CGFloat)cacheProgress {
    return self.progressView.cacheProgress;
}
- (void)setShowCancel:(BOOL)showCancel {
    if (_showCancel != showCancel) {
        _showCancel = showCancel;
        [UIView animateWithDuration:0.2 animations:^{
            self.progressContainer.alpha = showCancel ? 0 : 1;
            self.cancelContainer.alpha = showCancel ? 1 : 0;
        }];
    }
}

#pragma mark -
#pragma mark private methods
- (NSAttributedString *)_timeStringForProgress:(CGFloat)progress {
    NSTimeInterval currentTime = self.totalTime * progress;
    
    NSString *currentTimeStr;
    NSString *totalTimeStr;
    
    int totalHour, totalMin, totalSec, currentHour, currentMin, currentSec;
    
    currentHour = ((int)currentTime) / 3600;
    currentMin  = ((int)currentTime) % 3600 / 60;
    currentSec  = ((int)currentTime) % 60;
    totalHour   = ((int)self.totalTime) / 3600;
    totalMin    = ((int)self.totalTime) % 3600 / 60;
    totalSec    = ((int)self.totalTime) % 60;
    
    if (self.totalTime > 3600) {
        totalTimeStr = [NSString stringWithFormat:@"%02d:%02d:%02d", totalHour, totalMin, totalSec];
    } else {
        totalTimeStr = [NSString stringWithFormat:@"%02d:%02d", totalMin, totalSec];
    }
    
    if (currentTime > 3600) {
        currentTimeStr = [NSString stringWithFormat:@"%02d:%02d:%02d", currentHour, currentMin, currentSec];
    } else {
        currentTimeStr = [NSString stringWithFormat:@"%02d:%02d", currentMin, currentSec];
    }
    
    UIFont *font = [UIFont fontWithDescriptor:self.fontDescriptor size:[TTVPlayerUtility tt_fontSize:23.f]];
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:currentTimeStr];
    [attributedString1 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [currentTimeStr length])];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[TTVPlayerUtility colorWithHexString:self.currentTimeTextColorString] range:NSMakeRange(0, [currentTimeStr length])];
    
    totalTimeStr = [NSString stringWithFormat:@" / %@",totalTimeStr];
    
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:totalTimeStr];
    [attributedString2 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [totalTimeStr length])];
    [attributedString2 addAttribute:NSForegroundColorAttributeName value:[TTVPlayerUtility colorWithHexString:self.totalTimeTextColorString] range:NSMakeRange(0, [totalTimeStr length])];
    [attributedString1 appendAttributedString:attributedString2];
    return attributedString1;
}

#pragma mark -
#pragma mark UI

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressContainer.frame = self.bounds;
    self.cancelContainer.frame = self.bounds;
    
    //progress
    self.timeLabel.width = self.width;
    [self.timeLabel sizeToFit];
    self.timeLabel.center = CGPointMake(self.width / 2, self.height / 2 - 6);
    
    self.progressView.height = 2;
    self.progressView.top = self.timeLabel.bottom + 8;
    self.progressView.width = 96;
    self.progressView.centerX = self.width / 2;
    
    //cancel
    self.cancelView.size = self.cancelView.image.size;
    self.cancelView.center = CGPointMake(self.width / 2, self.height / 2 - 10);
    
    self.cancelLabel.centerX = self.width / 2;
    self.cancelLabel.top = self.cancelView.bottom;
    
    // background
    self.backgroundView.center = CGPointMake(self.width/2.0, self.height/2.0);
    self.backgroundView.left = self.timeLabel.left - 20;
    self.backgroundView.width = self.timeLabel.width + 20*2;//self.width - self.backgroundView.left * 2;
}

- (void)_buildViewHierarchy {
    [self addSubview:self.backgroundView];
    [self addSubview:self.progressContainer];
    [self addSubview:self.cancelContainer];
    [self.progressContainer addSubview:self.timeLabel];
    [self.progressContainer addSubview:self.progressView];
    [self.cancelContainer addSubview:self.cancelView];
    [self.cancelContainer addSubview:self.cancelLabel];
}

#pragma mark -
#pragma mark getters
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 174, 80)];
        _backgroundView.layer.cornerRadius = 4;
    }
    return _backgroundView;
}
- (UIView *)progressContainer {
    if (!_progressContainer) {
        _progressContainer = [[UIView alloc] init];
    }
    return _progressContainer;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont fontWithDescriptor:self.fontDescriptor size:self.textSize];
    }
    return _timeLabel;
}

- (UIView<TTVProgressViewOfSliderProtocol> *)progressView {
    if (!_progressView) {
        _progressView = [[TTVProgressViewOfSlider alloc] init];
        _progressView.layer.cornerRadius = 2;
    }
    return _progressView;
}

- (UIView *)cancelContainer {
    if (!_cancelContainer) {
        _cancelContainer = [[UIView alloc] init];
        _cancelContainer.alpha = 0;
    }
    return _cancelContainer;
}

- (UIImageView *)cancelView {
    if (!_cancelView) {
        UIImage *iconImage = [UIImage ttv_ImageNamed:@"cancelSchedule"];
        _cancelView = [[UIImageView alloc] initWithImage:iconImage];
    }
    return _cancelView;
}

- (UILabel *)cancelLabel {
    if (!_cancelLabel) {
        _cancelLabel = [[UILabel alloc] init];
        _cancelLabel.textColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        _cancelLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
        _cancelLabel.text = @"松开手指 取消进退";
        _cancelLabel.layer.shadowOpacity = 1.f;
        _cancelLabel.layer.shadowOffset = CGSizeZero;
        _cancelLabel.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.54f].CGColor;
        _cancelLabel.layer.shadowRadius = 1.f;
        [_cancelLabel sizeToFit];
    }
    return _cancelLabel;
}

//固定timeLabel的字符宽度，防止抖动
- (UIFontDescriptor *)fontDescriptor {
    UIFontDescriptor *newDescriptor = nil;
    if (@available(iOS 8.2, *)) {
        NSArray *monospacedSetting = @[@{UIFontFeatureTypeIdentifierKey :  @(kNumberSpacingType),
                                         UIFontFeatureSelectorIdentifierKey :  @(kMonospacedNumbersSelector),
                                         UIFontWeightTrait : @(UIFontWeightMedium)}];
        UIFont *font = [UIFont systemFontOfSize:0];
        newDescriptor = [[font fontDescriptor] fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute : monospacedSetting}];
    } else {
        NSArray *monospacedSetting = @[@{UIFontFeatureTypeIdentifierKey :  @(kNumberSpacingType),
                                         UIFontFeatureSelectorIdentifierKey :  @(kMonospacedNumbersSelector)}];
        UIFont *font = [UIFont systemFontOfSize:0];
        newDescriptor = [[font fontDescriptor] fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute : monospacedSetting}];
        // Fallback on earlier versions
    }
    return newDescriptor;
}

@end
