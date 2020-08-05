//
//  TTHorizontalPagingView.m
//  TTHorizontalPagingViewDemo
//
//  Created by 王迪 on 17/3/12.
//  Copyright © 2017年 wangdi. All rights reserved.
//

#import "TTHorizontalPagingView.h"
#import "TTHorizontalPagingSegmentView.h"
#import <objc/runtime.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "UIView+BTDAdditions.h"

@interface TTHorizontalPagingCollectionView : UICollectionView <UIGestureRecognizerDelegate>

@end

@implementation TTHorizontalPagingCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self){
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    return NO;
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;
    
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            if (point.x > 0 && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
    
}

@end

static void *TTHorizontalPagingViewOffsetContext = &TTHorizontalPagingViewOffsetContext;
static void *TTHorizontalPagingViewInsetContext = &TTHorizontalPagingViewInsetContext;
static void *TTHorizontalPagingViewPanContext = &TTHorizontalPagingViewPanContext;
static void *TTHorizontalPagingViewCellKey = &TTHorizontalPagingViewCellKey;
static void *TTHorizontalPagingViewSettingInset = &TTHorizontalPagingViewSettingInset;

@interface TTHorizontalPagingView ()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger lastPageIndex;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *,UIScrollView *> *contentViewDict;
@property (nonatomic, assign) CGFloat lastHeaderViewTop;
@property (nonatomic, assign) BOOL segmentCanPan;
@property (nonatomic, assign) CGFloat headerShowHeight;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign) BOOL animation;

@end

@implementation TTHorizontalPagingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self baseSetup];
        [self setupHorizontalCollectionView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        [self baseSetup];
        [self setupHorizontalCollectionView];
    }
    return self;
}

- (void)baseSetup
{
    _shouldAdvanceLoadData = YES;
    _section = 0;
    _segmentTopSpace = 0;
    _isSwitching = NO;
    _lastPageIndex = 0;
    _alwaysBounceHorizontal = NO;
    _segmentCanPan = YES;
    _isFirstLoad = YES;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark - public
-(void)reloadData
{
    NSInteger section = [self.delegate numberOfSectionsInPagingView:self];
    self.section = section;
    CGFloat headerViewHeight = [self.delegate heightForHeaderInPagingView];
    _headerViewHeight = headerViewHeight;
    _headerShowHeight = headerViewHeight;
    UIView *headerView = [self.delegate viewForHeaderInPagingView];
    self.headerView = headerView;
    
    CGFloat segmentViewHeight = [self.delegate heightForSegmentInPagingView];
    _segmentViewHeight = segmentViewHeight;
    TTHorizontalPagingSegmentView *segmentView = [self.delegate viewForSegmentInPagingView];
    self.segmentView = segmentView;
    
    for(int i = 0;i < section;i++) {
        [self.horizontalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:[self collectionViewCellIdentifierWithIndex:i]];
    }
    [self removeObserver];
    [self.contentViewDict removeAllObjects];
    if(section <= 0) return;
    [self.horizontalCollectionView reloadData];
    
    self.isSwitching = NO;
    self.segmentView.isSwitching = NO;
}

- (void)reloadHeaderShowHeight {
    self.headerShowHeight = self.headerViewHeight;
}

- (void)scrollEnable:(BOOL)enable {
    if(enable) {
        self.horizontalCollectionView.userInteractionEnabled = YES;
        self.segmentView.userInteractionEnabled = YES;
    } else {
        self.horizontalCollectionView.userInteractionEnabled = NO;
        self.segmentView.userInteractionEnabled = NO;
    }
}

- (void)scrollToIndex:(NSInteger)pageIndex withAnimation:(BOOL)animation {
    if(pageIndex >= self.section || pageIndex < 0 || self.section <= 0) return;
    [self.currentContentView setContentOffset:self.currentContentView.contentOffset animated:NO];
    self.animation = animation;
    [self.horizontalCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animation];
    if(!animation) {
        self.isSwitching = YES;
        self.segmentView.isSwitching = YES;
        [self scrollViewDidEndScrollingAnimation:self.horizontalCollectionView];
    }
}

- (UIScrollView *)scrollViewAtIndex:(NSInteger)index {
    UIScrollView *tmpScrollView = self.contentViewDict[@(index)];
    if (!tmpScrollView) {
        tmpScrollView = [self.delegate pagingView:self viewAtIndex:index];
#if DEBUG
        NSAssert(tmpScrollView != nil, @"返回的UIScrollView 不能为空");
#endif
        if(tmpScrollView) {
            [self setupContentView:tmpScrollView];
            self.contentViewDict[@(index)] = tmpScrollView;
        }
    }
    return tmpScrollView;
}

//#pragma mark 监听事件
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if(self.inertialBehavior != nil) {
//        [self.animator removeBehavior:self.inertialBehavior];
//        self.inertialBehavior = nil;
//        return nil;
//    }
//    return view;
//}

#pragma mark - private

#pragma mark - 懒加载
- (NSMutableDictionary<NSNumber *,UIScrollView *> *)contentViewDict
{
    if(!_contentViewDict) {
        _contentViewDict = [NSMutableDictionary dictionary];
    }
    return _contentViewDict;
}

- (CGFloat)currentContentViewTopInset
{
    return self.headerViewHeight + self.segmentViewHeight;
}

- (UIView *)movingView {
    if(!_movingView){
        _movingView = [[UIView alloc] init];
        _movingView.backgroundColor = [UIColor whiteColor];
    }
    return _movingView;
}

- (NSString *)collectionViewCellIdentifierWithIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"collectionViewCell_%zd",index];
}

