//
//  STPersistence.m
//  STKit
//
//  Created by SunJiangting on 13-12-8.
//  Copyright (c) 2013年 SunJiangting. All rights reserved.
//

#import "STPersistence.h"
#import "NSStringAdditions.h"
#import "NSObject+TTAdditions.h"

NSString *STPersistDocumentDirectory(void) {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *persistPath = [directory stringByAppendingPathComponent:@"STPreferences"];
    BOOL direct;
    BOOL exists = [manager fileExistsAtPath:persistPath isDirectory:&direct];
    if (!exists) {
        [manager createDirectoryAtPath:persistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return persistPath;
}

NSString *STPersistLibiaryDirectory(void) {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *persistPath = [directory stringByAppendingPathComponent:@"STPreferences"];
    BOOL direct;
    BOOL exists = [manager fileExistsAtPath:persistPath isDirectory:&direct];
    if (!exists) {
        [manager createDirectoryAtPath:persistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return persistPath;
}

NSString *STPersistCacheDirectory(void) {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *persistPath = [directory stringByAppendingPathComponent:@"STPreferences"];
    BOOL direct;
    BOOL exists = [manager fileExistsAtPath:persistPath isDirectory:&direct];
    if (!exists) {
        [manager createDirectoryAtPath:persistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return persistPath;
}

NSString *STPersistTemporyDirectory(void) {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *persistPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"STPreferences"];
    BOOL direct;
    BOOL exists = [manager fileExistsAtPath:persistPath isDirectory:&direct];
    if (!exists) {
        [manager createDirectoryAtPath:persistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return persistPath;
}


@interface STPersistence ()

@property(nonatomic, copy) NSString *cacheFileDirectory;
@property(nonatomic, strong) NSFileManager  *fileManager;

@end

@implementation STPersistence

+ (BOOL)writeValue:(id)value forKey:(NSString *)key toFile:(NSString *)path {
    if (key.length == 0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!value) {
        return [fileManager removeItemAtPath:path error:nil];
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [dictionary setValue:value forKey:@"data"];
    [dictionary setValue:key forKey:@"key"];
    return [dictionary writeToFile:path atomically:YES];
}

+ (id)valueForKey:(NSString *)key inFile:(NSString *)path {
    if (key.length == 0 || path.length == 0) {
        return nil;
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    if ([dictionary[@"key"] isEqualToString:key]) {
        return dictionary[@"data"];
    }
    return nil;
}

- (instancetype)init {
    return [self initWithDirectory:STPersistenceDirectoryLibiary subpath:nil];
}

- (instancetype)initWithDirectory:(STPersistenceDirectory)directory subpath:(NSString *)subpath {
    self = [super init];
    if (self) {
        self.cacheFileDirectory =[self _persistPath:subpath inDirectory:directory];
        if (!self.cacheFileDirectory) {
            self = nil;
        }
        self.fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

- (NSString *)cacheDirectory {
    return _cacheFileDirectory;
}

- (NSString *)cachedPathForKey:(NSString *)key {
    return [self.cacheDirectory stringByAppendingPathComponent:key.MD5HashString];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    NSString *path = [self cachedPathForKey:key];
    [[self class] writeValue:value forKey:key toFile:path];
}

- (id)valueForKey:(NSString *)key {
    NSString *path = [self cachedPathForKey:key];
    return [[self class] valueForKey:key inFile:path];
}

- (NSString *)_persistPath:(NSString *)subpath inDirectory:(STPersistenceDirectory)directory {
    NSString *domain = nil;
    switch (directory) {
        case STPersistenceDirectoryDocument:
            domain = STPersistDocumentDirectory();
            break;
        case STPersistenceDirectoryLibiary:
            domain = STPersistLibiaryDirectory();
            break;
        case STPersistenceDirectoryTemporary:
            domain = STPersistTemporyDirectory();
            break;
        case STPersistenceDirectoryCache:
        default:
            domain = STPersistCacheDirectory();
            break;
    }
    if (subpath.length == 0) {
        return domain;
    }
    NSString *path = [domain stringByAppendingPathComponent:subpath];
    BOOL isDirectory = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (isExists) {
        if (!isDirectory) {
            return domain;
        }
        return path;
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    return path;
}

@end

@interface _STUserDefaults : STPersistence

@property(nonatomic, copy) NSString *filePath;
- (instancetype)initWithName:(NSString *)name;
- (void)resetPersistence;

@end


@implementation STPersistence (STFileBased)

static _STUserDefaults *_userDefaults;
+ (instancetype)standardPersistence {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userDefaults = [[_STUserDefaults alloc] init];
    });
    return _userDefaults;
}

static NSMutableDictionary *_persistences;
+ (instancetype)persistenceNamed:(NSString *)name {
    if (name.length == 0) {
        return [self standardPersistence];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _persistences = [NSMutableDictionary dictionaryWithCapacity:1];
    });
    if (![_persistences valueForKey:name]) {
        @synchronized(_persistences) {
            _STUserDefaults *userDefaults = [[_STUserDefaults alloc] initWithName:name];
            if (![_persistences valueForKey:name]) {
                [_persistences setValue:userDefaults forKey:name];
            }
        }
    }
    return [_persistences valueForKey:name];
}

@end

@implementation _STUserDefaults

- (instancetype)initWithName:(NSString *)name {
    self = [super initWithDirectory:STPersistenceDirectoryLibiary subpath:nil];
    if (name.length == 0) {
        name = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@".plist"];
    } else {
        if (![name hasSuffix:@".plist"]) {
            name = [name stringByAppendingString:@".plist"];
        }
    }
    if (self) {
        self.filePath = [self.cacheDirectory stringByAppendingPathComponent:name];
    }
    return self;
}

- (instancetype)initWithDirectory:(STPersistenceDirectory)directory subpath:(NSString *)subpath {
    return [self initWithName:nil];
}

- (NSString *)description {
    return @"STPersistence";
}

+ (NSString *)description {
    return @"STPersistence";
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    NSMutableDictionary *dictionary;
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:_filePath];
    if ([defaults isKindOfClass:[NSDictionary class]]) {
        dictionary = [defaults mutableCopy];
    }
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    [dictionary setValue:value forKey:key];
    [dictionary writeToFile:_filePath atomically:YES];
}

- (id)valueForKey:(NSString *)key {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:_filePath];
    return [dictionary valueForKey:key];
}

- (void)resetPersistence {
    NSDictionary *dictionary = @{};
    [dictionary writeToFile:_filePath atomically:YES];
}

+ (Class)superclass {
    return [STPersistence superclass];
}

+ (Class)class {
    return [STPersistence class];
}

@end

@implementation STPersistence (STPersistCreation)

+ (instancetype)documentPersistence {
    return [self documentPersistenceWithSubpath:nil];
}


+ (instancetype)cachePersistence {
    return [self cachePersistenceWithSubpath:nil];
}

+ (instancetype)libiaryPersistence {
    return [self libiaryPersistenceWithSubpath:nil];
}

+ (instancetype)tempoaryPersistence {
    return [self tempoaryPersistenceWithSubpath:nil];
}

+ (instancetype)documentPersistenceWithSubpath:(NSString *)subpath {
    return [[self alloc] initWithDirectory:STPersistenceDirectoryDocument subpath:subpath];
}

+ (instancetype)libiaryPersistenceWithSubpath:(NSString *)subpath {
    return [[self alloc] initWithDirectory:STPersistenceDirectoryLibiary subpath:subpath];
}

+ (instancetype)cachePersistenceWithSubpath:(NSString *)subpath {
    return [[self alloc] initWithDirectory:STPersistenceDirectoryCache subpath:subpath];
}

+ (instancetype)tempoaryPersistenceWithSubpath:(NSString *)subpath {
    return [[self alloc] initWithDirectory:STPersistenceDirectoryTemporary subpath:subpath];
}

@end

@implementation STPersistence (STPersistenceClean)

- (void)removeAllCachedValues {
    if ([self respondsToSelector:@selector(resetPersistence)]) {
        [self performSelector:@selector(resetPersistence) withObjects:nil, nil];
        return;
    }
    
    NSString *directory = self.cacheDirectory;
    NSDirectoryEnumerator *enumerator = [self.fileManager enumeratorAtPath:directory];
    // 先清空子目录，最后删除文件夹
    for (NSString *itemPath in enumerator) {
        BOOL isDirectory = NO;
        @autoreleasepool {
            NSString *path = [directory stringByAppendingPathComponent:itemPath];
            if ([self.fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
                if (!isDirectory) {
                    [self.fileManager removeItemAtPath:path error:nil];
                }
            }
        }
    }
    NSArray *directories = [self.fileManager contentsOfDirectoryAtPath:directory error:nil];
    for (NSString *subname in directories) {
        @autoreleasepool {
            NSString *subpath = [directory stringByAppendingPathComponent:subname];
            [self.fileManager removeItemAtPath:subpath error:nil];
        }
    }
}


- (void)removeCachedValuesSinceDate:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }
    NSURL *diskCacheURL = [NSURL fileURLWithPath:[self cacheDirectory] isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        BOOL shouldDelete = !modificationDate || ([modificationDate timeIntervalSinceDate:date] < 0);
        if (shouldDelete) {
            [urlsToDelete addObject:fileURL];
        }
    }
    for (NSURL *fileURL in urlsToDelete) {
        [self.fileManager removeItemAtURL:fileURL error:nil];
    }
}

@end
