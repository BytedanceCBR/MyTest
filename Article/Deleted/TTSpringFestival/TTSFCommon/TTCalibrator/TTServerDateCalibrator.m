//
//  TTServerDateCalibrator.m
//  Article
//
//  Created by 冯靖君 on 2017/11/23.
//  云端时间校准器, 支持定时触发本地任务

#import "TTServerDateCalibrator.h"
#import <TTPersistence/TTPersistence.h>
#import <sys/sysctl.h>
#import <sys/types.h>

//#import "TTSFRedPackageConfig.h"

static NSString *const kLocalOnDateTriggerTaskPath = @"trigger/task"; //任务存储路径
static NSString *const kAllTasksKey = @"kAllTasksKey"; //任务持久化信息
static NSString *const kTriggerdOnceKey = @"kTriggerdOnceKey"; //已执行且只能执行一次的任务

static NSString *const kTriggerDateKey = @"kTriggerDateKey"; //任务触发时间
static NSString *const kExpireDateKey = @"kExpireDateKey";   //任务过期时间
static NSString *const kPersistentKey = @"kPersistentKey";   //任务是否持久化
static NSString *const kTaskExtraKey = @"kTaskExtraKey";     //任务业务上下文



static inline time_t systemBootTime()
{
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0)
    {
        return boottime.tv_sec;
    }
    return 0;
}

@interface TTServerDateCalibrator ()

@property (nonatomic, assign) NSTimeInterval serverTimeInterval;
@property (nonatomic, strong) NSDate *lastCalibrateDate;
@property (nonatomic, strong) dispatch_source_t dispatchTimer;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
// 存储任务基本信息。key为任务类名，value包含触发时间、过期时间、业务上下文等。用于持久化
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSDictionary *> *taskMetaDict;
// 存储任务实例。key为任务类名，value为任务对象。任务触发后即移除
@property (nonatomic, strong) NSMutableDictionary <NSString *, id<TTOnDateTaskTrigger>> *taskDict;
// 存储只能执行一次且已经执行的任务
@property (nonatomic, strong) NSMutableArray <NSString *> *triggeredOnceTaskArray;

@property (nonatomic, assign) time_t cachedSystemBootTime;
@property (nonatomic, assign) NSTimeInterval cachedLocalTime;
@property (nonatomic, assign) NSTimeInterval cachedServerTime;
@property (nonatomic, assign) BOOL isTimerRunning;

@property (nonatomic, strong) TTPersistence *persistence;


@end

@implementation TTServerDateCalibrator

static TTServerDateCalibrator *_calibrator;

+ (void)load
{
    [TTServerDateCalibrator sharedCalibrator];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_dispatchTimer) {
        dispatch_source_cancel(_dispatchTimer);
    }
}

+ (instancetype)sharedCalibrator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _calibrator = [[TTServerDateCalibrator alloc] init];
    });
    return _calibrator;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _calibrator = [super allocWithZone:zone];
    });
    return _calibrator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addAppRuntimeObservers];
        
        _lastCalibrateDate = [NSDate dateWithTimeIntervalSince1970:0];
        _serverTimeInterval = 0;
        [self initTasks];
    }
    return self;
}

- (void)initTasks
{
    dispatch_async(self.dispatchQueue, ^{
        //创建任务信息
        NSDictionary *persistenceTaskMetaDict = [self.persistence valueForKey:kAllTasksKey];
        if (persistenceTaskMetaDict && [persistenceTaskMetaDict isKindOfClass:[NSDictionary class]] && persistenceTaskMetaDict.count > 0) {
            // 读取本地持久化数据
            _taskMetaDict = [persistenceTaskMetaDict mutableCopy];
        } else {
            _taskMetaDict = [NSMutableDictionary dictionary];
        }
        
        NSArray *persistenceTriggeredOnceArray = [self.persistence valueForKey:kTriggerdOnceKey];
        if (persistenceTriggeredOnceArray && [persistenceTriggeredOnceArray isKindOfClass:[NSArray class]] && persistenceTriggeredOnceArray.count > 0) {
            _triggeredOnceTaskArray = [persistenceTriggeredOnceArray mutableCopy];
        } else {
            _triggeredOnceTaskArray = [NSMutableArray array];
        }
        
        //创建任务实例
        _taskDict = [NSMutableDictionary dictionary];
        NSDictionary <NSString *, NSDictionary *> *copyTaskMetaDict = [_taskMetaDict copy];
        [copyTaskMetaDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, NSDictionary * _Nonnull taskMeta, BOOL * _Nonnull stop) {
            Class class = NSClassFromString(className);
            id <TTOnDateTaskTrigger> task = [class instancesRespondToSelector:@selector(initWithDictionary:)] ? [[class alloc] initWithDictionary:taskMeta] : [[class alloc] init];
            [_taskDict setValue:task forKey:className];
        }];
    });
}

