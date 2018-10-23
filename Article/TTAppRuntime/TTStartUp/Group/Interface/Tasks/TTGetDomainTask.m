//
//  TTGetDomainTask.m
//  Article
//
//  Created by fengyadong on 17/1/20.
//
//

#import "TTGetDomainTask.h"
#import "TTRouteSelectionServerConfig.h" //add by songlu

@implementation TTGetDomainTask

- (NSString *)taskIdentifier {
    return @"GetDomain";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestGetDomainKey]) {
            BOOL isChromiumEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isChromiumEnabled;
            if ([SSCommonLogic isRefactorGetDomainsEnabled]) {
                if (!isChromiumEnabled) {
                    LOGD(@"Chromium is not Enabled and do refactorRequestURLDomains");
                    [[CommonURLSetting sharedInstance] refactorRequestURLDomains];
                } else {
                    LOGD(@"Chromium is Enabled and not do refactorRequestURLDomains");
                }
            } else {
                if (!isChromiumEnabled) {
                    LOGD(@"Chromium is not Enabled and do requestURLDomains");
                    [[CommonURLSetting sharedInstance] requestURLDomains];
                } else {
                    LOGD(@"Chromium is Enabled and not do requestURLDomains");
                }
            }
            
            [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestGetDomainKey];
        }
    });
}

@end
