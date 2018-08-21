//
//  YYImageDecoder+HEIF.h
//  Article
//
//  Created by fengyadong on 2017/11/2.
//  Copyright © 2017年 fengyadong. All rights reserved.
//

#import <YYImage/YYImage.h>

@class YYImageFrame;
@interface YYImageFrame (HEIF)

@property (nonatomic, assign) BOOL isHEIFImage;

@end

@interface YYImageDecoder (HEIF)

@end
