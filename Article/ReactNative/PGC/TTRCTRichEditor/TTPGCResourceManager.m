//
//  TTPGCResourceManager.m
//  Article
//
//  Created by liaozhijie on 2017/8/3.
//
//

#import <Foundation/Foundation.h>

#import "TTPGCResourceManager.h"
#import "NSStringAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import "SSZipArchive.h"

@interface TTPGCResourceManager ()

@property (nonatomic, strong) NSURLSessionDownloadTask * downloadTask;

@end

@implementation TTPGCResourceManager

- (void)dealloc
{
    [self cancel];
}

- (void)cancel {
    if (self.downloadTask) {
        [_downloadTask cancel];
    }
}

// 下载文件，当下载失败或者校验失败时，均返回失败
- (void)download:(NSString* _Nonnull )urlString
             md5:(NSString* _Nullable )md5
     zipFilename:(NSString *_Nonnull)zipFilename
     unzipFolder:(NSString *_Nonnull)unzipFolder
 completeHandler:(void (^_Nullable)(NSError * _Nullable error, BOOL verifyError))completeHandler
{
    [self cancel];

    NSURL *url = [TTStringHelper URLWithURLString:urlString];
    if (!url) {
        NSError *urlError = [NSError errorWithDomain:@"TTPGCResourceManager"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"url is missing"}];
        completeHandler(urlError, false);
        return;
    }

    NSURLSessionDownloadTask * downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err = nil;
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSString *zipFile = [zipFilename stringCachePath];
        NSURL *zipFileURL = [NSURL fileURLWithPath:zipFile];

        // 删除zip文件
        [defaultManager removeItemAtPath:zipFile error:nil];

        // 下载失败
        if (error) {
            if (completeHandler) {
                completeHandler(error, false);
            }
            return;
        }

        // 将下载的文件从location拷贝到zipFileURL并修改文件名
        if (location != nil && zipFileURL != nil && [defaultManager moveItemAtURL:location toURL:zipFileURL error:&err]) {
            // The methods of the shared NSFileManager object can be called from multiple threads safely.
            // MD5校验未通过，删除zip包后直接退出
            if (md5 && ![self verifyMd5:zipFile md5:md5]) {
                [defaultManager removeItemAtPath:zipFile error:nil];
                if (completeHandler) {
                    completeHandler(error, true);
                }
                return;
            }

            // 解压文件到tmp目录
            NSString * unzipFolderPath = [unzipFolder stringCachePath];
            NSString *unzipFolderTmp = [[unzipFolder stringCachePath] stringByAppendingString:@"_tmp"];
            BOOL unzipSuccess = [SSZipArchive unzipFileAtPath:zipFile toDestination:unzipFolderTmp];

            if (unzipSuccess) {
                // 删除目录下的旧文件夹，将tmp目录改名为指定目录名
                [defaultManager removeItemAtPath:unzipFolderPath error:nil];
                if ([defaultManager moveItemAtPath:unzipFolderTmp toPath:unzipFolderPath error:nil]) {
                    // 存储版本号
                    if (completeHandler) {
                        completeHandler(error, false);
                    }
                }
            }
            // 删除zip包
            [defaultManager removeItemAtPath:zipFile error:nil];
        }
    }];
    [downloadTask resume];

    self.downloadTask = downloadTask;
}

// 验证已下载js文件的md5值
- (BOOL)verifyMd5:(NSString *)zipFile md5:(NSString *)md5
{
    NSData* fileData = [NSData dataWithContentsOfFile:zipFile];
    NSString* fileMd5 = [self md5:fileData];

    if ([fileMd5 isEqualToString:md5]) {
        return YES;
    }

    return NO;
}

// md5 计算
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

// 判断文件是否存在
- (BOOL)exist:(NSString *)file
{
    if (!file) {
        return false;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExist = [fileManager fileExistsAtPath:[file stringCachePath]];
    return fileExist;
}

// 加载webview内容，如果本地有缓存，则加载本地，否则加载回退线上url
- (void)loadWebContent:(UIWebView *)webview
                folder:(NSString *)folder
              fileName:(NSString *)fileName
           fallbackUrl:(NSString *)fallbackUrl
            onDownload:(void(^)())onDownload {
    if (!webview || !folder || !fileName || !fallbackUrl) {
        return;
    }

    NSString * localFilePath = [NSString stringWithFormat:@"%@/%@", folder, fileName];
    BOOL existLocalFile = [self exist:localFilePath];

    if (!existLocalFile) {
        NSURL * url = [NSURL URLWithString:fallbackUrl];
        [webview loadRequest:[NSURLRequest requestWithURL:url]];
        if (onDownload) {
            onDownload();
        }
    } else {
        NSString * localFolderPath = [folder stringCachePath];
        localFolderPath = [NSString stringWithFormat:@"file://%@/", localFolderPath];
        NSURL * url = [TTStringHelper URLWithURLString:localFolderPath];
        NSString * template = [NSString stringWithContentsOfFile:[localFilePath stringCachePath] usedEncoding:nil error:nil];
        [webview loadHTMLString:template baseURL:url];
    }
}

- (void)setResourceInfo:(NSString *)key
                    url:(NSString *)url
                version:(NSString *)version
                    md5:(NSString *)md5 {
    if (!key || !url || !version || !md5) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@{
                                                       @"url": url,
                                                       @"version": version,
                                                       @"md5": md5
                                                       } forKey:key];
}

// 更新资源如果资源过期
- (void)updateResourceIfNeeded:(NSString *)key
                           url:(NSString *)url
                       version:(NSString *)version
                           md5:(NSString *)md5
                   zipFilename:(NSString *)zipFilename
                   unzipFolder:(NSString *)unzipFolder
             completionHandler:(void(^)(BOOL success))completionHandler {
    if (!key || !url || !version || !md5) {
        return;
    }
    if (![self shouleUpdate:key version:version]) {
        return;
    }
    [self download:url md5:md5 zipFilename:zipFilename unzipFolder:unzipFolder completeHandler:^(NSError * error, BOOL verifyError) {
        if (error || verifyError) {
            if (completionHandler) {
                completionHandler(false);
            }
            return;
        }
        [self setResourceInfo:key url:url version:version md5:md5];
        if (completionHandler) {
            completionHandler(true);
        }
    }];
}

// 判断是否应该更新
- (BOOL)shouleUpdate:(NSString *)key
             version:(NSString *)version {
    if (!key || !version) {
        return false;
    }
    NSDictionary * info = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!info) {
        return true;
    }
    NSString * currentVersionStr = (NSString *)info[@"version"];
    if (!currentVersionStr) {
        return true;
    }
    NSInteger currentVersion = [currentVersionStr integerValue];
    return currentVersion < [version integerValue];
}

@end
