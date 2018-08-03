//
//  TSVTabTipManager.m
//  Article
//
//  Created by 邱鑫玥 on 2017/11/7.
//

#import "TSVTabTipManager.h"
#import "TTSettingsManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTArticleCategoryManager.h"
#import "TTNetworkManager.h"
#import "AWEVideoDetailViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

#import "TTLocationManager.h"
#import "ArticleURLSetting.h"
#import "ListDataHeader.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVTabManager.h"
#import "TSVShortVideoDataFetchManagerProtocol.h"
#import "TTTabBarManager.h"
#import "TTTabBarProvider.h"

static NSString * const kTSVShouldNotifyTabRedDotWhenStartupKey = @"kTSVShouldNotifyTabTipWhenStartupKey";
static NSString * const kTSVRecentlyNotifyTabRedDotDateKey = @"kTSVRecentlyNotifyTabTipWhenStartupDateKey";
static NSString * const kTSVCurrentDayNotifyTabRedDotTimesKey = @"kTSVNotifyTabTipWhenStartupCountKey";
static NSInteger const kRedDotStrategyDefaultValue = 0;          // 策略默认值
static NSInteger const kPollIntervalDefaultValue = 7200;     // 策略1轮询间隔，单位s
static NSInteger const kTimeBeforeEnterTabDefaultValue = 300;  // 策略2启动后没有进入小视频tab时间，单位s
static NSInteger const kRedDotOneDayMaxTimesDefaultValue = 1;          // 策略2/3 每天最多展示次数

static NSString * const kTSVRecentlyShowBubbleTipDateKey = @"kTSVRecentlyShowBubbleTipDateKey";
static NSString * const kTSVAlreadyShowBubbleTipTimesKey = @"kTSVAlreadyShowBubbleTipTimesKey";
static NSString * const kTSVCurrentDayShowBubbleTipTimesKey = @"kTSVCurrentDayShowBubbleTipTimesKey";
static NSInteger const kBubbleTipStrategyDefaultValue = 0;  //气泡提示默认策略
static NSInteger const kBubbleTipMaxTimesDefaultValue = 1;  //气泡提示策略2最多展示次数
static NSString * const kBubbleTipTextDefaultValue = @"更多精彩小视频在这里";  //气泡提示文案

@interface TSVTabTipManager()

@property (nonatomic, assign) NSInteger numberForRedDot;
@property (nonatomic, assign) NSInteger styleForRedDot;
@property (nonatomic, assign) NSInteger strategyForRedDot;
@property (nonatomic, strong) NSTimer   *timerForPoll;
@property (nonatomic, strong) NSTimer   *timerForRecordingTimeBeforeEnterTab;
@property (nonatomic, assign) BOOL      hasEnterShortVideoTab;
@property (nonatomic, strong) NSDate    *appStartupTime;
@property (nonatomic, assign) BOOL      hasNotifyTabRedDot;
@property (nonatomic, assign) BOOL      shouldNotifyRedDotWhenStartup;
@property (nonatomic, assign) BOOL      videoDetailVisibility;

@property (nonatomic, assign) BOOL      enterDetailFromFeed;

@end

@implementation TSVTabTipManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static TSVTabTipManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TSVTabTipManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.strategyForRedDot = [self redDotStrategy];
        
        self.shouldNotifyRedDotWhenStartup = [[NSUserDefaults standardUserDefaults] boolForKey:kTSVShouldNotifyTabRedDotWhenStartupKey];
        
        self.appStartupTime = [NSDate date];
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil]
            takeUntil:self.rac_willDeallocSignal]
            subscribeNext:^(NSNotification * _Nullable x) {
                @strongify(self);
                [self stopTimerForPoll];
                [self stopTimerForRecordingTimeBeforeEnterTab];
            }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil]
            takeUntil:self.rac_willDeallocSignal]
            subscribeNext:^(NSNotification * _Nullable x) {
                @strongify(self);
                if (self.strategyForRedDot == 1) {
                    [self startTimerForPoll];
                } else if (self.strategyForRedDot ==2) {
                    [self startTimerForRecordingTimeBeforeEnterTab];
                }
            }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TSVVideoDetailVisibilityDidChangeNotification object:nil]
            takeUntil:self.rac_willDeallocSignal]
            subscribeNext:^(NSNotification * _Nullable notification) {
                @strongify(self);
                self.videoDetailVisibility = [notification.userInfo[TSVVideoDetailVisibilityDidChangeNotificationVisibilityKey] boolValue];
                
                if ([notification.userInfo objectForKey:TSVVideoDetailVisibilityDidChangeNotificationEntranceKey]) {
                    if ([notification.userInfo[TSVVideoDetailVisibilityDidChangeNotificationEntranceKey] integerValue]== TSVShortVideoListEntranceFeedCard) {
                        self.enterDetailFromFeed = YES;
                    } else {
                        self.enterDetailFromFeed = NO;
                    }
                }
            }];
        
        [RACObserve([TSVTabManager sharedManager], inShortVideoTab) subscribeNext:^(NSNumber *inShortVideoTab) {
            @strongify(self);
            self.hasEnterShortVideoTab = (self.hasEnterShortVideoTab || [inShortVideoTab boolValue]);
            
            if (self.hasEnterShortVideoTab) {
                [self stopTimerForRecordingTimeBeforeEnterTab];
            }
        }];
        
        [[[RACSignal combineLatest:@[RACObserve([TSVTabManager sharedManager], inShortVideoTab), RACObserve(self, videoDetailVisibility)]
                            reduce:^NSNumber *(NSNumber *inShortVideoTab, NSNumber *videoDetailVisibility) {
                                return @([inShortVideoTab boolValue] || [videoDetailVisibility boolValue]);
                            }]
                     distinctUntilChanged]
                     subscribeNext:^(NSNumber * value) {
                         [[NSUserDefaults standardUserDefaults] setBool:[value boolValue] forKey:kTSVShouldNotifyTabRedDotWhenStartupKey];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                     }];
    }
    return self;
}

