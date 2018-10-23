//
//  TTPhoneConnectWatchManager.m
//  TouTiao910Watch
//
//  Created by 邱鑫玥 on 16/9/11.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "TTPhoneConnectWatchManager.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "TTRoute.h"
#import "NewsBaseDelegate.h"

@interface TTPhoneConnectWatchManager()<WCSessionDelegate>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@property (strong,nonatomic) WCSession *wcSession;
#pragma clang diagnostic pop

@end

@implementation TTPhoneConnectWatchManager

static TTPhoneConnectWatchManager *manager;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)initWCSession{
    if([TTDeviceHelper OSVersionNumber] >= 9.f){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if ([WCSession isSupported]) {
            _wcSession = [WCSession defaultSession];
            _wcSession.delegate = self;
            [_wcSession activateSession];
        }
    }
}

//需要注意这些回调都是在子线程中进行
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error{
    //Todo
}

- (void)sessionDidBecomeInactive:(WCSession *)session{
    //Todo
}

- (void)sessionDidDeactivate:(WCSession *)session{
    //Todo
    [_wcSession activateSession];
}
- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext{
    [self watchOpenURL:applicationContext];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler{
    [self watchOpenURL:message];
    replyHandler(@{@"state":@"1"});
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo{
    [self watchOpenURL:userInfo];
}

- (void)watchOpenURL:(NSDictionary *)dic{
    NSURL *url = [NSURL URLWithString:[dic objectForKey:@"url"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(appTopNavigationController)]){
            UINavigationController *navCon = [[[UIApplication sharedApplication] delegate] performSelector:@selector(appTopNavigationController)];
            BOOL ret = [[TTRoute sharedRoute] canOpenURL:url];
            if (ret && navCon) {
                [[TTRoute sharedRoute] openURLByPushViewController:url];
            }
        }
        
    });
}

- (void)sendUserInfo:(NSDictionary *)dic{
    if ([_wcSession respondsToSelector:@selector(activationState)]) {
        if (_wcSession.activationState == WCSessionActivationStateActivated) {
            if (_wcSession.isReachable) {
                [_wcSession sendMessage:dic replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                    
                } errorHandler:^(NSError * _Nonnull error) {
                    
                }];
            }
        }
    }
    else {
        if (_wcSession.isReachable) {
            [_wcSession sendMessage:dic replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                
            } errorHandler:^(NSError * _Nonnull error) {
                
            }];
        }
    }
}
#pragma clang diagnostic pop

@end
