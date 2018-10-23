//
//  TTRNBundleDownloader.m
//  Article
//
//  Created by yangning on 2017/4/28.
//
//

#import "TTRNBundleDownloader.h"
#import "SSZipArchive.h"
#import <CommonCrypto/CommonDigest.h>
#import "DiffMatchPatch.h"
#import "TTRNBundleManager.h"

NSErrorDomain const TTRNBundleDownloaderErrorDomain = @"TTRNBundleDownloaderErrorDomain";

static NSString *const kRNBundleRootDirectoryName   = @"com.bytedance.reactnative";
static NSString *const KRNBundleDirectoryNamePrefix = @"com.bytedance.jsbundles";
static NSString *const kRNBundleMainFileName        = @"index.ios.bundle";

static NSString *const kRNBundleDownloaderLockName  = @"com.bytedance.bundle.downloader.lock";
static NSString *const kRNCommonBundleFileName  = @"common.bundle";
static NSString *const kRNCommonBusinessPatchFileName  = @"business.patch";

@interface TTRNBundleDownloader ()

@property (nonatomic) NSMutableDictionary *URLCallbacks;
@property (nonatomic) NSLock *lock;

@end

@implementation TTRNBundleDownloader

+ (instancetype)sharedDownloader
{
    static TTRNBundleDownloader *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTRNBundleDownloader alloc] init];
    });
    return _sharedInstance;
}

- (void)downloadBundleForModuleName:(NSString *)moduleName
                                url:(NSURL *)url
                            isPatch:(BOOL)isPatch
                          bundleMD5:(nullable NSString *)bundleMD5
                         completion:(nullable TTRNBundleDownloaderCompletionBlock)completion
{
    if (!url) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"url is nil."}];
        if (completion) {
            completion(nil, error);
        }
        return;
    }
        
    BOOL first = NO;
    
    [self.lock lock];
    NSMutableArray *callbacks = self.URLCallbacks[url];
    if (!callbacks) {
        callbacks = [NSMutableArray array];
        self.URLCallbacks[url] = callbacks;
        first = YES;
    }
    
    if (completion) {
        [callbacks addObject:completion];
    }
    [self.lock unlock];
    
    if (!first) {
        return;
    }
    
    WeakSelf;
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable taskError) {
        
        StrongSelf;
        
        [self.lock lock];
        NSArray *callbacks = [self.URLCallbacks[url] copy];
        [self.URLCallbacks removeObjectForKey:url];
        [self.lock unlock];
        
        if (taskError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, taskError);
                }
            });
            return;
        }
        
        NSError *error = nil;
        
        // Check m5
        if (!isEmptyString(bundleMD5)) {
            NSData *fileData = [NSData dataWithContentsOfURL:location];
            NSString *fileMD5 = [self md5:fileData];
            if (![fileMD5 isEqualToString:bundleMD5]) {
                error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"md5 not match"}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                        callback(nil, error);
                    }
                });
                return;
            }
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Detele temp directory if needed
        NSString *tempDirectoryPath = [self tempBundleDirectoryPathForModuleName:moduleName];
        if ([fileManager fileExistsAtPath:tempDirectoryPath] && ![fileManager removeItemAtPath:tempDirectoryPath error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        
        // Create bundle root directory if needed
        NSString *bundleRootDirectory = [self bundleRootDirectory];
        if (![[NSFileManager defaultManager] createDirectoryAtPath:bundleRootDirectory
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"Create bundle root directory error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        
        // Move zip file to temp directory
        NSString *cacheBundlePath = tempDirectoryPath;//[self cacheBundleDirectoryPathForModuleName:moduleName];
        if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheBundlePath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"Create temp directory error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        NSString *zipFilePath = [cacheBundlePath stringByAppendingPathComponent:@"ios.zip"];
        NSURL *zipFileURL = [NSURL fileURLWithPath:zipFilePath];
        if (![fileManager moveItemAtURL:location toURL:zipFileURL error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        
        // Unzip file
        BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:zipFilePath toDestination:cacheBundlePath];
        if (!unzipSuccess) {
            [fileManager removeItemAtPath:cacheBundlePath error:nil];
            error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"unzip file error"}];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        
        [fileManager removeItemAtPath:zipFilePath error:nil];
        
        // Check bundle name
        NSString *mainBundlePath = [cacheBundlePath stringByAppendingPathComponent:kRNBundleMainFileName];
        //common 用这个check
        NSString *mainBundlePath2 = [cacheBundlePath stringByAppendingPathComponent:kRNCommonBundleFileName];

        
        if (isPatch) {
            //get commom bundle
            NSString *commonBundleJSCode = [[NSString alloc] initWithContentsOfFile:[self commonBundlePath] encoding:NSUTF8StringEncoding error:nil];
            if (!commonBundleJSCode) {
                [fileManager removeItemAtPath:cacheBundlePath error:nil];
                error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"get commonBundle failed"}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                        callback(nil, error);
                    }
                });
                return;
            }
            //get patch bundle
            NSString *patchPath = [cacheBundlePath stringByAppendingPathComponent:kRNCommonBusinessPatchFileName];
            NSString *patchJSCode = [[NSString alloc] initWithContentsOfFile:patchPath encoding:NSUTF8StringEncoding error:nil];
            if (!patchJSCode) {
                [fileManager removeItemAtPath:cacheBundlePath error:nil];
                error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"get patchBundle failed"}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                        callback(nil, error);
                    }
                });
                return;
            }
            //merge
            DiffMatchPatch *diffMatchPatch = [[DiffMatchPatch alloc] init];
            NSArray *convertedPatches = [diffMatchPatch patch_fromText:patchJSCode error:nil];
            
            NSArray *resultsArray = [diffMatchPatch patch_apply:convertedPatches toString:commonBundleJSCode];
            if (SSIsEmptyArray(resultsArray) || ![resultsArray firstObject]) {
                [fileManager removeItemAtPath:cacheBundlePath error:nil];
                error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"patch merge failed"}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                        callback(nil, error);
                    }
                });
                return;
            }
            //write to file
            NSString *resultJSCode = [resultsArray firstObject]; //patch合并后的js
            BOOL success = [resultJSCode writeToFile:mainBundlePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (!success) {
                [fileManager removeItemAtPath:cacheBundlePath error:nil];
                error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"write main bundle failed"}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                        callback(nil, error);
                    }
                });
                return;
            }
        }
        
        if (![fileManager fileExistsAtPath:mainBundlePath] && ![fileManager fileExistsAtPath:mainBundlePath2]  ) {
            [fileManager removeItemAtPath:cacheBundlePath error:nil];
            
            error = [NSError errorWithDomain:TTRNBundleDownloaderErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"jsbundle (whose name must be `%@`) NOT found", kRNBundleMainFileName]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        
        // Replace old bundle
        NSString *oldBundleDirectoryPath = [self cacheBundleDirectoryPathForModuleName:moduleName];
        NSString *targetBundleDirectoryPath = oldBundleDirectoryPath;
        if ([fileManager fileExistsAtPath:oldBundleDirectoryPath] && ![fileManager removeItemAtPath:oldBundleDirectoryPath error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        if (![fileManager moveItemAtPath:tempDirectoryPath toPath:targetBundleDirectoryPath error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                    callback(nil, error);
                }
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (TTRNBundleDownloaderCompletionBlock callback in callbacks) {
                callback([targetBundleDirectoryPath stringByAppendingPathComponent:kRNBundleMainFileName], nil);
            }
        });
    }];
    [downloadTask resume];
}

