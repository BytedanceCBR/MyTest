//
//  TTVResolutionManager.m
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import "TTVResolutionManager.h"
#import "UIView+TTVPlayerSortPriority.h"
#import "UIView+TTVViewKey.h"
#import "TTVLPlayerResolutionView.h"
#import "TTVPlayerStateResolutionPrivate.h"
#import "TTVResolutionTracker.h"
#import "TTVideoResolutionService.h"
#import <TTBaseLib/NetworkUtilities.h>

@interface TTVResolutionManager()
@property (nonatomic, strong) UIButton *resolutionButton;
@property (nonatomic, strong) TTPlayerResolutionView *resolutionControlView;
@property (nonatomic ,assign)BOOL enableResolutionControl;
@property (nonatomic ,strong)NSObject <TTVPlayerTracker> *tracker;

@end

@implementation TTVResolutionManager
@synthesize store = _store;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (TTVideoEngineNetworkType)networkType {
    return TTNetworkWifiConnected() ? TTVideoEngineNetworkTypeWifi : TTVideoEngineNetworkTypeNotWifi;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            // TODO
//            if ([action.type isEqualToString:TTVPlayerActionTypeClickResolutionDegrade]) {
//                [self.resolutionControlView dismiss];
//                [self switchResolution:[action.info[TTVPlayerActionTypeClickResolutionDegradeKeyResolutionType] integerValue] afterDegrade:YES];
//            }else if ([action.type isEqualToString:TTVPlayerActionTypeFetchedVideoModel]){
//                if (!self.store.player.isLocalVideo) {
//                    if ([TTVideoResolutionService defaultResolutionType] != TTVideoEngineResolutionTypeAuto) {
//                        TTVideoEngineResolutionType currentType = TTVideoEngineResolutionTypeUnknown;
//                        if ([self.store.player.supportedResolutionTypes containsObject:@([TTVideoResolutionService defaultResolutionType])]) {
//                            currentType = [TTVideoResolutionService defaultResolutionType];
//                        } else {
//                            for (NSInteger i = self.store.player.supportedResolutionTypes.count - 1; i >= 0; i--) {
//                                if ([TTVideoResolutionService defaultResolutionType] > [self.store.player.supportedResolutionTypes[i] integerValue]) {
//                                    currentType = [self.store.player.supportedResolutionTypes[i] integerValue];
//                                    break;
//                                }
//
//                                if (i == 0) {
//                                    currentType = [[self.store.player.supportedResolutionTypes firstObject] integerValue];
//                                }
//                            }
//                        }
//
//                        if (currentType != TTVideoEngineResolutionTypeUnknown) {
//                            [self.store.player configResolution:currentType completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
//
//                            }];
//                        }
//                    } else {
//                        if ([self networkType] == TTVideoEngineNetworkTypeWifi) {
//                            [self.store.player configResolution:TTVideoEngineResolutionTypeFullHD completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
//
//                            }];
//                        } else {
//                            [self.store.player configResolution:TTVideoEngineResolutionTypeSD completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
//
//                            }];
//                        }
//                    }
//                }
//            }
        }];
        if (!self.resolutionButton) {
            self.resolutionButton = [self createResolutionButton];
        }
        [self ttvl_observer];
        self.tracker = [[TTVResolutionTracker alloc] init];
        [TTVideoResolutionService saveProgressWhenResolutionChanged:0.0f];
        // TODO
//        [self.store.player configResolution:[TTVideoResolutionService defaultResolutionType] completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
//
//        }];
    }
}