#pragma mark - public

- (BOOL)isAvailable
{
    return _serverTimeInterval > 0;
}

- (NSDate *)accurateCurrentServerDate
{
    return [self isAvailable] ? [TTServerDateCalibrator dateWithTimeInterval:self.serverTimeInterval] : nil;
}

- (void)calibrateLocalDateWithServerTimeInterval:(NSTimeInterval)serverTimeInterval
{
    dispatch_async(self.dispatchQueue, ^{
        NSDate *currentDate = [NSDate date];

        self.lastCalibrateDate = currentDate;
        self.serverTimeInterval = serverTimeInterval;
        
        // 触发计时器，计算两次校准之间的时钟
        [self scheduleDispatchTimer];
    });
}

#pragma mark - private

- (TTPersistence *)persistence
{
    if (!_persistence) {
        TTPersistenceOption *customOption = [[TTPersistenceOption alloc] init];
        customOption.shouldRemoveAllObjectsWhenEnteringBackground = NO;
        customOption.shouldRemoveAllObjectsOnMemoryWarning = NO;
        _persistence = [TTPersistence persistenceWithName:kLocalOnDateTriggerTaskPath option:customOption];
    }
    return _persistence;
}

- (dispatch_queue_t)dispatchQueue
{
    if (!_dispatchQueue) {
        _dispatchQueue = dispatch_queue_create("com.bytedance.serverdate.calibrator", DISPATCH_QUEUE_SERIAL);
    }
    return _dispatchQueue;
}

- (void)scheduleDispatchTimer
{
    if (!self.dispatchTimer) {
        self.dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.dispatchQueue);
        dispatch_source_set_timer(self.dispatchTimer, dispatch_walltime(NULL, 0), TTDispatchTimerUpdateInterval * NSEC_PER_SEC, 0);
        WeakSelf;
        dispatch_source_set_event_handler(self.dispatchTimer, ^{
            StrongSelf;
            self.serverTimeInterval += TTDispatchTimerUpdateInterval;
                        /////
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//            
//            NSLog(@"current schedule date is %@", [formatter stringFromDate:[self accurateCurrentServerDate]]);
                        /////
            
            //触发所有满足条件的定时任务
            [self triggerOnDateTaskIfNeed];
//            TTSFRedPackageTipModel *model = [TTSFRedPackageConfig curActivityInfo];
//            if (model) {
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                formatter.dateFormat = @"HH:mm:ssZ";
//                NSLog(@"next activity date : %@    state:%@   interval:%lld\n", [formatter stringFromDate:[TTSFRedPackageConfig nextActivityStartDate]] , [self.class stateDescByState:model.state], model.interval);
//            } else {
//                NSLog(@"no redpacket config information");
//            }
        });
        dispatch_source_set_cancel_handler(self.dispatchTimer, ^{
            StrongSelf;
            self.dispatchTimer = nil;
        });
        
        dispatch_resume(self.dispatchTimer);
        self.isTimerRunning = YES;
    }
}

//+ (NSString *)stateDescByState:(TTSFRedPackageState)state
//{
//    switch (state) {
//        case TTSFRedPackageStatePreheat:
//            return @"preheat";
//            break;
//        case TTSFRedPackageStateCountDown:
//            return @"countDown";
//            break;
//        case TTSFRedPackageStateInActivity:
//            return @"inActivity";
//            break;
//        case TTSFRedPackageStateNextActivityPreheat:
//            return @"next_preheat";
//            break;
//        case TTSFRedPackageStateFinish:
//            return @"finish";
//            break;
//        default:
//            break;
//    }
//}

