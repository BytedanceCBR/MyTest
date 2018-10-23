//
//  TTDebugRealMonitorManager.m
//  Article
//
//  Created by 苏瑞强 on 16/11/24.
//
//

#import "TTDebugRealMonitorManager.h"
//#import "SSAppPageLogicManager.h"
#import "TTDebugRealStorgeService.h"
#import "TTMonitor.h"
#import "TTMemoryUsageMonitorRecorder.h"

static  NSString * const kDebugRealDirectory = @"debug_real";
static  NSString * const kScreenShotDirectory = @"screen_shot";
static  NSString * const kScreenShotImageName = @"screen_shot.png";
static  NSInteger const kMAXApplogCount = 200;
static  NSString *const timestampKey = @"timestamp";
static  CFAbsoluteTime lastSysTime;

@interface TTDebugRealMonitorManager ()
    
@property(nonatomic, copy)NSString *sessionID;
@property (nonatomic, strong) NSMutableArray * cachedData;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, copy) NSArray* appSettings;
@property (nonatomic, assign) BOOL showPauseDataCollect;
@property (nonatomic, strong) NSMutableArray * visitedViewControllers;
@end

@implementation TTDebugRealMonitorManager

+ (instancetype)sharedManager
    {
        static TTDebugRealMonitorManager *defaultRecorder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultRecorder = [[[self class] alloc] init];
        });
        return defaultRecorder;
    }

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)start{
    self.enabled = YES;
    NSString *label = @"com.bytedance.debugreal.serialqueue";
    self.serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnetrBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate:) name:UIApplicationWillTerminateNotification object:nil];

}

- (void)willEnterForeground:(NSNotification *)notify{
    [self startSession];
}

- (void)didEnetrBackground:(NSNotification *)notify{
    [self endSession];
}

+ (void)cacheSStrackItemlog:(NSDictionary *)applogData{
    
}

+ (NSString *)cacheDevLogWithEventName:(NSString *)eventName params:(NSDictionary *)params{
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return nil;
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:eventName forKey:@"display_name"];
    [dict setValue:params forKey:@"params"];
    [dict setValue:@([[NSDate date] timeIntervalSince1970] * 1000) forKey:@"timestamp"];
    double currentMem = memory_now();
    if (currentMem>0) {
        [dict setValue:@(currentMem) forKey:@"current_mem"];
    }
    NSString * storeId = [[NSUUID UUID] UUIDString];
    [[TTDebugRealStorgeService sharedInstance] insertDevItem:dict storeId:storeId];
    return [storeId copy];
}

+ (void)removeEventById:(NSString *)eventId{
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return;
    }
    [[TTDebugRealStorgeService sharedInstance] removeDevItemById:eventId];
}

+ (void)cacheAppSettings:(NSDictionary *)settingsData{
    if (!settingsData) {
        return;
    }
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return;
    }
    [TTDebugRealMonitorManager sharedManager].appSettings = [settingsData copy];
}

-(void)cacheOneSession{
    if (!self.enabled) {
        return;
    }
    if (!self.cachedData) {
        self.cachedData = [[NSMutableArray alloc] init];
    }
    NSArray * viewControllerList = self.visitedViewControllers;
    if (viewControllerList && [viewControllerList count]>0) {
        [self.cachedData addObject:viewControllerList];
    }
    
    NSArray * devAndAppLogData = [self.cachedData copy];
    NSMutableDictionary * sendData = [[NSMutableDictionary alloc] init];
    [sendData setValue:devAndAppLogData forKey:@"devAndAppData"];
    if (self.appSettings && self.appSettings.count>0) {
        [sendData setValue:[self.appSettings copy] forKey:@"appSettings"];
    }
    NSDateFormatter * simpleFormatter = [[NSDateFormatter alloc] init];
    [simpleFormatter setDateFormat:@"MM-dd-HH-mm-ss"];
    NSString * dateStr = [simpleFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",self.sessionID, dateStr];
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
    [NSKeyedArchiver archiveRootObject:sendData toFile:[dictionaryPath stringByAppendingPathComponent:fileName]];
}

- (void)_createDebugRealDiectoryIfNeeded{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSArray *)_readContentsOfDebugReals{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
    NSArray * fileListRawNotExpired = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dictionaryPath error:nil];
    NSArray * fileListSorted = [fileListRawNotExpired sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary* first_properties  = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", dictionaryPath, obj1] error:nil];
        NSDate*       first             = [first_properties  objectForKey:NSFileModificationDate];
        NSDictionary* second_properties = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", dictionaryPath, obj2] error:nil];
        NSDate*       second            = [second_properties objectForKey:NSFileModificationDate];
        return [second compare:first];
    }];
    
    return [fileListSorted copy];
}

