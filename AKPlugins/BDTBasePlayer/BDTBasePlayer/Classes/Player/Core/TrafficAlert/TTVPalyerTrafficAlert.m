//
//  TTVPalyerTrafficAlert.m
//  Article
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPalyerTrafficAlert.h"
#import "TTReachability.h"
#import "TTVPlayerStateAction.h"
#import "TTReachability.h"
#import "TTVPlayerSettingUtility.h"
#import "TTVFluxDispatcher.h"
#import "TTVPlayerStateModel.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerStateAction.h"
#import "NetworkUtilities.h"
#import "KVOController.h"
#import "TTVResolutionStore.h"
#import "TTVNetTrafficFreeFlowTipView.h"
#import "TTIndicatorView.h"
#import "TTBaseMacro.h"
#import "TTTrackerWrapper.h"
#import "TTUIResponderHelper.h"
#import "UIViewController+TTMovieUtil.h"
#import "TTStringHelper.h"
#import "SSViewControllerBase.h"
#import "TTSettingsManager.h"

@interface TTThemedAlertControllerManager : NSObject
@property (nonatomic , assign) BOOL isShowing;
+ (TTThemedAlertControllerManager *)shareManager;
@end

@implementation TTThemedAlertControllerManager

static TTThemedAlertControllerManager *manager;
+ (TTThemedAlertControllerManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTThemedAlertControllerManager alloc] init];
    });
    return manager;
}
@end

#pragma mark - TTVPlayerFreeFlowTipStatusManager

@implementation TTVPlayerFreeFlowTipStatusManager