- (void)triggerOnDateTaskIfNeed
{
    // 加个保护，为0时表示尚未成功校准
    if (self.serverTimeInterval == 0) {
        return;
    }
    
    NSDictionary *checkTaskMetaDict = [self.taskMetaDict copy];
    NSDictionary *checkTaskDict = [self.taskDict copy];
    // 任务信息有变更则必须存储
    __block BOOL shouldPersistentNow = NO;
    [checkTaskMetaDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, NSDictionary * _Nonnull taskMeta, BOOL * _Nonnull stop) {
        id<TTOnDateTaskTrigger> task = [checkTaskDict objectForKey:className];
        
        // 任务时钟判断
        NSDate *taskTriggerDate = ([task respondsToSelector:@selector(triggerDate)] && [task triggerDate]) ? [task triggerDate] : [taskMeta objectForKey:kTriggerDateKey];
        NSDate *taskExpireDate = ([task respondsToSelector:@selector(expireDate)] && [task expireDate]) ? [task expireDate] : [taskMeta objectForKey:kExpireDateKey];
        BOOL taskReachDate = [taskTriggerDate timeIntervalSinceDate:[TTServerDateCalibrator dateWithTimeInterval:self.serverTimeInterval]] <= 0;
        BOOL taskExpired = taskExpireDate && [taskExpireDate timeIntervalSinceDate:[TTServerDateCalibrator dateWithTimeInterval:self.serverTimeInterval]] <= 0;
        
        // 如果任务时钟设置有变化则更新
        if ((taskTriggerDate && ![taskTriggerDate isEqualToDate:[taskMeta objectForKey:kTriggerDateKey]]) || (taskExpireDate && ![taskExpireDate isEqualToDate:[taskMeta objectForKey:kExpireDateKey]])) {
            NSMutableDictionary *updateTaskMeta = [NSMutableDictionary dictionaryWithDictionary:taskMeta];
            [updateTaskMeta setValue:taskTriggerDate forKey:kTriggerDateKey];
            [updateTaskMeta setValue:taskExpireDate forKey:kExpireDateKey];
            [self.taskMetaDict setValue:[updateTaskMeta copy] forKey:className];
            shouldPersistentNow = YES;
        }
        
        // 是否为只能执行一次的任务且已执行
        BOOL triggeredOnce = [task respondsToSelector:@selector(triggerOnce)] && [task triggerOnce] && [self.triggeredOnceTaskArray containsObject:className];
        
        // 如果重新设置为可重复执行，则删除标记
        if ([task respondsToSelector:@selector(triggerOnce)] && ![task triggerOnce] && [self.triggeredOnceTaskArray containsObject:className]) {
            [self.triggeredOnceTaskArray removeObject:className];
            shouldPersistentNow = YES;
        }
        
        // 到达时钟，未过期，业务条件满足，不是唯一执行，才可在本次检查执行
        if (taskReachDate && !taskExpired && !triggeredOnce) {
            // 业务层触发条件是否满足。到时间再判断业务条件，提高效率
            BOOL shouldTrigger = [task respondsToSelector:@selector(shouldTrigger)] ? [task shouldTrigger] : YES;
            if (shouldTrigger) {
                if ([task respondsToSelector:@selector(didTriggerWithTaskInfo:)]) {
                    NSMutableDictionary *taskInfo = [NSMutableDictionary dictionary];
                    NSTimeInterval passedInterval = (int64_t)[[TTServerDateCalibrator dateWithTimeInterval:self.serverTimeInterval] timeIntervalSinceDate:taskTriggerDate];
                    [taskInfo setValue:@(passedInterval) forKey:TTTriggeredTaskPassedIntervalKey];
                    [task didTriggerWithTaskInfo:taskInfo];
                }
                
                // 记录只能执行一次的任务
                if ([task respondsToSelector:@selector(triggerOnce)] && [task triggerOnce]) {
                    [self.triggeredOnceTaskArray addObject:className];
                }
                
                //执行完则移除任务
                [TTServerDateCalibrator unregisterTriggerTask:NSClassFromString(className)];
                shouldPersistentNow = YES;
            }
        }
    }];
    
    //存储任务
    if (shouldPersistentNow) {
        [self _saveTriggerTaskIntoPersistence];
    } else {
        [self saveTriggerTaskIntoPersistencePoll];
    }
}

