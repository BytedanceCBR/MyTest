//
//  SSSimpleCache.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/*
 SimpleCache2 文件夹从囧图1.7 开始使用，20120619
 之前的SimpleCache.将删除在垃圾回收时候删除。
 
 */

#import "SSSimpleCache.h"
#import <TTBaseLib/NSStringAdditions.h>
#import <TTImage/TTImageInfosModel.h>
#import <TTBaseLib/TTBaseMacro.h>

#define kCacheMaxDuration 4
#define HashLength 2
#define CacheDictionaryName @"SimpleCache.plist"
#define kCacheSizeKey   @"kCacheSizeKey"

static NSLock * cacheDictLock;
@interface SSSimpleCache()
{
    BOOL _stopGarbageCollection;
}

@property (retain) NSMutableDictionary * cacheDictionary;
@property (retain) NSOperationQueue * operationQueue;
@property (assign) NSTimeInterval defaultTimeoutInterval;


//- (void)reCalculateCacheSize;
- (void)removeItemFromCache:(NSString*)key updateSize:(BOOL)update;
@end

//static SSSimpleCache * _sharedCache = nil;
static NSString * _cacheDirectory = nil;

static inline NSString* CacheDirectory() {
	if(!_cacheDirectory) {
		_cacheDirectory = [[@"SimpleCache2" stringCachePath] copy];
	}
	
	return _cacheDirectory;
}

static inline NSString* cachePathForKey(NSString* key) {
	return [CacheDirectory() stringByAppendingPathComponent:key];
}

static inline NSString * cachePathForKeyWithHashFolder(NSString * key) {
    NSString * path = @"";
    if(HashLength > 0) {
        path = [key length] >= HashLength ? [key substringToIndex:HashLength] : @"";
    }
    path = [path stringByAppendingPathComponent:key];
    return [CacheDirectory() stringByAppendingPathComponent:path];
}


@implementation SSSimpleCache

@synthesize cacheDictionary = _cacheDictionary;
@synthesize operationQueue = _operationQueue;
@synthesize defaultTimeoutInterval = _defaultTimeoutInterval;

+ (SSSimpleCache *)sharedCache
{
    static dispatch_once_t onceToken;
    static SSSimpleCache * shareManager;
    
    dispatch_once(&onceToken, ^{
        shareManager = [[SSSimpleCache alloc] init];
    });
    
    return shareManager;
}

+ (void)initialize
{
    if (!cacheDictLock) {
        cacheDictLock = [[NSLock alloc] init];
    }
}

- (void)dealloc
{
    self.cacheDictionary = nil;
    self.operationQueue = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _stopGarbageCollection = NO;
        
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:cachePathForKey(CacheDictionaryName)];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            _cacheDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
        }
        else {
            _cacheDictionary = [[NSMutableDictionary alloc] init];
        }
        
        _operationQueue = [[NSOperationQueue alloc] init];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:CacheDirectory() withIntermediateDirectories:YES attributes:nil error:NULL];
        
        self.defaultTimeoutInterval = 3600*24*7;
        
    }
    return self;
}

#pragma mark -- save
- (void)saveCacheDictionary
{

    if ([cacheDictLock tryLock]) {
        [_cacheDictionary writeToFile:cachePathForKey(CacheDictionaryName) atomically:YES];
        [cacheDictLock unlock];
    }

}

- (void)removeCacheDictItemForKey:(NSString *)key
{
    if ([cacheDictLock tryLock]) {
        [_cacheDictionary removeObjectForKey:key];
        [cacheDictLock unlock];
    }
}

- (void)addCacheDictObj:(id)obj key:(NSString *)key
{
    if ([cacheDictLock tryLock]) {
        [_cacheDictionary setObject:obj forKey:key];
        [cacheDictLock unlock];
    }
}

- (void)writeData:(NSData *)data toPath:(NSString *)path
{
    if (HashLength > 0) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
	[data writeToFile:path atomically:YES];
    
    NSError *error = nil;
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if(!error)
    {
        float size = [SSSimpleCache cacheSize];
        size += [[dict objectForKey:NSFileSize] unsignedLongLongValue] / (1024.f * 1024);
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:size] forKey:kCacheSizeKey];
    }
}


- (void)saveAfterDelay { // Prevents multiple-rapid saves from happening, which will slow down your app
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveCacheDictionary) object:nil];
	[self performSelector:@selector(saveCacheDictionary) withObject:nil afterDelay:0.3];
}

//asynchronous method

