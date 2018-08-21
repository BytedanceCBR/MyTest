//
//  TTDebugRealStorgeService.m
//  Pods
//
//  Created by 苏瑞强 on 17/1/3.
//
//

#import "TTDebugRealStorgeService.h"
#import "TTMonitorReporter.h"
#import "TTMonitorConfiguration.h"
#import "FMDB.h"
#import "TTExtensions.h"

#define kDebugRealDB @"debugreal.sqlite"
#define kNetworkDebugRealDirectory @"network_debugreal"
#define kCrashDirectory @"crash_debugreal"
#define kDebugRealDirectory @"new_debug_real"
#define kDebugRealVersion @"2.0"
#define kDebugRealVersionKey @"kDebugRealVersionKey"
#define kOutdateTimestamp   7 * 24 * 3600 // 1 week
#define kMaxMemCacheCount 50

@interface TTDebugRealStorgeService ()

@property(nonatomic, strong)FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong)TTMonitorReporter * reporter;
@property (nonatomic, assign) BOOL pauseDataCollect;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSMutableDictionary * debugrealDataMemCache;

@end

@implementation TTDebugRealStorgeService


+ (instancetype)sharedInstance
{
    static TTDebugRealStorgeService *defaultService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultService = [[[self class] alloc] init];
    });
    return defaultService;
}

+ (NSString *)debugrealVersion {
    return kDebugRealVersion;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init{
    self = [super init];
    if (self) {
        NSString *label = @"com.bytedance.debugreal.storeservicequeue";
        self.serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        self.reporter = [[TTMonitorReporter alloc] init];
        self.debugrealDataMemCache = [[NSMutableDictionary alloc] init];
        [self.reporter setMonitorConfiguration:[TTMonitorConfiguration class]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnetrBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [self _initalizeDB];
    }
    return self;
}

- (BOOL)_initalizeDB{
    NSString * filePath = [[self _debugRealPath] stringByAppendingPathComponent:kDebugRealDB];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
        if([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil] == NO){
        }
    }else{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kDebugRealVersionKey] ||
            [[[NSUserDefaults standardUserDefaults] objectForKey:kDebugRealVersionKey] integerValue]!=[[TTDebugRealStorgeService debugrealVersion] integerValue]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            if([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil] == NO){
                return NO;
            }
            [[NSUserDefaults standardUserDefaults] setObject:[TTDebugRealStorgeService debugrealVersion] forKey:kDebugRealVersionKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([attributes fileSize] > 1024*1024*5) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            if([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil] == NO){
                return NO;
            }
        }
    }
    
    __block BOOL result = NO;
    dispatch_async(self.serialQueue, ^{
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
           BOOL rs = [db executeStatements:@"pragma journal_mode = wal; pragma synchronous = normal"];
            NSString *createSql = @"CREATE TABLE IF NOT EXISTS debug_real(store_id VARCHAR(100), type NVARCHAR(200), value blob, created_at VARCHAR(100), PRIMARY KEY(store_id))";
            result = [db executeUpdate:createSql];
        }];
    });
    return result;
}

- (void)insertNetworkItem:(NSDictionary *)networkItem storeId:(NSString *)createTime{
    dispatch_async(self.serialQueue, ^{
        if (![TTDebugRealMonitorManager sharedManager].enabled) {//如果开关关掉，视为所有都在黑名单里
            return;
        }
        
        if (self.pauseDataCollect) {
            return;
        }
        @try {
            NSMutableDictionary * oneNetworkItem = [[NSMutableDictionary alloc] init];
            [oneNetworkItem setValue:createTime forKey:@"createTime"];
            [oneNetworkItem setValue:@"network" forKey:@"debugreal_type"];
            NSData  * data = [NSJSONSerialization dataWithJSONObject:[networkItem copy] options:0 error:nil];
            [oneNetworkItem setValue:data forKey:@"data"];
            [self.debugrealDataMemCache setValue:oneNetworkItem forKey:[networkItem valueForKey:@"requestID"]];
            if (self.debugrealDataMemCache.count>kMaxMemCacheCount) {
                [self _syncMemCahceToDB];
            }
        } @catch (NSException *exception) {
        } @finally {
        }
    });
}

