//
//  TTWeitoutiaoRepostIconDownloadManager.m
//  Article
//
//  Created by 王霖 on 17/4/1.
//
//

#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import <NSStringAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "TTKitchenHeader.h"

static const NSString * kTTWeitoutiaoRepostIconPath = @"weitoutiao/images";

@implementation TTWeitoutiaoRepostIconDownloadManager

static TTWeitoutiaoRepostIconDownloadManager * manager = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTWeitoutiaoRepostIconDownloadManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self cleanNoUseIcon];
    }
    return self;
}

- (UIImage *)getWeitoutiaoRepostDayIcon {
    NSString * dayIconURLStr = [KitchenMgr getString:kKCUGCWeitoutiaoRepostIconDay];
    UIImage * dayIcon = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:dayIconURLStr];
    if (dayIcon) {
        return dayIcon;
    }
    NSString * dayIconPath = [[kTTWeitoutiaoRepostIconPath stringDocumentsPath] stringByAppendingPathComponent:[dayIconURLStr MD5HashString]];
    NSData * dayIconData = [[NSFileManager defaultManager] contentsAtPath:dayIconPath];
    if (dayIconData) {
        dayIcon = [UIImage imageWithData:dayIconData];
        if (dayIcon) {
            return dayIcon;
        }
    }
    [self downloadRepostIconIfNeedWithIconURL:dayIconURLStr];
    return nil;
}

- (UIImage *)getWeitoutiaoRepostNightIcon {
    NSString * nightIconURLStr = [KitchenMgr getString:kKCUGCWeitoutiaoRepostIconNight];
    UIImage * nightIcon = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:nightIconURLStr];
    if (nightIcon) {
        return nightIcon;
    }
    NSString * nightIconPath = [[kTTWeitoutiaoRepostIconPath stringDocumentsPath] stringByAppendingPathComponent:[nightIconURLStr MD5HashString]];
    NSData * nightIconData = [[NSFileManager defaultManager] contentsAtPath:nightIconPath];
    if (nightIconData) {
        nightIcon = [UIImage imageWithData:nightIconData];
        if (nightIcon) {
            return nightIcon;
        }
    }
    [self downloadRepostIconIfNeedWithIconURL:nightIconURLStr];
    return nil;
}

- (void)downloadRepostIconIfNeedWithIconURL:(NSString *)iconURL {
    if (isEmptyString(iconURL)) {
        return;
    }
    NSString * iconDirectoryPath = [kTTWeitoutiaoRepostIconPath stringDocumentsPath];
    NSString * iconPath = [iconDirectoryPath stringByAppendingPathComponent:[iconURL MD5HashString]];
    [[NSFileManager defaultManager] removeItemAtPath:iconPath error:nil];
    [[SDWebImageAdapter sharedAdapter] prefetchURLs:@[[NSURL URLWithString:iconURL]]
                                                      progress:nil
                                                     completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                                                         UIImage * icon = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:iconURL];
                                                         if (icon) {
                                                             dispatch_async(dispatch_queue_create("com.bytedance.savereposticon", DISPATCH_QUEUE_SERIAL), ^{
                                                                 //保存图片到沙盒中
                                                                 NSFileManager * fileManager = [NSFileManager defaultManager];
                                                                 BOOL isDirectory = NO;
                                                                 BOOL isExists = [fileManager fileExistsAtPath:iconDirectoryPath
                                                                                                   isDirectory:&isDirectory];
                                                                 BOOL needCreateIconDirectory = NO;
                                                                 if (isExists) {
                                                                     //icon目录存在
                                                                     if (!isDirectory) {
                                                                         //非目录，删除之
                                                                         [fileManager removeItemAtPath:iconDirectoryPath
                                                                                                 error:nil];
                                                                         needCreateIconDirectory = YES;
                                                                     }
                                                                 }else {
                                                                     //icon目录不存在
                                                                     needCreateIconDirectory = YES;
                                                                 }
                                                                 if (needCreateIconDirectory) {
                                                                     [fileManager createDirectoryAtPath:iconDirectoryPath
                                                                            withIntermediateDirectories:YES
                                                                                             attributes:nil
                                                                                                  error:nil];
                                                                 }
                                                                 [UIImagePNGRepresentation(icon) writeToFile:iconPath
                                                                                                  atomically:YES];
                                                             });
                                                         }
                                                     }];
}

- (void)cleanNoUseIcon {
    NSString * dayIconURLStr = [KitchenMgr getString:kKCUGCWeitoutiaoRepostIconDay];
    NSString * nightIconURLStr = [KitchenMgr getString:kKCUGCWeitoutiaoRepostIconNight];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator * enumerator = [fileManager enumeratorAtPath:[kTTWeitoutiaoRepostIconPath stringDocumentsPath]];
    for (NSString * fileName in enumerator) {
        if (![fileName isEqualToString:[dayIconURLStr MD5HashString]] && ![fileName isEqualToString:[nightIconURLStr MD5HashString]]) {
            [fileManager removeItemAtPath:[[kTTWeitoutiaoRepostIconPath stringDocumentsPath] stringByAppendingPathComponent:fileName]
                                    error:nil];
        }
    }
}

@end
