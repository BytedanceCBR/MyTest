//
//  TTMoviePlayerControlSliderView.m
//  Article
//
//  Created by xiangwu on 2016/12/28.
//
//

#import "TTVPlayerControlSliderView.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import "TTVPlayerSliderMarkPointView.h"

@interface TTVPlayerControlSliderView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, assign) CGPoint lastPanLocation;
@property (nonatomic, strong) TTVPlayerSliderMarkPointView *pointView;

@end

@implementation TTVPlayerControlSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [[UIColor colorWithHexString:@"ffffff"] colorWithAlphaComponent:0.35];
        _backView.layer.masksToBounds = YES;
        _backView.layer.borderWidth = 1;
        _backView.layer.borderColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.12].CGColor;
        [self addSubview:_backView];
        _cacheProgressView = [[UIView alloc] init];
        _cacheProgressView.backgroundColor = [UIColor whiteColor];
        _cacheProgressView.layer.masksToBounds = YES;
        [_backView addSubview:_cacheProgressView];
        _watchedProgressView = [[UIView alloc] init];
        _watchedProgressView.backgroundColor = [UIColor tt_defaultColorForKey:kColorLine2];
        _watchedProgressView.layer.masksToBounds = YES;
        [_backView addSubview:_watchedProgressView];
        
        _pointView = [[TTVPlayerSliderMarkPointView alloc] initWithFrame:self.watchedProgressView.bounds style:TTVPlayerSliderMarkPointStyleNormal];
        [_backView addSubview:_pointView];
        _pointView.hidden = YES;
        
        _thumbView = [[UIView alloc] init];
        _thumbView.backgroundColor = [UIColor whiteColor];
        _thumbView.layer.masksToBounds = YES;
        [self addSubview:_thumbView];
        self.duringDrag = NO;

    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGes:)];
    [newSuperview addGestureRecognizer:_panGes];
}

- (void)updateFrame {
    CGFloat backH = _isFull ? 2 : 1;
    _backView.frame= CGRectMake(0, 0, self.width, backH);
    _backView.centerY = self.height / 2;
    CGFloat w = _cacheProgress / 100.f * _backView.width;
    if (w > _backView.width) {
        w = _backView.width;
    }
    _cacheProgressView.frame = CGRectMake(0, 0, w, _backView.height);
    w = _watchedProgress / 100.f * _backView.width;
    if (w > _backView.width) {
        w = _backView.width;
    }
    _thumbView.centerX = w;
    _thumbView.centerY = _backView.centerY;
    _watchedProgressView.frame = CGRectMake(0, 0, w, _backView.height);
    _pointView.frame = _backView.bounds;
    [_pointView updateFrame];
}

- (void)updateThumbFrame {
    CGPoint center = _thumbView.center;
    _thumbView.frame = _duringDrag ? CGRectMake(0, 0, 22, 22) : _isFull ? CGRectMake(0, 0, 18, 18) : CGRectMake(0, 0, 15, 15);
    _thumbView.center = center;
    _thumbView.layer.cornerRadius = _thumbView.width / 2;
}

- (void)handlePanGes:(UIPanGestureRecognizer *)ges {
    CGPoint location = [ges locationInView:self.superview];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            _lastPanLocation = location;
            self.duringDrag = YES;
            if (_delegate && [_delegate respondsToSelector:@selector(sliderWatchedProgressWillChange:)]) {
                [_delegate sliderWatchedProgressWillChange:self];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat d = location.x - _lastPanLocation.x;
            self.watchedProgress = (self.thumbView.centerX + d) / self.width * 100.f;
            _lastPanLocation = location;
            if (_delegate && [_delegate respondsToSelector:@selector(sliderWatchedProgressChanging:)]) {
                [_delegate sliderWatchedProgressChanging:self];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            self.duringDrag = NO;
            if (_delegate && [_delegate respondsToSelector:@selector(sliderWatchedProgressChanged:)]) {
                [_delegate sliderWatchedProgressChanged:self];
            }
        }
            break;
        default:
            break;
    }
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        _playerStateStore = playerStateStore;
        _pointView.playerStateStore = self.playerStateStore;
    }
}

- (void)setWatchedProgress:(CGFloat)watchedProgress {
    if (watchedProgress < 0) {
        watchedProgress = 0;
    }
    if (watchedProgress > 100) {
        watchedProgress = 100;
    }
    _watchedProgress = watchedProgress;
    [self updateFrame];
}

- (void)setCacheProgress:(CGFloat)cacheProgress {
    if (cacheProgress < 0) {
        cacheProgress = 0;
    }
    if (cacheProgress > 100) {
        cacheProgress = 100;
    }
    _cacheProgress = cacheProgress;
    [self updateFrame];
}

- (void)setEnableDrag:(BOOL)enableDrag {
    _enableDrag = enableDrag;
    _panGes.enabled = enableDrag;
}

- (void)setDuringDrag:(BOOL)duringDrag {
    _duringDrag = duringDrag;
    [self updateThumbFrame];
}

- (void)setIsFull:(BOOL)isFull {
    _isFull = isFull;
    [self updateThumbFrame];
}

@end
