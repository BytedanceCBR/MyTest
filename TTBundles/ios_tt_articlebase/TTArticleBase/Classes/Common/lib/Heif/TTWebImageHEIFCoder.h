//
//  TTWebImageHEIFCoder.h
//  Article
//
//  Created by fengyadong on 2017/10/27.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTWebImageHEIFCoder : NSObject

+ (nonnull instancetype)sharedCoder;
- (nullable UIImage *)decodedImageWithData:(nullable NSData *)data;
- (BOOL)supportCustomHeifDecoderForData:(nullable NSData *)data;
- (BOOL)isHeifData:(nullable NSData *)data;

@end

NS_ASSUME_NONNULL_END
