//
//  BDPlayerObjManager.h
//  BDTBasePlayer
//
//  Created by lishuangyang on 2018/1/22.
//

#import <Foundation/Foundation.h>

@interface BDPlayerObjManager : NSObject

+ (void)setIsCanFullScreenFromOrientationMonitorChanged:(BOOL)isCanRotate;
+ (BOOL)isCanFullScreenFromOrientationMonitorChanged;

@end
