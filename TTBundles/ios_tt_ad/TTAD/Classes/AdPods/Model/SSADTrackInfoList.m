//
//  SSADTrackInfoList.m
//  Article
//
//  Created by Dai Dongpeng on 5/4/16.
//
//

#import "SSADTrackInfoList.h"

@interface SSADTrackInfoList ()

@property (nonatomic, strong) NSMutableArray <NSString *> *preloadList;
@property (nonatomic, strong) NSMutableArray <SSADTrackInfoLog> *lastLogList;

@end

@implementation SSADTrackInfoList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _preloadList = [[NSMutableArray alloc] initWithCapacity:7];
        _lastLogList = (NSMutableArray<SSADTrackInfoLog> *)[[NSMutableArray alloc] initWithCapacity:7];
    }
    return self;
}
+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

- (void)addInfoLog:(SSADTrackInfoLog *)log
{
    if (!log) {
        return;
    }
   
    __block BOOL hasFound = NO;
    
    [self.lastLogList enumerateObjectsUsingBlock:^(SSADTrackInfoLog * _Nonnull infoLog, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([infoLog.logID isEqualToString:log.logID])
        {
            [infoLog addHistoryArray:log.historyList];
            *stop = YES;
            hasFound = YES;
        }
    }];
    
    if (!hasFound) {
        [self.lastLogList addObject:log];
    }
}

//- (void)addLastLogsArray:(NSArray <SSADTrackInfoLog *> *)logs
//{
//    if (logs.count > 0) {
//        [self.lastLogList addObjectsFromArray:logs];
//    }
//}

- (void)addPreload:(NSString *)preloadID
{
    if (preloadID) {
        [self.preloadList addObject:preloadID];
    }
}
- (void)setPreloadListArray:(NSArray *)preloadIDs
{
    [self.preloadList removeAllObjects];
    if (preloadIDs.count > 0) {
        [self.preloadList addObjectsFromArray:preloadIDs];
    }
}
- (NSDictionary *)toCustomJSONDictionary
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:3];
    [result setValue:self.fetchTime forKey:@"fetch_time"];
    
    NSString *preload = [self jsonStringFromArray:self.preloadList];
    [result setValue:preload forKey:@"preload_list"];
    
    NSArray *logs = [JSONModel arrayOfDictionariesFromModels:self.lastLogList];
    NSString *logsString = [self jsonStringFromArray:logs];
    [result setValue:logsString forKey:@"last_log_list"];
    
    return result;
}

- (NSString *)jsonStringFromArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
    if (!jsonData) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end


@implementation SSADTrackInfoLog

- (instancetype)initWithLogID:(NSString *)logID
{
    if (self = [super init]) {
        _historyList = (NSMutableArray <SSADTrackInfoHistory> *)[[NSMutableArray alloc] initWithCapacity:7];
        _logID = logID;
    }
    return self;
}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:
    @{
      @"history" : NSStringFromSelector(@selector(historyList)),
      @"id" : NSStringFromSelector(@selector(logID))
      }];
}

- (void)addHistory:(SSADTrackInfoHistory *)history
{
    if (![self.logID isEqualToString:history.logID]) {
        return ;
    }
    
    __block BOOL hasFound = NO;
    [self.historyList enumerateObjectsUsingBlock:^(SSADTrackInfoHistory * _Nonnull his2, NSUInteger idx, BOOL * _Nonnull stop) {
    
        if (history.statue == his2.statue) {
            his2.count += 1;
            hasFound = YES;
            *stop = YES;
        }
    }];
    
    if (!hasFound) {
        [self.historyList addObject:history];
    }
}

- (void)addHistoryArray:(NSArray <SSADTrackInfoHistory *> *)hisArray
{
    [hisArray enumerateObjectsUsingBlock:^(SSADTrackInfoHistory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addHistory:obj];
    }];
}

@end

@implementation SSADTrackInfoHistory
@end