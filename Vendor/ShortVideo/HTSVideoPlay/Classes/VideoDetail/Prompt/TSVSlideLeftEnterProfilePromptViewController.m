//
//  TSVSlideLeftEnterProfilePromptViewController.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/11/14.
//

#import "TSVSlideLeftEnterProfilePromptViewController.h"
#import "AWEVideoDetailSwipePromptAnimationViewController.h"
#import "TTSettingsManager.h"
#import "AWEVideoDetailScrollConfig.h"

static UIViewController<AWEVideoDetailFirstUsePromptViewController> *slideLeftPromptViewController;
static NSString * const kTSVVideoPlayCountForProfileSlideLeft = @"TSVVideoPlayCountForProfileSlideLeft";
static NSString * const kTSVSlideLeftEnterProfilePromptViewControllerShown = @"TSVSlideLeftEnterProfilePromptViewControllerShown";

@implementation TSVSlideLeftEnterProfilePromptViewController

+ (void)showSlideLeftPromotionIfNeededInViewController:(UIViewController *)containerViewController;
{
    if (slideLeftPromptViewController && [slideLeftPromptViewController respondsToSelector:@selector(dismiss)]) {
        [slideLeftPromptViewController dismiss];
    }
    
    NSString *tipText = @"左滑查看个人主页";
    
    slideLeftPromptViewController = [[AWEVideoDetailSwipePromptAnimationViewController alloc] initWithText:tipText];
    slideLeftPromptViewController.direction = AWEPromotionDiretionLeftEnterProfile;
    
    [containerViewController addChildViewController:slideLeftPromptViewController];
    [containerViewController.view addSubview:slideLeftPromptViewController.view];
    slideLeftPromptViewController.view.frame = slideLeftPromptViewController.view.frame;
    [slideLeftPromptViewController didMoveToParentViewController:containerViewController];
    
    [[self class] setSlideLeftPromotionShown];
}

+ (BOOL)needSlideLeftPromotion
{
    NSInteger count = [self videoPlayCountForProfileSlideLeft] + 1;

    if (count < [self slideLeftIndex]) {
        return NO;
    }
    if ([AWEVideoDetailScrollConfig direction] == AWEVideoDetailScrollDirectionHorizontal) {
        return NO;
    }
    return ![[NSUserDefaults standardUserDefaults] boolForKey:kTSVSlideLeftEnterProfilePromptViewControllerShown];
}

+ (void)setSlideLeftPromotionShown
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTSVSlideLeftEnterProfilePromptViewControllerShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)slideLeftIndex
{
    NSNumber *res = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_slide_left_index" defaultValue:@5 freeze:YES];
    //保护，避免出现负数，默认第五个视频出引导
    if ([res integerValue] >= 1) {
        return [res integerValue];
    } else {
        return 5;
    }
}

+ (void)increaseVideoPlayCountForProfileSlideLeft
{
    if ([AWEVideoDetailScrollConfig direction] == AWEVideoDetailScrollDirectionVertical) {
        //开启上下滑动才计数
        [[NSUserDefaults standardUserDefaults] setInteger:[self videoPlayCountForProfileSlideLeft] + 1 forKey:kTSVVideoPlayCountForProfileSlideLeft];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSInteger)videoPlayCountForProfileSlideLeft
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kTSVVideoPlayCountForProfileSlideLeft];
}

@end

