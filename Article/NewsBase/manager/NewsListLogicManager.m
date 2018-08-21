//
//  NewsListLogicManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-10-30.
//
//

#import "NewsListLogicManager.h"
#import "NewsFetchListRefreshTipManager.h"
#import "TTProjectLogicManager.h"
#import "TTCategoryDefine.h"
#import "TTCategoryBadgeNumberManager.h"
#import "TTKitchenHeader.h"

#define kListLogicReturnBackgroundTimeKey @"kListLogicReturnBackgroundTimeKey"

#define kListSwitchToRecommendTabIntervalKey @"kListSwitchToRecommendTabIntervalKey"//间隔超过指定时间，回到前台，切换到推荐列表
#define kListTipDisplayIntervalKey @"kListTipDisplayIntervalKey"        //列表tip每次展示的时间间隔
#define kListTipRequestIntervalKey @"kListTipRequestIntervalKey"        //列表页tip刷新间隔
#define kListAutoReloadIntervalKey @"kListAutoReloadIntervalKey"        //列表页自动刷新间隔

#define kLastCategoryReloadTimeKey @"kLastCategoryReloadTimeKey"        //上一次reload 的时间
#define kListWillDisappearTimeKey  @"kListWillDisappearTimeKey"         //离开频道列表的时间（只记录了需要记录的频道）
#define kNewsListShowRefreshInfoKey  @"kNewsListShowRefreshInfoKey"     //tips提示（比如push）相关从文章页回到feed的标示，用以判断刷新

#define kFollowListWillDisappearTimeKey  @"kFollowListWillDisappearTimeKey"         //离开频道列表的时间（只记录了需要记录的频道）

static NewsListLogicManager * shareManager;

@interface NewsListLogicManager()<NewsFetchListRefreshTipManagerDelegate>

@property(nonatomic, assign, readwrite)NSTimeInterval listTipRefreshInterval;
@property(nonatomic, assign, readwrite)NSTimeInterval listAutoReloadRefreshInterval;
@property(nonatomic, assign, readwrite)NSTimeInterval listTipDisplayInterval;
@property(nonatomic, assign, readwrite)NSTimeInterval listSwitchToRecommendInterval;
@property(nonatomic, retain)NSMutableSet * hasReloadedCategoryIDs;//本次启动/后台切换前台已经刷新过的列表的categoryID
@property(nonatomic, retain)NewsFetchListRefreshTipManager * fetchReloadTipManager;
@property(nonatomic, retain)NSMutableDictionary * lastFetchReloadTipTimes;//最后一次获取tip的时间， key为categoryID，value为@（时间）
@property(nonatomic, retain)NSTimer * fetchRemoteReloadTipsTimer;
@end

@implementation NewsListLogicManager

+ (NewsListLogicManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[NewsListLogicManager alloc] init];
    });
    return shareManager;
}

- (void)dealloc
{
    [_fetchRemoteReloadTipsTimer invalidate];
    self.fetchRemoteReloadTipsTimer = nil;
    self.lastFetchReloadTipTimes = nil;
    [_fetchReloadTipManager cancel];
    self.fetchReloadTipManager = nil;
    self.hasReloadedCategoryIDs = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.listTipRefreshInterval = [NewsListLogicManager fetchListTipRefreshInterval];
        self.listAutoReloadRefreshInterval = [NewsListLogicManager fetchListAutoReloadInterval];
        self.listTipDisplayInterval = [NewsListLogicManager fetchListTipDisplayInterval];
        self.listSwitchToRecommendInterval = [NewsListLogicManager fetchSwitchToRecommendChannelInterval];
        
        self.hasReloadedCategoryIDs = [NSMutableSet setWithCapacity:100];
        self.lastFetchReloadTipTimes = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    return self;
}

