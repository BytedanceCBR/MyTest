//
//  TTHeaderScrollView.m
//  Article
//
//  Created by 王霖 on 16/8/3.
//
//

#import "TTHeaderScrollView.h"
#import <TTBaseLib/UIViewAdditions.h>

static const CGFloat kAnimationDuration = 0.25f;

#pragma mark - _TTHeaderScrollViewDelegateForwarder

@interface _TTHeaderScrollViewDelegateForwarder : NSObject <TTHeaderScrollViewDelegate>

@property (nonatomic,weak) id<TTHeaderScrollViewDelegate> delegate;

@end

#pragma mark - TTHeaderScrollView

@interface TTHeaderScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) _TTHeaderScrollViewDelegateForwarder *delegateForwarder;
@property (nonatomic, strong) NSMutableArray<__kindof UIScrollView *> * observedScrollViews;

@end

@implementation TTHeaderScrollView {
    BOOL _isObserving;
    BOOL _lock;
}

static void * const kTTHeaderScrollViewKVOContext = (void*)&kTTHeaderScrollViewKVOContext;

@synthesize delegate = _delegate;

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    @try {
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:kTTHeaderScrollViewKVOContext];
        [_headerView.layer removeObserver:self forKeyPath:@"bounds" context:kTTHeaderScrollViewKVOContext];
    } @catch (NSException *exception) {
        
    }
    [self removeObservedViews];
}

- (void)initialize {
    self.delegateForwarder = [_TTHeaderScrollViewDelegateForwarder new];
    super.delegate = self.delegateForwarder;
    self.observedScrollViews = [NSMutableArray array];
    self.showsVerticalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    self.bounces = NO;
    self.scrollsToTop = NO;
    self.animationEnable = YES;
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(contentOffset))
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:kTTHeaderScrollViewKVOContext];
    _isObserving = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentSize = CGSizeMake(self.width, _contentView.height);
}

#pragma mark - Custom access

- (void)setHeaderView:(UIView<TTHeaderViewProtocol> *)headerView {
    [_headerView removeFromSuperview];
    @try {
        [_headerView.layer removeObserver:self forKeyPath:@"bounds" context:kTTHeaderScrollViewKVOContext];
    } @catch (NSException *exception) {
        
    }
    _headerView = headerView;
    if (_headerView != nil) {
        _headerView.origin = CGPointMake(0, -_headerView.height);
        self.contentView.origin = CGPointMake(0, _headerView.bottom);
        [_headerView.layer addObserver:self
                            forKeyPath:@"bounds"
                               options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                               context:kTTHeaderScrollViewKVOContext];
        [self addSubview:_headerView];
    }else {
        self.contentView.origin = CGPointMake(0, 0);
    }
    self.contentInset = UIEdgeInsetsMake(_headerView.height, 0, 0, 0);
    self.contentOffset = CGPointMake(0, -headerView.height);
}

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    _contentView = contentView;
    if (_contentView != nil) {
        _contentView.origin = CGPointMake(0, _headerView.bottom);
        [self addSubview:_contentView];
    }
    self.contentSize = CGSizeMake(self.width, _contentView.height);
}

- (void)setDelegate:(id<TTHeaderScrollViewDelegate>)delegate {
    self.delegateForwarder.delegate = delegate;
    super.delegate = nil;
    super.delegate = self.delegateForwarder;
}

- (id<TTHeaderScrollViewDelegate>)delegate {
    return self.delegateForwarder.delegate;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self];
        
        //Lock horizontal pan gesture.
        if (fabs(velocity.x) > fabs(velocity.y)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIScrollView *scrollView = (id)otherGestureRecognizer.view;
    
    BOOL shouldScroll = scrollView != self && [scrollView isKindOfClass:[UIScrollView class]];
    
    if (shouldScroll && [self.delegate respondsToSelector:@selector(headerScrollView:shouldScrollWithScrollView:)]) {
        shouldScroll = [self.delegate headerScrollView:self shouldScrollWithScrollView:scrollView];
    }
    
    TTScrollViewScrollDirection direction = TTScrollViewScrollDirectionNone;
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pg = (UIPanGestureRecognizer *)otherGestureRecognizer;
        CGPoint velocity = [pg velocityInView:scrollView];
        if (velocity.y > 0) {
            //向下滚动
            direction = TTScrollViewScrollDirectionDown;
        } else if (velocity.y < 0) {
            //向上滚动
            direction = TTScrollViewScrollDirectionUp;
        } else {
            direction = TTScrollViewScrollDirectionNone;
        }
    }
    if (shouldScroll && [self.delegate respondsToSelector:@selector(scrollViewExtraTaskWithDirection:)]) {
        [self.delegate scrollViewExtraTaskWithDirection:direction];
    }
    
    if (shouldScroll) {
        [self addObservedView:scrollView];
    }
    return shouldScroll;
}

#pragma mark - KVO

- (void)addObserverToView:(UIScrollView *)scrollView {
    [scrollView addObserver:self
                 forKeyPath:NSStringFromSelector(@selector(contentOffset))
                    options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                    context:kTTHeaderScrollViewKVOContext];
    
    _lock = (scrollView.contentOffset.y > -scrollView.contentInset.top);
}