- (void)insertMonitorItem:(NSDictionary *)monitorItem storeId:(NSString *)storeId{
    dispatch_async(self.serialQueue, ^{
        if (![TTDebugRealMonitorManager sharedManager].enabled) {//如果开关关掉，视为所有都在黑名单里
            return;
        }
        if (self.pauseDataCollect) {
            return;
        }
        @try {
            NSString * dateNowStr = [[TTExtensions _dateformatter] stringFromDate:[NSDate date]];
            NSMutableDictionary * oneMonitorItem = [[NSMutableDictionary alloc] init];
            [oneMonitorItem setValue:dateNowStr forKey:@"createTime"];
            [oneMonitorItem setValue:@"monitor" forKey:@"debugreal_type"];
            NSData  * data = [NSJSONSerialization dataWithJSONObject:[monitorItem copy] options:0 error:nil];
            [oneMonitorItem setValue:data forKey:@"data"];
            [self.debugrealDataMemCache setValue:oneMonitorItem forKey:storeId];
            if (self.debugrealDataMemCache.count>kMaxMemCacheCount) {
                [self _syncMemCahceToDB];
            }
        } @catch (NSException *exception) {
            
        } @finally {
        }
    });
}

- (void)insertDevItem:(NSDictionary *)devItem storeId:(NSString *)storeId{
    dispatch_async(self.serialQueue, ^{
        if (![TTDebugRealMonitorManager sharedManager].enabled) {//如果开关关掉，视为所有都在黑名单里
            return;
        }
        if (self.pauseDataCollect) {
            return;
        }
        @try {
            NSString * dateNowStr = [[TTExtensions _dateformatter] stringFromDate:[NSDate date]];
            NSMutableDictionary * oneDevItem = [[NSMutableDictionary alloc] init];
            [oneDevItem setValue:dateNowStr forKey:@"createTime"];
            [oneDevItem setValue:@"dev" forKey:@"debugreal_type"];
            NSData  * data = [NSJSONSerialization dataWithJSONObject:[devItem copy] options:0 error:nil];
            //NSData * data = [NSKeyedArchiver archivedDataWithRootObject:[devItem copy]];
            [oneDevItem setValue:data forKey:@"data"];
            [self.debugrealDataMemCache setValue:oneDevItem forKey:storeId];
        } @catch (NSException *exception) {
            
        } @finally {
        }
        
    });
}

-(void)_syncMemCahceToDB {
    if (![TTDebugRealMonitorManager sharedManager].enabled) {//如果开关关掉，视为所有都在黑名单里
        return;
    }
    dispatch_barrier_async(self.serialQueue, ^{
        [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [self.debugrealDataMemCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSDictionary * debugrealItem = (NSDictionary *)obj;
                NSData  * data = [debugrealItem valueForKey:@"data"];
                NSString * dateNowStr = [debugrealItem valueForKey:@"createTime"];
                NSString *  debugrealType = [debugrealItem valueForKey:@"debugreal_type"];
                NSString * sqlStr = @"INSERT OR ROLLBACK INTO debug_real(store_id, type, value, created_at) VALUES(?,?,?,?)";
                if (!sqlStr || !debugrealType || !data || !dateNowStr) {
                    return ;
                }
                BOOL rs = [db executeUpdate:sqlStr withArgumentsInArray:@[key,debugrealType,data,dateNowStr]];
            }];
        }];
        [self.debugrealDataMemCache removeAllObjects];
    });
}

- (void)removeDevItemById:(NSString *)storeId{
    if (!storeId) {
        return;
    }
    dispatch_async(self.serialQueue, ^{
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM debug_real WHERE store_id = '%@'", storeId];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
        }];
    });
}

- (void)deleteExpiredData
{
    dispatch_async(self.serialQueue, ^{
        NSTimeInterval timeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] - kOutdateTimestamp;
        NSString * dateNowStr = [[TTExtensions _dateformatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM debug_real WHERE created_at < '%@'", dateNowStr];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
        }];
    });
}

