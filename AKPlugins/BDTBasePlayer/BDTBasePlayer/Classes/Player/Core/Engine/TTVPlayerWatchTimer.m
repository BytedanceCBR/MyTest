//
//  TTVPlayerWatchTimer.m
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import "TTVPlayerWatchTimer.h"
#import "TTVPlayerStateStore.h"

@interface TTVPlayerWatchTimer()
@property (nonatomic, assign, readwrite) NSTimeInterval total;
@property (nonatomic, strong) NSDate *startDate;
@end

@implementation TTVPlayerWatchTimer
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore {
    if (_playerStateStore != playerStateStore) {
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
    }
}

- (void)startWatch
{
    if (self.startDate) {
        self.total += [[NSDate date] timeIntervalSinceDate:self.startDate];
    }
    self.startDate = [NSDate date];
}

- (void)endWatch
{
    if (self.startDate) {
        self.total += [[NSDate date] timeIntervalSinceDate:self.startDate];
        self.startDate = nil;
    }
}

- (void)reset
{
    self.startDate = nil;
    self.total = 0;
}

- (void)actionChangeCallbackWithAction:(TTVFluxAction *)action state:(id)state
{
    TTVPlayerStateAction *newAction = (TTVPlayerStateAction *)action;
    if (![newAction isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    switch (newAction.actionType) {
        case TTVPlayerEventTypeRefreshTotalWatchTime:{
            if (self.playerStateStore.state.playbackState == TTVVideoPlaybackStatePlaying) {
                [self endWatch];
                [self startWatch];
            }
        }
            break;
            
        default:
            break;
    }    
    
}
@end
