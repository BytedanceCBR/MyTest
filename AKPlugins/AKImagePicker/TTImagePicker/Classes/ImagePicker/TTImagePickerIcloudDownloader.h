//
//  TTImagePickerIcloudDownloader.h
//  Pods
//
//  Created by tyh on 2017/7/13.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^IcloudCompletion)(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info);
typedef void(^IcloudProgressHandler)(double progress, NSError *error, BOOL *stop, NSDictionary *info);


@interface TTImagePickerIcloudDownloader : NSObject

/// 获取icloud图片
- (void)getIcloudPhotoWithAsset:(PHAsset *)asset completion:(IcloudCompletion)completion progressHandler:(IcloudProgressHandler)progressHandler isSingleTask:(BOOL)isSingleTask ;

/// 取消选择的图片
- (BOOL)cancelDownloadIcloudPhotoWithAsset:(PHAsset *)asset;

/// 取消预览的图片
- (void)cancelSingleIcloud;


@end
