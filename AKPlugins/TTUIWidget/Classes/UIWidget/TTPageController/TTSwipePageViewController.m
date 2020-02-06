//
//  TTSwipePageViewController.m
//  Article
//
//  Created by Dai Dongpeng on 4/9/16.
//
//

#import "TTNavigationController.h"
#import "TTSwipePageViewController.h"
#import <Masonry/Masonry.h>
@import ObjectiveC;

@interface _TTInternalPanAvailableScrollView : UIScrollView
@property (nonatomic, assign) BOOL forbidFullScreenPanGesture;
@end

@interface TTSwipePageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) _TTInternalPanAvailableScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray <__kindof UIViewController *> *backedViewControllers;
@property (nonatomic, assign) CGFloat lastOffset; // 保留上次的状态，判断滚动方向

@end

@implementation TTSwipePageViewController

- (void)dealloc {
    _scrollView.delegate = nil;
}

#pragma mark - Life Cycle

- (instancetype)initWithDefaultSelectedIndex:(NSUInteger)defaultIndex
{
    self = [super init];
    if (self) {
        _selectedIndex = defaultIndex;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scrollView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * self.pages.count, CGRectGetHeight(self.view.frame));
    self.scrollView.contentOffset = CGPointMake(self.selectedIndex * CGRectGetWidth(self.view.frame),0);   
    
    [self.backedViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = CGRectMake(CGRectGetWidth(self.view.frame) * idx, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }];
}

#pragma mark - Public Methods

- (UIViewController *)currentPageViewController
{
    return [self pageViewControllerWithIndex:self.selectedIndex];
}

- (UIViewController *)pageViewControllerWithIndex:(NSInteger)index
{
    if (index >= 0 && index < self.backedViewControllers.count) {
        return self.backedViewControllers[index];
    }
    return nil;
}

- (UIScrollView *)internalScrollView
{
    return self.scrollView;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (_selectedIndex != selectedIndex && selectedIndex < self.backedViewControllers.count)
    {
        UIViewController *from = self.backedViewControllers[_selectedIndex];
        UIViewController *to = self.backedViewControllers[selectedIndex];
        if (!self.shouldAutoForwordAppearances) {
            [from beginAppearanceTransition:NO animated:NO];
            [to beginAppearanceTransition:YES animated:NO];
        }
        
        from.tt_ControllerIsVisiable = NO;
        to.tt_ControllerIsVisiable = YES;
        
        _selectedIndex = selectedIndex;
        [UIView animateWithDuration:(animated ? .25f : 0) animations:^{
            CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.view.frame) * selectedIndex, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.scrollView.delegate = nil;
            [self.scrollView scrollRectToVisible:rectToVisible animated:NO];
        } completion:^(BOOL finished) {
            self.scrollView.delegate = self;
            if (!self.shouldAutoForwordAppearances) {
                [from endAppearanceTransition];
                [to endAppearanceTransition];
            }
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(enableEdgeSwipStrategy)]) {
        if ([self.delegate enableEdgeSwipStrategy]) {
            if (_selectedIndex == 0) {
                self.scrollView.forbidFullScreenPanGesture = NO;
            } else {
                self.scrollView.forbidFullScreenPanGesture = YES;
            }
        }
    }
}

#pragma mark - ForwardAppearanceMethods

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return self.shouldAutoForwordAppearances;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.shouldAutoForwordAppearances) {
        [[self currentPageViewController] beginAppearanceTransition:YES animated:animated];
    }
    [self currentPageViewController].tt_ControllerIsVisiable = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.shouldAutoForwordAppearances) {
        [[self currentPageViewController] endAppearanceTransition];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.shouldAutoForwordAppearances) {
        [[self currentPageViewController] beginAppearanceTransition:NO animated:animated];
    }
    [self currentPageViewController].tt_ControllerIsVisiable = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!_shouldAutoForwordAppearances) {
        [[self currentPageViewController] endAppearanceTransition];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat offsetX = scrollView.contentOffset.x;
    
    NSUInteger fromIndex = roundf(offsetX / viewWidth);
    NSUInteger toIndex = ceilf(offsetX / viewWidth);
    if (toIndex == fromIndex) {
        toIndex = floorf(offsetX / viewWidth);
    }
    
    CGFloat remainder = remainderf(offsetX - fromIndex * viewWidth, viewWidth);
    CGFloat percent = remainder * (1.0 / viewWidth);
    
    if ([self.delegate respondsToSelector:@selector(pageViewController:pagingFromIndex:toIndex:completePercent:)]) {
        [self.delegate pageViewController:self pagingFromIndex:fromIndex toIndex:toIndex completePercent:percent];
    }
    
    NSUInteger index = (NSUInteger)(offsetX / viewWidth);
    NSUInteger nextIndex = 0;
    CGFloat offset = offsetX / viewWidth;
    CGFloat scrollPercent = offsetX / viewWidth - index;
    if (scrollPercent < 0 || scrollPercent > 1) {
        scrollPercent = 0;
    }
    BOOL isLeftDirection = YES;
    if (self.lastOffset < offset) {
        isLeftDirection = NO;
    }
    self.lastOffset = offset;
    if (isLeftDirection) {
        index++;
        nextIndex = (index != 0) ? index - 1 : 0;
        scrollPercent = 1 - scrollPercent;
    } else {
        nextIndex = (index + 1 < self.pages.count) ? index + 1 : index;
    }
    if ([self.delegate respondsToSelector:@selector(pageViewController:scrollFromIndex:toIndex:percent:)]) {
        [self.delegate pageViewController:self scrollFromIndex:index toIndex:nextIndex percent:scrollPercent];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self didEndPagingForScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self didEndPagingForScrollView:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageViewControllerWillBeginDragging:)]) {
        [self.delegate pageViewControllerWillBeginDragging:scrollView];
    }
    
    NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    
    if ([self.delegate respondsToSelector:@selector(pageViewController:willPagingToIndex:)]) {
        [self.delegate pageViewController:self willPagingToIndex:index];
    }
}

