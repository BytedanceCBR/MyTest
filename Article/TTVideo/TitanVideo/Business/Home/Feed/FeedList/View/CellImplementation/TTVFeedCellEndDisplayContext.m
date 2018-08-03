//
//  TTVFeedCellEndDisplayContext.m
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import "TTVFeedCellEndDisplayContext.h"
#import "TTAdImpressionTracker.h"
#import "SSADEventTracker.h"
#import "TTADEventTrackerEntity.h"

@implementation TTVFeedCellEndDisplayContext

@end

@implementation TTVFeedEndDisplayHandler

+ (void)defaultADShowOverWithEntity:(TTADEventTrackerEntity *)entity context:(TTVFeedCellEndDisplayContext *)context
{
    NSString *adID = entity.ad_id;
    if (!isEmptyString(adID)) {
        NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:adID];
        NSDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:1];
        [adExtra setValue:trackInfo forKey:@"ad_extra_data"];
        NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:adID];
        [[SSADEventTracker sharedManager] trackEventWithEntity:entity label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration];
    }
}

@end
