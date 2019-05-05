//
//  SSImageUtil.h
//  Essay
//
//  Created by Zhang Leonardo on 13-2-6.
//  Copyright (c) 2013年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SSImageUtilCutType{
    SSImageUtilCutTypeNone,
    SSImageUtilCutTypeTop,
    SSImageUtilCutTypeCenter,
//    SSImageUtilCutTypeBottom
}SSImageUtilCutType;

@interface SSImageUtil : NSObject

+ (UIImage *)cutImage:(UIImage *)img withRect:(CGRect)rect;

+ (UIImage *)cutImage:(UIImage *)img withCutWidth:(CGFloat)sideWidth withSideHeight:(CGFloat)sideHeight cutPosition:(SSImageUtilCutType)cutType;

/*
 *  将图片sourceImage压缩成制定的大小targetSize
 */
+ (UIImage *)compressImage:(UIImage *)sourceImage withTargetSize:(CGSize)targetSize;

/*
 * 如果所给的图片大于targetSize（长或寛)，则等比例缩放，长宽不能超过targetSize
 */
+ (UIImage *)tryCompressImage:(UIImage *)sourceImage ifImageSizeLargeTargetSize:(CGSize)targetSize;

/*
 * 修正相机拍摄的图片旋转问题
 */
+ (UIImage *)fixImgOrientation:(UIImage *)aImage;
/*
 * 旋转图片
 */
+ (UIImage *)imageRotatedByRadians:(CGFloat)radians originImg:(UIImage *)originImg;
+ (UIImage *)imageRotatedByDegrees:(CGFloat)degrees originImg:(UIImage *)originImg;

///*
// *  如果图片超过制定大小， 压缩
// *  fileSize 单位KB
// */
//+ (UIImage *)compressImageIfNeed:(UIImage *)sourceImage maxFileSize:(CGFloat)fileSize;

@end
