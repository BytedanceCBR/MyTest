//
//  FHVideoMiniSliderView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/18.
//

#import "FHVideoMiniSliderView.h"
#import "UIColor+Theme.h"

@interface FHVideoMiniSliderView ()

@property(nonatomic, strong) UIView *cachedProgressView;
@property(nonatomic, strong) UIView *watchedProgressView;

@end

@implementation FHVideoMiniSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        
        self.cachedProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:_cachedProgressView];
        _cachedProgressView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _cachedProgressView.backgroundColor = [UIColor themeGray7];
        
        self.watchedProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:_watchedProgressView];
        _watchedProgressView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _watchedProgressView.backgroundColor = [UIColor themeRed1];
    }
    
    return self;
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    if (cacheProgress > 100) {
        cacheProgress = 100;
    }
    _cacheProgress = cacheProgress;
    [self setNeedsLayout];
}

- (void)setWatchedProgress:(CGFloat)watchedProgress {
    if (watchedProgress > 100) {
        watchedProgress = 100;
    }
    _watchedProgress = watchedProgress;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    if (isnan(_cacheProgress) || isnan(_watchedProgress) || _cacheProgress == NAN || _watchedProgress == NAN) {
        return;
    }
    
    if (_isVerticle) {
        CGFloat cacheH = self.frame.size.height * (_cacheProgress / 100.0);
        CGFloat watchH = self.frame.size.height * (_watchedProgress / 100.0);
        
        _cachedProgressView.frame = CGRectMake(0, self.frame.size.height-cacheH, self.frame.size.width, cacheH);
        _watchedProgressView.frame = CGRectMake(0, self.frame.size.height-watchH, self.frame.size.width, watchH);
    } else {
        CGFloat cacheW = self.frame.size.width * (_cacheProgress / 100.0);
        CGFloat watchW = self.frame.size.width * (_watchedProgress / 100.0);
        
        _cachedProgressView.frame = CGRectMake(0, 0, cacheW, self.frame.size.height);
        _watchedProgressView.frame = CGRectMake(0, 0, watchW, self.frame.size.height);
    }
}

@end
