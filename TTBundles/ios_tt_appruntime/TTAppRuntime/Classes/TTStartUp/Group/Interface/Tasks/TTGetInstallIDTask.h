//
//  TTGetInstallIDTask.h
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTStartupTask.h"
#import <BDInstall/BDInstallURLConfigProtocol.h>

@interface TTGetInstallIDTask : TTStartupTask<UIApplicationDelegate, BDInstallURLConfigProtocol>

@end
