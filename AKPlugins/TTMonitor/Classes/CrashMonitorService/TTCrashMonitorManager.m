//
//  TTCrashMonitorManager.m
//  Article
//
//  Created by 苏瑞强 on 16/10/25.
//
//

#import "TTCrashMonitorManager.h"
#import "TTMonitor.h"

static NSString *const cachedApplogFile = @"cachedApplogFile";
static NSString *const cachedDevlogFile = @"cachedDevlogFile";
static NSString *const cachedMonitorlogFile = @"cachedMonitorlogFile";
static NSString *const appSettingslogFile = @"appSettingslogFile";
static NSString *const timestampKey = @"timestamp";
static NSInteger const MAXApplogCount = 50;
static NSInteger const MAXDevlogCount = 200;
static NSInteger const MAXMonitorlogCount = 50;
static CFAbsoluteTime lastSyncTime;

@interface TTCrashMonitorManager ()

@property (nonatomic, strong) NSMutableArray * cachedData;
@property (nonatomic, strong) NSMutableArray * cachedDevLog;
@property (nonatomic, strong) NSMutableArray * cachedMonitorLog;
@property (nonatomic, strong) NSMutableArray * cacheApplog;
@property (nonatomic, assign) BOOL hasCrashData;
@property (nonatomic, assign) BOOL pauseCollectLogs;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, copy) NSArray* appSettings;

@end

@implementation TTCrashMonitorManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init{
    self = [super init];
    if (self) {
        NSString *label = @"com.bytedance.crash_monitor.serialqueue";
        self.serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        
        //解压devLog
        NSArray * unarchivedDevData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:cachedDevlogFile]];
        if (unarchivedDevData && [unarchivedDevData isKindOfClass:[NSArray class]]) {
         self.cachedDevLog = [[NSMutableArray alloc] initWithArray:unarchivedDevData];
        }
        if (!self.cachedDevLog) {
            self.cachedDevLog = [[NSMutableArray alloc] init];
        }
        //解压monitorLog
        NSArray * unarchivedMonitorData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:cachedMonitorlogFile]];

        if (unarchivedMonitorData && [unarchivedMonitorData isKindOfClass:[NSArray class]]) {
            self.cachedMonitorLog = [[NSMutableArray alloc] initWithArray:unarchivedMonitorData];
        }
        if (!self.cachedMonitorLog) {
            self.cachedMonitorLog = [[NSMutableArray alloc] init];
        }
        
        NSArray * unarchivedSettingsData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:appSettingslogFile]];

        if (unarchivedSettingsData && [unarchivedSettingsData isKindOfClass:[NSDictionary class]]) {
            self.appSettings = unarchivedSettingsData;
        }
        
        //解压appLog
        NSArray * unarchivedAppData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:cachedApplogFile]];

        if (unarchivedAppData && [unarchivedAppData isKindOfClass:[NSArray class]]) {
            self.cacheApplog = [[NSMutableArray alloc] initWithArray:unarchivedAppData];
        }
        if (self.cacheApplog && self.cacheApplog.count>0) {
            self.hasCrashData = YES;
        }else{
            self.cacheApplog = [[NSMutableArray alloc] init];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveActivity:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterActivity:) name:UIApplicationDidBecomeActiveNotification object:nil];

    }
    return self;
}

+ (instancetype)defaultMonitorManager
{
    static TTCrashMonitorManager *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

- (void)cacheOneSStrackItemlog:(NSDictionary *)applogData{
    if (self.hasCrashData || self.pauseCollectLogs) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary * newDict = [[NSMutableDictionary alloc] initWithDictionary:applogData];
        [newDict setValue:@([[NSDate date] timeIntervalSince1970]) forKey:timestampKey];
        [self.cacheApplog addObject:newDict];
        if (self.cacheApplog.count > MAXApplogCount) {
            [self.cacheApplog removeObjectAtIndex:0];
        }
    });
}

- (void)cacheOneDevItemDevLog:(NSString *)devData{
    if (self.hasCrashData || !devData || self.pauseCollectLogs) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary * newDict = [[NSMutableDictionary alloc] init];
        [newDict setValue:devData forKey:@"dev_data"];
        [newDict setValue:@([[NSDate date] timeIntervalSince1970]) forKey:timestampKey];
        [self.cachedDevLog addObject:newDict];
        if (self.cachedDevLog.count>MAXDevlogCount) {
            [self.cachedDevLog removeObjectAtIndex:0];
        }
    });
}

