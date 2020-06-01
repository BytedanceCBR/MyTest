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
#import "SSCommonLogic.h"
#import "TTLaunchDefine.h"
//#import <BDUGLocationKit/BDUGLocationNetworkManager.h>
#import <BDUGLocationKit/BDUGAmapGeocoder.h>
#import <FHHouseBase/FHMainApi.h>
#import <FHHouseBase/FHLocManager.h>
#import "BDUGLocationDataCollect.h"
#import "FHEnvContext.h"
#import "FHLocManager.h"
DEC_TASK("TTLocationStartupTask",FHTaskTypeAfterLaunch,TASK_PRIORITY_HIGH+1);

@implementation TTLocationStartupTask

- (NSString *)taskIdentifier {
    return @"Location";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    [[TTLocationManager sharedManager]disableReportLocationAtFinishLaunch];
    
    [self uploadLocationWithBlock:^(BOOL isSuccess) {
        //        NSLog(@"zjing test:isSuccess:%ld",isSuccess);
    }];
    
}
#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
//    if (![SSCommonLogic shouldUseOptimisedLaunch]) {
//        //更新扩展的location
//        TTPlacemarkItem *locationItem = [TTLocationManager sharedManager].placemarkItem;
//        if (locationItem.coordinate.latitude * locationItem.coordinate.longitude > 0) {
//            [ExploreExtenstionDataHelper saveSharedLatitude:locationItem.coordinate.latitude];
//            [ExploreExtenstionDataHelper saveSharedLongitude:locationItem.coordinate.longitude];
//        }
//        [ExploreExtenstionDataHelper saveSharedUserCity:[TTLocationManager sharedManager].city];
//        [[TTCookieManager sharedManager] updateLocationCookie];
//    }
}


- (void)uploadLocationWithBlock:(void (^)(BOOL isSuccess))block
{
    //单次采集上报
    if ([[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        [[FHLocManager sharedInstance] configLocationManager];
        [BDUGLocationDataCollect sharedCollector].geocoders = @[[BDUGAmapGeocoder sharedGeocoder]];
        [[BDUGLocationDataCollect sharedCollector] reportLocationInfoWithCompletion:^(BDUGLocationInfo * _Nullable locationInfo, NSError * _Nullable error) {
               if (block) {
                   block(error?NO:YES);
               }
        }];
    }

//
//    [BDUGAmapGeocoder sharedGeocoder].apiKey = [FHLocManager amapAPIKey];
//    [BDUGLocationNetworkManager sharedManager].allowedPopupAlert = NO;
//    [BDUGLocationNetworkManager sharedManager].hostEnvironment = BDUGLocationEnvironmentChina;
//    [BDUGLocationNetworkManager sharedManager].baseURLString = [FHMainApi host];
//    [BDUGLocationNetworkManager sharedManager].geocoders = @[[BDUGAmapGeocoder sharedGeocoder]];// [BDUGByteDanceGeocoder sharedGeocoder]
//    [[BDUGLocationNetworkManager sharedManager]startPollingReportLocationInfoWithCompletion:^(BDUGLocationInfo * _Nullable locationInfo, NSError * _Nullable error) {
//        if (block) {
//            block(error?NO:YES);
//        }
//    }];
}

@end
