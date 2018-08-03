//
//  SSTipModel.m
//  Article
//
//  Created by Yu Tianhang on 12-12-23.
//
//

#import "SSTipModel.h"

#import "TTBaseMacro.h"
#import "TTRoute.h"
#import "TTStringHelper.h"
#import "TTTrackerWrapper.h"
#import "TTURLTracker.h"

#define kSeperatorString @"://"

@implementation SSTipModel

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        self.displayTemplate = [data tt_stringValueForKey:@"display_template"];
        self.displayInfo = [data tt_stringValueForKey:@"display_info"];
        self.displayDuration = [data objectForKey:@"display_duration"];
        
        self.openURL = [data tt_stringValueForKey:@"open_url"];
        self.webURL = [data tt_stringValueForKey:@"web_url"];
        
        self.appleID = [data tt_stringValueForKey:@"appleid"];
        self.appName = [data tt_stringValueForKey:@"app_name"];
        self.downloadURL = [data tt_stringValueForKey:@"download_url"];
        
        self.type = data[@"type"];
        self.logExtra = [data tt_stringValueForKey:@"log_extra"];
        self.adID = [data objectForKey:@"ad_id"];
        if ([data objectForKey:@"track_url_list"]) {
            self.trackURLs = [data tt_arrayValueForKey:@"track_url_list"];
        } else if (data[@"track_url"]) {
            self.trackURLs = @[data[@"track_url"]];
        }
    }
    return self;
}

- (instancetype)initWithTips:(TTVRefreshTips *)tips
{
    self = [super init];
    if (self) {
        self.type = tips.type;
        self.displayInfo = tips.displayInfo;
        self.displayDuration = @(tips.displayDuration);
        self.openURL = tips.openURL;
        self.webURL = tips.webURL;
        self.appName = tips.appName;
        self.downloadURL = tips.downloadURL;
        self.displayTemplate = tips.displayTemplate;
    }
    return self;
}

- (void)sendTrackEventWithLabel:(NSString *)label {
    if (isEmptyString(label)) {
        return;
    }

    NSString *eventName = @"notify";
    if (_adID) {
        NSMutableDictionary *events =  @{}.mutableCopy;
        events[@"category"] = @"umeng";
        events[@"tag"] = eventName;
        events[@"label"] = label;
        events[@"value"] = _adID;
        events[@"log_extra"] = self.logExtra;
        events[@"is_ad_event"] = @"1";
        [TTTrackerWrapper eventData:events];
        
        TTURLTrackerModel *trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self.adID stringValue] logExtra:self.logExtra];
        
        if (!SSIsEmptyArray(self.trackURLs)) {
            ttTrackURLsModel(self.trackURLs, trackModel);
        }
    } else {
        wrapperTrackEventWithOption([TTSandBoxHelper appName], eventName, label, false);
    }
}

- (NSString *)v3EnterFrom:(NSString *)categoryName
{
    if ([categoryName isEqualToString:@"__all__"]) {
        return @"click_headline";
    } else {
        return @"click_category";
    }
}

- (void)sendV3TrackWithLabel:(NSString *)label params:(NSDictionary *)extra {
    NSParameterAssert(label != nil);
    if (label == nil || self.openURL == nil) {
        return;
    }
    
    NSMutableDictionary *queryKeyValues = @{}.mutableCopy;
    NSURL *openURL = [NSURL URLWithString:self.openURL];
    NSArray *urlComponents = [openURL.query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        if (pairComponents.count != 2) {
            continue;
        }
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        if (key == nil) {
            continue;
        }
        queryKeyValues[key] = value;
    }
    
    if (![openURL.host isEqualToString:@"category_feed"]) {
        return;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"enter_from"] = [self v3EnterFrom:extra[@"category_name"]];
    params[@"tab_name"] = @"stream";
    params[@"position"] = @"list_top_bar";
    params[@"to_category_name"] = queryKeyValues[@"category"];
    if (extra.count > 0) {
        [params addEntriesFromDictionary:extra];
    }
    [TTTracker eventV3:label params:params];
}

@end
