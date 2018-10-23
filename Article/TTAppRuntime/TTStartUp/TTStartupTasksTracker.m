//
//  TTStartupTasksTracker.m
//  Article
//
//  Created by xushuangqing on 2017/5/9.
//
//

#import "TTStartupTasksTracker.h"
#import "TTMonitorStartupTask.h"
#import "TTMonitor.h"

@implementation TTOneDevLog

@end

@interface TTStartupTasksTracker ()
{
    dispatch_queue_t _startupTasksTrackQueue;
}

@property (nonatomic, strong) NSMutableDictionary *tasksIntervalDic;
@property (nonatomic, strong) NSMutableDictionary *tasksIntervalDicInThread;

@property (nonatomic, strong) NSMutableArray<TTOneDevLog *> *cachedDevLogs;

@end

@implementation TTStartupTasksTracker

+ (instancetype)sharedTracker {
    static TTStartupTasksTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracker = [[TTStartupTasksTracker alloc] init];
    });
    return sharedTracker;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _startupTasksTrackQueue = dispatch_queue_create("com.bytdance.startuptasks.tracker", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debugrealInitializedNotification) name:TTDebugrealInitializedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)debugrealInitializedNotification {
    WeakSelf;
    dispatch_async(_startupTasksTrackQueue, ^{
        StrongSelf;
        if (self.cachedDevLogs && [self.cachedDevLogs count] > 0) {
            [self.cachedDevLogs enumerateObjectsUsingBlock:^(TTOneDevLog * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *storeID = [TTDebugRealMonitorManager cacheDevLogWithEventName:obj.eventName params:obj.params];
                obj.storeID = storeID;
            }];
        }
        [self.cachedDevLogs removeAllObjects];
    });
}

- (void)trackStartupTaskInItsThread:(NSString *)taskTag withInterval:(double)interval {
    if (isEmptyString(taskTag)) {
        return;
    }
    
    dispatch_async(_startupTasksTrackQueue, ^{
        if (!self.tasksIntervalDicInThread) {
            self.tasksIntervalDicInThread = [[NSMutableDictionary alloc] init];
        }
        
        [self.tasksIntervalDicInThread setValue:@(interval) forKey:taskTag];
    });
}

- (void)trackStartupTaskInMainThread:(NSString *)taskTag withInterval:(double)interval {
    if (isEmptyString(taskTag)) {
        return;
    }
    
    if (!self.tasksIntervalDic) {
        self.tasksIntervalDic = [[NSMutableDictionary alloc] init];
    }
    
    [self.tasksIntervalDic setValue:@(interval) forKey:taskTag];
}

- (void)removeInitializeDevLog:(TTOneDevLog *)devLog {
    if (!isEmptyString(devLog.storeID)) { //有storeID，说明是已经存入db
        [TTDebugRealMonitorManager removeEventById:devLog.storeID];
    }
    else { //还没存入db
        dispatch_async(_startupTasksTrackQueue, ^{
            if (!isEmptyString(devLog.storeID)) { //有storeID，说明是已经存入db
                [TTDebugRealMonitorManager removeEventById:devLog.storeID];
            }
            else { //还没存入db
                [self.cachedDevLogs removeObject:devLog];
            }
        });
    }
}

- (TTOneDevLog *)cacheInitializeDevLog:(NSString *)eventName params:(NSDictionary *)params {
    NSMutableDictionary *fixedParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    [fixedParams setValue:@([[NSDate date] timeIntervalSince1970]) forKey:@"origin_date"];
    
    TTOneDevLog *devLog = [[TTOneDevLog alloc] init];
    devLog.eventName = eventName;
    devLog.params = fixedParams;
    if ([TTMonitorStartupTask debugrealInitialized]) {
        devLog.storeID = [TTDebugRealMonitorManager cacheDevLogWithEventName:eventName params:fixedParams];
    }
    else {
        WeakSelf;
        dispatch_async(_startupTasksTrackQueue, ^{
            StrongSelf;
            if (!self.cachedDevLogs) {
                self.cachedDevLogs = [[NSMutableArray alloc] init];
            }
            [self.cachedDevLogs addObject:devLog];
        });
    }
    return devLog;
}

- (void)sendTasksIntervalsWithStatus:(int)status{
    if (self.tasksIntervalDic) {
        [self.tasksIntervalDic setValue:@(YES) forKey:@"isRefactored"];
        [self.tasksIntervalDic setValue:@(status) forKey:@"status"];
        LOGD(@"启动项耗时上报\n%@", self.tasksIntervalDic);
        [[TTMonitor shareManager] trackService:@"startup_tasks_interval" value:self.tasksIntervalDic extra:nil];
    }
    if (self.tasksIntervalDicInThread) {
        LOGD(@"启动项耗时上报2\n%@", self.tasksIntervalDicInThread);
        [self.tasksIntervalDicInThread setValue:@(status) forKey:@"status"];
        [[TTMonitor shareManager] trackService:@"startup_tasks_interval_in_thread" value:self.tasksIntervalDicInThread extra:nil];
    }
}

@end
