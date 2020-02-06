//
//  TTStateLoadMoreView.m
//  TTUIWidget
//
//  Created by carl on 2018/3/1.
//

#import "TTStateLoadMoreView.h"

#import <TTThemed/SSThemed.h>
#import "TTLoadingView.h"
#import "UIScrollView+Refresh.h"
#import <Masonry/Masonry.h>


const NSInteger kPullUpViewHeight = 80;

@interface TTStateLoadMoreView ()
{
    NSString *_pullText;
    NSString *_loadingText;
    NSString *_noMoreText;
    NSString *_timeText;
    NSString *_timeKey;
    NSString *_initText;
}

@property (nonatomic, strong) SSThemedButton *refreshBtn;

@property (nonatomic, strong) SSThemedView<TTLoadMoreStateView> *nomoreView;

@property (nonatomic, assign) UIEdgeInsets restingContentInset;
//当出现网络错误时 标记不刷新
@property (nonatomic, assign) BOOL hasNetError;

@end

@implementation TTStateLoadMoreView

- (void)dealloc {
    [self removeObserve:_scrollView];
}

- (instancetype)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        _state = -1;
        _direction = direction;
        self.state = PULL_REFRESH_STATE_INIT;
        _enabled = YES;
        [self buidupView];
    }
    return self;
}

- (void)buidupView {
    self.backgroundColorThemeKey = kColorBackground3;
    TTLoadMoreStateNomoreView *stateView = [[TTLoadMoreStateNomoreView alloc] initWithFrame:self.bounds];
    [self addSubview:stateView];
    self.nomoreView = stateView;
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 15, 0, 15));
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        if (self.isObserving) {
            [self removeObserve:(UIScrollView*)self.superview];
        }
    }
}

- (void)startObserve {
    _isObserving = YES;
    _isObservingContentInset = YES;
    @try {
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewPan:)];
    } @catch (NSException *exception) {
    }
}

