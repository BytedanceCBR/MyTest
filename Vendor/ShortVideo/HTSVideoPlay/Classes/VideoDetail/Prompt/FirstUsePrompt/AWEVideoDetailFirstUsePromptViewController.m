//
//  AWEVideoDetailFirstUsePromptViewController.m
//  Pods
//
//  Created by Zuyang Kou on 30/06/2017.
//
//

#import "AWEVideoDetailFirstUsePromptViewController.h"
#import "AWEVideoDetailSwipePromptAnimationViewController.h"

@interface AWEVideoDetailFirstUsePromptViewController ()<UIGestureRecognizerDelegate>

@end

@implementation AWEVideoDetailFirstUsePromptViewController

static UIViewController<AWEVideoDetailFirstUsePromptViewController> *promptViewController;

+ (BOOL)needPromotionForDirection:(AWEPromotionDiretion)direction
                         category:(AWEPromotionCategory)category

{
    NSString *key = [self userDefaultKeyForDirection:direction category:category];
    return ![[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)setNeedPromotionForDirection:(AWEPromotionDiretion)direction
                            category:(AWEPromotionCategory)category
{
    NSString *key = [self userDefaultKeyForDirection:direction category:category];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}

+ (NSString *)userDefaultKeyForDirection:(AWEPromotionDiretion)direction
                                category:(AWEPromotionCategory)category
{
    NSDictionary *mapping = @{
                              @(AWEPromotionCategoryDefault): @{
                                      @(AWEPromotionDiretionLeft): @"Left",
                                      @(AWEPromotionDiretionUpVideoSwitch): @"NewVersionUp",
                                      },
                              @(AWEPromotionCategoryA): @{
                                      @(AWEPromotionDiretionLeft): @"LeftA",
                                      @(AWEPromotionDiretionUpVideoSwitch): @"NewVersionUpA",
                                      },
                              };
    NSString *key = [@"AWEVideoDetailFirstUsePromotionViewControllerShown" stringByAppendingString:mapping[@(category)][@(direction)]];

    return key;
}

+ (void)showPromotionIfNeededWithDirection:(AWEPromotionDiretion)direction
                                  category:(AWEPromotionCategory)category
                          inViewController:(UIViewController *)containerViewController;
{
    if (![self needPromotionForDirection:direction category:category]) {
        return;
    }

    if (promptViewController && [promptViewController respondsToSelector:@selector(dismiss)]) {
        [promptViewController dismiss];
    }

    promptViewController = [[AWEVideoDetailSwipePromptAnimationViewController alloc] init];
    promptViewController.direction = direction;
    promptViewController.dismissCompleteBlock = ^{
        if (direction == AWEPromotionDiretionLeft) {
            [self setHasShownFirstLeftPromotion];
        }
    };
    
    [containerViewController addChildViewController:promptViewController];
    [containerViewController.view addSubview:promptViewController.view];
    promptViewController.view.frame = containerViewController.view.frame;
    [promptViewController didMoveToParentViewController:containerViewController];

    [[self class] setNeedPromotionForDirection:direction category:category];
}

+ (void)setHasShownFirstLeftPromotion
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAWEVideoDetailHasShownFirstLeftPromotion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)hasShownFirstLeftPromotion
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kAWEVideoDetailHasShownFirstLeftPromotion"];
}

@end
