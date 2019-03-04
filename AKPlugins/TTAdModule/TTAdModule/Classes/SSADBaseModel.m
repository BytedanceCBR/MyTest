//
//  SSADBaseModel.m
//  Article
//
//  Created by Zhang Leonardo on 14-2-20.
//
//

#import "SSADBaseModel.h"

#import "NSDictionary+TTAdditions.h"
#import "NSString-Extension.h"
#import "TTURLTracker.h"
#import <TTTracker/TTTrackerProxy.h>
#import <TTTracker/TTTracker.h>

#define kPlayerOverTrackUrlList @"playover_track_url_list"
#define kPlayerEffectiveTrackUrlList @"effective_play_track_url_list"
#define kPlayerActiveTrackUrlList @"active_play_track_url_list"
#define kPlayerTrackUrlList @"play_track_url_list"
#define kShowTrackUrlList @"track_url_list"
#define kEffectivePlayTime @"effective_play_time"

#define kSeperatorString @"://"

@implementation SSADBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        
        NSString *typeString = [data objectForKey:@"type"];
        self.type = [data tt_stringValueForKey:@"type"];
        SSADModelActionType type = SSADModelActionTypeApp;
        if ([typeString isEqualToString:@"web"]) {
            type = SSADModelActionTypeWeb;
        }
        else if ([typeString isEqualToString:@"form"])
        {
            type = SSADModelActionTypeAppoint;
        }
        self.actionType = type;

        if ([data.allKeys containsObject:@"id"]) {
            self.ad_id = [data tt_stringValueForKey:@"id"];
        }
        else if([data objectForKey:@"ad_id"])
        {
            self.ad_id = [data tt_stringValueForKey:@"ad_id"];
        }

        id click_track_urls = [data valueForKey:@"click_track_url_list"];

        if ([click_track_urls isKindOfClass:[NSArray class]]) {
            self.click_track_urls = click_track_urls;
        } else {
            id click_track_url = [data valueForKey:@"click_track_url"];
            if ([click_track_urls isKindOfClass:[NSArray class]]) {
                self.click_track_urls = click_track_url;
            } else if ([click_track_url isKindOfClass:[NSString class]]) {
                self.click_track_urls = @[click_track_url];
            }
        }
        
        id track_urls = [data valueForKey:kShowTrackUrlList];
        if (!track_urls) {
            track_urls = [data valueForKey:@"track_url_list"];
        }
        if ([track_urls isKindOfClass:[NSArray class]]) {
            self.track_urls = track_urls;
        } else {
            id track_url = [data valueForKey:@"track_url"];
            if ([track_url isKindOfClass:[NSArray class]]) {
                self.track_urls = track_url;
            } else if ([track_url isKindOfClass:[NSString class]]) {
                self.track_urls = @[track_url];
            }
        }

        if ([[data valueForKey:kPlayerTrackUrlList] isKindOfClass:[NSArray class]]) {
            self.adPlayTrackUrls = data[kPlayerTrackUrlList];
        }
        if ([[data valueForKey:kPlayerActiveTrackUrlList] isKindOfClass:[NSArray class]]) {
            self.adPlayActiveTrackUrls = data[kPlayerActiveTrackUrlList];
        }
        if ([[data valueForKey:kPlayerEffectiveTrackUrlList] isKindOfClass:[NSArray class]]) {
            self.adPlayEffectiveTrackUrls = data[kPlayerEffectiveTrackUrlList];
        }
        if ([[data valueForKey:kPlayerOverTrackUrlList] isKindOfClass:[NSArray class]]) {
            self.adPlayOverTrackUrls = data[kPlayerOverTrackUrlList];
        }
        if ([data valueForKey:kEffectivePlayTime]) {
            self.effectivePlayTime = [data[kEffectivePlayTime] floatValue];
        }
        
        self.webURL = [data objectForKey:@"web_url"];
        self.webTitle = [data objectForKey:@"web_title"];
        
        self.open_url = [data objectForKey:@"open_url"];
        NSRange seperateRange = [self.open_url rangeOfString:kSeperatorString];
        if (seperateRange.length > 0) {
            self.appUrl = [self.open_url substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
            self.tabUrl = [self.open_url substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.open_url length] - NSMaxRange(seperateRange))];
        }
        else {
            self.appUrl = self.open_url;
        }

        if ([data.allKeys containsObject:@"alert_text"]) {
            self.alertText = [data objectForKey:@"alert_text"];
        }
        else {
            self.alertText = nil;
        }
        
        if ([data.allKeys containsObject:@"appleid"]) {
            self.apple_id = [NSString stringWithFormat:@"%@", [data objectForKey:@"appleid"]];
        }

        if ([data.allKeys containsObject:@"download_url"]) {
            self.download_url = [data objectForKey:@"download_url"];
        }

        if ([data.allKeys containsObject:@"app_name"]) {
            self.appName = [data objectForKey:@"app_name"];
        }
        
        if ([data.allKeys containsObject:@"ipa_url"]) {
            self.ipa_url = [data objectForKey:@"ipa_url"];
        }
                
        self.source = [data objectForKey:@"source"];
        self.log_extra = [data objectForKey:@"log_extra"];
    }
    return self;
}

- (NSString *)webURL {
    NSString *webURL = _webURL;
    if (webURL.length > 0 && [self.ad_id longLongValue] > 0 && self.log_extra != nil) {
        webURL = [webURL tt_adChangeUrlWithLogExtra:self.log_extra];
    }
    return webURL;
}

- (NSString *)open_url {
    NSString *openURL = _open_url;
    if (openURL.length > 0 && [self.ad_id longLongValue] > 0 && self.log_extra != nil) {
        openURL = [openURL tt_adChangeUrlWithLogExtra:self.log_extra];
    }
    return openURL;
}

@end

@implementation SSADBaseModel (TTAdMonitor)

- (NSDictionary *)monitorInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:3];
    info[@"ad_id"] = [NSString stringWithFormat:@"%@", self.ad_id ];
    info[@"log_extra"] = self.log_extra;
    return info;
}

@end

@implementation SSADBaseModel (TTAdNatantTracker)

- (void)sendTrackEventWithLabel:(NSString *)label eventName:(NSString *)eventName {
    [self sendTrackEventWithLabel:label eventName:eventName extra:nil];
}

- (void)sendTrackEventWithLabel:(NSString *)label eventName:(NSString *)eventName extra:(NSDictionary *)extra{
    NSCParameterAssert(label != nil);
    NSCParameterAssert(eventName != nil);
    
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.ad_id logExtra:self.log_extra];
    if ([self.click_track_urls isKindOfClass:[NSArray class]] && ([label isEqualToString:@"click"])) {
        ttTrackURLsModel(self.click_track_urls, trackModel);
    }
    
    if ([self.track_urls isKindOfClass:[NSArray class]] && ([label isEqualToString:@"show"])) {
        ttTrackURLsModel(self.track_urls, trackModel);
    }
    
    if (self.ad_id) {
        TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
        NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
        [events setValue:@"umeng" forKey:@"category"];
        [events setValue:eventName forKey:@"tag"];
        [events setValue:label forKey:@"label"];
        [events setValue:@(nt) forKey:@"nt"];
        [events setValue:@"1" forKey:@"is_ad_event"];
        [events setValue:self.ad_id forKey:@"value"];
        [events setValue:self.log_extra forKey:@"log_extra"];
        [events addEntriesFromDictionary:extra];
        [TTTracker eventData:events];
    }
}

@end
