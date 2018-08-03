//
//  TTPostUGCEntranceIconDownloadManager.m
//  Article
//
//  Created by xushuangqing on 17/11/2017.
//

#import "TTPostUGCEntranceIconDownloadManager.h"
#import "TTPostUGCEntrance.h"
#import <BDWebImage/SDWebImageAdapter.h>

#import <NSStringAdditions.h>

static const NSString * kTTPublishEntranceIconPath = @"publish_entrance/images";

@interface TTPostUGCEntranceIconDownloadManager()

@property (nonatomic, strong) dispatch_queue_t save_serial_queue;

@end


@implementation TTPostUGCEntranceIconDownloadManager

static TTPostUGCEntranceIconDownloadManager * manager = nil;
+ (nullable instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTPostUGCEntranceIconDownloadManager alloc] init];
    });
    return manager;
}

- (nullable UIImage *)getEntranceIconForType:(TTPostUGCEntranceButtonType)type withURL:(NSString *)url {
    if (isEmptyString(url)) {
        return nil;
    }
    UIImage * icon = nil;//[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
    if (icon) {
        return icon;
    }
    
    /**
     存入沙盒的文件路径为：documents/publish_entrance/images/1/md5string
     其中1表示icon的类型 TTPostUGCEntranceButtonType
     更新时首先删除/1/整个文件夹内容，防止囤积过多图片
     */
    NSString * iconPath = [[[kTTPublishEntranceIconPath stringDocumentsPath] stringByAppendingPathComponent:[@(type) stringValue]] stringByAppendingPathComponent:[url MD5HashString]];
    NSData * iconData = [[NSFileManager defaultManager] contentsAtPath:iconPath];
    if (iconData) {
        icon = [UIImage imageWithData:iconData];
        if (icon) {
            return icon;
        }
    }
    [self downloadEntryIconIfNeedWithType:type iconURL:url];
    return nil;
}

- (void)downloadEntryIconIfNeedWithType:(TTPostUGCEntranceButtonType)type iconURL:(NSString *)iconURL {
    if (isEmptyString(iconURL)) {
        return;
    }
    NSString * iconDirectoryPath = [kTTPublishEntranceIconPath stringDocumentsPath];
    NSString * typeDirectory = [iconDirectoryPath stringByAppendingPathComponent:[@(type) stringValue]];
    NSString * iconPath = [typeDirectory stringByAppendingPathComponent:[iconURL MD5HashString]];
    [[NSFileManager defaultManager] removeItemAtPath:typeDirectory error:nil];
    [[SDWebImageAdapter sharedAdapter] prefetchURLs:@[iconURL]
                                                      progress:nil
                                                     completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
                                                         //由于此时缓存还未存入，故等待0.2s再去查询SD缓存
                                                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), self.save_serial_queue, ^{
                                                             UIImage * icon = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:iconURL];
                                                             if (icon) {
                                                                 //保存图片到沙盒中
                                                                 NSFileManager * fileManager = [NSFileManager defaultManager];
                                                                 BOOL isDirectory = NO;
                                                                 BOOL isExists = [fileManager fileExistsAtPath:typeDirectory
                                                                                                   isDirectory:&isDirectory];
                                                                 BOOL needCreateIconDirectory = NO;
                                                                 if (isExists) {
                                                                     //icon目录存在
                                                                     if (!isDirectory) {
                                                                         //非目录，删除之
                                                                         [fileManager removeItemAtPath:typeDirectory
                                                                                                 error:nil];
                                                                         needCreateIconDirectory = YES;
                                                                     }
                                                                 }else {
                                                                     //icon目录不存在
                                                                     needCreateIconDirectory = YES;
                                                                 }
                                                                 if (needCreateIconDirectory) {
                                                                     [fileManager createDirectoryAtPath:typeDirectory
                                                                            withIntermediateDirectories:YES
                                                                                             attributes:nil
                                                                                                  error:nil];
                                                                 }
                                                                 [UIImagePNGRepresentation(icon) writeToFile:iconPath
                                                                                                  atomically:YES];
                                                             }
                                                         });
                                                     }];
}

- (dispatch_queue_t)save_serial_queue {
    if (!_save_serial_queue) {
        _save_serial_queue = dispatch_queue_create("com.bytedance.savepostentranceicon", DISPATCH_QUEUE_SERIAL);
    }
    return _save_serial_queue;
}

@end
