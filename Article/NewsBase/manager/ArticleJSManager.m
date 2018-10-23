//
//  ArticleJSManager.m
//  Article
//
//  Created by 邓刚 on 14-3-26.
//
//

#import "ArticleJSManager.h"
#import "NSStringAdditions.h"
#import "SSSZipArchive.h"
#import <CommonCrypto/CommonDigest.h>
#import "TTStringHelper.h"

#define kArticleJSManagerJSVersionKey @"kArticleLocalJSVersionKey" // 本地存放的前端资源版本号
#define kArticleJSManagerUseJSInBundleKey @"kArticleJSManagerUseJSInBundleKey" // 内测版本控制是否使用下发setting的开关，防止较长项目开发过程中上线的影响

// @"13" 问答详情页新版内容升级
static NSString *const kJSVersionInBundle = @"244";  // 客户端内置资源版本号

@interface ArticleJSManager ()
@property(nonatomic, strong)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, copy)NSString* jsVersion;
@property (nonatomic, copy)NSString* jsMd5;
@property (nonatomic, copy)NSString* jsUrl;
@end

@implementation ArticleJSManager

static ArticleJSManager * shareManager;

+ (ArticleJSManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ArticleJSManager alloc] init];
    });
    return shareManager;
}


/* 新的详情页前端代码更新逻辑
 * https://wiki.bytedance.com/pages/viewpage.action?pageId=67605605
 */
+ (void)downloadAssetsWithUrl:(NSString *)assetsUrl {
    // 先取本地的jsVersion，如果没有，则取当前打包版本的版本号
    NSString* localJSVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleJSManagerJSVersionKey];
    
    if (!localJSVersion) {
        localJSVersion = kJSVersionInBundle;
        [[NSUserDefaults standardUserDefaults] setObject:localJSVersion forKey:kArticleJSManagerJSVersionKey];
    }
    
    // 解析settings下发的URL，获取version和md5
    NSURL *URL = [NSURL URLWithString:assetsUrl];
    if (!URL) {
        return;
    }
    
    NSString *name = URL.URLByDeletingPathExtension.lastPathComponent;
    NSArray *components = [name componentsSeparatedByString:@"_"];
    if (components.count < 3) {
        return;
    }
    
    NSString *jsVersion = components[1];
    NSString *jsMd5 = components[2];
    
    [ArticleJSManager shareInstance].jsUrl     = assetsUrl;
    [ArticleJSManager shareInstance].jsVersion = jsVersion;
    [ArticleJSManager shareInstance].jsMd5     = jsMd5;

    if ([jsVersion intValue] > [localJSVersion intValue]) {
        [[ArticleJSManager shareInstance] downloadJSFromWeb:assetsUrl jsVersion:jsVersion jsMd5:jsMd5];
    }
}

- (void)dealloc
{
    [self.downloadTask cancel];
    self.downloadTask = nil;
    self.jsUrl = nil;
    self.jsMd5 = nil;
    self.jsVersion = nil;
}

#pragma mark - public

