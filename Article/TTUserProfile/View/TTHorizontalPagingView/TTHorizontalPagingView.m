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

@interface TTDynamicItem : NSObject<UIDynamicItem>

@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign, readonly) CGRect bounds;
@property (nonatomic, assign) CGAffineTransform transform;

@end

@implementation TTDynamicItem

- (instancetype)init
{
    if (self = [super init]) {
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

@end

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
@property (nonatomic, strong, readwrite) UIView *headerView;
@property (nonatomic, strong, readwrite) TTHorizontalPagingSegmentView *segmentView;
@property (nonatomic, assign) BOOL isSwitching;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *,UIScrollView *> *contentViewDict;
@property (nonatomic, assign) NSInteger lastPageIndex;
@property (nonatomic, strong) UIPanGestureRecognizer *headerViewPanGestureRecognizer;
@property (nonatomic, assign) CGFloat lastHeaderViewTop;
// 用于模拟scrollView滚动

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIDynamicItemBehavior *inertialBehavior;

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
    
}

- (void)scrollEnable:(BOOL)enable
{
    if(enable) {
        self.horizontalCollectionView.userInteractionEnabled = YES;
        self.segmentView.userInteractionEnabled = YES;
    } else {
        self.horizontalCollectionView.userInteractionEnabled = NO;
        self.segmentView.userInteractionEnabled = NO;
    }
}

- (void)scrollToIndex:(NSInteger)pageIndex withAnimation:(BOOL)animation
{
    if(pageIndex >= self.section || pageIndex < 0 || self.section <= 0) return;
    [self.horizontalCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animation];
    if(!animation) {
        [self scrollViewDidEndScrollingAnimation:self.horizontalCollectionView];
    }
}

- (UIScrollView *)scrollViewAtIndex:(NSInteger)index
{
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

#pragma mark 监听事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if(self.inertialBehavior != nil) {
        [self.animator removeBehavior:self.inertialBehavior];
        self.inertialBehavior = nil;
        return nil;
    }
    return view;
}

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

- (UIPanGestureRecognizer *)headerViewPanGestureRecognizer
{
    if(!_headerViewPanGestureRecognizer) {
        _headerViewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _headerViewPanGestureRecognizer.delegate = self;
    }
    return _headerViewPanGestureRecognizer;
}

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] init];
    }
    return _animator;
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
    CGFloat headerViewDisplayHeight = self.headerViewHeight + self.headerView.top;
    if (headerViewDisplayHeight != self.segmentTopSpace) {// 还原位置
        scrollView.contentOffset = CGPointMake(0, -headerViewDisplayHeight - self.segmentViewHeight);
    } else if (scrollView.contentOffset.y < -self.segmentViewHeight) {
        scrollView.contentOffset = CGPointMake(0, -headerViewDisplayHeight - self.segmentViewHeight);
    } else {
        // self.segmentTopSpace
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y-headerViewDisplayHeight + self.segmentTopSpace);
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
    [_headerView removeFromSuperview];
    _headerView = headerView;
    [_headerView removeGestureRecognizer:self.headerViewPanGestureRecognizer];
    [_headerView addGestureRecognizer:self.headerViewPanGestureRecognizer];
    _headerView.frame = CGRectMake(0, 0, self.width, self.headerViewHeight);
    [self addSubview:_headerView];
}

