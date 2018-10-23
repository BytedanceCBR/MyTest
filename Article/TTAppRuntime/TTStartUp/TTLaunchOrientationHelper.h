//
//  TTLaunchOrientationHelper.h
//  Article
//
//  Created by xushuangqing on 2017/5/18.
//
//

#import <Foundation/Foundation.h>

@interface TTLaunchOrientationHelper : NSObject

//横屏启动时调用openURL，容易导致视图错乱，这个方法会等待statusbar方向正常后再调用block
+ (void)executeBlockAfterStatusbarOrientationNormal:(dispatch_block_t)block;

@end
