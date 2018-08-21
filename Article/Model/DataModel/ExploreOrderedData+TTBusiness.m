//
//  ExploreOrderedData+TTBusiness.m
//  Article
//
//  Created by pei yun on 2017/9/25.
//

#import "ExploreOrderedData+TTBusiness.h"
#import "SSUserSettingManager.h"
#import "ExploreCellHelper.h"
#import "TTDeviceHelper.h"
#import "NetworkUtilities.h"
#import "NSDictionary+TTAdditions.h"
#import "NSString-Extension.h"
#import "JSONAdditions.h"
#import <TTFollowManager.h>
#import "Article+TTADComputedProperties.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <objc/runtime.h>
#import "TTLayOutCellBaseModel.h"
//#import "UGCBaseCellLayoutModel.h"
#import "TTADTrackEventLinkModel.h"

//#import "Thread.h"
#import "ListDataHeader.h"
#import "WapData.h"
#import "StockData.h"
#import "HuoShan.h"
#import "LianZai.h"
#import "Card+CoreDataClass.h"
#import "RNData.h"
#import "LastRead.h"
#import "Book.h"
#import "TTCategoryAddToFirstPageData.h"
//#import "WenDaInviteData.h"
//#import "WDHeaderInfoCellData.h"
//#import "WenDaBaseData.h"
#import "Comment.h"
//#import "RecommendUserCardsData.h"
#import "TTUserData.h"
#import "TSVShortVideoOriginalData.h"
#import "TTWenda.h"
#import "HorizontalCard.h"
#import "ResurfaceData.h"
#import "FRApiModel.h"
//#import "Live.h"
#import "RecommendUserLargeCardData.h"
#import "MomentsRecommendUserData.h"
//#import "FantasyCardData.h"
//#import "SurveyListData.h"
//#import "SurveyPairData.h"
#import "TTHotNewsData.h"
#import "TSVRecUserCardOriginalData.h"
#import "TTAdFeedModel.h"
//#import "RecommendRedpacketData.h"
//#import "FRCommentRepost.h"
//#import "TTHashtagCardData.h"
//#import "TTXiguaLiveModel.h"
//#import "TTXiguaLiveRecommendUser.h"
//#import "TTXiguaLiveCardHorizontal.h"
#import "TSVActivityEntranceOriginalData.h"
#import "TSVActivityBannerOriginalData.h"
#import "TSVPublishStatusOriginalData.h"
//#import "TSVStoryOriginalData.h"
//#import "RecommendUserStoryCardData.h"
//#import "RecommendStoryCoverCardData.h"
#import "TTUGCDefine.h"
//#import "PopularHashtagData.h"
#import "TTADTrackEventLinkModel.h"
#import "TTExploreLoadMoreTipData.h"
#import "ExploreOrderedData+TTAd.h"

#define kPlayerOverTrackUrlList @"playover_track_url_list"
#define kPlayerEffectiveTrackUrlList @"effective_play_track_url_list"
#define kPlayerActiveTrackUrlList @"active_play_track_url_list"
#define kPlayerTrackUrlList @"play_track_url_list"
#define kClickTrackUrlList @"click_track_url_list"
#define kShowTrackUrlList @"track_url_list"
#define kEffectivePlayTime @"effective_play_time"

extern NSInteger ttvs_autoPlayModeServerSetting(void);

@implementation ExploreOrderedData (TTBusiness)

/*
 dbVersion 41 TTWenda
           43 ActionDataModel 增加articleLike
           45 修复ActionDataModel未持久化articleLike的问题
 */
+ (NSInteger)dbVersion {
    return 47;
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"adClickTrackURLs",
                       @"adTrackURLs",
                       @"adVideoClickTrackURLs",
                       @"adPlayTrackUrls",
                       @"adPlayActiveTrackUrls",
                       @"adPlayEffectiveTrackUrls",
                       @"adPlayOverTrackUrls",
                       @"effectivePlayTime",
                       @"logExtra",
                       @"statURLs",
                       @"adLabel",
                       @"categoryID",
                       @"concernID",
                       @"adID",
                       @"adIDStr",
                       @"uniqueID",
                       @"itemID",
                       @"behotTime",
                       @"adExpireInterval",
                       @"requestTime",
                       @"primaryID",
                       @"cellType",
                       @"label",
                       @"labelStyle",
                       @"listType",
                       @"listLocation",
                       @"orderIndex",
                       @"itemIndex",
                       @"debugInfo",
                       @"tip",
                       @"showDislike",
                       @"actionExtra",
                       @"cellDeleted",
                       @"videoStyle",
                       @"cellFlag",
                       @"recommendReason",
                       @"recommendUrl",
                       @"cellHeight",
                       @"cellHeightChanged",
                       @"isStick",
                       @"stickStyle",
                       @"stickLabel",
                       @"gallaryStyle",
                       //                       @"autoPlayFlag",
                       @"actionList",
                       //                       @"filterWords",
                       @"uiType",
                       @"videoChannelADType",
                       @"largePicCeativeType",
                       @"cellLayoutStyle",
                       @"innerUiFlag",
                       @"maxTextLine",
                       @"defaultTextLine",
                       @"showFollowButton",
                       @"cellUIType",
                       @"largeImageDict",
                       @"openURL",
                       @"isFirstCached",
                       @"type",
                       @"logPb",
                       @"groupSource",
                       @"rid",
                       @"cellCtrls",
                       @"followButtonStyle",
                       @"trackSDK",
                       @"activity",
                       @"ugcRecommendDict",
                       @"raw_ad_data"
                       ];
    };
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"actionExtra":@"action_extra",
                       @"actionList":@"action_list",
                       @"adClickTrackURLs":@"ad_click_track_url_list",
                       @"largePicCeativeType":@"ad_display_style",
                       @"adID":@"ad_id",
                       @"adLabel":@"ad_label",
                       @"adTrackURLs":@"ad_track_url_list",
                       @"adVideoClickTrackURLs":@"ad_video_click_track_urls",
                       @"behotTime":@"behot_time",
                       @"cellFlag":@"cell_flag",
                       @"cellHeight":@"cell_height",
                       @"cellLayoutStyle":@"cell_layout_style",
                       @"cellType":@"cell_type",
                       @"cellUIType":@"cell_ui_type",
                       @"adExpireInterval":@"expire_seconds",
                       @"gallaryStyle":@"gallary_style",
                       @"innerUiFlag":@"inner_ui_flag",
                       @"cellDeleted":@"is_deleted",
                       @"isStick":@"is_stick",
                       @"labelStyle":@"label_style",
                       @"logExtra":@"log_extra",
                       @"maxTextLine":@"max_text_line",
                       @"defaultTextLine":@"default_text_line",
                       @"openURL":@"open_url",
                       @"recommendReason":@"reason",
                       @"recommendUrl":@"recommend_url",
                       @"showDislike":@"show_dislike",
                       @"statURLs":@"stat_url_list",
                       @"stickLabel":@"stick_label",
                       @"stickStyle":@"stick_style",
                       @"uiType":@"ui_type",
                       @"videoChannelADType":@"video_channel_ad_type",
                       @"videoStyle":@"video_style",
                       @"groupSource":@"group_source",
                       @"cellCtrls":@"cell_ctrls",
                       @"followButtonStyle":@"follow_button_style",
                       @"trackSDK":@"track_sdk",
                       @"ugcRecommendDict":@"ugc_recommend",
                       @"debugInfo":@"debug_info",
                       };
    }
    return properties;
}

+ (void)cleanEntities {
    NSTimeInterval t1 = CFAbsoluteTimeGetCurrent();
    float oneM = 1024.f * 1024.f;
    float dbSize = [ExploreOrderedData dbSize] / oneM;
    
    NSNumber *countBeforeClean = [self aggregate:@"count(*)" where:nil arguments:nil];
    
    int maxCountToKeep = 600; // 表中保留的最大记录数
    int threshold = 1000; // 触发清理的阈值
    int limit = threshold - maxCountToKeep; // 单次清理上限，避免内存占用过大以及耗时过长
    
    if (countBeforeClean.longLongValue > threshold) {
        // 查询每个orderedData，是为了精确删除orderedData关联的对象
        NSArray<ExploreOrderedData *> *orderedDataArray = [ExploreOrderedData objectsWithQuery:nil orderBy:@"requestTime ASC" offset:0 limit:limit];
        
        NSMutableDictionary *deleteRowsDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        if (orderedDataArray.count > 0) {
            
            [orderedDataArray enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 非LastRead对象
                if (obj.originalData && ![obj.originalData isKindOfClass:[LastRead class]]) {
#if DEBUG
                    NSString *tableName = NSStringFromClass(obj.originalData.class);
                    NSNumber *num = [deleteRowsDict objectForKey:tableName];
                    [deleteRowsDict setValue:@(num.longLongValue + 1) forKey:tableName];
#endif
                    
                    [obj.originalData deleteObject];
                    [obj deleteObject];
                }
            }];
            
            NSNumber *countAfterClean = [self aggregate:@"count(*)" where:nil arguments:nil];
            LOGD(@"%@ : %@ -> %@", NSStringFromClass(self), countBeforeClean, countAfterClean);
            
            NSTimeInterval t2 = CFAbsoluteTimeGetCurrent();
            
            [Answers logCustomEventWithName:@"cleanOrderedData" customAttributes:@{@"threshold":@(threshold),
                                                                                   @"count1":countBeforeClean,
                                                                                   @"count2":countAfterClean,
                                                                                   @"cost":@(t2 - t1),
                                                                                   @"dbSize":@(dbSize)
                                                                                   }];
        }
        
#if DEBUG
        
        [deleteRowsDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            Class tableClass = NSClassFromString(key);
            if ([tableClass isSubclassOfClass:[TTEntityBase class]]) {
                __unused NSNumber *count = [tableClass aggregate:@"count(*)" where:nil arguments:nil];
                LOGD(@"%@ : %lld -> %@", key, (count.longLongValue + obj.longLongValue), count);
            }
        }];
#endif
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber *orderedDataCount = [ExploreOrderedData aggregate:@"count(*)" where:nil arguments:nil];
        NSNumber *articleCount = [Article aggregate:@"count(*)" where:nil arguments:nil];
//        NSNumber *threadCount = [Thread aggregate:@"count(*)" where:nil arguments:nil];
        NSNumber *commentCount = [Comment aggregate:@"count(*)" where:nil arguments:nil];
        NSNumber *cardCount = [Card aggregate:@"count(*)" where:nil arguments:nil];
        NSNumber *wapDataCount = [WapData aggregate:@"count(*)" where:nil arguments:nil];