- (UIButton *)createResolutionButton {
    UIButton *resolutionButton = [[UIButton alloc] init];
    resolutionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -7);
    [resolutionButton setTitle:@"自动" forState:UIControlStateNormal];
    resolutionButton.enabled = NO;
    if (@available(iOS 8.2, *)) {
        resolutionButton.titleLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_padding:17] weight:UIFontWeightMedium];
    } else {
        // Fallback on earlier versions
        resolutionButton.titleLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_padding:17]];
    }
    [resolutionButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
    [resolutionButton setTitleColor:[UIColor colorWithWhite:255.0f / 255.0f alpha:0.5f] forState:UIControlStateDisabled];
    [resolutionButton addTarget:self action:@selector(resolutionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    resolutionButton.ttvPlayerSortContainerPriority = 10;
    resolutionButton.ttvPlayerLayoutViewKey = TTVResolutionManager_resolutionButton;
    [resolutionButton sizeToFit];
    return resolutionButton;
}

- (void)ttvl_observer
{
    RAC(self.store.state.resolution, isShowing) = RACObserve(self.resolutionControlView, isShowing);

    @weakify(self);
    //只有 全屏 并且外部enable才真正开启
    RAC(self.store.state.resolution, realEnableResolution) = [RACSignal combineLatest:@[RACObserve(self.store.state.fullScreen, isFullScreen), RACObserve(self, enableResolutionControl)] reduce:^(NSNumber *fullScreen, NSNumber *enabled){
        return @([fullScreen boolValue] && [enabled boolValue]);
    }];
    
    //控制 清晰度切换按钮 出现消失 时候 的 渐变
    [RACObserve(self.store.state.resolution, realEnableResolution) subscribeNext:^(NSNumber *show) {
        @strongify(self);
        if ([show boolValue]) {
            self.resolutionButton.hidden = NO;
            self.resolutionButton.alpha = 0;
        }
        [UIView animateWithDuration:.25f animations:^{
            self.resolutionButton.alpha = [show boolValue] ? 1 : 0;
        } completion:^(BOOL finished) {
            if (!finished) return;
            self.resolutionButton.hidden = ![show boolValue];
        }];
    }];
    
    [[RACObserve(self.store.state.fullScreen, isFullScreen) distinctUntilChanged] subscribeNext:^(NSNumber *show) {
        @strongify(self);
        [UIView performWithoutAnimation:^{
            [self.resolutionControlView dismiss];
        }];
    }];
    
    [[RACObserve(self.store.state.control, isShowing) distinctUntilChanged] subscribeNext:^(NSNumber *showing) {
        @strongify(self);
        [self.resolutionControlView dismiss];
    }];
    
    [RACObserve(self.store.player, readyForRender) subscribeNext:^(NSNumber *readyToPlay) {
        @strongify(self);
        if ([readyToPlay boolValue]) {
            if (self.store.player.isLocalVideo) {
                [self updateResolutionButtonTitle:@"本地"];
                self.resolutionButton.enabled = NO;
            } else {
                NSArray *supportedResolutions = [self.store.player supportedResolutionTypes];
                [self.resolutionControlView setSupportedTypes:supportedResolutions
                                                  currentType:self.store.player.currentResolution];
                [self updateResolutionButtonTitle:[self.store.state.resolution titleForResolution:self.store.player.currentResolution]];
            }
        }
    }];
    
    [RACObserve(self.store.state.fullScreen, isFullScreen) subscribeNext:^(NSNumber *full) {
        if (self.store.state.fullScreen.isFullScreen) {
            [self.store.player.controlView.containerView.bottomView.fullScreenRightContainerView addView:self.resolutionButton];
        }else{
            [self.resolutionButton removeFromSuperview];
        }
    }];
}

- (void)enableResolution:(BOOL)enable
{
    self.enableResolutionControl = enable;
}

- (void)resolutionButtonClicked:(UIButton *)sender
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (self.resolutionControlView.isShowing) {
        [self.resolutionControlView dismiss];
    } else {
        if (self.resolutionControlView) {
            @weakify(self);
            self.resolutionControlView.didResolutionChanged = ^(TTVideoEngineResolutionType resolution) {
                @strongify(self);
                [self.resolutionControlView dismiss];
                
                TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeChangeResolution info:@{TTVPlayerActionTypeChangeResolutionKeyResolution:@(resolution)}];
                [self.store dispatch:action];
                
                BOOL resolutionChanged = (resolution != self.store.player.currentResolution);
                if (resolutionChanged) {
                    self.resolutionButton.enabled = NO;
                    if (resolution < self.store.player.currentResolution) {
                        self.store.player.smoothDelayedSeconds = 3.0f;
                    } else {
                        self.store.player.smoothDelayedSeconds = 5.0f;
                    }
                    [self switchResolution:resolution afterDegrade:NO];
                } else {
                    [self updateResolutionButtonTitle:[self.store.state.resolution titleForResolution:resolution]];
                }
            };
        }
        info[TTVPlayerActionTypeClickResolutionButtonKeyIsShowing] = @(NO);
        TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeClickResolutionButton info:info];
        [self.store dispatch:action];
        self.resolutionControlView.backgroundColor = [UIColor redColor];
        [self.resolutionControlView showInView:self.store.player.controlView atTargetPoint:CGPointZero];
        return;
    }
    TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeClickResolutionButton info:info];
    [self.store dispatch:action];

}

// isDegrading 是否是因为网络卡顿 导致的清晰度切换
- (void)switchResolution:(TTVideoEngineResolutionType)resolution afterDegrade:(BOOL)isDegrading {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisBegin] = @(YES);
    info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisDegrading] = @(isDegrading);
    info[TTVPlayerActionTypeSwitchResolutionFinishedKeyResolution] = @(resolution);
    TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeSwitchResolutionFinished info:info];
    [self.store dispatch:action];

    self.store.state.resolution.resolutionSwitching = YES;
    // TODO
//    WeakSelf;
//    [self.store.player configResolution:resolution completion:^(BOOL success, TTVideoEngineResolutionType completeResolution) {
//        StrongSelf;
//        self.store.state.resolution.resolutionSwitching = NO;
//
//        NSMutableDictionary *info = [NSMutableDictionary dictionary];
//        info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisBegin] = @(NO);
//        info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisSuccess] = @(success);
//        info[TTVPlayerActionTypeSwitchResolutionFinishedKeyisDegrading] = @(isDegrading);
//        info[TTVPlayerActionTypeSwitchResolutionFinishedKeyResolution] = @(resolution);
//        TTVRAction *action = [TTVRAction actionWithType:TTVPlayerActionTypeSwitchResolutionFinished info:info];
//        [self.store dispatch:action];
//        [self.resolutionControlView setSupportedTypes:self.store.player.supportedResolutionTypes
//                                          currentType:self.store.player.currentResolution];
//        [self updateResolutionButtonTitle:[self.store.state.resolution titleForResolution:resolution]];
//    }];
}

- (TTPlayerResolutionView *)resolutionControlView
{
    if (!_resolutionControlView) {
        _resolutionControlView = [[TTVLPlayerResolutionView alloc] initWithFrame:CGRectZero];
    }
    return _resolutionControlView;
}

- (void)updateResolutionButtonTitle:(NSString *)title
{
    self.resolutionButton.enabled = YES;
    [self.resolutionButton setTitle:title forState:UIControlStateNormal];
    [self.resolutionButton sizeToFit];
}

- (void)setTracker:(NSObject<TTVPlayerTracker> *)tracker
{
    if (_tracker != tracker) {
        _tracker = tracker;
        _tracker.store = self.store;
    }
}

- (void)customTracker:(NSObject <TTVPlayerTracker> *)tracker
{
    self.tracker = tracker;
}
@end


@implementation TTVPlayer (Resolution)

- (TTVResolutionManager *)resolutionManager;
{
    return nil;

//    return [self partManagerFromClass:[TTVResolutionManager class]];
}

@end
