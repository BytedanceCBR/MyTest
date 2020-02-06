//
//  TTRefreshView.m
//  TestUniversaliOS6
//
//  Created by yuxin on 3/31/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTRefreshView.h"
#import "UIScrollView+Refresh.h"
#import "TTRefreshAnimationView.h"
#import "SSThemed.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import <TTKitchen/TTKitchen.h>
#import <TTServiceProtocols/TTImpactFeedbackProtocol.h>
#import <BDMobileRuntime/BDMobileRuntime.h>
#import <TTRegistry/TTRegistryDefines.h>
#import "TTAnimatedRefreshView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <Masonry/Masonry.h>
#import <TTBaseLib/NSObject+MultiDelegates.h>

CGFloat const gestureMinimumTranslation = 20.0;

@interface TTRefreshView ()

@property (nonatomic, copy) NSString *pullText;
@property (nonatomic, copy) NSString *loadingText;
@property (nonatomic, copy) NSString *noMoreText;
@property (nonatomic, copy) NSString *refreshInitText;

@property (nonatomic, strong) SSThemedView<TTRefreshAnimationDelegate> *refreshAnimateView;
@property (nonatomic, strong, readwrite) TTRefreshAnimationContainerView * defaultRefreshAnimateView;
@property (nonatomic, strong, readwrite) SSThemedView * bgView;
@property (nonatomic, strong) TTAnimatedRefreshView *animatedRefreshView;

//当出现网络错误时 标记不刷新
@property (nonatomic) BOOL hasNetError;
@property (nonatomic) BOOL hasNotifiedShowAttachView;
@property (nonatomic) BOOL hasNotifiedOverAttachView;
@property (nonatomic) BOOL needMessageBarReset;
@property (nonatomic) BOOL usingCustomAnimationView;

//下拉刷新增加震动效果控制
@property (nonatomic,assign) BOOL isPullWillHandsOff;//标记下拉刷新完就松手状态
@property (nonatomic,assign) BOOL isPullWithDragBackToTop;//标记下拉刷新一直是没有松手状态，记录是否回到看不见刷新区域
@property (nonatomic) PullMoveDirectionType pullMoveDirection;
@property (nonatomic, assign) UIEdgeInsets restingContentInset;
@property (nonatomic) CGPoint lastPanPoint;

@end

@implementation TTRefreshView

- (void)dealloc {
    [self removeObserve:_scrollView];
    @try {
        [_scrollView removeObserver:_scrollView.pullUpView forKeyPath:@"contentInset"];
        [_scrollView removeObserver:_scrollView.pullDownView forKeyPath:@"contentInset"];
    } @catch (NSException *exception) {
    }
}

- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction {
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

- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction initText:(NSString *)initText pullText:(NSString *)pullText loadingText:(NSString *)loadingText noMoreText:(NSString *)noMoreText {
    return [self initWithFrame:frame
                 pullDirection:direction
                      initText:initText
                      pullText:pullText
                   loadingText:loadingText
                    noMoreText:noMoreText
                      timeText:nil
                   lastTimeKey:nil];
}

- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction initText:(NSString *)initText pullText:(NSString *)pullText loadingText:(NSString *)loadingText noMoreText:(NSString *)noMoreText timeText:(NSString *)timeText lastTimeKey:(NSString *)timeKey {
    if (self = [super initWithFrame:frame]) {
        _direction = direction;
        _refreshInitText = initText;
        _pullText = pullText;
        _noMoreText = noMoreText;
        _loadingText = loadingText;
        _state = -1;
        _enabled = YES;
        self.isPullWillHandsOff = YES;
        
        self.pullRefreshLoadingHeight = kTTPullRefreshHeight;
        self.messagebarHeight = kTTPullRefreshLoadingHeight;
        self.secondsNeedScrollToLoading = KTTSecondsNeedScrollToLoading;
        self.refreshAnimateView = self.defaultRefreshAnimateView;

        self.animatedRefreshView = [[TTAnimatedRefreshView alloc] init];
        self.animatedRefreshView.hidden = YES;
        [self addSubview:self.animatedRefreshView];
        [self.animatedRefreshView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@(200));
        }];

        self.bgView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-800, self.frame.size.width, 800)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        [self sendSubviewToBack:self.bgView];
        
        self.state = PULL_REFRESH_STATE_INIT;
    }
    return self;
}