- (void)setData:(NSData *)data forImageInfosModel:(TTImageInfosModel *)model
{
//    [self setData:data forKey:model.URI withTimeoutInterval:self.defaultTimeoutInterval];
    if (isEmptyString(model.URI)) {
        return;
    }
    [self setData:data forMD5Key:[model.URI MD5HashString] withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setData:(NSData*)data forKey:(NSString*)key
{
//	[self setData:data forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
    if (isEmptyString(key)) {
        return;
    }
    [self setData:data forMD5Key:[key MD5HashString] withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    //	[self setData:data forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
    if (isEmptyString(key)) {
        return;
    }
    NSTimeInterval time = timeoutInterval > 0? timeoutInterval:self.defaultTimeoutInterval;
    [self setData:data forMD5Key:[key MD5HashString] withTimeoutInterval:time];
}

- (void)setData:(NSData *)data forImageInfosModel:(TTImageInfosModel *)model withTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    //    [self setData:data forKey:model.URI withTimeoutInterval:self.defaultTimeoutInterval];
    if (isEmptyString(model.URI)) {
        return;
    }
    NSTimeInterval time = timeoutInterval > 0? timeoutInterval:self.defaultTimeoutInterval;
    [self setData:data forMD5Key:[model.URI MD5HashString] withTimeoutInterval:time];
}

- (void)setData:(NSData*)data forMD5Key:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval
{ 
//    if (data == nil) return;
    
    if (![data isKindOfClass:[NSData class]] || isEmptyString(key)) {
        return;
    }
    
//    NSString * real_key = [key MD5HashString];
    NSString *cachePath = cachePathForKeyWithHashFolder(key);
    
    NSInvocation * writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
    [writeInvocation setTarget:self];
    [writeInvocation setSelector:@selector(writeData:toPath:)];
    [writeInvocation setArgument:&data atIndex:2];
    [writeInvocation setArgument:&cachePath atIndex:3];
    
    [self performDiskWriteOperation:writeInvocation];
    
    [self addCacheDictObj:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] key:key];
    
    [self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES]; // Need to make sure the save delay get scheduled in the main runloop, not the current threads
    
}

#pragma mark -- delete

- (void)deletePreviousVersionCache
{
    // for "SimpleCache"
    NSString * oldFolder = [@"SimpleCache" stringCachePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldFolder] && !_stopGarbageCollection) {
        NSDirectoryEnumerator * dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:oldFolder];
        NSString *file;
        while (file = [dirEnum nextObject]) {
            if (_stopGarbageCollection) {
                break;
            }
            [[NSFileManager defaultManager] removeItemAtPath:[oldFolder stringByAppendingPathComponent:file] error:NULL];
        }
    }
}

- (void)deleteDataByKeyArrayAndSavePathDictionary:(NSArray *)keyArray
{
    for (NSString * key in keyArray) {
        if (_stopGarbageCollection) {
            break;
        }
        [[NSFileManager defaultManager] removeItemAtPath:cachePathForKeyWithHashFolder(key) error:NULL];
        [self removeCacheDictItemForKey:key];
    }
    [self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES]; // Need to make sure the save delay get scheduled in the main runloop, not the current threads
    
    [self deletePreviousVersionCache];
}

- (void)deleteDataAtPath:(NSString *)path
{
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)startGarbageCollection
{
    _stopGarbageCollection = NO;
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        UIApplication *app = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier taskId;
        taskId = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:taskId];
        }];
        
        if (taskId == UIBackgroundTaskInvalid) {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary * cacheDict = [_cacheDictionary copy];
            for (NSString * key in [cacheDict allKeys]) {
                if (_stopGarbageCollection) {
                    break;
                }
                NSDate * date = [cacheDict objectForKey:key];
                if ([[[NSDate date] earlierDate:date] isEqualToDate:date]) {
                    [[NSFileManager defaultManager] removeItemAtPath:cachePathForKeyWithHashFolder(key) error:NULL];
                    [self removeCacheDictItemForKey:key];
                }
            }
            [self performSelectorOnMainThread:@selector(saveCacheDictionary) withObject:nil waitUntilDone:YES];
            
            NSString * forderPath = CacheDirectory();
            NSArray * forderAry = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:forderPath error:nil];
            for (NSString * forderNameStr in forderAry) {
                NSString * sonForderPath = [forderPath stringByAppendingPathComponent:forderNameStr];
                BOOL isDirectory = NO;
                [[NSFileManager defaultManager] fileExistsAtPath:sonForderPath isDirectory:&isDirectory];
                if (isDirectory && [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sonForderPath error:nil] count] == 0) {
                    [[NSFileManager defaultManager] removeItemAtPath:sonForderPath error:nil];
                }
            }
            
            [self deletePreviousVersionCache];
            
            [app endBackgroundTask:taskId];
        });
        
    }
    else {
        
        NSDictionary * cacheDict = [_cacheDictionary copy];
        NSArray * ary = [cacheDict allKeys];
        NSInvocation * deleteInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(deleteDataByKeyArrayAndSavePathDictionary:)]];
        [deleteInvocation setTarget:self];
        [deleteInvocation setSelector:@selector(deleteDataByKeyArrayAndSavePathDictionary:)];
        [deleteInvocation setArgument:&ary atIndex:2];
        [self performDiskWriteOperation:deleteInvocation];
    }
}

