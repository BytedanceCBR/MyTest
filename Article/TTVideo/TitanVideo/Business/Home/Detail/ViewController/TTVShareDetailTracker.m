//
//  TTVShareDetailTracker.m
//  Article
//
//  Created by lishuangyang on 2017/7/31.
//
//

#import "TTVShareDetailTracker.h"
#import "TTTrackerWrapper.h"

static NSString *FROMSOURCE = @"fromSource";
@interface TTVShareDetailTracker ()<TTVShareDetailTrackerMessage>

@end

@implementation TTVShareDetailTracker

- (void)dealloc
{
    UNREGISTER_MESSAGE(TTVShareDetailTrackerMessage, self);
}

- (instancetype)init{
    self = [super init];
    if (self) {
        REGISTER_MESSAGE(TTVShareDetailTrackerMessage, self);
    }
    return self;
}

#pragma mark - TTVShareDetailActionTrackMessage
- (void)message_detailShareTrackWithGroupID:(NSString *)groupId ActivityType:(TTActivityType )activityType extraDic:(NSDictionary *)extraDic fullScreen:(BOOL )fullScreen
{
    [self shareTrackWithGroupID:groupId ActivityType:activityType extraDic:extraDic fullScreen:fullScreen iconSeat:@"inside"];
}

- (void)message_detailExposedShareTrackWithGroupID:(NSString *)groupId ActivityType:(TTActivityType )activityType extraDic:(NSDictionary *)extraDic fullScreen:(BOOL )fullScreen
{
    [self shareTrackWithGroupID:groupId ActivityType:activityType extraDic:extraDic fullScreen:fullScreen iconSeat:@"exposed"];
}

- (void)message_detailshareTrackActivityWithGroupID:(NSString *)groupId ActivityType:(TTActivityType)activityType FromSource:(NSString *)fromSource eventName:(NSString *)eventName
{
    TTActivitySectionType sectionType = 100; //100返回空
    NSString *iconSeat = @"inside";
    BOOL isFullScreen = NO;
    if (fromSource) {
        if ([fromSource isEqualToString:@"centre_button"]) {
            sectionType = TTActivitySectionTypeCentreButton;
        }else if ([fromSource isEqualToString:@"player_more"]){
            sectionType = TTActivitySectionTypePlayerMore;
            isFullScreen = YES;
        }else if ([fromSource isEqualToString:@"player_share"]){
            sectionType = TTActivitySectionTypePlayerShare;
            isFullScreen = YES;
        }else if ([fromSource isEqualToString:@"detail_video_over"]){
            sectionType = TTActivitySectionTypeDetailVideoOver;
        }else if ([fromSource isEqualToString:@"detail_video_over_direct"]){
            sectionType = TTActivitySectionTypeDetailVideoOver;
            iconSeat = @"exposed";
        }else if ([fromSource isEqualToString:@"centre_button_direct"]){
            sectionType = TTActivitySectionTypeCentreButton;
            iconSeat = @"exposed";
        }else if ([fromSource isEqualToString:@"detail_bottom_bar"]){
            sectionType = TTActivitySectionTypeDetailBottomBar;
        }else if([fromSource isEqualToString:@"no_full_more"]){
            sectionType = TTActivitySectionTypePlayerMore;
        }else if([fromSource isEqualToString:@"player_click_share"]){
            sectionType = TTActivitySectionTypePlayerDirect;
            iconSeat = @"exposed";
            isFullScreen = YES;
        }else{
            sectionType = 1000;
            iconSeat = nil;
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
        [params setValue:sectionName forKey:@"section"];
        [params setValue:@"video" forKey:@"source"];
        [params setValue:_position forKey:@"position"];
        [params setValue:_groupID forKey:@"group_id"];
        [params setValue:_itemID forKey:@"item_id"];
        [params setValue:_logPb forKey:@"log_pb"];
        [params setValue:screenState forKey:@"fullscreen"];
        NSNumber *isDouble = @NO;
        if ([params valueForKey:@"isDoublSending"]){
            isDouble = [params valueForKey:@"isDoublSending"];
            [params removeObjectForKey:@"isDoublSending"];
        }
        [TTTrackerWrapper eventV3:eventName params:params isDoubleSending:isDouble.boolValue];
    }
}

- (NSString *)paramsAddPlatForm:(NSMutableDictionary *)params
                 FromActionType:(TTActivityType )activityType
                       extraDic:(NSDictionary *)extraDic
                    andiconSeat:(NSString *)iconSeat{
    
    NSString *eventName;
    NSString *sectionName = [TTVideoCommon videoSectionNameForShareActivityType:[self sectionType:extraDic]];
    NSString *activityName = [TTVideoCommon videoListlabelNameForShareActivityType:activityType];
    if (activityType == TTActivityTypeNone) {
        if ([sectionName rangeOfString:@"more"].location == NSNotFound ) {
            eventName = @"share_button_cancel";
        }else{
            eventName = @"point_panel_cancel";
        }
    }
    else if(activityType == TTActivityTypeShareButton){
        if ([sectionName rangeOfString:@"more"].location == NSNotFound ) {
            eventName = @"share_button";
        }else{
            eventName = @"point_panel";
        }
    }
    else if (activityType == TTActivityTypeDigDown ) {
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
    }
    else if (activityType == TTActivityTypeFavorite){
        eventName = [NSString stringWithFormat:@"%@",[extraDic valueForKey:@"favorite_name"]];
        [params setValue:self.authorId forKey:@"author_id"];
        [params setValue:@"video" forKey:@"article_type"];
    }else if (activityType == TTActivityTypeDislike){
        eventName = @"dislike_button";
        NSArray *filterWords = [extraDic objectForKey:@"filter_words"];
        if (filterWords) {
            eventName = @"rt_dislike";
        }
        [params setValue:filterWords forKey:@"filter_words"];
        [params setValue:@(1) forKey:@"isDoublSending"];
    }else if(activityType == TTActivityTypeReport){
        eventName = @"report_button";
        NSArray *filterWords = [extraDic objectForKey:@"reason"];
        if (filterWords) {
            eventName = @"rt_report";
        }
        [params setValue:filterWords forKey:@"reason"];
    }
    else{
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

@end