- (void)saveTriggerTaskIntoPersistencePoll
{
    if ((int64_t)self.serverTimeInterval % TTTriggerTasksPersistenceMinTimeInterval == 0) {
        [self _saveTriggerTaskIntoPersistence];
    }
}

- (void)_saveTriggerTaskIntoPersistence
{
    // 任务持久化
    NSMutableDictionary *persistentTaskMetaDict = [NSMutableDictionary dictionary];
    NSDictionary *checkMetaDict = [_taskMetaDict copy];
    NSArray *triggeredOnceArray = [_triggeredOnceTaskArray copy];
    [checkMetaDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull className, NSDictionary * _Nonnull taskMeta, BOOL * _Nonnull stop) {
        if ([[taskMeta objectForKey:kPersistentKey] boolValue] && ![triggeredOnceArray containsObject:className]) {
            NSMutableDictionary *availableTaskMeta = [NSMutableDictionary dictionary];
            [taskMeta enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj conformsToProtocol:@protocol(NSCoding)] || [obj conformsToProtocol:@protocol(NSSecureCoding)]) {
                    [availableTaskMeta setValue:obj forKey:key];
                }
            }];
            [persistentTaskMetaDict setValue:[availableTaskMeta copy] forKey:className];
        }
    }];
    
    [self.persistence setValue:[persistentTaskMetaDict copy] forKey:kAllTasksKey];
    [self.persistence setValue:[self.triggeredOnceTaskArray copy] forKey:kTriggerdOnceKey];
    [self.persistence save];
}

- (void)addAppRuntimeObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)onAppDidEnterBackground:(NSNotification *)notification
{
    WeakSelf;
    dispatch_async(self.dispatchQueue, ^{
        StrongSelf;
        
        self.cachedSystemBootTime = systemBootTime();
        self.cachedLocalTime = [[NSDate date] timeIntervalSince1970];
        self.cachedServerTime = self.serverTimeInterval;
        
//         取到系统启动时间才存在校准的可能性
        if (self.cachedSystemBootTime > 0 && self.dispatchTimer && self.isTimerRunning) {
            dispatch_suspend(self.dispatchTimer);
            self.isTimerRunning = NO;
        }
        
        [self _saveTriggerTaskIntoPersistence];
    });
}

- (void)onAppWillEnterForeground:(NSNotification *)notification
{
    WeakSelf;
    dispatch_async(self.dispatchQueue, ^{
        StrongSelf;
        // cachedSystemBootTime 大于 0，说明是从后台进前台，而非进程启动，进行一次校准
        if (self.cachedSystemBootTime > 0) {
            // 系统启动时间戳 t1, 进后台时的本地时间戳 t2, 云端 ts2, 按此时间设置下再进前台的本地时间戳 t3，云端 ts3
            // 进前台时，实际取到的本地时间戳 t3'， 以及此时取得的系统启动时间戳 t1'，存在以下关系
            // t3' - t1' = t3 - t1 (只要机器不重启，系统启动时长确定)
            // ts3 - ts2 = t3 - t2 (不论云端还是本地，在后台的时长相同)
            // 综合上述两式，得到
            // ts3 = ts2 + t3' - t1' + t1 - t2
            time_t currentSystemBootTime = systemBootTime();
            NSTimeInterval currentLocalTime = [[NSDate date] timeIntervalSince1970] - (NSTimeInterval)currentSystemBootTime + (NSTimeInterval)self.cachedSystemBootTime;
            NSTimeInterval durationOnBackground = MAX(currentLocalTime - self.cachedLocalTime, 0);
            NSTimeInterval currentServerTime = self.cachedServerTime += durationOnBackground;

            self.serverTimeInterval = currentServerTime;

            if (self.dispatchTimer && !self.isTimerRunning) {
                dispatch_resume(self.dispatchTimer);
                self.isTimerRunning = YES;
            }
        }
    });
}