- (void)beginFetchRemoteReloadTipCountDownForCategoryID:(NSString *)categoryID
{
    [ _fetchRemoteReloadTipsTimer invalidate];
    
    if (isEmptyString(categoryID)) {
        return;
    }

    NSTimeInterval lastFetchTipTime = [[_lastFetchReloadTipTimes objectForKey:categoryID] doubleValue];
    NSTimeInterval lastReloadTime = [NewsListLogicManager listLastReloadTimeForCategory:categoryID];
    NSTimeInterval time = MAX(lastFetchTipTime, lastReloadTime);
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval afterTime = _listTipRefreshInterval - (now - time);
    
    if (afterTime > 0) {
        NSDictionary * userInfo = @{@"categoryID":categoryID};
        self.fetchRemoteReloadTipsTimer = [NSTimer scheduledTimerWithTimeInterval:afterTime target:self selector:@selector(fetchRemoteReloadTipTimerDone:) userInfo:userInfo repeats:NO];
    }
}

- (void)fetchRemoteReloadTipTimerDone:(NSTimer *)timer
{
    NSString * cID = [[timer userInfo] objectForKey:@"categoryID"];
    if (!isEmptyString(cID)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewsListShouldFetchedRemoteReloadTipNotification object:nil userInfo:@{@"categoryID" : cID}];
    }
}

- (BOOL)needSwitchToRecommendTab
{
    NSTimeInterval lastToBgTime = [NewsListLogicManager fetchLastToBackgroundTime];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - lastToBgTime > _listSwitchToRecommendInterval) {
        return YES;
    }
    return NO;
}

- (void)willEnterForground
{
    
}

- (void)didEnterBackground
{
    [_fetchRemoteReloadTipsTimer invalidate];
    [_hasReloadedCategoryIDs removeAllObjects];
//    [_lastFetchReloadTipTimes removeAllObjects];
    [NewsListLogicManager saveReturnToBackgroundTime];
}

- (BOOL)shouldFetchReloadTipForCategory:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return NO;
    }
    
    NSTimeInterval lastFetchTipTime = [[_lastFetchReloadTipTimes objectForKey:categoryID] doubleValue];
    NSTimeInterval lastReloadTime = [NewsListLogicManager listLastReloadTimeForCategory:categoryID];
    NSTimeInterval time = MAX(lastFetchTipTime, lastReloadTime);
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    if ((now - time > _listTipRefreshInterval) && (now - lastReloadTime < _listAutoReloadRefreshInterval)) {
        return YES;
    }
    return NO;
}

- (void)updateLastFetchReloadTipTimeForCategory:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    [_lastFetchReloadTipTimes setObject:@(now) forKey:categoryID];
}

- (void)fetchReloadTipWithMinBehotTime:(NSTimeInterval)minBehotTime categoryID:(NSString *)categoryID count:(NSUInteger)count
{
    if (isEmptyString(categoryID)) {
        return;
    }
    
    [self updateLastFetchReloadTipTimeForCategory:categoryID];
    
    if (!_fetchReloadTipManager) {
        self.fetchReloadTipManager = [[NewsFetchListRefreshTipManager alloc] init];
        _fetchReloadTipManager.delegate = self;
    }
    [_fetchReloadTipManager fetchListRefreshTipWithMinBehotTime:minBehotTime categoryID:categoryID count:count];
}

/*
 *  每次启动/后台切换前台，同一个category,最多只刷新一次，且是距离上次刷新超过 _listAutoReloadRefreshInterval间隔，如果没有超过间隔，本次也不再刷新
 */
- (BOOL)shouldAutoReloadFromRemoteForCategory:(NSString *)categoryID
{
    if ([categoryID isEqualToString:kTTFollowCategoryID] && [[TTCategoryBadgeNumberManager sharedManager] hasNotifyPointOfCategoryID:kTTFollowCategoryID]) {

        //关注频道刷新逻辑区别于其他频道，如果频道栏有红点，需要自动刷新列表
        NSTimeInterval timeInterval = [NewsListLogicManager followListDisappearInterval];
        if (timeInterval >= [NewsListLogicManager fetchFollowListAutoReloadWithNotifyInterval]) {
                return YES;
            }
    }

    if ([_hasReloadedCategoryIDs containsObject:categoryID]) {
        return NO;
    }

    NSTimeInterval lastReloadTime = [NewsListLogicManager listLastReloadTimeForCategory:categoryID];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    if (now - lastReloadTime >= _listAutoReloadRefreshInterval) {
        return YES;
    }
    return NO;
} 