#pragma mark - Public Method

- (void)setupShortVideoTabRedDotWhenStartupIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (self.strategyForRedDot == 1) {
            [self startTimerForPoll];
        } else if (self.strategyForRedDot == 2) {
            [self startTimerForRecordingTimeBeforeEnterTab];
        } else if (self.strategyForRedDot == 3) {
            [self notifyRedDotWhenStartup];
        }
    });
}

- (BOOL)isShowingRedDot
{
    return self.styleForRedDot != 0;
}

- (BOOL)shouldAutoReloadFromRemoteForCategory:(NSString *)categoryID listEntrance:(NSString *)listEntrance
{
    return self.styleForRedDot != 0 && [categoryID isEqualToString:kTTUGCVideoCategoryID] && [listEntrance isEqualToString:@"main_tab"];
}

- (NSDictionary *)extraCategoryListRequestParameters
{
    return @{
             @"refresh_tips_count" : @(self.numberForRedDot),
             @"refresh_tips_type" : @(self.styleForRedDot)
             };
}

- (void)clearRedDot
{
    if (![TTTabBarProvider isHTSTabOnTabBar]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{kExploreTabBarItemIndentifierKey:kTTTabHTSTabKey, kExploreTabBarBadgeNumberKey:@(0)}];
    
    self.styleForRedDot = 0;
    self.numberForRedDot = 0;
}

- (BOOL)shouldShowBubbleTip
{
    if ([[TSVTabManager sharedManager] isInShortVideoTab]) {
        return NO;
    }
    
    NSInteger bubbleTipStrategy = [self bubbleTipStrategy];
    if (bubbleTipStrategy == 1) {
        if (self.enterDetailFromFeed && [self timesForAlreadyShowBubbleTip] == 0) {
            return YES;
        }
    } else if (bubbleTipStrategy == 2) {
        if (self.enterDetailFromFeed && [self timesForCurrentDayShowBubbleTip] < 1 && [self timesForAlreadyShowBubbleTip] < [self maxTimesForShowBubbleTip]) {
            return YES;
        }
    }

    return NO;
}

- (NSString *)textForBubbleTip
{
    NSString *ret = [[self bubbleTipConfig] tt_stringValueForKey:@"tip_text"];
    
    if (isEmptyString(ret)) {
        return kBubbleTipTextDefaultValue;
    }
    
    return ret;
}

- (NSInteger)indexForBubbleTip
{
    return [[TSVTabManager sharedManager] indexOfShortVideoTab];
}

