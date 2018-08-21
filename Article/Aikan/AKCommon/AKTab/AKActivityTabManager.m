//
//  AKActivityTabManager.m
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//  管理任务tab按钮状态

#import "AKActivityTabManager.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import "AKNetworkManager.h"
#import "AKActivityViewController.h"

#define kMaxCountdownSeconds    (24 * 60 * 60)
#define kOneHourInSeconds       (60 * 60)
#define kOneMinInSeconds        60

@interface AKActivityTabManager ()

@property (nonatomic, strong) dispatch_source_t countDownTimer;
@property (atomic, assign) enum AKActivityTabState curState;
@property (atomic, assign) NSInteger lastSeconds;   //距下次开宝箱时间
@property (nonatomic, copy) NSString *badgeTip;     //角标提醒

@property (atomic, assign) BOOL isTimerRunning;
@property (nonatomic, strong) TTTabBarItem *activityTabItem;

@end

static AKActivityTabManager *_manager;

@implementation AKActivityTabManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[AKActivityTabManager alloc] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastSeconds = NSIntegerMax;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (dispatch_source_t)countDownTimer
{
    if (!_countDownTimer) {
        _countDownTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    return _countDownTimer;
}

- (void)startTimer
{
    dispatch_source_set_timer(self.countDownTimer, DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC, 0);
    WeakSelf;
    dispatch_source_set_event_handler(self.countDownTimer, ^{
        StrongSelf;
        [self onTimerTrigged];
    });
    dispatch_source_set_cancel_handler(self.countDownTimer, ^{
        StrongSelf;
        self.countDownTimer = nil;
    });
    dispatch_resume(self.countDownTimer);
    self.isTimerRunning = YES;
}

- (void)onTimerTrigged
{
    if (self.lastSeconds <= 0) {
        [self _updateActivityTabToState:AKActivityTabStateBonus withDescription:nil];
        [self _suspendTimerIfNeed];
    } else {
        self.lastSeconds -= 1;
        [self _updateActivityTabCountdownDisplay];
    }
}

- (void)onAppDidEnterBackground
{
    [self _suspendTimerIfNeed];
}

//- (void)onAppWillEnterForeground
//{
//    [self startUpdateActivityTabState];
//}

#pragma mark - public

NSInteger const AKNotLoginServerErrNum = 1;

- (void)startUpdateActivityTabState
{
    // 调接口查询宝箱状态，更新lastSeconds属性
    if (tta_IsLogin()) {
        [AKNetworkManager requestForJSONWithPath:@"tips/get_data/" params:nil method:@"GET" callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
            if (0 == err_no && [err_tips isEqualToString:@"success"]) {
                if ([dataDict objectForKey:@"current_time"] &&
                    [dataDict objectForKey:@"next_treasure_time"]) {
                    // 第一次开宝箱时lastSeconds会计算得到负值
                    int64_t lastSeconds = [dataDict tt_longlongValueForKey:@"next_treasure_time"] - [dataDict tt_longlongValueForKey:@"current_time"];
                    if (lastSeconds > kMaxCountdownSeconds) {
                        return;
                    } else if (lastSeconds >= 0) {
                        self.lastSeconds = lastSeconds;
                        [self _updateActivityTabCountdownDisplay];
                        [self _resumeTimerIfNeed];
                    } else {
                        [self _updateActivityTabToState:AKActivityTabStateBonus withDescription:nil];
                        [self _suspendTimerIfNeed];
                    }
                }
            } else {
                if (err_no == AKNotLoginServerErrNum) {
                    [self _updateActivityTabToState:AKActivityTabStateBonus withDescription:nil];
                    [self _suspendTimerIfNeed];
                }
            }
        }];
    } else {
        [self _updateActivityTabToState:AKActivityTabStateBonus withDescription:nil];
        [self _suspendTimerIfNeed];
    }
}

- (void)reloadActivityTabViewController
{
    UIViewController *nav = [AKActivityTabManager sharedManager].activityTabItem.viewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        UIViewController *rootVC = ((UINavigationController *)nav).topViewController;
        if ([rootVC isKindOfClass:[AKActivityViewController class]]) {
            [((AKActivityViewController *)rootVC) reloadPage];
        }
    }
}

- (void)updateActivityTabHiddenState:(BOOL)setToHidden
{
    [[TTTabBarManager sharedTTTabBarManager] updateItemState:setToHidden withIdentifier:kAKTabActivityTabKey];
}

#pragma mark - private

- (void)_updateActivityTabCountdownDisplay
{
    [self _updateActivityTabToState:AKActivityTabStateCountDown
                    withDescription:[self.class displayStringWithCountdownInseconds:self.lastSeconds]];
}

- (void)_updateActivityTabToState:(enum AKActivityTabState)state
                  withDescription:(NSString *)description
{
    self.curState = state;
    
    void (^UpdateTabBlock)(NSString*, NSString*) = ^(NSString *title, NSString *badge) {
        // 更新tab展示
        if (!isEmptyString(title)) {
            [self.activityTabItem setTitle:[title copy]];
        }
        if (!isEmptyString(badge)) {
            self.activityTabItem.ttBadgeView.badgeValue = [badge copy];
            self.activityTabItem.ttBadgeView.hidden = NO;
        } else {
            self.activityTabItem.ttBadgeView.badgeValue = nil;
            self.activityTabItem.ttBadgeView.hidden = YES;
        }
    };
    
    if (state == AKActivityTabStateInit) {
        UpdateTabBlock(@"任务", @"开宝箱");
    } else if (state == AKActivityTabStateCountDown) {
        UpdateTabBlock(description, nil);
    } else {
        UpdateTabBlock(@"任务", @"开宝箱");
    }
}

- (void)_suspendTimerIfNeed
{
    if (_countDownTimer) {
        if (self.isTimerRunning) {
            dispatch_suspend(self.countDownTimer);
            self.isTimerRunning = NO;
        }
    }
}

- (void)_resumeTimerIfNeed
{
    if (_countDownTimer) {
        if (!self.isTimerRunning) {
            dispatch_resume(self.countDownTimer);
            self.isTimerRunning = YES;
        }
    } else {
        [self startTimer];
    }
}

#pragma mark - lazy load

- (TTTabBarItem *)activityTabItem
{
    if (!_activityTabItem) {
        for (TTTabBarItem *item in [TTTabBarManager sharedTTTabBarManager].tabItems) {
            if ([item.identifier isEqualToString:kAKTabActivityTabKey]) {
                _activityTabItem = item;
                break;
            }
        }
    }
    return _activityTabItem;
}

#pragma mark - helper

+ (NSString *)displayStringWithCountdownInseconds:(NSTimeInterval)countdownInSeconds
{
    if (countdownInSeconds < 0) {
        return nil;
    }
    
    if (countdownInSeconds > kMaxCountdownSeconds) {
        return @"23:59:59";
    }
    
    NSInteger hour = countdownInSeconds / kOneHourInSeconds;
    NSInteger min = (countdownInSeconds - kOneHourInSeconds * hour) / kOneMinInSeconds;
    NSInteger sec = countdownInSeconds - kOneHourInSeconds * hour - kOneMinInSeconds * min;
    if (0 == hour) {
        return [NSString stringWithFormat:@"%@:%@", numberOnWatch(min), numberOnWatch(sec)];
    } else {
        return [NSString stringWithFormat:@"%@:%@:%@", numberOnWatch(hour), numberOnWatch(min), numberOnWatch(sec)];
    }
}

@end