-(void)_cleanExpiredDataIfNeeded {
    NSTimeInterval expiredTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] - [TTDebugRealConfig sharedInstance].maxCacheAge*(60 * 60 * 24);
    NSMutableArray * fileNamedExpired = [[NSMutableArray alloc] init];
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
    NSArray * fileListRaw = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dictionaryPath error:nil];
    
    __block long long totalFileSize = 0.0;
    [fileListRaw enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * fileName = [obj stringByDeletingPathExtension];
        NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSTimeInterval createTimeInterval = [[attributes fileCreationDate] timeIntervalSince1970];
        if (expiredTimeInterval > createTimeInterval) {
            [fileNamedExpired addObject:fileName];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            totalFileSize += (long long)[attributes fileSize];
        }
    }];
    //删除过期数据
    for(NSString * fileName in fileNamedExpired){
        NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            totalFileSize -= (long long)[attributes fileSize];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    if (totalFileSize>0) {
        [[TTMonitor shareManager] trackService:@"monitor_debugreal_size" value:@(totalFileSize/(1024.0f*1024.0f)) extra:nil];
    }
}

- (void)startSession{
    dispatch_async(self.serialQueue, ^{
        self.showPauseDataCollect = NO;
        self.sessionID = [self _uuid];
        self.cachedData = [[NSMutableArray alloc] init];
        self.appSettings = nil;
        [self _createDebugRealDiectoryIfNeeded];
    });
}

- (void)endSession {
    self.showPauseDataCollect = YES;
    if (lastSysTime>0 && ([[NSDate date] timeIntervalSince1970]-lastSysTime < 60*5)) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        [self cacheOneSession];
        lastSysTime = [[NSDate date] timeIntervalSince1970];
        self.visitedViewControllers = [[NSMutableArray alloc] init];
        [self _cleanExpiredDataIfNeeded];
    });
}

- (void)willTerminate:(NSNotification *)notify{
    [self cacheOneSession];
}

- (NSString*)_uuid
{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    return uuidStr;
}

//+ (void)sendDebugRealData{
//    if (![TTDebugRealMonitorManager sharedManager].enabled) {
//        return;
//    }
//    [TTDebugRealMonitorManager sharedManager].showPauseDataCollect = YES;
//    dispatch_async([TTDebugRealMonitorManager sharedManager].serialQueue, ^{
//        [[TTDebugRealMonitorManager sharedManager] cacheOneSession];
//        [TTDebugRealMonitorManager sendOldDebugRealDataWithConfigs:nil];
//        [TTDebugRealMonitorManager sharedManager].showPauseDataCollect = NO;
//    });
//}
+ (void)sendDebugRealDataIfNeeded{
    
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return;
    }
    if (![TTDebugRealConfig sharedInstance].receiveUploadCommand) {
        return;
    }
    [TTDebugRealConfig sharedInstance].receiveUploadCommand = NO;
    dispatch_async([TTDebugRealMonitorManager sharedManager].serialQueue, ^{
        [[TTDebugRealMonitorManager sharedManager] _cleanExpiredDataIfNeeded];
        NSArray * debugRealDataFileList = [[TTDebugRealMonitorManager sharedManager] _readContentsOfDebugReals];
        NSMutableDictionary * debugRealDataDict = [[NSMutableDictionary alloc] init];
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
        for(NSString * fileName in debugRealDataFileList){
            NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
            NSDictionary * archivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            [debugRealDataDict setValue:archivedData forKey:fileName];
        }
        if (debugRealDataDict.allValues.count > 0 && [NSJSONSerialization isValidJSONObject:debugRealDataDict]) {
            [[TTMonitor shareManager] trackData:debugRealDataDict type:TTMonitorTrackerTypeLocalLog];
        }
        [[NSFileManager defaultManager] removeItemAtPath:dictionaryPath error:nil];
        [[TTDebugRealStorgeService sharedInstance] sendDebugRealData:[TTDebugRealConfig sharedInstance]];
    });
}