//        NSNumber *liveCount = [Live aggregate:@"count(*)" where:nil arguments:nil];
        NSNumber *userDataCount = [TTUserData aggregate:@"count(*)" where:nil arguments:nil];
        
        LOGD(@"%@ : %@", @"ExploreOrderedData", orderedDataCount);
        LOGD(@"%@ : %@", @"Article", articleCount);
        LOGD(@"%@ : %@", @"Thread", threadCount);
        LOGD(@"%@ : %@", @"Comment", commentCount);
        LOGD(@"%@ : %@", @"Card", cardCount);
        LOGD(@"%@ : %@", @"WapData", wapDataCount);
//        LOGD(@"%@ : %@", @"Live", liveCount);
        LOGD(@"%@ : %@", @"TTUserData", userDataCount);
        
        NSTimeInterval t2 = CFAbsoluteTimeGetCurrent();
        LOGD(@"DB aggregate cost: %f", t2 - t1);
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:orderedDataCount forKey:@"order_data_count"];
        [dict setValue:articleCount forKey:@"article_count"];
//        [dict setValue:threadCount forKey:@"thread_count"];
        [dict setValue:commentCount forKey:@"comment_count"];
        [dict setValue:cardCount forKey:@"card_count"];
        [dict setValue:wapDataCount forKey:@"wap_count"];
//        [dict setValue:liveCount forKey:@"live_count"];
        [dict setValue:userDataCount forKey:@"user_data_count"];
        [dict setValue:@((t2 - t1)*1000) forKey:@"cost"];
        [dict setValue:@(dbSize) forKey:@"db_size"];
        
        [Answers logCustomEventWithName:@"news_db" customAttributes:dict];
        
        [[TTMonitor shareManager] trackService:@"news_db_size" value:@(dbSize) extra:nil];
    });
}