#pragma mark - Getters

- (_TTInternalPanAvailableScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[_TTInternalPanAvailableScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces  = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (NSMutableArray *)backedViewControllers
{
    if (!_backedViewControllers) {
        _backedViewControllers = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _backedViewControllers;
}

//- (NSMutableArray<UIScrollView *> *)backedScrollViews
//{
//    if (!_backedScrollViews) {
//        _backedScrollViews = [[NSMutableArray alloc] initWithCapacity:5];
//    }
//    return _backedScrollViews;
//}

#pragma mark - Setters

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:YES];
}

- (void)setPages:(NSArray<__kindof UIResponder *> *)pages
{
    if (_pages != pages)
    {
        [self.backedViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([self.childViewControllers containsObject:obj]) {
                [obj willMoveToParentViewController:nil];
                [obj removeFromParentViewController];
                [self.backedViewControllers removeObject:obj];
            }
        }];
        
        _pages = pages;
        
        [pages enumerateObjectsUsingBlock:^(UIResponder *responder, NSUInteger idx, BOOL *stop) {
            
            NSParameterAssert([responder isKindOfClass:[UIViewController class]] ||
                              [responder isKindOfClass:[UIView class]]);
            
            UIViewController *viewController;
            
            if ([responder isKindOfClass:[UIViewController class]]) {
                
                viewController = (UIViewController *)responder;
                
            } else if ([responder isKindOfClass:[UIView class]]) {
                
                UIViewController *vc = [UIViewController new];
                vc.view = (UIView *)responder;
                viewController = vc;
            }
            
            [self addChildViewController:viewController];
            [viewController didMoveToParentViewController:self];
            [self.backedViewControllers addObject:viewController];
            
            viewController.view.frame = CGRectMake(CGRectGetWidth(self.view.frame) * idx, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            [self.scrollView addSubview:viewController.view];
            
        }];
        
        CGFloat widthOfPage = CGRectGetWidth(self.view.frame);
        self.scrollView.contentSize = CGSizeMake(widthOfPage * pages.count, CGRectGetHeight(self.view.frame));
        [self.scrollView setContentOffset:CGPointMake(widthOfPage * _selectedIndex, 0) animated:NO];
    }
}

#pragma mark - Helper

- (void)didEndPagingForScrollView:(UIScrollView *)scrollView {
    self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    if ([self.delegate respondsToSelector:@selector(enableEdgeSwipStrategy)]) {
        if ([self.delegate enableEdgeSwipStrategy]) {
            if (self.selectedIndex == 0) {
                self.scrollView.forbidFullScreenPanGesture = NO;
            } else {
                self.scrollView.forbidFullScreenPanGesture = YES;
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(pageViewController:didPagingToIndex:)]) {
        [self.delegate pageViewController:self didPagingToIndex:self.selectedIndex];
    }
}

@end

#pragma mark - Private Class

@implementation _TTInternalPanAvailableScrollView
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    if (gestureRecognizer == self.panGestureRecognizer && self.forbidFullScreenPanGesture) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint location = [gestureRecognizer locationInView:self];
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat diviation = location.x - (int)(location.x / screenWidth) * screenWidth;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            if (diviation <= TTNavigationControllerDefaultSwapLeftEdge) {
                return NO;
            }
        }
    }
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self];
        CGFloat threshold = self.bounds.size.width;
        if (velocity.x > 0 && self.contentOffset.x <= 0 &&
            [gestureRecognizer locationInView:self].x < threshold) {
            return NO;
        }
        
        UIView *hitTestView =[self hitTest:[gestureRecognizer locationInView:self] withEvent:nil];
        if ([hitTestView isKindOfClass:[UISlider class]]) {
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end
@implementation UIViewController (TTSWipePageAddition)

- (BOOL)tt_ControllerIsVisiable
{
    id obj = objc_getAssociatedObject(self, _cmd);
    if ([obj respondsToSelector:@selector(boolValue)]) {
        return [obj boolValue];
    }
    return NO;
}

- (void)setTt_ControllerIsVisiable:(BOOL)tt_ControllerIsVisiable
{
    objc_setAssociatedObject(self, @selector(tt_ControllerIsVisiable), @(tt_ControllerIsVisiable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