- (void)setPullRefreshLoadingHeight:(CGFloat)pullRefreshLoadingHeight {
    _pullRefreshLoadingHeight = pullRefreshLoadingHeight;
    if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(configurePullRefreshLoadingHeight:)]) {
        [self.refreshAnimateView configurePullRefreshLoadingHeight:_pullRefreshLoadingHeight];
    }
}

- (NSString *)refreshLoadingText {
    return _loadingText;
}

- (TTRefreshAnimationContainerView *)defaultRefreshAnimateView {
    @synchronized(self) {
        if (_defaultRefreshAnimateView == nil) {
            _defaultRefreshAnimateView = [[TTRefreshAnimationContainerView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) WithLoadingHeight:self.pullRefreshLoadingHeight WithinitText:_refreshInitText WithpullText:_pullText WithloadingText:_loadingText WithnoMoreText:_noMoreText];
        }
    }
    return _defaultRefreshAnimateView;
}

#pragma -- mark 动态设置RefreshAnimateView

//设置defaultRefreshAnimateView
- (void)resetWithDefaultAnimateViewWithConfigureSuccessCompletion:(RefreshCompletionBlock)completion {
    if (self.enableAnimatedRefresh) {
        return;
    }

    if (!self.defaultRefreshAnimateView) {
        return;
    }

    if (self.refreshAnimateView && self.refreshAnimateView == self.defaultRefreshAnimateView) {
        return;
    }

    RefreshCompletionBlock tempBlock = [completion copy];
    self.refreshAnimateView = self.defaultRefreshAnimateView;
    if (self.refreshAnimateView == self.defaultRefreshAnimateView) {
        if (tempBlock) {
            tempBlock(YES);
        }
    }
}

- (BOOL)configAnimatedRefreshWithImageStyle:(TTAnimatedRefreshStyle)imageStyle imageFilePath:(NSString *)imageFilePath lotComposition:(LOTComposition *)lotComposition lottieThreshold:(CGFloat)lottieThreshold width:(CGFloat)width height:(CGFloat)height {
    // 自定义AnimationView优先级高于AnimatedRefresh
    if (self.usingCustomAnimationView) {
        return NO;
    }

    self.animatedRefreshView.imageStyle = imageStyle;

    BOOL isImageSucess = [self.animatedRefreshView configureImageFilePath:imageFilePath lotComposition:lotComposition width:width height:height];
    self.enableAnimatedRefresh = isImageSucess;
    self.animatedRefreshView.lottieThreshold = lottieThreshold;

    return isImageSucess;
}

//动态设置refreshAnimateView
- (void)reConfigureWithRefreshAnimateView:(SSThemedView<TTRefreshAnimationDelegate> *)refreshAnimateView WithConfigureSuccessCompletion:(RefreshCompletionBlock)completion {
    if (!refreshAnimateView) {
        return;
    }
    
    if (self.refreshAnimateView && self.refreshAnimateView == refreshAnimateView) {
        return;
    }
    
    RefreshCompletionBlock tempBlock = [completion copy];
    
    self.refreshAnimateView = refreshAnimateView;
    if (self.refreshAnimateView == refreshAnimateView) {
        // 自定义了refreshAnimateView，则不显示animatedRefresh
        self.usingCustomAnimationView = YES;
        self.enableAnimatedRefresh = NO;

        if (tempBlock) {
            tempBlock(YES);
        }
    }
}