- (void)enterBackgroundClear
{
    NSTimeInterval startInterval = [[NSDate date] timeIntervalSince1970];
    int count = 0;
    NSDictionary * cacheDict = [_cacheDictionary copy];
    NSMutableArray* deleteKeys = [NSMutableArray array];
    for (NSString * key in [cacheDict allKeys]) {
        
        //此处添加时间限制，如果一次调用时间超过了SDImageCacheMaxDuration秒，则终止本次清理。
        count ++;
        if (count % 40 == 0) {
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            if (now - startInterval >= kCacheMaxDuration) {
                break;
            }
        }

        NSDate * date = [cacheDict objectForKey:key];
        if ([[[NSDate date] earlierDate:date] isEqualToDate:date]) {
            if (!isEmptyString(key)) {
                [deleteKeys addObject:key];
            }
        }
    }
    //清楚过期key的缓存
    [deleteKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isEmptyString(key)) {
            [[NSFileManager defaultManager] removeItemAtPath:cachePathForKeyWithHashFolder(key) error:NULL];
            [self removeCacheDictItemForKey:key];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self saveCacheDictionary];
    });
    
    NSString * forderPath = CacheDirectory();
    NSArray * forderAry = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:forderPath error:nil];
    for (NSString * forderNameStr in forderAry) {
        NSString * sonForderPath = [forderPath stringByAppendingPathComponent:forderNameStr];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:sonForderPath isDirectory:&isDirectory];
        if (isDirectory && [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sonForderPath error:nil] count] == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:sonForderPath error:nil];
        }
    }
    
    [self deletePreviousVersionCache];
}

- (void)clearCache
{
    NSDictionary * cacheDict = [_cacheDictionary copy];
    
    for(NSString* key in [cacheDict allKeys]) {
		[self removeItemFromCache:key updateSize:NO];
	}
    [self saveCacheDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:.0f] forKey:kCacheSizeKey];
    SSLog(@"cache size:0");
}

- (void)removeCacheForUrl:(NSString *)url
{
    NSString * real_key = [url MD5HashString];
	[self removeItemFromCache:real_key updateSize:YES];
	[self saveCacheDictionary];
}


#pragma mark -- operation
- (void)performDiskWriteOperation:(NSInvocation *)invoction
{
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invoction];
	[_operationQueue addOperation:operation];
}

- (void)removeItemFromCache:(NSString*)key updateSize:(BOOL)update
{
    NSString* cachePath = cachePathForKeyWithHashFolder(key);
	
	NSInvocation* deleteInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(deleteDataAtPath:)]];
	[deleteInvocation setTarget:self];
	[deleteInvocation setSelector:@selector(deleteDataAtPath:)];
	[deleteInvocation setArgument:&cachePath atIndex:2];
	
	[self performDiskWriteOperation:deleteInvocation];
    [self removeCacheDictItemForKey:key];
    if(update)
    {
        NSError *error = nil;
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:&error];
        if(!error)
        {
            float fileSize = [[dict objectForKey:NSFileSize] unsignedLongLongValue] / (1024.f * 1024);
            float cacheSize = [SSSimpleCache cacheSize];
            cacheSize = cacheSize > fileSize ? cacheSize - fileSize : 0;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:cacheSize] forKey:kCacheSizeKey];
            SSLog(@"cache size:%f", cacheSize);
        }
    }
}

///...
#pragma mark - Video Cache

- (void)setData:(NSData *)data forVideoId:(NSString *)videoId
{
    NSString *key = [[videoId MD5HashString] stringByAppendingPathExtension:@"mp4"];
    [self setData:data forMD5Key:key withTimeoutInterval:self.defaultTimeoutInterval];
}

