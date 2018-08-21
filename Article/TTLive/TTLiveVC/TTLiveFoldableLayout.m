//
//  TTLiveFoldableLayout.m
//  Article
//
//  Created by 杨心雨 on 2016/11/3.
//
//

#import "TTLiveFoldableLayout.h"
#import "NSObject+MultiDelegates.h"
#import <Masonry/Masonry.h>
#import "TTSwipePageViewController.h"
#import "UIScrollView+Refresh.h"
@import ObjectiveC;

@interface TTLiveFoldableLayout ()

@property (nonatomic, strong, nonnull)  NSLayoutConstraint *topConstraint;
@property (nonatomic, strong, nonnull)  NSLayoutConstraint *bottomHeightConstraint;
@property (nonatomic, weak) UIViewController *targetViewController;
@property (nonatomic, assign)BOOL animationDisable;
@end

@interface UIScrollView (TTFoldableLayout)
@property (nonatomic) CGPoint tt_lastPoint;
@property (nonatomic) CGSize tt_lastSize;
@end

@implementation TTLiveFoldableLayout
@synthesize headerView = _headerView, tabView = _tabView, pageViewController = _pageViewController,
minHeaderHeight = _minHeaderHeight, maxHeaderHeight = _maxHeaderHeight, headerViewController = _headerViewController,
tabViewOffset = _tabViewOffset, tabViewHeight = _tabViewHeight, bottomViewColor = _bottomViewColor;

#pragma mark - Life Cycle

- (void)dealloc
{
    // NSLog(@">>> : %s",__func__);
}

- (instancetype)initWithItems:(NSArray <UIViewController <TTFoldableLayoutItemDelegate>*> *)items
{
    if (self = [super init]) {
        _items = items;
        _tabViewOffset = UIEdgeInsetsMake(0, 0, 5, 0);
        _bottomViewColor = [UIColor lightGrayColor];
        _tabViewHeight = 44;
    }
    return self;
}

- (instancetype)initWithItems:(NSArray <NSObject <TTFoldableLayoutItemDelegate>*> *)items
                     delegate:(id <TTFoldableLayoutDelegate>)layoutDelegate
{
    if (self = [self initWithItems:items]) {
        _layoutDelegate = layoutDelegate;
    }
    return self;
}

#pragma mark - TTLayoutProtocol

- (void)resetLayoutSubItems
{
    CGFloat bottomHeight = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight - self.targetViewController.view.tt_safeAreaInsets.bottom;
    self.bottomHeightConstraint.constant = bottomHeight;
}

/*
 - (void)resetLayoutToMinHeader:(BOOL)animated
 {
 if (self.lockHeaderAutoFolded) {
 self.bottomHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight;
 }
 
 [UIView animateWithDuration:animated ? .25 : 0 animations:^{
 self.topConstraint.constant = self.minHeaderHeight;
 if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
 [self.layoutDelegate distanceDidChanged:self.minHeaderHeight];
 }
 [self.targetViewController.view setNeedsLayout];
 [self.targetViewController.view layoutIfNeeded];
 }];
 }
 
 - (void)resetLayoutToMaxHeader:(BOOL)animated
 {
 if (self.lockHeaderAutoFolded) {
 self.bottomHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.maxHeaderHeight;
 }
 
 [UIView animateWithDuration:animated ? .25 : 0 animations:^{
 self.topConstraint.constant = self.maxHeaderHeight;
 if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
 [self.layoutDelegate distanceDidChanged:self.maxHeaderHeight];
 }
 [self.targetViewController.view setNeedsLayout];
 [self.targetViewController.view layoutIfNeeded];
 }];
 }
 */

- (void)resetLayoutToMinHeader:(BOOL)animated
{
    self.headerViewFolded = YES;
    [UIView animateWithDuration:animated ? .25 : 0 animations:^{
        self.topConstraint.constant = self.minHeaderHeight;
        if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
            [self.layoutDelegate distanceDidChanged:0];
        }
        if (self.lockHeaderAutoFolded) {
            self.bottomHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight - self.targetViewController.view.tt_safeAreaInsets.bottom;
            [self.pageViewController.view setNeedsLayout];
            [self.pageViewController.view layoutIfNeeded];
        }
        [self.targetViewController.view setNeedsLayout];
        [self.targetViewController.view layoutIfNeeded];
    }];
}

