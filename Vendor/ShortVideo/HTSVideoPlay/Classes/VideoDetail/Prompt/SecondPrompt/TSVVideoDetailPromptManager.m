//
//  TSVVideoDetailPromptManager.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/8/25.
//

#import "TSVVideoDetailPromptManager.h"
#import "AWEVideoDetailSecondUsePromptViewController.h"
#import "TSVSlideUpPromptViewController.h"
#import "TSVSlideLeftEnterProfilePromptViewController.h"
#import <ReactiveObjC.h>
#import "TTSettingsManager.h"
#import "AWEVideoDetailScrollConfig.h"
#import "AWEVideoDetailFirstUsePromptViewController.h"
#import "TSVSeondUseSwipeAnimation.h"
#import "AWEVideoDetailTracker.h"

@interface TSVVideoDetailPromptManager()

@property (nonatomic, assign) NSInteger visibleFloatingViewCount;
@property (nonatomic, assign) NSInteger currentVideoRepeatCount;
@property (nonatomic, strong) RACDisposable *timerDisposable;
@property (nonatomic, strong) NSDictionary *configDictionary;

@end

@implementation TSVVideoDetailPromptManager

+ (void)initialize
{
    if (self == [TSVVideoDetailPromptManager class]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kAWEVideoDetailVideoPlayCount"];
    }
}

#pragma mark -

+ (NSInteger)videoPlayCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"kAWEVideoDetailVideoPlayCount2"];
}

+ (void)increaseVideoPlayCount
{
    [[NSUserDefaults standardUserDefaults] setInteger:[self videoPlayCount] + 1 forKey:@"kAWEVideoDetailVideoPlayCount2"];
}

+ (NSInteger)lastVideoViewCountThatPromptAppears
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kAWEVideoDetailLastVideoViewCountThatPromptAppears"]) {
        return -9999;
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"kAWEVideoDetailLastVideoViewCountThatPromptAppears"];
}

+ (void)updateLastVideoViewCountThatPromptAppears
{
    [[NSUserDefaults standardUserDefaults] setValue:@([self videoPlayCount]) forKey:@"kAWEVideoDetailLastVideoViewCountThatPromptAppears"];
}

+ (NSDate *)dateOfBeginningOfToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar startOfDayForDate:[NSDate date]];
}

+ (BOOL)hasUserSwiped
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kAWEVideoDetailHasUaerSwipedKey"];
}

+ (void)setUserhasSwiped
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAWEVideoDetailHasUaerSwipedKey"];
}

+ (NSInteger)consecutiveClickPlayCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"kAWEVideoDetailConsecutiveClickPlayCountKey"];
}

+ (void)increaseConsecutiveClickPlayCount
{
    [[NSUserDefaults standardUserDefaults] setInteger:[self consecutiveClickPlayCount] + 1 forKey:@"kAWEVideoDetailConsecutiveClickPlayCountKey"];
}

+ (void)resetConsecutiveClickPlayCount
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"kAWEVideoDetailConsecutiveClickPlayCountKey"];
}

+ (BOOL)skipPromptToday
{
    NSDate *lastPromptDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAWEVideoDetailSkipPromptDateKey"];
    return [lastPromptDate isEqual:[self dateOfBeginningOfToday]];
}

+ (void)setSkipPromptToday
{
    [[NSUserDefaults standardUserDefaults] setObject:[self dateOfBeginningOfToday] forKey:@"kAWEVideoDetailSkipPromptDateKey"];
}

+ (NSInteger)promptCountToday
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAWEVideoDetailPromptCountTodayKey"];
    NSDate *date = dict[@"date"];
    NSInteger count = [dict[@"count"] integerValue];

    if ([date isEqualToDate:[self dateOfBeginningOfToday]]) {
        return count;
    } else {
        return 0;
    }
}

+ (void)increasePropmtCountToday
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAWEVideoDetailPromptCountTodayKey"];
    NSDate *date = dict[@"date"];
    NSInteger count = [dict[@"count"] integerValue];

    if ([date isEqualToDate:[self dateOfBeginningOfToday]]) {
        count++;
    } else {
        count = 1;
    }

    dict = @{
             @"date": [self dateOfBeginningOfToday],
             @"count": @(count),
             };
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"kAWEVideoDetailPromptCountTodayKey"];
}

#pragma mark-

- (instancetype)init
{
    if (self = [super init]) {
        self.visibleFloatingViewCount = 0;
        self.configDictionary = [[TTSettingsManager sharedManager]
                                 settingForKey:@"tt_huoshan_swipe_strong_prompt"
                                 defaultValue:@{@"show_after_delay": @1e9,
                                                @"show_after_loop_count": @1,
                                                @"prompt_per_video_count": @1,
                                                @"consecutive_click_play_threshold": @10,
                                                @"style_config": @[@{@"style": @0, @"count": @1e4}],
                                                @"assume_swiped": @NO,
                                                } freeze:NO];
        if ([self.configDictionary[@"assume_swiped"] boolValue]) {
            [[self class] setUserhasSwiped];
        }
    }
    return self;
}