- (UIViewController *)viewControllerForView:(UIView *)view
{
    UIView *next = view;
    while (next) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        next = next.superview;
    }
    return nil;
}

- (void)adjustContentViewOffsetWithScrollView:(UIScrollView *)scrollView {
    if (self.headerShowHeight >= self.segmentTopSpace) {// 还原位置
        scrollView.contentOffset = CGPointMake(0, - self.headerShowHeight - self.segmentViewHeight);
    } else if (scrollView.contentOffset.y < -self.segmentViewHeight) {
        scrollView.contentOffset = CGPointMake(0, - self.segmentTopSpace - self.segmentViewHeight);
    } else {
        
    }
}

- (void)setupHorizontalCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *horizontalCollectionView = [[TTHorizontalPagingCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _horizontalCollectionView = horizontalCollectionView;
    self.horizontalCollectionView.backgroundColor = [UIColor clearColor];
    self.horizontalCollectionView.dataSource = self;
    self.horizontalCollectionView.delegate = self;
    self.horizontalCollectionView.pagingEnabled = YES;
    self.horizontalCollectionView.bounces = self.alwaysBounceHorizontal;
    self.horizontalCollectionView.showsHorizontalScrollIndicator = NO;
    self.horizontalCollectionView.showsVerticalScrollIndicator = NO;
    self.horizontalCollectionView.scrollsToTop = NO;
    if([self.horizontalCollectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        self.horizontalCollectionView.prefetchingEnabled = NO;
#pragma clang diagnostic pop
    }
    [self addSubview:self.horizontalCollectionView];
}

// 视图切换时执行代码
- (void)didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex
{
    self.lastPageIndex = toIndex;
    
    _currentContentView = [self scrollViewAtIndex:toIndex];
    
    self.movingView.frame = CGRectMake(0, - self.currentContentViewTopInset, self.width, self.currentContentViewTopInset);
    
    [_headerView removeFromSuperview];
    _headerView.frame = CGRectMake(0, 0, self.width, self.headerViewHeight);
    [self.movingView addSubview:_headerView];
    
    if(self.headerShowHeight > self.segmentTopSpace) {
        [_segmentView removeFromSuperview];
        _segmentView.frame = CGRectMake(0, self.headerView.bottom, self.width, self.segmentViewHeight);
        [self.movingView addSubview:_segmentView];
    }
    
    [self.movingView removeFromSuperview];
    [_currentContentView addSubview:self.movingView];
    
    if ([self.delegate respondsToSelector:@selector(pagingView:didSwitchIndex:to:)]) {
        [self.delegate pagingView:self didSwitchIndex:aIndex to:toIndex];
    }
}

- (void)setupContentView:(UIScrollView *)scrollView
{
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [scrollView.panGestureRecognizer addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:TTHorizontalPagingViewPanContext];
    [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:TTHorizontalPagingViewOffsetContext];
    [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:TTHorizontalPagingViewInsetContext];
}

- (void)setHeaderView:(UIView *)headerView
{
    if(self.headerShowHeight <= self.segmentTopSpace || _headerView.superview == self){
        return;
    }
    
    [_headerView removeFromSuperview];
    _headerView = headerView;
  
    //这里重新计算下 headerShowHeight 的值，在kvo中计算的值会差0.5像素，导致视图会有一点移动
    if(_currentContentView){
        self.headerShowHeight = -_currentContentView.contentOffset.y - self.segmentViewHeight;
    }

    _headerView.frame = CGRectMake(0, self.headerShowHeight - self.headerViewHeight, self.width, self.headerViewHeight);
    [self addSubview:_headerView];
}

- (void)setSegmentView:(TTHorizontalPagingSegmentView *)segmentView
{
    if(_segmentView.superview == self){
        return;
    }
    
    [_segmentView removeFromSuperview];
    _segmentView = segmentView;
    _segmentView.frame = CGRectMake(0, self.headerView.bottom, self.width, self.segmentViewHeight);
    [self addSubview:_segmentView];
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal
{
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.horizontalCollectionView.bounces = alwaysBounceHorizontal;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.section;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.animation){
        self.isSwitching = YES;
        self.segmentView.isSwitching = YES;
    }
    NSString *identifier = [self collectionViewCellIdentifierWithIndex:indexPath.item];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(indexPath.row && self.segmentView.selectedIndex != indexPath.row){
        return cell;
    }
    UIScrollView *scrollView = [self scrollViewAtIndex:indexPath.row];
    UIScrollView *subScrollView = objc_getAssociatedObject(cell.contentView, TTHorizontalPagingViewCellKey);
    if (scrollView != subScrollView) {
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIViewController *vc = [self viewControllerForView:scrollView];
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        vc.view.frame = cell.contentView.bounds;
        BOOL inset = [objc_getAssociatedObject(scrollView, TTHorizontalPagingViewSettingInset) boolValue];
        
        if(!inset) {
            CGFloat height = self.headerShowHeight;
//            if(!indexPath.row){
//                height = self.headerViewHeight;
//            }
            CGFloat initHeader = height <= self.segmentTopSpace ? self.segmentTopSpace : height;
            CGFloat distance = initHeader + self.segmentViewHeight;
            
            scrollView.contentInset = UIEdgeInsetsMake(distance, 0, scrollView.contentInset.bottom, 0);
            scrollView.contentOffset = CGPointMake(0, -distance);
        }
        
        [cell.contentView addSubview:vc.view];
        objc_setAssociatedObject(cell.contentView, TTHorizontalPagingViewCellKey, scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self adjustContentViewOffsetWithScrollView:scrollView];
    return cell;
    
}

- (void)setupScrollViewEndScrollViewing:(UIScrollView *)scrollView
{
    NSInteger currentIndex = scrollView.contentOffset.x / self.width;
    [self didSwitchIndex:self.lastPageIndex to:currentIndex];
    [self.segmentView scrollToIndex:currentIndex];
    [self advanceLoadData];
    [self adjustContentViewOffsetWithScrollView:self.currentContentView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0)), dispatch_get_main_queue(), ^{
        self.isSwitching = NO;
        self.segmentView.isSwitching = NO;
    });
}

#pragma mark - UIScrollView 代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setupScrollViewEndScrollViewing:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate) {
        [self setupScrollViewEndScrollViewing:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self setupScrollViewEndScrollViewing:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.segmentView scrollToOffsetX:scrollView.contentOffset.x];
}

