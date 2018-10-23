//
//  TTVSegmentedPageViewController.m
//  Article
//
//  Created by pei yun on 2017/3/22.
//
//

#import "TTVSegmentedPageViewController.h"
#import "NSObject+FBKVOController.h"

@interface TTVSegmentedPageViewController () <TTVSegmentedControlDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) NSUInteger previousPageIndex;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) BOOL isMovingForward;
@property (nonatomic, assign) CGFloat previousContentOffset;

@property (nonatomic, strong) NSMutableSet *visiblePages;
@property (nonatomic, assign) NSInteger firstVisiblePageIndex;
@property (nonatomic, assign) NSInteger lastVisiblePageIndex;
@property (nonatomic, assign) NSUInteger pagesToPreload;

@end

@implementation TTVSegmentedPageViewController

- (instancetype)init
{
    if (self = [super init]) {
        _pageScrollView = [[UIScrollView alloc] init];
        _pageScrollView.pagingEnabled = YES;
        _pageScrollView.scrollsToTop = NO;
        _pageScrollView.backgroundColor = [UIColor whiteColor];
        _pageDelegate = self;
        _viewFrame = [UIScreen mainScreen].bounds;
        
        _visiblePages = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)loadView
{
    self.pageScrollView.frame = _viewFrame;
    self.view = self.pageScrollView;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageScrollView.delegate = self;
    self.pageScrollView.contentSize = CGSizeMake(self.pageScrollView.contentSize.width, self.view.height);
    self.pageScrollView.showsHorizontalScrollIndicator = NO;
    
    WeakSelf;
    [self.KVOController observe:self.view keyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial block:^(id observer, id object, NSDictionary *change) {
        StrongSelf;
        self.pageScrollView.contentSize = CGSizeMake(self.pageScrollView.contentSize.width, self.view.frame.size.height);
    }];
    
    for (UIViewController *vc in self.viewControllers) {
        [self addChildViewController:vc];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.rightPopAllowed && self.navigationController) {
        [self.pageScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
    [self configurePages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.pageDelegate conformsToProtocol:@protocol(TTVSegmentedPageViewDelegate)] && [self.pageDelegate respondsToSelector:@selector(viewControllerDidBecomeVisible:firstAppear:isSwiping:)]) {
        [self.pageDelegate viewControllerDidBecomeVisible:self.viewControllers[self.currentPageIndex] firstAppear:YES isSwiping:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.pageDelegate conformsToProtocol:@protocol(TTVSegmentedPageViewDelegate)] && [self.pageDelegate respondsToSelector:@selector(viewControllerDidBecomeInvisible:isSwiping:)]) {
        [self.pageDelegate viewControllerDidBecomeInvisible:self.viewControllers[self.currentPageIndex] isSwiping:NO];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers segmentedControl:(id<TTVSegmentedControl>)segmentedControl
{
    _segmentedControl = segmentedControl;
    _segmentedControl.segmentedControlDelegate = self;
    
    _viewControllers = [viewControllers copy];
    self.pageScrollView.contentSize = CGSizeMake(self.viewControllers.count * [UIScreen mainScreen].bounds.size.width, 0);
    if ([self isViewLoaded]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self configurePages];
        });
    }
}

- (void)switchToPageIndex:(NSUInteger)idx animated:(BOOL)animated
{
    if (idx >= self.viewControllers.count) return;
    if (self.currentPageIndex == idx) return;
    
    [self.pageScrollView setContentOffset:CGPointMake((CGFloat)idx / self.viewControllers.count * self.pageScrollView.contentSize.width, 0) animated:animated];
    if (!animated) {
        [self segmentedControllEndMovingWithScollView:self.pageScrollView];
    }
}

- (void)segmentedControllEndMovingWithScollView:(UIScrollView *)scrollView;
{
    self.previousPageIndex = self.currentPageIndex;
    self.currentPageIndex = (NSUInteger)((scrollView.contentOffset.x / scrollView.contentSize.width) * self.viewControllers.count);
    BOOL hasPageChanged = self.previousPageIndex != self.currentPageIndex;
    
    if ([self.segmentedControl respondsToSelector:@selector(moveToIndex:)]) {
        [self.segmentedControl moveToIndex:self.currentPageIndex];
    }
    if (!hasPageChanged) return;
    
    if ([self.pageDelegate conformsToProtocol:@protocol(TTVSegmentedPageViewDelegate)] && self.isViewLoaded) {
        if ([self.pageDelegate respondsToSelector:@selector(viewControllerDidBecomeInvisible:isSwiping:)]) {
            [self.pageDelegate viewControllerDidBecomeInvisible:self.viewControllers[self.previousPageIndex] isSwiping:YES];
        }
        if ([self.pageDelegate respondsToSelector:@selector(viewControllerDidBecomeVisible:firstAppear:isSwiping:)]) {
            [self.pageDelegate viewControllerDidBecomeVisible:self.viewControllers[self.currentPageIndex] firstAppear:NO isSwiping:YES];
        }
        if ([self.pageDelegate respondsToSelector:@selector(viewControllerFromIndex:toIndex:)]) {
            [self.pageDelegate viewControllerFromIndex:self.previousPageIndex toIndex:self.currentPageIndex];
        }
    }
}

#pragma mark - lazy load pages

- (NSInteger)firstVisiblePageIndex
{
    CGRect visibleBounds = _pageScrollView.bounds;
    return MAX(floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds)), 0);
}