- (void)removeObserverFromView:(UIScrollView *)scrollView {
    @try {
        [scrollView removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(contentOffset))
                           context:kTTHeaderScrollViewKVOContext];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kTTHeaderScrollViewKVOContext && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        
        CGPoint new = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint old = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        CGFloat diff = old.y - new.y;
        
        if (diff == 0.0 || !_isObserving) return;
        
        if (object == self) {
            //Adjust self scroll offset when scroll down
            if (diff > 0 && _lock) {
                //diff>0：当前self正在下拉
                //_lock：当前scroll view正处于上拉后的状态
                //目的：保证当前self不动，scroll view向下滚动
                [self scrollView:self setContentOffset:old];
            }
            else if (((self.contentOffset.y < -self.contentInset.top) && !self.bounces)) {
                //self.contentOffset.y < -self.contentInset.top：当前self处于下拉后的状态
                //self.bounces = NO：self不能回弹
                //目的：保证当前self处于原始位置，让scroll view滚动
                [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.contentInset.top)];
            }
        }
        else {
            //Adjust the observed scrollview's content offset
            UIScrollView *scrollView = object;
            _lock = (scrollView.contentOffset.y > -scrollView.contentInset.top);
            
            //Manage scroll up
            if (self.contentOffset.y < -self.headerView.minimumHeaderHeight && _lock && diff < 0) {
                //self.contentOffset.y < -self.parallaxHeader.minimumHeight：当前self还没有到达最顶部
                //_lock：当前scroll view处于上拉后的状态
                //diff<0：当前scroll view正在上拉
                //目的：如果当前self还没有到达最顶部、scroll view处于上拉后的状态 并且 scroll view正在上拉，保证当前scroll view位置不变，让self滚动
                [self scrollView:scrollView setContentOffset:old];
            }
            //Disable bouncing when scroll down
            if (!_lock && ((self.contentOffset.y > -self.contentInset.top) || self.bounces)) {
                //!_lock：当前scroll view处于下拉后的状态
                //(self.contentOffset.y > -self.contentInset.top) || self.bounces：当前self处于上拉后的状态或者self可以回弹
                //目的：保证当前scroll view处于原始位置，让self滚动
                [self scrollView:scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top)];
            }
        }
    }
    else if (context == kTTHeaderScrollViewKVOContext && [keyPath isEqualToString:@"bounds"]){
        CGRect new = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect old = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        if (new.size.height == old.size.height) {
            return;
        }
        _headerView.top = -_headerView.height;
        self.contentView.origin = CGPointMake(0, _headerView.bottom);
        self.contentInset = UIEdgeInsetsMake(_headerView.height, 0, 0, 0);
        self.contentOffset= CGPointMake(self.contentOffset.x, self.contentOffset.y - (new.size.height - old.size.height));
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Scrolling views handlers

- (void)addObservedView:(UIScrollView *)scrollView {
    if (![self.observedScrollViews containsObject:scrollView]) {
        [self.observedScrollViews addObject:scrollView];
        [self addObserverToView:scrollView];
    }
}

- (void)removeObservedViews {
    for (UIScrollView *scrollView in self.observedScrollViews) {
        [self removeObserverFromView:scrollView];
    }
    [self.observedScrollViews removeAllObjects];
}

- (void)scrollView:(UIScrollView*)scrollView setContentOffset:(CGPoint)offset {
    BOOL tempObserve = _isObserving;
    _isObserving = NO;
    scrollView.contentOffset = offset;
    _isObserving = tempObserve;
}

- (void)changeContentOffssetWithAnimation {
    if (scrollDistance > 0 && self.contentOffset.y != -self.headerView.minimumHeaderHeight) {
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.headerView.minimumHeaderHeight)];
        } completion:nil];
    }else if(scrollDistance < 0 && self.contentOffset.y != (-self.contentInset.top)){
        [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.contentInset.top)];
        } completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

static CGFloat scrollDistance;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //相比于上次滑动距离
    static CGPoint lastContentOffSet;
    static BOOL firstScroll = YES;
    
    if (firstScroll) {
        firstScroll = NO;
        scrollDistance = scrollView.contentOffset.y + scrollView.contentInset.top;
    }else {
        scrollDistance = scrollView.contentOffset.y - lastContentOffSet.y;
    }
    lastContentOffSet = scrollView.contentOffset;
    
    if (self.contentOffset.y > -self.headerView.minimumHeaderHeight) {
        [self scrollView:self setContentOffset:CGPointMake(self.contentOffset.x, -self.headerView.minimumHeaderHeight)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lock = NO;
    [self removeObservedViews];
    if (_animationEnable) {
        [self changeContentOffssetWithAnimation];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        _lock = NO;
        [self removeObservedViews];
    }
    if (_animationEnable) {
        [self changeContentOffssetWithAnimation];
    }
}

#pragma mark - Public

- (void)scrollUp {
    if (self.contentOffset.y != -self.headerView.minimumHeaderHeight) {
        __block BOOL tempObserve = _isObserving;
        _isObserving = NO;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self setContentOffset:CGPointMake(0, -self.headerView.minimumHeaderHeight)];
                             
                             _isObserving = tempObserve;
                         }
                         completion:nil];
    }
}

- (void)scrollDown {
    if (self.contentOffset.y != -self.headerView.height) {
        _isObserving = NO;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self setContentOffset:CGPointMake(0, -self.headerView.height)];
                         }
                         completion:nil];
        _isObserving = YES;
    }
}


- (void)switchScrollViewObserverOn:(BOOL)on
{
    _isObserving = on;
}

@end

#pragma mark - _TTHeaderScrollViewDelegateForwarder

@implementation _TTHeaderScrollViewDelegateForwarder

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.delegate respondsToSelector:selector] || [super respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.delegate];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(TTHeaderScrollView *)scrollView scrollViewDidScroll:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [(TTHeaderScrollView *)scrollView scrollViewDidEndDecelerating:scrollView];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [(TTHeaderScrollView *)scrollView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

@end

