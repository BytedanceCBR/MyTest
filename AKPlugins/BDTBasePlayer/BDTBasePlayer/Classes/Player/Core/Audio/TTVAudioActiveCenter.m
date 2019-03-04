//
//  TTVAudioActiveCenter.m
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import "TTVAudioActiveCenter.h"
#import "TTVPlayerStateStore.h"
#import "KVOController.h"
#import "TTVPlayerAudioController.h"
#import <AVFoundation/AVFoundation.h>
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "TTVPlayerController.h"
@interface TTVAudioActiveCenterExecutor : NSObject
+ (TTVAudioActiveCenterExecutor *)sharedInstance;
- (void)deactive;
- (void)beactive;
@end

@implementation TTVAudioActiveCenterExecutor
+ (TTVAudioActiveCenterExecutor *)sharedInstance {
    static TTVAudioActiveCenterExecutor *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTVAudioActiveCenterExecutor alloc] init];
    });
    return sharedInstance;
}

- (void)deactive
{
    if (![TTVPlayerController currentPlayerController]) {
        [[TTVPlayerAudioController sharedInstance] setActive:NO];
    }else if([TTVPlayerController currentPlayerController].playerStateStore.state.playbackState != TTVVideoPlaybackStatePlaying){
        [[TTVPlayerAudioController sharedInstance] setActive:NO];
    }
}

- (void)beactive
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(deactive) object:nil];
    [[TTVPlayerAudioController sharedInstance] setActive:YES];
}

@end

@interface TTVAudioActiveCenter()
@property (nonatomic ,assign)BOOL isPlayingWhenEnterBackground;
@end

@implementation TTVAudioActiveCenter
- (void)dealloc
{
    if (self.playerStateStore) {
        [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
    }
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)deactive
{
    if (!self.playerStateStore.state.playerModel.disableSessionDeactive) {
        [[TTVAudioActiveCenterExecutor sharedInstance] performSelector:@selector(deactive) withObject:nil afterDelay:1.5];
    }
}

- (void)beactive
{
    [NSObject cancelPreviousPerformRequestsWithTarget:[TTVAudioActiveCenterExecutor sharedInstance] selector:@selector(deactive) object:nil];
    [[TTVPlayerAudioController sharedInstance] setActive:YES];
}

+ (void)beactive
{
    [[self class] beactive];
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        switch (self.playerStateStore.state.playbackState) {
            case TTVVideoPlaybackStateError:
            case TTVVideoPlaybackStateFinished:
            case TTVVideoPlaybackStateBreak:{
                self.playerStateStore.state.isChangingResolution = NO;
                [self deactive];
            }
                break;
            case TTVVideoPlaybackStatePlaying:{
            }
                break;
            case TTVVideoPlaybackStatePaused:
                if (self.playerStateStore.state.isChangingResolution) {
                    self.playerStateStore.state.isChangingResolution = NO;
                }else{
                    [self deactive];
                }
                break;
            default:
                break;
        }
    }];
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,muted) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.playerStateStore.state.playerModel.mutedWhenStart = self.playerStateStore.state.muted;
        if ([[change valueForKey:NSKeyValueChangeNewKey] integerValue] != [[change valueForKey:NSKeyValueChangeOldKey] integerValue]) {
            if (self.playerStateStore.state.playbackState != TTVVideoPlaybackStateError && self.playerStateStore.state.playbackState != TTVVideoPlaybackStateFinished) {
                [[self class] setupAudioSessionIsMuted:self.playerStateStore.state.muted];
            }
        }
    }];
    
}

+ (void)setupAudioSessionIsMuted:(BOOL)isMuted
{
    if (isMuted) {//静音的时候不打断其他app音乐的播放
        [[TTVPlayerAudioController sharedInstance] setCategory:AVAudioSessionCategoryAmbient];
//        [[TTVPlayerAudioController sharedInstance] setActive:NO];
    }
    else
    {
        [[TTVPlayerAudioController sharedInstance] setCategory:AVAudioSessionCategoryPlayback];
        [[TTVPlayerAudioController sharedInstance] setActive:YES];
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            default:
                break;
        }
    }
    
}

@end
