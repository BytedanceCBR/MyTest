//
//  TTCanvasBundleManager.m
//  Article
//
//  Created by yin on 2017/1/3.
//
//

#import "NSStringAdditions.h"
#import "SSZipArchive.h"
#import "TTAdCanvasManager.h"
#import "TTAdManager.h"
#import "TTCanvasBundleManager.h"
#import "TTStringHelper.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const kCanvasBundleRoot = @"com.bytedance.canvasbundles";
static NSString *const kCanvasBundleZip = @"canvasbundle.zip";
static NSString *const kCanvasBundleMainFileName = @"index.ios.canvas.bundle";
static NSString *const kCanvasBundleVersionKey = @"kCanvasBundleVersionKey";
static NSString *const kCanvasBundleMD5Key = @"kCanvasBundleMD5Key";
static NSString *const kCanvasBundleVersion = @"0";
static NSString *const kCanvasVersion = @"0.37";

static NSString *const kCanvasAppBundleName = @"index.ios.canvas";
static NSString *const kCanvasAppBundleInfo = @"kCanvasAppBundleInfo";


@interface TTCanvasBundleManager()
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@end

@implementation TTCanvasBundleManager

+ (TTCanvasBundleManager *)sharedInstance {
    static TTCanvasBundleManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTCanvasBundleManager alloc] init];
    });
    return manager;
}

+ (void)downloadIfNeeded:(NSString *)url version:(NSString *)version md5:(NSString *)md5
{
    //先取本地的version，如果没有，则取当前打包版本的版本号。
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kCanvasBundleVersionKey];
    
    if (!localVersion) {
        localVersion = kCanvasBundleVersion;
        [[NSUserDefaults standardUserDefaults] setObject:localVersion forKey:kCanvasBundleVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /*
     * 需要下载的case：
     * 1 返回的js版本号比本地打包或已经下载的版本号大
     * (已废弃)2 返回的js版本号与本地打包的版本号相同，但是主文件不存在或MD5不同
     */
    
    BOOL needDownload = NO;
    
    if ([version intValue] > [localVersion intValue]) {
        needDownload = YES;
    }
    else if ([version intValue] < [localVersion intValue]  ||
             [localVersion intValue] < [kCanvasBundleVersion intValue]) {
        [[TTCanvasBundleManager sharedInstance] deleteAllBundles];
    }
    
    if (needDownload) {
        [[TTCanvasBundleManager sharedInstance] downloadBundle:url version:version md5:md5];
    }
}

- (void)downloadBundle:(NSString *)url version:(NSString *)version md5:(NSString *)md5
{
    NSURL *URL = [TTStringHelper URLWithURLString:url];
    if (!URL) {
        return;
    }
    
    self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 下载失败
        if (error) {
            return;
        }

        NSError *err = nil;
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSString *zipFile = [kCanvasBundleZip stringCachePath];
        NSURL *zipFileURL = [NSURL fileURLWithPath:zipFile];
        
        //删除zip文件
        [defaultManager removeItemAtPath:zipFile error:nil];
        
        
        BOOL copySuccess = [defaultManager moveItemAtURL:location toURL:zipFileURL error:&err];
        // 校验zip包md5是否正确
        if (location != nil && zipFileURL != nil && copySuccess) {
            //The methods of the shared NSFileManager object can be called from multiple threads safely.
            
            if (![self isZipFileMD5EqualTo:md5]) {
                // 删除zip文件
                [defaultManager removeItemAtPath:zipFile error:nil];
                return;
            }
            
            // 目标解压目录
            NSString *unzipFolder = [self bundleFolder];
            
            // 解压文件
            NSString *unzipFolderTmp = [unzipFolder stringByAppendingString:@"_tmp"];
            BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:zipFile toDestination:unzipFolderTmp];
            
            if (unzipSuccess) {
                // 删除之前的版本
                [defaultManager removeItemAtPath:unzipFolder error:nil];
                
                // 移到目标目录
                if ([defaultManager moveItemAtPath:unzipFolderTmp toPath:unzipFolder error:nil]) {
                    //下载成功，更新version，md5
                    //The NSUserDefaults class is thread-safe.
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:kCanvasBundleVersionKey];
                    [[NSUserDefaults standardUserDefaults] setObject:md5 forKey:kCanvasBundleMD5Key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else {
                    [defaultManager removeItemAtPath:unzipFolderTmp error:nil];
                }
            }
            //下载结束再执行下沉浸式bundle
            if ([NSThread isMainThread]) {
                [[TTAdCanvasManager sharedManager] preCreateCanvasView];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[TTAdCanvasManager sharedManager] preCreateCanvasView];
                });
            }
           
            //删除zip文件
            [defaultManager removeItemAtPath:zipFile error:nil];
            
        } else {
            /* Handle the error. */
        }
    }];
    
    [self.downloadTask resume];
}