@end

@implementation TTServerDateCalibrator (OnDateTaskTrigger)

+ (void)registerTriggerTask:(Class<TTOnDateTaskTrigger>)taskClass
                     onDate:(NSDate *)triggerDate
                 expireDate:(NSDate *)expireDate
           shouldPersistent:(BOOL)persistent
                      extra:(NSDictionary *)extra
{
    NSAssert([taskClass conformsToProtocol:@protocol(TTOnDateTaskTrigger)], @"register task class must conform to specific protocol");
    NSAssert(triggerDate != nil, @"task trigger date can not be nil");
    
    TTServerDateCalibrator *calibrator = [TTServerDateCalibrator sharedCalibrator];
    dispatch_async(calibrator.dispatchQueue, ^{
        NSString *taskClassString = NSStringFromClass(taskClass);
        BOOL taskExist = [calibrator.taskDict.allKeys containsObject:taskClassString];
        //任务实例已存在则更新meta信息，否则创建
        if (!taskExist) {
            id <TTOnDateTaskTrigger> task = [(Class)taskClass instancesRespondToSelector:@selector(initWithDictionary:)] ? [[(Class)taskClass alloc] initWithDictionary:extra] : [[(Class)taskClass alloc] init];
            [calibrator.taskDict setValue:task forKey:taskClassString];
            [calibrator.taskMetaDict setValue:({
                NSMutableDictionary *innerExtra = [NSMutableDictionary dictionaryWithDictionary:extra];
                [innerExtra setValue:triggerDate forKey:kTriggerDateKey];
                [innerExtra setValue:expireDate forKey:kExpireDateKey];
                [innerExtra setValue:@(persistent) forKey:kPersistentKey];
                [innerExtra setValue:extra forKey:kTaskExtraKey];
                [innerExtra copy];
            }) forKey:taskClassString];
        } else {
            NSMutableDictionary *taskMeta = [[calibrator.taskMetaDict objectForKey:taskClassString] mutableCopy];
            [taskMeta setValue:triggerDate forKey:kTriggerDateKey];
            [taskMeta setValue:expireDate forKey:kExpireDateKey];
            [taskMeta setValue:@(persistent) forKey:kPersistentKey];
            [taskMeta setValue:extra forKey:kTaskExtraKey];
            [calibrator.taskMetaDict setValue:[taskMeta copy] forKey:taskClassString];
        }
        //更新任务信息
        if (persistent) {
            [calibrator _saveTriggerTaskIntoPersistence];
        }
    });
}

+ (void)unregisterTriggerTask:(Class<TTOnDateTaskTrigger>)taskClass
{
    NSAssert(taskClass != nil, @"unregister class can not be nil");
    TTServerDateCalibrator *calibrator = [TTServerDateCalibrator sharedCalibrator];
    dispatch_async(calibrator.dispatchQueue, ^{
        NSString *taskClassString = NSStringFromClass(taskClass);
        BOOL taskExist = [calibrator.taskMetaDict.allKeys containsObject:taskClassString];
        if (taskExist) {
            [calibrator.taskMetaDict removeObjectForKey:taskClassString];
            [calibrator.taskDict removeObjectForKey:taskClassString];
        }
    });
}

@end

@implementation TTServerDateCalibrator (Helper)

+ (NSDate *)dateWithString:(NSString *)dateString
{
    return [self dateWithString:dateString formatterString:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

+ (NSDate *)dateWithString:(NSString *)dateString formatterString:(NSString *)formatterString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = formatterString;
    NSDate *date = [formatter dateFromString:dateString];
    return date;
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate:date];
//    return [date dateByAddingTimeInterval:interval];
}

+ (NSDate *)dateWithTimeInterval:(NSTimeInterval)interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return date;
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger addInterval = [zone secondsFromGMTForDate:date];
//    return [date dateByAddingTimeInterval:addInterval];
}

@end
