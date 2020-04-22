//
//  FHLynxManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/22.
//

#import "FHLynxManager.h"
#import "FHLynxChannelConfig.h"
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
@property (nonatomic, strong) NSMutableDictionary<NSString *, FHLynxChannelConfig *> *totalConfigDict;
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

+ (instancetype)sharedInstance {
    static FHLynxManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FHLynxManager alloc] init];
    });
    return instance;
}

- (NSData *)lynxDataForChannel:(NSString *)channel templateKey:(NSString *)templateKey version:(NSUInteger)version {
    NSString *cacheKey = [self cacheKeyForChannel:channel templateKey:templateKey version:version];
    __block NSData *data = [self.templateCache objectForKey:cacheKey];
    
    if (!data) {
        NSNumber *costTime = @(0);
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        //没有的话同步读，用磁盘io的串行队列
        dispatch_sync(self.lynx_io_queue, ^{
            
        FHLynxChannelConfig *channelConfig = [self configForChannel:channel];
        if (channelConfig.invalid) {
                data = nil;
        } else {
                for (FHLynxTemplateConfig *templateConfig in channelConfig.iOS.templateConfigList) {
                    NSString *fileName = templateConfig.templateName;
                    if ([templateKey isEqualToString:templateConfig.templateKey]
                        && (channelConfig.version == version || version == 0)) {
                        
                        data = [self getGeckoFileDataWithChannel:channel fileName:fileName];
                        if (!data) {
//                            NSInteger currentFolderInt = [TTKitchen getInt:kTTKLynxCurrentFolderTimeString];
//                            NSString *currentFolderStr = @(currentFolderInt).stringValue;
//                            data = [self getPersistenceFileDataWithChannel:channel fileName:fileName currentFolderStr:currentFolderStr];//这块建立在文件要么全丢要么不丢，不会单独丢失的情况下
                        }
                        [self.templateCache setValue:data forKey:cacheKey];
                        break;
                    }
                }
            }
        });
        costTime = @((CFAbsoluteTimeGetCurrent() - startTime) * 1000);

//        if (!data) {
//            //还是没有拿到数据，检查是否有兜底数据
//            Class<FHLynxDefaultTemplateProtocol> providerClass = [self.defaultProviderDict objectForKey:channel];
//            if ([providerClass conformsToProtocol:@protocol(FHLynxDefaultTemplateProtocol)]) {
//                NSData *templateData = [providerClass defaultTemplateData];
//                if ([templateData isKindOfClass:[NSData class]]) {
//                    [self.templateCache setValue:templateData forKey:cacheKey];
//                    return templateData;
//                }
//            }
//
//            // Url 标志和 Android 端对齐， channel/templateKey
//            NSString* url = [NSString stringWithFormat:@"%@/%@", channel, templateKey];
//            if ([TTKitchen getBOOL:kTTKLynxReSyncEnable]) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSString *path = [self geckoChannelPathWithChannel:channel];
//                    NSArray<NSString *> *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
//                    NSMutableString *string = @"_".mutableCopy;
//                    if ([fileArray count]) {
//                        [fileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                            [string appendFormat:@"%@_",obj];
//                        }];
//                    }
//                    [[HMDTTMonitor defaultManager] hmdTrackService:@"lynx_get_template_failed" metric:nil category:@{@"url" : url, @"folder":string} extra:nil];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (!self.isRetryingSync) {
//                            self.isRetryingSync = YES;
//                            [self syncAllChannel];
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([TTKitchen getFloat:kTTKLynxReSyncInterval] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                self.isRetryingSync = NO;
//                            });
//                        }
//                    });
//                });
//
//            } else {
//                [[HMDTTMonitor defaultManager] hmdTrackService:@"lynx_get_template_failed" metric:nil category:@{@"url" : url} extra:nil];
//            }
//        }
        //模版覆盖率统计
//        NSString *tempUrl = [NSString stringWithFormat:@"%@/%@", channel, templateKey];
//        NSMutableDictionary *trackParams = [NSMutableDictionary dictionary];
//        [trackParams setValue:@"gecko" forKey:@"lynx_fetch_way"];
//        [trackParams setValue:@(data ? 1 : 0) forKey:@"lynx_status"];
//        [trackParams setValue:tempUrl forKey:@"lynx_url"];
//        [trackParams setValue:costTime forKey:@"lynx_cost_time"];
//        [[HMDTTMonitor defaultManager] hmdTrackService:@"lynx_template_fetch_result" metric:nil category:trackParams extra:nil];
//        [BDTrackerProtocol eventV3:@"lynx_template_fetch_result" params:trackParams isDoubleSending:NO];
//        BDALOG_PROTOCOL_INFO_TAG(@"FHLynx", @"获取模版耗时：%@, url:%@", costTime, tempUrl);
    }
    return data;
}

//读取模板的时候使用的。里面包含了key和模板名字的对应信息。
- (FHLynxChannelConfig *)configForChannel:(NSString *)channel {
    pthread_mutex_lock(&_configDictLock);
    FHLynxChannelConfig *channelConfig = [self.totalConfigDict tt_objectForKey:channel ofClass:[FHLynxChannelConfig class]];
    pthread_mutex_unlock(&_configDictLock);
    if (channelConfig) {
        return channelConfig;
    } else {
        NSArray<NSString *> *localChannelConfigArray = [self allChannelArrays];
        
        __block FHLynxChannelConfig *config;
        [localChannelConfigArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:channel]) {
                NSData *data = [self getGeckoFileDataWithChannel:channel fileName:@"config.json"];
                NSDictionary *channelConfigDict = [data btd_jsonDictionary];

                config = [[FHLynxChannelConfig alloc] initWithDictionary:channelConfigDict error:nil];
                
                if (config) {
                    pthread_mutex_lock(&_configDictLock);
                    [self.totalConfigDict setValue:config forKey:channel];
                    pthread_mutex_unlock(&_configDictLock);
                } else {
                    //重新请求一下channel
                    if (self.tryForMissCount < 3) {
                        self.tryForMissCount ++;
                        [self syncAllChannel];
                    }
                    
                    //gecko目录下没有，从持久化目录下读
//                    NSInteger readConfigInt = [TTKitchen getInt:kTTKLynxCurrentFolderTimeString];
//                    NSString *readConfigFolder = @(readConfigInt).stringValue;
//                    NSData *perData = [self getPersistenceFileDataWithChannel:channel fileName:@"config.json" currentFolderStr:readConfigFolder];
//                    NSDictionary *perConfigDict = [perData btd_jsonDictionary];
//                    config = [[FHLynxChannelConfig alloc] initWithDictionary:perConfigDict error:nil];
//                    if (config) {
//                        if (config.version < obj.minSupportTemplateVersion) {
//                            config.invalid = YES;
//                        } else {
//                            config.invalid = NO;
//                        }
//                        pthread_mutex_lock(&_configDictLock);
//                        [self.totalConfigDict setValue:config forKey:channel];
//                        pthread_mutex_unlock(&_configDictLock);
//                    }
                }
                *stop = YES;
            }
        }];
        
        return config;
    }
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
        
        FHLynxChannelConfig *config = [[FHLynxChannelConfig alloc] initWithDictionary:channelConfigDict error:nil];
        
        if (config) {
     
                isAsync = YES;
                dispatch_group_async(read_group, self.lynx_io_queue, ^{
                    config.invalid = NO;
                    NSMutableDictionary *asyncDict = [NSMutableDictionary dictionary];
                    for (FHLynxTemplateConfig *templateConfig in config.iOS.templateConfigList) {
                        NSString *templateKey = templateConfig.templateKey;
                        NSString *cacheKey = [self cacheKeyForChannel:channel templateKey:templateKey version:config.version];
                        NSString *fileName = templateConfig.templateName;
                        NSData *templateData = [self getGeckoFileDataWithChannel:channel fileName:fileName];
                        [asyncDict setValue:templateData forKey:cacheKey];
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.templateCache addEntriesFromDictionary:asyncDict];
                        pthread_mutex_lock(&self->_configDictLock);
                        [self.totalConfigDict setValue:config forKey:channel];
                        pthread_mutex_unlock(&self->_configDictLock);
                        
                    });
                });
        }
    }
    
    //时机问题
    void(^versionBlock)(void) = ^(void) {
        NSMutableDictionary *versionDict = [NSMutableDictionary dictionary];
        pthread_mutex_lock(&self->_configDictLock);
        [self.totalConfigDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, FHLynxChannelConfig * _Nonnull obj, BOOL * _Nonnull stop) {
            [versionDict setValue:@(obj.version) forKey:key];
        }];
        pthread_mutex_unlock(&self->_configDictLock);
        
        //同步到特定目录。
        if ([changedChannels count]) {
            dispatch_async(self.lynx_io_queue, ^{
                //需要同步
                pthread_mutex_lock(&self->_configDictLock);
                [self.totalConfigDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull channel, FHLynxChannelConfig * _Nonnull channelConfig, BOOL * _Nonnull stop) {
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
    return @[@"lynx_test"];
}

@end