- (void)resetLayoutToMaxHeader:(BOOL)animated
{
    self.headerViewFolded = NO;
    [UIView animateWithDuration:animated ? .15 : 0 animations:^{
        self.topConstraint.constant = self.maxHeaderHeight;
        if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
            [self.layoutDelegate distanceDidChanged:1];
        }
        if (self.lockHeaderAutoFolded) {
            self.bottomHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.maxHeaderHeight - self.targetViewController.view.tt_safeAreaInsets.bottom;
            [self.pageViewController.view setNeedsLayout];
            [self.pageViewController.view layoutIfNeeded];
        }
        [self.targetViewController.view setNeedsLayout];
        [self.targetViewController.view layoutIfNeeded];
    }];
}

- (UIScrollView *)currentScrollView
{
    __block UIScrollView *scrollView;
    [self.items enumerateObjectsUsingBlock:^(UIViewController<TTFoldableLayoutItemDelegate> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tt_ControllerIsVisiable) {
            scrollView = [obj tt_foldableDirvenScrollView];
            *stop = YES;
        }
    }];
    return scrollView;
}

- (void)layoutWillAddToTargetViewController:(UIViewController *)targetViewController
{
    
}

- (void)layoutDidAddToTargetViewController:(UIViewController *)targetViewController
{
    if (!targetViewController) {
        return ;
    }
    
    
    NSArray <NSObject <TTFoldableLayoutItemDelegate>*> * items = self.items;
    self.targetViewController = targetViewController;
    
    [items enumerateObjectsUsingBlock:^(NSObject<TTFoldableLayoutItemDelegate> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[obj tt_foldableDirvenScrollView] tt_addDelegate:self asMainDelegate:NO];
        
    }];
    
    UIView *targetView = self.targetViewController.view;
    
    // add bottom
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = self.bottomViewColor;
    [targetView addSubview:bottomView];
    
    // add header
    if (self.headerView) {
        [targetView addSubview:self.headerView];
    } else if (self.headerViewController){
        self.headerView = self.headerViewController.view;
        [targetView addSubview:self.headerView];
        [targetViewController addChildViewController:self.headerViewController];
        [self.headerViewController didMoveToParentViewController:targetViewController];
    }
    
    // add tabView
    if (self.tabView) {
        [targetView addSubview:self.tabView];
    }
    
    // add page
    UIView *pagesView = self.pageViewController.view;
    if (pagesView) {
        [targetView addSubview:pagesView];
        [targetViewController addChildViewController:self.pageViewController];
        [self.pageViewController didMoveToParentViewController:targetViewController];
    }
    
    // add constraint
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(targetView.mas_top).with.priority(900);
        make.left.equalTo(targetView.mas_left);
        make.right.equalTo(targetView.mas_right);
        make.bottom.equalTo(bottomView.mas_top);
        make.height.equalTo(@(self.maxHeaderHeight));
        
    }];
    
    CGFloat bottomHeight = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight - targetView.tt_safeAreaInsets.bottom;
    if (self.lockHeaderAutoFolded) {
        bottomHeight = [UIScreen mainScreen].bounds.size.height - self.maxHeaderHeight  - targetView.tt_safeAreaInsets.bottom;
    }
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(targetView.mas_left);
        make.right.equalTo(targetView.mas_right);
    }];
    
    self.bottomHeightConstraint = [NSLayoutConstraint constraintWithItem:bottomView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.f
                                                                constant:bottomHeight];
    
    self.topConstraint = [NSLayoutConstraint constraintWithItem:bottomView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:targetView
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.f
                                                       constant:self.maxHeaderHeight];
    
    [targetView addConstraints:@[self.bottomHeightConstraint, self.topConstraint]];
    
    
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(bottomView.mas_top).with.offset(self.tabViewOffset.top);
        make.left.equalTo(bottomView.mas_left).with.offset(self.tabViewOffset.left);
        make.right.equalTo(bottomView.mas_right).with.offset(self.tabViewOffset.right);
        make.bottom.equalTo(pagesView.mas_top).with.offset(-self.tabViewOffset.bottom);
        make.height.equalTo(@(self.tabViewHeight));
    }];
    
    [pagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(bottomView.mas_left);
        make.right.equalTo(bottomView.mas_right);
        make.bottom.equalTo(bottomView.mas_bottom);
    }];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView != [self currentScrollView]) {
        return ;
    }
    [self beginAnimationWithScrollView:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != [self currentScrollView]) {
        return ;
    }
    self.lockFoldOneOpen = NO;
    [self beginAnimationWithScrollView:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    self.lockFoldOneOpen = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.topConstraint.constant >= self.maxHeaderHeight) {
        scrollView.tt_lastPoint = scrollView.contentOffset;
        scrollView.tt_lastSize = scrollView.contentSize;
    }
    
    if (self.topConstraint.constant <= self.minHeaderHeight){
        scrollView.tt_lastPoint = CGPointZero;
        scrollView.tt_lastSize = scrollView.contentSize;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != [self currentScrollView]) {
        return ;
    }
    
    if (scrollView.hasMore && _headerViewFolded){
        return;
    }
    
    if (self.lockHeaderAutoFolded || !self.unlockPushToFolded || self.lockFoldOneOpen) {
        return;
    }
    
    if (scrollView.isDragging)
    {
        CGFloat originY = scrollView.contentOffset.y - scrollView.tt_lastPoint.y - scrollView.contentSize.height + scrollView.tt_lastSize.height;
        CGFloat targetConstant = self.topConstraint.constant - originY;
        if (targetConstant <= self.minHeaderHeight) {
            
            targetConstant = self.minHeaderHeight;
            scrollView.tt_lastPoint = CGPointZero;
//            [self resetLayoutToMinHeader:YES];
        }
        else if (targetConstant >= self.maxHeaderHeight) {
//            targetConstant = self.topConstraint.constant;
//
            targetConstant = self.maxHeaderHeight;
//            [self resetLayoutToMaxHeader:YES];
        }
        else {
            CGRect bounds = scrollView.bounds;
            bounds.origin.y = scrollView.tt_lastPoint.y;
            scrollView.bounds = bounds;
        }
        if (self.topConstraint.constant != targetConstant) {
            self.topConstraint.constant = targetConstant;
            if (/*shouldPerformSeletor && */[self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
                [self.layoutDelegate distanceDidChanged:(self.topConstraint.constant  - self.minHeaderHeight)/(self.maxHeaderHeight - self.minHeaderHeight)];
            }
        }
    }
}

