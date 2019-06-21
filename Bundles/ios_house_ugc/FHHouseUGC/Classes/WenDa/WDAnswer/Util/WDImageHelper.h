//
//  WDImageHelper.h
//  Article
//
//  Created by 延晋 张 on 16/8/1.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

@interface WDImageHelper : NSObject

/** 处理上传图片的压缩流程 */
+ (NSData * _Nullable)processImageDataForUploadImage:(UIImage * _Nullable)image;
/** 获取图片使用WebP格式进行压缩编码后的数据 */
+ (NSData * _Nullable)webpForImage:(UIImage * _Nullable)image;

/**
 根据提供的高度和宽度限制，对图片进行缩放。使用的缩放方式取决于传入的高度和宽度值，scale采取设备的scale，旋转方向会正确处理且置为Up
 1. 若宽高均为0，返回nil
 2. 若宽为0，高不为0，限制高度等比缩放
 3. 若宽不为0，高为0，限制宽度等比缩放
 4. 若宽高均不为0，直接拉伸缩放

 @param image 原始的图片
 @param height 限制高度，如果为0，表示无限制
 @param width 限制宽度，如果为0，表示无限制
 @return 缩放后的图片
 */
+ (UIImage * _Nullable)scaledImageWithImage:(UIImage * _Nullable)image
                                limitHeight:(CGFloat)height
                                 limitWidth:(CGFloat)width;

@end
