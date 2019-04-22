//
//  SKFileManger.m
//  homework
//
//  Created by panxiang on 14-4-23.
//  Copyright (c) 2014年 panxiang. All rights reserved.
//

#import "TTFileManager.h"

@interface TTFileManager ()
@property (nonatomic, strong) NSString          *documentPath;
@property (nonatomic, strong) NSString          *cachePath;
@property (nonatomic, strong) NSString          *tempPath;
@end
#define kFileManagerStoreDirectory @"com.bytedanche.fastcoding"

@implementation TTFileManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initPath];
        
        [self createDirectory];
        
    }
    return self;
}

- (void)initPath
{
    _documentPath = [[self documentPath] stringByAppendingPathComponent:kFileManagerStoreDirectory];
    _tempPath = [[self tempPath] stringByAppendingPathComponent:kFileManagerStoreDirectory];
    _cachePath = [[self libraryCachePath] stringByAppendingPathComponent:kFileManagerStoreDirectory];
}

- (BOOL)createDirectoryWithName:(NSString *)directory inDic:(SKDirectory)parent
{
    @synchronized(self)
    {
        BOOL isDir = YES;
        NSString *path = [self wholePath:parent fileName:directory];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if (!isDir) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        if (isExist && isDir) {
            return YES;
        }
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

- (void)createDirectory
{
    @synchronized(self)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:self.documentPath])
        {
            [fileManager createDirectoryAtPath:self.documentPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if(![fileManager fileExistsAtPath:self.tempPath])
        {
            [fileManager createDirectoryAtPath:self.tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if(![fileManager fileExistsAtPath:self.cachePath])
        {
            [fileManager createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    

}

/*
 Documents 目录：您应该将所有的应用程序数据文件写入到这个目录下。这个目录用于存储用户数据或其它应该定期备份的信息。
 */

- (NSString *)documentPath
{
    if (_documentPath) {
        return _documentPath;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return docDir;
}

/*
 * Library 目录：这个目录下有两个子目录：Caches 和 Preferences
 Preferences 目录：包含应用程序的偏好设置文件。您不应该直接创建偏好设置文件，而是应该使用NSUserDefaults类来取得和设置应用程序的偏好.
 Caches 目录：用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
 */
- (NSString *)libraryCachePath
{
    if (_cachePath) {
        return _cachePath;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}

/*
 * tmp 目录：这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。
 */
- (NSString *)tempPath
{
    if (_tempPath) {
        return _tempPath;
    }
    NSString *tmpDir = NSTemporaryDirectory();
    return tmpDir;
}

- (NSString *)defaultPath
{
    return [self tempPath];
}

- (NSString *)directoryPath:(SKDirectory)directory
{
    switch (directory) {
        case SKDirectory_default:
            return _cachePath;
            break;
        case SKDirectory_document:
            return _documentPath;
            break;
        case SKDirectory_libraryCache:
            return _cachePath;
            break;
        case SKDirectory_temp:
            return _tempPath;
            break;
        default:
            return _cachePath;
            break;
    }
}

- (NSString *)wholePath:(SKDirectory)directory fileName:(NSString *)name
{
    NSString * fullPath = [self directoryPath:directory];
    if (name) {
        fullPath = [fullPath stringByAppendingPathComponent:name];
    }
    return fullPath;
}

- (void)storeObject:(NSObject *)object inDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName
{
    @synchronized(self)
    {
        if (object != nil && fileName != nil)
        {
            [NSKeyedArchiver archiveRootObject:object toFile:[self wholePath:directroy fileName:fileName]];
        }
    }

}
- (id)readObjectFromDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName
{
    @synchronized(self)
    {
        id object = nil;
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self wholePath:directroy fileName:fileName]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
        }
        
        return object;
        
    }
}

- (NSArray *)contentsOfDirectoryInDirectory:(SKDirectory)directroy
{
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self wholePath:directroy fileName:nil] error:nil];
    return items;
}

- (void)deleteObjectsFromDirectory:(SKDirectory)directroy inSubDirectory:(NSString *)directrory
{
    @synchronized(self) {
        @try {
            NSString *path = [self wholePath:directroy fileName:directrory];
            NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self wholePath:directroy fileName:directrory] error:nil];
            [items enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                NSString *objPath = [path stringByAppendingPathComponent:obj];
                [[NSFileManager defaultManager] removeItemAtPath:objPath error:nil];
            }];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }

}

- (void)deleteObjectFromDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName
{
    @synchronized(self) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:[self wholePath:directroy fileName:fileName] error:nil];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }

}

+ (void)cleanExpirationFileFromDirectroy:(SKDirectory)directroy inSubDirectory:(NSString *)sub expiration:(NSUInteger)expiration
{
    [self cleanExpirationFileInPath:[[self sharedInstance_tt] wholePath:directroy fileName:sub] expiration:expiration];
}

+ (void)cleanExpirationFileInPath:(NSString *)path expiration:(NSUInteger)expiration
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *diskCacheURL = [NSURL fileURLWithPath:path isDirectory:YES];
    NSArray *resourceKeys = @[ NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                              includingPropertiesForKeys:resourceKeys
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:NULL];
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    for (NSURL *fileURL in fileEnumerator)
    {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue])
        {
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        
        if ([[NSDate date] timeIntervalSinceDate:modificationDate] >= expiration)
        {
            [fileManager removeItemAtURL:fileURL error:nil];
            continue;
        }
    }
}

+ (BOOL)removeFileAtPath:(NSString *)path error:(NSError **)err
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSError *removeError = nil;
        [fileManager removeItemAtPath:path error:&removeError];
        if (removeError) {
            if (err) {
                *err = [NSError errorWithDomain:@"TTFileManager.domain" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to delete file at path '%@'",path],NSLocalizedDescriptionKey,removeError,NSUnderlyingErrorKey,nil]];
            }
            return NO;
        }
    }
    return YES;
}

- (void)removeAllCache
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_cachePath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename = nil;
    while ((filename = [e nextObject])) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[_cachePath stringByAppendingPathComponent:filename] error:NULL];

    }
}


- (void)storeObjectAsync:(NSObject *)object inDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName
{
    
}

- (id)readObjectAsyncFromDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName
{
    return nil;
}
@end