- (void)setSegmentView:(TTHorizontalPagingSegmentView *)segmentView
{
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
    self.isSwitching = YES;
    NSString *identifier = [self collectionViewCellIdentifierWithIndex:indexPath.item];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
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
            CGFloat headerDisplayHeight = self.headerViewHeight + self.headerView.top;
            scrollView.contentInset = UIEdgeInsetsMake(headerDisplayHeight + self.segmentViewHeight, 0, scrollView.contentInset.bottom, 0);
            scrollView.contentOffset = CGPointMake(0, -headerDisplayHeight - self.segmentViewHeight);
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
        self.currentContentView.contentSize = CGSizeMake(0, self.currentContentView.contentSize.height);
        CGFloat oldOffsetY = [change[NSKeyValueChangeOldKey] CGPointValue].y;
        CGFloat newOffsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        CGFloat headerDisplayHeight = self.headerViewHeight + self.headerView.top;
        [self scrollViewContentOffsetDidChangeWithOldValue:oldOffsetY newValue:newOffsetY headerDisplayHeight:headerDisplayHeight];
    } else if (context == TTHorizontalPagingViewInsetContext) {
        if(self.currentContentView.contentOffset.y > -self.segmentViewHeight) return;
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.top = -self.headerViewHeight - self.segmentViewHeight - self.currentContentView.contentOffset.y;
            self.segmentView.top = self.headerView.bottom;
        }];
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
    CGFloat headerViewHeight = self.headerViewHeight;
    if(self.ignoreAdjust) return;
    if(deltaY >= 0) {    //向上滚动
        if(headerDisplayHeight - deltaY <= self.segmentTopSpace) {
            self.headerView.top = -headerViewHeight + self.segmentTopSpace;
        } else {
            self.headerView.top -= deltaY;
        }
        if(headerDisplayHeight <= self.segmentTopSpace) {
            self.headerView.top = -headerViewHeight + self.segmentTopSpace;
        }
        self.segmentView.top = self.headerView.bottom;
    } else {
        if (headerDisplayHeight + self.segmentViewHeight < -newOffsetY) {
            self.headerView.top = -self.headerViewHeight - self.segmentViewHeight - self.currentContentView.contentOffset.y;
            self.segmentView.top = self.headerView.bottom;
        }
    }
    if(deltaY == 0) return;
    if([self.delegate respondsToSelector:@selector(pagingView:scrollTopOffset:)]) {
        [self.delegate pagingView:self scrollTopOffset:self.currentContentView.contentOffset.y];
    }
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

- (void)pan:(UIPanGestureRecognizer*)pan
{
    // 偏移计算
    CGPoint point = [pan translationInView:self.headerView];
    CGPoint contentOffset = self.currentContentView.contentOffset;
    CGFloat border = -self.headerViewHeight - self.segmentViewHeight;
    CGFloat offsety = contentOffset.y - point.y * (1/contentOffset.y * border * 0.6);
    self.currentContentView.contentOffset = CGPointMake(contentOffset.x, offsety);
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateFailed) {
        if(contentOffset.y <= border) {
            // 模拟弹回效果
            [UIView animateWithDuration:0.35 animations:^{
                self.currentContentView.contentOffset = CGPointMake(contentOffset.x, border);
                [self layoutIfNeeded];
            }];
            
        } else {
            // 模拟减速滚动效果
            CGFloat velocity = [pan velocityInView:self.headerView].y;
            [self deceleratingAnimator:velocity];
        }
    }
    // 清零防止偏移累计
    [pan setTranslation:CGPointZero inView:self.headerView];
}

- (void)deceleratingAnimator:(CGFloat)velocity
{
    if(self.inertialBehavior != nil) {
        [self.animator removeBehavior:self.inertialBehavior];
    }
    TTDynamicItem *item = [[TTDynamicItem alloc] init];
    item.center = CGPointMake(0, 0);
    // velocity是在手势结束的时候获取的竖直方向的手势速度
    UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[item]];
    [inertialBehavior addLinearVelocity:CGPointMake(0, velocity * 0.025) forItem:item];
    // 通过尝试取2.0比较像系统的效果
    inertialBehavior.resistance = 2;
    __weak typeof(self)weakSelf = self;
    CGFloat maxOffset = self.currentContentView.contentSize.height - self.currentContentView.bounds.size.height;
    inertialBehavior.action = ^{
        CGPoint contentOffset = weakSelf.currentContentView.contentOffset;
        CGFloat speed = [weakSelf.inertialBehavior linearVelocityForItem:item].y;
        CGFloat offset = contentOffset.y -  speed;
        if(speed >= -0.2) {
            [weakSelf.animator removeBehavior:weakSelf.inertialBehavior];
            weakSelf.inertialBehavior = nil;
        } else if (offset >= maxOffset){
            [weakSelf.animator removeBehavior:weakSelf.inertialBehavior];
            weakSelf.inertialBehavior = nil;
            offset = maxOffset;
            // 模拟减速滚动到scrollView最底部时，先拉一点再弹回的效果
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.currentContentView.contentOffset = CGPointMake(contentOffset.x, offset - speed);
                [weakSelf layoutIfNeeded];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25 animations:^{
                    weakSelf.currentContentView.contentOffset = CGPointMake(contentOffset.x, offset);
                    [weakSelf layoutIfNeeded];
                }];
            }];
        } else {
            weakSelf.currentContentView.contentOffset = CGPointMake(contentOffset.x, offset);
        }
    };
    self.inertialBehavior = inertialBehavior;
    [self.animator addBehavior:inertialBehavior];
}

- (void)removeObserver
{
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
}

@end