+ (BOOL)ttv_getCommonState {
    
    return (TTNetworkConnected() &&
            !TTNetworkWifiConnected() &&
            [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
            [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
            ![[TTFlowStatisticsManager sharedInstance] isExcessFlow]);
}

+ (BOOL)shouldShowFreeFlowSubscribeTip {
    
    return (TTNetworkConnected() &&
            !TTNetworkWifiConnected() &&
            [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [[TTFlowStatisticsManager sharedInstance] flowOrderEntranceEnable] &&
            [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
            ![[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow]);
}

+ (BOOL)shouldShowWillOverFlowTip:(CGFloat)videoSize {
    
    return ([self ttv_getCommonState] &&
            [[TTFlowStatisticsManager sharedInstance] isExcessFlowWithSize:videoSize]);
}

+ (BOOL)shouldShowFreeFlowToastTip:(CGFloat)videoSize {
    
    return ([self ttv_getCommonState] &&
            ![[TTFlowStatisticsManager sharedInstance] isExcessFlowWithSize:videoSize]);
}

+ (BOOL)shouldShowFreeFlowLoadingTip {
    
    return ([self ttv_getCommonState]);
}

+ (BOOL)shouldSwithToHDForFreeFlow {
    
    return ([self ttv_getCommonState] &&
            ![TTVResolutionStore sharedInstance].userSelected);
}

+ (BOOL)shouldShowDidOverFlowTip {
    
    return (TTNetworkConnected() &&
            !TTNetworkWifiConnected() &&
            [[TTFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
            [[TTFlowStatisticsManager sharedInstance] isSupportFreeFlow] &&
            [[TTFlowStatisticsManager sharedInstance] isOpenFreeFlow] &&
            [[TTFlowStatisticsManager sharedInstance] isExcessFlow]);
}

+ (NSString *)getSubscribeTitleTextWithVideoSize:(CGFloat)videoSize {
    
    NSString *text = [[TTFlowStatisticsManager sharedInstance] flowReminderTitle];
    
    if (isEmptyString(text)) {
        
        text = [NSString stringWithFormat:@"播放将消耗%.2fMB流量，试试免流量服务", videoSize];
    } else {
        
        text = [text stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%.2f", videoSize]];
    }
    
    return text;
}

+ (NSString *)getSubcribeButtonText {
    
    NSString *text = [[TTFlowStatisticsManager sharedInstance] orderButtonTitle];
    
    return (isEmptyString(text)) ? @"我要免流量": text;
}

@end

@interface TTVPalyerTrafficAlert ()
@property (nonatomic, weak)UIView <TTVPlayerViewTrafficView> *trafficView;
@property (nonatomic, assign) BOOL shouldShow;//重播不显示
@property (nonatomic, assign) NSInteger changeNumber;
@property (nonatomic, strong) TTVNetTrafficFreeFlowTipView *freeFlowTipView;

@end

@implementation TTVPalyerTrafficAlert

- (void)dealloc
{
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    [self ttv_removeObserver];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldShow = YES;
        [self ttv_addObserver];
    }
    return self;
}

- (void)setTrafficView:(UIView<TTVPlayerViewTrafficView> *)trafficView
{
    [_trafficView removeFromSuperview];
    if (_trafficView != trafficView) {
        [self.KVOController unobserve:_trafficView];
        _trafficView = trafficView;
        [self addSubview:trafficView];
        __weak typeof(self) wself = self;
        [self.trafficView setContinuePlayBlock:^{
            __strong typeof(wself) self = wself;
            self.hidden = YES;
            [self confimTrack];
            self.playerStateStore.state.isShowingTrafficAlert = NO;
            [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficPlay payload:nil];
        }];
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.trafficView.hidden = hidden;
}

- (void)layoutSubviews
{
    _trafficView.frame = self.bounds;
    _freeFlowTipView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
    }
}

- (void)setContinuePlayBlock:(dispatch_block_t)continuePlayBlock
{
    if ([_trafficView respondsToSelector:@selector(setContinuePlayBlock:)]) {
        [_trafficView setContinuePlayBlock:continuePlayBlock];
    }
}

- (void)setTrafficVideoDuration:(NSInteger)duration videoSize:(NSInteger)videoSize inDetail:(BOOL)inDetail
{
    if ([self.trafficView respondsToSelector:@selector(setTrafficVideoDuration:videoSize:inDetail:)]) {
        [self.trafficView setTrafficVideoDuration:duration videoSize:videoSize inDetail:inDetail];
    }
}

- (void)ttv_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_netChanged:) name:kReachabilityChangedNotification object:nil];
    [self.playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];

}

- (void)ttv_removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (NSString *)ttv_position
{
    return [self.playerStateStore.state ttv_position];
}


- (void)cancelTrack
{
    wrapperTrackEventWithCustomKeys(@"video", @"net_alert_cancel", self.playerStateStore.state.playerModel.groupID, nil, @{@"is_initial":@(NO),@"position":[self ttv_position]});
}

- (void)confimTrack
{
    //重播不显示
    wrapperTrackEventWithCustomKeys(@"video", @"net_alert_confirm", self.playerStateStore.state.playerModel.groupID, nil, @{@"is_initial":@(NO),@"position":[self ttv_position]});
}

- (void)showTrack
{
    wrapperTrackEventWithCustomKeys(@"video", @"net_alert_show", self.playerStateStore.state.playerModel.groupID, nil, @{@"is_initial":@(NO),@"position":[self ttv_position]});
}

#pragma mark - traffic alert
- (void)handleTrafficAlert
{
    if ([[NSThread currentThread] isMainThread]) {
        [self handleTrafficAlertInternal];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleTrafficAlertInternal];
        });
    }
}

- (void)handleTrafficAlertInternal {
    
    // 0.有贴片广告时 原视频不弹流量提醒 由贴片广告播放器处理
    if (self.playerStateStore.state.disableTrafficAlert) {
        return ;
    }
    
    // 1.免流超量判断
    if ([self ttv_shouldShowTrafficAlert] &&[TTVPlayerFreeFlowTipStatusManager shouldShowDidOverFlowTip]) {
        [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficDidOverFreeFlowShow payload:nil];
        
        return ;
    }
    
    
    // 2.免流即将超量判断
    if ([self ttv_shouldShowTrafficAlert] &&
        [TTVPlayerFreeFlowTipStatusManager shouldShowWillOverFlowTip:self.playerStateStore.state.videoSize / 1024.f]) {
        
        [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficWillOverFreeFlowShow payload:nil];
        
        return ;
    }
    
    // 3. 符合免流条件
    if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowToastTip:self.playerStateStore.state.videoSize / 1024.f]) {
        // 用户设置过清晰度 & 符合免流条件 切换到高清
        if ([TTVPlayerFreeFlowTipStatusManager shouldSwithToHDForFreeFlow] &&
            self.playerStateStore.state.currentResolution != TTVPlayerResolutionTypeHD) {
            // 支持高清，切换到高清
            if ([self.playerStateStore.state.supportedResolutionTypes containsObject:@(TTVPlayerResolutionTypeHD)]){
                [TTVResolutionStore sharedInstance].lastResolution = TTVPlayerResolutionTypeHD;
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:@(TTVPlayerResolutionTypeHD) forKey:@"resolution_type"];
                [dic setValue:@(YES) forKey:@"is_auto_switch"];
                [self.playerStateStore sendAction:TTVPlayerEventTypeSwitchResolution payload:dic];
            }
        }
        return ;
    }
    
    // 4.流量提醒弹窗有效性判断
    if (![self ttv_shouldShowTrafficAlert]) {
        BOOL isEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"tt_mobile_toast_data_usage_enable" defaultValue:@(NO) freeze:YES] boolValue];
        if (isEnabled) {
            [self ttv_showTrafficToastTipView];
        }
        return ;
    }
    
    // 5.订购入口和流量弹窗逻辑相同
    if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowSubscribeTip]) {
        [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficFreeFlowSubscribeShow payload:nil];
        
        return ;
    }
    
    // 6.正常 流量弹窗逻辑
    [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficShow payload:nil];
    self.hidden = NO;
    self.playerStateStore.state.isShowingTrafficAlert = YES;
    [self showTrack];
}

