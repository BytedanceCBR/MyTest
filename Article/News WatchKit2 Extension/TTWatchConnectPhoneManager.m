//
//  WatchConnectPhoneManager.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/19.
//
//

#import <WatchConnectivity/WatchConnectivity.h>
#import "TTWatchConnectPhoneManager.h"
#import "TTWatchCommonInfoManager.h"

@interface TTWatchConnectPhoneManager ()<WCSessionDelegate>

@property(strong,nonatomic) WCSession *session;

@end

@implementation TTWatchConnectPhoneManager

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static TTWatchConnectPhoneManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TTWatchConnectPhoneManager alloc] init];
    });
    return manager;
}

- (void)initWCSession{
    if ([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
    }
}

- (void)openParentApplication:(NSDictionary *)userInfo reply:(void (^)(NSError *error))replyBlock{
    NSError *error;
    if ([_session respondsToSelector:@selector(activationState)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if (_session.activationState == WCSessionActivationStateActivated) {
#pragma clang diagnostic pop
            if(_session.isReachable){
                [_session sendMessage:userInfo replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(replyBlock){
                            replyBlock(nil);
                        }
                    });
                } errorHandler:^(NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(replyBlock){
                            replyBlock(error);
                        }
                    });
                }];
            }
            else {
                error = [NSError errorWithDomain:@"WCSession is not reachable" code:-2 userInfo:nil];
                if(replyBlock){
                    replyBlock(error);
                }
            }
        }
        else {
            error = [NSError errorWithDomain:@"WCSession is not reachable" code:-2 userInfo:nil];
            if(replyBlock){
                replyBlock(error);
            }
        }
    }
    else {
        if(_session.isReachable){
            [_session sendMessage:userInfo replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(replyBlock){
                        replyBlock(nil);
                    }
                });
            } errorHandler:^(NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(replyBlock){
                        replyBlock(error);
                    }
                });
            }];
        }
        else {
            error = [NSError errorWithDomain:@"WCSession is not reachable" code:-2 userInfo:nil];
            if(replyBlock){
                replyBlock(error);
            }
        }
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([message objectForKey:@"deviceID"]){
            [self saveDeviceID:[message objectForKey:@"deviceID"]];
        }
    });

}

- (void)saveDeviceID:(NSString *)deviceID{
    [TTWatchCommonInfoManager saveDeviceID:deviceID];
}

#pragma mark - WCSessionDelegate
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error{
#pragma clang diagnostic pop
    //Todo
}

@end
