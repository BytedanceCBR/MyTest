//
//  TTVADEventTracker.m
//  Article
//
//  Created by pei yun on 2017/8/1.
//
//

#import "TTVADEventTracker.h"
#import "TTTrackerProxy.h"

@implementation TTVADEventTracker

+ (void)ttv_adEventTrackerWithTag:(NSString *)tag label:(NSString *)label adID:(NSString *)adID logExtra:(NSString *)logExtra
{
    [self ttv_adEventTrackerWithTag:tag label:label adID:adID logExtra:logExtra extraParamsDict:nil];
}

+ (void)ttv_adEventTrackerWithTag:(NSString *)tag label:(NSString *)label adID:(NSString *)adID logExtra:(NSString *)logExtra extraParamsDict:(NSDictionary *)extraParamsDict
{
    if (isEmptyString(adID)) {
        return;
    }
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:7];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:adID forKey:@"value"];
    [events setValue:logExtra forKey:@"log_extra"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];;
    [events setValue:@(connectionType) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    if (extraParamsDict) {
        [events addEntriesFromDictionary:extraParamsDict];
    }
    
    [TTTrackerWrapper eventData:events];
}

@end