- (BOOL)ttv_shouldShowTrafficAlert {
    
    if (self.playerStateStore.state.disableTrafficAlert ||
        self.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished ||
        self.playerStateStore.state.playbackState == TTVVideoPlaybackStateError) {
        // 有贴片广告时 原视频不弹流量提醒 由贴片广告播放器处理
        return NO;
    }
    
    if (!self.shouldShow) {
        return NO;
    }
    TTVPlayerStateModel *stateModel = _playerStateStore.state;
    if (stateModel.isUsingLocalURL) {
        return NO;
    }
    if (TTNetworkWifiConnected() || !TTNetworkConnected()) {
        return NO;
    }

    BOOL shouldShow = YES;
    if (TTVHasShownNewTrafficAlert) {
        if ([TTVPlayerSettingUtility trafficAlertShowTimes] == TTVTrafficAlertShowOnce) {
            shouldShow = NO;
        }
        else if ([TTVPlayerSettingUtility trafficAlertShowTimes] == TTVTrafficAlertShowAlways) {
            shouldShow = YES;
        }
    }

    if (!shouldShow) {
        return NO;
    }
    shouldShow = YES;
    if (TTVHasShownOldTrafficAlert) {
        if ([TTVPlayerSettingUtility trafficAlertShowTimes] == TTVTrafficAlertShowOnce) {
            shouldShow = NO;
        }
        else if ([TTVPlayerSettingUtility trafficAlertShowTimes] == TTVTrafficAlertShowAlways) {
            shouldShow = YES;
        }
    }
    return YES;
}

- (void)ttv_showTrafficToastTipView {
    
    CGFloat size = self.playerStateStore.state.videoSize / 1024.f / 1024.f;
    TTIndicatorView *trafficToast = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"%@%.2fM", @"正在使用流量播放，本视频约", size] indicatorImage:nil dismissHandler:^(BOOL isUserDismiss) {
    }];
    SEL selector = NSSelectorFromString(@"indicatorTextLabel");
    if ([trafficToast respondsToSelector:selector]) {
        IMP imp = [trafficToast methodForSelector:selector];
        UILabel* (*func)(id, SEL) = (void *)imp;
        UILabel *toastLabel = func(trafficToast, selector);
        toastLabel.font = [UIFont systemFontOfSize:14.f];
    }
    [trafficToast showFromParentView:[UIViewController ttmu_currentViewController].view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [trafficToast dismissFromParentView];
    });
}