- (NSString *)_debugRealPath{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
        [self _createDebugRealDiectoryIfNeeded];
    }
    return dictionaryPath;
}

- (void)_createDebugRealDiectoryIfNeeded{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * dictionaryPath = [docsPath stringByAppendingPathComponent:kDebugRealDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)saveData:(NSData *)data storeId:(NSString *)storeId{
    if (!data || !storeId) {
        return;
    }
    NSString * dictionaryPath = [[self _debugRealPath] stringByAppendingPathComponent:kNetworkDebugRealDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * fileName = [NSString stringWithFormat:@"%@.json",storeId];
    NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
    [data writeToFile:filePath atomically:YES];
}

- (NSString *)networkResponseContentForStoreId:(NSString *)storeId{
    if (!storeId) {
        return nil;
    }
    if (![TTDebugRealConfig sharedInstance].needNetworkReponse) {
        return nil;
    }
    NSString * dictionaryPath = [[self _debugRealPath] stringByAppendingPathComponent:kNetworkDebugRealDirectory];
    NSString * fileName = [NSString stringWithFormat:@"%@.json",storeId];
    NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData * rawData = [NSData dataWithContentsOfFile:filePath];
        return [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)sendDebugRealData:(TTDebugRealConfig *)config{
        self.pauseDataCollect = YES;
        dispatch_async(self.serialQueue, ^{
            if (!config.submitTypeFlags) {
                
            }
            if (config.submitTypeFlags & TTDataWillSubmitedTypeNetwork) {
                [self _sendNetworkData:[TTDebugRealConfig sharedInstance]];
            }
        
            if (config.submitTypeFlags & TTDataWillSubmitedTypeDEV) {
                [self _sendDevData:[TTDebugRealConfig sharedInstance]];
            }
        
            if (config.submitTypeFlags & TTDataWillSubmitedTypeMonitor) {
                [self _sendMonitorData:[TTDebugRealConfig sharedInstance]];
            }
            
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                //    NSString *sql = [NSString stringWithFormat:@"DELETE FROM track WHERE created_at < '%@'", dateString];
                
                NSString * deleteStr = [NSString stringWithFormat:@"DELETE FROM debug_real WHERE  created_at > '%@' and created_at < '%@'",[TTDebugRealConfig sharedInstance].startTime, [TTDebugRealConfig sharedInstance].endTime];
                BOOL rs = [db executeUpdate:deleteStr];
                [db executeUpdate:@"vacuum"];
                
            }];
            
        self.pauseDataCollect = NO;
    });
}

- (void)_sendNetworkData:(TTDebugRealConfig *)congig{
    NSMutableArray * fileListToDelete = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        //    NSString *sql = [NSString stringWithFormat:@"DELETE FROM track WHERE created_at < '%@'", dateString];

        NSString * queryNetwork = [NSString stringWithFormat:@"SELECT * FROM debug_real WHERE type='network' and created_at > '%@' and created_at < '%@' ORDER BY created_at",congig.startTime, congig.endTime];
        FMResultSet *rs = [db executeQuery:queryNetwork];
        NSString * dictionaryPath = [[self _debugRealPath] stringByAppendingPathComponent:kNetworkDebugRealDirectory];
        while ([rs next]) {
            NSMutableDictionary * oneItem = [[NSMutableDictionary alloc] init];
            NSString *storeId = [rs stringForColumn:@"store_id"];
            NSString *createAt = [rs stringForColumn:@"created_at"];
            id valueObj = [rs dataForColumn:@"value"];
            if (valueObj) {
                if (!storeId) {
                    continue;
                }
                @try {
                    id parsedObj = [NSJSONSerialization JSONObjectWithData:valueObj options:NSJSONReadingMutableContainers error:nil];
                    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
                        NSString * requestContent = [self networkResponseContentForStoreId:createAt];
                        if (requestContent) {
                            NSMutableDictionary * networkWithContent = [NSMutableDictionary dictionaryWithDictionary:parsedObj];
                            [networkWithContent setValue:requestContent forKey:@"response_content"];
                            [[TTMonitor shareManager] trackData:networkWithContent type:TTMonitorTrackerTypeLocalLog];
                        }else{
                            [[TTMonitor shareManager] trackData:parsedObj type:TTMonitorTrackerTypeLocalLog];
                        }
                        NSString * fileName = [NSString stringWithFormat:@"%@.json",createAt];
                        NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
                        if (filePath) {
                            [fileListToDelete addObject:filePath];
                        }
                    }
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                
            }
        }
    }];
    
    //数据发完后 网络请求内容json文件也删掉
    for(NSString * filePath in fileListToDelete){
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

- (void)_sendMonitorData:(TTDebugRealConfig *)congig{
    NSMutableArray * monitorList = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * queryNetwork = [NSString stringWithFormat:@"SELECT * FROM debug_real WHERE type='monitor' and created_at > '%@' and created_at < '%@' ORDER BY created_at",congig.startTime, congig.endTime];

        FMResultSet *rs = [db executeQuery:queryNetwork];
        while ([rs next]) {
            NSMutableDictionary * oneItem = [[NSMutableDictionary alloc] init];
            NSString *storeId = [rs stringForColumn:@"store_id"];
            NSString *createAt = [rs stringForColumn:@"created_at"];
            id valueObj = [rs dataForColumn:@"value"];
            if (valueObj) {
                @try {
                    id parsedObj = [NSJSONSerialization JSONObjectWithData:valueObj options:NSJSONReadingMutableContainers error:nil];
                    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
                        [[TTMonitor shareManager] trackData:parsedObj type:TTMonitorTrackerTypeLocalLog];
                    }
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
            }
        }
    }];
    NSString * crashDir = [[self _debugRealPath] stringByAppendingPathComponent:kCrashDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:crashDir]) {
        NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:crashDir error:nil];
        if (fileList && fileList.count>0) {
            [fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * crashFilePath = [crashDir stringByAppendingPathComponent:obj];
                if ([[NSFileManager defaultManager] fileExistsAtPath:crashFilePath]) {
                    NSString * crashContent = [NSString stringWithContentsOfFile:crashFilePath encoding:NSUTF8StringEncoding error:nil];
                    if (crashContent) {
                        NSMutableDictionary * crashItem = [[NSMutableDictionary alloc] init];
                        [crashItem setValue:crashContent forKey:@"crash_value"];
                        [crashItem setValue:[obj stringByReplacingOccurrencesOfString:@".crash" withString:@""] forKey:@"created_at"];
                        [[TTMonitor shareManager] trackData:crashItem type:TTMonitorTrackerTypeLocalLog];
                    }
                }
            }];
            [[NSFileManager defaultManager] removeItemAtPath:crashDir error:nil];
        }
    }
}

