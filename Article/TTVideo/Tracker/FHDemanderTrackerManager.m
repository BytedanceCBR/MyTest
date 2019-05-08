//
//  FHDemanderTrackerManager.m
//  Article
//
//  Created by 张静 on 2018/9/19.
//

#import "FHDemanderTrackerManager.h"
#import "TTVPlayerStateStore.h"
#import "FHDataPlayerTracker.h"
#import "TTVADPlayerTracker.h"
#import "TTVDemanderPlayerTracker.h"
#import "TTVPlayerUrlTracker.h"
#import "FHPlayerTrackerV3.h"

@interface FHDemanderTrackerManager ()
@property(nonatomic, strong)TTVADPlayerTracker *adTracker;
@property(nonatomic, strong)FHDataPlayerTracker *dataTracker;
@property(nonatomic, strong)TTVDemanderPlayerTracker *commonTracker;
@property(nonatomic, strong)NSHashTable *map;
@property(nonatomic, strong)FHPlayerTrackerV3 *logV3;

@end

@implementation FHDemanderTrackerManager

@synthesize playerStateStore = _playerStateStore;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataTracker = [[FHDataPlayerTracker alloc] init];
        _commonTracker = [[TTVDemanderPlayerTracker alloc] init];
        _logV3 = [[FHPlayerTrackerV3 alloc] init];
        _map = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore {
    if (_playerStateStore != playerStateStore) {
        _playerStateStore = playerStateStore;
        _adTracker.playerStateStore = playerStateStore;
        _dataTracker.playerStateStore = playerStateStore;
        _commonTracker.playerStateStore = playerStateStore;
        _logV3.playerStateStore = playerStateStore;
    }
}

- (void)sendEndTrack
{
    [_dataTracker sendEndTrack];
    [_adTracker sendEndTrack];
}

- (void)configureData
{
    if (!_adTracker && !isEmptyString(self.adID)) {
        _adTracker = [[TTVADPlayerTracker alloc] init];
        [self registerTracker:_adTracker];
    }
    [self registerTracker:_commonTracker];
    [self registerTracker:_dataTracker];
    [self registerTracker:_logV3];
}

- (void)configureTracker:(TTVPlayerTracker *)tracker
{
    tracker.trackLabel = self.trackLabel;
    tracker.itemID = self.itemID;
    tracker.groupID = self.groupID;
    tracker.aggrType = self.aggrType;
    tracker.adID = self.adID;
    tracker.logExtra = self.logExtra;
    tracker.categoryID = self.categoryID;
    tracker.videoSubjectID = self.videoSubjectID;
    tracker.playerStateStore = self.playerStateStore;
    tracker.logPb = self.logPb;
    tracker.enterFrom = self.enterFrom;
    tracker.categoryName = self.categoryName;
    tracker.authorId = self.authorId;
}

- (void)addExtra:(NSDictionary *)extra forEvent:(NSString *)event
{
    [_commonTracker addExtra:extra forEvent:event];
    [_dataTracker addExtra:extra forEvent:event];
    [_logV3 addExtra:extra forEvent:event];
}

- (void)registerTracker:(TTVPlayerTracker *)tracker
{
    if (![_map containsObject:tracker] && [tracker isKindOfClass:[TTVPlayerTracker class]]) {
        [self configureTracker:tracker];
        [_map addObject:tracker];
    }
}

@end
