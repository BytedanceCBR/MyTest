//
//  AKUILayout.m
//  Article
//
//  Created by chenjiesheng on 2018/3/13.
//

#import "AKUILayout.h"

@interface AKUILayoutContainerView : UIView

@end

@implementation AKUILayoutContainerView

@end

@implementation AKUILayout

+ (UIView *)horizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                             padding:(CGFloat)viewPadding
                            viewSize:(NSValue *)viewSize;
{
    AKUILayoutContainerView *containerView = nil;
    //检查是否拥有containerView
    for (NSInteger i = 0; i < subViews.count; i += 1) {
        UIView *view = subViews[i];
        UIView *superView = view.superview;
        if ([superView isKindOfClass:[AKUILayoutContainerView class]]) {
            if (!containerView) {
                containerView = (AKUILayoutContainerView *)superView;
            } else if (superView != containerView) {
                [superView removeFromSuperview];
            }
        } else {
            [superView removeFromSuperview];
        }
    }
    if (!containerView) {
        containerView = [[AKUILayoutContainerView alloc] init];
        containerView.backgroundColor = [UIColor clearColor];
    }
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [containerView addSubview:obj];
    }];
    [AKUILayout autoReSizeWithHorizontalLayoutViewWith:subViews
                                               padding:viewPadding
                                              viewSize:viewSize
                                         containerView:containerView];
    return containerView;
}

+ (UIView *)verticalLayoutViewWith:(NSArray<UIView *> *)subViews
                             padding:(CGFloat)viewPadding
                            viewSize:(NSValue *)viewSize;
{
    AKUILayoutContainerView *containerView = nil;
    //检查是否拥有containerView
    for (NSInteger i = 0; i < subViews.count; i += 1) {
        UIView *view = subViews[i];
        UIView *superView = view.superview;
        if ([superView isKindOfClass:[AKUILayoutContainerView class]]) {
            if (!containerView) {
                containerView = (AKUILayoutContainerView *)superView;
            } else if (superView != containerView) {
                [superView removeFromSuperview];
            }
        } else {
            [superView removeFromSuperview];
        }
    }
    if (!containerView) {
        containerView = [[AKUILayoutContainerView alloc] init];
        containerView.backgroundColor = [UIColor clearColor];
    }
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [containerView addSubview:obj];
    }];
    [AKUILayout autoReSizeWithVerticalLayoutViewWith:subViews
                                             padding:viewPadding
                                            viewSize:viewSize
                                       containerView:containerView];
    return containerView;
}

+ (void)autoReSizeWithHorizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                                       padding:(CGFloat)viewPadding
                                      viewSize:(NSValue *)viewSize
                                 containerView:(UIView *)containerView
{
    CGSize size = [AKUILayout sizeWithHorizontalLayoutViewWith:subViews
                                                       padding:viewPadding
                                                      viewSize:viewSize];
    containerView.size = size;
}

+ (CGSize)sizeWithHorizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                                   padding:(CGFloat)viewPadding
                                  viewSize:(NSValue *)viewSize
{
    return [self sizeWithHorizontalLayoutViewWith:subViews
                                          padding:viewPadding
                                         viewSize:viewSize
                                     firstPadding:0];
}

+ (CGSize)sizeWithHorizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                                   padding:(CGFloat)viewPadding
                                  viewSize:(NSValue *)viewSize
                              firstPadding:(CGFloat)firstPadding
{
    CGSize specialSize = viewSize.CGSizeValue;
    BOOL useSpecialSize = viewSize && !CGSizeEqualToSize(CGSizeZero, specialSize);
    __block CGFloat centerY = specialSize.height / 2;
    if (!useSpecialSize) {
        [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            centerY = MAX(obj.height / 2, centerY);
        }];
    }
    __block CGFloat viewLeft = firstPadding;
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (useSpecialSize) {
            obj.size = specialSize;
        }
        obj.left = viewLeft;
        obj.centerY = centerY;
        viewLeft = obj.right + viewPadding;
    }];
    return CGSizeMake(viewLeft - viewPadding, centerY * 2);
}

+ (void)horizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                         padding:(CGFloat)viewPadding
                        viewSize:(NSValue *)viewSize
                    firstPadding:(CGFloat)firstPadding
                         centerY:(CGFloat)centerY
{
    CGSize specialSize = viewSize.CGSizeValue;
    BOOL useSpecialSize = viewSize && !CGSizeEqualToSize(CGSizeZero, specialSize);
    __block CGFloat viewLeft = firstPadding;
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (useSpecialSize) {
            obj.size = specialSize;
        }
        obj.left = viewLeft;
        obj.centerY = centerY;
        viewLeft = obj.right + viewPadding;
    }];
}

+ (void)autoReSizeWithVerticalLayoutViewWith:(NSArray<UIView *> *)subViews
                                     padding:(CGFloat)viewPadding
                                    viewSize:(NSValue *)viewSize
                               containerView:(UIView *)containerView
{
    CGSize size = [AKUILayout sizeWithVerticalLayoutViewWith:subViews
                                                     padding:viewPadding
                                                    viewSize:viewSize];
    containerView.size = size;
}

+ (CGSize)sizeWithVerticalLayoutViewWith:(NSArray<UIView *> *)subViews
                                   padding:(CGFloat)viewPadding
                                  viewSize:(NSValue *)viewSize
{
    return [self sizeWithVerticalLayoutViewWith:subViews
                                        padding:viewPadding
                                       viewSize:viewSize firstPadding:0];
}

+ (CGSize)sizeWithVerticalLayoutViewWith:(NSArray<UIView *> *)subViews
                                 padding:(CGFloat)viewPadding
                                viewSize:(NSValue *)viewSize
                            firstPadding:(CGFloat)firstPadding
{
    CGSize specialSize = viewSize.CGSizeValue;
    BOOL useSpecialSize = viewSize && !CGSizeEqualToSize(CGSizeZero, specialSize);
    __block CGFloat centerX = specialSize.width / 2;
    if (!useSpecialSize) {
        [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            centerX = MAX(obj.width / 2, centerX);
        }];
    }
    __block CGFloat viewTop = firstPadding;
    [subViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (useSpecialSize) {
            obj.size = specialSize;
        }
        obj.top = viewTop;
        obj.centerX = centerX;
        viewTop = obj.bottom + viewPadding;
    }];
    return CGSizeMake(centerX * 2,viewTop - viewPadding);
}
@end
