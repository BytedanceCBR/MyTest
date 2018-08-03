//
//  TTLaunchOrientationHelper.m
//  Article
//
//  Created by xushuangqing on 2017/5/18.
//
//

#import "TTLaunchOrientationHelper.h"
#import "NewsBaseDelegate.h"

@implementation TTLaunchOrientationHelper

+ (void)executeBlockAfterStatusbarOrientationNormal:(dispatch_block_t)block {
    UINavigationController *topNavigationController = [SharedAppDelegate appTopNavigationController];
    if (topNavigationController && ([[UIApplication sharedApplication] statusBarOrientation] != topNavigationController.interfaceOrientation)) {
        
        __block BOOL excecuted = NO;
        
        //这种情况下push，会导致视图错乱，等statusBar转过来之后再push
        uint64_t startTime = [NSObject currentUnixTime];
        __block __weak id observer = nil;
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification * _Nonnull note) {
            
            uint64_t endTime = [NSObject currentUnixTime];
            //等statusBarOrientation转过来后再push，并且时间间隔需要在0.5s内，防止误伤
            if (([NSObject machTimeToSecs:endTime - startTime] < 0.5) && [[UIApplication sharedApplication] statusBarOrientation] == topNavigationController.interfaceOrientation && !excecuted) {
                block();
                excecuted = YES;
            }
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!excecuted) {
                block();
                excecuted = YES;
            }
        });
    }
    else {
        block();
    }
}

@end