- (void)ttv_netChanged:(NSNotification *)noti {
    __unused __strong typeof(self) strongSelf = self;//iOS8会crash,在cancel的时候,self可能被释放了,需要一个局部变量来强持有.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttv_netChanged) object:nil];
    [self performSelector:@selector(ttv_netChanged) withObject:nil afterDelay:2 inModes:@[NSRunLoopCommonModes]];
}

- (void)ttv_netChanged
{
    if ([[NSThread currentThread] isMainThread]) {
        [self ttv_showNetAlert];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ttv_showNetAlert];
        });
    }

}

- (void)ttv_showNetAlert
{
    if (self.playerStateStore.state.tipType == TTVPlayerControlTipViewTypeFinished) {
        return;
    }
    if (TTNetworkConnected() && !TTNetworkWifiConnected()) { //显示流量提示
        
        if ([self ttv_showFreeFlowToastView]) {
            return ;
        };
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTrafficAlert) object:nil];
        [self performSelector:@selector(handleTrafficAlert) withObject:nil afterDelay:2 inModes:@[NSRunLoopCommonModes]];
    } else if (TTNetworkWifiConnected() && self.playerStateStore.state.isShowingTrafficAlert) { //wifi下自动恢复播放
        self.hidden = YES;
        [self.freeFlowTipView removeFromSuperview];
        self.playerStateStore.state.isShowingTrafficAlert = NO;
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficPlay payload:nil];
        }
    }
}

- (void)showFreeFlowTipView:(BOOL)isSubscribe didOverFlow:(BOOL)overFlow userInfo:(NSDictionary *)info {
    
    if (self.playerStateStore.state.isShowingTrafficAlert) {
        
        return ;
    }
    
    self.playerStateStore.state.isShowingTrafficAlert = YES;
    
    CGFloat videoSize = self.playerStateStore.state.minVideoSize / 1024.f / 1024.f;
    NSString *tipText = nil;
    
    if (isSubscribe) {
        
        tipText = [TTVPlayerFreeFlowTipStatusManager getSubscribeTitleTextWithVideoSize:videoSize];
    } else {
        
        tipText = [NSString stringWithFormat:@"本月免费流量已不足，继续播放将消耗%.2fMB流量", videoSize];
    }
    
    self.freeFlowTipView = [[TTVNetTrafficFreeFlowTipView alloc] initWithFrame:self.bounds tipText:tipText isSubscribe:isSubscribe];
    self.hidden = NO;
    self.trafficView.hidden = YES;
    [self.freeFlowTipView removeFromSuperview];
    [self addSubview:self.freeFlowTipView];
    
    if (isSubscribe) {
        
        [TTTrackerWrapper eventV3:@"continue_button_show" params:info];
        [TTTrackerWrapper eventV3:@"purchase_button_show" params:info];
    }
    
    __weak typeof(self) wself = self;
    self.freeFlowTipView.continuePlayBlock = ^{
        __strong typeof(wself) self = wself;
        if (isSubscribe) {
            [TTTrackerWrapper eventV3:@"continue_button_click" params:info];
        }
        
        self.hidden = YES;
        [self.freeFlowTipView removeFromSuperview];
        self.playerStateStore.state.isShowingTrafficAlert = NO;
        
        if (!isSubscribe && !overFlow) {
            
            [self ttv_freeFlowContinuePlay];
        } else {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:self.playerStateStore.state.minResolution forKey:@"resolution_type"];
            [dic setValue:@(YES) forKey:@"is_auto_switch"];
            
            [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficFreeFlowPlay payload:dic];
        }
    };
    
    self.freeFlowTipView.subscribeBlock = ^{
        __strong typeof(wself) self = wself;
        
        [TTTrackerWrapper eventV3:@"purchase_button_click" params:info];
        NSString *webURL = [[TTFlowStatisticsManager sharedInstance] freeFlowEntranceURL];
        if (!isEmptyString(webURL)) {
            
            TTAppPageCompletionBlock block = ^(id obj) {
                
                if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowToastTip:self.playerStateStore.state.videoSize / 1024.f]) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"免流量服务中" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                    
                    self.hidden = YES;
                    [self.freeFlowTipView removeFromSuperview];
                    self.playerStateStore.state.isShowingTrafficAlert = NO;
                    
                    if (!isSubscribe) {
                        
                        [self ttv_freeFlowContinuePlay];
                    }
                }
            };
            NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:1];
            condition[@"completion_block"] = [block copy];
            [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficFreeFlowSubscribe payload:nil];
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:webURL] userInfo:TTRouteUserInfoWithDict(condition)];
        }
    };
}

