//
//  TTVNetMonitorManager.m
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import "TTVNetMonitorManager.h"
#import "TTVPlayerStateNetMonitorPrivate.h"
#import "TTVPlayerState.h"
#import "TTVFullScreenManager.h"
#import "TTVPlayerStateFullScreen.h"

#import <TTReachability.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVFreeFlowTipManager.h"
#import "TTVFlowStatisticsManager.h"
#import <SSAppPageManager.h>
#import <TTURLUtils.h>

#import <TTVideoEngineInfoModel.h>
#import <TTUIResponderHelper.h>
#import <Aspects/Aspects.h>

#import "TTVIndicatorView.h"

#import <NetworkUtilities.h>

static BOOL _currentMovieHasTouchedContinue = NO;

@interface TTVNetMonitorManager ()
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, weak) UIView <TTVNetTrafficFreeFlowTipView> *freeFlowTipView;
@property (nonatomic, assign) BOOL pauseByUser;
//不通过freetflow的继续播放
@property (atomic, assign) BOOL playByUser;
@property (atomic, assign) BOOL playEnable;
/**
 免流提示开关 default NO
 */
@property (nonatomic, assign) BOOL flowTipEnable;
@property (nonatomic, copy) TTVCreateFlowTipView createFlowTipView;

@end

@implementation TTVNetMonitorManager
@synthesize store = _store;
- (instancetype)init
{
    if (self = [super init]) {
        _playEnable = YES;
    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypePlay]) {
                self.playEnable = YES;
                self.store.state.netMonitor.pausingBycellularNetwork = NO;
            }else if ([action.type isEqualToString:TTVPlayerActionTypePause]){
                self.playEnable = NO;
            }
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)enableFlowTip:(BOOL)enableFlowTip
{
    _flowTipEnable = enableFlowTip;
}

- (void)beginMonitor
{
    if (self.isMonitoring) return;
    self.isMonitoring = YES;
    self.pauseByUser = YES;
    self.playByUser = YES;
    self.store.state.netMonitor.pausingBycellularNetwork = NO;
    @weakify(self);
    [[RACObserve(self.store.player, readyForRender) distinctUntilChanged] subscribeNext:^(NSNumber *readyToPlay) {
        @strongify(self);
        if ([readyToPlay boolValue]) {
            [self ttv_showTipIfNeeded];
        }
    }];
    
    [[RACObserve(self.store.player, playbackState) distinctUntilChanged] subscribeNext:^(NSNumber *playbackState) {
        @strongify(self);
        if (TTVideoEnginePlaybackStatePlaying == [playbackState integerValue] && TTVideoEngineLoadStatePlayable == self.store.player.loadState) {
            // 只有用户主动触发的才展示提示
            if (self.playByUser) {
                [self ttv_showTipIfNeeded];
            } else {
                // 非用户主动触发的，不进行提示，恢复初始状态
                self.playByUser = YES;
            }
        } else {
            self.playByUser = YES;
        }
    }];
    [self addNotification];
}

- (void)removeFlowTipView
{
    [self.freeFlowTipView removeFromSuperview];
    self.freeFlowTipView = nil;
}

- (void)ttv_showTipIfNeeded
{
    @weakify(self);
    void(^resumePlay)() = ^() {
        @strongify(self);
        if (self.freeFlowTipView.superview) {
            [self.freeFlowTipView removeFromSuperview];
        }
        if ((self.playEnable || !self.pauseByUser) && self.store.player && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            self.playByUser = NO;
            [self.store.player play];
        }
    };
    if (TTNetworkConnected()) {
        [self showFlowTipViewIfNeededWithFinish:resumePlay];
    } else {
        BOOL isLocalVideo = self.store.player.isLocalVideo;
        if (!isLocalVideo) {
            [TTVIndicatorView showIndicatorAudoHideWithText:@"没有网络" image:[UIImage imageNamed:@"close_popup_textpage"]];
        }
        resumePlay();
    }
}

