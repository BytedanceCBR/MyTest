//
//  TTWatchConnectionTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTWatchConnectionTask.h"
#import "TTPhoneConnectWatchManager.h"
#import "TTRoute.h"

@implementation TTWatchConnectionTask

- (NSString *)taskIdentifier {
    return @"WatchConnection";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] initWatchConnection];
}

#pragma mark - 打开Watch Session
+ (void)initWatchConnection{
    [[TTPhoneConnectWatchManager sharedInstance] initWCSession];
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    if (userInfo[@"url"]) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:userInfo[@"url"]]];
        [[TTMonitor shareManager] trackService:@"watchkit_active" status:1 extra:nil];
        
        reply(@{@"status":@"done"});
    }
    else{
        [[TTMonitor shareManager] trackService:@"watchkit_active" status:2 extra:nil];
        reply(@{@"status":@"fail"});
    }
}

@end
