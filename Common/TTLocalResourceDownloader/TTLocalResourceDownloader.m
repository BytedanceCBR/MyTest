//
//  TTLocalResourceDownloader.m
//  Article
//
//  Created by xushuangqing on 12/09/2017.
//

#import "TTLocalResourceDownloader.h"
#import <TTBaseLib/NSStringAdditions.h>
#import "SSZipArchive.h"
#import <CommonCrypto/CommonDigest.h>
#import <TTReachability/TTReachability.h>
#import <NetworkUtilities.h>
#import <TTImageDownloader.h>
#import <TTVersionHelper.h>

#define kTTLocalResourceZipLocation @"tt_local_resource.zip"
#define kTTLocalResourceUnzipPath @"tt_local_resource"
#define localResourcePath [kTTLocalResourceUnzipPath stringDocumentsPath]

static NSString * const kTTLocalResourceCurrentDownloadedVersionKey = @"kTTLocalResourceCurrentDownloadedVersionKey";
static NSString * const kTTLocalResourceNewVersionKey = @"kTTLocalResourceNewVersionKey";
static NSString * const kTTLocalResourceDownloadURLKey = @"kTTLocalResourceDownloadURLKey";
static NSString * const kTTLocalResourceDownloadMd5Key = @"kTTLocalResourceDownloadMd5Key";
static NSString * const kTTLocalResourceDynamicWebURL = @"kTTLocalResourceDynamicWebURL";

typedef NS_ENUM(NSUInteger, TTReadImageSource) {
    TTReadImageFromZip = 0,
    TTReadImageFromWeb = 1,
    TTReadImageFailed = 2,
};

static NSURLSessionDownloadTask *downloadTask = nil;

@interface TTLocalResourceDownloader()

@end

@implementation TTLocalResourceDownloader

#pragma mark - NSUserDefaults

//当前已知的最新资源包版本
+ (void)setLocalResourceNewVersion:(NSInteger)version {
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:kTTLocalResourceNewVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//当前已知的最新资源包版本
+ (NSInteger)localResourceNewVersion {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kTTLocalResourceNewVersionKey];
}

//当前已下载完毕的资源包版本
+ (void)setLocalResourceCurrentVersion:(NSInteger)currentVersion {
    [[NSUserDefaults standardUserDefaults] setInteger:currentVersion forKey:kTTLocalResourceCurrentDownloadedVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//当前已下载完毕的资源包版本
+ (NSInteger)localResourceCurrentVersion {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kTTLocalResourceCurrentDownloadedVersionKey];
}

//当前已知的最新资源包版本的md5
+ (void)setLocalResourceMd5:(NSString *)md5 {
    if (isEmptyString(md5)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:md5 forKey:kTTLocalResourceDownloadMd5Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//当前已知的最新资源包版本的md5
+ (NSString *)localResourceMd5 {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kTTLocalResourceDownloadMd5Key];
}

//当前已知的最新资源包版本的下载路径
+ (void)setLocalResourceDownloadURL:(NSString *)downloadURL {
    if (isEmptyString(downloadURL)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:downloadURL forKey:kTTLocalResourceDownloadURLKey];
}

//当前已知的最新资源包版本的下载路径
+ (NSString *)localResourceDownloadURL {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kTTLocalResourceDownloadURLKey];
}

//单张图的url前缀
+ (NSString *)dynamicWebURL {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kTTLocalResourceDynamicWebURL];
}

//单张图的url前缀
+ (void)setDynamicWebURL:(NSString *)dynamicWebURL {
    if (isEmptyString(dynamicWebURL)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:dynamicWebURL forKey:kTTLocalResourceDynamicWebURL];
}

//默认的单张图的url前缀
+ (NSString *)defaultWebURL {
    if ([TTDeviceHelper screenScale] >= 3.0) {
        return @"http://s3.pstatp.com/toutiao/resource/tt_ios_app_local_resources/all_3x/";
    }
    else {
        return @"http://s3.pstatp.com/toutiao/resource/tt_ios_app_local_resources/all_2x/";
    }
}