- (void)updateBubbleTipShownStatus
{
    [[NSUserDefaults standardUserDefaults] setInteger:[self timesForAlreadyShowBubbleTip] + 1 forKey:kTSVAlreadyShowBubbleTipTimesKey];
    [[NSUserDefaults standardUserDefaults] setInteger:[self timesForCurrentDayShowBubbleTip] + 1 forKey:kTSVCurrentDayShowBubbleTipTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kTSVRecentlyShowBubbleTipDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setShouldNotShowBubbleTip
{
    self.enterDetailFromFeed = NO;
}

#pragma mark - Strategy 1

- (void)startTimerForPoll
{
    [self stopTimerForPoll];
    
    self.timerForPoll = [NSTimer scheduledTimerWithTimeInterval:[self redDotPollInterval] target:self selector:@selector(fetchRedDot) userInfo:nil repeats:YES];
    [self.timerForPoll fire];
}

- (void)stopTimerForPoll
{
    if (self.timerForPoll) {
        [self.timerForPoll invalidate];
        self.timerForPoll = nil;
    }
}

#pragma mark - Strategy 2

- (void)startTimerForRecordingTimeBeforeEnterTab
{
    if (self.hasEnterShortVideoTab || self.hasNotifyTabRedDot) {
        return;
    }
    
    if ([self timesForCurrentDayShowRedDot] >= [self maxTimesForShowRedDotOneDay]) {
        return;
    }
    
    [self stopTimerForRecordingTimeBeforeEnterTab];
    
    NSTimeInterval appStartupInterval = [[NSDate date] timeIntervalSinceDate:self.appStartupTime];
    NSTimeInterval intervalBeforeEnterTab = [self redDotIntervalBeforeEnterTab];
    
    if (appStartupInterval >= intervalBeforeEnterTab) {
        [self fetchRedDot];
    } else {
        self.timerForRecordingTimeBeforeEnterTab = [NSTimer scheduledTimerWithTimeInterval:intervalBeforeEnterTab - appStartupInterval target:self selector:@selector(fetchRedDot) userInfo:nil repeats:NO];
    }
}

- (void)stopTimerForRecordingTimeBeforeEnterTab
{
    if (self.timerForRecordingTimeBeforeEnterTab) {
        [self.timerForRecordingTimeBeforeEnterTab invalidate];
        self.timerForRecordingTimeBeforeEnterTab = nil;
    }
}

#pragma mark - Strategy 3

- (void)notifyRedDotWhenStartup
{
    if (self.shouldNotifyRedDotWhenStartup && !self.hasEnterShortVideoTab && [self timesForCurrentDayShowRedDot] < [self maxTimesForShowRedDotOneDay]) {
        [self fetchRedDot];
    }
}

#pragma mark -

- (void)fetchRedDot
{
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    [queryDict setValue:kTTUGCVideoCategoryID forKey:@"categoryID"];
    [queryDict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
    [queryDict setValue:@(ExploreOrderedDataListLocationCategory) forKey:@"listLocation"];
    
    NSArray *items = [ExploreOrderedData objectsWithQuery:queryDict
                                                  orderBy:@"orderIndex DESC"
                                                   offset:0
                                                    limit:1];
    
    NSTimeInterval minBehotTime = 0;
    if ([items.firstObject isKindOfClass:[ExploreOrderedData class]]) {
        minBehotTime = [(ExploreOrderedData *)items.firstObject behotTime];
    } else {
        minBehotTime = ([[NSDate date] timeIntervalSinceNow] - 5.f * 24.f * 60.f * 60.f) * 1000;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@(minBehotTime) forKey:@"min_behot_time"];
    [params setValue:kTTUGCVideoCategoryID forKey:@"category"];
    [params setValue:@(ListDataDefaultRemoteNormalLoadCount) forKey:@"count"];
    
    TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
    if (newsLocalCategory) {
        if ([TTArticleCategoryManager isUserSelectedLocalCity]) {
            [params setValue:newsLocalCategory.name forKey:@"user_city"];
        }
    }
    NSString *city = [TTLocationManager sharedManager].city;
    [params setValue:city forKey:@"city"];
    
    @weakify(self);
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting refreshTipURLString]
                                                     params:params
                                                     method:@"GET"
                                           needCommonParams:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       @strongify(self);
                                                       if (!error) {
                                                           if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                                                               NSDictionary * data = [jsonObj tt_dictionaryValueForKey:@"data"];
                                                               if (data) {
                                                                   [self notifyRedDotWithData:data];
                                                               }
                                                           }
                                                       }
                                                   }];
}


