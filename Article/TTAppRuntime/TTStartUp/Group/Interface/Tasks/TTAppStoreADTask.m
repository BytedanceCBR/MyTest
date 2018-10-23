//
//  TTAppStoreADTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTAppStoreADTask.h"
#import <iAd/ADClient.h>
#import "TTNetworkManager.h"

@implementation TTAppStoreADTask

- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    return [TTDeviceHelper OSVersionNumber] >= 10.0f;
}

- (NSString *)taskIdentifier {
    return @"AppStoreAD";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] checkAttributionAPI];
}

+ (void)checkAttributionAPI {
    BOOL noAttibutionAPI = [[NSUserDefaults standardUserDefaults] boolForKey:@"noAttibutionAPI"];
    if (!noAttibutionAPI && [[ADClient sharedClient] respondsToSelector:@selector(requestAttributionDetailsWithBlock:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            [[ADClient sharedClient] requestAttributionDetailsWithBlock:^(NSDictionary *attributionDetails, NSError *error) {
#pragma clang diagnostic pop
                
                if (!error){
                    NSDictionary* newAttributionDetails;
                    NSString* versionKey;
                    for (NSString* key in attributionDetails.allKeys){
                        if([key hasPrefix:@"Version"]){
                            versionKey = key;
                            break;
                        }
                    }
                    
                    if(!versionKey){
                        return ;
                    }
                    
                    newAttributionDetails = [attributionDetails tt_dictionaryValueForKey:versionKey];
                    BOOL attribution = [newAttributionDetails tt_boolValueForKey:@"iad-attribution"];
                    if(!attribution){
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noAttibutionAPI"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        return;
                    }
                    
                    NSString* url = @"https://track.toutiao.com/search_ads/attribution/";
                    NSDictionary* paramsKeys = @{@"iad-org-name":@"org",
                                                 @"iad-campaign-name":@"campaign_name",
                                                 @"iad-campaign-id":@"campaign_id",
                                                 @"iad-conversion-date":@"conversion_date",
                                                 @"iad-click-date":@"click_date",
                                                 @"iad-adgroup-id":@"adgroup_id",
                                                 @"iad-adgroup-name":@"adgroup_name",
                                                 @"iad-keyword":@"keyword"};
                    NSMutableDictionary* params = [NSMutableDictionary new];
                    
                    for (NSString* key in paramsKeys.allKeys){
                        NSString* value = [newAttributionDetails tt_stringValueForKey:key];
                        NSString* newKey = [paramsKeys tt_stringValueForKey:key];
                        [params setValue:value forKey:newKey];
                    }
                    
                    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
                        if(!error){
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noAttibutionAPI"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }];
                }
            }];
        });
    }
}

@end