- (void)setRefreshAnimateView:(SSThemedView<TTRefreshAnimationDelegate> *)refreshAnimateView {
    if (self.state == PULL_REFRESH_STATE_LOADING) {
        return;
    }
    
    if (!refreshAnimateView) {
        return;
    }
    
    if (_refreshAnimateView && _refreshAnimateView == refreshAnimateView) {
        return;
    }

    if (_refreshAnimateView) {
        [_refreshAnimateView stopLoading];
    }
    
    if (_refreshAnimateView.superview) {
        [_refreshAnimateView removeFromSuperview];
    }
    
    _refreshAnimateView = refreshAnimateView;
    [self addSubview:_refreshAnimateView];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        if (self.isObserving) {
            [self removeObserve:(UIScrollView*)self.superview];
        }
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        if (self.state == PULL_REFRESH_STATE_LOADING) {
            // 恢复动画
            if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(startLoading)]) {
                [self.refreshAnimateView startLoading];
            }
        }
    }
}

- (void)setEnableAnimatedRefresh:(BOOL)enableAnimatedRefresh {
    _enableAnimatedRefresh = enableAnimatedRefresh;
    self.animatedRefreshView.hidden = !enableAnimatedRefresh;
    self.refreshAnimateView.hidden = enableAnimatedRefresh;
    self.defaultRefreshAnimateView.hidden = enableAnimatedRefresh;

    if (enableAnimatedRefresh) {
        self.bgView.backgroundColorThemeKey = kColorBackground20;
    } else {
        self.bgView.backgroundColorThemeKey = kColorBackground3;
    }
}

- (void)setTtAttachView:(SSThemedView<TTRefreshAttachViewDelegate> *)ttAttachView {
    _ttAttachView = ttAttachView;
    [self insertSubview:_ttAttachView aboveSubview:self.bgView];
}

- (void)setState:(PullDirectionState)state {
    if (state == _state) {
        return;
    }

    switch (state) {
        case PULL_REFRESH_STATE_INIT:
            self.hasNotifiedOverAttachView = NO;
            self.hasNotifiedShowAttachView = NO;
            self.isPullWillHandsOff = YES;

            [self showAnimationView];
            break;

        case PULL_REFRESH_STATE_PULL:
            break;

        case PULL_REFRESH_STATE_PULL_OVER:
            break;

        case PULL_REFRESH_STATE_LOADING:
            if (self.enableAnimatedRefresh) {
                [self.animatedRefreshView startAnimation];
            }
            if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(startLoading)]) {
                [self.refreshAnimateView performSelector:@selector(startLoading)];
            }
            if ([self.delegate respondsToSelector:@selector(refreshViewStartLoading:)]) {
                [self.delegate refreshViewStartLoading:self];
            }
            break;

        case PULL_REFRESH_STATE_NO_MORE:
            break;

        default:
            break;
    }

    if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(updateViewWithPullState:)]) {
        [self.refreshAnimateView updateViewWithPullState:state];
    }
    
    _state = state;
    [_scrollView pullView:self stateChange:state];
}

- (void)startObserve {
    _isObserving = YES;
    _isObservingContentInset = YES;
    @try {
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(gestureRecognizerUpdate:)];
    } @catch (NSException *exception) {
    }
}

