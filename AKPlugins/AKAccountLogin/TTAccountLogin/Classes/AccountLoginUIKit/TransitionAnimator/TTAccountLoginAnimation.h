//
//  TTAccountLoginAnimation.h
//  TTAccountLogin
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import <UIKit/UIKit.h>



typedef
NS_ENUM(NSInteger, TTAccountLoginPresentAnimationType) {
    TTAccountLoginPresentAnimationTypeDefault,
    TTAccountLoginPresentAnimationTypeNoScale,
};



@interface TTAccountLoginAnimationDelegate : NSObject
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate
>

@property (nonatomic,   weak) UINavigationController *viewController;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactionController;
@property (nonatomic, assign) TTAccountLoginPresentAnimationType type;

+ (instancetype)sharedDelegate;

+ (UITapGestureRecognizer *)tapGestureRecognizer;
+ (void)setTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer;

- (void)ttAnimationPan:(UIPanGestureRecognizer *)recognizer;

@end



@interface TTAccountLoginPresentAnimation : NSObject
<
UIViewControllerAnimatedTransitioning
>
@property (nonatomic, assign) TTAccountLoginPresentAnimationType type;
@end



@interface TTAccountLoginDismissAnimation : NSObject
<
UIViewControllerAnimatedTransitioning
>

@end



@interface TTAccountLoginPushAnimation : NSObject
<
UIViewControllerAnimatedTransitioning
>

@end



@interface TTAccountLoginPopAnimation : NSObject
<
UIViewControllerAnimatedTransitioning
>

@end
