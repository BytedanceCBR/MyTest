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

static NSString *const TrackEventPageShow = @"go_detail";
static NSString *const TrackEventTabIndexChange = @"go_detail";
static NSString *const TrackEventSuggestionResultShow = @"sug_word_show";

static NSString *const TrackKeyTabName = @"tab_name";
static NSString *const TrackKeySuggestionResultCount = @"result_num";
static NSString *const TrackKeySuggestionWord = @"word";
static NSString *const TrackKeySuggestionResultTags = @"tags";

@implementation FHSuggestionListViewController(FHTracker)

static const char tabSwitchedKey;
- (void)setTabSwitched:(BOOL)tabSwitched {
    objc_setAssociatedObject(self, &tabSwitchedKey, @(tabSwitchedKey), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tabSwitched {
    return [objc_getAssociatedObject(self, &tabSwitchedKey) boolValue];
}

- (void)trackPageShow {
    NSDictionary *parameters = @{
        UT_ORIGIN_FROM: [self fh_originFrom],
        UT_ENTER_FROM: [self fh_fromPageType],
        UT_PAGE_TYPE: [self fh_pageType],
        TrackKeyTabName: [self trackTabName]
    };
    TRACK_EVENT(TrackEventPageShow, parameters);
}

- (void)trackTabIndexChange {
    self.tabSwitched = YES;
    NSDictionary *parameters = @{
        UT_ORIGIN_FROM: [self fh_originFrom],
        UT_ENTER_FROM: [self fh_pageType],
        UT_PAGE_TYPE: [self fh_pageType],
        TrackKeyTabName: [self trackTabName]
    };
    TRACK_EVENT(TrackEventPageShow, parameters);
}

- (void)trackSuggestionWithWord:(NSString *)word houseType:(NSInteger)houseType result:(FHSuggestionResponseModel *)result {
    if (self.houseType != houseType || !word || !word.length) return;
    NSDictionary *parameters = @{
        UT_ORIGIN_FROM: [self fh_originFrom],
        UT_ENTER_FROM: self.tabSwitched ? [self fh_pageType] : [self fh_fromPageType],
        UT_PAGE_TYPE: [self fh_pageType],
        TrackKeyTabName: [self trackTabName],
        TrackKeySuggestionResultCount: @(result.data.count),
        TrackKeySuggestionWord: word,
        TrackKeySuggestionResultTags: [self resultTagsString:result]
    };
    TRACK_EVENT(TrackEventSuggestionResultShow, parameters);
}

//{小区|牡丹园,小区|牡丹园中兴大厦,地铁|牡丹园站}
- (NSString *)resultTagsString:(FHSuggestionResponseModel *)result {
    NSMutableString *tagStr = [NSMutableString string];
    [tagStr appendString:@"{"];
    BOOL firstTag = YES;
    for (FHSuggestionResponseDataModel *item in result.data) {
        if (!firstTag) {
            [tagStr appendFormat:@","];
        }
        
        firstTag = NO;
        NSString *name = item.name;
        if (!name || !name.length) name = item.text;
        if (!name || !name.length) continue;;
        
        if (item.recallType && item.recallType.length) {
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
@end
