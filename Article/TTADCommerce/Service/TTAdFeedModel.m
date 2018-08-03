//
//  TTAdModel.m
//  Article
//
//  Created by carl on 2017/7/10.
//
//

#import "TTAdFeedModel.h"
#import "TTRoute.h"

@implementation TTAdFeedModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *mapper = @{
                             @"id" : @"ad_id",
                             @"hide_if_exists" : @"hideIfExists",
                             @"display_type" : @"displayType",
                             
                             @"web_title" : @"webTitle",
                             @"web_url" : @"webURL",
                             
                             @"app_name" : @"appName",
                             @"appleid" : @"apple_id",
                             
                             @"dial_action_type" : @"dialActionType",
                             @"phone_number" : @"phoneNumber",
                             
                             @"effective_play_time" : @"effectivePlayTime",
                             @"play_track_url_list" : @"playTrackUrls",
                             @"active_play_track_url_list" : @"activePlayTrackUrls",
                             @"effective_play_track_url_list" : @"effectivePlayTrackUrls",
                             @"playover_track_url_list" : @"playOverTrackUrls"
                             };
    return [[JSONKeyMapper alloc] initWithDictionary:mapper];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    NSSet *requiredProperty = nil;
    if ([SSCommonLogic isRawAdDataEnable]) {
        requiredProperty = [[NSSet alloc] initWithObjects:@"ad_id", @"log_extra", nil];
    }
    if ([requiredProperty containsObject:propertyName]) {
        return NO;
    }
    return YES;
}

- (BOOL)isCanvasStyle {
    return [self.style isEqualToString:@"canvas"];
}

- (BOOL)isFullScreenVideoStyle {
    return [self.style isEqualToString:@"full_video"];
}

- (ExploreActionType) adType {
    if ([self.type isEqualToString:@"web"]) {
        return ExploreActionTypeWeb;
    } else if ([self.type isEqualToString:@"action"]) {
        return ExploreActionTypeAction;
    } else if ([self.type isEqualToString:@"form"]) {
        return ExploreActionTypeForm;
    } else if ([self.type isEqualToString:@"counsel"]) {
        return ExploreActionTypeCounsel;
    } else if ([self.type isEqualToString:@"location_action"]) {
        return ExploreActionTypeLocationAction;
    } else if ([self.type isEqualToString:@"location_form"]) {
        return ExploreActionTypeLocationForm;
    } else if ([self.type isEqualToString:@"location_counsel"]) {
        return ExploreActionTypeLocationcounsel;
    } else if ([self.type isEqualToString:@"discount"]) {
        return ExploreActionTypeDiscount;
    } else if ([self.type isEqualToString:@"coupon"]) {
        return ExploreActionTypeCoupon;
    }
    return ExploreActionTypeApp;
}

- (NSString *)actionButtonTitle {
    if (!isEmptyString(self.button_text)) {
        return self.button_text;
    } else {
        switch (self.adType) {
            case ExploreActionTypeApp: {
                BOOL appInstalled = (!isEmptyString(self.open_url) && [[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:self.open_url]]) ||
                [TTRoute conformsToRouteWithScheme:self.appUrl];
                if (appInstalled) {
                    return NSLocalizedString(@"立即打开", @"立即打开");
                } else {
                    if ([TTDeviceHelper isJailBroken] && !isEmptyString(self.ipa_url)) {
                        return NSLocalizedString(@"越狱下载", @"越狱下载");
                    }
                    else {
                        return NSLocalizedString(@"立即下载", @"立即下载");
                    }
                }
            }
                break;
            case ExploreActionTypeWeb: {
                return NSLocalizedString(@"查看详情", @"查看详情");
            }
                break;
            case ExploreActionTypeLocationcounsel:
            case ExploreActionTypeCounsel: {
                return NSLocalizedString(@"在线咨询", @"在线咨询");
                break;
            }
            case ExploreActionTypeLocationAction:
            case ExploreActionTypeAction: {
                return NSLocalizedString(@"拨打电话", @"拨打电话");
            } break;
            case ExploreActionTypeDiscount:
            case ExploreActionTypeCoupon: {
                return NSLocalizedString(@"领取优惠", @"领取优惠");
            } break;
            default:
                break;
        }
    }
    return nil;
}

- (BOOL)showActionButtonIcon {
    
    ExploreActionType actionType = self.adType;
    if (actionType != ExploreActionTypeApp &&
        actionType != ExploreActionTypeAction &&
        actionType != ExploreActionTypeCounsel &&
        actionType != ExploreActionTypeLocationAction &&
        actionType != ExploreActionTypeLocationcounsel &&
        actionType != ExploreActionTypeDiscount &&
        actionType != ExploreActionTypeCoupon) {
        return NO;
    }
    
    TTAdFeedCellDisplayType displayType = self.displayType;
    if (displayType != TTAdFeedCellDisplayTypeRight && displayType != TTAdFeedCellDisplayTypeGroup) {
        return NO;
    }
    return YES;
}

- (NSString *)appUrl {
    if (!isEmptyString(_appUrl)) {
        return _appUrl;
    }
    NSRange seperateRange = [self.open_url rangeOfString:kSeperatorString];
    if (seperateRange.length > 0) {
        _appUrl = [self.open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
    } else {
        _appUrl = self.open_url;
    }
    return _appUrl;
}

- (NSString *)tabUrl {
    if (!isEmptyString(_tabUrl)) {
        return _tabUrl;
    }
    NSRange seperateRange = [self.open_url rangeOfString:kSeperatorString];
    if (seperateRange.length > 0) {
        _tabUrl = [self.open_url substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.open_url length] - NSMaxRange(seperateRange))];
    }
    return _tabUrl;
}

- (NSDictionary *)mointerInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
    info[@"ad_id"] = [NSString stringWithFormat:@"%@", self.ad_id ];
    info[@"log_extra"] = self.log_extra;
    return info;
}

- (NSString *)locationStreet {
    return self.location_data[@"street"];
}

- (NSString *)locationDisdance {
    return self.location_data[@"distance"];
}

- (NSString *)locationDistrict {
    return self.location_data[@"district"];
}

- (NSString *)descInfo {
    return self.title;
}

- (BOOL)isCreativeAd {
    if (self.system_origin || self.type == nil) {
        return NO;
    }
    return YES;
}

- (BOOL)showActionButton {
    if (self.button_style)
        return YES;
    if (self.type != nil && ![self.type isEqualToString:@"web"]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasLocationInfo
{
    if (!isEmptyString(self.sub_style)) {
        return self.sub_style.integerValue == 1;
    }
    return NO;
}

@end

@implementation TTAdFeedLbsModel

@end