+ (void)setNewsListShowRefreshInfo:(NSDictionary *)info
{
    [[NSUserDefaults standardUserDefaults] setValue:info forKey:kNewsListShowRefreshInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)newsListShowRefreshInfo
{
    NSDictionary *infoDic = [[NSUserDefaults standardUserDefaults] valueForKey:kNewsListShowRefreshInfoKey];
    return infoDic;
}

+ (BOOL)checkIfJustReloadFromRemote:(NSString *)categoryID
{
    NSTimeInterval lastReloadTime = [NewsListLogicManager listLastReloadTimeForCategory:categoryID];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    if (now - lastReloadTime <= 2.5) {
        return YES;
    }
    return NO;
}

- (void)saveHasReloadForCategoryID:(NSString *)categoryID
{
    [_hasReloadedCategoryIDs addObject:categoryID];
    [NewsListLogicManager saveListLastReloadTimeForCategory:categoryID];
}


#pragma mark -- NewsFetchListRefreshTipManagerDelegate

- (void)refreshTipManager:(NewsFetchListRefreshTipManager *)manager fetchedTip:(NSString *)tip categoryID:(NSString *)categoryID count:(NSInteger)count
{
    if (!isEmptyString(categoryID)) {
        
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
        [userInfo setValue:categoryID forKey:@"categoryID"];
        [userInfo setValue:tip forKey:@"tip"];
        [userInfo setValue:@(count) forKey:@"count"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewsListFetchedRemoteReloadTipNotification object:nil userInfo:userInfo];
    }
}

#pragma mark -- static method

//关注频道多存一份，给红点逻辑使用
+ (void)saveDisappearDateForFollowCategory{

    NSDate *now = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:[NSString stringWithFormat:@"%@", kFollowListWillDisappearTimeKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//关注频道多存一份，给红点逻辑使用
+ (NSTimeInterval)followListDisappearInterval {

    NSDate * last = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@", kFollowListWillDisappearTimeKey]];
    NSTimeInterval disappearInterval = 0.;
    if (last){
        disappearInterval = fabs([last timeIntervalSinceNow]);
    }
    return disappearInterval;

}

+ (void)saveDisappearDateForCategoryID:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return;
    }
    NSDate *now = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:[NSString stringWithFormat:@"%@%@", kListWillDisappearTimeKey, categoryID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)listDisappearIntercalForCategoryID:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return 0.;
    }
    NSDate * last = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kListWillDisappearTimeKey, categoryID]];
    NSTimeInterval disappearInterval = 0.;
    if (last){
        disappearInterval = fabs([last timeIntervalSinceNow]);
    }
    return disappearInterval;
}

+ (void)saveListLastReloadTimeForCategory:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return;
    }
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:time] forKey:[NSString stringWithFormat:@"%@%@", kLastCategoryReloadTimeKey, categoryID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)listLastReloadTimeForCategory:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return 0.;
    }
    NSNumber * num = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@", kLastCategoryReloadTimeKey, categoryID]];
    return [num doubleValue];
}

+ (NSTimeInterval)fetchListTipRefreshInterval
{
    NSTimeInterval time = [[[NSUserDefaults standardUserDefaults] objectForKey:kListTipRequestIntervalKey] doubleValue];
    if (time < 60) {
        //轮询时间必须大于60s，否则使用默认15min
        time = 15 * 60;
    }
    return time;
}