- (BOOL)ttv_showFreeFlowToastView {
    
    BOOL status = NO;
    // 符合免流条件
    if ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowToastTip:self.playerStateStore.state.videoSize / 1024.f]) {
        
        if (!self.playerStateStore.state.isFullScreen) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"免流量服务中" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        
        // 用户设置过清晰度 & 符合免流条件 切换到高清
        if ([TTVPlayerFreeFlowTipStatusManager shouldSwithToHDForFreeFlow] &&
            [[self.playerStateStore.state supportedResolutionTypes] containsObject:@(TTVPlayerResolutionTypeHD)] &&
            self.playerStateStore.state.currentResolution != TTVPlayerResolutionTypeHD) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:@(TTVPlayerResolutionTypeHD) forKey:@"resolution_type"];
            [dic setValue:@(YES) forKey:@"is_auto_switch"];
            [self.playerStateStore sendAction:TTVPlayerEventTypeSwitchResolution payload:dic];
        }
        
        status = YES;
    }
    
    return status;
}

- (void)ttv_freeFlowContinuePlay {
    
    NSNumber *resolutionType = nil;
    
    if ([TTVPlayerFreeFlowTipStatusManager shouldSwithToHDForFreeFlow] &&
        self.playerStateStore.state.currentResolution != TTVPlayerResolutionTypeHD) {
        resolutionType = @(TTVPlayerResolutionTypeHD);
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:resolutionType forKey:@"resolution_type"];
    [dic setValue:@(YES) forKey:@"is_auto_switch"];
    
    [self.playerStateStore sendAction:TTVPlayerEventTypeTrafficFreeFlowPlay payload:dic];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypeShowVideoFirstFrame:{
            if (TTNetworkConnected() && !TTNetworkWifiConnected()) { //显示流量提示
                [self handleTrafficAlert];
            }
        }
            break;
        case TTVPlayerEventTypeFinishUIReplay:{
            self.shouldShow = NO;
        }
            break;
        case TTVPlayerEventTypePlayerBeginPlay:{
            if ([action.payload isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = action.payload;
                NSString *action = [dic valueForKey:TTVPlayAction];
                if ([action isEqualToString:TTVPlayActionTrafficContinue] || [action isEqualToString:TTVPlayActionFromUIFinished] ) {
                    self.shouldShow = NO;
                }else{
                    self.shouldShow = YES;
                }
            }
        }
            break;
        case TTVPlayerEventTypeTrafficFreeFlowPlay:
        case TTVPlayerEventTypeTrafficPlay:{
            self.shouldShow = NO;
            TTVHasShownNewTrafficAlert = YES;
            // 防止后台切换网络 导致流量浮层无法隐藏
            if (self.playerStateStore.state.isShowingTrafficAlert) {
                self.hidden = YES;
                self.playerStateStore.state.isShowingTrafficAlert = NO;
            }
        }

            break;
        case TTVPlayerEventTypePlayerStop:{
            self.shouldShow = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTrafficAlert) object:nil];
        }
            break;

        default:
            break;
    }
}

@end
