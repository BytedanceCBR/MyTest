//
//  TTOOMMonitor.h
//  DemoTest
//
//  Created by ShaJie on 21/5/2017.
//  Copyright © 2017 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTTerminationType) {
    TTTerminationTypeUnknown = 0,
    TTTerminationTypeAppLaunchAfterFirstInstall,
    TTTerminationTypeAppUpdate,
    TTTerminationTypeCrash,
    TTTerminationTypeForcelyTerminate, // 接收到了 UIApplicationWillTerminateNotification
    TTTerminationTypeOSUpdate,
    TTTerminationTypeDebugger,          // 开发调试模式
    TTTerminationTypeForegroundOOM,
    TTTerminationTypeBackgroundOOM
};

// OOM 检测逻辑，参照 Facebook 的流程设计
// https://code.facebook.com/posts/1146930688654547/reducing-fooms-in-the-facebook-ios-app/
@interface TTOOMMonitor : NSObject

@property (nonatomic, readonly) TTTerminationType lastTerminationType;

- (TTTerminationType)runCheckWithWhetherCrashDetected:(BOOL)crashDetected;

// 避免添加重复的 Application state listener，将接口暴露出来
- (void)logApplicationEnterForeground;
- (void)logApplicationEnterBackground;
- (void)logApplicationForcelyTermination;


@end