- (void)removeObserve:(UIScrollView *)scrollView {
    _isObserving = NO;
    _isObservingContentInset = NO;
    @try {
        [scrollView removeObserver:self forKeyPath:@"contentInset"];
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [scrollView removeObserver:self forKeyPath:@"contentSize"];
        [_scrollView.panGestureRecognizer removeTarget:self action:@selector(gestureRecognizerUpdate:)];
    } @catch (NSException *exception) {
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"contentInset"]) {
        if (self.scrollView.pullUpView && self.scrollView.pullDownView){
            if (self.isPullUp) {
                return;
            }
        }

        if (self.state != PULL_REFRESH_STATE_LOADING) {
            if (self.scrollView.originContentInset.bottom == 0) {
                self.scrollView.originContentInset = _scrollView.contentInset;
            } else {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.originContentInset.bottom, 0);
            }
        } else {
            if (self.scrollView.originContentInset.bottom == 0) {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top-kTTPullRefreshHeight, 0, _scrollView.contentInset.bottom, 0);
            } else {
                self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top-kTTPullRefreshHeight, 0, _scrollView.originContentInset.bottom, 0);
            }
        }
        
        if (_needMessageBarReset) {
            self.scrollView.originContentInset = UIEdgeInsetsMake(_scrollView.contentInset.top-self.messagebarHeight, 0, _scrollView.originContentInset.bottom, 0);
        }
        
        if (self.state != PULL_REFRESH_STATE_LOADING) {
            if (self.scrollView.pullUpView && !self.scrollView.isDone) {
                self.scrollView.originContentInset =  UIEdgeInsetsMake(_scrollView.contentInset.top, 0, _scrollView.contentInset.bottom + kTTPullRefreshHeight, 0);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ( self.state != PULL_REFRESH_STATE_LOADING ) {
                        [self setScrollViewContentInsetWithOutObserve:self.scrollView.originContentInset];
                    } else {
                        [self setScrollViewContentInsetWithOutObserve:UIEdgeInsetsMake(self.scrollView.originContentInset.top+self.pullRefreshLoadingHeight, self.scrollView.originContentInset.left, self.scrollView.originContentInset.bottom, self.scrollView.originContentInset.right)];
                        
                    }
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

    TTLoadMoreView *sibling = (TTLoadMoreView *)_scrollView.pullUpView;
    if (_state == PULL_REFRESH_STATE_LOADING || (_scrollView.isMutex && [sibling isKindOfClass:TTLoadMoreView.class] && sibling.state == PULL_REFRESH_STATE_LOADING)) {
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

- (void)contentSizeChange:(NSDictionary *)change {
    if (_direction == PULL_DIRECTION_DOWN) {
        return;
    }
    
    NSInteger y = MAX(_scrollView.contentSize.height, _scrollView.bounds.size.height-_scrollView.contentInset.top);
    self.frame = CGRectMake(0, y, self.bounds.size.width, kTTPullRefreshHeight);
}

- (void)contentOffsetChange:(NSDictionary *)change {
    if (!self.window || !self.enabled ) {
        return;
    }
    
    CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];

    if (self.scrollView.isDragging) {
        [self messageBarResetContentInset];
    }

    if (self.scrollView.isDragging && self.pullMoveDirection == PULL_DIRECTION_UP && point.y + self.scrollView.contentInset.top >= 0) {
        self.isPullWithDragBackToTop = YES;
    }
    
    if (point.y + self.scrollView.contentInset.top <= 0  && _direction == PULL_DIRECTION_DOWN && self.state != PULL_REFRESH_STATE_LOADING) {
        [self processPullDown:(float)point.y];
    }
}

- (void)processPullDown:(float)y {
    CGFloat offset = y + _scrollView.contentInset.top;
    if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(updateAnimationWithScrollOffset:)]) {
        [self.refreshAnimateView updateAnimationWithScrollOffset:offset];
    }

    if (self.enableAnimatedRefresh && self.state != PULL_REFRESH_STATE_INIT) {
        [self.animatedRefreshView updateAnimationWithScrollOffset:offset];
    }
    
    NSInteger topInset = _scrollView.contentInset.top;

    if (y < -kTTPullRefreshHeight - topInset) {
        if (_scrollView.isDragging) {
            //振动
            if (self.refreshAnimateView) {
                [self pullRefreshStateWithShake];
            }
            self.state = PULL_REFRESH_STATE_PULL_OVER;
            if (!self.hasNotifiedShowAttachView) {
                self.hasNotifiedShowAttachView = YES;
                [self.ttAttachView willShowAttachView];
            }
            
            if (y < -kTTPullRefreshHeight-self.ttAttachView.frame.size.height) {
                if (!self.hasNotifiedOverAttachView) {
                    self.hasNotifiedOverAttachView = YES;
                    [self.ttAttachView didShowEntireAttachView];
                }
            }
        } else if (_state == PULL_REFRESH_STATE_PULL_OVER) {
            [self pullAndRefresh];
        }
    } else if (y < - topInset) {
        if (self.scrollView.isDragging) {
            self.state = PULL_REFRESH_STATE_PULL;
        } else if (_state == PULL_REFRESH_STATE_PULL_OVER) { //如果出现松手推荐用户松手触发推荐
            [self pullAndRefresh];
        }
    }

    if ([self.delegate respondsToSelector:@selector(refreshViewDidScroll:WithScrollOffset:)]) {
        [self.delegate refreshViewDidScroll:self WithScrollOffset:y];
    }
}

