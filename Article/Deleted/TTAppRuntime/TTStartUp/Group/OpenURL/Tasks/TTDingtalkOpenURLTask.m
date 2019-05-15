//
//  TTDingtalkOpenURLTask.m
//  Article
//
//  Created by fengyadong on 17/1/24.
//
//

#import "TTDingtalkOpenURLTask.h"
#import <TTDingTalkShare.h>

@implementation TTDingtalkOpenURLTask

- (NSString *)taskIdentifier {
    return @"DingtalkOpenURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [TTDingTalkShare handleOpenURL:url];
}

@end
