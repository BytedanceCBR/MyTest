
#import <Foundation/Foundation.h>
#import "TTCommonPresentAnimator.h"
#import "TTSharedViewTransition.h"

@interface TTFloatPresentAnimator : TTCommonPresentAnimator

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactionController;

@end
