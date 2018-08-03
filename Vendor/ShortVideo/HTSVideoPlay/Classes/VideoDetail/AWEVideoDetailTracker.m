//
//  AWEVideoDetailTrackingInfo.m
//  Pods
//
//  Created by Zuyang Kou on 03/07/2017.
//
//

#import "AWEVideoDetailTracker.h"
#import "TSVShortVideoOriginalData.h"
#import "AWEVideoPlayTrackerBridge.h"
#import <TTBaseLib/TTBaseMacro.h>

@interface AWEVideoDetailTracker ()

@property (nonatomic, copy, nullable) NSDate *stayPageStartTime;

@end

@implementation AWEVideoDetailTracker

+ (void)trackEvent:(NSString *)event
             model:(TTShortVideoModel *)model
   commonParameter:(NSDictionary *)commonParameter
    extraParameter:(NSDictionary *)extraParameter;
{
#if !DEBUG
    @try {
#endif
        NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
        [parameterDictionary addEntriesFromDictionary:commonParameter];
        NSMutableDictionary *paramters = @{}.mutableCopy;
        paramters[@"group_id"] = model.groupID;
        paramters[@"item_id"] =  model.itemID;
        paramters[@"user_id"] =  model.author.userID;
        paramters[@"group_source"] = model.groupSource;
        [parameterDictionary addEntriesFromDictionary:paramters];
        if (model.logPb) {
            parameterDictionary[@"log_pb"] = model.logPb;
        }
        
        if (!isEmptyString(model.activity.concernID)) {
            parameterDictionary[@"concern_id"] = model.activity.concernID;
        }
        
        if (!isEmptyString(model.cardID)) {
            parameterDictionary[@"card_id"] = model.cardID;
        }
        if (!isEmptyString(model.cardPosition)) {
            parameterDictionary[@"card_position"] = model.cardPosition;
        }
        if (!isEmptyString(model.listEntrance)) {
            parameterDictionary[@"list_entrance"] = model.listEntrance;
        }

        if (!isEmptyString(model.categoryName)) {
            parameterDictionary[@"category_name"] = model.categoryName;
        }
        
        if (!isEmptyString(model.enterFrom)) {
            parameterDictionary[@"enter_from"] = model.enterFrom;
        }

        parameterDictionary[@"is_follow"] = @(model.author.isFollowing);
        parameterDictionary[@"is_friend"] = @(model.author.isFriend);

        [parameterDictionary addEntriesFromDictionary:extraParameter];

        if (parameterDictionary[@"to_user_id"] && parameterDictionary[@"user_id"]) {
            [parameterDictionary removeObjectForKey:@"user_id"];
        }

        [AWEVideoPlayTrackerBridge trackEvent:event params:parameterDictionary];
#if !DEBUG
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
#endif
}

- (void)flushStayPageTime
{
    self.stayPageStartTime = [NSDate date];
}

- (NSTimeInterval)timeIntervalForStayPage
{
    return [[NSDate date] timeIntervalSinceDate:self.stayPageStartTime];
}

@end
