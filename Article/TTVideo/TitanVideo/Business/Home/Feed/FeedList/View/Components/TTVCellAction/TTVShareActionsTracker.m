//
//  TTVShareActionSTracker.m
//  Article
//
//  Created by lishuangyang on 2017/7/26.
//
//
#import "TTTrackerWrapper.h"
#import "TTVShareActionsTracker.h"
#import "TTTrackerProxy.h"

static NSString *FROMSOURCE = @"fromSource";
@interface TTVShareActionsTracker ()<TTVShareActionTrackMessage>

@end

@implementation TTVShareActionsTracker

- (void)dealloc
{
    UNREGISTER_MESSAGE(TTVShareActionTrackMessage, self);
}

- (instancetype)init{
    self = [super init];
    if (self) {
        REGISTER_MESSAGE(TTVShareActionTrackMessage, self);
    }
    return self;
}

#pragma mark - TTVShareActionTrackMessage
- (void)message_shareTrackWithGroupID:(NSString *)groupId ActivityType:(TTActivityType )activityType extraDic:(NSDictionary *)extraDic fullScreen:(BOOL )fullScreen
{
    [self shareTrackWithGroupID:groupId ActivityType:activityType extraDic:extraDic fullScreen:fullScreen iconSeat:@"inside"];
}

- (void)message_shareTrackActivityWithGroupID:(NSString *)groupId ActivityType:(TTActivityType)activityType FromSource:(NSString *)fromSource eventName:(NSString *)eventName
{
    TTActivitySectionType sectionType = 100; //100返回空
    NSString *iconSeat = @"inside";
    BOOL isFullScreen = NO;
        if (fromSource) {
            if ([fromSource isEqualToString:@"list_more"]) {
                sectionType = TTActivitySectionTypeListMore;
            }else if ([fromSource isEqualToString:@"player_more"]){
                sectionType = TTActivitySectionTypePlayerMore;
                isFullScreen = YES;
            }else if ([fromSource isEqualToString:@"player_share"]){
                sectionType = TTActivitySectionTypePlayerShare;
                isFullScreen = YES;
            }else if ([fromSource isEqualToString:@"list_video_over"]){
                sectionType = TTActivitySectionTypeListVideoOver;
            }else if ([fromSource isEqualToString:@"list_video_over_direct"]){
                sectionType = TTActivitySectionTypeListVideoOver;
                iconSeat = @"exposed";
            }else if ([fromSource isEqualToString:@"list_share"]){
                sectionType = TTActivitySectionTypeListShare;
            }else if ([fromSource isEqualToString:@"list_direct"]){
                sectionType = TTActivitySectionTypeListShare;
                iconSeat = @"exposed";
            }else if ([fromSource isEqualToString:@"player_direct"]){
                sectionType = TTActivitySectionTypePlayerDirect;
                iconSeat = @"exposed";
                isFullScreen = YES;
            }

        }
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:fromSource forKey:FROMSOURCE];
    [extraDic setValue:@(sectionType) forKey:@"sectionType"];
    [extraDic setValue:eventName forKey:@"eventName"];
    [self shareTrackWithGroupID:groupId ActivityType:activityType extraDic:[extraDic copy] fullScreen:isFullScreen iconSeat:iconSeat];
}

- (void)shareTrackWithGroupID:(NSString *)groupId
                 ActivityType:(TTActivityType)activityType
                     extraDic:(NSDictionary *)extraDic
                   fullScreen:(BOOL)fullScreen
                     iconSeat:(NSString *)iconseat
{
    if ([groupId isEqualToString:_groupID]) {
        NSString *sectionName = [TTVideoCommon videoSectionNameForShareActivityType:[self sectionType:extraDic]];
        NSString *screenState = (fullScreen ? @"fullscreen" : @"notfullscreen");
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *eventName = [self paramsAddPlatForm:params FromActionType:activityType extraDic:extraDic andiconSeat:iconseat];
        [params setValue:_categoryName forKey:@"category_name"];
        [params setValue:_enterFrom forKey:@"enter_from"];
        [params setValue:_categoryName forKey:@"category_name"];
        [params setValue:sectionName forKey:@"section"];
        [params setValue:@"video" forKey:@"source"];
        [params setValue:_position forKey:@"position"];
        [params setValue:_groupID forKey:@"group_id"];
        [params setValue:_logPb forKey:@"log_pb"];
        [params setValue:_itemID forKey:@"item_id"];
        [params setValue:screenState forKey:@"fullscreen"];
        NSNumber *isDouble = @NO;
        if ([params valueForKey:@"isDoublSending"]){
           isDouble = [params valueForKey:@"isDoublSending"];
            [params removeObjectForKey:@"isDoublSending"];
        }
        [TTTrackerWrapper eventV3:eventName params:params isDoubleSending:isDouble.boolValue];
    }
}