//根据文件名拼出单张图的url
+ (NSString *)webURLForImageName:(NSString *)name {
    if (isEmptyString(name)) {
        return nil;
    }
    
    NSString *urlPrefix = nil;
    NSString *dynamicURL = [self dynamicWebURL];
    if (!isEmptyString(dynamicURL)) {
        urlPrefix = dynamicURL;
    }
    else {
        urlPrefix = [self defaultWebURL];
    }
    
    NSURL *preURL = [NSURL URLWithString:urlPrefix];
    NSURL *fullURL = [preURL URLByAppendingPathComponent:name];
    return [fullURL absoluteString];
}

#pragma mark - life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)downloadAndRetryTimes:(NSInteger)times completion:(void (^ __nullable)(BOOL finished))completion {
    if (times < 0) {
        if (completion) {
            completion(NO);
        };
        return;
    }
    
    [self downloadNewVersionWithCompletion:^(BOOL finished) {
        if (!finished) {
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                StrongSelf;
                [self downloadAndRetryTimes:times-1 completion:completion];
            });
        }
        else {
            if (completion) {
                completion(YES);
            }
        }
    }];
}

//在settings请求返回时调用
//下载策略：立即下载、如果未成功则注册通知，等待网络连接和下次app进入前台
+ (void)checkAndDownloadIfNeed {
    if ([self needDownloadNewVersion]) {
        //下载未成功则重复3次
        [self downloadAndRetryTimes:2 completion:^(BOOL finished) {
            if (!finished) {
                [self registerNotificationsToDownloadLater];
            }
            else {
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [self trackDownloadSuccessTime];
            }
        }];
    }
}

+ (void)trackDownloadSuccessTime {
    double current = [[NSDate date] timeIntervalSince1970];
    double lastTime = [TTVersionHelper lastUpdateTimestamp];
    double gap = current - lastTime;
    [[TTMonitor shareManager] trackService:@"tt_local_image_gap" value:@(gap) extra:nil];
}

#pragma mark - Download

+ (BOOL)needDownloadNewVersion {
    NSInteger currentVersion = [[self class] localResourceCurrentVersion];
    NSInteger resourceNewVersion = [[self class] localResourceNewVersion];
    if (resourceNewVersion > currentVersion) {
        return YES;
    }
    return NO;
}

