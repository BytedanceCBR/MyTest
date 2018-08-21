//
//  TTAdVideoRelateAdModel.m
//  Article
//
//  Created by yin on 16/8/19.
//
//

#import "TTAdVideoRelateAdModel.h"
#import "NSDictionary+TTAdditions.h"
#import <TTBaseLib/TTBaseMacro.h>

#define separtor @"://"

#define kPlayerOverTrackUrlList @"playover_track_url_list"
#define kPlayerEffectiveTrackUrlList @"effective_play_track_url_list"
#define kPlayerActiveTrackUrlList @"active_play_track_url_list"
#define kPlayerTrackUrlList @"play_track_url_list"
#define kClickTrackUrlList @"click_track_url_list"
#define kShowTrackUrlList @"track_url_list"
#define kEffectivePlayTime @"effective_play_time"

@implementation TTAdVideoRelateAdModel

//相关视频位视频广告数据转化成TTAdVideoRelateAdModel
- (instancetype)initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.card_type = [dict tt_stringValueForKey:@"card_type"];
        self.ad_id = [dict tt_stringValueForKey:@"ad_id"];
        self.show_tag = [dict tt_stringValueForKey:@"show_tag"];
        self.source = [dict tt_stringValueForKey:@"source"];
        self.log_extra = [dict tt_stringValueForKey:@"log_extra"];
        self.web_url = [dict tt_stringValueForKey:@"web_url"];
        self.title = [dict tt_stringValueForKey:@"title"];
        self.image_url = [dict tt_stringValueForKey:@"image_url"];
        self.track_url_list = [dict tt_arrayValueForKey:kShowTrackUrlList];
        self.click_track_url_list = [dict tt_arrayValueForKey:kClickTrackUrlList];
        self.adPlayTrackUrls = [dict tt_arrayValueForKey:kPlayerTrackUrlList];
        self.adPlayActiveTrackUrls = [dict tt_arrayValueForKey:kPlayerActiveTrackUrlList];
        self.adPlayEffectiveTrackUrls = [dict tt_arrayValueForKey:kPlayerEffectiveTrackUrlList];
        self.adPlayOverTrackUrls = [dict tt_arrayValueForKey:kPlayerOverTrackUrlList];
        self.effectivePlayTime = [dict tt_floatValueForKey:kEffectivePlayTime];
        self.ui_type = @([dict tt_intValueForKey:@"ui_type"]);

        NSDictionary* imageDict = [dict tt_dictionaryValueForKey:@"middle_image"];
        self.middle_image = [[TTAdVideoRelateAdImageUrlModel alloc] initWithDictionary:imageDict error:nil];
        self.type = [dict tt_stringValueForKey:@"type"];
        self.is_preview = @([dict tt_integerValueForKey:@"is_preview"]);
        self.creative_type = [dict tt_stringValueForKey:@"creative_type"];
        self.button_text = [dict tt_stringValueForKey:@"button_text"];
        self.phone_number = [dict tt_stringValueForKey:@"phone_number"];
        self.download_url = [dict tt_stringValueForKey:@"download_url"];
        self.apple_id = [dict tt_stringValueForKey:@"apple_id"];
        self.open_url = [dict tt_stringValueForKey:@"open_url"];
        self.ipa_url = [dict tt_stringValueForKey:@"ipa_url"];
        self.dial_action_type = @([dict tt_intValueForKey:@"dial_action_type"]);
        self.form_url = [dict tt_stringValueForKey:@"form_url"];
        self.form_width = @([dict tt_intValueForKey:@"form_width"]);
        self.form_height = @([dict tt_intValueForKey:@"form_height"]);
        self.use_size_validation = @([dict tt_intValueForKey:@"use_size_validation"]);
    }
    return self;
}



- (BOOL)isValidAd
{
    BOOL validImage = self.middle_image&&[self.middle_image isKindOfClass:[TTAdVideoRelateAdImageUrlModel class]];
    BOOL validStr = !isEmptyString(self.title)&&!isEmptyString(self.source)&&!isEmptyString(self.show_tag)&&!isEmptyString(self.web_url)&&!isEmptyString(self.ad_id);
    return validImage && validStr;
}

- (NSString<Optional>*)appUrl
{
    if ([_open_url rangeOfString:separtor].location!=NSNotFound) {
        NSRange seperateRange = [_open_url rangeOfString:separtor];
        NSInteger length = [_open_url length] - NSMaxRange(seperateRange);
        if (!isEmptyString(_open_url)&&length>0) {
            NSString* app_url = [_open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
            return app_url;
        }
    }
    return nil;
}

- (NSString<Optional>*)tabUrl
{
    NSRange seperateRange = [_open_url rangeOfString:separtor];
    NSString* tab_url = [_open_url substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [_open_url length] - NSMaxRange(seperateRange))];
    return tab_url;
}

- (TTAdActionType)actionType
{
    if ([self.type isEqualToString:@"app"]) {
        return TTAdActionTypeApp;
    }
    else if ([self.type isEqualToString:@"action"]){
        return TTAdActionTypePhone;
    }
    else if ([self.type isEqualToString:@"web"]){
        return TTAdActionTypeWeb;
    }
    else if ([self.type isEqualToString:@"form"]){
        return TTAdActionTypeForm;
    }
    return TTAdActionTypeWeb;
}

@end

@implementation TTAdVideoRelateAdImageUrlModel

@end


@implementation TTAdVideoRelateAdUrlModel

@end


