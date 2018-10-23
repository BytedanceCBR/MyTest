//
//  TTSwipePageViewController.m
//  Article
//
//  Created by Dai Dongpeng on 4/9/16.
//
//

#import "TTSwipePageViewController.h"
#import <Masonry/Masonry.h>
@import ObjectiveC;

@interface _TTInternalPanAvailableScrollView : UIScrollView
@end

@interface TTSwipePageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) _TTInternalPanAvailableScrollView *scrollView;
@property (nonatomic)         NSUInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray <__kindof UIViewController *> *backedViewControllers;
//@property (nonatomic, strong) NSMutableArray <__kindof UIScrollView *> *backedScrollViews;

@end

@implementation TTSwipePageViewController

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
//    CGPoint contentOffset = scrollView.contentOffset;
//    double rate = contentOffset.x / scrollView.frame.size.width;
//    
//    //左边页面
//    NSInteger leftPage;
//    //右边页面
//    NSInteger rightPage;
//    if (scrollView.contentOffset.x <= 0) {
//        leftPage = 0;
//        rightPage = 0;
//    }else if (scrollView.contentOffset.x >= (scrollView.frame.size.width * (_pages.count -1))) {
//        leftPage = _pages.count -1;
//        rightPage = _pages.count -1;
//    }else {
//        leftPage = (NSInteger)rate;
//        rightPage = leftPage + 1;
//    }
//    
//    NSLog(@"leftPage:%ld",leftPage);
//    NSLog(@"percent:%f",fabs(rate - (NSInteger)rate));
//    
//    
//    if ([self.delegate respondsToSelector:@selector(pageViewController:pagingFromIndex:toIndex:completePercent:)]) {
//        [self.delegate pageViewController:self pagingFromIndex:leftPage toIndex:rightPage completePercent:fabs(rate - (NSInteger)rate)];
//    }

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
    
    if ([self.delegate respondsToSelector:@selector(pageViewController:didPagingToIndex:)]) {
        [self.delegate pageViewController:self didPagingToIndex:self.selectedIndex];
    }
}

@end

#pragma mark - Private Class

@implementation _TTInternalPanAvailableScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self];
        CGFloat threshold = self.bounds.size.width;
        if (velocity.x > 0 && self.contentOffset.x <= 0 &&
            [gestureRecognizer locationInView:self].x < threshold) {
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
