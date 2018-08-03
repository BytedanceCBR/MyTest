//
//  TTRefreshView.m
//  TestUniversaliOS6
//
//  Created by yuxin on 3/31/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTLoadMoreView.h"
#import "UIScrollView+Refresh.h"
#import "TTLoadingView.h"
#import "SSThemed.h"

@interface TTLoadMoreView ()
{
    NSString *_pullText;
    NSString *_loadingText;
    NSString *_noMoreText;
    NSString *_timeText;
    NSString *_timeKey;
    NSString *_initText;
}

@property (nonatomic,weak) IBOutlet SSThemedLabel * titleLabel;
@property (nonatomic,weak) IBOutlet UILabel * subtitleLabel;
@property (nonatomic,weak) IBOutlet TTLoadingView * refreshAnimationView;
@property (nonatomic,weak) IBOutlet SSThemedButton * refreshBtn;

@property (nonatomic,weak) IBOutlet SSThemedLabel * noContentLabel;

@property (nonatomic,assign) UIEdgeInsets restingContentInset;
//当出现网络错误时 标记不刷新
@property (nonatomic,assign) BOOL hasNetError;

@end

@implementation TTLoadMoreView

- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction
{
    NSString *tmpInit = kTTPullRefreshTextUp;
    NSString *tmpPull = kTTPullRefreshTextRefresh;
    NSString *tmpNo = kTTPullRefreshTextNomore;
    if (direction == PULL_DIRECTION_DOWN) {
        tmpInit = kTTPullRefreshTextDown;
        tmpPull = kTTPullRefreshTextMore;
        tmpNo = nil;
    }
    return [self initWithFrame:frame
                 pullDirection:direction
                      initText:tmpInit
                      pullText:tmpPull
                   loadingText:kTTPullRefreshTextLoading
                    noMoreText:tmpNo];
}

- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction initText:(NSString *)initText pullText:(NSString *)pullText
        loadingText:(NSString *)loadingText noMoreText:(NSString *)noMoreText
{
    return [self initWithFrame:frame
                 pullDirection:direction
                      initText:initText
                      pullText:pullText
                   loadingText:loadingText
                    noMoreText:noMoreText
                      timeText:nil
                   lastTimeKey:nil];
}

- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction initText:(NSString *)initText pullText:(NSString *)pullText
        loadingText:(NSString *)loadingText noMoreText:(NSString *)noMoreText timeText:(NSString *)timeText lastTimeKey:(NSString *)timeKey
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"TTLoadMoreView" owner:self options:nil];
    self = nibViews.firstObject;
    self.frame = frame;
    if (self) {
        _direction = direction;
        _initText = initText;
        _pullText = pullText;
        _noMoreText = noMoreText;
        _loadingText = loadingText;
        _timeText = timeText;
        _timeKey = timeKey;
        _state = -1;
        self.state = PULL_REFRESH_STATE_INIT;
        self.titleLabel.textColorThemeKey = kColorText2;
        self.noContentLabel.textColorThemeKey = kColorText2;
        self.refreshBtn.titleColorThemeKey = kColorText2;
        self.refreshBtn.backgroundColorThemeKey = kColorBackground4;
        _enabled = YES;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview && newSuperview == nil) {
        if (self.isObserving) {
            [self removeObserve:(UIScrollView*)self.superview];
        }
    }
}



- (NSString *)getStandardTimestringFromSeconds:(NSInteger)seconds
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *_date = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:_date]];
}

