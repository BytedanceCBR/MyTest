//
//  HTSVideoPlayModule.m
//  Pods
//
//  Created by SongLi.02 on 20/11/2016.
//
//

#import "AWEVideoPlayModule.h"
#import "AWEVideoPlayAccountBridge.h"
#import <TTModuleBridge.h>
#import "AWEVideoDiskCache.h"

@implementation AWEVideoPlayModule

+ (void)load
{
    @autoreleasepool {
        [AWEVideoPlayAccountBridge registerLoginResultListener];
        [AWEVideoPlayAccountBridge registerLogoutResultListener];
        
        __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            
//            [AWEVideoPlayAccountBridge loginHotsoon];
            observer = nil;
        }];

    }
}

@end
