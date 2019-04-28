//
//  HTSAppSettingsModel.m
//  LiveStreaming
//
//  Created by Quan Quan on 16/11/6.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "HTSAppSettingsModel.h"

@implementation HTSAppSettingsModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"HTTP_RETRY_COUNT"    : @"data.http_retry_count",
             @"HTTP_RETRY_INTERVAL" : @"data.http_retry_interval",
             @"HTTP_TIMEOUT"        : @"data.http_timeout",
             @"encryptModel"        : @"data.sp",
             @"videoSlideAction"    : @"data.video_updown_slide",
             @"profileActivity"     : @"data.guide_setting",
             @"settingGuideList"    : @"data.guide_setting_list",
             @"videoFollowGuide"    : @"data.video_follow_guide",
             @"pushFreq"            : @"data.push_popup_freq",
             @"pushDenyThreshold"   : @"data.push_popup_deny_threshold",
             @"pushCandidateFreq"   : @"data.push_popup_candidate_freq",
             @"reportCrashAction"   : @"data.ios_action_report",
             @"liveFeedStyle"       : @"data.feed_live_icon_type",
             @"guestPhotoButtonShow": @"data.anonymous_show_publish_button",
             @"loginBtnStyle"       : @"data.anonymous_login_button_style",
             @"followBadgePriority" : @"data.feed_follow_red_point_priority",
             @"launchPositionAB"    : @"data.feed_default_position_type",
             @"networkLibUpgrade"   : @"data.network_lib_upgrade",
             @"videoPlayerType"     : @"data.video_player_type",
             @"videoSlideControl"   : @"data.video_slide_control",
             @"videoDurationLimit"  : @"data.video_duration_upper_limit",
             @"isFakeVersion"       : @"data.is_fake_version",
             @"showCommentAlert"    : @"data.rate_on_withdraw_success",
             @"enableMusicSearch"   : @"data.enable_baidu_music_sdk",
             @"musicFilterTitles"   : @"data.filter_search_song_titles",
             @"musicFilterAuthors"  : @"data.filter_search_song_authors",
             @"enableProfileUserRecommend" : @"data.enable_profile_recommend_user",
             };
}

+ (NSValueTransformer *)profileActivityJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[HTSProfileActivityModel class]];
}

+ (NSValueTransformer *)encryptModelJSONTransformer
{
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[HTSSettingsEncryptModel class]];
}

+ (NSValueTransformer *)settingGuideListJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[HTSProfileActivityModel class]];
}

@end

#pragma mark -- HTSProfileActivityModel

@implementation HTSProfileActivityModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"activityID"  : @"id",
             @"title"       : @"title",
             @"message"     : @"description",
             @"text"        : @"button_name",
             @"URL"         : @"schema_url"
             };
}

- (BOOL)isValid
{
    if (self.activityID && self.title.length > 0 && self.text.length > 0 && self.URL.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end

#pragma mark -- HTSSettingsEncryptModel

@implementation HTSSettingsEncryptModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"estr" : @"estr"};
}

@end