#pragma mark - Cache

- (BOOL)cacheBundleFileExistsForModuleName:(NSString *)moduleName
{
    NSCParameterAssert(!isEmptyString(moduleName));
    if (isEmptyString(moduleName)) {
        return NO;
    }
    if ([moduleName isEqualToString:TTRNCommonBundleName]) {
        return [[NSFileManager defaultManager] fileExistsAtPath:[self commonBundlePath]];
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cacheBundleFilePathForModuleName:moduleName]];
}

- (NSString *)cacheBundleFilePathForModuleName:(NSString *)moduleName
{
    if (isEmptyString(moduleName)) {
        return nil;
    }
    
    return [[self cacheBundleDirectoryPathForModuleName:moduleName] stringByAppendingPathComponent:kRNBundleMainFileName];
}

- (NSString *)cacheBundleDirectoryPathForModuleName:(NSString *)moduleName
{
    if (isEmptyString(moduleName)) {
        return nil;
    }

    return [[self bundleRootDirectory] stringByAppendingPathComponent:[self cachedDirectoryNameForModuleName:moduleName]];
}

- (NSString *)tempBundleDirectoryPathForModuleName:(NSString *)moduleName
{
    if (isEmptyString(moduleName)) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@-1", [self cacheBundleDirectoryPathForModuleName:moduleName]];
}

- (NSString *)bundleRootDirectory
{
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *rootDirectoryPath = [cachesPath stringByAppendingPathComponent:kRNBundleRootDirectoryName];
    return rootDirectoryPath;
}

- (NSString *)commonBundlePath
{
    return [[self cacheBundleDirectoryPathForModuleName:TTRNCommonBundleName] stringByAppendingPathComponent:kRNCommonBundleFileName];
}

- (NSString *)cachedDirectoryNameForModuleName:(NSString *)moduleName
{
    NSCParameterAssert(!isEmptyString(moduleName));
    if (isEmptyString(moduleName)) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@.%@", KRNBundleDirectoryNamePrefix, moduleName];
}

#pragma mark - Custom accessors

- (NSMutableDictionary *)URLCallbacks
{
    if (!_URLCallbacks) {
        _URLCallbacks = [[NSMutableDictionary alloc] init];
    }
    return _URLCallbacks;
}

- (NSLock *)lock
{
    if (_lock) {
        _lock = [[NSLock alloc] init];
        _lock.name = kRNBundleDownloaderLockName;
    }
    return _lock;
}

#pragma mark - Util

- (NSString *)md5:(NSData *)input
{
    const char *cStr = input.bytes;
    unsigned char digest[16];
    CC_MD5(cStr, (int)input.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
