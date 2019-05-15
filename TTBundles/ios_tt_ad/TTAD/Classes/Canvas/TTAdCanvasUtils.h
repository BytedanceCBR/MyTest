//
//  TTAdCanvasUtils.h
//  Article
//
//  Created by yin on 2017/4/6.
//
//

#import <Foundation/Foundation.h>
#import "SSSimpleCache.h"
#import "TTPhotoDetailAdModel.h"
#import "TTAdCanvasDefine.h"

@interface TTAdCanvasUtils : NSObject

+ (UIColor *)colorWithCanvasRGBAString:(NSString *)string;

/**
 沉浸式广告 是否支持
 */
@property (nonatomic, assign, readonly, class) BOOL canvasEnable;
@property (nonatomic, assign, readonly, class) BOOL nativeEnable;
@property (nonatomic, assign, readonly, class) TTAdCanvasOpenStrategy openStrategy;
@end


@interface SSSimpleCache (TTAdImageModel)
- (NSData *)data4AdImageModel:(TTAdImageModel *)model;
@end