- (BOOL)shouldUseJSFromWebWithSubRootPath:(NSString *)jsSubRootPath
{
#if INHOUSE
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kArticleJSManagerUseJSInBundleKey]) {
        BOOL useJSInBundle = [[NSUserDefaults standardUserDefaults] boolForKey:kArticleJSManagerUseJSInBundleKey];
        if (useJSInBundle) return NO;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kArticleJSManagerUseJSInBundleKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
#endif
    
    /*
     * 条件1：已下载版本比打包版本大
     * 条件2：存在该版本js文件
     */
    
    NSString *localJSVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleJSManagerJSVersionKey];

    if ([localJSVersion intValue] > [[self bundleVersion] intValue] && [self isJSFileExistsInFolder:jsSubRootPath]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - private
- (void)downloadJSFromWeb:(NSString* )jsUrl jsVersion:(NSString* )jsVersion jsMd5:(NSString* )jsMd5
{
    
    [self.downloadTask cancel];
    self.downloadTask = nil;

    NSURL *URL = [TTStringHelper URLWithURLString:jsUrl];
    if (!URL) {
        return;
    }
        
    self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err = nil;
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSString *zipFile = [kIphoneJsZipFileName stringCachePath];
        NSURL *zipFileURL = [NSURL fileURLWithPath:zipFile];
        
        // 删除zip文件
        [defaultManager removeItemAtPath:zipFile error:nil];

        // 下载失败
        if (error) {
            return;
        }

        // 将下载的文件从location拷贝到zipFileURL并修改文件名(Caches/ios_asset/iphone.zip)
        if (location != nil && zipFileURL != nil && [defaultManager moveItemAtURL:location toURL:zipFileURL error:&err]) {
            // The methods of the shared NSFileManager object can be called from multiple threads safely.
            // MD5校验未通过，删除zip包后直接退出
            if (![self verifyMd5OfJSZipFile]) {
                [defaultManager removeItemAtPath:zipFile error:nil];
                return;
            }
            
            // 解压文件到tmp目录
            NSString *unzipFolder = [self packageFolderPath];
            NSString *unzipFolderTmp = [unzipFolder stringByAppendingString:@"_tmp"];
            BOOL unzipSuccess = [SSSZipArchive unzipFileAtPath:zipFile toDestination:unzipFolderTmp];
        
            if (unzipSuccess) {
                // 删除目录下的旧文件夹，将tmp目录改名为ios_asset
                [defaultManager removeItemAtPath:unzipFolder error:nil];
                if ([defaultManager moveItemAtPath:unzipFolderTmp toPath:unzipFolder error:nil]) {
                    // 存储版本号
                    [[NSUserDefaults standardUserDefaults] setObject:self.jsVersion forKey:kArticleJSManagerJSVersionKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            // 删除zip包
            [defaultManager removeItemAtPath:zipFile error:nil];
        }
    }];
    [self.downloadTask resume];
    
}

- (void)clearJSFromWeb
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *unzipfile = [self packageFolderPath];
    if ([defaultManager fileExistsAtPath:unzipfile]) {
        [defaultManager removeItemAtPath:unzipfile error:nil];
    }
    
    self.jsVersion = [self bundleVersion];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.jsVersion forKey:kArticleJSManagerJSVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startLoadJSResourcesIfNeed:(ArticleJSManagerLoadResourcesCallback)callback {
    
    void (^safeCallback)(NSString *, NSError *) = ^void(NSString *url, NSError *error) {
        if (callback) {
            callback(error? nil: url, error);
        }
    };
    if ([self isPackageFolderExist]) {
        if ([NSThread isMainThread]) {
            safeCallback([self packageFolderPath], nil);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                safeCallback([self packageFolderPath], nil);
            });
        }
        return;
    }
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/ios_asset"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:[self packageFolderPath] error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            safeCallback([self packageFolderPath], error);
        });
        
    });
}
//打包js文件的版本号
- (NSString* )bundleVersion
{
    return kJSVersionInBundle;
}

// 验证主要资源文件iphone.js是否存在，因为前面有zip的md5校验，所以简单查看这一个即可
// Caches目录有被系统删除的风险，所以进入页面之前都要查验
// TODO 应探索此检测的耗时
- (BOOL)isJSFileExistsInFolder:(NSString *)folder
{
    NSString *jsFilePath;
    
    if (isEmptyString(folder)) {
        jsFilePath = [NSString stringWithFormat:@"%@/%@", kIOSAssetFolderName, kIphoneJsFilePath];
    }
    else {
        jsFilePath = [NSString stringWithFormat:@"%@/%@/%@", kIOSAssetFolderName, folder, kIphoneJsFilePath];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:[jsFilePath stringCachePath]];
    return fileExist;
}

- (BOOL)isPackageFolderExist
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *packageFolder = [self packageFolderPath];
    BOOL packageFolderExist = [fileManager fileExistsAtPath:packageFolder];
    return packageFolderExist;
}

- (NSString *)packageFolderPath
{
    return [kIOSAssetFolderName stringCachePath];
}

// 验证已下载js文件的md5值
- (BOOL)verifyMd5OfJSZipFile
{
    NSString* jsZipFile = [kIphoneJsZipFileName stringCachePath];
    NSData* fileData = [NSData dataWithContentsOfFile:jsZipFile];
    NSString* md5 = [self md5:fileData];

    if ([md5 isEqualToString:self.jsMd5]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)md5:(NSData *)input
{
    const char *cStr = input.bytes;
    
    unsigned char digest[16];
    CC_MD5( cStr, (int)input.length, digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
