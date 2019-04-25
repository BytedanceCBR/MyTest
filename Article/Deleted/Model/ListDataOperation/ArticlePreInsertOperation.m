//
//  ArticlePreInsertOperation.m
//  Article
//
//  Created by Dianwei on 13-2-24.
//
//

#import "ArticlePreInsertOperation.h"
#import "ListDataHeader.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "ExploreFetchListDefines.h"
#import "ExploreListHelper.h"

#import "Card+CoreDataClass.h"
#import "HorizontalCard.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTFeedValidator.h"
#import "TTTrackerWrapper.h"
#import "NSObject+TTAdditions.h"
#import <Heimdallr/HMDTTMonitor.h>

@implementation ArticlePreInsertOperation

typedef NS_ENUM(NSUInteger, TTAdDataErrorCode) {
    TTAdDataErrorCodeWrongFormat = 1,       // ad_id 在外面
    TTAdDataErrorCodeWrongADData = 2,       // 有_data
    TTAdDataErrorCodeWrongDuplicate = 3,    // ad_id 重复
    TTAdDataErrorCodeWrongExpire = 4        // 过期广告
};

static TTFeedValidator *_feedValidator;
+ (TTFeedValidator *)feedValidator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _feedValidator = [[TTFeedValidator alloc] init];
    });
    return _feedValidator;
}