+ (BOOL)isVideoCacheExistWithVideoId:(NSString *)videoId
{
    if (isEmptyString(videoId)) {
        return NO;
    }
    NSString *key = [[videoId MD5HashString] stringByAppendingPathExtension:@"mp4"];
    return [[SSSimpleCache sharedCache] isCacheExistWithMD5Key:key];
}

+ (NSString *)cachePath4VideoWithVideoId:(NSString *)videoId
{
    if (isEmptyString(videoId)) {
        return nil;
    }
    NSString *key = [[videoId MD5HashString] stringByAppendingPathExtension:@"mp4"];
    NSString *cachePath = cachePathForKeyWithHashFolder(key);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        return cachePath;
    }
    return nil;
}

#pragma mark -- judge

- (BOOL)quickCheckIsCacheExist:(NSString *)url
{
    if (isEmptyString(url)) {
        return NO;
    }
    NSString * real_key = [url MD5HashString];
    if ([_cacheDictionary objectForKey:real_key] != nil) {
        return YES;
    }
    return NO;
}

- (BOOL)quickCheckIsImageInfosModelExist:(TTImageInfosModel *)model
{
    return [self quickCheckIsCacheExist:model.URI];
}

- (BOOL)isCacheExist:(NSString *)url
{
    if (isEmptyString(url)) {
        return NO;
    }

    NSString * real_key = [url MD5HashString];
    
    return [self isCacheExistWithMD5Key:real_key];
}

- (NSString *)fileCachePathIfExist:(NSString *)url
{
    if ([url length] == 0) {
        return nil;
    }
    
    NSString * real_key = [url MD5HashString];
    NSString * cacheFile = cachePathForKeyWithHashFolder(real_key);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile]) {
        return cacheFile;
    }
    return nil;
}

- (NSString *)imageInfoModelCachePathIfExist:(TTImageInfosModel *)model
{
    return [self fileCachePathIfExist:model.URI];
}

- (BOOL)isImageInfosModelCacheExist:(TTImageInfosModel *)model
{
    if (![model isKindOfClass:[TTImageInfosModel class]]) {
        return NO;
    }
    return [self isCacheExist:model.URI];
}

- (BOOL)isImageCacheExist:(NSString *)uri
{
    if (isEmptyString(uri)) {
        return NO;
    }
    return [self isCacheExist:uri];
}

- (BOOL)isCacheExistWithMD5Key:(NSString *)md5Key
{
    if (isEmptyString(md5Key)) {
        return NO;
    }
    
    NSString *cachedFilePath = cachePathForKeyWithHashFolder(md5Key);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedFilePath]) {
        return YES;
    }
    return NO;
}

#pragma mark -- get

- (NSData *)dataForURLAndHeaders:(NSArray *)URLAndHeaders
{
    if ([URLAndHeaders count] == 0) {
        return nil;
    }
    for (int i = 0; i < [URLAndHeaders count]; i++) {
        NSData * data = [self dataForUrl:[[URLAndHeaders objectAtIndex:i] objectForKey:@"url"]];
        if (data != nil) {
            return data;
        }
    }
    return nil;
}

- (NSData *)dataForUrl:(NSString *)url
{
    if ([url length] == 0) {
        return nil;
    }
    NSString * real_key = [url MD5HashString];
	if (![self isCacheExist:real_key]) {
		return [NSData dataWithContentsOfFile:cachePathForKeyWithHashFolder(real_key) options:0 error:NULL];
	}
    else {
		return nil;
	}
}

- (NSData *)dataForImageInfosModel:(TTImageInfosModel *)model
{
    if ([model.URI length] > 0) {
        return [self dataForUrl:model.URI];
    }
    return nil;
}

#pragma mark -- control

//- (void)enterForegroundClear
//{
//    _stopGarbageCollection = YES;
//}

- (void)stopGarbageCollection
{
    _stopGarbageCollection = YES;
}

#pragma mark - cache size
+ (void)reCalculateCacheSize
{
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:cachePathForKey(@"SimpleCache.plist")];
    float fileSize = [[dict allKeys] count] * 5 * 1024;
    NSNumber *size = [NSNumber numberWithFloat:fileSize / (float)(1024 * 1024)];
    [[NSUserDefaults standardUserDefaults] setObject:size forKey:kCacheSizeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)hasCacheSize
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSizeKey] != nil;
}

+ (float)cacheSize
{
    @synchronized(self)
    {
        if(![SSSimpleCache hasCacheSize])
        {
            [SSSimpleCache reCalculateCacheSize];
        }
    }
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kCacheSizeKey] floatValue];
}

@end