- (NSInteger)lastVisiblePageIndex
{
    CGRect visibleBounds = _pageScrollView.bounds;
    NSUInteger pageCount = self.viewControllers.count;
    return MIN(floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds)), pageCount - 1);
}

- (UIView *)viewForVisiblePageAtIndex:(NSUInteger)index {
    for (UIView *page in _visiblePages) {
        if (page.tag == index) {
            return page;
        }
    }
    return nil;
}

- (UIViewController *)viewControllerForPageAtIndex:(NSUInteger)index {
    if (index < self.viewControllers.count) {
        UIViewController *viewController = self.viewControllers[index];
        return viewController;
    }
    return nil;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    return CGRectMake(index * _pageScrollView.frame.size.width, 0, _pageScrollView.frame.size.width, _pageScrollView.frame.size.height);
}

- (void)configurePage:(UIView *)page forIndex:(NSInteger)index {
    page.tag = index;
    page.frame = [self frameForPageAtIndex:index];
    
    [page setNeedsDisplay]; // just in case
}

- (void)configurePages {
    CGRect visibleBounds = _pageScrollView.bounds;
    NSUInteger pageCount = self.viewControllers.count;
    NSInteger newPageIndex = MIN(MAX(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)), 0), pageCount - 1);
    newPageIndex = MAX(0, MIN(pageCount, newPageIndex));
    
    NSInteger firstVisiblePage = self.firstVisiblePageIndex;
    NSInteger lastVisiblePage = self.lastVisiblePageIndex;
    NSInteger firstPage = MAX(0,            MIN(firstVisiblePage, newPageIndex - _pagesToPreload));
    NSInteger lastPage  = MIN(pageCount-1, MAX(lastVisiblePage,  newPageIndex + _pagesToPreload));
    
    for (NSInteger index = firstPage; index <= lastPage; index ++) {
        if ([self viewForVisiblePageAtIndex:index] == nil) {
            UIViewController *pageViewController = [self viewControllerForPageAtIndex:index];
            UIView *page = pageViewController.view;
            [self configurePage:page forIndex:index];
            [_pageScrollView addSubview:page];
            [pageViewController didMoveToParentViewController:self];
            if (page) {
                [_visiblePages addObject:page];
            }
        }
    }
}

#pragma mark -- UIScrollViewDelegate

// segmentedControl is driven to move by page scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isMovingForward = scrollView.contentOffset.x > self.previousContentOffset;
    self.previousContentOffset = scrollView.contentOffset.x;
    
    [self configurePages];
    
    if ([self.segmentedControl respondsToSelector:@selector(moveToNormalizedOffset:)]) {
        [self.segmentedControl moveToNormalizedOffset:scrollView.contentOffset.x / scrollView.contentSize.width];
    }
}

// segmentedControl ends being driven to move
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self segmentedControllEndMovingWithScollView:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self segmentedControllEndMovingWithScollView:scrollView];
}

#pragma mark -- TTVNavigationSegmentedControlDelegate

// paging scroll view is driven to move by drag of segmented Control
- (void)segmentedControllDidDragWithNormalizedOffset:(CGFloat)offset
{
    CGPoint contentOffset = self.pageScrollView.contentOffset;
    contentOffset.x = offset * self.pageScrollView.contentSize.width;
    self.pageScrollView.contentOffset = contentOffset;
}

- (void)segmentedControllDidBeginSnapingToIndex:(NSUInteger)index withDuration:(NSTimeInterval)duration
{
    BOOL hasPageChanged = self.currentPageIndex != index;
    // paging scroll view is driven to snap when segmentedControl begins to snap
    self.previousPageIndex = self.currentPageIndex;
    self.currentPageIndex = index;
    CGPoint contentOffset = self.pageScrollView.contentOffset;
    contentOffset.x = index * self.pageScrollView.bounds.size.width;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pageScrollView.contentOffset = contentOffset;
    } completion:^(BOOL finished) {
        if (!hasPageChanged) return;
        
        if ([self.pageDelegate conformsToProtocol:@protocol(TTVSegmentedPageViewDelegate)]) {
            if ([self.pageDelegate respondsToSelector:@selector(viewControllerDidBecomeInvisible:isSwiping:)]) {
                [self.pageDelegate viewControllerDidBecomeInvisible:self.viewControllers[self.previousPageIndex] isSwiping:NO];
            }
            if ([self.pageDelegate respondsToSelector:@selector(viewControllerDidBecomeVisible:firstAppear:isSwiping:)]) {
                [self.pageDelegate viewControllerDidBecomeVisible:self.viewControllers[self.currentPageIndex] firstAppear:NO isSwiping:NO];
            }
            if ([self.pageDelegate respondsToSelector:@selector(viewControllerFromIndex:toIndex:)]) {
                [self.pageDelegate viewControllerFromIndex:self.previousPageIndex toIndex:self.currentPageIndex];
            }
        }
    }];
}

#pragma mark -- TTVSegmentedPageViewDelegate

- (void)viewControllerDidBecomeVisible:(UIViewController *)viewController firstAppear:(BOOL)firstAppear isSwiping:(BOOL)isSwiping {}

- (void)viewControllerDidBecomeInvisible:(UIViewController *)viewController isSwiping:(BOOL)isSwiping {}

@end
