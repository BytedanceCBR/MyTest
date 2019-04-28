//
//  TTArticleMomentAnimationDelegate.h
//  Article
//
//  Created by zhaoqin on 26/12/2016.
//
//

#import <Foundation/Foundation.h>
#import "TTNavigationController.h"

@interface TTArticleMomentAnimationDelegate : NSObject <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *viewController;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactionController;

+ (UITapGestureRecognizer *)tapGestureRecognizer;
+ (void)setTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer;
+ (instancetype)shareDelegate;
- (void)ttAnimationPan:(UIPanGestureRecognizer *)recognizer;

- (void)addGesture;
- (void)removeGesture;

@end

@interface TTMomentPresentAnimation: NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface TTMomentDismissAnimation: NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface TTMomentPushAnimation: NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface TTMomentPopAnimation: NSObject <UIViewControllerAnimatedTransitioning>

@end