+ (void)saveListTipRefreshInterval:(NSTimeInterval)interval
{
    if (interval >= 60) {
        //轮询时间必须大于60s
        [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:kListTipRequestIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSTimeInterval)fetchListAutoReloadInterval
{
    NSTimeInterval time = [[[NSUserDefaults standardUserDefaults] objectForKey:kListAutoReloadIntervalKey] doubleValue];
    if (time <= 0) {
        time = 6 * 60 * 60;
    }
    return time;
}

+ (void)saveListAutoReloadInterval:(NSTimeInterval)interval
{
    if (interval >= 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:kListAutoReloadIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSTimeInterval)fetchFollowListAutoReloadWithNotifyInterval {

    NSTimeInterval time = [KitchenMgr getFloat:kKCUGCFollowAutoRefreshWithNotifyInterval];
    if (time < 0) {
        time = 1 * 60 * 60;
    }
    return time;
}

+ (NSTimeInterval)fetchListTipDisplayInterval
{
    NSTimeInterval time = [[[NSUserDefaults standardUserDefaults] objectForKey:kListTipDisplayIntervalKey] doubleValue];
    if (time <= 0) {
        time = 15;
    }
    return time;
}

+ (void)saveListTipDisplayInterval:(NSTimeInterval)interval
{
    if (interval >= 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:kListTipDisplayIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)saveReturnToBackgroundTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:@(time) forKey:kListLogicReturnBackgroundTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)fetchLastToBackgroundTime
{
    NSNumber * time = [[NSUserDefaults standardUserDefaults] objectForKey:kListLogicReturnBackgroundTimeKey];
    return [time doubleValue];
}

+ (NSTimeInterval)fetchSwitchToRecommendChannelInterval
{
    NSTimeInterval time = [[[NSUserDefaults standardUserDefaults] objectForKey:kListSwitchToRecommendTabIntervalKey] doubleValue];
    if (time <= 0) {
        time = 24 * 60 * 60;
    }
    return time;
}

+ (void)saveSwitchToRecommendChannelInterval:(NSTimeInterval)interval
{
    if (interval > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@(interval) forKey:kListSwitchToRecommendTabIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

+ (BOOL)needShowFixationCategory
{
    NSString * fixationCategoryID = TTLogicString(@"ArticleCategoryManagerViewFixationCategoryID", nil);
    if (isEmptyString(fixationCategoryID)) {
        return NO;
    }
    NSNumber * need = [[NSUserDefaults standardUserDefaults] objectForKey:@"kNeedShowFixationCategory"];
    if (need == nil) {
        return YES;
    }
    return [need boolValue];
}

//+ (void)setNeedShowFixationCategory:(BOOL)need
//{
//    [[NSUserDefaults standardUserDefaults] setObject:@(need) forKey:@"kNeedShowFixationCategory"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

+ (TTExploreMixedListUpdateTipType)tipListUpdateUseTabbarOfCategoryID:(NSString *)categoryID
                                                         listLocation:(ExploreOrderedDataListLocation)listLocation
{
    if ([categoryID isEqualToString:kTTWeitoutiaoCategoryID] && listLocation == ExploreOrderedDataListLocationWeitoutiao) {
        //微头条频道更新tip展示类型单独控制
        NSUInteger type = [SSCommonLogic WeitoutiaoTabListUpdateTipType];
        switch (type) {
            case 1:
                return TTExploreMixedListUpdateTipTypeTabbarRedPoint;
            case 2:
                return TTExploreMixedListUpdateTipTypeBlueBar;
            default:
                return TTExploreMixedListUpdateTipTypeNone;
        }
    }
    
    if ([categoryID isEqualToString:kTTFollowCategoryID]) {
        return TTExploreMixedListUpdateTipTypeNone;
    }
    
    NSNumber * resultNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"kTipListUpdateUseTabbar"];
    if (!resultNumber) {
        resultNumber = @(YES);
    }
    BOOL result = [resultNumber boolValue];
    if (result) {
        return TTExploreMixedListUpdateTipTypeTabbarRedPoint;
    }else {
        return TTExploreMixedListUpdateTipTypeBlueBar;
    }
}

/**
 *  设置是否使用tabbar来提示列表更新
 *
 *  @param useTabbar YES，使用tabbar更新;NO，使用蓝条更新
 */
+ (void)setTipListUpdateUseTabbar:(BOOL)useTabbar
{
    [[NSUserDefaults standardUserDefaults] setObject:@(useTabbar) forKey:@"kTipListUpdateUseTabbar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)needShowCitySelectionBar
{
    NSNumber * resultNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"kShowCitySelectionBar"];
    if (!resultNumber) {
        return YES;
    }
    BOOL result = [resultNumber boolValue];
    return result;
}

+ (void)setNeedShowCitySelectionBar:(BOOL)need
{
    [[NSUserDefaults standardUserDefaults] setObject:@(need) forKey:@"kShowCitySelectionBar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