- (void)beginAnimationWithScrollView:(UIScrollView *)scrollView
{
    if (self.topConstraint.constant <= self.minHeaderHeight ||
        self.topConstraint.constant >= self.maxHeaderHeight || _animationDisable)
    {
        _headerViewFolded = self.topConstraint.constant <= self.minHeaderHeight;
        return;
    }
    
    _animationDisable = YES;
    
    CGFloat constant = _headerViewFolded ? self.maxHeaderHeight : self.minHeaderHeight;
    
    _headerViewFolded = !_headerViewFolded;
    
    UIPanGestureRecognizer *panGesture = scrollView.panGestureRecognizer;
    CGFloat yVelocity = [panGesture velocityInView:panGesture.view].y;
    if (yVelocity == 0){
        yVelocity = 1;
    }
    CGFloat duration = !_headerViewFolded ? fabs((self.topConstraint.constant - constant) / yVelocity) : .15f;
    if (duration > 1.f){
        duration = .15f;
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.topConstraint.constant = constant;
        if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
            [self.layoutDelegate distanceDidChanged:_headerViewFolded ? 0.f : 1.f];
        }
        [self.targetViewController.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        _animationDisable = NO;
    }];
}

@end

@implementation UIScrollView (TTFoldableLayout)

- (CGPoint)tt_lastPoint
{
    id obj = objc_getAssociatedObject(self, _cmd);
    if ([obj isKindOfClass:[NSValue class]]) {
        return [obj CGPointValue];
    }
    return CGPointZero;
}

- (void)setTt_lastPoint:(CGPoint)tt_lastPoint
{
    objc_setAssociatedObject(self, @selector(tt_lastPoint), [NSValue valueWithCGPoint:tt_lastPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)tt_lastSize {
    id obj = objc_getAssociatedObject(self, _cmd);
    if ([obj isKindOfClass:[NSValue class]]) {
        return [obj CGSizeValue];
    }
    return CGSizeZero;
}

- (void)setTt_lastSize:(CGSize)tt_lastSize {
    objc_setAssociatedObject(self, @selector(tt_lastSize), [NSValue valueWithCGSize:tt_lastSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