- (void)pullAndRefresh {
    self.isUserPullAndRefresh = YES;
    if (_loadingText.length == 0) {
        [UIView animateWithDuration:0.4 animations:^{
            self.state = PULL_REFRESH_STATE_LOADING;
        }];
    } else {
        self.state = PULL_REFRESH_STATE_LOADING;
    }

    [self setScrollInsets:YES];
}

- (void)pullRefreshStateWithShake {
    if (self.isPullWillHandsOff) {//如果是下拉刷新完就松手状态
        [(id<TTImpactFeedbackProtocol>)[[BDContextGet() findServiceClassByName:TTSoundEffectManagerServiceName] sharedInstance] impactFeedbackWithType:@"feed_refresh_view"];
        self.isPullWillHandsOff = NO;
        self.isPullWithDragBackToTop = NO;
    } else if (self.isPullWithDragBackToTop) {//如果是没有松手状态，需要记录是否回到看不见刷新区域才允许再次震动
        [(id<TTImpactFeedbackProtocol>)[[BDContextGet() findServiceClassByName:TTSoundEffectManagerServiceName] sharedInstance] impactFeedbackWithType:@"feed_refresh_view"];
        self.isPullWithDragBackToTop = NO;
    }
}

- (void)setScrollInsets:(BOOL)animation {
    UIEdgeInsets insets = self.scrollView.originContentInset;
    CGFloat notifyBarHeight = _needMessageBarReset?self.messagebarHeight:0;
    UIEdgeInsets dest = UIEdgeInsetsMake(self.pullRefreshLoadingHeight + insets.top + notifyBarHeight, insets.left, insets.bottom, insets.right);

    [UIView animateWithDuration:self.secondsNeedScrollToLoading animations:^{
        if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(animationWithScrollViewBackToLoading)]) {
            [self.refreshAnimateView performSelector:@selector(animationWithScrollViewBackToLoading)];
        }
        [self setScrollViewContentInsetWithOutObserve: dest];
    } completion:^(BOOL finished) {
        if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(completionWithScrollViewBackToLoading)]) {
            [self.refreshAnimateView performSelector:@selector(completionWithScrollViewBackToLoading)];
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self doHandler];
    });
}

- (void)setUpRefreshBackColor:(UIColor *)backColor
{
    if (backColor) {
        [self.bgView setBackgroundColor:backColor];
        [self.defaultRefreshAnimateView setBackgroundColor:backColor];
        [self setBackgroundColor:backColor];
    }
}

- (void)layoutSubviews {
    [UIView setAnimationsEnabled:NO];
    [super layoutSubviews];
    if (self.refreshAnimateView) {
        self.refreshAnimateView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    [UIView setAnimationsEnabled:YES];
}

- (void)resetScrollInsets {
    if (!self.window) {
        [self setScrollViewContentInsetWithOutObserve:UIEdgeInsetsMake(self.scrollView.originContentInset.top, self.scrollView.originContentInset.left, self.scrollView.originContentInset.bottom, self.scrollView.originContentInset.right)];
        
        self.scrollView.originContentInset = self.scrollView.contentInset;
        self.state = PULL_REFRESH_STATE_INIT;
        
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        if (self.scrollView.ttHasIntegratedMessageBar) {
            CGFloat height = self.messagebarHeight;
            [self setScrollViewContentInsetWithOutObserve:UIEdgeInsetsMake(self.scrollView.originContentInset.top+height, self.scrollView.originContentInset.left, self.scrollView.originContentInset.bottom, self.scrollView.originContentInset.right)];
            self.needMessageBarReset = YES;
        } else {
            [self setScrollViewContentInsetWithOutObserve:UIEdgeInsetsMake(self.scrollView.originContentInset.top, self.scrollView.originContentInset.left, self.scrollView.originContentInset.bottom, self.scrollView.originContentInset.right)];
            
            if (self.scrollView.customTopOffset != 0) {
                [UIView performWithoutAnimation:^{
                    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.customTopOffset - self.scrollView.contentInset.top);
                }];
            }
        }
    } completion:^(BOOL finished) {
        self.state = PULL_REFRESH_STATE_INIT;
        self.isUserPullAndRefresh = NO;
    }];
}