- (void)_sendDevData:(TTDebugRealConfig *)congig{
    NSMutableArray * devLogList = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * queryNetwork = [NSString stringWithFormat:@"SELECT * FROM debug_real WHERE type='dev' and created_at > '%@' and created_at < '%@' ORDER BY created_at",congig.startTime, congig.endTime];

        FMResultSet *rs = [db executeQuery:queryNetwork];
        while ([rs next]) {
            NSMutableDictionary * oneItem = [[NSMutableDictionary alloc] init];
            NSString *storeId = [rs stringForColumn:@"store_id"];
            NSString *createAt = [rs stringForColumn:@"created_at"];
            id valueObj = [rs dataForColumn:@"value"];
            if (valueObj) {
                @try {
                    id parsedObj = [NSJSONSerialization JSONObjectWithData:valueObj options:NSJSONReadingMutableContainers error:nil];
                    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
                        [[TTMonitor shareManager] trackData:parsedObj type:TTMonitorTrackerTypeLocalLog];
                    }
                } @catch (NSException *exception) {} @finally {}
            }
        }
    }];
}

-(void)reportData:(NSArray *)data type:(NSString *)type{
    NSMutableDictionary* dataForSend = [[NSMutableDictionary alloc] init];
    if (type && [type isEqualToString:@"network"]) {
        for(NSDictionary * obj in data){
            if (![obj isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            NSString *createTime = [obj valueForKey:@"created_at"];
            NSString *storeId = [obj valueForKey:@"store_id"];

            if (!storeId) {
                continue;
            }
            NSMutableDictionary * oneItem = [[NSMutableDictionary alloc] initWithDictionary:obj];
            NSString * requestContent = [self networkResponseContentForStoreId:createTime];
            [oneItem setValue:requestContent forKey:@"response_content"];
            [dataForSend setValue:oneItem forKey:storeId];
        }
        [[TTMonitor shareManager] trackData:[dataForSend copy] type:TTMonitorTrackerTypeLocalLog];
    }else{
        if (type && [type isEqualToString:@"monitor"]) {
            [dataForSend setValue:data forKey:@"monitor_data"];
            [[TTMonitor shareManager] trackData:[dataForSend copy] type:TTMonitorTrackerTypeLocalLog];
        }else
            if (type && [type isEqualToString:@"dev"]) {
                [dataForSend setValue:data forKey:@"dev_data"];
                [[TTMonitor shareManager] trackData:[dataForSend copy] type:TTMonitorTrackerTypeLocalLog];
            }
    }
}

//下面的删除可能不是最优化的，记得评估测试。

- (void)willEnterForeground:(NSNotification *)notify{
    self.pauseDataCollect = NO;
}

- (void)didEnetrBackground:(NSNotification *)notify{
    self.pauseDataCollect = YES;
    [self _syncMemCahceToDB];
    dispatch_async(self.serialQueue, ^{
        NSString * filePath = [[self _debugRealPath] stringByAppendingPathComponent:kDebugRealDB];
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSTimeInterval lastCheckTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastcheckdate"];
        //10分钟触发一次清理
        if ([[NSDate date] timeIntervalSince1970] - lastCheckTimeInterval < 10*60) {
#ifndef DEBUG
            return;
#endif
        }
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"lastcheckdate"];
        NSTimeInterval timeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] - [TTDebugRealConfig sharedInstance].maxCacheAge*(60 * 60 * 24);
        
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            NSString * dateStr =  [[TTExtensions _dateformatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM debug_real WHERE created_at < '%@'", dateStr];
            BOOL result0 = [db executeUpdate:sql];
            if (!result0) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }];
        
        if ([attributes fileSize] > [TTDebugRealConfig sharedInstance].maxCacheDBSize*(1024*1024)) {
            [[TTMonitor shareManager] trackService:@"monitor_new_debugreal_db_size" value:@([attributes fileSize]/(1024.0f/1024.0f)) extra:nil];
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                NSString * deleteNetworkSql = @"DELETE FROM debug_real WHERE store_id NOT IN (SELECT store_id from debug_real WHERE type='network' ORDER BY created_at DESC LIMIT 2000) and type='network'";
                BOOL result1 = [db executeUpdate:deleteNetworkSql];
                
                NSString * deleteMonitorSql = @"DELETE FROM debug_real WHERE store_id NOT IN (SELECT store_id from debug_real WHERE type='monitor' ORDER BY created_at DESC LIMIT 2000) and type='monitor'";
                BOOL result2 = [db executeUpdate:deleteMonitorSql];
                
                NSString * deleteDevSql = @"DELETE FROM debug_real WHERE store_id NOT IN (SELECT store_id from debug_real WHERE type='dev' ORDER BY created_at DESC LIMIT 2000) and type='dev'";
                BOOL result3 = [db executeUpdate:deleteDevSql];

                if (!result1 || !result2 || !result3) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                [db executeUpdate:@"vacuum"];
            }];
        }
        NSString * dictionaryPath = [[self _debugRealPath] stringByAppendingPathComponent:kNetworkDebugRealDirectory];
        NSDirectoryEnumerator* en = [[NSFileManager defaultManager] enumeratorAtPath:dictionaryPath];
        NSError* err = nil;
        BOOL res;
        NSTimeInterval expiredTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] - [TTDebugRealConfig sharedInstance].maxCacheAge*(60 * 60 * 24);
        NSArray * fileListRaw = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dictionaryPath error:nil];
        NSMutableArray * fileNamedExpired = [[NSMutableArray alloc] init];
        __block long long totalFileSize = 0.0;
        [fileListRaw enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString * fileName = [obj stringByDeletingPathExtension];
            NSDate * fileCreateDate = [[TTExtensions _dateformatter] dateFromString:fileName];
            NSTimeInterval createTimeInterval = [fileCreateDate timeIntervalSince1970];
            if (expiredTimeInterval > createTimeInterval) {
                [fileNamedExpired addObject:fileName];
            }
            NSString * fullName = [NSString stringWithFormat:@"%@.json",fileName];
            NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fullName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                long long filesize = [attributes fileSize];
                totalFileSize += (long long)filesize;
            }
        }];
        //删除过期数据
        for(NSString * fileName in fileNamedExpired){
            NSString * fullName = [NSString stringWithFormat:@"%@.json",fileName];
            NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fullName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                totalFileSize -= [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        ////清除一遍后 重新读一遍文件夹下的文件信息
        long long maxFileSize = [[TTDebugRealConfig sharedInstance] maxCacheSize]*1024*1024;
        NSArray * fileListAfterExpiredCleared = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dictionaryPath error:nil];
            NSArray * fileListSorted = [fileListAfterExpiredCleared sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSString * fileName1 = [obj1 stringByDeletingPathExtension];
                NSDate * fileCreateDate1 = [[TTExtensions _dateformatter] dateFromString:fileName1];
                NSString * fileName2 = [obj1 stringByDeletingPathExtension];
                NSDate * fileCreateDate2 = [[TTExtensions _dateformatter] dateFromString:fileName2];
                return [fileCreateDate1 compare:fileCreateDate2];
            }];
            
            for(NSInteger index = fileListAfterExpiredCleared.count-1; index>=0;index--){
                NSString * fileName = [fileListSorted objectAtIndex:index];
                NSString * filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    totalFileSize -= [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                if (totalFileSize <= maxFileSize) {
                    break;
                }
            }
        if (totalFileSize/(1024.0f*1024.0f)>0) {
            [[TTMonitor shareManager] trackService:@"monitor_new_debugreal_size" value:@(totalFileSize/(1024.0f*1024.0f)) extra:nil];
        }
        
        NSString * crashDir = [[self _debugRealPath] stringByAppendingPathComponent:kCrashDirectory];
        if ([[NSFileManager defaultManager] fileExistsAtPath:crashDir]) {
            NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:crashDir error:nil];
            if (fileList && fileList.count>10) {
                [[NSFileManager defaultManager] removeItemAtPath:crashDir error:nil];
            }
        }
    });
}

