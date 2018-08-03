//
//  ExploreListHelper.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-4.
//
//

#import "ExploreListHelper.h"
#import "NetworkUtilities.h"
#import "ExploreOriginalData.h"
#import "TTArticleCategoryManager.h"
#import "NewsBaseDelegate.h"
#import "TTNavigationController.h"
#import "TTDeviceHelper.h"
#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>
#import "TTHistoryEntryGroup.h"

@implementation ExploreListHelper

+ (BOOL)supportForCellType:(ExploreOrderedDataCellType)cellType
{
    BOOL support = YES;
    switch (cellType) {
        case ExploreOrderedDataCellTypeArticle:
            break;
        case ExploreOrderedDataCellTypeEssay:
            break;
        case ExploreOrderedDataCellTypeEssayAD:
            break;
        case ExploreOrderedDataCellTypeFantasyCard:
            break;
        case ExploreOrderedDataCellTypeSurveyList:
            break;
        case ExploreOrderedDataCellTypeSurveyPair:
            break;
//        case ExploreOrderedDataCellTypeThread:
//            break;
        case ExploreOrderedDataCellTypeWeb:
            break;
        case ExploreOrderedDataCellTypeAppDownload:
            break;
            
        case ExploreOrderedDataCellTypeCard:
//        case ExploreOrderedDataCellTypeLive:
//            break;
        case ExploreOrderedDataCellTypeStock:
            break;
//        case ExploreOrderedDataCellTypeHuoShan:
//            break;
        case ExploreOrderedDataCellTypeLastRead:
            break;

        case ExploreOrderedDataCellTypeRN:
        case ExploreOrderedDataCellTypeInterestGuide:
        case ExploreOrderedDataCellTypeDynamicRN:
        {
            // iOS7不支持
            if ([TTDeviceHelper OSVersionNumber] < 8.f) {
                return NO;
            }
        }
            break;
        case ExploreOrderedDataCellTypeLianZai:
            break;
        case ExploreOrderedWenDaCategoryHeaderInfoCell:
            break;
        case ExploreOrderedWenDaCategoryBaseCell:
            break;
        case ExploreOrderedWenDaInviteCellType:
            break;
        case ExploreOrderedAddToFirstPageCellType:
            break;
        case ExploreOrderedDataCellTypeBook:
            break;
//        case ExploreOrderedDataCellTypeComment:
//            break;
//        case ExploreOrderedDataCellTypeHashtag:
//        case ExploreOrderedDataCellTypeRecommendUser:
//            break;
        case ExploreOrderedDataCellTypeShortVideo_AD:
        case ExploreOrderedDataCellTypeShortVideo: {
            if ([TTDeviceHelper OSVersionNumber] < 8.f) {
                [[TTMonitor shareManager] trackService:@"shortvideo_feed_unsupported_os" attributes:@{
                                                                                                      @"type": @"ugcvideo",
                                                                                                      }];
                return NO;
            }
        }
            break;
//        case ExploreOrderedDataCellTypeWendaAnswer:
//        case ExploreOrderedDataCellTypeWendaQuestion:
//            break;
        case ExploreOrderedDataCellTypeHorizontalCard: {
            if ([TTDeviceHelper OSVersionNumber] < 8.f) {
                [[TTMonitor shareManager] trackService:@"shortvideo_feed_unsupported_os" attributes:@{
                                                                                                      @"type": @"card",
                                                                                                      }];
                return NO;
            }
        }
            break;
//        case ExploreOrderedDataCellTypeResurface:
//            break;
//        case ExploreOrderedDataCellTypeRecommendUserLargeCard:
//            break;
//        case ExploreOrderedDataCellTypeRedpacketRecommendUser:
//            break;
//        case ExploreOrderedDataCellTypeMomentsRecommendUser:
//            break;
//        case ExploreOrderedDataCellTypeCommentRepost:
//            break;
        case ExploreOrderedDataCellTypeShortVideoRecommendUserCard:
        case ExploreOrderedDataCellTypeShortVideoActivityEntrance:
        case ExploreOrderedDataCellTypeShortVideoActivityBanner:
            break;
        case ExploreOrderedDataCellTypeShortVideoStory:
            break;
//        case ExploreOrderedDataCellTypeXiguaLiveRecommend:
//            break;
//        case ExploreOrderedDataCellTypeXiguaLiveHorizontal:
//            break;
//        case ExploreOrderedDataCellTypeXiguaLive:
//            break;
//        case ExploreOrderedDataCellTypeRecommendUserStoryCard:
//            break;
//        case ExploreOrderedDataCellTypeRecommendStoryCoverCard:
//            break;
//        case ExploreOrderedDataCellTypeTopPopularHashtag:
//            break;
        case ExploreOrderedDataCellTypeHotNews:
            break;
        case ExploreOrderedDataCellTypeLoadMoreTip:
            break;
        default:
        {
            support = NO;
        }
            break;
    }
    return support;
}