- (void)addFreeFlowTipViewWithTipText:(NSString *)tipText isSubscribe:(BOOL)isSubscribe
{
    UIView <TTVNetTrafficFreeFlowTipView> *freeFlowTipView = nil;
    if (self.createFlowTipView) {
       freeFlowTipView = self.createFlowTipView();
    }
    if (!freeFlowTipView) {
        freeFlowTipView = [[[TTVNetTrafficFreeFlowTipView class] alloc] initWithFrame:self.store.player.controlView.controlsOverlayView.bounds];
        freeFlowTipView.tipText = tipText;
        freeFlowTipView.isSubscribe = isSubscribe;
    }
    if (self.belowSubview) {
        [self.store.player.controlView.controlsOverlayView insertSubview:freeFlowTipView belowSubview:self.belowSubview];
    } else {
        [self.store.player.controlView.controlsOverlayView addSubview:freeFlowTipView];
    }
    self.freeFlowTipView = freeFlowTipView;
}

- (void)_showFreeFlowSubscribeTipWithContinueBlock:(void(^)())continueBlock
{
    CGFloat videoSize = [self ttv_currentVideoSize] / 1024.f / 1024.f;
    NSString *tipText = [TTVFreeFlowTipManager getSubscribeTitleTextWithVideoSize:videoSize];
    [self addFreeFlowTipViewWithTipText:tipText isSubscribe:YES];
    
    TTVRAction *action = [TTVRAction actionWithType:TTVNetMonitorManagerActionTypeShow info:nil];
    [self.store dispatch:action];
    
    @weakify(self);
    self.freeFlowTipView.continuePlayBlock = ^{
        @strongify(self);
        TTVRAction *action = [TTVRAction actionWithType:TTVNetMonitorManagerActionTypeContinuePlay info:nil];
        [self.store dispatch:action];        
        [self.freeFlowTipView removeFromSuperview];
        _currentMovieHasTouchedContinue = YES;
        if (continueBlock) {
            continueBlock();
        }
    };
    self.freeFlowTipView.subscribeBlock = ^{
        @strongify(self);
        NSString *webURL = [[TTVFlowStatisticsManager sharedInstance] freeFlowEntranceURL];
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"web_url"] = webURL;
        TTVRAction *action = [TTVRAction actionWithType:TTVNetMonitorManagerActionTypeSubscrib info:info];
        [self.store dispatch:action];
        
        if (!isEmptyString(webURL)) {
            WeakSelf;
            void (^block)(id) = ^(id obj) {
                StrongSelf;
                if ([[TTVFlowStatisticsManager sharedInstance] flowStatisticsEnable] &&
                    [TTVFlowStatisticsManager sharedInstance].isSupportFreeFlow &&
                    [TTVFlowStatisticsManager sharedInstance].isOpenFreeFlow) {
                    [TTVIndicatorView showIndicatorAudoHideWithText:@"免流量服务中" image:nil];
                    [self.freeFlowTipView removeFromSuperview];
                    if (continueBlock) {
                        continueBlock();
                    }
                }
            };
            
            //            // 标记返回时页面不刷新
            //            if (TTPlayerViewModelSourceList == self.store.player.viewModel.source) {
            //                self.currentListView.preventRefreshWhenAppear = YES;
            //            }
            // 构造web页面参数
            NSMutableDictionary *condition = [[NSMutableDictionary alloc] initWithCapacity:2];
            condition[@"completion_block"] = [block copy];
            
            typedef NSDictionary*(^JSCallHandler)(NSString * callbackId, NSDictionary* result, NSString *JSSDKVersion, BOOL * executeCallback);
            JSCallHandler handler = ^NSDictionary *(NSString * callbackId, NSDictionary* result, NSString *JSSDKVersion, BOOL * executeCallback) {
                [[TTVFlowStatisticsManager sharedInstance] setFlowData:result];
                *executeCallback = NO;
                return nil;
            };
            condition[@"JSCallHandler"] = @{@"TTRFlowStatistics.flowStatistics": [handler copy]};
            condition[@"title"] = @"专属流量包";
            condition[@"hide_more"] = @(YES);
            NSURL *pageURL = [TTURLUtils URLWithString:webURL];
            // 跳转
            [[SSAppPageManager sharedManager] openURL:pageURL baseCondition:condition];
        }
    };
}

