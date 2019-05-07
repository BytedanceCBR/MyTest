//
//  TTVProgressViewOfSlider.m
//  Article
//
//  Created by liuty on 2017/1/8.
//
//

#import "TTVProgressViewOfSlider.h"

@interface TTVProgressViewOfSlider ()

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) CGFloat cacheProgress;

@end

@implementation TTVProgressViewOfSlider

@synthesize trackProgressView = _trackProgressView, cacheProgressView = _cacheProgressView;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [TTVPlayerUtility colorWithHexString:@"0xffffff4d"];
        [self _buildViewHierarchy];
    }
    return self;
}

#pragma mark -
#pragma mark public methods

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MIN(1, MAX(0, progress));
    self.progress = progress;
    [self.markView updateMarkColorWithProgress:progress];
    [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self _updateTrackProgress];
    } completion:nil];
}

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MIN(1, MAX(0, progress));
    self.cacheProgress = progress;
    [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self _updateCacheProgress];
    } completion:nil];
}

- (void)setMarkPoints:(NSArray<NSNumber *> *)markPoints
{
    _markPoints = markPoints;
    
    self.markView.markPoints = markPoints;
    self.markView.hidden = 0 == markPoints.count;
}

- (void)setOpeningPoints:(NSArray<NSNumber *> *)openingPoints
{
    _openingPoints = openingPoints;
    
    self.markView.openingPoints = openingPoints;
    self.markView.hidden = 0 == openingPoints.count;

}

#pragma mark -
#pragma mark UI

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _updateLayout];
    [self _updateCacheProgress];
    [self _updateTrackProgress];
}

- (void)_buildViewHierarchy {
    [self addSubview:self.cacheProgressView];
    [self addSubview:self.trackProgressView];
    [self addSubview:self.markView];
}

- (void)_updateLayout {
    self.trackProgressView.height = self.height;
    self.cacheProgressView.height = self.height;
    self.markView.width = self.width;
    self.markView.height = self.height;
}

- (void)_updateCacheProgress {
    self.cacheProgressView.width = self.width * self.cacheProgress;
}

- (void)_updateTrackProgress {
    self.trackProgressView.width = self.width * self.progress;
}

#pragma mark -
#pragma mark getters

- (UIView *)trackProgressView {
    if (!_trackProgressView) {
        _trackProgressView = [[UIView alloc] init];
        _trackProgressView.backgroundColor = [UIColor redColor];;
    }
    return _trackProgressView;
}

- (UIView *)cacheProgressView {
    if (!_cacheProgressView) {
        _cacheProgressView = [[UIView alloc] init];
        _cacheProgressView.backgroundColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:0.5f];
    }
    return _cacheProgressView;
}

- (TTVPlayerSliderMarkView *)markView
{
    if (!_markView) {
        _markView = [[TTVPlayerSliderMarkView alloc] init];
    }
    return _markView;
}


@end
