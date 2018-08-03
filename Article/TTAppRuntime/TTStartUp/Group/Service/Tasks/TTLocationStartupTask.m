//
//  TTLocationStartupTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTLocationStartupTask.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTLocationManager.h"
#import "TTCookieManager.h"

@implementation TTLocationStartupTask

- (NSString *)taskIdentifier {
    return @"Location";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (![SSCommonLogic shouldUseOptimisedLaunch]) {
        //更新扩展的location
        TTPlacemarkItem *locationItem = [TTLocationManager sharedManager].placemarkItem;
        if (locationItem.coordinate.latitude * locationItem.coordinate.longitude > 0) {
            [ExploreExtenstionDataHelper saveSharedLatitude:locationItem.coordinate.latitude];
            [ExploreExtenstionDataHelper saveSharedLongitude:locationItem.coordinate.longitude];
        }
        [ExploreExtenstionDataHelper saveSharedUserCity:[TTLocationManager sharedManager].city];
        [[TTCookieManager sharedManager] updateLocationCookie];
    }
}

@end
