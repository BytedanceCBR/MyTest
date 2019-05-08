//
//  BDPlayerObjManager.m
//  BDTBasePlayer
//
//  Created by lishuangyang on 2018/1/22.
//

#import "BDPlayerObjManager.h"

static BOOL isCanFullScreenFromOrientationMonitor = YES;
@implementation BDPlayerObjManager

+ (void)setIsCanFullScreenFromOrientationMonitorChanged:(BOOL) isCanRotate{
    isCanFullScreenFromOrientationMonitor = isCanRotate;
}

+ (BOOL)isCanFullScreenFromOrientationMonitorChanged{
    return isCanFullScreenFromOrientationMonitor;
}

@end
