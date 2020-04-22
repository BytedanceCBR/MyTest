//
//  FHLynxManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/22.
//

#import "FHLynxManager.h"
#import "IESGeckoKit.h"
#import "FHIESGeckoManager.h"
#include <pthread.h>
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"
#import "NSData+BTDAdditions.h"
#import "IESGeckoKit.h"

@interface FHLynxManager()

@property (nonatomic, strong) dispatch_queue_t lynx_io_queue;
@property (nonatomic, strong) NSMutableDictionary *templateCache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *totalConfigDict;
//@property (nonatomic, strong) NSMutableDictionary<NSString *, Class<FHLynxDefaultTemplateProtocol>> *defaultProviderDict;
@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) NSUInteger tryForMissCount;
@property (nonatomic, assign) BOOL hasRegistGecko;
@property (nonatomic, assign) BOOL isRetryingSync;

@end

@implementation FHLynxManager
{
    pthread_mutex_t _configDictLock;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lynx_io_queue = dispatch_queue_create("com.bytedance.fh_lynx_manager.lynx_io_queue", DISPATCH_QUEUE_SERIAL);
        _templateCache = [NSMutableDictionary dictionary];
        _totalConfigDict = [NSMutableDictionary dictionary];
        pthread_mutex_init(&_configDictLock, NULL);
    }
    return self;
}


+ (instancetype)sharedInstance {
    static FHLynxManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FHLynxManager alloc] init];
    });
    return instance;
}

- (NSData *)lynxDataForChannel:(NSString *)channel templateKey:(NSString *)templateKey version:(NSUInteger)version {
    NSString *cacheKey = [self cacheKeyForChannel:channel templateKey:templateKey version:0];
    __block NSData *data = [self.templateCache objectForKey:cacheKey];
    
    if (!data) {
        NSNumber *costTime = @(0);
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        //没有的话同步读，用磁盘io的串行队列
        dispatch_sync(self.lynx_io_queue, ^{
            data = [self getGeckoFileDataWithChannel:channel fileName:[FHLynxManager defaultJSFileName]];
            if (data) {
                [self cacheData:data andChannel:channel];
            }
        });
    };
   return data;
}
                     


- (NSString *)cacheKeyForChannel:(NSString *)channel templateKey:(NSString *)templateKey version:(NSUInteger)version {
    return [NSString stringWithFormat:@"%@-%@-%lu",channel,templateKey,(unsigned long)version];
}

- (NSData *)getGeckoFileDataWithChannel:(NSString *)channel fileName:(NSString *)fileName {
    return [IESGeckoKit dataForPath:fileName accessKey:[FHIESGeckoManager getGeckoKey] channel:channel];
}

- (NSData *)getPersistenceFileDataWithChannel:(NSString *)channel fileName:(NSString *)fileName currentFolderStr:(NSString *)currentFolderStr {
    if (isEmptyString(channel) || isEmptyString(fileName) || isEmptyString(currentFolderStr) || [currentFolderStr isEqualToString:@"0"]) {
        return nil;
    }
    
    NSString *appSupportFolder = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderPath = [[[appSupportFolder stringByAppendingPathComponent:@"FHLynx"] stringByAppendingPathComponent:currentFolderStr] stringByAppendingPathComponent:channel];
    NSString *totalPath = [folderPath stringByAppendingPathComponent:fileName];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:totalPath];
    return data;
}

- (void)syncAllChannel {
    if (self.retryCount > 3) {
        return;
    }
    NSArray *channelNameArray = [self allChannelArrays];

    WeakSelf;
    [IESGeckoKit syncResourcesWithAccessKey:[FHIESGeckoManager getGeckoKey] channels:channelNameArray completion:^(BOOL succeed, IESGeckoSyncStatusDict  _Nonnull dict) {
        StrongSelf;
        if (succeed) {
            self.retryCount = 0;
            [self activateChannels:channelNameArray];
                
        } else {
            //重试
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.retryCount++;
                [self syncAllChannel];
            });
        }
    }];
}

- (void)cacheData:(NSData *)templateData andChannel:(NSString *)channel{
    NSString *cacheKey = [self cacheKeyForChannel:channel templateKey:[FHLynxManager defaultJSFileName] version:0];
    [self.templateCache setValue:templateData forKey:cacheKey];
}