+ (NSArray *)sortByIndexForArray:(NSArray *)array listType:(ExploreOrderedDataListType)listType
{
    return [self sortByIndexForArray:array orderedAscending:NO];
}

+ (NSArray *)sortByIndexForArray:(NSArray *)array orderedAscending:(BOOL)ascending
{
    BOOL insideAscending = ascending;
    NSArray * result = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        @try {
            NSTimeInterval obj1OrderIndex = 0;
            NSTimeInterval obj2OrderIndex = 0;
            if ([obj1 isKindOfClass:[ExploreOrderedData class]]) {
                obj1OrderIndex = [((ExploreOrderedData *)obj1) orderIndex];
            }
            else if ([obj1 isKindOfClass:[TTHistoryEntryGroup class]]){
                obj1OrderIndex = [((TTHistoryEntryGroup *)obj1) dateIdentifier];
                ((TTHistoryEntryGroup *)obj1).orderedDataList = [self sortByIndexForArray:((TTHistoryEntryGroup *)obj1).orderedDataList orderedAscending:ascending];
            }
            else {
                //扩展....
            }
            
            if ([obj2 isKindOfClass:[ExploreOrderedData class]]) {
                obj2OrderIndex = [((ExploreOrderedData *)obj2) orderIndex];
            }
            else if ([obj2 isKindOfClass:[TTHistoryEntryGroup class]]){
                obj1OrderIndex = [((TTHistoryEntryGroup *)obj2) dateIdentifier];
                ((TTHistoryEntryGroup *)obj2).orderedDataList = [self sortByIndexForArray:((TTHistoryEntryGroup *)obj2).orderedDataList orderedAscending:ascending];
            }
            else {
                //扩展....
            }
            
            NSComparisonResult comparisionResult = NSOrderedDescending;
            if (insideAscending) {
                comparisionResult = (obj1OrderIndex <= obj2OrderIndex ? NSOrderedAscending : NSOrderedDescending);//[@(obj1OrderIndex) compare:@(obj2OrderIndex)];
            }
            else {
                comparisionResult = (obj1OrderIndex >= obj2OrderIndex ? NSOrderedAscending : NSOrderedDescending);//[@(obj2OrderIndex) compare:@(obj1OrderIndex)];
            }
            
            return comparisionResult;
        }
        @catch (NSException *exception)
        {
            return NSOrderedDescending;
        }
    }];
    return result;
}