#pragma mark -
- (void)updateVisibleFloatingViewCountForVisibility:(BOOL)isVisible
{
    if (isVisible) {
        self.visibleFloatingViewCount += 1;
        [self hidePrompt];
    } else {
        self.visibleFloatingViewCount -= 1;
    }

    self.visibleFloatingViewCount = MAX(0, self.visibleFloatingViewCount);
}

- (void)videoDidPlayWithSwipe:(BOOL)swipe
{

    [self.timerDisposable dispose];
    self.timerDisposable = nil;

    if (swipe) {
        [[self class] setUserhasSwiped];
        [[self class] resetConsecutiveClickPlayCount];
        [[self class] setSkipPromptToday];
    } else {
        [[self class] increaseConsecutiveClickPlayCount];
    }

    [[self class] increaseVideoPlayCount];
    self.currentVideoRepeatCount = 0;

    @weakify(self);
    self.timerDisposable = [[[[RACSignal return:nil] delay:[self.configDictionary[@"show_after_delay"] doubleValue]]
                             deliverOn:[RACScheduler mainThreadScheduler]]
                            subscribeNext:^(id  _Nullable x) {
                                @strongify(self);
                                [self showPromptIfConditionsMet];
                            }];
}

- (void)videoDidPlayOneLoop;
{
    self.currentVideoRepeatCount++;

    if ([self.configDictionary[@"show_after_loop_count"] integerValue] == self.currentVideoRepeatCount) {
        [self showPromptIfConditionsMet];
    }
}

- (void)showPromptIfConditionsMet
{
    // https://wiki.bytedance.net/pages/viewpage.action?pageId=158231400

    id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager = self.dataFetchManager;
    UIViewController *containerViewController = self.containerViewController;
    UIScrollView *scrollView = self.scrollView;
    NSDictionary *commonTrackingParameter = self.commonTrackingParameter;

    if (!dataFetchManager || !containerViewController || !scrollView) {
        return;
    }

    if ([[self class] hasUserSwiped] &&
        !([[self class] consecutiveClickPlayCount] > [self.configDictionary[@"consecutive_click_play_threshold"] integerValue])) {
        return;
    }

    if ([[self class] skipPromptToday]) {
        return;
    }

    if (self.visibleFloatingViewCount > 0) {
        return;
    }

    if ([[self class] videoPlayCount] - [[self class] lastVideoViewCountThatPromptAppears] < [self.configDictionary[@"prompt_per_video_count"] integerValue]) {
        return;
    }

    // 首次滑动引导出现
    if (![AWEVideoDetailFirstUsePromptViewController hasShownFirstLeftPromotion]) {
        return;
    }

    // 后面还有数据
    if (dataFetchManager.currentIndex >= [dataFetchManager numberOfShortVideoItems] - 1) {
        return;
    }

    // 目前做的滑动引导针对的是左右滑动
    if ([AWEVideoDetailScrollConfig direction] != AWEVideoDetailScrollDirectionHorizontal) {
        return;
    }

    // 下一个model非空
    if (![dataFetchManager itemAtIndex:dataFetchManager.currentIndex + 1]) {
        return;
    }

    NSArray *styleConfig = self.configDictionary[@"style_config"];
    NSInteger promptCountToday = [[self class] promptCountToday];
    NSInteger selectedStyle = 0;
    for (NSDictionary *singleConfig in styleConfig) {
        if (promptCountToday >= [singleConfig[@"count"] integerValue]) {
            promptCountToday -= [singleConfig[@"count"] integerValue];
        } else {
            selectedStyle = [singleConfig[@"style"] integerValue];
            break;
        }
    }
    if (selectedStyle == 1) {
        [AWEVideoDetailSecondUsePromptViewController showSecondSwipePromptWithDataFetchManager:dataFetchManager currentIndex:dataFetchManager.currentIndex inViewController:containerViewController];
    } else if (selectedStyle == 2) {
        [TSVSeondUseSwipeAnimation sharedAnimation].scrollView = scrollView;
        [TSVSeondUseSwipeAnimation sharedAnimation].arrowParentView = containerViewController.view;
        [[TSVSeondUseSwipeAnimation sharedAnimation] startAnimation];
    }

    [[self class] updateLastVideoViewCountThatPromptAppears];
    [[self class] increasePropmtCountToday];
    [AWEVideoDetailTracker trackEvent:@"detail_draw_guide_show"
                                model:[dataFetchManager itemAtIndex:dataFetchManager.currentIndex]
                      commonParameter:commonTrackingParameter
                       extraParameter:nil];
}

- (void)hidePrompt
{
    [self.timerDisposable dispose];
    self.timerDisposable = nil;

    [AWEVideoDetailSecondUsePromptViewController dismiss];
    [[TSVSeondUseSwipeAnimation sharedAnimation] stopAnimation];
}

@end