- (void)cacheOneMonitorItemLog:(NSString *)monitorData{
    if (self.hasCrashData || !monitorData || self.pauseCollectLogs) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary * newDict = [[NSMutableDictionary alloc] init];
        [newDict setValue:monitorData forKey:@"monitor_data"];
        [newDict setValue:@([[NSDate date] timeIntervalSince1970]) forKey:timestampKey];
        [self.cachedMonitorLog addObject:newDict];
        if (self.cachedMonitorLog.count>MAXMonitorlogCount) {
            [self.cachedMonitorLog removeObjectAtIndex:0];
        }
    });

}

- (void)cacheAppSettings:(NSDictionary *)settingsData{
    if (self.hasCrashData || !settingsData || self.pauseCollectLogs) {
        return;
    }
    _appSettings = [settingsData copy];
}

- (void)leaveActivity:(NSNotification *)notify{
    self.pauseCollectLogs = YES;
    if (!self.enabled) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.cachedDevLog];
        if (data) {
         [[NSUserDefaults standardUserDefaults] setObject:data forKey:cachedDevlogFile];
        }
        NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:self.cachedMonitorLog];
        if (data2) {
            [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:cachedMonitorlogFile];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}


- (void)enterActivity:(NSNotification *)notify{
    self.pauseCollectLogs = NO;
}

- (void)saveToDisk:(id)sender {
    self.pauseCollectLogs = YES;
    if (!self.enabled) {
        return;
     }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.cachedDevLog];
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:cachedDevlogFile];
    }
    if (self.cachedMonitorLog && self.cachedMonitorLog.count>0) {
        NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:self.cachedMonitorLog];
        if (data2) {
            [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:cachedMonitorlogFile];
        }
    }
    if (self.cacheApplog && self.cacheApplog.count>0) {
        NSData *data3 = [NSKeyedArchiver archivedDataWithRootObject:self.cacheApplog];
        if (data3) {
            [[NSUserDefaults standardUserDefaults] setObject:data3 forKey:cachedApplogFile];
        }
    }
    if (self.appSettings) {
        NSData *data4 = [NSKeyedArchiver archivedDataWithRootObject:self.appSettings];
        if (data4) {
            [[NSUserDefaults standardUserDefaults] setObject:data4 forKey:appSettingslogFile];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sendMonitedData {
    self.pauseCollectLogs = YES;
#warning 测试
    if (!self.enabled) {
        return;
    }
    if (!self.cachedData) {
        self.cachedData = [[NSMutableArray alloc] init];
    }
    if (self.cacheApplog && self.cacheApplog.count>0) {
        [self.cachedData addObject:self.cacheApplog];
    }
    if (self.cachedDevLog && self.cachedDevLog.count>0) {
        [self.cachedData addObject:self.cachedDevLog];
    }
    if (self.cachedMonitorLog && self.cachedMonitorLog.count>0) {
        [self.cachedData addObject:self.cachedMonitorLog];
    }
    if (self.appSettings && self.appSettings.count>0) {
        [self.cachedData addObject:self.appSettings];
    }
    
    [self.cachedData sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary * dict1 = (NSDictionary *)obj1;
        NSDictionary * dict2 = (NSDictionary *)obj2;
        if ([dict1 isKindOfClass:[NSDictionary class]] && [dict2 isKindOfClass:[NSDictionary class]]) {
            NSNumber* time1 = [dict1 valueForKey:timestampKey];
            NSNumber* time2 = [dict2 valueForKey:timestampKey];
            if ([time1 isKindOfClass:[NSNumber class]] && [time2 isKindOfClass:[NSNumber class]]) {
                return [time1 compare:time2];
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }];
    
    NSDictionary * sendData = [self.cachedData copy];
    NSDictionary * data = [[NSDictionary alloc] initWithObjectsAndKeys:sendData,@"extra_value", nil];
    [[TTMonitor shareManager] trackData:data type:TTMonitorTrackerTypeLocalLog];
    [self clear];
    self.hasCrashData = NO;
    self.pauseCollectLogs = NO;
}

- (void)clear{
    [self.cacheApplog removeAllObjects];
    [self.cachedDevLog removeAllObjects];
    [self.cacheApplog removeAllObjects];
    [self.cachedData removeAllObjects];
    self.cachedData = nil;
}

@end
