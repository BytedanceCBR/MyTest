//
//  TTUploadingStatusCellProgressBar.m
//  Article
//
//  Created by 徐霜晴 on 16/10/9.
//
//

#import "TTThemedUploadingStatusCellProgressBar.h"
#import <TTBaseLib/TTDeviceHelper.h>

static const CGFloat kAnimationDuration = 0.5;

@interface TTThemedUploadingStatusCellProgressBar ()

@property (nonatomic, strong) SSThemedView *progressView;
@property (nonatomic, assign) CGFloat progress;

@end

@implementation TTThemedUploadingStatusCellProgressBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.progressView];
    }
    return self;
}

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey {
    [super setBackgroundColorThemeKey:backgroundColorThemeKey];
}

- (void)setForegroundColorThemeKey:(NSString *)foregroundColorThemeKey {
    [self.progressView setBackgroundColorThemeKey:foregroundColorThemeKey];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (progress > 1.0) {
        progress = 1.0;
    }
    if (progress < 0.0) {
        progress = 0.0;
    }
    
    self.progress = progress;
    
    //iOS7上，设置UIViewAnimationOptionBeginFromCurrentState进度条会闪动，但打log发现设置的frame复合预期，写demo未出现闪动问题，只能暂时分版本处理
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
        options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState;
    }
    
    CGRect frame = self.bounds;
    frame.size.width = floor(CGRectGetWidth(self.bounds) * self.progress);
    [UIView animateWithDuration:animated ? kAnimationDuration : 0.0
                          delay:0.0
                        options:options
                     animations:^{
                         self.progressView.frame = frame;
                     }
                     completion:nil];
}

#pragma mark - accessors

- (SSThemedView *)progressView {
    if (!_progressView) {
        _progressView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) * self.progress, CGRectGetHeight(self.bounds))];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return _progressView;
}

@end