- (void)messageBarResetContentInset {
    CGFloat height = self.messagebarHeight;
    if (!self.window && _needMessageBarReset) {
        [self setScrollViewContentInsetWithOutObserve:UIEdgeInsetsMake(self.scrollView.contentInset.top - height, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom, self.scrollView.contentInset.right)];
        
        _needMessageBarReset = NO;
        return;
    }
    if (!_needMessageBarReset || !self.window ) {
        return;
    }

    SEL selector = @selector(needResetScrollView);
    if ([self.scrollView.ttIntegratedMessageBar respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[self.scrollView.ttIntegratedMessageBar class] instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:self.scrollView.ttIntegratedMessageBar];
        [invocation invoke];
        BOOL returnValue;
        [invocation getReturnValue:&returnValue];
        if (returnValue) {
            return;
        }
    }
    
    _needMessageBarReset = NO;
    if ([self.scrollView.ttIntegratedMessageBar respondsToSelector:@selector(hideIfNeeds)]) {
        [self.scrollView.ttIntegratedMessageBar performSelector:@selector(hideIfNeeds) withObject:nil];
    }
    
    NSTimeInterval dur = (self.scrollView.customTopOffset != 0 ? 0.45 : 0.3);
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setScrollViewContentInsetWithOutObserve:self.scrollView.originContentInset];
        if (self.scrollView.customTopOffset != 0) {
            if (self.scrollView.contentOffset.y <=  0) {// 频道图片化时，offset可能小于0
                self.scrollView.contentOffset = CGPointMake(0, self.scrollView.customTopOffset - self.scrollView.contentInset.top);
            }
        }
    } completion:^(BOOL finished) {
        if (self.enableAnimatedRefresh && self.state == PULL_REFRESH_STATE_INIT) {
            [self.animatedRefreshView stopAnimation];
        }
        // state改为self.state会触发set方法,会导致下拉刷新广告显示异常
        _state = PULL_REFRESH_STATE_INIT;
        [self showAnimationView];
        if ([self.delegate respondsToSelector:@selector(refreshViewDidMessageBarResetContentInset)]) {
            [self.delegate refreshViewDidMessageBarResetContentInset];
        }
    }];
}

- (void)doHandler {
    if (_direction == PULL_DIRECTION_DOWN) {
        _actionHandler();
    } else {
        if (!self.hasNetError) {
            _actionHandler();
        }
    }
}

- (IBAction)refreshBtnTouched:(id)sender {
    _actionHandler();
}

- (void)stopAnimation:(BOOL)success {
    if (self.refreshAnimateView && [self.refreshAnimateView respondsToSelector:@selector(stopLoading)]) {
        [self.refreshAnimateView stopLoading];
    }

    if (!success && self.isPullUp) {
        self.hasNetError = YES;
        self.state = PULL_REFRESH_STATE_INIT;
    } else {
        if (!self.isPullUp) {
            [self resetScrollInsets];
        } else {
            self.hasNetError = NO;
            self.state = PULL_REFRESH_STATE_INIT;
        }
    }
}

- (void)showAnimationView {
    if (self.refreshAnimateView && !self.enableAnimatedRefresh) {
        self.refreshAnimateView.hidden = NO;
    }
}

- (void)hideAnimationView {
    if (self.refreshAnimateView && !self.enableAnimatedRefresh) {
        self.refreshAnimateView.hidden = YES;
    }
}

- (void)triggerRefreshAndHideAnimationView {
    if (self.hidden) {
        return;
    }
    [self triggerRefresh];
    [self hideAnimationView];
}

- (void)triggerRefresh {
    [self triggerRefreshWithDefaultRefreshView:YES];
}

