//
//  TTInfiniteLoopFetchNewsListRefreshTipManager.m
//  Article
//
//  Created by 王霖 on 2017/6/4.
//
//

#import "TTInfiniteLoopFetchNewsListRefreshTipManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import <TTNetworkManager.h>
#import "ArticleURLSetting.h"
#import "ListDataHeader.h"
#import "TTArticleCategoryManager.h"
#import "TTLocationManager.h"
#import <JSONModel.h>

static NSString * const kTTMinBehotTimeKey = @"kTTMinBehotTimeKey";
static NSString * const kChannelTipPollingIntervalKey = @"kChannelTipPollingIntervalKey";

@interface _TTChannelTipPollingIntervalEntity : JSONModel
@property (nonatomic, copy) NSString * category;
@property (nonatomic, assign) NSTimeInterval interval;
@end
@implementation _TTChannelTipPollingIntervalEntity
@end

#pragma mark - TTInfiniteLoopFetchNewsListRefreshTipManager

@interface TTInfiniteLoopFetchNewsListRefreshTipManager ()

@property (nonatomic, assign)NSTimeInterval followChannelRefreshTipInterval;
@property (nonatomic, strong)NSTimer * followChannelRefreshTipTimer;
@property (nonatomic, assign)NSTimeInterval saveInvalidateFollowChannelMinBehotTime;

@end

@implementation TTInfiniteLoopFetchNewsListRefreshTipManager

#pragma mark -- Life cycle

+ (instancetype)sharedManager {
    static TTInfiniteLoopFetchNewsListRefreshTipManager * _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TTInfiniteLoopFetchNewsListRefreshTipManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _followChannelRefreshTipInterval = [self getChannelTipPollingIntervalWithcategoryID:kTTFollowCategoryID];
        _saveInvalidateFollowChannelMinBehotTime = -1;
        [self addNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeNotification];
    [_followChannelRefreshTipTimer invalidate];
}

#pragma mark -- Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (-1 != self.saveInvalidateFollowChannelMinBehotTime) {
        [self.followChannelRefreshTipTimer invalidate];
        self.followChannelRefreshTipTimer = [NSTimer scheduledTimerWithTimeInterval:self.followChannelRefreshTipInterval
                                                                             target:self
                                                                           selector:@selector(fetchFollowChannelRefreshTip:)
                                                                           userInfo:@{kTTMinBehotTimeKey:@(self.saveInvalidateFollowChannelMinBehotTime)}
                                                                            repeats:YES];
        [self.followChannelRefreshTipTimer fire];
        self.saveInvalidateFollowChannelMinBehotTime = -1;
    }
}

- (void)didEnterBackground:(NSNotification *)notification {
    if (self.followChannelRefreshTipTimer.isValid) {
        self.saveInvalidateFollowChannelMinBehotTime = [[self.followChannelRefreshTipTimer.userInfo objectForKey:kTTMinBehotTimeKey] doubleValue];
        [self.followChannelRefreshTipTimer invalidate];
        self.followChannelRefreshTipTimer = nil;
    }
}

#pragma mark -- Fetch refresh tip

- (void)fetchCategoryRefreshTipWithCategoryID:(NSString *)categoryID minBehotTime:(NSTimeInterval)minBehotTime{
    if (minBehotTime < 0) {
        return;
    }
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@(minBehotTime) forKey:@"min_behot_time"];
    [params setValue:categoryID forKey:@"category"];
    [params setValue:@(ListDataDefaultRemoteNormalLoadCount) forKey:@"count"];
    TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
    if (newsLocalCategory) {
        if ([TTArticleCategoryManager isUserSelectedLocalCity]) {
            [params setValue:newsLocalCategory.name forKey:@"user_city"];
        }
    }
    NSString *city = [TTLocationManager sharedManager].city;
    [params setValue:city forKey:@"city"];
    
    NSMutableDictionary * userInfoDict = [NSMutableDictionary dictionaryWithCapacity:10];
    [userInfoDict setValue:categoryID forKey:@"categoryID"];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting refreshTipURLString]
                                                     params:params
                                                     method:@"GET"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       if (nil == error) {
                                                           StrongSelf;
                                                           if (self.followChannelRefreshTipTimer.valid) {
                                                               NSTimeInterval currentMinBehotTime = [[self.followChannelRefreshTipTimer.userInfo objectForKey:kTTMinBehotTimeKey] doubleValue];
                                                               if (minBehotTime < currentMinBehotTime) {
                                                                   return;
                                                               }
                                                           }
                                                           if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                                                               NSDictionary * data = [jsonObj tt_dictionaryValueForKey:@"data"];
                                                               if (nil != data) {
                                                                   NSUInteger count = [data tt_intValueForKey:@"count"];
                                                                   [[TTCategoryBadgeNumberManager sharedManager] updateNotifyPointOfCategoryID:categoryID
                                                                                                                                     withClean:count<=0];
                                                               }
                                                           }
                                                       }
                                                   }];
}

