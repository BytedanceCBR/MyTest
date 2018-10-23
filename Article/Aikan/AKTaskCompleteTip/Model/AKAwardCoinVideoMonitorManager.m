//
//  AKAwardCoinVideoMonitorManager.m
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#import "ReactiveObjC.h"
#import "TTVPlayVideo.h"
#import "TTDetailModel.h"
#import "AKAwardCoinManager.h"
#import "TTVVideoPlayerModel.h"
#import "TTVVideoPlayerStateStore.h"
#import "AKAwardCoinVideoMonitorManager.h"
#import "AKTaskSettingHelper.h"
#import <KVOController/KVOController.h>

#define kAKEnableGetBonusPercentVideo                0.8
#define kAKEnableGetBonusDurationVideo               25

@interface AKAwardCoinVideoMonitorManager()

@property (nonatomic, weak)TTVDemandPlayer                  *player;
@property (nonatomic, copy)NSString                         *groupID;
//已经看了多久的视频
@property (nonatomic, assign)NSTimeInterval                 watchVideoDuration;
@property (nonatomic, strong)dispatch_source_t              countDownTimer;
@property (nonatomic, assign)BOOL                           timerIsRunning;
@end

@implementation AKAwardCoinVideoMonitorManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _countDownTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(self.countDownTimer, DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC, 0);
        WeakSelf;
        dispatch_source_set_event_handler(self.countDownTimer, ^{
            StrongSelf;
            [self watchVideoTimerTrigged];
        });
        dispatch_source_set_cancel_handler(self.countDownTimer, ^{
            StrongSelf;
            self.countDownTimer = nil;
        });
    }
    return self;
}

- (void)watchVideoTimerTrigged;
{
    _watchVideoDuration += 1;
}

static AKAwardCoinVideoMonitorManager *shareInstace = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstace = [[AKAwardCoinVideoMonitorManager alloc] init];
    });
    return shareInstace;
}

- (void)monitorVideoWith:(TTVPlayVideo *)playVideo
{
    if (![AKTaskSettingHelper shareInstance].akBenefitEnable || ![TTAccount sharedAccount].isLogin) {
        return;
    }
    NSString *groupID = playVideo.playerModel.groupID;
    NSString *aid = playVideo.playerModel.adID;
    if (isEmptyString(aid) && [[AKAwardCoinManager shareInstance] checkIfNeedMonitorWithGroupID:groupID]) {
        self.watchVideoDuration = 0;
        self.player = playVideo.player;
        self.groupID = groupID;
        [self.player registerPart:self];
        [self resumeTimer];
    }
}

#pragma TTVPlayerContext

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        [self.KVOController unobserve:_playerStateStore.state];
        _playerStateStore = playerStateStore;
        [self.playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            CGFloat percent = self.playerStateStore.state.currentPlaybackTime / self.playerStateStore.state.duration;
            [self checkIsEnableGetBonusWithPercent:percent];
        }];
    }
}

- (void)checkIsEnableGetBonusWithPercent:(CGFloat)percent
{
    NSString *groupID = self.groupID;
    __weak TTVDemandPlayer *player = self.player;
    if (percent >= kAKEnableGetBonusPercentVideo && self.watchVideoDuration > kAKEnableGetBonusDurationVideo && [[AKAwardCoinManager shareInstance] checkIfNeedMonitorWithGroupID:groupID]) {
        [self finishCurMonitor];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
        if (self.videoDetailModel.fromSource == NewsGoDetailFromSourceAPNS ||
            self.videoDetailModel.fromSource == NewsGoDetailFromSourceAPNSInAppAlert) {
            [dict setValue:@"push" forKey:@"impression_type"];
        }
        [AKAwardCoinManager requestReadBounsWithGroupID:groupID withExtraParam:nil completion:^(NSInteger err_no, NSString * err_tip, NSDictionary * dict) {
            if (err_no == 0 && [dict isKindOfClass:[NSDictionary class]]) {
                NSString *content = [dict tt_stringValueForKey:@"content"];
                NSInteger coinNum = [dict tt_integerValueForKey:@"score_amount"];
                if (player) {
                    [AKAwardCoinManager showAwardCoinTipInView:player tipType:AKAwardCoinTipTypeVideo coinNum:coinNum title:content];
                }
                [[AKAwardCoinManager shareInstance] setHadReadWithGroupID:groupID];
            }
        }];
    }
}

- (void)finishCurMonitor
{
    [self setPlayerStateStore:nil];
    self.player = nil;
    [self suspendTimer];
    self.watchVideoDuration = 0;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypePlayerStop:
            case TTVPlayerEventTypePlayerPause:
                [self suspendTimer];
                break;
            case TTVPlayerEventTypePlayerResume:
            case TTVPlayerEventTypePlayerBeginPlay:
            case TTVPlayerEventTypePlayerContinuePlay:
                [self resumeTimer];
                break;
            default:
                break;
        }
    }
}

- (void)resumeTimer
{
    if (!self.timerIsRunning) {
        self.timerIsRunning = YES;
        dispatch_resume(self.countDownTimer);
    }
}

- (void)suspendTimer
{
    if (self.timerIsRunning) {
        self.timerIsRunning = NO;
        dispatch_suspend(self.countDownTimer);
    }
}

@end
