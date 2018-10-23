//
//  TTCookieStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTCookieStartupTask.h"
#import "SSCookieManager.h"
#import "ExploreExtenstionDataHelper.h"

@implementation TTCookieStartupTask

- (NSString *)taskIdentifier {
    return @"TimeInterval";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //共享cookie 给extenstion
    if (!isEmptyString([SSCookieManager sessionIDFromCookie])) {
        [ExploreExtenstionDataHelper saveSharedSessionID:[SSCookieManager sessionIDFromCookie]];
    }
    //共享openUDID给extension
    NSString *openUDID = [TTDeviceHelper openUDID];
    if (!isEmptyString(openUDID)) {
        [ExploreExtenstionDataHelper saveSharedOpenUDID:openUDID];
    }
}

@end