- (void)removeObserve:(UIScrollView *)scrollView
{
    if (!scrollView) {
        return;
    }
    
    @try {
        if (_isObservingContentInset) {
             _isObservingContentInset = NO;
            [scrollView removeObserver:self forKeyPath:@"contentInset"];
        }
        if (_isObserving) {
             _isObserving = NO;
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"contentSize"];
            [_scrollView.panGestureRecognizer removeTarget:self action:@selector(scrollViewPan:)];
        }
    } @catch (NSException *exception) {
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
            } else {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.originContentInset.bottom, 0);
            }
        } else {
            if (self.scrollView.originContentInset.bottom == 0) {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top - kTTPullRefreshHeight, 0, _scrollView.contentInset.bottom, 0);
            } else {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top- kTTPullRefreshHeight, 0, _scrollView.originContentInset.bottom, 0);
            }
        }
        
        if (self.state != PULL_REFRESH_STATE_LOADING) {
            if (self.scrollView.pullUpView && !self.scrollView.isDone) {
                self.scrollView.originContentInset =  UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kPullUpViewHeight, 0);
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

- (void)scrollViewPan:(UIPanGestureRecognizer *)recognizer {

    CGPoint translation = [recognizer translationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.nomoreView.state == PULL_REFRESH_STATE_PULL) {
            [self.nomoreView reduxState:PULL_REFRESH_STATE_INIT];
        }
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
    
    NSInteger y = MAX(_scrollView.contentSize.height, _scrollView.bounds.size.height - _scrollView.contentInset.top);
    self.frame = CGRectMake(0, y, self.bounds.size.width, kPullUpViewHeight);
    
    UIEdgeInsets dest = self.scrollView.originContentInset;
    if (!self.scrollView.isDone) {
        dest =  UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kPullUpViewHeight, 0);
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
    BOOL hasMore = _scrollView.hasMore;
    
    if (!hasMore) {
        self.state = PULL_REFRESH_STATE_NO_MORE;
    }
    
    if (self.hasNetError) {
        return;
    }
 
    NSInteger calY = y + _scrollView.bounds.size.height;
    NSInteger height = MAX(_scrollView.contentSize.height, _scrollView.bounds.size.height);
    NSInteger bottomInset = _scrollView.contentInset.bottom;
    
    const NSInteger threshold = height + bottomInset;
    const NSInteger range = 40;
    if (calY <= threshold) {
        [self.nomoreView reduxState:PULL_REFRESH_STATE_INIT];
    } else if (calY >= threshold + range) {
        if (self.scrollView.isDragging) {
            [self.nomoreView reduxState:PULL_REFRESH_STATE_PULL_OVER];
        } else if (self.nomoreView.state == PULL_REFRESH_STATE_PULL_OVER) {
            [self.nomoreView reduxState:PULL_REFRESH_STATE_LOADING];
            [self setScrollInsets:YES];
        }
    } else if (calY < threshold + range) {
        if (self.scrollView.isDragging) {
            [self.nomoreView reduxState:PULL_REFRESH_STATE_PULL];
        } else {
            [self.nomoreView reduxState:PULL_REFRESH_STATE_INIT];
        }
    }
    if ([self.nomoreView respondsToSelector:@selector(updateScrollPercent:)]) {
        CGFloat percent = (calY - threshold) * 1.0 / 400;
        [self.nomoreView updateScrollPercent:MAX(MIN(percent, 0.15), 0)];
    }
}

- (void)setScrollInsets:(BOOL)animation
{
    UIEdgeInsets dest = self.scrollView.originContentInset;
    
    //这里是加个逻辑，大部分tableView是有刷新和加载更多的，但如果只有加载更多，且如果没有设置contentInset 那么这里走一下初始化逻辑
    if (!self.scrollView.isDone) {
        dest = UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kPullUpViewHeight, 0);
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
        } @catch (NSException *exception) {
        }
    }
    
    if (_scrollView.pullDownView && _scrollView.pullDownView.isObservingContentInset) {
        @try {
            [_scrollView removeObserver:_scrollView.pullDownView forKeyPath:@"contentInset"];
            _scrollView.pullDownView.isObservingContentInset = NO;
        } @catch (NSException *exception) {
        }
    }
    
    _scrollView.contentInset =  inset;
    
    if (_scrollView.pullUpView && !_scrollView.pullUpView.isObservingContentInset) {
        @try {
            [_scrollView addObserver:_scrollView.pullUpView forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            _scrollView.pullUpView.isObservingContentInset = YES;
        } @catch (NSException *exception) {
        }
    }
    
    if (_scrollView.pullDownView && !_scrollView.pullDownView.isObservingContentInset) {
        @try {
            [_scrollView addObserver:_scrollView.pullDownView forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            _scrollView.pullDownView.isObservingContentInset = YES;
        } @catch (NSException *exception) {
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

- (void)refreshBtnTouched:(id)sender
{
    self.state = PULL_REFRESH_STATE_LOADING;
    self.refreshBtn.hidden = YES;
    if (_actionHandler)
        _actionHandler();
}

- (void)stopAnimation:(BOOL)success
{
    if (!success && self.isPullUp) {
        self.hasNetError = YES;
    } else {
        self.hasNetError = NO;
    }
    self.state = PULL_REFRESH_STATE_INIT;
    [self.nomoreView reduxState:PULL_REFRESH_STATE_INIT];
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
            [_scrollView setContentOffset:CGPointMake(0, offset + kPullUpViewHeight) animated:NO];
        }
    }
    [self setScrollInsets:YES];
}

- (void)setHasMore:(BOOL)hasMore
{
    _hasMore = hasMore;
    if (!_hasMore) {
        self.state = PULL_REFRESH_STATE_NO_MORE;
    } else {
        self.state = PULL_REFRESH_STATE_INIT;
    }
}

@end
