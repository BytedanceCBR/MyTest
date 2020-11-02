//
//  FHSuggestionListViewController+FHTracker.m
//  FHHouseBase
//
//  Created by bytedance on 2020/10/13.
//

#import "FHSuggestionListViewController+FHTracker.h"
#import "FHUserTracker.h"
#import "FHSuggestionListModel.h"
#import <objc/runtime.h>
#import <ByteDanceKit/ByteDanceKit.h>

static NSString *const TrackEventPageShow = @"go_detail";
static NSString *const TrackEventSuggestionResultShow = @"sug_word_show";

static NSString *const TrackKeyTabName = @"tab_name";
static NSString *const TrackKeySuggestionResultCount = @"result_num";
static NSString *const TrackKeySuggestionWord = @"word";
static NSString *const TrackKeySuggestionResultTags = @"tags";

static NSString *const TrackValuePageShowTrackingID = @"113200";
static NSString *const TrackValueSuggestionResultShowTrackingID = @"113201";

@implementation FHSuggestionListViewController(FHTracker)

static const char tabSwitchedKey;
- (void)setTabSwitched:(BOOL)tabSwitched {
    objc_setAssociatedObject(self, &tabSwitchedKey, @(tabSwitched), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tabSwitched {
    return [objc_getAssociatedObject(self, &tabSwitchedKey) boolValue];
}

- (void)trackPageShow {
    NSDictionary *parameters = @{
        UT_ORIGIN_FROM: [self fh_originFrom],
        UT_ENTER_FROM:  self.tabSwitched ? [self fh_pageType] : [self fh_fromPageType],
        UT_PAGE_TYPE: [self fh_pageType],
        TrackKeyTabName: [self trackTabName],
        UT_EVENT_TRACKING_ID: TrackValuePageShowTrackingID,
    };
    TRACK_EVENT(TrackEventPageShow, parameters);
}

- (void)trackTabIndexChange {
    self.tabSwitched = YES;
    [self trackPageShow];
}

- (void)trackSuggestionWithWord:(NSString *)word houseType:(NSInteger)houseType result:(FHSuggestionResponseModel *)result {
    if (self.houseType != houseType || !word || !word.length) return;
    
    NSString *tagsStr = @"{}";
    NSInteger count = result.data.items.count;
    if (count) {
        NSArray *filteredResultArray = [result.data.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            if (![object isKindOfClass:FHSuggestionResponseitemModel.class]) return NO;
            FHSuggestionResponseitemModel *item = (FHSuggestionResponseitemModel *)object;
            return item.cardType == 16;
        }]];
        
        count = filteredResultArray.count;
        tagsStr = [self resultTagsString:filteredResultArray houseType:houseType];
    }
    
    NSDictionary *parameters = @{
        UT_ORIGIN_FROM: [self fh_originFrom],
        UT_ENTER_FROM: self.tabSwitched ? [self fh_pageType] : [self fh_fromPageType],
        UT_PAGE_TYPE: [self fh_pageType],
        TrackKeyTabName: [self trackTabName],
        TrackKeySuggestionResultCount: @(count),
        TrackKeySuggestionWord: word,
        TrackKeySuggestionResultTags: tagsStr,
        UT_EVENT_TRACKING_ID: TrackValueSuggestionResultShowTrackingID,
    };
    TRACK_EVENT(TrackEventSuggestionResultShow, parameters);
}

//{小区|牡丹园,小区|牡丹园中兴大厦,地铁|牡丹园站}
- (NSString *)resultTagsString:(NSArray *)resultArray houseType:(NSInteger)houseType {
    NSMutableString *tagStr = [NSMutableString string];
    [tagStr appendString:@"{"];
    BOOL firstTag = YES;
    for (FHSuggestionResponseitemModel *item in resultArray) {
        if (!firstTag) {
            [tagStr appendFormat:@","];
        }
        
        NSString *name = item.name;
        if (!name || !name.length) name = item.text;
        if (!name || !name.length) continue;;
        
        firstTag = NO;
        if (item.recallType && item.recallType.length && houseType == FHHouseTypeSecondHandHouse) {
            [tagStr appendFormat:@"%@|%@", item.recallType, name];
        } else {
            [tagStr appendFormat:@"%@", name];
        }
    }
    [tagStr appendString:@"}"];
    return tagStr;
}

//{"old":"默认二手房","new":"新房","renting":"租房","neighborhood":"小区"}
- (NSString *)trackTabName {
    NSString *tab_name = @"be_null";
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            tab_name = @"new";
            break;
        case FHHouseTypeSecondHandHouse:
            tab_name = @"old";
            break;
        case FHHouseTypeRentHouse:
            tab_name = @"renting";
            break;
        case FHHouseTypeNeighborhood:
            tab_name = @"neighborhood";
            break;
        default:
            break;
    }
    
    return tab_name;
}

- (NSString *)fh_pageType {
    return @"search_detail";
}

- (NSString *)fh_fromPageType {
    if (!self.tracerDict || ![self.tracerDict isKindOfClass:NSDictionary.class]) return @"be_null";
    return [self.tracerDict btd_objectForKey:UT_FROM_PAGE_TYPE default:@"be_null"];
}
@end
