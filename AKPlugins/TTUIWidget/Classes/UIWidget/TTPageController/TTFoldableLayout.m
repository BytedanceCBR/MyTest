//
//  TTFoldableLayout.m
//  Article
//
//  Created by Dai Dongpeng on 4/17/16.
//
//

#import "TTFoldableLayout.h"
//#import "TTFoldableLayoutViewController.h"
#import "NSObject+MultiDelegates.h"
#import <Masonry/Masonry.h>
#import "TTSwipePageViewController.h"
@import ObjectiveC;

@interface TTFoldableLayout ()

@property (nonatomic, strong, nonnull)  NSLayoutConstraint *topConstraint;
@property (nonatomic, strong, nonnull)  NSLayoutConstraint *bottomHeightConstraint;
@property (nonatomic, weak) UIViewController *targetViewController;

@end

@interface UIScrollView (TTFoldableLayout)
@property (nonatomic) CGPoint tt_lastPoint;
@end

@implementation TTFoldableLayout
@synthesize headerView = _headerView, tabView = _tabView, pageViewController = _pageViewController,
minHeaderHeight = _minHeaderHeight, maxHeaderHeight = _maxHeaderHeight, headerViewController = _headerViewController,
tabViewOffset = _tabViewOffset, tabViewHeight = _tabViewHeight, bottomViewColor = _bottomViewColor;

#pragma mark - Life Cycle

- (void)dealloc
{
    NSLog(@">>> : %s",__func__);
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
    CGFloat bottomHeight = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight;
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
    [UIView animateWithDuration:animated ? .25 : 0 animations:^{
        self.topConstraint.constant = self.minHeaderHeight;
        if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
            [self.layoutDelegate distanceDidChanged:self.minHeaderHeight];
        }
        if (self.lockHeaderAutoFolded) {
            self.bottomHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight;
            [self.pageViewController.view setNeedsLayout];
            [self.pageViewController.view layoutIfNeeded];
        }
        [self.targetViewController.view setNeedsLayout];
        [self.targetViewController.view layoutIfNeeded];
    }];
}

- (void)resetLayoutToMaxHeader:(BOOL)animated
{
    [UIView animateWithDuration:animated ? .25 : 0 animations:^{
        self.topConstraint.constant = self.maxHeaderHeight;
        if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
            [self.layoutDelegate distanceDidChanged:self.maxHeaderHeight];
        }
        if (self.lockHeaderAutoFolded) {
            self.bottomHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.maxHeaderHeight;
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
    
    CGFloat bottomHeight = [UIScreen mainScreen].bounds.size.height - self.minHeaderHeight;
    if (self.lockHeaderAutoFolded) {
        bottomHeight = [UIScreen mainScreen].bounds.size.height - self.maxHeaderHeight;
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
    [self beginAnimationWithScrollView:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.topConstraint.constant >= self.maxHeaderHeight) {
        scrollView.tt_lastPoint = scrollView.contentOffset;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != [self currentScrollView]) {
        return ;
    }
    
    if (self.lockHeaderAutoFolded) {
        return;
    }
    
    if (scrollView.isDragging)
    {
        CGFloat originY = scrollView.contentOffset.y - scrollView.tt_lastPoint.y;
        
        CGFloat targetConstant = self.topConstraint.constant - originY;
        
        
        if (targetConstant <= self.minHeaderHeight) {
            
            targetConstant = self.minHeaderHeight;
            scrollView.tt_lastPoint = CGPointZero;
            
        } else if (targetConstant >= self.maxHeaderHeight) {
            
            targetConstant = self.maxHeaderHeight;
            
        } else {
            
            CGRect bounds = scrollView.bounds;
            bounds.origin.y = scrollView.tt_lastPoint.y;
            scrollView.bounds = bounds;
            
        }
        if (self.topConstraint.constant != targetConstant) {
            self.topConstraint.constant = targetConstant;
            
            if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
                [self.layoutDelegate distanceDidChanged:targetConstant];
            }
        }
    }
}

- (void)beginAnimationWithScrollView:(UIScrollView *)scrollView
{
    if (self.topConstraint.constant <= self.minHeaderHeight ||
        self.topConstraint.constant >= self.maxHeaderHeight)
    {
        return;
    }
    
    CGFloat constant = self.minHeaderHeight;
//    if (self.topConstraint.constant > (self.maxHeaderHeight + self.minHeaderHeight) / 2) {
//        constant = self.maxHeaderHeight;
//    }
    
    // make the animation of the header to follow the current direction of finger
    if ([scrollView.panGestureRecognizer velocityInView:scrollView].y >= 0) {
        constant = self.maxHeaderHeight;
    }
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.topConstraint.constant = constant;
        if ([self.layoutDelegate respondsToSelector:@selector(distanceDidChanged:)]) {
            [self.layoutDelegate distanceDidChanged:constant];
        }
        [self.targetViewController.view layoutIfNeeded];
        
    } completion:nil];
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

@end
//@implementation UIResponder (_TTFoldableLayoutItemDelegate)
//
//-(UIScrollView *)tt_foldableDirvenScrollView
//{
//    if ([self isKindOfClass:[UIScrollView class]]) {
//        return (UIScrollView *)self;
//    } else if ([self respondsToSelector:NSSelectorFromString(@"scrollView")]) {
//        return [self valueForKey:@"scrollView"];
//    } else if ([self respondsToSelector:NSSelectorFromString(@"listView")]) {
//        return [self valueForKey:@"listView"];
//    } else if ([self respondsToSelector:NSSelectorFromString(@"tableView")]) {
//        return [self valueForKey:@"tableView"];
//    }
//    else if ([self isKindOfClass:[UIViewController class]]) {
//        return [[(UIViewController *)self view] tt_foldableDirvenScrollView];
//    }
//    
//    return nil;
//}
//
//- (UIView *)tt_bottomView
//{
//    if ([self isKindOfClass:[UIView class]]) {
//        return (UIView *)self;
//    } else if ([self isKindOfClass:[UIViewController class]]) {
//        return [(UIViewController *)self view];
//    }
//    return nil;
//}
//
//@end

