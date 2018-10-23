//
//  UIImage+Normalization.h
//  Article
//
//  Created by lizhuoli on 16/12/21.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (Normalization)

/** 标准化UIImage，将EXIF的orientation直接转换 */
- (UIImage *)normalizedImage;
/** 使用Frame截取指定的UIImage */
- (UIImage *)croppedImageWithFrame:(CGRect)frame;

@end