- (void)triggerRefreshWithDefaultRefreshView:(BOOL)useDefaultRefreshView {
    if (self.hidden) return;

    if ([self.delegate respondsToSelector:@selector(refreshViewWillBeTriggered:)]) {
        [self.delegate refreshViewWillBeTriggered:self];
    }
    
    // 业务方自定义的 RefreshAnimateView 在这里被重置为头条主端默认的 RefreshAnimateView，不符合预期
    // 这里用这个方式规避下这个貌似的bug
    if (useDefaultRefreshView) {
        __weak typeof(self)wSelf = self;
        [self resetWithDefaultAnimateViewWithConfigureSuccessCompletion:^(BOOL isSucess) {
            if (isSucess) {
                __strong typeof(wSelf)sSelf = wSelf;
                sSelf.secondsNeedScrollToLoading = KTTSecondsNeedScrollToLoading;
            }
        }];
    }
    
    self.isUserPullAndRefresh = NO;
    [self showAnimationView];
    
    self.state = PULL_REFRESH_STATE_LOADING;

    UIEdgeInsets insets = self.scrollView.originContentInset;
    UIEdgeInsets dest = UIEdgeInsetsMake(self.pullRefreshLoadingHeight + insets.top, insets.left, insets.bottom, insets.right);
    
    if (_direction == PULL_DIRECTION_DOWN) {
        [_scrollView setContentOffset:CGPointMake(0, -dest.top) animated:NO];
    } else {
        CGFloat offset = _scrollView.contentSize.height - _scrollView.bounds.size.height;
        if (offset > 0) {
            [_scrollView setContentOffset:CGPointMake(0, offset + self.pullRefreshLoadingHeight) animated:NO];
        }
    }
    
    if ([self.scrollView.ttIntegratedMessageBar respondsToSelector:@selector(hideIfNeeds)]) {
        [self.scrollView.ttIntegratedMessageBar performSelector:@selector(hideIfNeeds) withObject:nil];
    }
    
    _needMessageBarReset = NO;
    
    [self.layer removeAllAnimations];

    if (self.ignoreInsetAnimation) {
        [self setScrollViewContentInsetWithOutObserve: dest];
        [self doHandler];
    } else {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setScrollViewContentInsetWithOutObserve: dest];
        } completion:^(BOOL finished) {
            [self doHandler];
        }];
    }
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

#pragma scrollview pangesturer action
- (IBAction)gestureRecognizerUpdate:(UIPanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(refreshViewWillStartDrag:)]) {
            [self.delegate refreshViewWillStartDrag:self];
        }
        
        self.pullMoveDirection = Pull_MoveDirectionNone;
        self.lastPanPoint = CGPointMake(0, 0);
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        PullMoveDirectionType curPullDirection = [self determineCameraDirectionIfNeeded:translation];
        
        if (curPullDirection != self.pullMoveDirection) {
            if ([self.delegate respondsToSelector:@selector(refreshViewWillChangePullDirection:changedPullDirection:)]) {
                [self.delegate refreshViewWillChangePullDirection:self changedPullDirection:curPullDirection];
            }
        }
        
        self.pullMoveDirection = curPullDirection;
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.state == PULL_REFRESH_STATE_PULL) {
            self.state = PULL_REFRESH_STATE_INIT;
        }
        
        if ([self.delegate respondsToSelector:@selector(refreshViewDidEndDrag:)]) {
            [self.delegate refreshViewDidEndDrag:self];
        }
    }
}

- (PullMoveDirectionType)determineCameraDirectionIfNeeded:(CGPoint)translation {
    PullMoveDirectionType curPullMoveDirection = self.pullMoveDirection;

    if (fabs(translation.y) > 0) {
        if ((translation.y - self.lastPanPoint.y) > 0) {
            curPullMoveDirection = Pull_MoveDirectionDown;
        } else {
            curPullMoveDirection = Pull_MoveDirectionUp;
        }
    }
    
    self.lastPanPoint = translation;
    
    return curPullMoveDirection;
}

@end
