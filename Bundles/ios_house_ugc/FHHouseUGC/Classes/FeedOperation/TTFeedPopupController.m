//
//  TTFeedPopupController.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/15.
//

#import "TTFeedPopupController.h"
#import "UIViewAdditions.h"
#import <objc/runtime.h>

@interface TTFeedPopupController ()
/// 会同 TTFeedDislikeView 相互持有，使用 weak 防止循环引用
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSMutableArray<UIView *> *views;
@end

@implementation TTFeedPopupController

- (instancetype)initWithContainer:(UIView *)container contentView:(nonnull UIView *)contentView {
    if (self = [super init]) {
        _containerView = container;
        _contentView = contentView;
        _views = [NSMutableArray array];
    }
    return  self;
}

- (void)pushView:(UIView *)view animated:(BOOL)animated {
    UIView *topView = self.topView;
    [self.views addObject:view];
    view.popupController = self;
    [self transitionFromView:topView toView:self.topView animated:animated forward:YES];
}

- (void)popViewAnimated:(BOOL)animated {
    if (self.views.count <= 1) return;
    UIView *topView = self.topView;
    [self.views removeLastObject];
    [self transitionFromView:topView toView:self.topView animated:animated forward:NO];
    topView.popupController = nil;
}

- (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView animated:(BOOL)animated forward:(BOOL)forward {
    if (toView.width == 0) toView.width = self.containerView.width;
    [self.contentView addSubview:toView];
    [self.containerView layoutIfNeeded];
    if (animated) {
        self.containerView.userInteractionEnabled = NO;
        toView.alpha = 0.0;
        if (forward) {
            fromView.left = 0.0;
            toView.left = toView.width;
        } else {
            fromView.left = 0;
            toView.left = -toView.width;
        }
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (forward) {
                fromView.left = -fromView.width;
                toView.left = 0.0;
            } else {
                fromView.left = fromView.width;
                toView.left = 0.0;
            }
            toView.left = 0.0;
            toView.left = 0.0;
            [self layoutContainerView];
            fromView.alpha = 0.0;
            toView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [fromView  removeFromSuperview];
            self.containerView.userInteractionEnabled = YES;
        }];
    } else {
        [self layoutContainerView];
        [fromView removeFromSuperview];
    }
}

- (void)layoutContainerView {
    CGSize topViewSize = [self contentSizeOfTopView];
    self.contentView.size = topViewSize;
    self.contentView.left = 0;
    self.contentView.top =  self.isArrowOnTop ? 8.0 : 0.0;
    self.topView.frame = self.contentView.bounds;
    CGFloat bottom = self.containerView.bottom;
    self.containerView.size = CGSizeMake(topViewSize.width, topViewSize.height + 8.0);
    if (!self.isArrowOnTop) {
        self.containerView.bottom = bottom;
    }
}

- (CGSize)contentSizeOfTopView {
    return self.topView.contentSizeInPopup;
}

- (UIView *)topView {
    return self.views.lastObject;
}

@end


@implementation UIView (TTFeedPopup)
@dynamic contentSizeInPopup;
@dynamic popupController;

- (void)setContentSizeInPopup:(CGSize)contentSizeInPopup
{
    objc_setAssociatedObject(self, @selector(contentSizeInPopup), [NSValue valueWithCGSize:contentSizeInPopup], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)contentSizeInPopup
{
    return [objc_getAssociatedObject(self, @selector(contentSizeInPopup)) CGSizeValue];
}

- (void)setPopupController:(TTFeedPopupController * _Nullable)transitionController {
    objc_setAssociatedObject(self, @selector(popupController), transitionController, OBJC_ASSOCIATION_ASSIGN);
}

- (TTFeedPopupController *)popupController {
    return objc_getAssociatedObject(self, @selector(popupController));
}

@end
