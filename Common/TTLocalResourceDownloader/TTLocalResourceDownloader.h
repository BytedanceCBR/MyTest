//
//  TTLocalResourceDownloader.h
//  Article
//
//  Created by xushuangqing on 12/09/2017.
//

#import <Foundation/Foundation.h>

@interface TTLocalResourceDownloader : NSObject

+ (void)setLocalResourceNewVersion:(NSInteger)version;
+ (void)setLocalResourceMd5:(NSString *)md5;
+ (void)setLocalResourceDownloadURL:(NSString *)downloadURL;
+ (void)checkAndDownloadIfNeed;
+ (void)setDynamicWebURL:(NSString *)dynamicWebURL;

@end


@interface UIImage(TTLocalImageDownload)

+ (void)imageNamed:(NSString *)name completion:(void (^)(UIImage *image))completion;
+ (void)imageNamed:(NSString *)name startDownloadBlock:(void (^)(void))startDownloadBlock completion:(void (^)(UIImage *image))completion;

@end
