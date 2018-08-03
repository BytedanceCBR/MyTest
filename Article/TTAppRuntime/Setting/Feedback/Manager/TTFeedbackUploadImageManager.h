//
//  TTFeedbackUploadImageManager.h
//  Essay
//
//  Created by Zhang Leonardo on 13-4-12.
//
//  Refactored by Nick YU on 15-5-21.
//
//  Copyright (c) 2013年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol TTFeedbackUploadImageManagerDelegate;

@interface TTFeedbackUploadImageManager : NSObject

@property(nonatomic, weak)id<TTFeedbackUploadImageManagerDelegate>delegate;

+ (NSString *)imageUniqueKey:(UIImage *)image;

- (void)uploadImages:(NSArray *)images uniqueKey:(NSArray *)keyStrs;

- (void)uploadImages:(NSArray *)images uniqueKey:(NSArray *)keyStrs withMaxAspectSize:(CGSize)maxAspectSize withMaxDataSize:(CGFloat)maxDataSize;

- (void)cancelAllOperation;

+ (NSData *)imageDataForImage:(UIImage *)image withMaxAspectSize:(CGSize)maxAspectSize withMaxDataSize:(CGFloat)maxDataSize;


@end

@protocol TTFeedbackUploadImageManagerDelegate <NSObject>

@optional

- (void)uploadImageManager:(TTFeedbackUploadImageManager *)manager uploadFinishForUniqueKeys:(NSArray *)finishKeyStrs results:(NSArray*)dicts error:(NSError *)error;

- (void)uploadImageManager:(TTFeedbackUploadImageManager *)manager uploadImagesProgress:(NSNumber *)progress;

@end
