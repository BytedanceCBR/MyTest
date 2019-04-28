//
//  TTNetworkStubTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTNetworkStubTask.h"
#import "TTNetworkStub.h"

@implementation TTNetworkStubTask

- (NSString *)taskIdentifier {
    return @"NetworkStub";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //Release环境去除OHHTTPStub相关代码用，勿动
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Class class = NSClassFromString(@"TTNetworkStub");
    if (class) {
        [[class sharedInstance] performSelector:@selector(restoreAllStubs) withObject:nil];
    }
#pragma clang diagnostic pop
}

@end