+ (NSString *)primaryIDFromDictionary:(NSDictionary *)dictionary {
    NSString *uniqueID = [dictionary stringValueForKey:@"uniqueID" defaultValue:@""];
    NSString *categoryID = [dictionary stringValueForKey:@"categoryID" defaultValue:@""];
    NSString *concernID = [dictionary stringValueForKey:@"concernID" defaultValue:@""];
    NSInteger listType = [dictionary tt_integerValueForKey:@"listType"]; //必须作为主键的一部分，用于区分不同列表的ExploreOrderedData，避免UI等相关数据覆盖问题
    NSInteger listLocation = [dictionary tt_intValueForKey:@"listLocation"];
    NSString *adId = [dictionary stringValueForKey:@"ad_id" defaultValue:@""];
    NSString *primaryID = [NSString stringWithFormat:@"%@%@%@%lu%lu%@", uniqueID, categoryID, concernID, (unsigned long)listType, (unsigned long)listLocation, adId];
    return primaryID;
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    NSString *primaryID = [self primaryIDFromDictionary:dictionary];
    
    ExploreOrderedData *object = [ExploreOrderedData objectForPrimaryKey:primaryID];
    if (!object) {
        object = [super objectWithDictionary:dictionary];
        object.isFirstCached = YES;
    } else {
        [object updateWithDictionary:dictionary];
        object.isFirstCached = NO;
    }
    
    object.uniqueID = [dictionary stringValueForKey:@"uniqueID" defaultValue:@""];
    object.adIDStr = [dictionary stringValueForKey:@"ad_id" defaultValue:nil];
    object.adID = @([dictionary tt_longlongValueForKey:@"ad_id"]);
    
    object.primaryID = primaryID;
    
    id itemId = [dictionary valueForKey:@"item_id"]?:dictionary[@"itemID"];
    if (itemId) {
        object.itemID = [NSString stringWithFormat:@"%@", itemId];
    } else {
        object.itemID = @"";
    }
    
    NSNumber *uniqueIDInNumber = @([object.uniqueID longLongValue]);
    
    ExploreOrderedDataCellType cellType = object.cellType;
    BOOL unSupportType = NO;
    switch (cellType) {
        case ExploreOrderedDataCellTypeArticle:
        case ExploreOrderedDataCellTypeAppDownload:
        {
            NSString *primaryID = [Article primaryIDByUniqueID:[object.uniqueID longLongValue] itemID:object.itemID adID:object.adIDStr];
            
            Article *article = [Article updateWithDictionary:dictionary forPrimaryKey:primaryID];
            
            object.article = article;
        }
            break;
            
//        case ExploreOrderedDataCellTypeThread:
//        {
//            NSString *threadId = [dictionary tt_stringValueForKey:@"thread_id"];
//            Thread *thread = [Thread updateWithDictionary:dictionary threadId:threadId parentPrimaryKey:object.primaryID];
//
//            NSDictionary* remoteForwardInfo = [dictionary tt_dictionaryValueForKey:@"forward_info"];
//            if ([remoteForwardInfo objectForKey:@"forward_count"]) { //避免server未下发导致置0
//                thread.actionDataModel.repostCount = [remoteForwardInfo tt_longValueForKey:@"forward_count"];
//            }
//            if ([dictionary objectForKey:@"comment_count"]) { //避免server未下发导致置0
//                thread.actionDataModel.commentCount = [dictionary tt_longValueForKey:@"comment_count"];
//            }
//            object.thread = thread;
//        }
//            break;
            
        case ExploreOrderedDataCellTypeWeb:
        {
            WapData *wapData = [WapData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.wapData = wapData;
        }
            break;
            
        case ExploreOrderedDataCellTypeRN:
        case ExploreOrderedDataCellTypeInterestGuide:
        case ExploreOrderedDataCellTypeDynamicRN:
        {
            RNData *rnData = [RNData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.rnData = rnData;
        }
            break;
            
        case ExploreOrderedDataCellTypeStock:
        {
            StockData *stockData = [StockData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.stockData = stockData;
        }
            break;
            
//        case ExploreOrderedDataCellTypeLive:
//        {
//            Live *live = [Live updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.live = live;
//        }
//            break;
            
        case ExploreOrderedDataCellTypeHuoShan:
        {
            HuoShan *huoshan = [HuoShan updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.huoShan = huoshan;
        }
            break;
            
        case ExploreOrderedDataCellTypeCard:
        {
            Card *card = [Card updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.card = card;
        }
            break;
            
        case ExploreOrderedDataCellTypeLastRead:
        {
            LastRead *lastRead = [LastRead updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.lastRead = lastRead;
        }
            break;
            
        case ExploreOrderedDataCellTypeLianZai:
        {
            LianZai *lianzai = [LianZai updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.lianZai = lianzai;
        }
            break;
            
        case ExploreOrderedDataCellTypeBook:
        {
            Book *book = [Book updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.book = book;
        }
            break;
            
//        case ExploreOrderedWenDaInviteCellType:
//        {
//            WenDaInviteData *wenDaInviteData = [WenDaInviteData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.wenDaInviteData = wenDaInviteData;
//        }
//            break;
//
//        case ExploreOrderedWenDaCategoryBaseCell:
//        {
//            NSDictionary *json = [ExploreOrderedData wendaBaseDicParse:dictionary];
//            WenDaBaseData *wenDaBaseData = [WenDaBaseData updateWithDictionary:json forPrimaryKey:uniqueIDInNumber];
//            wenDaBaseData.showDislike = @(1);
//            wenDaBaseData.showBottomSeparator = @(1);
//            object.wendaBaseData = wenDaBaseData;
//        }
//            break;
//
//        case ExploreOrderedWenDaCategoryHeaderInfoCell:
//        {
//            WDHeaderInfoCellData *wenDaHeaderInfoCellData = [WDHeaderInfoCellData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.wenDaHeaderInfoCellData = wenDaHeaderInfoCellData;
//        }
//            break;
            
        case ExploreOrderedAddToFirstPageCellType:
        {
            TTCategoryAddToFirstPageData * addModel = [TTCategoryAddToFirstPageData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            if (addModel) {
                addModel.showBottomSeparator = @(NO);
                object.addToFirstPageData = addModel;
            }
        }
            break;
            
        case ExploreOrderedDataCellTypeComment:
        {
            Comment *comment = [Comment updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.comment = comment;
        }
            break;
//        case ExploreOrderedDataCellTypeRecommendUser:
//        {
//            RecommendUserCardsData *recommendUserCardsData = [RecommendUserCardsData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.recommendUserCardsData = recommendUserCardsData;
//        }
//            break;
            
        case ExploreOrderedDataCellTypeShortVideo_AD:
        case ExploreOrderedDataCellTypeShortVideo:
        {
            NSString *primaryID = [TSVShortVideoOriginalData primaryIDByUniqueID:[object.uniqueID longLongValue] listType:object.listType];
            TSVShortVideoOriginalData *shortVideoOriginalData = [TSVShortVideoOriginalData updateWithDictionary:dictionary forPrimaryKey:primaryID];
            object.shortVideoOriginalData = shortVideoOriginalData;
        }
            break;
        case ExploreOrderedDataCellTypeWendaAnswer:
        case ExploreOrderedDataCellTypeWendaQuestion:
        {
            TTWenda *wenda = [TTWenda updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.ttWenda = wenda;
        }
            break;
        case ExploreOrderedDataCellTypeHorizontalCard:
        {
            HorizontalCard *horizontalCard = [HorizontalCard updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.horizontalCard = horizontalCard;
        }
            break;
        case ExploreOrderedDataCellTypeResurface:
        {
            ResurfaceData *resurface = [ResurfaceData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.resurface = resurface;
        }
            break;
//        case ExploreOrderedDataCellTypeRecommendUserLargeCard:
//        {
//            RecommendUserLargeCardData *recommendUserLargeCardData = [RecommendUserLargeCardData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.recommendUserLargeCardData = recommendUserLargeCardData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeHashtag:
//        {
//            TTHashtagCardData *hashtagData = [TTHashtagCardData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.hashtagData = hashtagData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeMomentsRecommendUser:
//        {
//            MomentsRecommendUserData *momentsRecommendUserData = [MomentsRecommendUserData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.momentsRecommendUserData = momentsRecommendUserData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeFantasyCard:
//        {
//            FantasyCardData *fantasyCardData = [FantasyCardData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.fantasyCardData = fantasyCardData;
//        }
//            break;
        case ExploreOrderedDataCellTypeLoadMoreTip:
        {
            TTExploreLoadMoreTipData *loadmoreTipData = [TTExploreLoadMoreTipData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
            object.loadmoreTipData = loadmoreTipData;
        }
            break;
//        case ExploreOrderedDataCellTypeSurveyList:
//        {
//            SurveyListData *surveyListData = [SurveyListData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.surveyListData = surveyListData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeSurveyPair:
//        {
//            SurveyPairData *surveyPairData = [SurveyPairData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//            object.surveyPairData = surveyPairData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeCommentRepost:
//        {
//            NSMutableDictionary *rawData = [[dictionary tt_dictionaryValueForKey:@"raw_data"] mutableCopy];
//            if (rawData != nil) {
//                [rawData setValue:[dictionary objectForKey:@"filter_words"] forKey:@"filter_words"];
//                [rawData setValue:object.uniqueID forKey:@"uniqueID"];
//                NSString *idStr = uniqueIDInNumber.stringValue;
//                FRCommentRepost *cellModel = [FRCommentRepost updateWithDictionary:rawData commentId:idStr parentPrimaryKey:object.primaryID];
//
//                NSDictionary *actionDic = [rawData valueForKeyPath:@"comment_base.action"];
//                if ([actionDic isKindOfClass:[NSDictionary class]]) {
//                    if ([actionDic objectForKey:@"forward_count"]) {
//                        cellModel.actionDataModel.repostCount = [actionDic tt_integerValueForKey:@"forward_count"];
//                    }
//                    if ([actionDic objectForKey:@"comment_count"]) {
//                        cellModel.actionDataModel.commentCount = [actionDic tt_integerValueForKey:@"comment_count"];
//                    }
//                }
//
//                object.commentRepostModel = cellModel;
//            } else {
//                unSupportType = YES;
//            }
//        }
//            break;
        case ExploreOrderedDataCellTypeShortVideoRecommendUserCard:
        {
            object.tsvRecUserCardOriginalData = [TSVRecUserCardOriginalData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
        }
            break;
        case ExploreOrderedDataCellTypeShortVideoActivityEntrance:
        {
            object.tsvActivityEntranceOriginalData = [TSVActivityEntranceOriginalData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
        }
            break;
        case ExploreOrderedDataCellTypeShortVideoActivityBanner:
        {
            object.tsvActivityBannerOriginalData = [TSVActivityBannerOriginalData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
        }
            break;
//        case ExploreOrderedDataCellTypeShortVideoStory:
//        {
//            object.tsvStoryOriginalData = [TSVStoryOriginalData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//        }
//            break;
//        case ExploreOrderedDataCellTypeRedpacketRecommendUser:
//        {
//            object.recommendRedpacketData = [RecommendRedpacketData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//        }
//            break;
//        case ExploreOrderedDataCellTypeXiguaLive:
//        {
//            object.xiguaLiveModel = [TTXiguaLiveModel updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//        }
//            break;
//        case ExploreOrderedDataCellTypeXiguaLiveHorizontal:
//        {
//            object.xiguaLiveCardHorizontal = [TTXiguaLiveCardHorizontal updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//        }
//            break;
//        case ExploreOrderedDataCellTypeXiguaLiveRecommend:
//        {
//            object.xiguaLiveRecommendUser = [TTXiguaLiveRecommendUser updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
//        }
//            break;
        case ExploreOrderedDataCellTypeShortVideoPublishStatus:
        {
            object.tsvPublishStatusOriginalData = [TSVPublishStatusOriginalData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
        }
            break;
//        case ExploreOrderedDataCellTypeRecommendUserStoryCard:
//        {
//            object.recommendUserStoryCardData = [RecommendUserStoryCardData updateWithDictionary:dictionary uniqueID:uniqueIDInNumber parentPrimaryKey:object.primaryID];
//        }
//            break;
//        case ExploreOrderedDataCellTypeRecommendStoryCoverCard:
//        {
//            object.recommendUserStoryCoverCardData = [RecommendStoryCoverCardData updateWithDictionary:dictionary uniqueID:uniqueIDInNumber parentPrimaryKey:object.primaryID];
//        }
//            break;
//        case ExploreOrderedDataCellTypeTopPopularHashtag:
//        {
//            object.popularHashtagData = [PopularHashtagData updateWithDictionary:dictionary uniqueID:object.uniqueID];
//        }
//            break;
        case ExploreOrderedDataCellTypeHotNews:
        {
            object.hotNewsData = [TTHotNewsData updateWithDictionary:dictionary forPrimaryKey:uniqueIDInNumber];
        }
            break;
        default:
        {
            //exploreOriginData = nil;
            unSupportType = YES;
        }
    }
    
    if (unSupportType) {
        NSLog(@"%@", [NSString stringWithFormat:@"in %s, data type not supported", __PRETTY_FUNCTION__]);
        [[TTMonitor shareManager] trackService:@"unknown_cell_type" status:1 extra:@{@"type":@(cellType)}];
    }
    
    return object;
}

- (void)save {
    [super save];
    [self.originalData save];
}

- (ExploreOriginalData *)originalData {
    if (!self.uniqueID) {
        return nil;
    }
    
    ExploreOrderedDataCellType cellType = self.cellType;
    ExploreOriginalData *exploreOriginData = nil;
    
    switch (cellType) {
        case ExploreOrderedDataCellTypeArticle:
        case ExploreOrderedDataCellTypeAppDownload:
        {
            exploreOriginData = self.article;
        }
            break;
            
        case ExploreOrderedDataCellTypeThread:
        {
            exploreOriginData = self.thread;
        }
            break;
            
        case ExploreOrderedDataCellTypeWeb:
        {
            exploreOriginData = self.wapData;
        }
            break;
            
        case ExploreOrderedDataCellTypeRN:
        case ExploreOrderedDataCellTypeInterestGuide:
        case ExploreOrderedDataCellTypeDynamicRN:
        {
            exploreOriginData = self.rnData;
        }
            break;
            
        case ExploreOrderedDataCellTypeStock:
        {
            exploreOriginData = self.stockData;
        }
            break;
            
//        case ExploreOrderedDataCellTypeLive:
//        {
//            exploreOriginData = self.live;
//        }
//            break;
            
        case ExploreOrderedDataCellTypeHuoShan:
        {
            exploreOriginData = self.huoShan;
        }
            break;
            
        case ExploreOrderedDataCellTypeCard:
        {
            exploreOriginData = self.card;
        }
            break;
            
        case ExploreOrderedDataCellTypeLastRead:
        {
            exploreOriginData = self.lastRead;
        }
            break;
            
        case ExploreOrderedDataCellTypeLianZai:
        {
            exploreOriginData = self.lianZai;
        }
            break;
            
        case ExploreOrderedDataCellTypeBook:
        {
            exploreOriginData = self.book;
        }
            break;
            
        case ExploreOrderedAddToFirstPageCellType:
        {
            exploreOriginData = self.addToFirstPageData;
        }
            break;
            
        case ExploreOrderedDataCellTypeComment:
        {
            exploreOriginData = self.comment;
        }
            break;
//        case ExploreOrderedDataCellTypeRecommendUser:
//        {
//            exploreOriginData = self.recommendUserCardsData;
//        }
//            break;
        case ExploreOrderedDataCellTypeShortVideo_AD:
        case ExploreOrderedDataCellTypeShortVideo:
        {
            exploreOriginData = self.shortVideoOriginalData;
        }
            break;
        case ExploreOrderedDataCellTypeWendaAnswer:
        case ExploreOrderedDataCellTypeWendaQuestion:
        {
            exploreOriginData = self.ttWenda;
        }
            break;
        case ExploreOrderedDataCellTypeHorizontalCard:
        {
            exploreOriginData = self.horizontalCard;
        }
            break;
        case ExploreOrderedDataCellTypeResurface:
        {
            exploreOriginData = self.resurface;
        }
            break;
//        case ExploreOrderedDataCellTypeRecommendUserLargeCard:
//        {
//            exploreOriginData = self.recommendUserLargeCardData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeMomentsRecommendUser:
//        {
//            exploreOriginData = self.momentsRecommendUserData;
//        }
//            break;
        case ExploreOrderedDataCellTypeEssayAD:
        {
            
        }
            break;
//        case ExploreOrderedDataCellTypeFantasyCard:
//        {
//            exploreOriginData = self.fantasyCardData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeTopPopularHashtag:
//        {
//            exploreOriginData = self.popularHashtagData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeSurveyList:
//        {
//            exploreOriginData = self.surveyListData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeSurveyPair:
//        {
//            exploreOriginData = self.surveyPairData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeCommentRepost:
//        {
//            exploreOriginData = self.commentRepostModel;
//        }
//            break;
        case ExploreOrderedDataCellTypeShortVideoRecommendUserCard:
        {
            exploreOriginData = self.tsvRecUserCardOriginalData;
        }
            break;
        case ExploreOrderedDataCellTypeShortVideoActivityEntrance:
        {
            exploreOriginData = self.tsvActivityEntranceOriginalData;
        }
            break;
        case ExploreOrderedDataCellTypeShortVideoActivityBanner:
        {
            exploreOriginData = self.tsvActivityBannerOriginalData;
        }
            break;
//        case ExploreOrderedDataCellTypeShortVideoStory:
//        {
//            exploreOriginData = self.tsvStoryOriginalData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeHashtag:
//        {
//            exploreOriginData = self.hashtagData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeRedpacketRecommendUser:
//        {
//            exploreOriginData = self.recommendRedpacketData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeXiguaLive:
//        {
//            exploreOriginData = self.xiguaLiveModel;
//        }
//            break;
//        case ExploreOrderedDataCellTypeXiguaLiveHorizontal:
//        {
//            exploreOriginData = self.xiguaLiveCardHorizontal;
//        }
//            break;
//        case ExploreOrderedDataCellTypeXiguaLiveRecommend:
//        {
//            exploreOriginData = self.xiguaLiveRecommendUser;
//        }
//            break;
        case ExploreOrderedDataCellTypeShortVideoPublishStatus:
        {
            exploreOriginData = self.tsvPublishStatusOriginalData;
        }
            break;
//        case ExploreOrderedDataCellTypeRecommendUserStoryCard:
//        {
//            exploreOriginData = self.recommendUserStoryCardData;
//        }
//            break;
//        case ExploreOrderedDataCellTypeRecommendStoryCoverCard:
//        {
//            exploreOriginData = self.recommendUserStoryCoverCardData;
//        }
//            break;
        case ExploreOrderedDataCellTypeLoadMoreTip:
        {
            exploreOriginData = self.loadmoreTipData;
        }
            break;
        case ExploreOrderedDataCellTypeHotNews:
        {
            exploreOriginData = self.hotNewsData;
        }
            break;
        default:
        {
            exploreOriginData = nil;
            NSLog(@"%@", [NSString stringWithFormat:@"in %s, data type not supported", __PRETTY_FUNCTION__]);
        }
    }
    
    return exploreOriginData;
}

#pragma mark --

+ (void)removeAllEntities {
    [super removeAllEntities];
    [Article removeAllEntities];
//    [Thread removeAllEntities];
    [WapData removeAllEntities];
    [StockData removeAllEntities];
//    [Live removeAllEntities];
    [HuoShan removeAllEntities];
    [Card removeAllEntities];
    [LianZai removeAllEntities];
    [RNData removeAllEntities];
//    [WenDaInviteData removeAllEntities];
//    [WenDaBaseData removeAllEntities];
//    [WDHeaderInfoCellData removeAllEntities];
    [Book removeAllEntities];
    [Comment removeAllEntities];
    [HorizontalCard removeAllEntities];
    [TSVShortVideoOriginalData removeAllEntities];
    [TTWenda removeAllEntities];
//    [RecommendUserCardsData removeAllEntities];
    [ResurfaceData removeAllEntities];
    [TSVRecUserCardOriginalData removeAllEntities];
//    [TTXiguaLiveModel removeAllEntities];
//    [TTXiguaLiveCardHorizontal removeAllEntities];
//    [TTXiguaLiveRecommendUser removeAllEntities];
    [TSVActivityEntranceOriginalData removeAllEntities];
    [TSVActivityBannerOriginalData removeAllEntities];
    [TSVPublishStatusOriginalData removeAllEntities];
//    [TSVStoryOriginalData removeAllEntities];
    [TTHotNewsData removeAllEntities];
}

#pragma mark - Getters && Setters
- (long long)itemIndex
{
    NSNumber *num = objc_getAssociatedObject(self, @selector(itemIndex));
    return [num longLongValue];
}

- (void)setItemIndex:(long long)itemIndex
{
    objc_setAssociatedObject(self, @selector(itemIndex), @(itemIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)debugInfo
{
    NSString *debugInfo = objc_getAssociatedObject(self, @selector(debugInfo));
    return debugInfo;
}

- (void)setDebugInfo:(NSString *)debugInfo
{
    objc_setAssociatedObject(self, @selector(debugInfo), debugInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTLayOutCellBaseModel *)cellLayOut
{
    return objc_getAssociatedObject(self, @selector(cellLayOut));
}

- (void)setCellLayOut:(TTLayOutCellBaseModel *)cellLayOut {
    objc_setAssociatedObject(self, @selector(cellLayOut), cellLayOut, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (UGCBaseCellLayoutModel *)ugcCellLayout {
//    return objc_getAssociatedObject(self, @selector(ugcCellLayout));
//}
//
//- (void)setUgcCellLayout:(UGCBaseCellLayoutModel *)ugcCellLayout {
//    objc_setAssociatedObject(self, @selector(ugcCellLayout), ugcCellLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (FRCommentRepost *)commentRepostModel {
//    FRCommentRepost *result = objc_getAssociatedObject(self, @selector(commentRepostModel));
//    if (self.cellType == ExploreOrderedDataCellTypeCommentRepost) {
//        if (!result && self.uniqueID) {
//            result = [FRCommentRepost objectForCommentId:self.uniqueID parentPrimaryKey:self.primaryID];
//            objc_setAssociatedObject(self, @selector(commentRepostModel), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(commentRepostModel), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setCommentRepostModel:(FRCommentRepost *)commentRepostModel {
//    objc_setAssociatedObject(self, @selector(commentRepostModel), commentRepostModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (void)setUgcRecommendDict:(NSDictionary *)ugcRecommendDict {
    objc_setAssociatedObject(self, @selector(ugcRecommendDict), ugcRecommendDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)ugcRecommendDict {
    return objc_getAssociatedObject(self, @selector(ugcRecommendDict));
}

//- (Thread *)thread {
//    Thread *result = objc_getAssociatedObject(self, @selector(thread));
//    if (self.cellType == ExploreOrderedDataCellTypeThread) {
//        if (!result && self.uniqueID) {
//            result = [Thread objectForThreadId:self.uniqueID parentPrimaryKey:self.primaryID];
//            objc_setAssociatedObject(self, @selector(thread), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(thread), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setThread:(Thread *)thread
//{
//    objc_setAssociatedObject(self, @selector(thread), thread, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (NSNumber *)maxTextLine {
    if (_maxTextLine == nil || _maxTextLine.integerValue == 0) {
        if ([self.originalData isKindOfClass:[Comment class]]) {
            return self.comment.commentExtra[@"max_text_line"];
        }
    }
    return _maxTextLine;
}

- (NSNumber *)defaultTextLine {
    if (_defaultTextLine == nil || _defaultTextLine.integerValue == 0) {
        if ([self.originalData isKindOfClass:[Comment class]]) {
            return self.comment.commentExtra[@"default_text_line"];
        }
    }
    return _defaultTextLine;
}

- (WapData *)wapData {
    WapData *result = objc_getAssociatedObject(self, @selector(wapData));
    if (self.cellType == ExploreOrderedDataCellTypeWeb) {
        if (!result && self.uniqueID) {
            result = [WapData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(wapData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(wapData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setWapData:(WapData *)wapData {
    objc_setAssociatedObject(self, @selector(wapData), wapData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (StockData *)stockData {
    StockData *result = objc_getAssociatedObject(self, @selector(stockData));
    if (self.cellType == ExploreOrderedDataCellTypeStock) {
        if (!result && self.uniqueID) {
            result = [StockData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(stockData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(stockData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setStockData:(StockData *)stockData {
    objc_setAssociatedObject(self, @selector(stockData), stockData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (Live *)live {
//    Live *result = objc_getAssociatedObject(self, @selector(live));
//    if (self.cellType == ExploreOrderedDataCellTypeLive) {
//        if (!result && self.uniqueID) {
//            result = [Live objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(live), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(live), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setLive:(Live *)live {
//    objc_setAssociatedObject(self, @selector(live), live, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (HuoShan *)huoShan {
    HuoShan *result = objc_getAssociatedObject(self, @selector(huoShan));
    if (self.cellType == ExploreOrderedDataCellTypeHuoShan) {
        if (!result && self.uniqueID) {
            result = [HuoShan objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(huoShan), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(huoShan), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setHuoShan:(HuoShan *)huoShan {
    objc_setAssociatedObject(self, @selector(huoShan), huoShan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Card *)card {
    Card *result = objc_getAssociatedObject(self, @selector(card));
    if (self.cellType == ExploreOrderedDataCellTypeCard) {
        if (!result && self.uniqueID) {
            result = [Card objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(card), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(card), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setCard:(Card *)card {
    objc_setAssociatedObject(self, @selector(card), card, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LastRead *)lastRead {
    LastRead *result = objc_getAssociatedObject(self, @selector(lastRead));
    if (self.cellType == ExploreOrderedDataCellTypeLastRead) {
        if (!result && self.uniqueID) {
            result = [LastRead objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(lastRead), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(lastRead), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setLastRead:(LastRead *)lastRead {
    objc_setAssociatedObject(self, @selector(lastRead), lastRead, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LianZai *)lianZai {
    LianZai *result = objc_getAssociatedObject(self, @selector(lianZai));
    if (self.cellType == ExploreOrderedDataCellTypeLianZai) {
        if (!result && self.uniqueID) {
            result = [LianZai objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(lianZai), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(lianZai), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setLianZai:(LianZai *)lianZai {
    objc_setAssociatedObject(self, @selector(lianZai), lianZai, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RNData *)rnData {
    RNData *result = objc_getAssociatedObject(self, @selector(rnData));
    if (self.cellType == ExploreOrderedDataCellTypeRN ||
        self.cellType == ExploreOrderedDataCellTypeInterestGuide ||
        self.cellType == ExploreOrderedDataCellTypeDynamicRN) {
        if (!result && self.uniqueID) {
            result = [RNData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(rnData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(rnData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setRnData:(RNData *)rnData {
    objc_setAssociatedObject(self, @selector(rnData), rnData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (WenDaInviteData *)wenDaInviteData
//{
//    WenDaInviteData *result = objc_getAssociatedObject(self, @selector(wenDaInviteData));
//    if (self.cellType == ExploreOrderedWenDaInviteCellType) {
//        if (!result && self.uniqueID) {
//            result = [WenDaInviteData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(wenDaInviteData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(wenDaInviteData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setWenDaInviteData:(WenDaInviteData *)wenDaInviteData {
//    objc_setAssociatedObject(self, @selector(wenDaInviteData), wenDaInviteData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (WDHeaderInfoCellData *)wenDaHeaderInfoCellData
//{
//    WDHeaderInfoCellData *result = objc_getAssociatedObject(self, @selector(wenDaHeaderInfoCellData));
//    if (self.cellType == ExploreOrderedWenDaCategoryHeaderInfoCell) {
//        if (!result && self.uniqueID) {
//            result  = [WDHeaderInfoCellData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(wenDaHeaderInfoCellData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(wenDaHeaderInfoCellData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setWenDaHeaderInfoCellData:(WDHeaderInfoCellData *)wenDaHeaderInfoCellData {
//    objc_setAssociatedObject(self, @selector(wenDaHeaderInfoCellData), wenDaHeaderInfoCellData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (WenDaBaseData *)wendaBaseData
//{
//    WenDaBaseData *result = objc_getAssociatedObject(self, @selector(wendaBaseData));
//    if (self.cellType == ExploreOrderedWenDaCategoryBaseCell) {
//        if (!result && self.uniqueID) {
//            result = [WenDaBaseData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(wendaBaseData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else {
//        result = nil;
//        objc_setAssociatedObject(self, @selector(wendaBaseData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//
//    return result;
//}
//
//- (void)setWendaBaseData:(WenDaBaseData *)wendaBaseData {
//    objc_setAssociatedObject(self, @selector(wendaBaseData), wendaBaseData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}


- (Book *)book {
    Book *result = objc_getAssociatedObject(self, @selector(book));
    if (self.cellType == ExploreOrderedDataCellTypeBook) {
        if (!result && self.uniqueID) {
            result = [Book objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(book), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(book), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setBook:(Book *)book {
    objc_setAssociatedObject(self, @selector(book), book, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Comment *)comment {
    Comment *result = objc_getAssociatedObject(self, @selector(comment));
    if (self.cellType == ExploreOrderedDataCellTypeComment) {
        if (!result && self.uniqueID) {
            result = [Comment objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(comment), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(comment), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setComment:(Comment *)comment {
    objc_setAssociatedObject(self, @selector(comment), comment, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (RecommendUserCardsData *)recommendUserCardsData {
//    RecommendUserCardsData *result = objc_getAssociatedObject(self, @selector(recommendUserCardsData));
//    if (self.cellType == ExploreOrderedDataCellTypeRecommendUser) {
//        if (!result && self.uniqueID) {
//            result = [RecommendUserCardsData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(recommendUserCardsData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(recommendUserCardsData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setRecommendUserCardsData:(RecommendUserCardsData *)recommendUserCardsData {
//    objc_setAssociatedObject(self, @selector(recommendUserCardsData), recommendUserCardsData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (TTCategoryAddToFirstPageData *)addToFirstPageData
{
    TTCategoryAddToFirstPageData *result = objc_getAssociatedObject(self, @selector(addToFirstPageData));
    if (!result && self.uniqueID && self.cellType == ExploreOrderedAddToFirstPageCellType) {
        result = [TTCategoryAddToFirstPageData objectForPrimaryKey:@([self.uniqueID longLongValue])];
        objc_setAssociatedObject(self, @selector(addToFirstPageData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setAddToFirstPageData:(TTCategoryAddToFirstPageData *)addToFirstPageData {
    objc_setAssociatedObject(self, @selector(addToFirstPageData), addToFirstPageData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TSVShortVideoOriginalData *)shortVideoOriginalData
{
    TSVShortVideoOriginalData *result = objc_getAssociatedObject(self, @selector(shortVideoOriginalData));
    if (self.cellType == ExploreOrderedDataCellTypeShortVideo ||
        self.cellType == ExploreOrderedDataCellTypeShortVideo_AD) {
        if (!result && self.uniqueID) {
            result = [TSVShortVideoOriginalData objectForPrimaryKey:[TSVShortVideoOriginalData primaryIDByUniqueID:[self.uniqueID longLongValue] listType:self.listType]];
            objc_setAssociatedObject(self, @selector(shortVideoOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(shortVideoOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData {
    objc_setAssociatedObject(self, @selector(shortVideoOriginalData), shortVideoOriginalData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTWenda *)ttWenda {
    TTWenda *result = objc_getAssociatedObject(self, @selector(ttWenda));
    if (self.cellType == ExploreOrderedDataCellTypeWendaAnswer || self.cellType == ExploreOrderedDataCellTypeWendaQuestion) {
        if (!result && self.uniqueID) {
            result = [TTWenda objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(ttWenda), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else {
        result = nil;
        objc_setAssociatedObject(self, @selector(ttWenda), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setTtWenda:(TTWenda *)ttWenda {
    objc_setAssociatedObject(self, @selector(ttWenda), ttWenda, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HorizontalCard *)horizontalCard
{
    HorizontalCard *result = objc_getAssociatedObject(self, @selector(horizontalCard));
    if (self.cellType == ExploreOrderedDataCellTypeHorizontalCard) {
        if (!result && self.uniqueID) {
            result = [HorizontalCard objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(horizontalCard), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(horizontalCard), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setHorizontalCard:(HorizontalCard *)horizontalCard {
    objc_setAssociatedObject(self, @selector(horizontalCard), horizontalCard, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ResurfaceData *)resurface
{
    ResurfaceData *result = objc_getAssociatedObject(self, @selector(resurface));
    if (self.cellType == ExploreOrderedDataCellTypeResurface){
        if (!result && self.uniqueID){
            result = [ResurfaceData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(resurface), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }else{
        result = nil;
        objc_setAssociatedObject(self, @selector(resurface), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setResurface:(ResurfaceData *)resurface {
    objc_setAssociatedObject(self, @selector(resurface), resurface, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


//- (RecommendUserLargeCardData *)recommendUserLargeCardData {
//    RecommendUserLargeCardData *result = objc_getAssociatedObject(self, @selector(recommendUserLargeCardData));
//    if (self.cellType == ExploreOrderedDataCellTypeRecommendUserLargeCard) {
//        if (!result && self.uniqueID) {
//            result = [RecommendUserLargeCardData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(recommendUserLargeCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(recommendUserLargeCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setRecommendUserLargeCardData:(RecommendUserLargeCardData *)recommendUserLargeCardData {
//    objc_setAssociatedObject(self, @selector(recommendUserLargeCardData), recommendUserLargeCardData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (RecommendUserStoryCardData *)recommendUserStoryCardData {
//    RecommendUserStoryCardData *result = objc_getAssociatedObject(self, @selector(recommendUserStoryCardData));
//    if (self.cellType == ExploreOrderedDataCellTypeRecommendUserStoryCard) {
//        if (!result && self.uniqueID) {
//            result = [RecommendUserStoryCardData objectForUniqueID:self.uniqueID parentPrimaryKey:self.primaryID];
//            objc_setAssociatedObject(self, @selector(recommendUserStoryCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(recommendUserStoryCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setRecommendUserStoryCardData:(RecommendUserStoryCardData *)recommendUserStoryCardData {
//    objc_setAssociatedObject(self, @selector(recommendUserStoryCardData), recommendUserStoryCardData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (RecommendStoryCoverCardData *)recommendUserStoryCoverCardData {
//
//    RecommendStoryCoverCardData *result = objc_getAssociatedObject(self, @selector(recommendUserStoryCoverCardData));
//    if (self.cellType == ExploreOrderedDataCellTypeRecommendStoryCoverCard) {
//        if (!result && self.uniqueID) {
//
//            result = [RecommendStoryCoverCardData objectForUniqueID:self.uniqueID parentPrimaryKey:self.primaryID];
//            objc_setAssociatedObject(self, @selector(recommendUserStoryCoverCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(recommendUserStoryCoverCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setRecommendUserStoryCoverCardData:(RecommendStoryCoverCardData *)recommendUserStoryCoverCardData {
//    objc_setAssociatedObject(self, @selector(recommendUserStoryCoverCardData), recommendUserStoryCoverCardData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (TTHashtagCardData *)hashtagData {
//    TTHashtagCardData *result = objc_getAssociatedObject(self, @selector(hashtagData));
//    if (self.cellType == ExploreOrderedDataCellTypeHashtag) {
//        if (!result && self.uniqueID) {
//            result = [TTHashtagCardData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(hashtagData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(hashtagData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setHashtagData:(TTHashtagCardData *)hashtagData {
//    objc_setAssociatedObject(self, @selector(hashtagData), hashtagData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (MomentsRecommendUserData *)momentsRecommendUserData {
//    MomentsRecommendUserData *result = objc_getAssociatedObject(self, @selector(momentsRecommendUserData));
//    if (self.cellType == ExploreOrderedDataCellTypeMomentsRecommendUser) {
//        if (!result && self.uniqueID) {
//            result = [MomentsRecommendUserData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(momentsRecommendUserData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(momentsRecommendUserData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setMomentsRecommendUserData:(MomentsRecommendUserData *)momentsRecommendUserData {
//    objc_setAssociatedObject(self, @selector(momentsRecommendUserData), momentsRecommendUserData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (FantasyCardData *)fantasyCardData {
//    FantasyCardData *result = objc_getAssociatedObject(self, @selector(fantasyCardData));
//    if (self.cellType == ExploreOrderedDataCellTypeFantasyCard) {
//        if (!result && self.uniqueID) {
//            result = [FantasyCardData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(fantasyCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(fantasyCardData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}

//- (void)setFantasyCardData:(FantasyCardData *)fantasyCardData {
//    objc_setAssociatedObject(self, @selector(fantasyCardData), fantasyCardData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (TTHotNewsData *)hotNewsData {
    TTHotNewsData *result = objc_getAssociatedObject(self, @selector(hotNewsData));
    if (self.cellType == ExploreOrderedDataCellTypeHotNews) {
        if (!result && self.uniqueID) {
            result = [TTHotNewsData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(hotNewsData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else {
        result = nil;
        objc_setAssociatedObject(self, @selector(hotNewsData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setHotNewsData:(TTHotNewsData *)hotNewsData {
    objc_setAssociatedObject(self, @selector(hotNewsData), hotNewsData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setLoadmoreTipData:(TTExploreLoadMoreTipData *)loadmoreTipData {
    objc_setAssociatedObject(self, @selector(loadmoreTipData), loadmoreTipData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTExploreLoadMoreTipData *)loadmoreTipData {
    TTExploreLoadMoreTipData *result = objc_getAssociatedObject(self, @selector(loadmoreTipData));
    if (self.cellType == ExploreOrderedDataCellTypeLoadMoreTip) {
        if (!result && self.uniqueID) {
            result = [TTExploreLoadMoreTipData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(loadmoreTipData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(loadmoreTipData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

//- (SurveyListData *)surveyListData {
//    SurveyListData *result = objc_getAssociatedObject(self, @selector(surveyListData));
//    if (self.cellType == ExploreOrderedDataCellTypeSurveyList) {
//        if (!result && self.uniqueID) {
//            result = [SurveyListData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(surveyListData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(essayADData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setSurveyListData:(SurveyListData *)surveyListData {
//    objc_setAssociatedObject(self, @selector(surveyListData), surveyListData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (SurveyPairData *)surveyPairData {
//    SurveyPairData *result = objc_getAssociatedObject(self, @selector(surveyPairData));
//    if (self.cellType == ExploreOrderedDataCellTypeSurveyPair) {
//        if (!result && self.uniqueID) {
//            result = [SurveyPairData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(surveyPairData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(surveyPairData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setSurveyPairData:(SurveyPairData *)surveyPairData {
//    objc_setAssociatedObject(self, @selector(surveyPairData), surveyPairData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (FRRedpackStructModel *)redpacketModel {
//    FRRedpackStructModel *result = objc_getAssociatedObject(self, @selector(redpacketModel));
//    if (result) {
//        return result;
//    }
//    if (0 == self.activity.count || ![self.activity.allKeys containsObject:@"redpack"]) {
//        return nil;
//    }
//    result = [[FRRedpackStructModel alloc] initWithDictionary:[self.activity tt_dictionaryValueForKey:@"redpack"]
//                                                        error:nil];
//    objc_setAssociatedObject(self, @selector(redpacketModel), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    return result;
//}
//
//- (void)setRedpacketModel:(FRRedpackStructModel *)redpacketModel {
//    objc_setAssociatedObject(self, @selector(redpacketModel), redpacketModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (TTXiguaLiveModel *)xiguaLiveModel {
//    TTXiguaLiveModel *result = objc_getAssociatedObject(self, @selector(xiguaLiveModel));
//    if (self.cellType == ExploreOrderedDataCellTypeXiguaLive) {
//        if (!result && self.uniqueID) {
//            result = [TTXiguaLiveModel objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(xiguaLiveModel), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    } else {
//        result = nil;
//        objc_setAssociatedObject(self, @selector(xiguaLiveModel), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setXiguaLiveModel:(TTXiguaLiveModel *)xiguaLiveModel {
//    objc_setAssociatedObject(self, @selector(xiguaLiveModel), xiguaLiveModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (TTXiguaLiveRecommendUser *)xiguaLiveRecommendUser {
//    TTXiguaLiveRecommendUser *result = objc_getAssociatedObject(self, @selector(xiguaLiveRecommendUser));
//    if (self.cellType == ExploreOrderedDataCellTypeXiguaLiveRecommend) {
//        if (!result && self.uniqueID) {
//            result = [TTXiguaLiveRecommendUser objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(xiguaLiveRecommendUser), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    } else {
//        result = nil;
//        objc_setAssociatedObject(self, @selector(xiguaLiveRecommendUser), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setXiguaLiveRecommendUser:(TTXiguaLiveRecommendUser *)xiguaLiveRecommendUser {
//    objc_setAssociatedObject(self, @selector(xiguaLiveRecommendUser), xiguaLiveRecommendUser, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (TTXiguaLiveCardHorizontal *)xiguaLiveCardHorizontal {
//    TTXiguaLiveCardHorizontal *result = objc_getAssociatedObject(self, @selector(xiguaLiveCardHorizontal));
//    if (self.cellType == ExploreOrderedDataCellTypeXiguaLiveHorizontal) {
//        if (!result && self.uniqueID) {
//            result = [TTXiguaLiveCardHorizontal objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(xiguaLiveCardHorizontal), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    } else {
//        result = nil;
//        objc_setAssociatedObject(self, @selector(xiguaLiveCardHorizontal), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setXiguaLiveCardHorizontal:(TTXiguaLiveCardHorizontal *)xiguaLiveCardHorizontal {
//    objc_setAssociatedObject(self, @selector(xiguaLiveCardHorizontal), xiguaLiveCardHorizontal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (TSVRecUserCardOriginalData *)tsvRecUserCardOriginalData {
    TSVRecUserCardOriginalData *result = objc_getAssociatedObject(self, @selector(tsvRecUserCardOriginalData));
    if (self.cellType == ExploreOrderedDataCellTypeShortVideoRecommendUserCard) {
        if (!result && self.uniqueID) {
            result = [TSVRecUserCardOriginalData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(tsvRecUserCardOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    else{
        result = nil;
        objc_setAssociatedObject(self, @selector(tsvRecUserCardOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setTsvRecUserCardOriginalData:(TSVRecUserCardOriginalData *)tsvRecUserCardOriginalData {
    objc_setAssociatedObject(self, @selector(tsvRecUserCardOriginalData), tsvRecUserCardOriginalData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TSVPublishStatusOriginalData *)tsvPublishStatusOriginalData {
    TSVPublishStatusOriginalData *result = objc_getAssociatedObject(self, @selector(tsvPublishStatusOriginalData));
    if (self.cellType == ExploreOrderedDataCellTypeShortVideoPublishStatus) {
        if (!result && self.uniqueID) {
            result = [TSVPublishStatusOriginalData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(tsvPublishStatusOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else { 
        result = nil;
        objc_setAssociatedObject(self, @selector(tsvPublishStatusOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setTsvPublishStatusOriginalData:(TSVPublishStatusOriginalData *)tsvPublishStatusOriginalData
{
    objc_setAssociatedObject(self, @selector(tsvPublishStatusOriginalData), tsvPublishStatusOriginalData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TSVActivityEntranceOriginalData *)tsvActivityEntranceOriginalData {
    TSVActivityEntranceOriginalData *result = objc_getAssociatedObject(self, @selector(tsvActivityEntranceOriginalData));
    if (self.cellType == ExploreOrderedDataCellTypeShortVideoActivityEntrance) {
        if (!result && self.uniqueID) {
            result = [TSVActivityEntranceOriginalData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(tsvActivityEntranceOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else {
        result = nil;
        objc_setAssociatedObject(self, @selector(tsvActivityEntranceOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setTsvActivityEntranceOriginalData:(TSVActivityEntranceOriginalData *)tsvActivityEntranceOriginalData {
    objc_setAssociatedObject(self, @selector(tsvActivityEntranceOriginalData), tsvActivityEntranceOriginalData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TSVActivityBannerOriginalData *)tsvActivityBannerOriginalData {
    TSVActivityBannerOriginalData *result = objc_getAssociatedObject(self, @selector(tsvActivityBannerOriginalData));
    if (self.cellType == ExploreOrderedDataCellTypeShortVideoActivityBanner) {
        if (!result && self.uniqueID) {
            result = [TSVActivityBannerOriginalData objectForPrimaryKey:@([self.uniqueID longLongValue])];
            objc_setAssociatedObject(self, @selector(tsvActivityBannerOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else {
        result = nil;
        objc_setAssociatedObject(self, @selector(tsvActivityBannerOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setTsvActivityBannerOriginalData:(TSVActivityBannerOriginalData *)tsvActivityBannerOriginalData {
    objc_setAssociatedObject(self, @selector(tsvActivityBannerOriginalData), tsvActivityBannerOriginalData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (TSVStoryOriginalData *)tsvStoryOriginalData
//{
//    TSVStoryOriginalData *result = objc_getAssociatedObject(self, @selector(tsvStoryOriginalData));
//    if (self.cellType == ExploreOrderedDataCellTypeShortVideoStory) {
//        if (!result && self.uniqueID) {
//            result = [TSVStoryOriginalData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(tsvStoryOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    }
//    else{
//        result = nil;
//        objc_setAssociatedObject(self, @selector(tsvStoryOriginalData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setTsvStoryOriginalData:(TSVStoryOriginalData *)tsvStoryOriginalData
//{
//    objc_setAssociatedObject(self, @selector(tsvStoryOriginalData), tsvStoryOriginalData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

//- (RecommendRedpacketData *)recommendRedpacketData {
//    RecommendRedpacketData *result = objc_getAssociatedObject(self, @selector(recommendRedpacketData));
//    if (self.cellType == ExploreOrderedDataCellTypeRedpacketRecommendUser) {
//        if (!result && self.uniqueID) {
//            result = [RecommendRedpacketData objectForPrimaryKey:@([self.uniqueID longLongValue])];
//            objc_setAssociatedObject(self, @selector(recommendRedpacketData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    } else {
//        result = nil;
//        objc_setAssociatedObject(self, @selector(recommendRedpacketData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setRecommendRedpacketData:(RecommendRedpacketData *)recommendRedpacketData {
//    objc_setAssociatedObject(self, @selector(recommendRedpacketData), recommendRedpacketData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (PopularHashtagData *)popularHashtagData {
//    PopularHashtagData *result = objc_getAssociatedObject(self, @selector(popularHashtagData));
//    if (self.cellType == ExploreOrderedDataCellTypeTopPopularHashtag) {
//        if (!result && self.uniqueID) {
//            result = [PopularHashtagData objectForCategory:self.categoryID uniqueID:self.uniqueID];
//            objc_setAssociatedObject(self, @selector(popularHashtagData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    } else {
//        result = nil;
//        objc_setAssociatedObject(self, @selector(popularHashtagData), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//    return result;
//}
//
//- (void)setPopularHashtagData:(PopularHashtagData *)popularHashtagData {
//    objc_setAssociatedObject(self, @selector(popularHashtagData), popularHashtagData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (NSString *) displayLabel {
    return isEmptyString(self.adLabel) ? self.label : self.adLabel;
}

- (NSString *)ugcRecommendReason {
    return [self.ugcRecommendDict tt_stringValueForKey:@"reason"];
}

- (NSString *)ugcRecommendAction {
    return [self.ugcRecommendDict tt_stringValueForKey:@"activity"];
}

- (CGFloat)cacheHeightForListType:(ExploreOrderedDataListType)listType
{
    return _cacheCellHeight[listType];
}

- (void)saveCacheHeight:(CGFloat)height forListType:(ExploreOrderedDataListType)listType
{
    //置顶的不缓存高度 5.4 add nick
    if (self.stickStyle >= 1) {
        return;
    }
    _cacheCellHeight[listType] = height;
}

- (CGFloat)cacheHeightForListType:(ExploreOrderedDataListType)listType cellType:(NSUInteger)cellType
{
    if (listType == ExploreOrderedDataListTypeFavorite) {
        return 0;
    }
    
    //置顶的不缓存高度 5.4 add nick
    if (self.stickStyle >= 1) {
        return 0;
    }
    
    //带推荐评论的不缓存高度
    if ([self.article.zzComments isKindOfClass:[NSArray class]]) {
        return 0;
    }
    
    if (_exploreCellType == cellType) {
        return _cacheCellHeight[listType];
    }
    return 0;
}

- (void)saveCacheHeight:(CGFloat)height forListType:(ExploreOrderedDataListType)listType cellType:(NSUInteger)cellType
{
    _exploreCellType = cellType;
    _cacheCellHeight[listType] = height;
}

- (CGFloat)cellItemCacheHeightForlistType:(ExploreOrderedDataListType)listType cacheKey:(NSString *)cacheKey;
{
    if (isEmptyString(cacheKey)) {
        return 0;
    }
    if (listType >= _cellItemHeightInfos.count) {
        return 0;
    }
    NSNumber *cacheHeight = _cellItemHeightInfos[listType][cacheKey];
    if (cacheHeight != nil) {
        return cacheHeight.doubleValue;
    }
    return 0;
}
- (void)saveCellItemCacheHeight:(CGFloat)height listType:(ExploreOrderedDataListType)listType cacheKey:(NSString *)cacheKey
{
    if (isEmptyString(cacheKey)) {
        return;
    }
    if (_cellItemHeightInfos.count == 0) {
        NSMutableArray *heightInfos = [NSMutableArray arrayWithCapacity:ExploreOrderedDataListTypeTotalCount];
        for (int i = 0; i < ExploreOrderedDataListTypeTotalCount; i++) {
            NSMutableDictionary *heightInfoDic = [NSMutableDictionary dictionary];
            [heightInfos addObject:heightInfoDic];
        }
        _cellItemHeightInfos = [heightInfos copy];
    }
    if (listType < ExploreOrderedDataListTypeTotalCount) {
        _cellItemHeightInfos[listType][cacheKey] = [NSNumber numberWithDouble:height];
    }
}

- (void)clearCacheHeight
{
    if (self.cellLayOut){
        self.cellLayOut.needUpdateAllFrame = YES;
    }
//    if (self.ugcCellLayout) {
//        self.ugcCellLayout.needCalculateLayout = YES;
//    }
    memset(_cacheCellHeight, 0, sizeof(_cacheCellHeight));
    _cellItemHeightInfos = nil;
}

- (void)clearCachedCellType
{
    self.cellTypeCached = 0;
}

- (BOOL)needShowAbstractWhenNotSet
{
    return NO;
}

- (void)followNotification:(NSNotification *)notification {
    NSString * userID = notification.userInfo[kRelationActionSuccessNotificationUserIDKey];
    if (isEmptyString(userID)) {
        return;
    }
    if (self.article) {
        if ([[self.article userIDForAction] isEqualToString:userID]) {
            [self clearRedpacket];
        }
    }
//    else if (self.thread) {
//        if ([self.thread.userID isEqualToString:userID]) {
//            [self clearRedpacket];
//        }
//    }
    else if (self.shortVideoOriginalData) {
        if ([self.shortVideoOriginalData.shortVideo.author.userID isEqualToString:userID]) {
            [self clearRedpacket];
        }
    }else if (self.comment) {
        if ([[self.comment userID] isEqualToString:userID]) {
            [self clearRedpacket];
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)registNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheHeight) name:kClearCacheHeightNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCachedCellType) name:kClearCachedCellTypeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
}

#pragma clang diagnostic pop

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    [super updateWithDictionary:dataDict];
    
    if (![dataDict objectForKey:@"requestTime"]) {
        self.requestTime = [[NSDate date] timeIntervalSince1970];
    }
    
    if ([dataDict[kShowTrackUrlList] isKindOfClass:[NSArray class]]) {
        self.adTrackURLs = [dataDict valueForKey:kShowTrackUrlList];
    }
    if (!self.adTrackURLs) {
        if ([dataDict[@"ad_track_url_list"] isKindOfClass:[NSArray class]]) {
            self.adTrackURLs = [dataDict valueForKey:@"ad_track_url_list"];
        }
    }
    if ([[dataDict valueForKey:@"ad_video_click_track_urls"] isKindOfClass:[NSArray class]]) {
        self.adVideoClickTrackURLs = dataDict[@"ad_video_click_track_urls"];
    }
    if ([dataDict[kClickTrackUrlList] isKindOfClass:[NSArray class]]) {
        self.adClickTrackURLs = [dataDict valueForKey:kClickTrackUrlList];
        if (!self.adClickTrackURLs) {
            if ([dataDict[@"ad_click_track_url_list"] isKindOfClass:[NSArray class]]) {
                self.adClickTrackURLs = [dataDict valueForKey:@"ad_click_track_url_list"];
            }
        }
    }
    if ([[dataDict valueForKey:kPlayerTrackUrlList] isKindOfClass:[NSArray class]]) {
        self.adPlayTrackUrls = dataDict[kPlayerTrackUrlList];
    }
    if ([[dataDict valueForKey:kPlayerActiveTrackUrlList] isKindOfClass:[NSArray class]]) {
        self.adPlayActiveTrackUrls = dataDict[kPlayerActiveTrackUrlList];
    }
    if ([[dataDict valueForKey:kPlayerEffectiveTrackUrlList] isKindOfClass:[NSArray class]]) {
        self.adPlayEffectiveTrackUrls = dataDict[kPlayerEffectiveTrackUrlList];
    }
    if ([[dataDict valueForKey:kPlayerOverTrackUrlList] isKindOfClass:[NSArray class]]) {
        self.adPlayOverTrackUrls = dataDict[kPlayerOverTrackUrlList];
    }
    if ([dataDict valueForKey:kEffectivePlayTime]) {
        self.effectivePlayTime = [dataDict[kEffectivePlayTime] floatValue];
    }
    
    
    if ([[dataDict valueForKey:@"stat_url_list"] isKindOfClass:[NSArray class]]) {
        self.statURLs = dataDict[@"stat_url_list"];
    }
    if ([[dataDict valueForKey:@"action_list"] isKindOfClass:[NSArray class]]) {
        self.actionList = dataDict[@"action_list"];
    }
    
    if ([dataDict objectForKey:@"large_image_list"])
    {
        NSArray *imageLists = [dataDict arrayValueForKey:@"large_image_list"
                                            defaultValue:nil];
        if ([imageLists count] > 0) {
            NSDictionary *dataDict = [imageLists objectAtIndex:0];
            self.largeImageDict = dataDict;
        }
        else {
            self.largeImageDict = nil;
        }
    }
    
    self.videoChannelADType = [dataDict tt_integerValueForKey:@"video_channel_ad_type"];
    
    self.largePicCeativeType = [dataDict tt_integerValueForKey:@"ad_display_style"];
    
    self.trackSDK = [dataDict tt_integerValueForKey:@"track_sdk"];
    
    self.logPb = [dataDict tt_dictionaryValueForKey:@"log_pb"];
    
//    if ([self.activity.allKeys containsObject:@"redpack"]) {
//        self.redpacketModel = [[FRRedpackStructModel alloc] initWithDictionary:[self.activity tt_dictionaryValueForKey:@"redpack"]
//                                                                         error:nil];
//    }else {
//        self.redpacketModel = nil;
//    }
    
    /*
     针对CommentRepost情况 raw_data中增加了下面的结构体
     struct StreamUICtrl {
     1: i32 max_text_line,                          # Cell展示最大行数
     2: i32 default_text_line,                      # Cell展示默认行数
     3: i32 inner_ui_flag,                          # 帖子图片UI
     }
     */
    if (self.cellType == ExploreOrderedDataCellTypeCommentRepost) {
        NSDictionary *streamUIDict = [[dataDict tt_dictionaryValueForKey:@"raw_data"] tt_dictionaryValueForKey:@"stream_ui"];
        if (streamUIDict) {
            self.maxTextLine = @([streamUIDict tt_intValueForKey:@"max_text_line"]);
            self.defaultTextLine = @([streamUIDict tt_intValueForKey:@"default_text_line"]);
            self.innerUiFlag = @([streamUIDict tt_integerValueForKey:@"inner_ui_flag"]);
        }
        
        NSDictionary *cellCtrls = [dataDict tt_dictionaryValueForKey:@"cell_ctrls"];
        if (cellCtrls) {
            if ([cellCtrls objectForKey:@"cell_flag"]) {
                self.cellFlag = [cellCtrls tt_intValueForKey:@"cell_flag"];
            }
            if ([cellCtrls objectForKey:@"cell_layout_style"]) {
                self.cellLayoutStyle = @([cellCtrls tt_intValueForKey:@"cell_layout_style"]);
            }
        }
    }
    if (self.cellType == ExploreOrderedDataCellTypeShortVideo) {
        //针对小视频，他的视频样式是cell_ctrls里面的cell_layout_stype控制的
        NSDictionary *cellCtrls = [dataDict tt_dictionaryValueForKey:@"cell_ctrls"];
        if (cellCtrls) {
            if ([cellCtrls objectForKey:@"cell_layout_style"]) {
                self.cellLayoutStyle = @([cellCtrls tt_intValueForKey:@"cell_layout_style"]);
            }
        }
    }
    
    
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    NSDictionary *originalData = [self.originalData toDictionary];
    [dictionary setValue:originalData forKey:@"originalData"];
    return dictionary;
}

- (BOOL)isListShowPlayVideoButton {
    if (isEmptyString(self.article.videoID)) {
        return NO;
    }
    
    ExploreOrderedDataVideoStyle style = self.videoStyle;
    
    switch (style) {
        case ExploreOrderedDataVideoStyle0:
        case ExploreOrderedDataVideoStyle1:
            return NO;
            
        default:
            return YES;
    }
    
    return YES;
}

- (BOOL)isPlayInDetailView {
    return (self.cellFlag & ExploreOrderedDataCellFlagPlayInDetailView) != 0;
}

- (BOOL)isShowRecommendReasonLabel {
    return (self.cellFlag & ExploreOrderedDataCellFlagShowRecommendReason) != 0;
}

- (BOOL)isShowDigButton {
    if (self.cellFlag == 0) return YES;
    return (self.cellFlag & ExploreOrderedDataCellFlagShowDig) != 0;
}

- (BOOL)isAutoPlayFlagEnabled {
    return (self.cellFlag & ExploreOrderedDataCellFlagAutoPlay) != 0;
}

- (BOOL)isShowComment {
    if (self.cellFlag == 0) return YES;
    return (self.cellFlag & ExploreOrderedDataCellFlagShowCommentCount) != 0;
}

- (BOOL)isShowAbstract {
    return (self.cellFlag & ExploreOrderedDataCellFlagShowAbstract) != 0;
}

- (BOOL)isShowCommentCountLabel {
    if (self.cellFlag == 0) return YES;
    return (self.cellFlag & ExploreOrderedDataCellFlagShowCommentCount) != 0 &&
    ((self.cellFlag & ExploreOrderedDataCellFlagShowRecommendReason) == 0);
}

- (BOOL)isShowSourceImage
{
    NSInteger flag = self.cellFlag;
    if (flag == 0) return NO; //默认不显示来源头像
    
    if ((flag & ExploreOrderedDataCellFlagShowSourceImage) != 0) {
        return YES;
    }
    
#if INHOUSE
    if ([ExploreCellHelper getSourceImgTest]) {
        return YES;
    }
#endif
    
    return NO;
}

- (BOOL)isShowSourceLabel {
    if (self.cellFlag == 0) return YES;
    return ((self.cellFlag & ExploreOrderedDataCellFlagShowSource) != 0) &&
    ((self.cellFlag & ExploreOrderedDataCellFlagShowRecommendReason) == 0);
}

- (BOOL)isShowTimeLabel {
    if (self.gallaryStyle != 1 && self.article.isImageSubject) {
        //图片频道不显示时间
        return NO;
    }
    NSInteger flag = self.cellFlag;
    if (flag == 0) return YES;
    return (flag & ExploreOrderedDataCellFlagShowTime) != 0 && ((flag & ExploreOrderedDataCellFlagShowRecommendReason) == 0);
}

/** ugc主feed流新样式 */
- (BOOL)isFeedUGC
{
    if (self.isInCard) return NO;
#if INHOUSE
    //用户在高级设置中修改过FeedUGC开关，则不需判断服务器下发开关
    if ([ExploreCellHelper userDidSetFeedUGCTest]) {
        return [ExploreCellHelper getFeedUGCTest];
    }
#endif
    return ((self.cellFlag & ExploreOrderedDataCellFlagSourceAtTop) != 0);
}

- (BOOL)isVideoPGCCard
{
    return (self.cellFlag & ExploreOrderedDataCellFlagVideoPGCCard) != 0;
}

//直播是否显示

- (BOOL)isShowMediaLiveTitle
{
    return (self.cellFlag & ExploreOrderedDataCellFlagHuoShanTitle) != 0;
}

- (BOOL)isShowMediaLiveViewCount
{
    return (self.cellFlag & ExploreOrderedDataCellFlagHuoShanViewCount) != 0;
}

- (BOOL)isShowMediaLiveUserInfo
{
    return (self.cellFlag & ExploreOrderedDataCellFlagHuoShanUserInfo) != 0;
}

- (BOOL)isShowHuoShanTitle
{
    return (self.cellFlag & ExploreOrderedDataCellFlagHuoShanTitle) != 0;
}
- (BOOL)isShowHuoShanViewCount
{
    return (self.cellFlag & ExploreOrderedDataCellFlagHuoShanViewCount) != 0;
}

- (BOOL)isShowHuoShanUserInfo
{
    return (self.cellFlag & ExploreOrderedDataCellFlagHuoShanUserInfo) != 0;
}

- (BOOL)isFeedCategory
{
    NSString *categoryID = self.categoryID;
    if (self.isInCard) {
        ExploreOrderedData *cardOrderedData = [ExploreOrderedData objectForPrimaryKey:self.cardPrimaryID];
        categoryID = cardOrderedData.categoryID;
    }
    if ([categoryID isEqualToString:kTTMainCategoryID]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)autoPlayServerEnabled
{
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_auto_play_flag" defaultValue:@NO freeze:NO] boolValue];
    return result && [self isAutoPlayFlagEnabled];
}

- (BOOL)couldAutoPlay
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"video_auto_play_test"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_auto_play_test"];
    }
    BOOL dataCanAutoPlay = [self autoPlayServerEnabled];
    if (!dataCanAutoPlay) return NO;
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    if (isPad) {
        return NO;
    }
    
    BOOL settingModeOn = NO;
    if (TTNetworkWifiConnected()) {
        settingModeOn = ttvs_autoPlayModeServerSetting() != TTAutoPlaySettingModeNone;
    } else if (TTNetworkConnected()) {
        settingModeOn = ttvs_autoPlayModeServerSetting() == TTAutoPlaySettingModeAll;
    }
    
    return settingModeOn;
}

- (BOOL)couldContinueAutoPlay
{
    BOOL result = [[[TTSettingsManager sharedManager] settingForKey:@"video_play_continue_flag" defaultValue:@YES freeze:NO] boolValue];
    return [self couldAutoPlay] && result;
}


- (BOOL)isU11ShowPadding {
    if (self.cellFlag == 0) return NO;
    return (self.cellFlag & ExploreOrderedDataCellFlagU11ShowPadding) != 0;
}

- (BOOL)isU11ShowFollowItem {
    NSInteger flag = self.cellFlag;
    if (flag == 0) return NO;
    return (self.cellFlag & ExploreOrderedDataCellFlagU11ShowFollowItem) != 0;
}

- (BOOL)isU11ShowRecommendReason {
    NSInteger flag = self.cellFlag;
    if (flag == 0) return NO;
    return (self.cellFlag & ExploreOrderedDataCellFlagU11ShowRecommendReason) != 0;
}

- (BOOL)isU11ShowTimeItem {
    NSInteger flag = self.cellFlag;
    if (flag == 0) return NO;
    return (flag & ExploreOrderedDataCellFlagU11ShowTimeItem) != 0;
}

- (BOOL)isU11ShowFollowButton {
    NSInteger flag = self.cellFlag;
    if (flag == 0) return NO;
    return (flag & ExploreOrderedDataCellFlagU11ShowFollowButton) != 0;
}


- (BOOL)isFakePlayCount{
    NSInteger flag = self.cellFlag;
    if (flag == 0) return NO;
    return (flag & ExploreOrderedDataCellFlagIsFakePlayCount) != 0;
}

- (BOOL)isU13CellInStoryMode
{
    if (([self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle24 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle25 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle26 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle27 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle28 )
        /*&& [self.categoryID isEqualToString:kStoryCategoryName]*/) { // TODO 确认控制字段，频道
        return YES;
    }

    return NO;
}

- (BOOL)isU13Cell
{
    if ([self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle24 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle25 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle26 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle27 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle28 ) {
        //24是普通u13cell
        //25～28是文章、图集的u13cell
        return YES;
    }

    return NO;
}

- (BOOL)isHotNewsCellWithAvatar {
    return [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle201;
}
            
- (BOOL)isHotNewsCellWithRedDot {
    return [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle202;
}

//,u11,5，8，9表示有顶踩；6，7表示无顶踩、大头像在上的普通文章样式
- (BOOL)isU11Cell
{
    //普通文章的u11样式依赖cell_layout_style区分
    if ([self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle5 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle6 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle7 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11){
        return YES;
    }
    
    return NO;
}

//表示有评论点赞转发的u11
- (BOOL)isU11HasActionButtonCell
{
    if ([self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle5 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11){
        return YES;
    }
    return NO;
}

- (BOOL)isUGCArticleCellAndCommentCellHadTopPadding
{
    if ([self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle5 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11 ||
        [self.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle24 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle25 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle26 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle27 ||
        [self.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle28){
        return YES;
    }
    return NO;
}

- (BOOL)isPlainCell
{
    if (self.layoutUIType == TTLayOutCellUITypePlainCellPureTitleS0 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellPureTitleS1 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellPureTitleS2 ||
        
        self.layoutUIType == TTLayOutCellUITypePlainCellRightPicS0 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellRightPicS1 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellRightPicS2 ||
        
        self.layoutUIType == TTLayOutCellUITypePlainCellGroupPicS0 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellGroupPicS1 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellGroupPicS2 ||
        
        self.layoutUIType == TTLayOutCellUITypePlainCellLargePicS0 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellLargePicS1 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellLargePicS2 ||
        self.layoutUIType == TTLayOutCellUITypePlainCellLoopPic)
        
    {
        return YES;
    }
    return NO;
}

- (BOOL)isUGCCell
{
    if (self.layoutUIType == TTLayOutCellUITypeUGCCellPureTitle) {
        return YES;
    }
    return NO;
}

- (BOOL)isUnifyADCell
{
    if (self.layoutUIType == TTLayOutCellUITypeUnifyADCellRightPic ||
        self.layoutUIType == TTLayOutCellUITypeUnifyADCellGroupPic ||
        self.layoutUIType == TTLayOutCellUITypeUnifyADCellLargePic) {
        return YES;
    }
    return NO;
}

- (BOOL)hasTopPadding{
    if (self.cellType == ExploreOrderedDataCellTypeLastRead ||
        self.cellType == ExploreOrderedDataCellTypeNull) {
        return YES;
    }
    if (self.isInCard) {
        return NO;
    }
    if (self.cellType == ExploreOrderedDataCellTypeWendaQuestion) {
        return (self.ttWenda.questionLayoutType != 0);
    }
    if (self.cellType == ExploreOrderedDataCellTypeSurveyList ||
        self.cellType == ExploreOrderedDataCellTypeSurveyPair ||
        self.cellType == ExploreOrderedDataCellTypeWendaAnswer ||
        self.cellType == ExploreOrderedDataCellTypeShortVideo ||
        self.cellType == ExploreOrderedDataCellTypeHorizontalCard ||
        self.cellType == ExploreOrderedDataCellTypeShortVideoStory ||
        self.cellType == ExploreOrderedDataCellTypeLianZai ||
        self.cellType == ExploreOrderedDataCellTypeCard ||
        self.cellType == ExploreOrderedDataCellTypeLive ||
        self.cellType == ExploreOrderedDataCellTypeComment ||
        self.cellType == ExploreOrderedDataCellTypeRecommendUser ||
        self.cellType == ExploreOrderedDataCellTypeRecommendUserLargeCard ||
        self.cellType == ExploreOrderedDataCellTypeMomentsRecommendUser ||
        self.cellType == ExploreOrderedDataCellTypeCommentRepost ||
        self.cellType == ExploreOrderedDataCellTypeRecommendUserStoryCard ||
        self.cellType == ExploreOrderedDataCellTypeRecommendStoryCoverCard ||
        self.cellType == ExploreOrderedDataCellTypeXiguaLiveHorizontal ||
        self.cellType == ExploreOrderedDataCellTypeXiguaLive ||
        (self.cellType == ExploreOrderedDataCellTypeArticle && [self isU11ShowPadding] && [self isUGCArticleCellAndCommentCellHadTopPadding]) ||
        (self.cellType == ExploreOrderedDataCellTypeThread && [self isU11ShowPadding])||
        (self.cellType == ExploreOrderedDataCellTypeEssay && ![ExploreCellHelper shouldShowEssayActionButtons:self.categoryID])||
        self.cellType == ExploreOrderedDataCellTypeResurface) {
        return YES;
    }
    return NO;
}

- (BOOL)preCellHasBottomPadding{
    if (self.preCellType == ExploreOrderedDataCellTypeLastRead ||
        self.preCellType == ExploreOrderedDataCellTypeNull){
        return YES;
    }
    return NO;
}

- (TTImageInfosModel *)listLargeImageModel
{
    if (![self.listLargeImageDict isKindOfClass:[NSDictionary class]] || [self.listLargeImageDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:self.listLargeImageDict];
    model.imageType = TTImageTypeLarge;
    return model;
}

- (NSDictionary *)listLargeImageDict {
    if (self.largeImageDict) {
        return self.largeImageDict;
    }
    return self.article.largeImageDict;
}

- (NSString *)openURL {
    NSString *openURL = _openURL;
    if (!isEmptyString(openURL) && [self.adID longLongValue] > 0 && self.logExtra != nil) {
        openURL = [openURL tt_adChangeUrlWithLogExtra:self.logExtra];
    }
    return openURL;
}

- (BOOL)hasRead {
    if (self.listType == ExploreOrderedDataListTypeFavorite || self.listType == ExploreOrderedDataListTypeReadHistory || self.listType == ExploreOrderedDataListTypePushHistory) {
        return NO;
    }
    return self.originalData.hasRead.boolValue;
}

+ (NSDictionary *)wendaBaseDicParse:(NSDictionary *)json
{
    NSString *extraString = [json valueForKey:@"extra"];
    if (!isEmptyString(extraString)) {
        NSError *extraError = nil;
        NSDictionary *extraJson = [NSString tt_objectWithJSONString:extraString error:&extraError];
        
        if (!extraError) {
            [json setValue:extraJson forKey:@"extra"];
        }
    }
    
    NSString *questionString = [json valueForKey:@"question"];
    if (!isEmptyString(questionString)) {
        NSError *questionError = nil;
        NSDictionary *questionJson = [NSString tt_objectWithJSONString:questionString error:&questionError];
        
        if (!questionError) {
            [json setValue:questionJson forKey:@"question"];
        }
    }
    
    NSString *answerString = [json valueForKey:@"answer"];
    if (!isEmptyString(answerString)) {
        NSError *answerError = nil;
        NSDictionary *answerJson = [NSString tt_objectWithJSONString:answerString error:&answerError];
        
        if (!answerError) {
            [json setValue:answerJson forKey:@"answer"];
        }
        
    }
    
    return json;
}

- (void)clearRedpacket {
//    self.redpacketModel = nil;
//    if (0 == self.activity.count || ![self.activity.allKeys containsObject:@"redpack"]) {
//        return;
//    }
//    NSMutableDictionary * activity = self.activity.mutableCopy;
//    [activity removeObjectForKey:@"redpack"];
//
//    if (activity.count == 0) {
//        self.activity = nil;
//    }else {
//        self.activity = activity.copy;
//    }
//    [self save];
}

@end