- (void)_showOverFlowTip:(NSString *)tipText withContinueBlock:(void(^)())continueBlock
{
    [self addFreeFlowTipViewWithTipText:tipText isSubscribe:NO];
    @weakify(self);
    self.freeFlowTipView.continuePlayBlock = ^{
        @strongify(self);
        [self.freeFlowTipView removeFromSuperview];
        _currentMovieHasTouchedContinue = YES;
        if (continueBlock) {
            continueBlock();
        }
    };
}

- (void)_showFlowTipWithContinueBlock:(void(^)())continueBlock
{
    CGFloat videoSize = [self ttv_currentVideoSize] / 1024.f / 1024.f;
    
    NSString *tipText = [NSString stringWithFormat:@"正在使用非WiFi网络\n「继续播放」将消耗%.2fMB流量", videoSize];
    [self addFreeFlowTipViewWithTipText:tipText isSubscribe:NO];
    @weakify(self);
    self.freeFlowTipView.continuePlayBlock = ^{
        @strongify(self);
        [self.freeFlowTipView removeFromSuperview];
        _currentMovieHasTouchedContinue = YES;
        if (continueBlock) {
            continueBlock();
        }
    };
}

- (BOOL)_shouldResumeCurrentPlayer
{
    if (TTVideoEnginePlaybackStatePaused != self.store.player.playbackState) {
        return NO;
    }
    
    if (!self.store.player.view.superview) {
        return NO;
    }
    
    return YES;
}

- (CGFloat)ttv_currentVideoSize
{
    return [self.store.player videoSizeOfCurrrentResolution];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_freeFlowOrderFinish) name:ttv_kFreeFlowOrderFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)_freeFlowOrderFinish
{
    if (self.freeFlowTipView) {
        [self.freeFlowTipView removeFromSuperview];
    }
    if ([TTVFreeFlowTipManager shouldShowFreeFlowToastTip:[self ttv_currentVideoSize] / 1024.f]) {
        [TTVIndicatorView showIndicatorAudoHideWithText:@"免流量服务中" image:[UIImage imageNamed:@"doneicon_popup_textpage"]];
        if (TTVideoEnginePlaybackStatePaused == self.store.player.playbackState) {
            self.playByUser = NO;
            [self.store.player play];
        }
    }
}

- (void)connectionChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFlowTipViewIfNeeded) object:nil];
        [self performSelector:@selector(showFlowTipViewIfNeeded) withObject:nil afterDelay:1.0];
    });
}

- (void)showFlowTipViewIfNeededWithFinish:(void(^)())finish
{
    BOOL cellularNetwork = !TTNetworkWifiConnected() && TTNetworkConnected();
    BOOL currentMovieAllowAlert = !_currentMovieHasTouchedContinue && !self.allowPlayWithoutWiFi;
    BOOL isLocalVideo = self.store.player.isLocalVideo;
    if (cellularNetwork && currentMovieAllowAlert && _flowTipEnable && !isLocalVideo) {
        // 暂停当前播放
        BOOL isPlaying = self.store.player.playbackState == TTVideoEnginePlaybackStatePlaying;
        // 当前有正在显示的提示
        if (self.freeFlowTipView) {
            if (isPlaying) {
                self.store.state.netMonitor.pausingBycellularNetwork = YES;
                [self.store.player pause];
            }
            
            CGFloat videoSize = [self ttv_currentVideoSize] / 1024.f / 1024.f;
            NSString *tipText = [NSString stringWithFormat:@"正在使用非WiFi网络\n「继续播放」将消耗%.2fMB流量", videoSize];
            [self.freeFlowTipView refreshTipLabelText:tipText];
            
            return;
        }
#warning TOCHECK px
//        if (!isPlaying) return;
        // 剩余流量足够播放
        if ([TTVFreeFlowTipManager shouldShowFreeFlowToastTip:[self ttv_currentVideoSize] / 1024.f]) {
            return;
        }
        
        self.pauseByUser = NO;
        self.store.state.netMonitor.pausingBycellularNetwork = YES;
        [self.store.player pause];
        if ([TTVFreeFlowTipManager shouldShowFreeFlowSubscribeTip]) {
            [self _showFreeFlowSubscribeTipWithContinueBlock:finish];
            return;
        }
        if ([TTVFreeFlowTipManager shouldShowWillOverFlowTip:[self ttv_currentVideoSize] / 1024.f]) {
            CGFloat videoSize = [self ttv_currentVideoSize] / 1024.f / 1024.f;
            NSString *tipText = [NSString stringWithFormat:@"本月免费流量已不足\n继续播放将消耗%.2fMB流量", videoSize];
            [self _showOverFlowTip:tipText withContinueBlock:finish];
            return;
        }
        if ([TTVFreeFlowTipManager shouldShowDidOverFlowTip]) {
            CGFloat videoSize = [self ttv_currentVideoSize] / 1024.f / 1024.f;
            NSString *tipText = [NSString stringWithFormat:@"本月免费流量已经使用完毕\n继续播放将消耗%.2fMB流量", videoSize];
            [self _showOverFlowTip:tipText withContinueBlock:finish];
            return;
        }
        [self _showFlowTipWithContinueBlock:finish];
    } else {
        if (finish) {
            finish();
        }
    }
}

