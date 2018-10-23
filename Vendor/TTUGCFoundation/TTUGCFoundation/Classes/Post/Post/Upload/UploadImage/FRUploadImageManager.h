//
//  FRUploadImageManager.h
//  Forum
//
//  Created by Zhang Leonardo on 15-4-30.
//
//

#import <Foundation/Foundation.h>
#import "FRUploadImageModel.h"

typedef void (^FRUploadImageManagerProgressBlock)(int expectCount, int receivedCount);
typedef void (^FRUploadImageManagerFinishBlock)(NSError *error, NSArray<FRUploadImageModel *> * finishUpLoadModels);

const static NSString *FRUploadImageErrorDomain = @"com.bytedance.ugcUploadImage";
const static int FRUploadImageErrorIsLoading = 81101;
const static int FRUploadImageErrorCancel = 81102;

const static int FRUploadImageErrorLocalCompress = 81103;
const static int FRUploadImageErrorImageDataNULL = 81104;

@class TTForumPostThreadTask;

@interface FRUploadImageManager : NSObject

- (void)cancel;


/**
 注意，方法内会自动重试1次进行上传
 图片上传方法，会把传入图片统一上传，会在全部传完后走finishBlock（哪怕都失败了，也要都试1次）

 @param photoModels 需要上传的图片集
 @param task 对应的发布器task
 @param extParameters 上传需要的携带参数
 @param progressBlock 进度更新block
 @param finishBlock 完成block
 */
- (void)uploadPhotos:(NSArray<FRUploadImageModel *> *)photoModels
            withTask:(TTForumPostThreadTask *)task
        extParameter:(NSDictionary *)extParameters
       progressBlock:(FRUploadImageManagerProgressBlock)progressBlock
         finishBlock:(FRUploadImageManagerFinishBlock)finishBlock;

+ (void)uploadPhoto:(NSData *)imageData
   withExtParameter:(NSDictionary *)extParameter
        finishBlock:(void (^)(NSError * resultError, NSString * webURI ))finishBlock;
@end
