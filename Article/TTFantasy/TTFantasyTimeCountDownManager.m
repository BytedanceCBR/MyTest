//
//  TTFantasyTimeCountDownManager.m
//  Article
//
//  Created by chenren on 2018/01/18.
//

#import "TTFantasyTimeCountDownManager.h"
#import "TTNetworkManager.h"
#import "VideoSettings.pbobjc.h"
#import "ArticleURLSetting.h"

@interface TTFantasyTimeCountDownManager()

@property(nonatomic, strong) dispatch_source_t silentFetchTimer;
@property(nonatomic, readwrite, strong) NSMutableArray<TTVMillionHeroSettings_SingleActivity*> *activityListArray;
@property(nonatomic, assign) BOOL isInBackground;
@property(nonatomic, assign) NSTimeInterval currentActivityTime;
@property (nonatomic, strong) NSMutableArray *times;

@end

@implementation TTFantasyTimeCountDownManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TTFantasyTimeCountDownManager * sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        //[sharedManager fetchFantasyActivityTimes];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addAppRuntimeObservers];
        self.currentActivityTime = 0;
        
        _times = [NSMutableArray new];
        NSArray *times = [[NSUserDefaults standardUserDefaults] valueForKey:@"kFantasyTimeCountDown"];
        if (times) {
            [_times addObjectsFromArray:times];
        }
    }
    return self;
}

- (void)fetchFantasyActivityTimes
{
    NSMutableDictionary *para = [NSMutableDictionary new];
    [para setValue:@"pb" forKey:@"format"];
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:[ArticleURLSetting videoSettingURLString] params:para method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        TTVVideoSettingsResponse *response = [TTVVideoSettingsResponse parseFromData:obj error:&error];
        TTVMillionHeroSettings *heroSettings = response.heroSettings;
        self.activityListArray =  heroSettings.activityListArray;
        [self setupSilentFetchTimer];
    }];
}

- (void)updateMillionHeroActivity:(NSArray *)activityListArray
{
}

- (void)updateTimerAction
{
}

- (BOOL)isShowingTime
{
    NSTimeInterval currentUnixTime = [[NSDate date] timeIntervalSince1970];
    BOOL result = NO;
    for (int i = 0; i < self.times.count; ++i) {
        double activityTime = [[self.times objectAtIndex:i] doubleValue];
        if (currentUnixTime >= (activityTime - 60) && currentUnixTime < (activityTime + 60 * 30)) {
            //result = YES;
            return YES;
            //break;
        }
    }
    
    for (int i = 0; i < self.activityListArray.count; ++i) {
        TTVMillionHeroSettings_SingleActivity *activity = [self.activityListArray objectAtIndex:i];
        if (currentUnixTime >= (activity.startTime - 60) && currentUnixTime < (activity.startTime + 60 * 30)) {
            return YES;
            //break;
        }
    }
    
    return result;
}

- (NSTimeInterval)nextActivityTime
{
    NSTimeInterval currentUnixTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval result = 0;
    for (int i = 0; i < self.activityListArray.count; ++i) {
        TTVMillionHeroSettings_SingleActivity *activity = [self.activityListArray objectAtIndex:i];
        if (currentUnixTime < activity.startTime && activity.startTime != self.currentActivityTime && activity.startTime > self.currentActivityTime) {
            result = activity.startTime;
            break;
        }
    }
    
    return result;
}

- (BOOL)setupSilentFetchTimer
{
    for (int i = 0; i < self.activityListArray.count; ++i) {
        TTVMillionHeroSettings_SingleActivity *activity = [self.activityListArray objectAtIndex:i];
        if ([self.times indexOfObject:@(activity.startTime)] == NSNotFound) {
            [self.times addObject:@(activity.startTime)];
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:self.times forKey:@"kFantasyTimeCountDown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSTimeInterval currentUnixTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval nextActivityTime = [self nextActivityTime];
    if (currentUnixTime > nextActivityTime) {
        return NO;
    }
    
    self.silentFetchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    NSTimeInterval time = nextActivityTime - currentUnixTime - 60;//- 5 * 60 * 60 - 15 *60;
//    if (time < 0 && nextActivityTime > currentUnixTime) {
//        time = 0;
//    }
    NSTimeInterval waitTime = time / 60.;
    CGFloat progress = 0.0;
    if (time < 0 && nextActivityTime - currentUnixTime < 60 && nextActivityTime > currentUnixTime) {
        NSTimeInterval min = (nextActivityTime - currentUnixTime) / 60.;
        progress = 1 - min;
        time = 0;
    }
    
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    
    dispatch_source_set_timer(self.silentFetchTimer, startDelayTime, 70 * NSEC_PER_SEC, 0);
    
    //dispatch_source_set_timer(self.silentFetchTimer, dispatch_walltime(NULL, 0), 10 * NSEC_PER_SEC, 0);
    WeakSelf;
    dispatch_source_set_event_handler(self.silentFetchTimer, ^{
        StrongSelf;
        // dosomething
        self.currentActivityTime = nextActivityTime;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFantasyTimeCountDown" object:@"" userInfo:@{@"progress": @(progress)}];
        dispatch_source_cancel(self.silentFetchTimer);
        
    });
    dispatch_source_set_cancel_handler(self.silentFetchTimer, ^{
        StrongSelf;
        self.silentFetchTimer = nil;
        
        if (!self.isInBackground) {
            [self setupSilentFetchTimer];
        }
    });
    dispatch_resume(self.silentFetchTimer);
    
    return YES;
}

- (void)addAppRuntimeObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAppDidEnterBackground:(NSNotification *)notification
{
    _isInBackground = YES;
    if (self.silentFetchTimer) {
        dispatch_source_cancel(self.silentFetchTimer);
        self.silentFetchTimer = nil;
    }
    self.currentActivityTime = 0;
}

- (void)onAppWillEnterForeground:(NSNotification *)notification
{
    _isInBackground = NO;
    BOOL success = [self setupSilentFetchTimer];
    if (!success) {
        NSMutableDictionary *para = [NSMutableDictionary new];
        [para setValue:@"pb" forKey:@"format"];
        [[TTNetworkManager shareInstance] requestForBinaryWithURL:[ArticleURLSetting videoSettingURLString] params:para method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
            TTVVideoSettingsResponse *response = [TTVVideoSettingsResponse parseFromData:obj error:&error];
            TTVMillionHeroSettings *heroSettings = response.heroSettings;
            self.activityListArray =  heroSettings.activityListArray;
            
            [self setupSilentFetchTimer];
        }];
    }
}

@end
