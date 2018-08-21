//
//  ExtensionDelegate.m
//  Watch Complication Extension
//
//  Created by 邱鑫玥 on 16/8/18.
//
//

#import "ExtensionDelegate.h"
#import "TTWatchFetchDataManager.h"
#import "TTWatchPageManager.h"
#import "TTWatchConnectPhoneManager.h"

typedef NS_ENUM(NSUInteger, TTWatchActiveType){
    TTWatchActiveTypeFromLaunch = 0,
    TTWatchActiveTypeFromBackground,
    TTWatchActiveTypeFromComplicationPreLaunch,
    TTWatchActiveTypeFromComplicationPreBackground
};

@interface ExtensionDelegate ()

@property (assign,nonatomic) NSInteger activeType;

@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    _activeType = TTWatchActiveTypeFromLaunch;
    [[TTWatchConnectPhoneManager sharedInstance] initWCSession];
}

- (void)applicationDidBecomeActive {
    if(_activeType == TTWatchActiveTypeFromComplicationPreBackground){
        //加载历史缓存数据
        [TTWatchPageManager loadCachedData];
    }
    else if(_activeType == TTWatchActiveTypeFromBackground){
        if([[TTWatchFetchDataManager sharedInstance] shouldFetchRemoteData]){
            [TTWatchPageManager loadRemoteData];
        }
        else if([TTWatchFetchDataManager sharedInstance].hasBackgroundRefreshData){
            [TTWatchPageManager loadCachedData];
            [TTWatchFetchDataManager sharedInstance].hasBackgroundRefreshData = NO;
        }
    }
        
    //默认下次加载就是从后台加载的
    _activeType = TTWatchActiveTypeFromBackground;
    
    if([[[WKInterfaceDevice currentDevice] systemVersion] floatValue] >= 3.0){
        [[TTWatchFetchDataManager sharedInstance] stopBackgroundRefresh];
    }
}

- (void)handleUserActivity:(NSDictionary *)userInfo{
    if(_activeType == TTWatchActiveTypeFromBackground){
        _activeType = TTWatchActiveTypeFromComplicationPreBackground;
    }
    else{
        _activeType = TTWatchActiveTypeFromComplicationPreLaunch;
    }
}

- (void)applicationWillResignActive{
    [[TTWatchFetchDataManager sharedInstance] scheduleNextBackgroundRefresh];
}

//API for 3
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [[TTWatchFetchDataManager sharedInstance] startBackgroundRefreshWithTask:backgroundTask];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // To fix.目前没有收到过WKURLSessionRefreshBackgroundTask
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
//            NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:backgroundTask.sessionIdentifier];
//            [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:[TTWatchFetchDataManager sharedInstance] delegateQueue:nil];
            [backgroundTask setTaskCompleted];
        }
        else {
            [task setTaskCompleted];
        }
    }
}
#pragma clang diagnostic pop

@end
