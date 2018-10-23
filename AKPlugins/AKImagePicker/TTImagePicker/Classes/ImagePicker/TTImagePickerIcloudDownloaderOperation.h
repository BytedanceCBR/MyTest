//
//  TTImageIcloudDownloaderOperation.h
//  Pods
//
//  Created by tyh on 2017/7/11.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^IcloudCompletion)(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info);
typedef void(^IcloudProgressHandler)(double progress, NSError *error, BOOL *stop, NSDictionary *info);




@interface TTImagePickerIcloudDownloaderOperation : NSOperation

@property (nonatomic,strong,readonly)PHAsset *asset;


- (instancetype)initWithAsset:(PHAsset *)asset;

- (void)addCompletion:(IcloudCompletion)completion progressHandler:(IcloudProgressHandler)progressHandler;


@end