+ (void)sendOldDebugRealDataWithConfigs:(NSDictionary *)params{
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return;
    }
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if (![[params valueForKey:@"should_submit_debugreal"] boolValue]) {
        return;
    }
    dispatch_async([TTDebugRealMonitorManager sharedManager].serialQueue, ^{
        [[TTDebugRealConfig sharedInstance] configDataCollectPolicy:params];
        [[TTDebugRealMonitorManager sharedManager] _cleanExpiredDataIfNeeded];
        NSArray * debugRealDataFileList = [[TTDebugRealMonitorManager sharedManager] _readContentsOfDebugReals];
        NSMutableDictionary * debugRealDataDict = [[NSMutableDictionary alloc] init];
        NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
        for(NSString * fileName in debugRealDataFileList){
            NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
            NSDictionary * archivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            [debugRealDataDict setValue:archivedData forKey:fileName];
        }
        if (debugRealDataDict.allValues.count > 0 && [NSJSONSerialization isValidJSONObject:debugRealDataDict]) {
            [[TTMonitor shareManager] trackData:debugRealDataDict type:TTMonitorTrackerTypeLocalLog];
        }
        [[NSFileManager defaultManager] removeItemAtPath:dictionaryPath error:nil];
        [[TTDebugRealStorgeService sharedInstance] sendDebugRealData:[TTDebugRealConfig sharedInstance]];
    });
}

+ (void)logEnterEvent:(NSDictionary *)willAppearItem{
    if (!willAppearItem) {
        return;
    }
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return;
    }
    dispatch_async([TTDebugRealMonitorManager sharedManager].serialQueue, ^{
        if (![TTDebugRealMonitorManager sharedManager].showPauseDataCollect) {
            if (![TTDebugRealMonitorManager sharedManager].visitedViewControllers) {
                [TTDebugRealMonitorManager sharedManager].visitedViewControllers = [[NSMutableArray alloc] init];
            }
            [[TTDebugRealMonitorManager sharedManager].visitedViewControllers addObject:willAppearItem];
            if ([TTDebugRealMonitorManager sharedManager].visitedViewControllers.count>300) {
                [[TTDebugRealMonitorManager sharedManager].visitedViewControllers removeObjectAtIndex:0];
            }
        }
    });
}

+ (void)logLeaveEvent:(NSDictionary *)willDisAppearItem{
    if (!willDisAppearItem) {
        return;
    }
    if (![TTDebugRealMonitorManager sharedManager].enabled) {
        return;
    }
    dispatch_async([TTDebugRealMonitorManager sharedManager].serialQueue, ^{
        if (![TTDebugRealMonitorManager sharedManager].showPauseDataCollect && [TTDebugRealMonitorManager sharedManager].visitedViewControllers) {
            [[TTDebugRealMonitorManager sharedManager].visitedViewControllers addObject:willDisAppearItem];
            if ([TTDebugRealMonitorManager sharedManager].visitedViewControllers.count>300) {
                [[TTDebugRealMonitorManager sharedManager].visitedViewControllers removeObjectAtIndex:0];
            }
        }
    });
    
}

+ (void)handleException:(NSString *)execeptionInfo{
    [[TTDebugRealStorgeService sharedInstance] handleException:execeptionInfo];
}
@end