- (void)notifyRedDotWithData:(NSDictionary *)data
{
    if ([TSVTabManager sharedManager].isInShortVideoTab) {
        return;
    }
    
    if ((self.strategyForRedDot == 2 || self.strategyForRedDot == 3) && self.hasEnterShortVideoTab) {
        return;
    }
    
    if (![TTTabBarProvider isHTSTabOnTabBar]) {
        return;
    }
    
    NSInteger tipNumber = [data tt_unsignedIntegerValueForKey:@"count"];
    
    if (tipNumber < 0) {
        return;
    }
    
    self.numberForRedDot = tipNumber;
    self.styleForRedDot = [data tt_unsignedIntegerValueForKey:@"show_type"];
    
    if (self.styleForRedDot == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{
                                                                                                                                     kExploreTabBarItemIndentifierKey:kTTTabHTSTabKey, kExploreTabBarDisplayRedPointKey:@(YES)}
         ];
    } else if (self.styleForRedDot == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeExploreTabBarBadgeNumberNotification object:nil userInfo:@{
                                                                                                                                     kExploreTabBarItemIndentifierKey:kTTTabHTSTabKey,
                                                                                                                                kExploreTabBarBadgeNumberKey:@(self.numberForRedDot)}
         ];
    }
    
    self.hasNotifyTabRedDot = YES;
    
    [[NSUserDefaults standardUserDefaults] setInteger:[self timesForCurrentDayShowRedDot] + 1 forKey:kTSVCurrentDayNotifyTabRedDotTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kTSVRecentlyNotifyTabRedDotDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Utils

- (NSInteger)timesForCurrentDayShowRedDot
{
    if ([self isSameDay:[self dateForRecentlyShowRedDot] date2:[NSDate date]]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:kTSVCurrentDayNotifyTabRedDotTimesKey];
    } else {
        return 0;
    }
}

- (NSDate *)dateForRecentlyShowRedDot
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTSVRecentlyNotifyTabRedDotDateKey];
}

- (NSInteger)timesForCurrentDayShowBubbleTip
{
    if ([self isSameDay:[self dateForRecentlyShowBubbleTip] date2:[NSDate date]]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:kTSVCurrentDayShowBubbleTipTimesKey];;
    } else {
        return 0;
    }
}

- (NSDate *)dateForRecentlyShowBubbleTip
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTSVRecentlyShowBubbleTipDateKey];
}

- (NSInteger)timesForAlreadyShowBubbleTip
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kTSVAlreadyShowBubbleTipTimesKey];
}

- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
}

#pragma mark - Tip Config

- (NSDictionary *)redDotConfig
{
    return (NSDictionary *)[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_tab_tips_config" defaultValue:@{
                                                                                                                        @"strategy"         : @(kRedDotStrategyDefaultValue),
                                                                                                                        @"poll_interval"    : @(kPollIntervalDefaultValue),
                                                                                                                        @"startup_interval" : @(kTimeBeforeEnterTabDefaultValue),
                                                                                                                        @"max_count"        : @(kRedDotOneDayMaxTimesDefaultValue)
                                                                                                                        } freeze:YES];
}

- (NSInteger)redDotStrategy
{
    if ([[TSVTabManager sharedManager] indexOfShortVideoTab] == NSNotFound) {
        return 0;
    }
    
    NSInteger ret = [[self redDotConfig] tt_integerValueForKey:@"strategy"];
    
    if (ret < 0 || ret > 3) {
        return kRedDotStrategyDefaultValue;
    }
    
    return ret;
}

- (NSInteger)redDotPollInterval
{
    NSInteger ret = [[self redDotConfig] tt_integerValueForKey:@"poll_interval"];
    
    if (ret <= 60) {
        return kPollIntervalDefaultValue;
    }
    
    return ret;
}

- (NSInteger)redDotIntervalBeforeEnterTab
{
    NSInteger ret = [[self redDotConfig] tt_integerValueForKey:@"startup_interval"];
    
    if (ret < 0) {
        return kTimeBeforeEnterTabDefaultValue;
    }
    
    return ret;
}

- (NSInteger)maxTimesForShowRedDotOneDay
{
    NSInteger ret = [[self redDotConfig] tt_integerValueForKey:@"max_count"];
    
    if (ret < 0) {
        return kRedDotOneDayMaxTimesDefaultValue;
    }
    
    return ret;
}

- (NSDictionary *)bubbleTipConfig
{
    return (NSDictionary *)[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_tab_bubbletip_config" defaultValue:@{
                                                                                                                               @"strategy"         : @(kBubbleTipStrategyDefaultValue),
                                                                                                                               @"max_count"        : @(kBubbleTipMaxTimesDefaultValue),
                                                                                                                               @"tip_text"  :
                                                                                                                          kBubbleTipTextDefaultValue
                                                                                                                               } freeze:NO];
}

- (NSInteger)bubbleTipStrategy
{
    if ([[TSVTabManager sharedManager] indexOfShortVideoTab] == NSNotFound) {
        return 0;
    }
    
    NSInteger ret = [[self bubbleTipConfig] tt_integerValueForKey:@"strategy"];
    
    if (ret < 0 || ret > 2) {
        return kBubbleTipStrategyDefaultValue;
    }
    
    return ret;
}

- (NSInteger)maxTimesForShowBubbleTip
{
    NSInteger ret = [[self bubbleTipConfig] tt_integerValueForKey:@"max_count"];
    
    if (ret < 0) {
        return kBubbleTipMaxTimesDefaultValue;
    }
    
    return ret;
}

@end
