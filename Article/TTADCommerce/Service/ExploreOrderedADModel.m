//
//  ExploreOrderedADModel.m
//  Article
//
//  Created by SunJiangting on 14-11-26.
//
//

#import "ExploreOrderedADModel.h"

#import "NSDictionary+TTAdditions.h"
#import "TTBaseMacro.h"
#import "TTRoute.h"

//图片Model在详情大图数组，小图数组，列表大图数组的顺序key
#define kArticleImgsIndexKey    @"kArticleImgsIndexKey"


@implementation ExploreOrderedADModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (dictionary[@"id"]) {
            self.ad_id = [NSString stringWithFormat:@"%@", dictionary[@"id"]];
        }
        if (dictionary[@"ad_id"] && self.ad_id == nil) {
            self.ad_id = [NSString stringWithFormat:@"%@", dictionary[@"ad_id"]];
        }
        
        self.log_extra = [dictionary tt_stringValueForKey:@"log_extra"];
        
        self.descInfo = [dictionary valueForKey:@"description"];

        self.type = [dictionary valueForKey:@"type"];
        
        NSString *buttonText = dictionary[@"btn_text"];
        if (buttonText == nil && dictionary[@"button_text"] ) {
            buttonText = dictionary[@"button_text"];
        }
        self.button_text = buttonText;
        
        id trackURLValue = [dictionary valueForKey:@"click_track_url"];
        if ([trackURLValue isKindOfClass:[NSString class]]) {
            self.track_url_list = @[trackURLValue];
        } else if ([trackURLValue isKindOfClass:[NSArray class]]) {
            self.track_url_list = trackURLValue;
        }
        
        NSDictionary *imageInfo = [dictionary valueForKey:@"image"];
        if ([imageInfo isKindOfClass:[NSDictionary class]]) {
            self.imageInfo = imageInfo;
            self.imageModel = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
        }
        
        self.displayType = [dictionary tt_longlongValueForKey:@"display_type"];
       
        self.open_url = [dictionary tt_stringValueForKey:@"open_url"];
        
        self.title = [dictionary tt_stringValueForKey:@"title"];
        self.source = [dictionary tt_stringValueForKey:@"source"];
       
        self.webURL = [dictionary tt_stringValueForKey:@"web_url"];
        self.webTitle = [dictionary tt_stringValueForKey:@"web_title"];
        
       
        self.appName = [dictionary tt_stringValueForKey:@"app_name"];
        self.apple_id = [dictionary tt_stringValueForKey:@"appleid"];
        self.download_url = [dictionary tt_stringValueForKey:@"download_url"];
        self.ipa_url = [dictionary tt_stringValueForKey:@"ipa_url"];
        
        self.hideIfExists = dictionary[@"hide_if_exists"];
        self.ui_type = dictionary[@"ui_type"];
        
        // new style ads
        if ([dictionary valueForKey:@"display_info"]) {
            self.displayInfo = [dictionary tt_stringValueForKey:@"display_info"];
        }
        self.form_url = [dictionary tt_stringValueForKey:@"form_url"];
        self.form_width = @([dictionary tt_integerValueForKey:@"form_width"]);
        self.form_height = @([dictionary tt_integerValueForKey:@"form_height"]);
        self.use_size_validation = @([dictionary tt_boolValueForKey:@"use_size_validation"]);
        
        self.phoneNumber = [dictionary valueForKey:@"phone_number"];
        self.dialActionType = @([dictionary tt_intValueForKey:@"dial_action_type"]);
    
        if ([dictionary objectForKey:@"location_url"]) {
            self.location_url = [dictionary tt_stringValueForKey:@"location_url"];
        }
        
        if ([dictionary objectForKey:@"location_data"]) {
            NSDictionary *locationDictionary = [dictionary tt_dictionaryValueForKey:@"location_data"];
            self.location_data = locationDictionary;
        }
    }
    return self;
}

- (ExploreActionType)adType {
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

- (NSString *)actionButtonTitle {
    if (!isEmptyString(self.button_text)) {
        return self.button_text;
    }
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
            } break;
            
        case ExploreActionTypeWeb: {
            return NSLocalizedString(@"查看详情", @"查看详情");
        } break;
            
        case ExploreActionTypeLocationcounsel:
        case ExploreActionTypeCounsel: {
            return NSLocalizedString(@"在线咨询", @"在线咨询");
        } break;
            
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

- (NSDictionary *)mointerInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
    info[@"ad_id"] = [NSString stringWithFormat:@"%@", self.ad_id ];
    info[@"log_extra"] = self.log_extra;
    return info;
}

- (NSString *)locationStreet {
    return self.location_data[@"district"];
}

- (NSString *)locationDisdance {
    return self.location_data[@"street"];
}

- (NSString *)locationDistrict {
    return self.location_data[@"distance"];
}

- (BOOL)isCreativeAd {
    return YES;
}

- (BOOL)showActionButton {
    return YES;
}

@end
