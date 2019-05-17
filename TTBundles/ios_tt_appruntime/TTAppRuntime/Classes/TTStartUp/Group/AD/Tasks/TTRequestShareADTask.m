//
//  TTRequestShareADTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTRequestShareADTask.h"

@implementation TTRequestShareADTask

- (NSString *)taskIdentifier {
    return @"RequestShareAD";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestShareAd];
    });
}

- (void)requestShareAd {
    
}

@end