+ (NSString *)md5:(NSData *)input
{
    const char *cStr = input.bytes;
    
    unsigned char digest[16];
    CC_MD5( cStr, (int)input.length, digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (BOOL)verifyMd5OfJSZipFile {
    NSString* jsZipFile = [kTTLocalResourceZipLocation stringCachePath];
    NSData* fileData = [NSData dataWithContentsOfFile:jsZipFile];
    NSString* md5 = [self md5:fileData];
    
    if ([md5 isEqualToString:[self.class localResourceMd5]]) {
        return YES;
    }
    return NO;
}

+ (void)downloadNewVersionWithCompletion:(void (^ __nullable)(BOOL finished))completion {
    
    //不需要下载新版本资源文件
    if (![self needDownloadNewVersion]) {
        if (completion) {
            completion(YES);
        }
        return;
    }
    
    [downloadTask cancel];
    downloadTask = nil;
    
    //URL无效
    NSString *urlString = [[self class] localResourceDownloadURL];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    //开始下载
    downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //下载成功
            if (!error && location) {
                
                NSError *err = nil;
                NSFileManager *defaultManager = [NSFileManager defaultManager];
                
                NSString *zipFile = [kTTLocalResourceZipLocation stringCachePath];
                NSURL *zipFileURL = [NSURL fileURLWithPath:zipFile];
                
                // 删除上一个zip文件
                [defaultManager removeItemAtPath:zipFile error:nil];
                
                // 将下载的文件从location拷贝到zipFileURL并修改文件名(dictionary/tt_local_resource.zip)
                if (location != nil && zipFileURL != nil && [defaultManager moveItemAtURL:location toURL:zipFileURL error:&err]) {
                    // The methods of the shared NSFileManager object can be called from multiple threads safely.
                    // MD5校验未通过，删除zip包后直接退出
                    if (![self verifyMd5OfJSZipFile]) {
                        [defaultManager removeItemAtPath:zipFile error:nil];
                        if (completion) {
                            completion(NO);
                        }
                        return;
                    }
                    
                    BOOL unzipAndMoveSuccess = YES;
                    
                    // 解压文件到tmp目录
                    NSString *unzipFolder = localResourcePath;
                    NSString *unzipFolderTmp = [unzipFolder stringByAppendingString:@"_tmp"];
                    [defaultManager removeItemAtPath:unzipFolderTmp error:nil];
                    BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:zipFile toDestination:unzipFolderTmp];
                    unzipAndMoveSuccess = unzipAndMoveSuccess && unzipSuccess;
                    
                    if (unzipSuccess) {
                        // 删除目录下的旧文件夹，将tmp目录改名为tt_local_resource
                        [defaultManager removeItemAtPath:unzipFolder error:nil];
                        BOOL moveSuccess = [defaultManager moveItemAtPath:unzipFolderTmp toPath:unzipFolder error:nil];
                        unzipAndMoveSuccess = unzipAndMoveSuccess && moveSuccess;
                        if (moveSuccess) {
                            // 存储版本号
                            [[self class] setLocalResourceCurrentVersion:[[self class] localResourceNewVersion]];
                            if (completion) {
                                completion (YES);
                            }
                        }
                    }
                    // 删除zip包
                    [defaultManager removeItemAtPath:zipFile error:nil];
                    
                    if (!unzipAndMoveSuccess) {
                        if (completion) {
                            completion(NO);
                        }
                    }
                }
                else {
                    if (completion) {
                        completion(NO);
                    }
                }
            }
            else { //下载失败
                if (completion) {
                    completion(NO);
                }
            }
        });
    }];
    [downloadTask resume];
}

#pragma mark - retry

+ (void)registerNotificationsToDownloadLater {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
}

+ (void)applicationDidBecomeActive:(NSNotificationCenter *)notification {
    if (TTNetworkConnected()) {
        [self checkAndDownloadIfNeed];
    }
}

+ (void)networkChanged:(NSNotification *)notification {
    if (TTNetworkConnected()) {
        [self checkAndDownloadIfNeed];
    }
}

@end


@implementation UIImage(TTLocalImageDownload)

+ (void)imageNamed:(NSString *)name startDownloadBlock:(void (^)(void))startDownloadBlock completion:(void (^)(UIImage *image))completion {
    UIImage *bundleImage = [UIImage imageNamed:name];
    if (bundleImage) {
        if (completion) {
            completion(bundleImage);
        }
        return;
    }
    
    name = [name stringByAppendingString:@".png"];
    
    NSString *unzipFolder = localResourcePath;
    NSURL *url = [NSURL URLWithString:unzipFolder];
    url = [url URLByAppendingPathComponent:@"resources"];
    url = [url URLByAppendingPathComponent:name];
    NSString *path = [url absoluteString];
    UIImage *localImage = [UIImage imageWithContentsOfFile:path];
    if (localImage) {
        [[TTMonitor shareManager] trackService:@"tt_read_image_from" status:TTReadImageFromZip extra:nil];
        if (completion) {
            completion(localImage);
        }
        return;
    }
    
    if (startDownloadBlock) {
        startDownloadBlock();
    }
    
    [[TTImageDownloader sharedInstance] downloadImageWithURL:[TTLocalResourceDownloader webURLForImageName:name] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
        if (image) {
            [[TTMonitor shareManager] trackService:@"tt_read_image_from" status:TTReadImageFromWeb extra:nil];
        }
        else {
            [[TTMonitor shareManager] trackService:@"tt_read_image_from" status:TTReadImageFailed extra:nil];
        }
        
        if (completion) {
            completion(image);
        }
    }];
}

+ (void)imageNamed:(NSString *)name completion:(void (^)(UIImage *))completion {
    [self imageNamed:name startDownloadBlock:nil completion:completion];
}

@end