- (NSString *)processRefreshTime:(NSInteger)lastUpdate
{
    NSString *tmp;
    if (lastUpdate == 0) {
        tmp = kTTPUllRefreshTimeTextZero;
    } else {
        tmp = [self getStandardTimestringFromSeconds:lastUpdate];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@ %@", _timeText, tmp];
    return result;
}

- (void)setState:(PullDirectionState)state
{
    if (state == _state) {
        return;
    }
    self.noContentLabel.text = @"";

    NSString *tmp;
    switch (state) {
        case PULL_REFRESH_STATE_INIT:

            
            _refreshAnimationView.hidden = NO;
            _titleLabel.hidden = NO;
            _refreshBtn.hidden = YES;
            _noContentLabel.hidden = YES;
            
            if (_direction == PULL_DIRECTION_DOWN) {
                [_refreshAnimationView setArrowDirection:TTLoadingArrowUp];
            } else {
                _refreshAnimationView.hidden = YES;
            }
            tmp = _initText;
            break;
        case PULL_REFRESH_STATE_PULL:

            _refreshAnimationView.hidden = NO;
            _titleLabel.hidden = NO;
            _refreshBtn.hidden = YES;
            _noContentLabel.hidden = YES;
            
            [UIView beginAnimations:nil context:NULL];
            if (_direction == PULL_DIRECTION_DOWN) {
                [_refreshAnimationView setArrowDirection:TTLoadingArrowUp];
            } else {
                _refreshAnimationView.hidden = YES;
            }
            tmp = _initText;
            [UIView commitAnimations];
            break;
        case PULL_REFRESH_STATE_PULL_OVER:

            _refreshAnimationView.hidden = NO;
            _titleLabel.hidden = NO;
            _refreshBtn.hidden = YES;
            _noContentLabel.hidden = YES;
            
            [UIView beginAnimations:nil context:NULL];
            if (_direction == PULL_DIRECTION_DOWN) {
                [_refreshAnimationView setArrowDirection:TTLoadingArrowDown];
            } else {
                _refreshAnimationView.hidden = YES;
            }
            tmp = _pullText;
            [UIView commitAnimations];
            break;
        case PULL_REFRESH_STATE_LOADING:
            
            _refreshAnimationView.hidden = NO;
            _titleLabel.hidden = NO;
            _refreshBtn.hidden = YES;
            _noContentLabel.hidden = YES;
            
            _refreshAnimationView.hidden = NO;
            [_refreshAnimationView startLoading];
            
            tmp = _loadingText;
            
            break;
        case PULL_REFRESH_STATE_NO_MORE:
            
            _refreshAnimationView.hidden = YES;
            _titleLabel.hidden = YES;
            _refreshBtn.hidden = YES;
            _noContentLabel.hidden = NO;
            _noContentLabel.text = _noMoreText;
            
            break;
        default:
            break;
    }
    
    _titleLabel.text = tmp;
    _state = state;
    [_scrollView pullView:self stateChange:state];
}

- (void)setLastTime:(NSInteger)lastTime
{
    if (lastTime == _lastTime || !_timeKey || !_timeText) {
        return;
    }
    
    _lastTime = lastTime;
    [[NSUserDefaults standardUserDefaults] setInteger:_lastTime forKey:_timeKey];
    
    _subtitleLabel.text = [self processRefreshTime:_lastTime];
}

- (void)startObserve
{
    _isObserving = YES;
    _isObservingContentInset = YES;
    @try {
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];

    }
    @catch (NSException *exception) {
        
    }
    
}

- (void)removeObserve:(UIScrollView *)scrollView
{
    _isObserving = NO;
    _isObservingContentInset = NO;
    @try {
        [scrollView removeObserver:self forKeyPath:@"contentInset"];
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
    @catch (NSException *exception) {
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqual:@"contentInset"]) {
        
        if (self.scrollView.pullUpView && self.scrollView.pullDownView){
            
            if (self.isPullUp)
                return;
        }
        
        
        
        if ( self.state != PULL_REFRESH_STATE_LOADING ) {
            if (self.scrollView.originContentInset.bottom == 0) {
                self.scrollView.originContentInset = _scrollView.contentInset;
            }
            else
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.originContentInset.bottom, 0);
            
        }
        else
        {
            if (self.scrollView.originContentInset.bottom == 0) {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top-kTTPullRefreshHeight, 0, _scrollView.contentInset.bottom, 0);
            }
            else
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top-kTTPullRefreshHeight, 0, _scrollView.originContentInset.bottom, 0);
        }
        
        if ( self.state != PULL_REFRESH_STATE_LOADING ) {
            
            if (self.scrollView.pullUpView && !self.scrollView.isDone) {
                
                self.scrollView.originContentInset =  UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kTTPullRefreshHeight, 0);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self setScrollViewContentInsetWithOutObserve:self.scrollView.originContentInset];
                    
                });
                self.scrollView.isDone = YES;
                
            }
        }
        
    }
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self contentSizeChange:change];
    }
    
    if (self.hidden) {
        return;
    }

    
    TTRefreshView *sibling = _scrollView.pullDownView;
    if (_state == PULL_REFRESH_STATE_LOADING || (_scrollView.isMutex && sibling && sibling.state == PULL_REFRESH_STATE_LOADING)) {
        return;
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self contentOffsetChange:change];
    }
}



- (void)setEnabled:(BOOL)enabled {
    self.hidden = !enabled;
    _enabled = enabled;
}
- (void)contentSizeChange:(NSDictionary *)change
{
    if (_direction == PULL_DIRECTION_DOWN) {
        return;
    }
    
    NSInteger y = MAX(_scrollView.contentSize.height, _scrollView.bounds.size.height-_scrollView.contentInset.top);
    self.frame = CGRectMake(0, y, self.bounds.size.width, kTTPullRefreshHeight);
    
    
    UIEdgeInsets dest = self.scrollView.originContentInset;
    if (!self.scrollView.isDone) {
        dest =  UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kTTPullRefreshHeight, 0);
        self.scrollView.originContentInset = dest;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setScrollViewContentInsetWithOutObserve:self.scrollView.originContentInset];
            
        });
        self.scrollView.isDone = YES;
    }
}

- (void)contentOffsetChange:(NSDictionary *)change
{
    CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
    if (!self.enabled) {
        return;
    }
  
    if (point.y + self.scrollView.contentInset.top >= 0 && _direction == PULL_DIRECTION_UP) {
        [self processPullUp:(float)point.y];
    }
}