//广告dislike打点v1
- (void)message_shareTrackAdEventWithAdId:(NSString *)adId logExtra:(NSString *)logExtra tag:(NSString *)tag label:(NSString *)label  extra:(NSDictionary *)extra{
    if ([adId isEqualToString:_adId]) {
        TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
        NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
        [events setValue:@"umeng" forKey:@"category"];
        [events setValue:tag forKey:@"tag"];
        [events setValue:label forKey:@"label"];
        [events setValue:@(nt) forKey:@"nt"];
        [events setValue:@"1" forKey:@"is_ad_event"];
        [events setValue:adId forKey:@"value"];
        [events setValue:logExtra forKey:@"log_extra"];
        if (extra) {
            [events addEntriesFromDictionary:extra];
        }
        [TTTracker eventData:events];
    }
}

- (NSString *)paramsAddPlatForm:(NSMutableDictionary *)params
                 FromActionType:(TTActivityType )activityType
                       extraDic:(NSDictionary *)extraDic
                    andiconSeat:(NSString *)iconSeat{
    
    NSString *eventName = @"share_unkwon";
    NSString *sectionName = [TTVideoCommon videoSectionNameForShareActivityType:[self sectionType:extraDic]];
    NSString *activityName = [TTVideoCommon videoListlabelNameForShareActivityType:activityType];
    if (activityType == TTActivityTypeNone) {
        if ([sectionName rangeOfString:@"more"].location == NSNotFound ) {
            eventName = @"share_button_cancel";
        }else{
            eventName = @"point_panel_cancel";
        }
    }else if(activityType == TTActivityTypeShareButton){
        if ([sectionName rangeOfString:@"more"].location == NSNotFound ) {
            eventName = @"share_button";
        }else{
            eventName = @"point_panel";
        }
    }else if (activityType == TTActivityTypeDigDown ) {
        if (![extraDic tta_boolForKey:@"userBury"]) {
            eventName = @"rt_unbury";
        }else{
            eventName = @"rt_bury";
        }
        [params setValue:self.authorId forKey:@"author_id"];
        [params setValue:@"video" forKey:@"article_type"];
    }else if(activityType == TTActivityTypeDigUp){
        if (![extraDic tta_boolForKey:@"userDigg"]) {
            eventName = @"rt_unlike";
        }else{
            eventName = @"rt_like";
        }
        [params setValue:self.authorId forKey:@"author_id"];
        [params setValue:@"video" forKey:@"article_type"];
    }else if (activityType == TTActivityTypeFavorite){
        [params setValue:self.authorId forKey:@"author_id"];
        [params setValue:@"video" forKey:@"article_type"];
        eventName = [NSString stringWithFormat:@"%@",[extraDic valueForKey:@"favorite_name"]];
    }else if (activityType == TTActivityTypeDislike){
        eventName = @"dislike_button";
        NSArray *filterWords = [extraDic objectForKey:@"filter_words"];
        if (filterWords) {
            eventName = @"rt_dislike";
            [params setValue:@(1) forKey:@"isDoublSending"];
        }
        [params setValue:filterWords forKey:@"filter_words"];
    }else if(activityType == TTActivityTypeReport){
        eventName = @"report_button";
        NSString *filterWords = [extraDic objectForKey:@"reason"];
        if (filterWords) {
            eventName = @"rt_report";
        }
        [params setValue:filterWords forKey:@"reason"];
    }else{
        eventName = @"rt_share_to_platform";
        if ([[extraDic allKeys] containsObject:@"eventName"]) {
            eventName = [extraDic valueForKey:@"eventName"];
            if ([eventName hasSuffix:@"_done"]) {
                [params setValue:self.authorId forKey:@"author_id"];
                [params setValue:@"video" forKey:@"article_type"];
            }
        }
        NSString *platForm = [activityName stringByReplacingOccurrencesOfString:@"share_" withString:@""];
        platForm = [platForm stringByReplacingOccurrencesOfString:@"_link" withString:@""];
        [params setValue:platForm forKey:@"share_platform"];
        [params setValue:iconSeat forKey:@"icon_seat"];
        params[@"event_type"] = @"house_app2c_v2";

    }
    return eventName;
}

- (TTActivitySectionType)sectionType:(NSDictionary *)extraDic{
    
    NSNumber *section = [extraDic valueForKey:@"sectionType"];
    TTActivitySectionType sectionType = section.integerValue;
    if (!section) {
        sectionType = 1000; // 缺省值 对应的sectionName是空
    }
    return sectionType;
}

- (void)message_exposedShareTrackWithGroupID:(NSString *)groupId ActivityType:(TTActivityType)activityType extraDic:(NSDictionary *)extraDic fullScreen:(BOOL)fullScreen
{
    [self shareTrackWithGroupID:groupId ActivityType:activityType extraDic:extraDic fullScreen:fullScreen iconSeat:@"exposed"];
}

@end
