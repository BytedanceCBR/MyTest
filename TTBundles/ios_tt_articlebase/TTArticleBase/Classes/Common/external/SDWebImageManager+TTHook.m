//
//  SDWebImageManager+TTHook.m
//  Article
//
//  Created by lizhuoli on 2017/9/6.
//
//

#import "SDWebImageManager+TTHook.h"

@implementation SDWebImageManager (TTHook)

// 关闭SDWebImage的图片下载失败进入黑名单的功能
- (NSMutableSet<NSURL *> *)failedURLs {
    return nil;
}

@end
