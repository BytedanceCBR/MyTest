//
//  TTVResolutionTipManager.m
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import "TTVResolutionTipManager.h"
#import "UIView+TTVPlayerSortPriority.h"
#import "UIView+TTVViewKey.h"
#import "TTPlayerResolutionDegradeTipView.h"
#import "TTPlayerIndicatorView.h"
#import "TTVideoResolutionService.h"
#import "TTVResolutionTipTracker.h"

@interface TTVResolutionTipManager()
@property (nonatomic, strong) NSObject <TTVPlayerTracker> *tracker;
@property (nonatomic, strong) TTPlayerIndicatorView *resolutionIndicatorView;
@property (nonatomic, strong) TTPlayerResolutionDegradeTipView *resolutionDegradeTipView;
@end

@implementation TTVResolutionTipManager
@synthesize store = _store;
- (void)dealloc
{
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeSwitchResolutionFinished]){
                TTVideoEngineResolutionType resolutionType = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyResolution] integerValue];
                BOOL isbegin = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisBegin] boolValue];
                BOOL isSuccess = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisSuccess] boolValue];
                BOOL isDegrade = [action.info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisDegrading] boolValue];
                if (isbegin) {
                    [self.resolutionIndicatorView switchResolutionWithType:resolutionType state:TTPlayerResolutionSwitchStateStart];
                }else{
                    if (isSuccess) {
                        [self.resolutionIndicatorView switchResolutionWithType:resolutionType state:TTPlayerResolutionSwitchStateDone];
                        if (isDegrade) {
                            // 关闭清晰度自动模式，保存切换成功以后的清晰度
                            [TTVideoResolutionService setDefaultResolutionType:self.store.player.currentResolution];
                            [TTVideoResolutionService setAutoModeEnable:NO];
                        }
                        
                        if (self.store.player.duration > 0) {
                            [TTVideoResolutionService saveProgressWhenResolutionChanged:(self.store.player.currentPlaybackTime / self.store.player.duration) * 100.0f];
                        }
                    } else {
                        [self.resolutionIndicatorView switchResolutionWithType:resolutionType state:TTPlayerResolutionSwitchStateFailed];
                    }
                }
            }else if ([action.type isEqualToString:TTVPlayerActionTypeSuggestReduceResolution]){
                [self showResolutionDegradeTip];
            }
        }];
        if (!self.resolutionIndicatorView) {
            [self createIndicatorView];
        }
        if (!self.resolutionDegradeTipView) {
            [self createDegradeTipView];
        }
        [self ttvl_observer];
        self.tracker = [[TTVResolutionTipTracker alloc] init];
    }
}

- (void)customTracker:(NSObject <TTVPlayerTracker> *)tracker
{
    self.tracker = tracker;
}

- (void)setTracker:(NSObject<TTVPlayerTracker> *)tracker
{
    if (_tracker != tracker) {
        _tracker = tracker;
        tracker.store = self.store;
    }
}

- (void)createIndicatorView
{
    self.resolutionIndicatorView = [[TTPlayerIndicatorView alloc] init];
    [self.store.player.view addSubview:self.resolutionIndicatorView];
    [self.resolutionIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(14);
        make.bottom.mas_offset(-35);
    }];
}

- (void)createDegradeTipView
{
    self.resolutionDegradeTipView = [[TTPlayerResolutionDegradeTipView alloc] initWithFrame:CGRectZero];
    [self.store.player.view addSubview:self.resolutionDegradeTipView];
    [self.resolutionDegradeTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(14);
        make.bottom.mas_offset(-35);
    }];
    @weakify(self);
    self.resolutionDegradeTipView.resolutionDegradeBlock = ^ {
        @strongify(self);
        [self.resolutionIndicatorView switchResolutionWithType:TTVideoEngineResolutionTypeSD state:TTPlayerResolutionSwitchStateStart];
        TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeClickResolutionDegrade info:@{TTVPlayerActionTypeClickResolutionDegradeKeyResolutionType : @(TTVideoEngineResolutionTypeSD) , TTVPlayerActionTypeClickResolutionDegradeKeyResolutionTypeBefore : @(self.store.player.currentResolution)}];
        [self.store dispatch:action];
    };
    self.resolutionDegradeTipView.closeBlock = ^ {
        @strongify(self);
        TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeCloseResolutionDegrade info:nil];
        [self.store dispatch:action];
    };
}

- (void)showResolutionDegradeTip {
    BOOL showSuccess = [self.resolutionDegradeTipView showIfNeeded];
    if (showSuccess) {
        TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeShowResolutionDegrade info:@{TTVPlayerActionTypeShowResolutionDegradeKeyCurrentResolution : @(self.store.player.currentResolution)}];
        [self.store dispatch:action];
    }
}

- (void)ttvl_observer
{
    @weakify(self);
    [[RACObserve(self.store.state.control, isShowing) distinctUntilChanged] subscribeNext:^(NSNumber *showing) {
        @strongify(self);
        [self _updateResolutionIndicatorWithShowing:[showing boolValue]];
        self.resolutionIndicatorView.alpha = [showing boolValue] ? .0f : 1.f;
        self.resolutionDegradeTipView.alpha = [showing boolValue] ? .0f : 1.f;
    }];
    
    // 1.只有在非全屏并且网络卡顿3次以上时，清晰度降级提示才会显示在左下角
    // 2.只要存在切换清晰度操作，清晰度切换提示出现时会一直显示在左下角
    NSArray *resolutionTipShowingObservers = @[RACObserve(self.store.state.fullScreen, isFullScreen),
                                               RACObserve(self.resolutionDegradeTipView, hidden),
                                               RACObserve(self.resolutionIndicatorView, hidden),
                                               ];
    RAC(self.store.state.resolutionTip, showingResolutionTip) = [RACSignal combineLatest:resolutionTipShowingObservers reduce:^ {
        @strongify(self);
        return @((!self.store.state.fullScreen.isFullScreen && !self.resolutionDegradeTipView.hidden) || !self.resolutionIndicatorView.hidden);
    }];
}

- (void)_updateResolutionIndicatorWithShowing:(BOOL)showing {
    BOOL isIPhoneXDevice = [TTDeviceHelper isIPhoneXSeries];
    CGFloat statusBarHeight = 44.0f; // iPhoneX 刘海高度
    CGFloat bottomSafeAreaHeight = self.store.state.fullScreen.supportsPortaitFullScreen ? 34.0f : 21.0f;
    [self.resolutionDegradeTipView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.store.state.fullScreen.isFullScreen) {
            make.centerX.equalTo(self.store.player.controlView);
        } else {
            make.left.mas_offset(14.0f);
        }
        CGFloat bottomMargin = -8.0f;
        if (isIPhoneXDevice && self.store.state.fullScreen.isFullScreen) {
            bottomMargin -= bottomSafeAreaHeight;
        }
        make.bottom.mas_offset(bottomMargin);
    }];
    
    [self.resolutionIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat leftMargin = 14.0f;
        if (isIPhoneXDevice && self.store.state.fullScreen.isFullScreen && !self.store.state.fullScreen.supportsPortaitFullScreen) {
            leftMargin += statusBarHeight;
        }
        make.left.mas_offset(leftMargin);
        make.bottom.equalTo(self.resolutionDegradeTipView);
    }];
}

@end


@implementation TTVPlayer (ResolutionTip)

- (TTVResolutionTipManager *)resolutionTipManager
{
    return nil;

//    return [self partManagerFromClass:[TTVResolutionTipManager class]];
}

@end
