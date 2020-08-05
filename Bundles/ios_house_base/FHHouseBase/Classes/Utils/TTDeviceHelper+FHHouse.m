//
//  TTDeviceHelper+FHHouse.m
//  FHHouseBase
//
//  Created by 张静 on 2019/6/26.
//

#import "TTDeviceHelper+FHHouse.h"
#import <TTBaseLib/TTDeviceHelper.h>

@implementation TTDeviceHelper (FHHouse)

+ (CGFloat)scaleToScreen375
{
    return [UIScreen mainScreen].bounds.size.width / 375.0f;
}

+ (CGFloat)getTotalCacheSpace
{
    return [TTDeviceHelper cacheSizeToGB:[NSProcessInfo processInfo].physicalMemory];
}

+(CGFloat)cacheSizeToGB:(unsigned long long)fileSize
{
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    CGFloat cacheSizeT = ((CGFloat)fileSize)/GB;
    if (cacheSizeT < 1) {
        cacheSizeT = 1.0;
    }
    return cacheSizeT;
}

+ (Boolean)is896Screen2X {
    CGFloat scale = [UIScreen mainScreen].scale;
    return [TTDeviceHelper getDeviceType] == TTDeviceMode896 && scale == 2.f;
}

+ (Boolean)is896Screen3X {
    CGFloat scale = [UIScreen mainScreen].scale;
    return [TTDeviceHelper getDeviceType] == TTDeviceMode896 && scale == 3.f;
}

+ (BOOL)isScreenWidthLarge320 {
    CGFloat shortSide = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    return shortSide > 320;
}

@end