- (void)execute:(NSMutableDictionary *)operationContext
{
    NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
    
    NSDictionary *result = [operationContext objectForKey:kExploreFetchListResponseRemoteDataKey];
    
    //action_to_last_stick : 0表示不处理，1表示删除置顶，2表示取消置顶
    NSNumber * actionToLastStick = @([[result tt_dictionaryValueForKey:@"result"] tt_intValueForKey:@"action_to_last_stick"]);
    
    if ([operationContext objectForKey:kExploreFetchListConditionKey][kExploreFetchListSilentFetchFromRemoteKey]) {
        // 快速插入，action_to_last_stick设置为0
        actionToLastStick = @(0);
    }

    NSMutableArray * handledAllItems = [NSMutableArray array];
    if ([actionToLastStick intValue] == 1) {
        for (NSObject *item in allItems) {
            if ([item isKindOfClass:[ExploreOrderedData class]] && ((ExploreOrderedData *)item).stickStyle != 0)
            {
                [ExploreOrderedData removeEntities:@[item]];
            }
            else{
                [handledAllItems addObject:item];
            }
        }
    }
    else if ([actionToLastStick intValue] == 2){
        NSUInteger cancelStickCount = 0;
        for (NSObject *item in allItems) {
            if ([item isKindOfClass:[ExploreOrderedData class]] && ((ExploreOrderedData *)item).stickStyle != 0) {//取消使用置顶的样式
                ((ExploreOrderedData *)item).isStick = NO;
                ((ExploreOrderedData *)item).stickStyle = 0;
                [((ExploreOrderedData *)item) save];
                cancelStickCount ++;
            }
            [handledAllItems addObject:item];
        }
        [operationContext setObject:@(cancelStickCount) forKey:kExploreFetchListResponseCancelStickCountKey];
    }
    else{
        handledAllItems = [allItems mutableCopy];
    }
    [operationContext setValue:handledAllItems forKey:kExploreFetchListItemsKey];
    
    
    NSArray *remoteList = [[[operationContext tt_dictionaryValueForKey:kExploreFetchListResponseRemoteDataKey] tt_dictionaryValueForKey:@"result"] tt_arrayValueForKey:@"data"];
    NSString *categoryID = [[operationContext tt_dictionaryValueForKey:kExploreFetchListConditionKey] tt_stringValueForKey:kExploreFetchListConditionListUnitIDKey];
    
    NSString *concernID = [[operationContext tt_dictionaryValueForKey:kExploreFetchListConditionKey] tt_stringValueForKey:kExploreFetchListConditionListConcernIDKey];
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [[operationContext tt_dictionaryValueForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListPreInsertOperationBeginTimeStampKey];
    

    NSString *listEntrance = [operationContext tt_dictionaryValueForKey:kExploreFetchListConditionKey][kExploreFetchListConditionListShortVideoListEntranceKey];
    
    NSMutableArray * persistents = [NSMutableArray arrayWithCapacity:10];       //保存非内嵌型数据(原始数据)
    NSMutableArray * cardArticles = [NSMutableArray arrayWithCapacity:10];      // card里的article
    
    NSMutableArray * cardStockDatas = [NSMutableArray arrayWithCapacity:10];        //card里的自选股cell
    NSMutableArray * cardBookDatas = [NSMutableArray arrayWithCapacity:10];         //card里推荐多本小说
    
    NSMutableArray * horizontalCardShortVideoDatas = [NSMutableArray arrayWithCapacity:10];
    
    ExploreOrderedDataListType listType = [operationContext tt_intValueForKey:kExploreFetchListListTypeKey];
    ExploreOrderedDataListLocation listLocation = [operationContext tt_intValueForKey:kExploreFetchListListLocationKey];
    
    NSUInteger loadMoreCount = [operationContext tt_intValueForKey:kExploreFetchListConditionLoadMoreCountKey];
    BOOL isGetMore = [operationContext tt_boolValueForKey:kExploreFetchListGetMoreKey];
    
    NSUInteger searchStartOrderIndex = 0;//用于搜索
    if (isGetMore) {
        searchStartOrderIndex = (loadMoreCount + 1) * kExploreFetchListSearchRemoteLoadCount;
    }
    
    //存储文章，段子的group id， 用于一次返回的列表内消重
    NSMutableSet * infoGIDSet = [NSMutableSet setWithCapacity:20];
    NSMutableSet *infoIIDs = [NSMutableSet setWithCapacity:5];
    BOOL forceRawAdData = [SSCommonLogic isRawAdDataEnable];

    NSMutableArray *incorrectRecords = [NSMutableArray arrayWithCapacity:2];
    for(NSDictionary *originDict in remoteList)
    {
        if (![originDict isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary * dict;
        if ([originDict.allKeys containsObject:@"code"] && [originDict count]<=2) {
            NSString* content  = [originDict valueForKey:@"content"];
            NSData * contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
            dict = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
        }else{
            dict = originDict;
        }
        if (!dict) {
            continue;
        }
        //此处处理不支持的类型
        ExploreOrderedDataCellType cellType = [dict tt_intValueForKey:@"cell_type"];
        BOOL supportCellType = [ExploreListHelper supportForCellType:cellType];
        if (!supportCellType) {
            [[HMDTTMonitor defaultManager] hmdTrackService:@"article_cell_type_unsupport" attributes:@{@"cell_type":@(cellType),@"category_id":categoryID?:@"unknown"}];
            continue;
        }
        if (![[ArticlePreInsertOperation feedValidator] isValidObject:dict]) {
            [incorrectRecords addObject:dict];
            continue;
        }
        
        NSMutableDictionary * mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        if (!isEmptyString(categoryID)) {
            [mutDict setValue:categoryID forKey:@"categoryID"];
        } else {
            [mutDict setValue:@"" forKey:@"categoryID"];
        }
        
        if (!isEmptyString(concernID)) {
            [mutDict setValue:concernID forKey:@"concernID"];
        } else {
            [mutDict setValue:@"" forKey:@"concernID"];
        }
        
        [mutDict setValue:@(listType) forKey:@"listType"];
        [mutDict setValue:@(listLocation) forKey:@"listLocation"];
    
        [mutDict setValue:listEntrance forKey:@"list_entrance"];//看起来可以删掉-。-
        
        if (![[mutDict allKeys] containsObject:@"ad_click_track_url"] && [[mutDict allKeys] containsObject:@"click_track_url"]) {
            [mutDict setValue:[mutDict objectForKey:@"click_track_url"] forKey:@"ad_click_track_url"];
        }
        
        if (![[mutDict allKeys] containsObject:@"ad_track_url"] && [[mutDict allKeys] containsObject:@"track_url"]) {
            [mutDict setValue:[mutDict objectForKey:@"track_url"] forKey:@"ad_track_url"];
        }

        if (![[mutDict allKeys] containsObject:@"ad_click_track_url_list"] && [[mutDict allKeys] containsObject:@"click_track_url_list"]) {
            [mutDict setValue:[mutDict objectForKey:@"click_track_url_list"] forKey:@"ad_click_track_url_list"];
        }
        
        if (![[mutDict allKeys] containsObject:@"ad_track_url_list"] && [[mutDict allKeys] containsObject:@"track_url_list"]) {
            [mutDict setValue:[mutDict objectForKey:@"track_url_list"] forKey:@"ad_track_url_list"];
        }
        
        if (listType == ExploreOrderedDataListTypeFavorite) {
            if (![[dict allKeys] containsObject:@"user_repin_time"]) {
                //没有user_repin_time的数据用behot_time
                if ([[dict allKeys] containsObject:kExploreOrderedDataCursorKey]) {
                    [mutDict setValue:[dict objectForKey:kExploreOrderedDataCursorKey] forKey:@"orderIndex"];
                }
                else if ([[dict allKeys] containsObject:@"behot_time"]) {
                    NSNumber *behotTime = [dict objectForKey:@"behot_time"];
                    [mutDict setValue:@([behotTime longLongValue] * 1000) forKey:@"orderIndex"];
                }
                else {
                    //没有user_repin_time和behot_time、cursor的数据过滤
                    continue;
                }
                
            }
            else {
                //补充order Index
                NSNumber *repinTime = [dict objectForKey:@"user_repin_time"];
                [mutDict setValue:@([repinTime longLongValue] * 1000) forKey:@"orderIndex"];
            }
            
            [mutDict setValue:@(YES) forKey:@"user_repin"];
        }
        else {
            if ([[dict allKeys] containsObject:kExploreOrderedDataCursorKey]) {
                [mutDict setValue:[dict objectForKey:kExploreOrderedDataCursorKey] forKey:@"orderIndex"];
            }
            else if ([[dict allKeys] containsObject:@"behot_time"]) {
                NSNumber *behotTime = [dict objectForKey:@"behot_time"];
                [mutDict setValue:@([behotTime longLongValue] * 1000) forKey:@"orderIndex"];
            }
            else {
                //没有behot_time、cursor的数据， 全部过滤
                continue;
            }
        }
        NSString *itemID = nil;
        if (dict[@"item_id"]) {
            itemID = [NSString stringWithFormat:@"%@", dict[@"item_id"]];
        }
        [mutDict setValue:itemID forKey:@"itemID"];
        
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        [mutDict setValue:@(now) forKey:@"requestTime"];
        
        if (cellType == ExploreOrderedDataCellTypeArticle ||
            cellType == ExploreOrderedDataCellTypeEssay) {
            
            if (![[dict allKeys] containsObject:@"group_id"]) {
                //判断，如果没有gid，则废弃这条数据
                continue;
            }

            NSString * gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"group_id"]];
            
            NSString *ad_id = nil;
            NSDictionary *raw_ad_data = dict[@"raw_ad_data"];
            if (dict[@"ad_id"]) {
                ad_id = [dict tt_stringValueForKey:@"ad_id"];
            } else if ([raw_ad_data isKindOfClass:[NSDictionary class]] && raw_ad_data[@"id"]) {
                [mutDict setValue:raw_ad_data[@"id"] forKey:@"ad_id"];
                [mutDict setValue:raw_ad_data[@"log_extra"] forKey:@"log_extra"];
                ad_id = [raw_ad_data tt_stringValueForKey:@"id"];
            }
            // 有adID时优先使用adID排重，不同的广告adID不同，gid可能相同
            if (!isEmptyString(ad_id)) {
                if ([infoGIDSet containsObject:ad_id]) {
                    NSMutableDictionary *extra = @{}.mutableCopy;
                    [extra setValue:ad_id forKey:@"ad_id"];
                    [extra setValue:@(cellType) forKey:@"cell_type"];
                    [extra setValue:@"feed" forKey:@"source"];
                    [[TTMonitor shareManager] trackService:@"ad_data_error" status:TTAdDataErrorCodeWrongDuplicate extra:extra];
                    continue;
                }
                [infoGIDSet addObject:ad_id];
            } else {
                if ([infoGIDSet containsObject:gid] || (itemID && [infoIIDs containsObject:itemID])) {
                    //如果本次返回的数据，已经有包含这个gid/itemid 的数据， 则消重
                    continue;
                }
                [infoGIDSet addObject:gid];
                if (itemID) {
                    [infoIIDs addObject:itemID];
                }
            }
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            
            /// 新增了文章类型的广告，实际是文章，但是 广告的属性都包含在 ad_data里面，为了避免新建很多字段进行存储，就直接dump成string存储
            if ([dict valueForKey:@"ad_data"]) {
                NSDictionary *adData = [dict valueForKey:@"ad_data"];
                if ([adData isKindOfClass:[NSDictionary class]]) {
                    NSString *adPromoter = [adData tt_JSONRepresentation];
                    [mutDict setValue:adPromoter forKey:@"ad_data"];
                }
                if (forceRawAdData) {
                    NSMutableDictionary *extra = @{}.mutableCopy;
                    [extra setValue:ad_id forKey:@"ad_id"];
                    [extra setValue:@(cellType) forKey:@"cell_type"];
                    [extra setValue:@"feed" forKey:@"source"];
                    [[TTMonitor shareManager] trackService:@"ad_data_error" status:TTAdDataErrorCodeWrongADData extra:extra];
                }
            }
            [persistents addObject:mutDict];
            
            NSString *title = [dict tt_stringValueForKey:@"title"];
            if (cellType == ExploreOrderedDataCellTypeArticle && isEmptyString(title) && ![categoryID isEqualToString:@"fake"]) {
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                [extra setValue:gid forKey:@"gid"];
                [extra setValue:itemID forKey:@"itemid"];
                [[TTMonitor shareManager] trackService:@"article_without_title" status:1 extra:extra];
            }
        }
        else if (cellType == ExploreOrderedDataCellTypeEssayAD) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeFantasyCard) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeLoadMoreTip) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        
        else if (cellType == ExploreOrderedDataCellTypeFHHouse) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        
        else if (cellType == ExploreOrderedDataCellTypeSurveyList) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeSurveyPair) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeThread) {
            if (![[dict allKeys] containsObject:@"thread_id"]) {
                //判断，如果没有thread_id，就废弃这条数据
                continue;
            }
            NSString *tid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"thread_id"]];
            
            if ([infoGIDSet containsObject:tid]) {
                //如果本次返回的数据，已经有包含这个adID 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:tid];
            
            [mutDict setValue:tid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeAppDownload) {
            NSString *ad_id = nil;
            NSDictionary *raw_ad_data = dict[@"raw_ad_data"];
            if (dict[@"ad_id"]) {
                ad_id = [NSString stringWithFormat:@"%@", dict[@"ad_id"]];
            } else if ([raw_ad_data isKindOfClass:[NSDictionary class]] && dict[@"raw_ad_data"][@"id"]) {
                [mutDict setValue:raw_ad_data[@"id"] forKey:@"ad_id"];
                [mutDict setValue:raw_ad_data[@"log_extra"] forKey:@"log_extra"];
                ad_id = [raw_ad_data tt_stringValueForKey:@"id"];
            }
            if (isEmptyString(ad_id)) { //判断，如果没有adid, raw_ad_data，则废弃这条数据
                NSMutableDictionary *extra = @{}.mutableCopy;
                [extra setValue:@(cellType) forKey:@"cell_type"];
                [extra setValue:@"feed" forKey:@"source"];
                [[TTMonitor shareManager] trackService:@"ad_data_error" status:TTAdDataErrorCodeWrongFormat extra:extra];
                continue;
            }
            if ([infoGIDSet containsObject:ad_id]) {
                //如果本次返回的数据，已经有包含这个adID 的数据， 则消重
                NSMutableDictionary *extra = @{}.mutableCopy;
                [extra setValue:ad_id forKey:@"ad_id"];
                [extra setValue:@(cellType) forKey:@"cell_type"];
                [extra setValue:@"feed" forKey:@"source"];
                [[TTMonitor shareManager] trackService:@"ad_data_error" status:TTAdDataErrorCodeWrongDuplicate extra:extra];
                continue;
            }
            [infoGIDSet addObject:ad_id];
            [mutDict setValue:ad_id forKey:@"uniqueID"];
            
            NSString *adPromoter = [mutDict tt_JSONRepresentation];
            [mutDict setValue:adPromoter forKey:@"ad_data"];
            
            [persistents addObject:mutDict];
        }
        else if(cellType == ExploreOrderedDataCellTypeCard)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                LOGD(@"ExploreOrderedDataCellTypeCard has NO id");
                continue;
            }
            
            NSString * gID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];

            if ([infoGIDSet containsObject:gID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gID];
            [mutDict setValue:gID forKey:@"uniqueID"];
            LOGD(@"card uniqueID: %@", gID);
            
            // 处理card里的article
            NSArray *dataArray = [mutDict tt_arrayValueForKey:@"data"];
            NSMutableArray *filterDataArray = [NSMutableArray arrayWithCapacity:dataArray.count];
            
            for (NSDictionary *data in dataArray)
            {
                ExploreOrderedDataCellType cellType = [data tt_intValueForKey:@"cell_type"];
                if (cellType == ExploreOrderedDataCellTypeArticle)
                {
                    if (![[data allKeys] containsObject:@"group_id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        LOGD(@"ExploreOrderedDataCellTypeCard has NO group_id");
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"group_id"]];

                    NSMutableDictionary *articleData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [articleData setValue:gid forKey:@"uniqueID"];
                    [articleData setValue:categoryID forKey:@"categoryID"];
                    [articleData setValue:concernID forKey:@"concernID"];
                    [articleData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [articleData setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
                    [cardArticles addObject:articleData];
                    [filterDataArray addObject:articleData];
                }
                else if (cellType == ExploreOrderedDataCellTypeStock){
                    if (![[data allKeys] containsObject:@"id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
                    NSMutableDictionary *stockData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [stockData setValue:gid forKey:@"uniqueID"];
                    [stockData setValue:categoryID forKey:@"categoryID"];
                    [stockData setValue:concernID forKey:@"concernID"];
                    [stockData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [stockData setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
                    [cardStockDatas addObject:stockData];
                    [filterDataArray addObject:stockData];
                }
                else if (cellType == ExploreOrderedDataCellTypeBook) {
                    if (![[data allKeys] containsObject:@"id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
                    NSMutableDictionary *bookData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [bookData setValue:gid forKey:@"uniqueID"];
                    [bookData setValue:categoryID forKey:@"categoryID"];
                    [bookData setValue:concernID forKey:@"concernID"];
                    [bookData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [bookData setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
                    [cardBookDatas addObject:bookData];
                    [filterDataArray addObject:bookData];
                }
            } //for
            
            [mutDict setValue:filterDataArray forKey:@"data"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeWeb ||
                 cellType == ExploreOrderedDataCellTypeRN ||
                 cellType == ExploreOrderedDataCellTypeInterestGuide ||
                 cellType == ExploreOrderedDataCellTypeDynamicRN) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];

            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeLive) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                continue;
            }
            
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"live_id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [mutDict setValue:@([gid longLongValue]) forKey:@"live_id"];
            NSDictionary *raw_ad_data = dict[@"raw_ad_data"];
            if ([dict[@"raw_ad_data"] isKindOfClass:[NSDictionary class]] && raw_ad_data[@"id"]) {
                [mutDict setValue:raw_ad_data[@"id"] forKey:@"ad_id"];
                [mutDict setValue:raw_ad_data[@"log_extra"] forKey:@"log_extra"];
            }
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeHuoShan) {
            
            if (![[dict allKeys] containsObject:@"live_id"]) {
                //判断，如果没有live id，则废弃这条数据
                continue;
            }
            NSString *liveId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"live_id"]];
            if ([infoGIDSet containsObject:liveId]) {
                //如果本次返回的数据，已经有包含这个liveId 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:liveId];
            [mutDict setValue:liveId forKey:@"uniqueID"];
            [mutDict setValue:@([liveId longLongValue]) forKey:@"live_id"];
            [persistents addObject:mutDict];
        }
        else if(cellType == ExploreOrderedDataCellTypeLianZai) {
            if(![[dict allKeys] containsObject:@"id"]){
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeBook) {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedWenDaInviteCellType)
        {
            if(![[dict allKeys] containsObject:@"id"]){
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedAddToFirstPageCellType)
        {
            if(![[dict allKeys] containsObject:@"id"]){
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedWenDaCategoryBaseCell)
        {
            if(![[dict allKeys] containsObject:@"id"]){
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeComment)
        {
            NSDictionary *commentExtra = nil;
            if ([[dict allKeys] containsObject:@"comment_extra"]) {
                commentExtra = [dict tt_dictionaryValueForKey:@"comment_extra"];
            }
            if (![[commentExtra allKeys] containsObject:@"dongtai_id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[commentExtra objectForKey:@"dongtai_id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeRecommendUser)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeCommentRepost)
        {
            NSDictionary *rawData = [dict tt_dictionaryValueForKey:@"raw_data"];
            if (rawData == nil || ![[rawData allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[rawData objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeShortVideo ||
                 cellType == ExploreOrderedDataCellTypeShortVideo_AD){
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *uniqueID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:uniqueID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:uniqueID];
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"uniqueID"];
            //没有下发item_id，客户端自己加一个
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"itemID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeWendaAnswer || cellType == ExploreOrderedDataCellTypeWendaQuestion) {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *uniqueID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:uniqueID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:uniqueID];
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeHorizontalCard)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                LOGD(@"ExploreOrderedDataCellTypeHorizontalCard has NO id");
                continue;
            }
            
            NSString * gID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gID];
            [mutDict setValue:gID forKey:@"uniqueID"];
            [persistents addObject:mutDict];
            LOGD(@"card uniqueID: %@", gID);
            // 处理card里的shortvideo
            for (NSDictionary *data in [mutDict tt_arrayValueForKey:@"data"])
            {
                ExploreOrderedDataCellType cellType = [data tt_intValueForKey:@"cell_type"];
                if (cellType == ExploreOrderedDataCellTypeShortVideo)
                {
                    if (![[data allKeys] containsObject:@"id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        LOGD(@"ExploreOrderedDataCellTypeShortVideo has NO id");
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
                    
                    NSMutableDictionary *shortVideoOriginalData = [NSMutableDictionary dictionaryWithDictionary:data];
                   
                    [shortVideoOriginalData setValue:gid forKey:@"uniqueID"];
                    [shortVideoOriginalData setValue:/*cardModel.categoryID*/kHorizontalCardCategoryID forKey:@"categoryID"];
                    [shortVideoOriginalData setValue:@"" forKey:@"concernID"];
                    [shortVideoOriginalData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [shortVideoOriginalData setValue:@(ExploreOrderedDataListLocationCategory) forKey:@"listLocation"];
                    [horizontalCardShortVideoDatas addObject:shortVideoOriginalData];
                }
            }
        }else if (cellType == ExploreOrderedDataCellTypeResurface){
            
            if (![[dict allKeys] containsObject:@"id"] || [TTDeviceHelper isPadDevice]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeRecommendUserLargeCard)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeHashtag)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeRedpacketRecommendUser)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeXiguaLive)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeTopPopularHashtag)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeXiguaLiveHorizontal)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeXiguaLiveRecommend)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeMomentsRecommendUser)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeShortVideoRecommendUserCard ||
                   cellType == ExploreOrderedDataCellTypeShortVideoActivityEntrance ||
                   cellType == ExploreOrderedDataCellTypeShortVideoActivityBanner ||
                   cellType == ExploreOrderedDataCellTypeShortVideoStory) {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeRecommendUserStoryCard) {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeRecommendStoryCoverCard) {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeHotNews) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group_id，就废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            
            [mutDict setValue:gid forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
    }
    
    // 只监控主Feed频道返回数据的数量
    if ([categoryID isEqualToString:kTTMainCategoryID] || [categoryID isEqualToString:kTTVideoCategoryID]) {
        if (remoteList.count == 0) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:categoryID forKey:@"categoryID"];
            [extra setValue:concernID forKey:@"concernID"];
            [[TTMonitor shareManager] trackService:@"feed_no_data" status:1 extra:extra];
        } else if (remoteList.count < 4) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:categoryID forKey:@"categoryID"];
            [extra setValue:concernID forKey:@"concernID"];
            [[TTMonitor shareManager] trackService:@"feed_count_abnormal" status:1 extra:extra];
        }
    } else if ([categoryID isEqualToString:kTTUGCVideoCategoryID]) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];

        [extra setValue:listEntrance forKey:@"list_entrance"];
        
        if (remoteList.count == 0) {//刷新返回条数等于0条，无数据
            [[TTMonitor shareManager] trackService:@"short_video_list_no_data" status:1 extra:extra];
        } else if (remoteList.count <= 6) {//刷新返回条数少于等于6条，过少
            [extra setValue:@(remoteList.count) forKey:@"abnormal_count"];
            [[TTMonitor shareManager] trackService:@"short_video_list_count_abnormal" status:1 extra:extra];
        } else if (remoteList.count >= 14) {//刷新返回条数大于等于14条，过多
            [extra setValue:@(remoteList.count) forKey:@"abnormal_count"];
            [[TTMonitor shareManager] trackService:@"short_video_list_count_abnormal" status:2 extra:extra];
        } else {
            [extra setValue:@(remoteList.count) forKey:@"abnormal_count"];
            [[TTMonitor shareManager] trackService:@"short_video_list_count_abnormal" status:0 extra:extra];

        }
    } else if ([categoryID isEqualToString:kTTFollowCategoryID]) {
        if (remoteList.count == 0) {
            [[TTMonitor shareManager] trackService:@"followcategory_no_data" status:isGetMore? 2: 1  extra:@{}]; //拉去更多和下拉刷新需要分别监控
        } else if (remoteList.count < 4) {
            [[TTMonitor shareManager] trackService:@"followcategory_count_abnormal" status:isGetMore? 2: 1  extra:@{}];
        }
    } else if (categoryID && [[self popularCategoryIDs] containsObject:categoryID]) {
        if (remoteList.count == 0) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:categoryID forKey:@"categoryID"];
            [extra setValue:concernID forKey:@"concernID"];
            NSString *serviceName = [NSString stringWithFormat:@"%@_no_data", categoryID];
            [[TTMonitor shareManager] trackService:serviceName status:isGetMore? 2: 1 extra:extra];
        } else if (remoteList.count < 4) {
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            [extra setValue:categoryID forKey:@"categoryID"];
            [extra setValue:concernID forKey:@"concernID"];
            NSString *serviceName = [NSString stringWithFormat:@"%@_count_abnormal", categoryID];
            [[TTMonitor shareManager] trackService:serviceName status:isGetMore? 2: 1 extra:extra];
        }
    }
    
    [operationContext setValue:persistents forKey:kExploreFetchListResponseRemotePersistantDataKey];
    [operationContext setValue:cardArticles forKey:kExploreFetchListResponseArticleInCardDataKey];
    [operationContext setValue:cardStockDatas forKey:kExploreFetchListResponseStockDataInCardDataKey];
    [operationContext setValue:cardBookDatas forKey:kExploreFetchListResponseBookDataInCardDataKey];
    
    [operationContext setValue:horizontalCardShortVideoDatas forKey:kExploreFetchListResponseShortVideoDataInCardDataKey];
    
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListPreInsertOperationEndTimeStampKey];
    [self executeNext:operationContext];
    
    if (incorrectRecords.count > 0) {
        /// 发送出错的记录给服务器
        [self _handleIncorrectRecords:incorrectRecords];
    }
}

- (void)_handleIncorrectRecords:(NSArray *)records {
    if (SSIsEmptyArray(records)) {
        return;
    }
    // 发送几条数据出错了
    NSDictionary * events = @{@"category":@"umeng", @"tag":@"embeded_ad", @"label":@"invalidate", @"value":@(records.count)};
    [TTTrackerWrapper eventData:events];
    
    [[TTMonitor shareManager] trackService:@"feed_incorrect_records" status:1 extra:events];
}

- (NSSet *)popularCategoryIDs {
    static NSSet *categoryIDs = nil;
    if (!categoryIDs) {
        categoryIDs = [NSSet setWithObjects:
                       @"news_hot",
                       @"news_local",
                       @"video",
                       @"news_society",
                       @"news_entertainment",
                       @"question_and_answer",
                       @"news_tech",
                       @"news_car",
                       @"news_sports",
                       @"news_finance",
                       @"news_military",
                       @"news_world",
                       @"essay_joke",
                       @"image_funny",
                       @"news_health",
                       nil];
    }
    return categoryIDs;
}


@end
