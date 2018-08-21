//
//  TSVSlideUpPromptViewController.m
//  Pods
//
//  Created by 王双华 on 2017/9/7.
//
//

#import "TSVSlideUpPromptViewController.h"
#import "AWEVideoDetailSwipePromptAnimationViewController.h"
#import "TTSettingsManager.h"
#import "AWEVideoDetailScrollConfig.h"

@interface TSVSlideUpPromptViewController ()

@end

static UIViewController<AWEVideoDetailFirstUsePromptViewController> *slideUpPromptViewController;

@implementation TSVSlideUpPromptViewController

+ (void)showSlideUpPromotionIfNeededInViewController:(UIViewController *)containerViewController;
{
    if (slideUpPromptViewController && [slideUpPromptViewController respondsToSelector:@selector(dismiss)]) {
        [slideUpPromptViewController dismiss];
    }
    
    NSString *tipText = nil;
    if ([self slideUpViewType] == TSVDetailSlideUpViewTypeProfile) {
        tipText = @"上滑查看作者更多视频";
    } else if([self slideUpViewType] == TSVDetailSlideUpViewTypeComment){
        tipText = @"上滑查看评论";
    }
    
    slideUpPromptViewController = [[AWEVideoDetailSwipePromptAnimationViewController alloc] initWithText:tipText];
    slideUpPromptViewController.direction = AWEPromotionDiretionUpFloatingViewPop;
    
    [containerViewController addChildViewController:slideUpPromptViewController];
    [containerViewController.view addSubview:slideUpPromptViewController.view];
    slideUpPromptViewController.view.frame = slideUpPromptViewController.view.frame;
    [slideUpPromptViewController didMoveToParentViewController:containerViewController];
    
    [[self class] setSlideUpPromotionShown];
}

+ (BOOL)needSlideUpPromotion
{
    NSInteger count = [self videoPlayCountForProfileSlideUp] + 1;
    
    if ([self slideUpViewType] == TSVDetailSlideUpViewTypeNone) {
        return NO;
    }
    if (count < [self slideUpIndex]) {
        return NO;
    }
    if ([AWEVideoDetailScrollConfig direction] == AWEVideoDetailScrollDirectionVertical) {
        return NO;
    }
    return ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"TSVSlideUpPromptViewControllerShownSlideUp%lu",[self slideUpViewType]]];
}

+ (void)setSlideUpPromotionShown
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"TSVSlideUpPromptViewControllerShownSlideUp%lu",[self slideUpViewType]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)slideUpIndex
{
    NSNumber *res = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_slide_up_index" defaultValue:@5 freeze:YES];
    //保护，避免出现负数，默认第五个视频出引导
    if ([res integerValue] >= 1) {
        return [res integerValue];
    } else {
        return 5;
    }
}

+ (TSVDetailSlideUpViewType)slideUpViewType
{
    NSNumber *res = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_slide_up_view_type" defaultValue:@0 freeze:YES];
    if ([res integerValue] > 2 || [res integerValue] < 0) {
        return 0;
    } else {
        return [res integerValue];
    }
}

+ (void)increaseVideoPlayCountForProfileSlideUp
{
    [[NSUserDefaults standardUserDefaults] setInteger:[self videoPlayCountForProfileSlideUp] + 1 forKey:[NSString stringWithFormat:@"TSVVideoPlayCountForProfileSlideUp%lu", [self slideUpViewType]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)videoPlayCountForProfileSlideUp
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"TSVVideoPlayCountForProfileSlideUp%lu", [self slideUpViewType]]];
}

+ (TSVDetailAvatarClickType)clickAvatarType
{
    NSNumber *config = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_avatar_click_config" defaultValue:@0 freeze:YES];
    if ([config integerValue] > 1 || [config integerValue] < 0) {
        return 1;
    } else {
        return [config integerValue];
    }
}

@end
