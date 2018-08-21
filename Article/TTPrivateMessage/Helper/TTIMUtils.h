//
//  TTIMUtils.h
//  EyeU
//
//  Created by matrixzk on 11/8/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TTIMUtils : NSObject

/**
 *  获取狸猫相机拍照返回图片
 */
+ (void)fetchImageWithIdentifier:(NSString *)identifier
                   resultHandler:(void(^)(UIImage *image, NSString *identifier))resultHandler;

/**
 *  对 `image` 做指定size和大小的压缩
 */
+ (NSData *)imageDataWithImage:(UIImage *)image targetSize:(CGSize)targetSize maxDataSize:(CGFloat)dataSize;

/**
 *  Json字符串与字典间互转
 */
+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFromJSONString:(NSString *)jsonString;

@end
