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

- (void)trackSugWordClickWithmodel:(FHSuggestionResponseItemModel *)model eventName:(nonnull NSString *)eventName{
    NSMutableDictionary *parameters =  [NSMutableDictionary dictionaryWithDictionary:self.sugWordShowtracerDic];
    parameters[@"rank"] = @(model.rank) ?: 0;
    [parameters btd_objectForKey:model.logPb default:@"be_null"];
    parameters[@"word_text"] = [model.houseType intValue] == FHHouseTypeNewHouse? model.text:model.name;
    parameters[@"group_id"] = model.info.qrecid ?: @"be_null";
    parameters[@"element_type"] = @"search";
    parameters[@"recall_type"] = model.recallType ?: @"be_null";
    if([eventName isEqualToString:@"search_detail_show"]){
        [parameters removeObjectForKey:@"result_num"];
        [parameters removeObjectForKey:@"differ_result_num"];
        [parameters removeObjectForKey:@"rank"];
    }
    TRACK_EVENT(eventName, parameters);
}

- (void)trackSuggestionWithWord:(NSString *)word houseType:(NSInteger)houseType result:(FHSuggestionResponseModel *)result {
    if (self.houseType != houseType || !word || !word.length) return;
    
    NSString *tagsStr = @"{}";
    NSInteger count = result.data.items.count + result.data.otherItems.count;
    if (count) {
        NSArray *filteredResultArray = [result.data.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            if (![object isKindOfClass:FHSuggestionResponseItemModel.class]) return NO;
            FHSuggestionResponseItemModel *item = (FHSuggestionResponseItemModel *)object;
            return item.cardType == 16;
        }]];
        
        NSArray *filteredOtherResultArray = [result.data.otherItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            if (![object isKindOfClass:FHSuggestionResponseItemModel.class]) return NO;
            FHSuggestionResponseItemModel *item = (FHSuggestionResponseItemModel *)object;
            return item.cardType == 16;
        }]];
        
        count = filteredResultArray.count + filteredOtherResultArray.count;
    }
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    [itemArray addObjectsFromArray:result.data.items];
    [itemArray addObjectsFromArray:result.data.otherItems];
    if(count){
        tagsStr = [self resultTagsString:itemArray houseType:houseType];
    }
    NSMutableDictionary *differResultnum = [NSMutableDictionary new];
    NSInteger newNum = [self getDifferResultnum:itemArray houseType:FHHouseTypeNewHouse];
    NSInteger oldNum = [self getDifferResultnum:itemArray houseType:FHHouseTypeSecondHandHouse];
    NSInteger rentingNum = [self getDifferResultnum:itemArray houseType:FHHouseTypeRentHouse];
    NSInteger neighborhoodNum = [self getDifferResultnum:itemArray houseType:FHHouseTypeNeighborhood];
    if(newNum){
        differResultnum[@"new"] = @(newNum);
    }
    if(oldNum){
        differResultnum[@"old"] = @(oldNum);
    }
    if(rentingNum){
        differResultnum[@"renting"] = @(rentingNum);
    }
    if(neighborhoodNum){
        differResultnum[@"neighborhood"] = @(neighborhoodNum);
    }
    NSString *differResultnumstring = [differResultnum btd_jsonStringEncoded];
    self.sugWordShowtracerDic = @{
        UT_ORIGIN_FROM: [self fh_originFrom],
        UT_ENTER_FROM: self.tabSwitched ? [self fh_pageType] : [self fh_fromPageType],
        UT_PAGE_TYPE: [self fh_pageType],
        TrackKeyTabName: [self trackTabName],
        TrackKeySuggestionResultCount: @(count),
        TrackKeySuggestionWord: word,
        TrackKeySuggestionResultTags: tagsStr,
        UT_EVENT_TRACKING_ID: TrackValueSuggestionResultShowTrackingID,
        @"differ_result_num":differResultnumstring,
    };
    [FHUserTracker writeEvent:TrackEventSuggestionResultShow params:self.sugWordShowtracerDic];
//    TRACK_EVENT(TrackEventSuggestionResultShow,self.sugWordShowtracerDic);
}
//cardtype == 16是sug词对应可以跳转列表页cell/详情页cell卡片
- (NSInteger)getDifferResultnum:(NSArray *)resultArray houseType:(NSInteger)houseType{
    NSArray *filteredOtherResultArray = [resultArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        if (![object isKindOfClass:FHSuggestionResponseItemModel.class]) return NO;
        FHSuggestionResponseItemModel *item = (FHSuggestionResponseItemModel *)object;
        return [item.houseType intValue] == houseType && item.cardType == 16;
    }]];
    return  filteredOtherResultArray.count;
}

//{小区|牡丹园,小区|牡丹园中兴大厦,地铁|牡丹园站}
- (NSString *)resultTagsString:(NSArray *)resultArray houseType:(NSInteger)houseType {
    NSMutableString *tagStr = [NSMutableString string];
    [tagStr appendString:@"{"];
    BOOL firstTag = YES;
    for (FHSuggestionResponseItemModel *item in resultArray) {
        if(item.cardType != 16){
            continue;
        }
        if (!firstTag) {
            [tagStr appendFormat:@","];
        }
        
        NSString *name = item.name;
        if (!name || !name.length) name = item.text;
        if (!name || !name.length) continue;;
        
        firstTag = NO;
        if(!item.isNewStyle && item.recallType && item.recallType.length && [item.houseType intValue]== FHHouseTypeSecondHandHouse){
            [tagStr appendFormat:@"%@|%@", item.recallType, name];
        }else if (item.newtip && item.newtip.content.length &&  [item.houseType intValue] == FHHouseTypeSecondHandHouse) {
            [tagStr appendFormat:@"%@|%@", item.newtip.content, name];
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