- (void)fetchFollowChannelRefreshTip:(NSTimer *)timer {
    NSTimeInterval minBehotTime = [[timer.userInfo objectForKey:kTTMinBehotTimeKey] doubleValue];
    [self fetchCategoryRefreshTipWithCategoryID:kTTFollowCategoryID minBehotTime:minBehotTime];
}

#pragma mark -- Public

- (void)newsListLastHadRefreshWithCategoryID:(NSString *)categoryID minBehotTime:(NSTimeInterval)minBehotTime{
    if ([categoryID isEqualToString:kTTFollowCategoryID]) {
        //关注列表刷新、移除关注频道栏红点提醒
        [[TTCategoryBadgeNumberManager sharedManager] updateNotifyPointOfCategoryID:kTTFollowCategoryID
                                                                          withClean:YES];
        if (self.followChannelRefreshTipTimer.isValid) {
            //开始新的轮询
            [self.followChannelRefreshTipTimer invalidate];
            self.followChannelRefreshTipTimer = [NSTimer scheduledTimerWithTimeInterval:self.followChannelRefreshTipInterval
                                                                                 target:self
                                                                               selector:@selector(fetchFollowChannelRefreshTip:)
                                                                               userInfo:@{kTTMinBehotTimeKey:@(minBehotTime)}
                                                                                repeats:YES];
        }
    }
}

- (void)startInfiniteLoopFetchFollowChannelRefreshTip {
    if (self.followChannelRefreshTipTimer.isValid) {
        return;
    }
    //启动关注频道提醒轮询，从数据库中获取min behot time
    NSMutableDictionary * queryDict = @{}.mutableCopy;
    [queryDict setValue:kTTFollowCategoryID forKey:@"categoryID"];
    [queryDict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
    [queryDict setValue:@(ExploreOrderedDataListLocationCategory) forKey:@"listLocation"];
    NSArray * items = [ExploreOrderedData objectsWithQuery:queryDict
                                                   orderBy:@"orderIndex DESC"
                                                    offset:0
                                                     limit:1];
    NSTimeInterval minBehotTime = 0;
    if ([items.firstObject isKindOfClass:[ExploreOrderedData class]]) {
        minBehotTime = [(ExploreOrderedData *)items.firstObject behotTime];
    }else {
        //如果一条数据都没有，使用五天前的behot time
        minBehotTime = ([[NSDate date] timeIntervalSinceNow] - 5.f * 24.f * 60.f * 60.f)*1000;
    }
    
    [self.followChannelRefreshTipTimer invalidate];
    self.followChannelRefreshTipTimer = [NSTimer scheduledTimerWithTimeInterval:self.followChannelRefreshTipInterval
                                                                         target:self
                                                                       selector:@selector(fetchFollowChannelRefreshTip:)
                                                                       userInfo:@{kTTMinBehotTimeKey:@(minBehotTime)}
                                                                        repeats:YES];
    [self.followChannelRefreshTipTimer fire];
}

- (void)stopInfiniteLoopFetchFollowChannelRefreshTip {
    [self.followChannelRefreshTipTimer invalidate];
    self.followChannelRefreshTipTimer = nil;
}

- (void)setChannelTipPollingInterval:(NSArray *)channelTipPollingInterval {
    if (![channelTipPollingInterval isKindOfClass:[NSArray class]] || channelTipPollingInterval.count == 0) {
        return;
    }
    NSError * error = nil;
    NSMutableArray * channelTipPollingIntervalEntitys = [_TTChannelTipPollingIntervalEntity arrayOfModelsFromDictionaries:channelTipPollingInterval
                                                                                                                    error:&error];
    if (!error && channelTipPollingIntervalEntitys.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:channelTipPollingInterval
                                                  forKey:kChannelTipPollingIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSTimeInterval)getChannelTipPollingIntervalWithcategoryID:(NSString *)categoryID {
    if (isEmptyString(categoryID)) {
        return 15 * 60;
    }
    NSArray * channelTipPollingInterval = [[NSUserDefaults standardUserDefaults] objectForKey:kChannelTipPollingIntervalKey];
    if (![channelTipPollingInterval isKindOfClass:[NSArray class]] || channelTipPollingInterval.count == 0) {
        return 15 * 60;
    }else {
        NSMutableArray <_TTChannelTipPollingIntervalEntity *> * channelTipPollingIntervalEntitys =
        [_TTChannelTipPollingIntervalEntity arrayOfModelsFromDictionaries:channelTipPollingInterval
                                                                    error:nil];
        __block _TTChannelTipPollingIntervalEntity * targetEntity = nil;
        [channelTipPollingIntervalEntitys enumerateObjectsUsingBlock:^(_TTChannelTipPollingIntervalEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.category isEqualToString:categoryID]) {
                targetEntity = obj;
                *stop = YES;
            }
        }];
        if (targetEntity) {
            if (targetEntity.interval < 60) {
                return 15 * 60;
            }else {
                return targetEntity.interval;
            }
        }else {
            return 15 * 60;
        }
    }
}

@end
