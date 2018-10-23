//
//  TTBackgroundModeTask.h
//  Article
//
//  Created by fengyadong on 17/1/23.
//
//

#import "TTStartupTask.h"



@interface TTBackgroundModeTask : TTStartupTask<UIApplicationDelegate>

/**
 *  主要通过appLogout接口上报deviceToken
 */
+ (void)reportDeviceTokenByAppLogout;

@end