- (void)activateChannels:(NSArray<NSString *> *)channelArray {
    dispatch_group_t activateGroup = dispatch_group_create();
    for (NSString *channel in channelArray) {
        dispatch_group_enter(activateGroup);
        [IESGeckoKit applyInactivePackageForAccessKey:[FHIESGeckoManager getGeckoKey] channel:channel completion:^(BOOL succeed, IESGeckoSyncStatus status) {
            dispatch_group_leave(activateGroup);
        }];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_wait(activateGroup, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
        dispatch_async(dispatch_get_main_queue(), ^{
            [self readGeckoResources];
        });
        
    });
}

//这块需要把部分任务拆分到子线程。
- (void)readGeckoResources {
    //把数据读出来，放到缓存。
    NSArray<NSString *> *channelConfigArray = [self allChannelArrays];
    dispatch_group_t read_group = dispatch_group_create();
    BOOL isAsync = NO;
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
//    NSUInteger timeInteger = (NSUInteger)time;
//    NSString * timeString = [NSString stringWithFormat:@"%lu",(unsigned long)timeInteger];
    NSMutableArray *changedChannels = [NSMutableArray array];
    
    for (NSString *localChannelin in channelConfigArray) {
        NSString *channel = localChannelin;
        NSData *data = [self getGeckoFileDataWithChannel:channel fileName:@"config.json"];
        
        NSDictionary *channelConfigDict = [data btd_jsonDictionary];
        NSDictionary *perConfigDict = [data btd_jsonDictionary];
        NSMutableDictionary *mutPerConfigDict = perConfigDict.mutableCopy;
        [mutPerConfigDict removeObjectForKey:@"invalid"];
        
        if (![channelConfigDict isEqualToDictionary:mutPerConfigDict]) {
            [changedChannels addObject:channel];
        }
                
     
        NSString *cacheKey = [self cacheKeyForChannel:channel templateKey:[FHLynxManager defaultJSFileName] version:0];
        dispatch_group_async(read_group, self.lynx_io_queue, ^{
            NSMutableDictionary * asyncDict = [NSMutableDictionary new];
            NSData *templateData = [self getGeckoFileDataWithChannel:channel fileName:[FHLynxManager defaultJSFileName]];
            [asyncDict setValue:templateData forKey:cacheKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.templateCache addEntriesFromDictionary:asyncDict];
            });
        });
    }
    
    //时机问题
    void(^versionBlock)(void) = ^(void) {
        NSMutableDictionary *versionDict = [NSMutableDictionary dictionary];
          
        //同步到特定目录。
        if ([changedChannels count]) {
            dispatch_async(self.lynx_io_queue, ^{
                //需要同步
                pthread_mutex_lock(&self->_configDictLock);
                [self.totalConfigDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull channel, NSDictionary * _Nonnull channelConfig, BOOL * _Nonnull stop) {
                    if ([changedChannels containsObject:channel]) {
                        //存config
//                        NSData *channelData = [channelConfig toJSONData];
//                        [self savePersistenceFileData:channelData channel:channel fileName:@"config.json" currentFolerStr:timeString];
                        //存模版
//                        for (TTLynxTemplateConfig *templateConfig in channelConfig.iOS.templateConfigList) {
//                            NSString *fileName = templateConfig.templateName;
//                            NSString *cacheKey = [self cacheKeyForChannel:channel templateKey:templateConfig.templateKey version:channelConfig.version];
//                            NSData *templateData = [self.templateCache valueForKey:cacheKey];
//                            [self savePersistenceFileData:templateData channel:channel fileName:fileName currentFolerStr:timeString];
//                        }
                        //删除老的。
//                        if (!isEmptyString(oldFolderString)) {
//                            [self removeFolerForChannel:channel folderString:oldFolderString];
//
//                        }
                        
                    } else {
                        //仅仅重命名。
//                        if (!isEmptyString(oldFolderString)) {
//                            [self moveFilesForChannel:channel fromFolder:oldFolderString toFolder:timeString];
//
//                        }
                        
                    }
                }];
                pthread_mutex_unlock(&self->_configDictLock);
                
                //在这儿搞一下全删。
                dispatch_async(self.lynx_io_queue, ^{
//                    [self removeAllFoldersBeforFolderTime:timeInteger];
                });
            });
        }
        
    };
    if (isAsync == YES) {
        dispatch_group_notify(read_group, dispatch_get_main_queue(), versionBlock);
    } else {
        versionBlock();
    }
    
}

- (NSArray<NSString *> *)allChannelArrays{
    return @[@"test_ios"];
}

+ (NSString *)defaultJSFileName
{
    return @"template_key.js";
}

@end
