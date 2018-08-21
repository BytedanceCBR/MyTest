//
//  TTAVPlayerTask.m
//  Article
//
//  Created by fengyadong on 17/1/20.
//
//

#import "TTAVPlayerTask.h"
#import "TTAVPlayerOpenGLActivity.h"
#import "TTVideoTip.h"

@implementation TTAVPlayerTask

- (NSString *)taskIdentifier {
    return @"AVPlayer";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [TTAVPlayerOpenGLActivity start];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [TTAVPlayerOpenGLActivity stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [TTAVPlayerOpenGLActivity stop];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [TTVideoTip setCanShowVideoTip:NO];
}

@end
