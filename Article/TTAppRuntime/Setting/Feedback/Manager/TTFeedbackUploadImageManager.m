//
//  TTFeedbackUploadImageManager.m
//  Essay
//
//  Created by Zhang Leonardo on 13-4-12.
//  Refactored by Nick YU on 15-5-21.
//  Copyright (c) 2013年 Bytedance. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "TTFeedbackUploadImageManager.h"
#import "NetworkUtilities.h"
#import "CommonURLSetting.h"
#import "UIImageAdditions.h"
#import "TTNetworkManager.h"

#define TTFeedbackUploadImageWatermarkTypeNone  0

@interface TTFeedbackUploadImageManager()
{
    NSUInteger _uploadTotalSize;
    CGFloat _uploadSize;
 
}
@property(nonatomic, assign) BOOL cancelUpload;
@property(nonatomic, assign) NSUInteger currentUploadTaskIndex;
@property(nonatomic, strong) NSOperationQueue * operationQueue;

@property(nonatomic, strong) NSDictionary * uploadTasks;
@property(nonatomic, strong) NSMutableArray * finishResults;

@end


@implementation TTFeedbackUploadImageManager

- (void)dealloc
{
    self.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
     
        self.finishResults = [NSMutableArray array];
        self.operationQueue = [[NSOperationQueue alloc] init];
        _uploadTotalSize = 0;
        _uploadSize = 0;
    }
    return self;
}

#pragma mark helper functions
+ (NSData *)imageDataForImage:(UIImage *)image withMaxAspectSize:(CGSize)maxAspectSize withMaxDataSize:(CGFloat)maxDataSize
{
    NSData * imgData = [image imageDataWithMaxSize:maxAspectSize maxDataSize:maxDataSize];
    
    if (imgData == nil) {
        imgData = UIImageJPEGRepresentation(image, 1.f);
    }
    
    return imgData;
}

+ (NSString *)imageUniqueKey:(UIImage *)image
{
    if (image == nil) {
        return nil;
    }
    unsigned char result[16];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.f)];
    CC_MD5([imageData bytes], (int)[imageData length], result);
    NSString *imageHash = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return imageHash;
}

#pragma mark helper functions end

- (void)uploadImageData:(NSData *)imgData uniqueKey:(NSString *)keyStr
{
    if (!TTNetworkConnected()) {
        return;
    }
    if (imgData == nil || imgData.length == 0) {
        return;
    }
    
    
    
    _cancelUpload = NO;
 
    NSMutableDictionary * postParameter = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParameter setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [postParameter setValue:[NSNumber numberWithInteger:TTFeedbackUploadImageWatermarkTypeNone] forKey:@"watermark"];
    [postParameter setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    
    __weak typeof(self) wself = self;
   
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
         __autoreleasing NSProgress * progress = nil;
        [[TTNetworkManager shareInstance] uploadWithURL:[CommonURLSetting uploadImageString] parameters:postParameter constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
            [formData appendPartWithFileData:imgData name:@"image" fileName:@"image.jpeg" mimeType:@"image"];
        } progress:&progress needcommonParams:YES callback:^(NSError *error, id jsonObj) {
            if (error) {
                [wself didUploadImage:nil error:error];
            } else if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                [wself didUploadImage:jsonObj error:nil];
            }
        }];
        
        if (progress) {
            [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:nil];
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)uploadImages:(NSArray *)images uniqueKey:(NSArray *)keyStrs
{
    [self uploadImages:images uniqueKey:keyStrs withMaxAspectSize:CGSizeMake(NSIntegerMax, NSIntegerMax)    withMaxDataSize:NSIntegerMax];
}

- (void)uploadImages:(NSArray *)images uniqueKey:(NSArray *)keyStrs withMaxAspectSize:(CGSize)maxAspectSize withMaxDataSize:(CGFloat)maxDataSize
{
    if (images.count == 0) {
        return;
    }
    
    [self cancelAllOperation];
    
    NSAssert(images.count == keyStrs.count, @"the count of images must be equal to the count of keystrs");
    
    _cancelUpload = NO;

    _uploadTotalSize = 0;
    _uploadSize = 0;
    
    NSMutableArray *imgDatas = [NSMutableArray arrayWithCapacity:[images count]];
    for (NSUInteger index = 0; index < [images count]; ++index)
    {
        UIImage * image = [images objectAtIndex:index];
        NSData * imgData = [TTFeedbackUploadImageManager imageDataForImage:image withMaxAspectSize:maxAspectSize withMaxDataSize:maxDataSize];
        _uploadTotalSize += imgData.length;

        [imgDatas addObject:imgData];
    }
    
    self.uploadTasks = @{@"UniqueKeys":keyStrs,
                         @"ImageDatas":imgDatas};

    
    self.currentUploadTaskIndex = 0;
    [self uploadImageData:imgDatas.firstObject uniqueKey:keyStrs.firstObject];

}

- (void)cancelAllOperation
{
    _cancelUpload = YES;
    [self.operationQueue cancelAllOperations];
}


#pragma mark -- operation target

- (void)didUploadImage:(NSDictionary *)result error:(NSError *)error
{
    self.currentUploadTaskIndex++;
    
    if (error)
    {
        [_delegate uploadImageManager:self uploadFinishForUniqueKeys:self.uploadTasks[@"UniqueKeys"] results:self.finishResults   error:error];
        return;
    }
    if (result) {
        [self.finishResults addObject:result];
    }
    
    if (self.currentUploadTaskIndex == [((NSArray *)self.uploadTasks[@"UniqueKeys"]) count])
    {
        if (_delegate && [_delegate respondsToSelector:@selector(uploadImageManager:uploadFinishForUniqueKeys:results:error:)])
        {
            [_delegate uploadImageManager:self uploadFinishForUniqueKeys:self.uploadTasks[@"UniqueKeys"] results:self.finishResults   error:error];
        }
    }
    
    if (self.currentUploadTaskIndex < [((NSArray *)self.uploadTasks[@"UniqueKeys"]) count]) {
        
        [self uploadImageData:self.uploadTasks[@"ImageDatas"][self.currentUploadTaskIndex] uniqueKey:self.uploadTasks[@"UniqueKeys"][self.currentUploadTaskIndex]];
    }
     
}

- (void)uploadProgress:(NSNumber *)progress
{
    if (_delegate && [_delegate respondsToSelector:@selector(uploadImageManager:uploadImagesProgress:)])
    {
        
        NSUInteger currentFinishedSize = 0;
        for (NSInteger i=0; i<self.currentUploadTaskIndex; i++) {
            currentFinishedSize += [self.uploadTasks[@"ImageDatas"][i] length];
        }
        
        _uploadSize = currentFinishedSize + [progress floatValue];
        
        [_delegate uploadImageManager:self uploadImagesProgress:@(_uploadSize/_uploadTotalSize)];
    }
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[NSProgress class]] && [keyPath isEqualToString:@"completedUnitCount"]) {
        NSProgress * progress = object;
        NSInteger nProgress = 0;
        if (progress.completedUnitCount >= progress.totalUnitCount) {
            nProgress = progress.totalUnitCount;
            [progress removeObserver:self forKeyPath:@"completedUnitCount"];
        } else {
            nProgress = progress.completedUnitCount;
        }
        
        [self uploadProgress:@(nProgress)];
    }
}

@end

