//
//  SSTrashManager.m
//  Article
//
//  Created by SunJiangting on 14-11-25.
//
//

#import "SSTrashManager.h"

NSString *const SSTrashFileName = @".SSTrash";
static NSString * SSTrashDirectory() {
//    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = cachePaths[0];
//    NSString *cacheDirectory = [cachePath stringByAppendingPathComponent:SSTrashFileName];
    NSString *temporaryDirectory = NSTemporaryDirectory() ?: [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *trashDirectory = [temporaryDirectory stringByAppendingString:SSTrashFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:trashDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:trashDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return trashDirectory;
}

@interface SSTrashManager ()

@property(nonatomic, strong) dispatch_queue_t   backgroundQueue;
@property(nonatomic, strong) NSFileManager      *fileManager;

@end

@implementation SSTrashManager {
    BOOL    _isEmptying;
    BOOL    _isCancelled;
}

+ (void)initialize {
    [self sharedManager];
}

static SSTrashManager *_sharedManager;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fileManager = NSFileManager.new;
        self.backgroundQueue = dispatch_queue_create("com.bytdance.dispatch.queue.trash", NULL);
        self.tryEmptyTrashWhenEnterBackground = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
/// 移到废纸篓
- (BOOL)trashItemAtPath:(NSString *)path resultingItemPath:(NSString **)outResultingPath error:(NSError **)error {
    if (![self.fileManager fileExistsAtPath:path]) {
        return NO;
    }
    NSString *trashDirectory = SSTrashDirectory();
    // 每次创建一个新的文件夹，按照时间命名，防止如果上一次未删除，下一个文件又移动过来，导致的move失败
    NSString *name = [self.fileManager displayNameAtPath:path];
    NSString *tempPath = [trashDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld",(long long)[[NSDate date] timeIntervalSince1970]]];
    if (![self.fileManager fileExistsAtPath:tempPath]) {
        [self.fileManager createDirectoryAtPath:tempPath  withIntermediateDirectories:YES attributes:nil error:NULL];
    }
                        
    NSString *destPath = [tempPath stringByAppendingPathComponent:name];
    BOOL trashed = [self.fileManager moveItemAtPath:path toPath:destPath error:error];
    if (trashed && outResultingPath) {
        *outResultingPath = destPath;
    }
    return trashed;
}

- (BOOL)isEmptying {
    @synchronized(self.class) {
        return _isEmptying;
    }
}

/// 清空废纸篓
- (void)emptyTrashWithCompletionHandler:(void(^)(BOOL))completion {
    if (_isEmptying) {
        return;
    }
    @synchronized(self.class) {
        _isCancelled = NO;
        _isEmptying = YES;
    }
    dispatch_async(self.backgroundQueue, ^{
        NSString *trashDirectory = SSTrashDirectory();
        NSDirectoryEnumerator *enumerator = [self.fileManager enumeratorAtPath:trashDirectory];
        BOOL breaked = NO;
        // 先清空子目录，最后删除文件夹
        for (NSString *itemPath in enumerator) {
            if (_isCancelled) {
                breaked = YES;
                break;
            }
            BOOL isDirectory = NO;
            @autoreleasepool {
                NSString *path = [trashDirectory stringByAppendingPathComponent:itemPath];
                if ([self.fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
                    if (!isDirectory) {
                        [self.fileManager removeItemAtPath:path error:nil];
                    }
                }
            }
        }
        if (breaked) {
            @synchronized(self.class) {
                _isEmptying = NO;
            }
            [self notifyHandlerOnMainThread:completion isFinished:NO];
        } else {
            NSArray *directories = [self.fileManager contentsOfDirectoryAtPath:trashDirectory error:nil];
            for (NSString *subname in directories) {
                @autoreleasepool {
                    NSString *subpath = [trashDirectory stringByAppendingPathComponent:subname];
                    [self.fileManager removeItemAtPath:subpath error:nil];
                }
            }
            @synchronized(self.class) {
                _isEmptying = NO;
            }
            [self notifyHandlerOnMainThread:completion isFinished:YES];
        }
    });
}

- (NSUInteger)trashSize {
    NSString *trashDirectory = SSTrashDirectory();
    NSDirectoryEnumerator *enumerator = [self.fileManager enumeratorAtPath:trashDirectory];
    // 先清空子目录，最后删除文件夹
    NSUInteger totalSize = 0;
    for (NSString *itemPath in enumerator) {
        NSError *error = nil;
        NSString *path = [trashDirectory stringByAppendingPathComponent:itemPath];
        NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:path error:&error];
        if (!error && ![attributes.fileType isEqualToString:NSFileTypeDirectory]) {
            totalSize += attributes.fileSize;
        }
    }
    return totalSize;
}

- (void)notifyHandlerOnMainThread:(void(^)(BOOL))completion isFinished:(BOOL)finished {
    if (!completion) {
        return;
    }
    if ([NSThread isMainThread]) {
        completion(finished);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(finished);
        });
    }
}

- (void)cancel {
    @synchronized(self) {
        _isCancelled = YES;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.tryEmptyTrashWhenEnterBackground && !_isEmptying) {
        [self emptyTrashWithCompletionHandler:NULL];
    }
}

@end
