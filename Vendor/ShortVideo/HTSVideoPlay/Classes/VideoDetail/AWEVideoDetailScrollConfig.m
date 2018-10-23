//
//  AWEVideoDetailScrollConfig.m
//  Pods
//
//  Created by Zuyang Kou on 17/07/2017.
//
//

#import "AWEVideoDetailScrollConfig.h"

@implementation AWEVideoDetailScrollConfig

static AWEVideoDetailScrollDirection direction;

+ (AWEVideoDetailScrollDirection)direction
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *key = @"kSSCommonLogicShortVideoDetailScrollDirectionKey";
        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (!value) {
            value = @1;
        }
        direction = [value integerValue];
        NSAssert(direction != 0, @"不支持不滑动");
        NSAssert((direction == 1) || (direction == 2), @"非法的值");
        if ((direction != 1) && (direction != 2)) {
            direction = 1;
        }
    });
    
    return direction;
}

@end