+ (NSURL *)bundleURL
{
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kCanvasBundleVersionKey];
    
    if ([[self sharedInstance] isBundleCached]) {
        if ([localVersion intValue] > [[[self sharedInstance] bundleVersion] intValue]) {
            return [NSURL URLWithString:[[self sharedInstance] bundlePath]];
        }
    }
    
    return [[NSBundle mainBundle] URLForResource:kCanvasAppBundleName withExtension:@"bundle"];
}

+ (NSURL *)fallbackSourceURL
{
    return [[NSBundle mainBundle] URLForResource:kCanvasAppBundleName withExtension:@"bundle"];
}

// 获取本地bundle路径
- (NSString *)bundleFolder
{
    NSString *cachesPath        = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *folderPath        = [cachesPath stringByAppendingPathComponent:kCanvasBundleRoot];
    return folderPath;
}

- (NSString *)bundlePath
{
    NSString *bundleFolder = [self bundleFolder];
    NSString *bundleName = kCanvasBundleMainFileName;//[url MD5HashString];
    NSString *bundlePath = [bundleFolder stringByAppendingPathComponent:bundleName];
    return bundlePath;
}

- (BOOL)isBundleCached
{
    NSString *bundlePath = [self bundlePath];
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDirectory]) {
        return YES;
    }
    return NO;
}


// 清除本地所有bundle
- (void)deleteAllBundles
{
    NSString *bundleRootPath = [self bundleFolder];
    NSError *error;
    if ([[NSFileManager defaultManager] removeItemAtPath:bundleRootPath error:&error]) {
        [[NSUserDefaults standardUserDefaults] setObject:[self bundleVersion] forKey:kCanvasBundleVersionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        if (error) {
            LOGE(@"%@", error.localizedDescription);
        }
    }
}

- (NSString *)bundleVersion
{
    // 内置版本号
    return kCanvasBundleVersion;
}

+ (NSString *)localVersion {
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kCanvasBundleVersionKey];
    if (!localVersion) {
        localVersion = kCanvasBundleVersion;
    }
    return localVersion;
}

+ (NSString *_Nonnull)RNVersion {
    return kCanvasVersion;
}

- (BOOL)isZipFileMD5EqualTo:(NSString *)md5
{
    
#ifdef INHOUSE
    if (self.isDebug) {
        self.isDebug = NO;
        return YES;
    }
#endif
    
    NSString *zipFile = [kCanvasBundleZip stringCachePath];
    NSData *fileData = [NSData dataWithContentsOfFile:zipFile];
    NSString *fileMD5 = [self md5:fileData];
    
    if ([md5 isEqualToString:fileMD5]) {
        return YES;
    }
    [self monitorTrack:md5 fileMD5:fileMD5];
    return NO;
}

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

- (void)monitorTrack:(NSString*)md5 fileMD5:(NSString*)fileMD5
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:md5 forKey:@"md5"];
    [dict setValue:fileMD5 forKey:@"fileMD5"];
    [TTAdManager monitor_trackService:@"canvasad_md5_notmatch" status:0 extra:dict];
}

+ (TTAdRNBundleInfo *)currentCanvasBundleInfo {
    TTAdRNBundleInfo *bundleInfo = [TTAdRNBundleInfo new];
    bundleInfo.md5 = [[NSUserDefaults standardUserDefaults] stringForKey:kCanvasBundleMD5Key];
    bundleInfo.version = [[NSUserDefaults standardUserDefaults] stringForKey:kCanvasBundleVersionKey];
    //bundleInfo.url =
    return bundleInfo;
}

@end

@implementation TTAdRNBundleInfo
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (NSString *)debugDescription {
    NSMutableString *debugString = [NSMutableString new];
    [debugString appendFormat:@"md5: %@\n", self.md5];
    [debugString appendFormat:@"version: %@", self.version];
    return debugString;
}

@end
