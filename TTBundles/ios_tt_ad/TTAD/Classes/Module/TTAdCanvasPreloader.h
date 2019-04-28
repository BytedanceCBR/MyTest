//
//  TTAdCanvasPreloader.h
//  Article
//
//  Created by carl on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import "TTAdResourceDefine.h"

/**
 沉浸式广告预加载逻辑
 */
@interface TTAdCanvasPreloader : NSObject <TTAdPreloader>
+ (instancetype)sharedPreloader;
@end