- (void)advanceLoadData
{
    //这里暂时不知道原因，不知道为什么莫名的就把contentSize 给改了， 暂时先强制改回来
    self.currentContentView.contentSize = CGSizeMake(0, self.currentContentView.contentSize.height);
    if(self.section <= 0 || !self.shouldAdvanceLoadData) return;
    NSInteger currentIndex = self.horizontalCollectionView.contentOffset.x / self.width;
    if(currentIndex < 0 || currentIndex >= self.section) return;
    NSInteger nextIndex = currentIndex + 1;
    if(nextIndex >= self.section - 1) {
        nextIndex = self.section - 1;
    }
    NSInteger preIndex = currentIndex - 1;
    if(preIndex < 0) {
        preIndex = 0;
    }
    [self scrollViewAtIndex:preIndex];
    [self scrollViewAtIndex:nextIndex];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(__unused id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == TTHorizontalPagingViewPanContext) {
        UIGestureRecognizerState newState = ((NSNumber *)change[NSKeyValueChangeNewKey]).integerValue;
        [self scrollViewPanDidChangeWithNewValue:newState];
    } else if (context == TTHorizontalPagingViewOffsetContext) {
        if (self.isSwitching || object != self.currentContentView || self.horizontalCollectionView.isDragging) return;
//        self.currentContentView.contentSize = CGSizeMake(0, self.currentContentView.contentSize.height);
        CGFloat oldOffsetY = [change[NSKeyValueChangeOldKey] CGPointValue].y;
        CGFloat newOffsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        [self scrollViewContentOffsetDidChangeWithOldValue:oldOffsetY newValue:newOffsetY headerDisplayHeight:self.headerShowHeight];
    } else if (context == TTHorizontalPagingViewInsetContext) {
//        if(self.currentContentView.contentOffset.y > -self.segmentViewHeight) return;
//        [UIView animateWithDuration:0.2 animations:^{
//            self.headerView.top = -self.headerViewHeight - self.segmentViewHeight - self.currentContentView.contentOffset.y;
//            self.segmentView.top = self.headerView.bottom;
//        }];
    }
}