- (void)showFlowTipViewIfNeeded
{
    if ([TTVFreeFlowTipManager shouldShowFreeFlowToastTip:[self ttv_currentVideoSize] / 1024.f]) {
        [TTVIndicatorView showIndicatorAudoHideWithText:@"免流量服务中" image:[UIImage imageNamed:@"doneicon_popup_textpage"]];

    } else {
        @weakify(self);
        void(^resumePlay)() = ^() {
            @strongify(self);
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"shouldResume"] = @([self _shouldResumeCurrentPlayer]);
            TTVRAction *action = [TTVRAction actionWithType:TTVNetMonitorManagerActionTypeReplay info:info];
            [self.store dispatch:action];
            
            if ([self _shouldResumeCurrentPlayer]) {
                if (self.freeFlowTipView.superview) {
                    [self.freeFlowTipView removeFromSuperview];
                }
                if (self.store.player && !self.pauseByUser) {
                    // 只有不在后台时才开始播放
                    if (UIApplicationStateActive == [UIApplication sharedApplication].applicationState) {
                        [self.store.player play];
                    }
//                    else {
//                        self.store.player.playerControlsViewController.showing = YES;
//                    }
                    self.pauseByUser = YES;
                }
            }
        };
        [self showFlowTipViewIfNeededWithFinish:resumePlay];
    }
}

- (void)setFreeFlowTipView:(UIView <TTVNetTrafficFreeFlowTipView> *)freeFlowTipView {
    _freeFlowTipView = freeFlowTipView;
    
    if (freeFlowTipView) {
        UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backbtn setImage:[UIImage imageNamed:@"player_back"] forState:UIControlStateNormal];
        @weakify(self);
        [[backbtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            /////???????
//            [self.store.player.fullScreenManager setFullScreen:NO animated:YES completion:^(BOOL finished) {
//
//            }];
        }];
        backbtn.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
        [_freeFlowTipView addSubview:backbtn];
        

        
        BOOL isIPhoneXDevice = [TTDeviceHelper isIPhoneXSeries];
        CGFloat statusBarHeight = 44.0f; // iPhoneX刘海高度
        [backbtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat leftMargin = [TTVPlayerUtility tt_padding:12];
            if (isIPhoneXDevice && !self.store.state.fullScreen.supportsPortaitFullScreen) {
                leftMargin += statusBarHeight; // 返回按钮左边需要留出刘海空间
            }
            make.top.equalTo(_freeFlowTipView).offset(32);
            make.left.equalTo(_freeFlowTipView).offset(leftMargin);
        }];
        
        RAC(backbtn, hidden) = RACObserve(self.store.state.fullScreen, isFullScreen).not;
    }
}

- (void)customNetTrafficTipView:(TTVCreateFlowTipView)create
{
    self.createFlowTipView = create;
}

- (void)registerNetTrafficTracker:(NSObject <TTVNetMonitorTracker> *)tracker
{
    if ([tracker respondsToSelector:@selector(setStore:)]) {
        tracker.store = self.store;
    }
}
@end

@implementation TTVPlayer (TTVNetMonitorManager)

- (TTVNetMonitorManager *)netMonitorManager
{    return nil;

//    return [self partManagerFromClass:[TTVNetMonitorManager class]];
}

@end
