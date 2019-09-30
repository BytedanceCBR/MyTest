//
//  TTVDemanderTrackerManager.m
//  Article
//
//  Created by panxiang on 2017/6/16.
//
//

#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerStateStore.h"
#import "TTVDataPlayerTracker.h"
#import "TTVADPlayerTracker.h"
#import "TTVDemanderPlayerTracker.h"
#import "TTVPlayerUrlTracker.h"
#import "TTVPlayerTrackerV3.h"

@interface TTVDemanderTrackerManager ()
@property(nonatomic, strong)TTVADPlayerTracker *adTracker;
@property(nonatomic, strong)TTVDataPlayerTracker *dataTracker;
@property(nonatomic, strong)TTVDemanderPlayerTracker *commonTracker;
@property(nonatomic, strong)NSHashTable *map;
@property(nonatomic, strong)TTVPlayerTrackerV3 *logV3;
@end

@implementation TTVDemanderTrackerManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataTracker = [[TTVDataPlayerTracker alloc] init];
        _commonTracker = [[TTVDemanderPlayerTracker alloc] init];
        _logV3 = [[TTVPlayerTrackerV3 alloc] init];
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
    tracker.extraDic = self.extraDic;
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