- (void)scrollViewPanDidChangeWithNewValue:(UIGestureRecognizerState)newState
{
    if(newState == UIGestureRecognizerStateBegan) {
        BOOL inset = [objc_getAssociatedObject(self.currentContentView, TTHorizontalPagingViewSettingInset) boolValue];
        if(!inset) {
             objc_setAssociatedObject(self.currentContentView, TTHorizontalPagingViewSettingInset, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.currentContentView.contentInset = UIEdgeInsetsMake(self.headerViewHeight + self.segmentViewHeight, 0, self.currentContentView.contentInset.bottom, 0);
        }
    }
}

- (void)scrollViewContentOffsetDidChangeWithOldValue:(CGFloat)oldOffsetY newValue:(CGFloat)newOffsetY headerDisplayHeight:(CGFloat)headerDisplayHeight
{
    CGFloat deltaY = newOffsetY - oldOffsetY;
    
    if(deltaY == - self.currentContentViewTopInset){
        return;
    }
    
    if(self.ignoreAdjust) return;
    if(deltaY >= 0) {    //向上滚动
        if(self.headerShowHeight <= self.segmentTopSpace) {
            if(self.segmentView.superview != self){
                [_segmentView removeFromSuperview];
                _segmentView.frame = CGRectMake(0, self.segmentTopSpace, self.width, self.segmentViewHeight);
                [self addSubview:_segmentView];
            }
        }
    } else {
        if(self.headerShowHeight > self.segmentTopSpace) {
            if(self.segmentView.superview == self){
                [_segmentView removeFromSuperview];
                 _segmentView.btd_y = self.headerView.bottom;
                _segmentView.frame = CGRectMake(0, self.headerView.bottom, self.width, self.segmentViewHeight);
                [self.movingView addSubview:_segmentView];
            }
        }
    }
    
    if(deltaY == 0) return;
    self.headerShowHeight = [self headerDisplayHeight] - deltaY;
    
    if([self.delegate respondsToSelector:@selector(pagingView:scrollTopOffset:)]) {
        [self.delegate pagingView:self scrollTopOffset:self.currentContentView.contentOffset.y];
    }
}

- (CGFloat)headerDisplayHeight {
    CGFloat height = 0;
    CGRect rect = [self.headerView convertRect:self.headerView.frame toView:self];
    height = self.headerViewHeight + rect.origin.y;
    return height;
}

#pragma mark - 手势相关
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self.headerView];
        if(point.x > 0 && point.y == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)removeObserver {
    [self.contentViewDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIScrollView * _Nonnull scrollView, BOOL * _Nonnull stop) {
        [scrollView.panGestureRecognizer removeObserver:self forKeyPath:NSStringFromSelector(@selector(state)) context:TTHorizontalPagingViewPanContext];
        [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:TTHorizontalPagingViewOffsetContext];
        [scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) context:TTHorizontalPagingViewInsetContext];
    }];
    
}

- (void)dealloc
{
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UICollectionViewFlowLayout *followLayout = (UICollectionViewFlowLayout *)self.horizontalCollectionView.collectionViewLayout;
    followLayout.itemSize = self.bounds.size;
    self.horizontalCollectionView.frame = self.bounds;
    self.horizontalCollectionView.contentInset = UIEdgeInsetsZero;
    self.isSwitching = NO;
    self.segmentView.isSwitching = NO;
}

- (void)reloadHeaderViewHeight:(CGFloat)height {
    if(self.headerViewHeight == height) return;
    CGFloat delta = self.headerViewHeight - height;
    CGFloat offsetY = self.currentContentView.contentOffset.y + delta;
    [self setValue:@(height) forKeyPath:@"headerViewHeight"];
    self.headerView.height = height;
    
    for (UIScrollView *scrollView in [self.contentViewDict allValues]) {
        scrollView.contentOffset = CGPointMake(0,offsetY);
        scrollView.contentInset = UIEdgeInsetsMake(self.headerViewHeight + self.segmentViewHeight, 0, scrollView.contentInset.bottom, 0);
    }
    
    //    self.currentContentView.contentOffset = CGPointMake(0,offsetY);
    //    self.currentContentView.contentInset = UIEdgeInsetsMake(self.headerViewHeight + self.segmentViewHeight, 0, self.currentContentView.contentInset.bottom, 0);
    self.movingView.frame = CGRectMake(0, - self.currentContentViewTopInset, self.width, self.currentContentViewTopInset);
    self.segmentView.frame = CGRectMake(0, self.headerView.bottom, self.width, self.segmentViewHeight);
}

@end
