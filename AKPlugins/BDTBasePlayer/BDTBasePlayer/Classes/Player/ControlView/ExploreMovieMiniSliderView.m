//
//  ExploreMovieMiniSliderView.m
//  Article
//
//  Created by Chen Hong on 15/5/27.
//
//

#import "ExploreMovieMiniSliderView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "TTVPlayerSliderMarkPointView.h"

@interface ExploreMovieMiniSliderView ()

@property(nonatomic, strong)SSThemedView *cachedProgressView;
@property(nonatomic, strong)SSThemedView *watchedProgressView;
@property(nonatomic, strong)TTVPlayerSliderMarkPointView *pointView;


@end

@implementation ExploreMovieMiniSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground9;
        self.clipsToBounds = YES;
        
        self.cachedProgressView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:_cachedProgressView];
        _cachedProgressView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _cachedProgressView.backgroundColorThemeKey = kColorBackground1;
        
        self.watchedProgressView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:_watchedProgressView];
        _watchedProgressView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        _watchedProgressView.backgroundColorThemeKey = kColorBackground7;
        
        _pointView = [[TTVPlayerSliderMarkPointView alloc] initWithFrame:self.bounds style:TTVPlayerSliderMarkPointStyleMini];
        [self addSubview:_pointView];
        _pointView.hidden = YES;
    }
    
    return self;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        _playerStateStore = playerStateStore;
        _pointView.playerStateStore = playerStateStore;
    }
}

- (void)setCacheProgress:(CGFloat)cacheProgress
{
    if (cacheProgress > 100) {
        cacheProgress = 100;
    }
    _cacheProgress = cacheProgress;
    [self setNeedsLayout];
}

- (void)setWatchedProgress:(CGFloat)watchedProgress
{
    if (watchedProgress > 100) {
        watchedProgress = 100;
    }
    _watchedProgress = watchedProgress;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
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
    
    _pointView.frame = self.bounds;
    [_pointView updateFrame];
}

@end
