//
//  TTLivePlayerTrafficViewController.m
//  Article
//
//  Created by matrixzk on 26/10/2017.
//

#import "TTLivePlayerTrafficViewController.h"

#import "TTReachability.h"
#import "NetworkUtilities.h"
#import "TTNetworkHelper.h"
#import "TTFlowStatisticsManager.h"
#import "TTIndicatorView.h"
#import "TTChatroomMovieNetTrafficView.h"
#import <TTRoute.h>
#import <TTUIWidget/SSViewControllerBase.h>


static BOOL kOnlyShowOnceTrafficView = NO;
static BOOL kHadShowOnceTrafficView = NO;


@interface TTLivePlayerTrafficViewController ()

@property (nonatomic, strong) TTChatroomMovieNetTrafficView *netTrafficView;
@property (nonatomic) BOOL currentHasShownTrafficView;
@property (nonatomic) BOOL networkConnectionStateChanged;
@property (nonatomic) BOOL isShowingTrafficView;
@property (nonatomic) BOOL shouldAutoPlayWhenTrafficViewDismiss;

@end


@implementation TTLivePlayerTrafficViewController

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showTrafficViewIfNeeded) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//NSLog(@">>>>>> TTLivePlayerTrafficViewController dealloc");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupTrafficView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleExcessFlowNotification:) name:kExcessFlowNotification object:nil];
    }
    return self;
}

- (void)setupTrafficView
{
    _netTrafficView = [TTChatroomMovieNetTrafficView new];
    
    WeakSelf;
    _netTrafficView.continuePlayBlock = ^{
        StrongSelf;
        // 如果在设置页面设置只显示一次，则把kOnlyShowOnceTrafficView置为YES
        NSNumber *settingValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"TTVideoTrafficTipSettingKey"];
        if (!settingValue || settingValue.integerValue) {
            kOnlyShowOnceTrafficView = YES;
        }
        kHadShowOnceTrafficView = YES;
        self.isShowingTrafficView = NO;
        self.trafficView.hidden = YES;
        
        !self.didEndDisplayingTrafficViewBlock ? : self.didEndDisplayingTrafficViewBlock();
    };
    
    _netTrafficView.goOrderBlock = ^{
        StrongSelf;
        NSURL *openURL = [NSURL URLWithString:[TTFlowStatisticsManager sharedInstance].freeFlowEntranceURL];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            
            TTAppPageCompletionBlock block = ^(id obj) {
                if ([self isFreeFlow]) {
                    self.trafficView.hidden = YES;
                    !self.didEndDisplayingTrafficViewBlock ? : self.didEndDisplayingTrafficViewBlock();
                }
            };
            NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:1];
            condition[@"completion_block"] = [block copy];
            [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(condition)];
        }
    };
}

// getter
- (UIView *)trafficView
{
    return _netTrafficView;
}


#pragma mark - public methods

- (void)showTrafficViewIfNeeded
{
    if (TTNetworkWifiConnected() || !TTNetworkConnected() || [self isFreeFlow]) return;
    
    if ([self shouldShowTrafficView]) {
        [self showTrafficView];
    } else if (kHadShowOnceTrafficView) {
        [self showTrafficToastIfNeeded];
    }
}

+ (void)changeFrequencyOfTrafficViewDisplayed
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"TTVideoTrafficTipSettingKey"] == 0) { // 如果每次都显示提示，则关掉开关
        kOnlyShowOnceTrafficView = NO;
    } else {
        if (kHadShowOnceTrafficView) { // 如果已经显示过提示页面，则打开开关
            kOnlyShowOnceTrafficView = YES;
        } else {
            kOnlyShowOnceTrafficView = NO;
        }
    }
}


#pragma mark - Notification

- (void)handleReachabilityChangedNotification:(NSNotification *)notification
{
    NS_VALID_UNTIL_END_OF_SCOPE __strong typeof(self) strongSelf = self;
    // 延迟2s，防止网络抖动
    [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(_showTrafficViewIfNeeded) object:nil];
    [strongSelf performSelector:@selector(_showTrafficViewIfNeeded) withObject:nil afterDelay:2];
    if (!TTNetworkWifiConnected() && TTNetworkConnected()) {
        strongSelf.networkConnectionStateChanged = YES;
    }
    
//NSLog(@">>>>>> handleReachabilityChangedNotification:");
}

