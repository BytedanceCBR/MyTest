//
//  TTCustomAnimationDelegate.h
//  Article
//
//  Created by 王双华 on 17/3/6.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTCustomAnimationStyle){
    TTCustomAnimationStyleUGCPostEntrance,
};

@interface TTCustomAnimationManager : NSObject

@property (nonatomic, assign) BOOL pushSearchVCWithCustomAnimation;

+ (instancetype)sharedManager;

- (void)registerFromVCClass:(Class)fromVCClass toVCClass:(Class)toVCClass animationClass:(Class)animationClass;

- (id)customAnimationForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC;

- (UIPercentDrivenInteractiveTransition *)percentDrivenTransitionForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController;

@end

@interface TTCustomAnimationDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UINavigationController *viewController;
@property (nonatomic, assign) TTCustomAnimationStyle style;

@end

@interface TTCustomAnimationPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface TTCustomAnimationDismissAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface TSVShortVideoEnterDetailAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@end

@interface TSVProfileVCEnterDetailAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@end

@interface TTCustomAnimationPushAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@end

