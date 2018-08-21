//
//  SKFileManger.h
//  homework
//
//  Created by panxiang on 14-4-23.
//  Copyright (c) 2014年 panxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum SKDirectory
{
    SKDirectory_default         = 0, // SKDirectory_default = SKDirectory_libraryCache
    SKDirectory_document        = 1,
    SKDirectory_libraryCache    = 2,
    SKDirectory_temp            = 3,
}
SKDirectory;

@interface TTFileManager : NSObject<Singleton>
#pragma mark ============= 沙盒文件夹便利获取 =============
- (NSString *)documentPath;
- (NSString *)libraryCachePath;
- (NSString *)tempPath;
- (NSString *)defaultPath;
- (BOOL)createDirectoryWithName:(NSString *)directory inDic:(SKDirectory)parent;
#pragma mark ============= 存储读取 =============
- (void)storeObject:(NSObject *)object inDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName;
- (id)readObjectFromDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName;
- (void)deleteObjectFromDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName;
- (void)deleteObjectsFromDirectory:(SKDirectory)directroy inSubDirectory:(NSString *)directrory;

+ (void)cleanExpirationFileFromDirectroy:(SKDirectory)directroy inSubDirectory:(NSString *)sub expiration:(NSUInteger)expiration;

- (NSArray *)contentsOfDirectoryInDirectory:(SKDirectory)directroy;
#pragma mark ============= 异步存储读取 TODO =============
//- (void)storeObjectAsync:(NSObject *)object inDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName;
//- (id)readObjectAsyncFromDirectroy:(SKDirectory)directroy fileName:(NSString *)fileName;
- (void)removeAllCache;
@end