- (NSArray *)allNetworkItems{
    NSMutableArray * networkList = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString * queryNetwork = @"SELECT * FROM debug_real WHERE type='network' ORDER BY created_at";
        FMResultSet *rs = [db executeQuery:queryNetwork];
        while ([rs next]) {
            NSMutableDictionary * oneItem = [[NSMutableDictionary alloc] init];
            NSString *storeId = [rs stringForColumn:@"store_id"];
            NSString *createAt = [rs stringForColumn:@"created_at"];
            id valueObj = [rs dataForColumn:@"value"];
            if (valueObj) {
                @try {
                    id parsedObj = [NSJSONSerialization JSONObjectWithData:valueObj
                                                                   options:NSJSONReadingMutableContainers error:nil];
                    if ([parsedObj isKindOfClass:[NSDictionary class]]) {
                        [oneItem setValue:parsedObj forKey:@"value"];
                    }
                } @catch (NSException *exception) {
                } @finally {
                }
            }
            [oneItem setValue:storeId forKey:@"store_id"];
            [oneItem setValue:createAt forKey:@"created_at"];
            [networkList addObject:oneItem];
        }
    }];
    return [networkList copy];
}

- (void)handleException:(NSString *)execeptionInfo {
    if (!execeptionInfo) {
        return;
    }
    [self _syncMemCahceToDB];
    NSString * dictionaryPath = [[self _debugRealPath] stringByAppendingPathComponent:kCrashDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * crashFile = [dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f.crash",[[NSDate date] timeIntervalSince1970]*1000]];
    [execeptionInfo writeToFile:crashFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end