- (void)handleExcessFlowNotification:(NSNotification *)notification
{
    [self _showTrafficViewIfNeeded];
}

- (void)_showTrafficViewIfNeeded
{
    if ([self shouldShowTrafficView]) {
        [self showTrafficView];
    } else {
        [self showTrafficToastIfNeeded];
    }
}

#pragma mark - Traffic View

- (void)showTrafficView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _isShowingTrafficView = YES;
        _currentHasShownTrafficView = YES;
        
        !self.willDisplayTrafficViewBlock ? : self.willDisplayTrafficViewBlock();
        
        TTChatroomMovieNetTrafficViewModel *viewModel = [[TTChatroomMovieNetTrafficViewModel alloc] init];
        viewModel.isInDetail = YES;
        if ([[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable]) {
            BOOL openFreeFlow = [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow];
            if ([[TTFlowStatisticsManager sharedInstance] flowOrderEntranceEnable] && openFreeFlow == NO) {
                viewModel.type = TTChatroomMovieNetTrafficViewTypeOrder;
            }
            if (openFreeFlow && ([[TTFlowStatisticsManager sharedInstance] isExcessFlowWithSize:viewModel.videoSize] || [[TTFlowStatisticsManager sharedInstance] isExcessFlow])) {
                viewModel.type = TTChatroomMovieNetTrafficViewTypeExceed;
            }
        }
        _netTrafficView.viewModel = viewModel;
        _netTrafficView.hidden = NO;
        [_netTrafficView setNeedsLayout];
    });
}

- (BOOL)shouldShowTrafficView
{
    NSString *name = [TTNetworkHelper connectMethodName];
    if (isEmptyString(name) || [name isEqualToString:@"WIFI"]) return NO;
    
    if ((kOnlyShowOnceTrafficView && kHadShowOnceTrafficView) || _currentHasShownTrafficView) return NO;
    
    if ([[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] && [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow]) {
        BOOL openFreeFlow = [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow];
        if ([[TTFlowStatisticsManager sharedInstance] flowOrderEntranceEnable] && !openFreeFlow) {
            return YES;
        }
        
        if (openFreeFlow) return [[TTFlowStatisticsManager sharedInstance] isExcessFlow];
    }
    
    if (!_isShowingTrafficView) return YES;
    
    return NO;
}

- (void)showTrafficToastIfNeeded
{
    if (TTNetworkWifiConnected() || !TTNetworkConnected()) return;
    
    BOOL freeFlow = [self isFreeFlow];
    
    if (!kHadShowOnceTrafficView && !freeFlow) return;
    
    if (!kOnlyShowOnceTrafficView && !_currentHasShownTrafficView && !freeFlow) return;
    
    if (_isShowingTrafficView) return;
    
    NSString *title = @"正在使用流量播放";
    if (freeFlow) {
        if (!TTNetworkWifiConnected() && _networkConnectionStateChanged) {
            title = @"免流量服务中";
            _networkConnectionStateChanged = NO;
        } else {
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        TTIndicatorView *trafficToast = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:title indicatorImage:nil dismissHandler:^(BOOL isUserDismiss) {
        }];
        SEL selector = NSSelectorFromString(@"indicatorTextLabel");
        if ([trafficToast respondsToSelector:selector]) {
            IMP imp = [trafficToast methodForSelector:selector];
            UILabel* (*func)(id, SEL) = (void *)imp;
            UILabel *toastLabel = func(trafficToast, selector);
            toastLabel.font = [UIFont systemFontOfSize:14.f];
        }
        [trafficToast showFromParentView:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [trafficToast dismissFromParentView];
        });
    });
}

- (BOOL)isFreeFlow
{
    BOOL freeFlow = [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
                    [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
                    [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
                    ![[TTFlowStatisticsManager sharedInstance] isExcessFlow];
    return freeFlow;
}

@end
