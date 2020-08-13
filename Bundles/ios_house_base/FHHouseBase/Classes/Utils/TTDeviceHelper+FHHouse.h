//
//  TTDeviceHelper+FHHouse.h
//  FHHouseBase
//
//  Created by 张静 on 2019/6/26.
//

#import "TTDeviceHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTDeviceHelper (FHHouse)

+ (CGFloat)scaleToScreen375;

+ (CGFloat)getTotalCacheSpace;

+ (BOOL)is896Screen2X;

+ (BOOL)is896Screen3X;

+ (BOOL)isScreenWidthLarge320;

@end

NS_ASSUME_NONNULL_END