+ (NSArray *)filterFavoriteItems:(NSArray *)orderedDatas
{
    if ([orderedDatas count] == 0) {
        return orderedDatas;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    for (id item in orderedDatas) {
        if ([item isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData * orderItem = (ExploreOrderedData *)item;
            if (orderItem.originalData.userRepined) {
                [result addObject:item];
            }
        }
    }
    return [NSArray arrayWithArray:result];
}

#pragma mark -- 预加载条数

+ (void)setPreloadCount:(NSUInteger)count userSettingStatus:(TTNetworkTrafficSetting)setting
{
    NSString * key = [NSString stringWithFormat:@"ArticleHelperPreloadListCellCountFor%iKey", setting];
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)countForPreloadCell
{
    TTNetworkTrafficSetting setting = [TTUserSettingsManager networkTrafficSetting];
    if (TTNetworkWifiConnected()) {
        setting = TTNetworkTrafficOptimum;
    }
    NSString * key = [NSString stringWithFormat:@"ArticleHelperPreloadListCellCountFor%iKey", setting];
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void)trackEventForLabel:(NSString *)label listType:(ExploreOrderedDataListType)listType categoryID:(NSString *)categoryID concernID:(NSString *)concernID refer:(NSUInteger)refer
{
    if (isEmptyString(label)) {
        return;
    }
    NSString * eventName = @"category";
    switch (listType) {
        case ExploreOrderedDataListTypeCategory:
        {
            eventName = @"category";
        }
            break;
        case ExploreOrderedDataListTypeFavorite:
        {
            eventName = @"favorite_tab";
        }
            break;
        default:
            break;
    }
    if ([categoryID isEqualToString:kTTMainCategoryID]) {
        eventName = @"new_tab";
        if ([label isEqualToString:@"enter"]) {
            return; //添加频道时会调用此函数，enter统计错误，(@"new_tab", @"enter")改在其他地方统计
        }
    }
    
    // 不再发送 ("category", "enter") 统计，在列表切换时发送携带categoryId的。
    if ([eventName isEqualToString:@"category"] && [label isEqualToString:@"enter"]) {
        return;
    }
    
    //关心架构下 (@"category", @"enter")事件发送
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:label forKey:@"label"];
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:eventName forKey:@"tag"];
    if (!isEmptyString(categoryID)) {
        [dictionary setValue:categoryID forKey:@"category_id"];
    }
    if (!isEmptyString(concernID)) {
        [dictionary setValue:concernID forKey:@"concern_id"];
    }
    [dictionary setValue:@(refer) forKey:@"refer"];
    [TTTrackerWrapper eventData:dictionary];
}

+ (NSString *)refreshTypeStrForReloadFromType:(ListDataOperationReloadFromType)fromType
{
    NSDictionary *mapping = @{
                              @(ListDataOperationReloadFromTypeAirdownload): @"download",
                              @(ListDataOperationReloadFromTypeAuto): @"enter_auto",
                              @(ListDataOperationReloadFromTypeTip): @"tip",
                              @(ListDataOperationReloadFromTypeLastRead): @"last_read",
                              @(ListDataOperationReloadFromTypeAutoFromBackground): @"auto",
                              @(ListDataOperationReloadFromTypePull): @"pull",
                              @(ListDataOperationReloadFromTypeTab): @"tab",
                              @(ListDataOperationReloadFromTypeTabWithTip): @"tab_tip",
                              @(ListDataOperationReloadFromTypeClickCategory): @"click",
                              @(ListDataOperationReloadFromTypeClickCategoryWithTip): @"click_tip",
                              @(ListDataOperationReloadFromTypeLoadMore): @"load_more",
                              @(ListDataOperationReloadFromTypePreLoadMore): @"pre_load_more",
                              @(ListDataOperationReloadFromTypeLoadMoreDraw): @"load_more_draw",
                              @(ListDataOperationReloadFromTypePreLoadMoreDraw): @"pre_load_more_draw",
                              @(ListDataOperationReloadFromTypeCardItem): @"card",
                              @(ListDataOperationReloadFromTypeCardMore): @"more",
                              @(ListDataOperationReloadFromTypeCardDraw): @"card_draw",
                              };
    NSString *fromTypeString = mapping[@(fromType)];
    if (isEmptyString(fromTypeString)) {
        fromTypeString = @"unknown";
    }
    return fromTypeString;
}

@end
