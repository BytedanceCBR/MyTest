//
//  SSADModel.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-18.
//
//

#import "SSADModel.h"
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTBaseMacro.h>

static inline CGSize stringToSize(NSString *density) {
    if (isEmptyString(density))
        return CGSizeZero;
    
    NSArray *sizeArray = [density componentsSeparatedByString:@"x"];
    if (sizeArray.count == 2) {
        // TODO: 测下非数字的情况，比如"ax/"
        NSInteger width = [sizeArray.firstObject integerValue];
        NSInteger height = [sizeArray.lastObject integerValue];
        if (width > 0 && height > 0) {
            return CGSizeMake(width, height);
        }
    }
    return CGSizeZero;
}

@implementation TTAdRefreshModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id" : @"splashID",
                                                       @"log_extra" : @"logExtra",
                                                       }];
}

@end

@implementation SSADModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                        @"id" : @"splashID",
                                                        @"log_extra" : @"logExtra",
                                                        @"display_density" : @"display_density",

                                                        @"display_time_ms" : @"displayTime",
                                                        @"max_display_time_ms" : @"maxDisplayTime",
                                                        @"display_after" : @"splashDisplayAfterSecond",
                                                        @"expire_seconds" : @"splashExpireSeconds",
                                                        @"splash_load_type" : @"commerceType",
                                                        @"open_url" : @"splashOpenURL",
                                                        @"open_url_list" : @"splashOpenUrlList",
                                                        @"splash_interval" : @"splashInterval",
                                                        @"leave_interval" : @"splashLeaveInterval",
                                                        @"type" : @"splashActionType",
                                                        @"wifi_only" : @"splashShowOnWifiOnly",
                                                        @"download_url" : @"splashDownloadURLStr",
                                                        @"app_name" : @"splashAppName",
                                                        @"alert_text" : @"splashAlertText",
                                                        @"appleid" : @"splashAppleID",
                                                        @"web_url" : @"splashWebURLStr",
                                                        @"web_url_list" : @"splashWebUrlList",
                                                        @"web_title" : @"splashWebTitle",

                                                        @"click_track_url_list" : @"splashClickTrackURLStrings",
                                                        @"track_url_list" : @"splashTrackURLStrings",
                                                        
                                                        @"banner_mode" : @"splashBannerMode",
                                                        @"image_info" : @"imageInfo",
                                                        @"url" : @"splashURLString",
                                                        @"landscape_image_info" : @"landscapeImageInfo",
                                                        @"interval_creative" : @"intervalCreatives",
                                                        
                                                        @"predownload" : @"predownload",
                                                        @"click_btn" : @"displayViewButton",
                                                        @"button_text" : @"buttonText",
                                                        @"skip_btn" : @"displaySkipButton",
                                                        @"repeat" : @"repeats",
                                                        @"app_open_url" : @"actionURL",
                                                       
                                                        @"splash_type"                        : @"splashADType",
                                                        @"video_info.video_id"                : @"videoId",
                                                        @"video_info.video_group_id"          : @"videoGroupId",
                                                        @"video_info.video_url_list"          : @"videoURLArray",
                                                        @"video_info.play_track_url_list"     : @"videoPlayTrackURLArray",
                                                        @"video_info.action_track_url_list"   : @"videoActionTrackURLArray",
                                                        @"video_info.playover_track_url_list" : @"videoPlayOverTrackURLArray",
                                                        @"video_info.video_density"           : @"video_density",
                                                        @"video_info.voice_switch"            : @"videoMute",
                                                        
                                                        ///__deprecated wait for hero
                                                        @"title" : @"splashActionTitle",
                                                        @"action" : @"splashActionURLStr",
                                                        @"hide_if_exists" : @"splashHideIfExist",
                                                        @"click_track_url" : @"splashClickTrackURLString",
                                                        @"track_url" : @"splashTrackURLStr",

                                                        @"area"         : @"areaUniqueKeyName",
                                                        @"type"         : @"areaType",
                                                        @"title"        : @"areaTitle",
                                                        @"wap_app_url"  : @"areaWapAppURL",
                                                        @"interval"     : @"areaInterval",
                                                        
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    NSSet *optional = [NSSet setWithObjects:@"splashID", nil];
    if ([optional containsObject:propertyName]) {
        return NO;
    }
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    //public
    [aCoder encodeInteger:_adModelType forKey:@"adModelType"];
    [aCoder encodeDouble:_requestTimeInterval forKey:@"requestTimeInterval"];
    [aCoder encodeObject:_splashID forKey:@"splashID"];
    [aCoder encodeObject:self.logExtra forKey:@"log_extra"];
    
    //splash
    [aCoder encodeInteger:self.commerceType forKey:@"commerceType"];
    [aCoder encodeDouble:_displayTime forKey:@"displayTime"];
    [aCoder encodeDouble:_maxDisplayTime forKey:@"maxDisplayTime"];
    [aCoder encodeInteger:_splashDisplayAfterSecond forKey:@"splashDisplayAfterSecond"];
    [aCoder encodeInteger:_splashExpireSeconds forKey:@"splashExpireSeconds"];
   
    [aCoder encodeObject:_splashOpenURL forKey:@"splashOpenURL"];
    [aCoder encodeObject:_splashOpenUrlList forKey:@"splashOpenUrlList"];
    [aCoder encodeInteger:_splashInterval forKey:@"splashInterval"];
    [aCoder encodeInteger:_splashLeaveInterval forKey:@"splashLeaveInterval"];
    [aCoder encodeObject:_splashActionType forKey:@"splashActionType"];
    [aCoder encodeObject:_splashShowOnWifiOnly forKey:@"splashShowOnWifiOnly"];
    [aCoder encodeObject:_splashDownloadURLStr forKey:@"splashDownloadURLStr"];
    [aCoder encodeObject:_splashAppName forKey:@"splashAppName"];
    [aCoder encodeObject:_splashAlertText forKey:@"splashAlertText"];
    [aCoder encodeObject:_splashAppleID forKey:@"splashAppleID"];
    [aCoder encodeObject:_splashWebURLStr forKey:@"splashWebURLStr"];
    [aCoder encodeObject:_splashWebUrlList forKey:@"splashWebUrlList"];
    [aCoder encodeObject:_splashWebTitle forKey:@"splashWebTitle"];
    
    [aCoder encodeObject:_splashTrackURLStrings forKey:@"splashTrackURLStrings"];
    [aCoder encodeObject:_splashClickTrackURLStrings forKey:@"splashClickTrackURLStrings"];
    
    [aCoder encodeObject:_imageInfo forKey:@"image_info"];
    [aCoder encodeObject:_landscapeImageInfo forKey:@"landscape_image_info"];
    [aCoder encodeObject:_splashURLString forKey:@"splashURLString"];
    [aCoder encodeObject:_display_density forKey:@"display_density"];
   
    [aCoder encodeObject:_splashBannerMode forKey:@"splashBannerMode"];
    [aCoder encodeObject:_intervalCreatives forKey:@"interval_creative"];
    
    [aCoder encodeObject:_predownload forKey:@"predownload"];
    [aCoder encodeObject:_displayViewButton forKey:@"click_btn"];
    [aCoder encodeObject:_buttonText forKey:@"button_text"];
    [aCoder encodeObject:_actionURL forKey:@"app_open_url"];
    [aCoder encodeObject:_displaySkipButton forKey:@"skip_btn"];
    
    [aCoder encodeObject:_repeats forKey:@"repeat"];
    
    // 开机视频广告
    [aCoder encodeInteger:_splashADType forKey:@"splashADType"];
    [aCoder encodeObject:_videoId forKey:@"videoId"];
    [aCoder encodeObject:_videoGroupId forKey:@"videoGroupId"];
    [aCoder encodeObject:_videoURLArray forKey:@"videoURLArray"];
    [aCoder encodeObject:_videoPlayTrackURLArray forKey:@"videoPlayTrackURLArray"];
    [aCoder encodeObject:_videoActionTrackURLArray forKey:@"videoActionTrackURLArray"];
    [aCoder encodeObject:_videoPlayOverTrackURLArray forKey:@"videoPlayOverTrackURLArray"];
    [aCoder encodeBool:_videoMute forKey:@"videoMute"];
    [aCoder encodeObject:_video_density forKey:@"video_density"];
    
    ///__deprecated wait for hero
    
    //area
    [aCoder encodeObject:_areaUniqueKeyName forKey:@"areaUniqueKeyName"];
    [aCoder encodeObject:_areaType forKey:@"areaType"];
    [aCoder encodeObject:_areaTitle forKey:@"areaTitle"];
    [aCoder encodeObject:_areaWapAppURL forKey:@"areaWapAppURL"];
    [aCoder encodeObject:_areaInterval forKey:@"areaInterval"];
    
    [aCoder encodeInteger:_splashImgHeight forKey:@"splashImgHeight"];
    [aCoder encodeInteger:_splashImgWidth forKey:@"splashImgWidth"];
    [aCoder encodeObject:_splashActionTitle forKey:@"splashActionTitle"];
    [aCoder encodeObject:_splashActionURLStr forKey:@"splashActionURLStr"];
    [aCoder encodeObject:_splashHideIfExist forKey:@"splashHideIfExist"];
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        //public
        self.adModelType = [aDecoder decodeIntegerForKey:@"adModelType"];
        self.requestTimeInterval = [aDecoder decodeDoubleForKey:@"requestTimeInterval"];
        self.splashID = [aDecoder decodeObjectForKey:@"splashID"];
        self.logExtra = [aDecoder decodeObjectForKey:@"log_extra"];
        
        //splash
        self.commerceType = [aDecoder decodeIntegerForKey:@"commerceType"];
        NSInteger splashDisplayTime = [aDecoder decodeIntegerForKey:@"splashDisplayTime"];
        self.displayTime = [aDecoder decodeDoubleForKey:@"displayTime"];
        // 如果原有的时间有效，并且现在没有displayTime，则使用原来的时间
        if (self.displayTime == 0 && splashDisplayTime > 0) {
            self.displayTime = splashDisplayTime;
        }
        self.maxDisplayTime = [aDecoder decodeDoubleForKey:@"maxDisplayTime"];
        if (self.maxDisplayTime < self.displayTime) {
            self.maxDisplayTime = self.displayTime;
        }
        self.splashDisplayAfterSecond = [aDecoder decodeIntegerForKey:@"splashDisplayAfterSecond"];
        self.splashExpireSeconds = [aDecoder decodeIntegerForKey:@"splashExpireSeconds"];
       
        self.splashOpenURL = [aDecoder decodeObjectForKey:@"splashOpenURL"];
        self.splashOpenUrlList = [aDecoder decodeObjectForKey:@"splashOpenUrlList"];
        self.splashInterval = [aDecoder decodeIntegerForKey:@"splashInterval"];
        self.splashLeaveInterval = [aDecoder decodeIntegerForKey:@"splashLeaveInterval"];
        self.splashTrackURLStrings = [aDecoder decodeObjectForKey:@"splashTrackURLStrings"];
        if (!self.splashTrackURLStrings) {
            id splashTrackURLStr = [aDecoder decodeObjectForKey:@"splashTrackURLStr"];
            if ([splashTrackURLStr isKindOfClass:[NSString class]]) {
                self.splashTrackURLStrings = @[splashTrackURLStr];
            }
        }
        self.splashActionType = [aDecoder decodeObjectForKey:@"splashActionType"];
        self.splashShowOnWifiOnly = [aDecoder decodeObjectForKey:@"splashShowOnWifiOnly"];
        self.splashDownloadURLStr = [aDecoder decodeObjectForKey:@"splashDownloadURLStr"];
        self.splashAppName = [aDecoder decodeObjectForKey:@"splashAppName"];
        self.splashAlertText = [aDecoder decodeObjectForKey:@"splashAlertText"];
        self.splashAppleID = [aDecoder decodeObjectForKey:@"splashAppleID"];
        self.splashWebURLStr = [aDecoder decodeObjectForKey:@"splashWebURLStr"];
        self.splashWebUrlList = [aDecoder decodeObjectForKey:@"splashWebUrlList"];
        self.splashWebTitle = [aDecoder decodeObjectForKey:@"splashWebTitle"];
        
        self.imageInfo = [aDecoder decodeObjectForKey:@"image_info"];
        self.landscapeImageInfo = [aDecoder decodeObjectForKey:@"landscape_image_info"];
        self.splashURLString = [aDecoder decodeObjectForKey:@"splashURLString"];
        self.display_density = [aDecoder decodeObjectForKey:@"display_density"];
        
        self.intervalCreatives = [aDecoder decodeObjectForKey:@"interval_creative"];
        
        self.splashClickTrackURLStrings = [aDecoder decodeObjectForKey:@"splashClickTrackURLStrings"];
        if (!self.splashClickTrackURLStrings) {
            id splashClickTrackURLString = [aDecoder decodeObjectForKey:@"splashClickTrackURLString"];
            if ([splashClickTrackURLString isKindOfClass:[NSString class]]) {
                self.splashClickTrackURLStrings = @[splashClickTrackURLString];
            }
        }
        
        self.splashBannerMode = [aDecoder decodeObjectForKey:@"splashBannerMode"];
       
        id value = [aDecoder decodeObjectForKey:@"predownload"];
        
        if (value) {
            self.predownload = value;
        } else {
            // 和Android一致，如果取不到值，则只允许wifi下载
            self.predownload = @(TTNetworkFlagWifi);
        }
        
        id repeatValue = [aDecoder decodeObjectForKey:@"repeat"];
        if (repeatValue) {
            self.repeats = @([repeatValue boolValue]);
        } else {
            self.repeats = @(NO);
        }
        
        /// 这个值 默认是YES
        id displaySkipValue = [aDecoder decodeObjectForKey:@"skip_btn"];
        if (displaySkipValue) {
            self.displaySkipButton = @([displaySkipValue boolValue]);
        } else {
            self.displaySkipButton = @YES;
        }
        
        // 0不显示按钮，1显示新样式，2显示旧样式，默认为1。
        id displayClickValue = [aDecoder decodeObjectForKey:@"click_btn"];
        if (displayClickValue) {
            self.displayViewButton = @([displayClickValue intValue]);
        } else {
            self.displayViewButton = @(1);
        }
        self.buttonText = [aDecoder decodeObjectForKey:@"button_text"];
        self.actionURL = [aDecoder decodeObjectForKey:@"app_open_url"];
        
        // 开机视频广告
        _splashADType = [aDecoder decodeIntegerForKey:@"splashADType"];
        _videoId = [aDecoder decodeObjectForKey:@"videoId"];
        _videoGroupId = [aDecoder decodeObjectForKey:@"videoGroupId"];
        _videoURLArray = [aDecoder decodeObjectForKey:@"videoURLArray"];
        _videoPlayTrackURLArray = [aDecoder decodeObjectForKey:@"videoPlayTrackURLArray"];
        _videoActionTrackURLArray = [aDecoder decodeObjectForKey:@"videoActionTrackURLArray"];
        _videoPlayOverTrackURLArray = [aDecoder decodeObjectForKey:@"videoPlayOverTrackURLArray"];
        _videoMute = [aDecoder decodeBoolForKey:@"videoMute"];
        _video_density = [aDecoder decodeObjectForKey:@"video_density"];
        
        ///__deprecated wait for hero
        //area
        self.areaUniqueKeyName = [aDecoder decodeObjectForKey:@"areaUniqueKeyName"];
        self.areaType = [aDecoder decodeObjectForKey:@"areaType"];
        self.areaTitle = [aDecoder decodeObjectForKey:@"areaTitle"];
        self.areaWapAppURL = [aDecoder decodeObjectForKey:@"areaWapAppURL"];
        self.areaInterval = [aDecoder decodeObjectForKey:@"areaInterval"];
                
        self.splashActionTitle = [aDecoder decodeObjectForKey:@"splashActionTitle"];
        self.splashActionURLStr = [aDecoder decodeObjectForKey:@"splashActionURLStr"];
        self.splashHideIfExist = [aDecoder decodeObjectForKey:@"splashHideIfExist"];
        self.splashImgHeight = [aDecoder decodeIntegerForKey:@"splashImgHeight"];
        self.splashImgWidth = [aDecoder decodeIntegerForKey:@"splashImgWidth"];
    }
    return self;
}

@end

@implementation SSADModel (TTAdMedia)

- (CGSize)imageSize {
    return stringToSize(self.display_density);
}

- (CGSize)videoSize {
    return stringToSize(self.video_density);
}

@end