- (void)processPullUp:(float)y
{
    if (!self.window) {
        return;
    }
    
    self.hasMore = _scrollView.hasMore;

    if (!self.hasMore) {
        self.state = PULL_REFRESH_STATE_NO_MORE;
        return;
    }
    
    if (self.hasNetError) {
        return;
    }
    NSInteger calY = y + _scrollView.bounds.size.height;
    NSInteger height = MAX(_scrollView.contentSize.height, _scrollView.bounds.size.height);
    
    NSInteger bottomInset = _scrollView.contentInset.bottom;

    
    if (calY > height + bottomInset) {
        if (_state != PULL_REFRESH_STATE_LOADING && _state != PULL_REFRESH_STATE_NO_MORE) {
            self.state = PULL_REFRESH_STATE_LOADING;
            [self setScrollInsets:YES];
        }
    }
}

- (void)setScrollInsets:(BOOL)animation
{
    UIEdgeInsets dest = self.scrollView.originContentInset;

    //这里是加个逻辑，大部分tableView是有刷新和加载更多的，但如果只有加载更多，且如果没有设置contentInset 那么这里走一下初始化逻辑
    if (!self.scrollView.isDone) {
        dest =  UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kTTPullRefreshHeight, 0);
        self.scrollView.originContentInset = dest;
        
        self.scrollView.isDone = YES;
    }
    
 
    [UIView animateWithDuration:0.4 animations:^{
        
        [self setScrollViewContentInsetWithOutObserve:dest];
        
        
    } completion:^(BOOL finished) {
        
        
    }];

    [self doHandler];

}

- (void)setScrollViewContentInsetWithOutObserve:(UIEdgeInsets) inset {
    
    if (_scrollView.pullUpView && _scrollView.pullUpView.isObservingContentInset) {
        
        @try {
            
            [_scrollView removeObserver:_scrollView.pullUpView forKeyPath:@"contentInset"];
            _scrollView.pullUpView.isObservingContentInset = NO;
        }
        @catch (NSException *exception) {
            
        }
        
    }
    if (_scrollView.pullDownView && _scrollView.pullDownView.isObservingContentInset) {
        
        @try {
            
            [_scrollView removeObserver:_scrollView.pullDownView forKeyPath:@"contentInset"];
            _scrollView.pullDownView.isObservingContentInset = NO;
        }
        @catch (NSException *exception) {
            
        }
    }
    
    _scrollView.contentInset =  inset;
    
    
    if (_scrollView.pullUpView && !_scrollView.pullUpView.isObservingContentInset) {

        @try {
            [_scrollView addObserver:_scrollView.pullUpView forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            _scrollView.pullUpView.isObservingContentInset = YES;

        }
        @catch (NSException *exception) {
            
        }
      
       
    }
    
    if (_scrollView.pullDownView && !_scrollView.pullDownView.isObservingContentInset) {

        @try {
            [_scrollView addObserver:_scrollView.pullDownView forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            _scrollView.pullDownView.isObservingContentInset = YES;
            
        }
        @catch (NSException *exception) {
            
        }
    }
}

- (void)doHandler
{
    if (!self.hasNetError) {
        if (_actionHandler) {
            _actionHandler();
        }
    }
}

- (IBAction)refreshBtnTouched:(id)sender
{
    self.state = PULL_REFRESH_STATE_LOADING;
    self.refreshBtn.hidden = YES;
    if(_actionHandler)
        _actionHandler();
}

- (void)stopAnimation:(BOOL)success
{
    if (_timeKey && _timeText) {
        NSDate *date = [NSDate date];
        NSInteger time = [date timeIntervalSince1970];
        _subtitleLabel.text = [self processRefreshTime:time];
    }
    
    [_refreshAnimationView stopLoading];
    
    if (!success && self.isPullUp) {
        
        self.hasNetError = YES;
        self.state = PULL_REFRESH_STATE_INIT;
        self.refreshBtn.hidden = NO;

    }
    else {
 
        self.hasNetError = NO;
        self.state = PULL_REFRESH_STATE_INIT;
        self.refreshBtn.hidden = YES;
        
    }
}

- (void)triggerRefresh
{
    if (self.hidden) {
        return;
    }
    
    self.isUserPullAndRefresh = NO;
    
    self.state = PULL_REFRESH_STATE_LOADING;
    if (_direction == PULL_DIRECTION_DOWN) {
        [_scrollView setContentOffset:CGPointMake(0, -kTTPullRefreshHeight - _scrollView.contentInset.top) animated:NO];
    } else {
        CGFloat offset = _scrollView.contentSize.height - _scrollView.bounds.size.height;
        if (offset > 0) {
            [_scrollView setContentOffset:CGPointMake(0, offset + kTTPullRefreshHeight) animated:NO];
        }
    }
    [self setScrollInsets:YES];
}

- (void)setHasMore:(BOOL)hasMore
{
    _hasMore = hasMore;
    if (!_hasMore) {
        self.state = PULL_REFRESH_STATE_NO_MORE;
    }
    else {
        self.state = PULL_REFRESH_STATE_INIT;

    }
}

@end
