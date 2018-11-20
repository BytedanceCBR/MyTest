//
//  ExploreCellHelper.m
//  Article
//
//  Created by Chen Hong on 14-9-12.
//
//

#import "ExploreCellHelper.h"

//model
#import "Article.h"
#import "WapData.h"
#import "StockData.h"
#import "HuoShan.h"
#import "TTCategoryAddToFirstPageData.h"
#import "Card+CoreDataClass.h"
#import "LastRead.h"
#import "LianZai.h"
#import "RNData.h"
#import "Book.h"
#import "Comment.h"
#import "TSVShortVideoOriginalData.h"
//#import "RecommendUserCardsData.h"
#import "HorizontalCard.h"
#import "ResurfaceData.h"
//#import "TSVStoryOriginalData.h"
//cell
#import "ExploreArticlePureTitleCell.h"
#import "ExploreArticleTitleRightPicCell.h"
#import "ExploreArticleTitleLargePicCell.h"
#import "TTVideoTabBaseCell.h"
#import "ExploreArticleTitleGroupPicCell.h"
#import "ExploreArticleCardCell.h"
#import "ExploreArticleWebCell.h"
#import "ExploreArticleStockCell.h"
//#import "TTVideoTabLiveCell.h"
//#import "TTVideoTabHuoShanCell.h"
//#import "TTArticleTitleLargePicHuoShanCell.h"
//#import "TTMeiNvTitleLargePicHuoShanCell.h"
#import "ExploreLastReadCell.h"
#import "ExploreArticleLianZaiCell.h"
#import "TTCategoryAddToFirstPageCell.h"
#import "TTLayOutPureTitleCell.h"
#import "TTLayOutRightPicCell.h"
#import "TTLayOutLargePicCell.h"
#import "TTLayOutNewLargePicCell.h"
#import "TTLayOutGroupPicCell.h"
#import "ExploreBookCell.h"
//#import "TTRecommendUserCell.h"
#import "TTLayOutWenDaCell.h"
#import "TTLayoutLoopPicCell.h"
#import "TTLayoutPanoramaViewCell.h"
#import "TTLayoutPanorama3DViewCell.h"
//#import "FantasyCardCell.h"
//#import "ExploreArticleSurveyListCell.h"
//#import "ExploreArticleSurveyPairCell.h"
#import "TTHotNewsCell.h"
#import "ExploreArticleHotNewsCell.h"

//cell view
#import "TTCategoryAddToFirstPageCellView.h"
//#import "TTMeiNvTitleLargePicHuoShanCellView.h"
//#import "TTVideoTabHuoShanCellView.h"
//#import "TTArticleTitleLargePicHuoShanCellView.h"
//#import "TTVideoTabLiveCellView.h"
#import "ExploreArticlePureTitleCellView.h"
#import "ExploreArticleTitleRightPicCellView.h"
#import "ExploreArticleTitleLargePicCellView.h"
#import "TTVideoTabBaseCellView.h"
#import "ExploreArticleTitleGroupPicCellView.h"
#import "ExploreArticleWebCellView.h"
#import "ExploreArticleCardCellView.h"
#import "ExploreArticleStockCellView.h"
#import "ExploreLastReadCellView.h"
#import "TTRNCellView.h"
#import "TTDynamicRNCellView.h"
#import "ExploreArticleLianZaiCellView.h"
#import "ExploreCollectionCellView.h"
//#import "FantasyCardCellView.h"
//#import "TTRecommendRedpacketCell.h"
//#import "ExploreArticleSurveyListCellView.h"
//#import "ExploreArticleSurveyPairCellView.h"
//#import "TTRecommendUserStoryCell.h"
//#import "TTUGCCoverStoryContainerCell.h"
#import "TTHotNewsCellView.h"
#import "ExploreArticleHotNewsCellView.h"

//#import "TTLiveStarCell.h"
//#import "TTLiveMatchCell.h"
//#import "TTLiveVideoCell.h"
//#import "TTLiveSimpleCell.h"
#import "TTHorizontalCardCell.h"
//#import "RecommendRedpacketData.h"
//#import "TTPopularHashtagCell.h"

//#import "TTUGCCell.h"
#import "WDBaseCell.h"
#import "ExploreArticleCellCommentView.h"
#import "ExploreArticleCellViewConsts.h"

#import "NewsUserSettingManager.h"
#import "NetworkUtilities.h"
#import "NewsLogicSetting.h"
#import "ExploreListHelper.h"
#import "ArticleImpressionHelper.h"

#import "ExploreOrderedData+TTAd.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTArticleCategoryManager.h"

#import "TTLabelTextHelper.h"
#import <objc/runtime.h>
#import "TTCellBridge.h"
#import "TTDeviceHelper.h"
#import "TTTAttributedLabel.h"
#import "TTArticlePanoramaView.h"

//#import "RecommendUserLargeCardData.h"
//#import "RecommendUserStoryCardData.h"
//#import "RecommendStoryCoverCardData.h"
//#import "TTRecommendUserLargeCell.h"
#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>
//#import "TTMomentsRecommendUserCell.h"
#import <TTServiceKit/TTServiceCenter.h>
//#import "MomentsRecommendUserData.h"
//#import "TTHashtagCardData.h"
//#import "TTHashtagRightPicCell.h"
//#import "TTWendaCell.h"

//#import "TTUGCCell.h"
//#import "TTXiguaLiveModel.h"
//#import "TTXiguaLiveRecommendUser.h"
//#import "TTXiguaLiveCell.h"
//#import "TTXiguaLiveCardHorizontal.h"
//#import "TTXiguaLiveHorizonCell.h"
//#import "TTXiguaLiveRecommendCell.h"
//#import "TTUGCU13Cell.h"
#import "TSVFeedFollowCell.h"
//#import "PopularHashtagData.h"
//#import "TSVFeedStoryCell.h"

#import "TTExploreLoadMoreTipData.h"
#import "TTExploreLoadMoreTipCell.h"
#import "FHHouseItemFeedCell.h"
#import "FHExploreHouseItemData.h"

#define kVideoCategoryID @"video"
#define kVideoShowListDigg @"video_show_list_digg"

#define RegisterTableViewCellClass(tableView, cellClass) \
([tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)])

static ExploreCellHelper *s_cellHelper;

static NSMutableArray *s_reusableCardViews;

@interface ExploreCellHelper () <TTCellDataHelper>

@property(nonatomic,assign,readwrite) NSTimeInterval midInterval;

@end

@implementation ExploreCellHelper

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cellHelper = [[ExploreCellHelper alloc] init];
        
        [self refreshMidnightInterval];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMidnightInterval) name:UIApplicationSignificantTimeChangeNotification object:nil];
    });
    
    return s_cellHelper;
}

#pragma mark - cell

+ (void)registerCellBridge
{
    // cell class
    [[TTCellBridge sharedInstance] registerCellClass:[TTLayOutPureTitleCell class]
                                       cellViewClass:[TTLayOutPureTitleCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticlePureTitleCell class]
                                       cellViewClass:[ExploreArticlePureTitleCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTLayOutRightPicCell class]
                                       cellViewClass:[TTLayOutRightPicCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTLayoutLoopPicCell class]
                                       cellViewClass:[TTLayoutLoopPicCellView class]];

    [[TTCellBridge sharedInstance] registerCellClass:[TTLayoutPanoramaViewCell class]
                                       cellViewClass:[TTArticlePanoramaView class]];

    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleTitleRightPicCell class]
                                       cellViewClass:[ExploreArticleTitleRightPicCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTLayOutNewLargePicCell class]
                                       cellViewClass:[TTLayOutNewLargePicCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTLayOutLargePicCell class]
                                       cellViewClass:[TTLayOutLargePicCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleTitleLargePicCell class]
                                       cellViewClass:[ExploreArticleTitleLargePicCellView class]];
    
//    [[TTCellBridge sharedInstance] registerCellClass:[TTVideoTabHuoShanCell class]
//                                       cellViewClass:[TTVideoTabHuoShanCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTVideoTabBaseCell class]
                                       cellViewClass:[TTVideoTabBaseCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTLayOutGroupPicCell class]
                                       cellViewClass:[TTLayOutGroupPicCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleTitleGroupPicCell class]
                                       cellViewClass:[ExploreArticleTitleGroupPicCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleCardCell class]
                                       cellViewClass:[ExploreArticleCardCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleWebCell class]
                                       cellViewClass:[ExploreArticleWebCellView class]];
    
//    [[TTCellBridge sharedInstance] registerCellClass:[TTLiveStarCell class]
//                                       cellViewClass:[TTLiveStarCellView class]];
//
//    [[TTCellBridge sharedInstance] registerCellClass:[TTLiveMatchCell class]
//                                       cellViewClass:[TTLiveMatchCellView class]];
//
//    [[TTCellBridge sharedInstance] registerCellClass:[TTLiveVideoCell class]
//                                       cellViewClass:[TTLiveVideoCellView class]];
//
//    [[TTCellBridge sharedInstance] registerCellClass:[TTLiveSimpleCell class]
//                                       cellViewClass:[TTLiveSimpleCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleStockCell class]
                                       cellViewClass:[ExploreArticleStockCellView class]];

//    //视频直播需求cell
//    [[TTCellBridge sharedInstance] registerCellClass:[TTVideoTabLiveCell class]
//                                       cellViewClass:[TTVideoTabLiveCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreLastReadCell class]
                                       cellViewClass:[ExploreLastReadCellView class]];

    [[TTCellBridge sharedInstance] registerCellClass:[TTRNCell class]
                                       cellViewClass:[TTRNCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTDynamicRNCell class]
                                       cellViewClass:[TTDynamicRNCellView class]];

    //连载cell
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleLianZaiCell class]
                                       cellViewClass:[ExploreArticleLianZaiCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleLianZaiCell class]
                                       cellViewClass:[ExploreArticleLianZaiCellView class]];
    //推荐多本小说cell
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreBookCell class]
                                       cellViewClass:[ExploreCollectionCellView class]];
    //添加到首屏cell
    [[TTCellBridge sharedInstance] registerCellClass:[TTCategoryAddToFirstPageCell class]
                                       cellViewClass:[TTCategoryAddToFirstPageCellView class]];
    
//    [[TTCellBridge sharedInstance] registerCellClass:[FantasyCardCell class]
//                                       cellViewClass:[FantasyCardCellView class]];
    
//    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleSurveyListCell class]
//                                       cellViewClass:[ExploreArticleSurveyListCellView class]];
//
//    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleSurveyPairCell class]
//                                       cellViewClass:[ExploreArticleSurveyPairCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTHotNewsCell class] cellViewClass:[TTHotNewsCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[ExploreArticleHotNewsCell class] cellViewClass:[ExploreArticleHotNewsCellView class]];
    
    [[TTCellBridge sharedInstance] registerCellClass:[TTExploreLoadMoreTipCell class] cellViewClass:[TTExploreLoadMoreTipCellView class]];
    
    // feed支持房源
    [[TTCellBridge sharedInstance] registerCellClass:[FHHouseItemFeedCell class] cellViewClass:[FHHouseItemFeedCellView class]];

}

+ (void)registerAllCellClassWithTableView:(UITableView *)tableView
{
    [[TTCellBridge sharedInstance] enumerateCellInfoUsingBlock:^(NSString *cellId, TTCellClassInfo *classInfo) {
        RegisterTableViewCellClass(tableView, classInfo.cellCls);
    }];
}

+ (Class)cellClassFromCellViewType:(ExploreCellViewType)cellViewType data:(id)data
{
    switch (cellViewType) {
            
        case ExploreCellViewTypeArticlePureTitle:
            return [TTLayOutPureTitleCell class];
        
        case ExploreCellViewTypeArticleTitleRightPicLive:
        {
            [[TTMonitor shareManager] trackService:@"tt_mixed_list_cell_is_nil" status:1 extra:nil];
            NSAssert(NO, @"ExploreArticleTitleRightPicLiveCell is deprecated");
//            return [ExploreArticleTitleRightPicLiveCell class];
            return nil;
        }
        case ExploreCellViewTypeArticleTitleRightPic:
            return [TTLayOutRightPicCell class];
            
        case ExploreCellViewTypeArticleTitleLargePic:
        {
            if ([SSCommonLogic feedNewPlayerEnabled]) {
                return [TTLayOutNewLargePicCell class];
            } else {
                return [TTLayOutLargePicCell class];
            }
        }
        case ExploreCellViewTypeArticleTitleMultiPic:
            return [TTLayOutGroupPicCell class];
            
        case ExploreCellViewTypeArticleTtileLoopPic:
           return [TTLayoutLoopPicCell class];
 
        case ExploreCellViewTypeArticleFullView:
            return [TTLayoutPanoramaViewCell class];

        case ExploreCellViewTypeArticle3DFullView:
            return [TTLayoutPanorama3DViewCell class];
            
        case ExploreCellViewTypeArticleTitlePlayVideo:
        {
            //视频情况
//            if ([data isU11HasActionButtonCell]) {
//                return [TTUGCVideoCell class];
//            }
//            if ([data isU13Cell]) {
//                return [TTUGCU13VideoCell class];
//            }
            
            if ([SSCommonLogic feedNewPlayerEnabled]) {
                return [TTLayOutNewLargePicCell class];
            } else {
                return [TTLayOutLargePicCell class];
            }
        }
        case ExploreCellViewTypeArticleTitlePlayLiveVideo:
        {
            [[TTMonitor shareManager] trackService:@"tt_mixed_list_cell_is_nil" status:2 extra:nil];
            NSAssert(NO, @"ExploreArticleTitleLargePicPlayVideoLiveCell is deprecated");
//            return [ExploreArticleTitleLargePicPlayVideoLiveCell class];
            return nil;
        }
//        case ExploreCellViewTypeArticleTitleLargePicHuoShan:
//            return [TTArticleTitleLargePicHuoShanCell class];
//
//        case ExploreCellViewTypeVideoTabHuoShan:
//            return [TTVideoTabHuoShanCell class];
//
//        case ExploreCellViewTypeMeiNvHuoShan:
//            return [TTMeiNvTitleLargePicHuoShanCell class];
            
//        case ExploreCellViewTypeVideoTabLiveCell:
//            return [TTVideoTabLiveCell class];
            
        case ExploreCellViewTypeVideoTabBaseCell:
            return [TTVideoTabBaseCell class];
            
//        case ExploreCellViewTypeFantasyCardCell:
//            return [FantasyCardCell class];
            
//        case ExploreCellViewTypeSurveyListCell:
//            return [ExploreArticleSurveyListCell class];
//
//        case ExploreCellViewTypeSurveyPairCell:
//            return [ExploreArticleSurveyPairCell class];
            
        case ExploreCellViewTypeCard:
            return [ExploreArticleCardCell class];
            
        case ExploreCellViewTypeWeb:
            return [ExploreArticleWebCell class];
            
        case ExploreCellViewTypeGallaryGroupPic:
            return [ExploreArticleTitleGroupPicCell class];
            
        case ExploreCellViewTypeGallaryLargePic:
            return [ExploreArticleTitleLargePicCell class];
            
        case ExploreCellViewTypeNotSupport:
            return nil;
            
//        case ExploreCellViewTypeLiveStar:
//            return [TTLiveStarCell class];
//
//        case ExploreCellViewTypeLiveMatch:
//            return [TTLiveMatchCell class];
//
//        case ExploreCellViewTypeLiveVideo:
//            return [TTLiveVideoCell class];
//
//        case ExploreCellViewTypeLiveSimple:
//            return [TTLiveSimpleCell class];
            
        case ExploreCellViewTypeStock:
        {
            [[TTMonitor shareManager] trackService:@"tt_mixed_list_cell_is_nil" status:3 extra:nil];
            NSAssert(NO, @"ExploreArticleStockCell is deprecated");
            //            return [ExploreArticleStockCell class];
            return nil;
        }

        case ExploreCellViewTypeLastRead:
            return [ExploreLastReadCell class];

        case ExploreCellViewTypeRN:
            return [TTRNCell class];
        case ExploreCellViewTypeDynamicRN:
            return [TTDynamicRNCell class];
        
        case ExploreCellViewTypeLianZai:
            return [ExploreArticleLianZaiCell class];
            
        case ExploreCellViewTypeAddToFirstPageCell:
            return [TTCategoryAddToFirstPageCell class];
        case ExploreCellViewTypeCollectionBookCell:
            return [ExploreBookCell class];
//        case ExploreCellViewTypeCardRecommendUserCardCell:
//            return [TTRecommendUserCell class];
        case ExploreCellViewTypeShortVideoCell:
        {

            // add by zjing 收藏增加小视频
            if ([data isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData *orderedData = data;
                if (orderedData.cellCtrls && [orderedData.cellCtrls isKindOfClass:[NSDictionary class]]) {
                    NSInteger layoutStyle = [orderedData.cellCtrls tt_integerValueForKey:@"cell_layout_style"];
//                    if (layoutStyle == 100 || layoutStyle == 101) {
                        return [TSVFeedFollowCell class];
//                    }
                }
            }
            return [TTLayOutPureTitleCell class];
        }
        case ExploreCellViewTypeHorizontalCard:
            return [TTHorizontalCardCell class];
        case ExploreCellViewTypeWenDaLayOutCell:
            return [TTLayOutWenDaCell class];
//        case ExploreCellViewTypeRecommendUserLargeCardCell:
//            return [TTRecommendUserLargeCell class];
//        case ExploreCellViewTypeMomentsRecommendUserCell:
//            return [TTMomentsRecommendUserCell class];
//        case ExploreCellViewTypeHashtagRightPicCell:
//            return [TTHashtagRightPicCell class];
//        case ExploreCellViewTypeRecommendRedPacketCell:
//            return [TTRecommendRedpacketCell class];
//        case ExploreCellViewTypeXiguaLargePicCell:
//            return [TTXiguaLiveCell class];
//        case ExploreCellViewTypeXiguaHorizontalCell:
//            return [TTXiguaLiveHorizonCell class];
//        case ExploreCellViewTypeXiguaRecommendCell:
//            return [TTXiguaLiveRecommendCell class];
//        case ExploreCellViewTypeRecommendUserStoryCardCell:
//            return [TTRecommendUserStoryCell class];
//        case ExploreCellViewTypeRecommendStoryCoverCardCell:
//            return [TTUGCCoverStoryContainerCell class];
//        case ExploreCellViewTypePopularHashtagCell:
//            return [TTPopularHashtagCell class];
//        case ExploreCellViewTypeTSVStoryCell:
//            return [TSVFeedStoryCell class];
        case ExploreCellViewTypeHotNews:
            return [TTHotNewsCell class];
        case ExploreCellViewTypeArticleHotNews:
            return [ExploreArticleHotNewsCell class];
        case ExploreCellViewTypeLoadmoreTipCell:
            return [TTExploreLoadMoreTipCell class];
        case ExploreCellViewTypeFHHouseItemCell:
            return [FHHouseItemFeedCell class];
        default:
            break;
    }
    
    return [TTLayOutPureTitleCell class];
}

+ (UITableViewCell *)dequeueTableCellForData:(id)data tableView:(UITableView *)view atIndexPath:(NSIndexPath *)indexPath refer:(NSUInteger)refer
{
    NSString * identifier = [self identifierForData:data];
    
    if (identifier == nil) {
        [ExploreCellHelper trackAdCellTypeException:data];
        NSMutableDictionary *cellMonitorExtraDict = [NSMutableDictionary dictionary];
        if ([data isKindOfClass:[ExploreOrderedData class]]) {
            [cellMonitorExtraDict setValue:@(((ExploreOrderedData *)data).cellType) forKey:@"cell_type"];
            [cellMonitorExtraDict setValue:((ExploreOrderedData *)data).uniqueID forKey:@"unique_id"];
            [cellMonitorExtraDict setValue:((ExploreOrderedData *)data).rid forKey:@"request_id"];
        }
        [[TTMonitor shareManager] trackService:@"tt_mixed_list_cell_is_nil" status:0 extra:cellMonitorExtraDict];
        if (![((ExploreOrderedData *)data).categoryID isEqualToString:@"fake"]) {
            NSAssert(NO, @"cell can not be nil");
        }
        return nil;

    }
    
    id tableCell = [view dequeueReusableCellWithIdentifier:identifier];
    if (tableCell) {
        if(![SSCommonLogic isNewFeedImpressionEnabled]){
            if ([tableCell isKindOfClass:[ExploreCellBase class]] &&
                [((ExploreCellBase *)tableCell).cellData isKindOfClass:[ExploreOrderedData class]]) {
                ExploreCellBase *baseCell = (ExploreCellBase *)tableCell;
                // cellData不为空时，cell是之前创建的，此次被复用，需要将之前cell数据impression标记为end
                ExploreOrderedData * orderedData = (ExploreOrderedData *)((ExploreCellBase *)tableCell).cellData;

                SSImpressionParams *params = [[SSImpressionParams alloc] init];
                params.categoryID = orderedData.categoryID;
                params.concernID = orderedData.concernID;
                params.refer = refer;
                params.cellStyle = baseCell.cellStyle;
                params.cellSubStyle = baseCell.cellSubStyle;
                
                [ArticleImpressionHelper recordGroupForExploreOrderedData:orderedData status:SSImpressionStatusEnd params:params];
            }
        }
        
        if ([tableCell isKindOfClass:[ExploreCellBase class]]) {
            ((ExploreCellBase *)tableCell).tableView = view;
        }
        else if ([tableCell isKindOfClass:[WDBaseCell class]]) {
            ((WDBaseCell *)tableCell).tableView = view;
        }
        return tableCell;
    }
    else {
        Class cellClass = NSClassFromString(identifier);
        if ([cellClass isSubclassOfClass:[ExploreCellBase class]]) {
            return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        else if ([cellClass isSubclassOfClass:[WDBaseCell class]]) {
            return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        else {
            // 默认纯标题样式
            ExploreCellBase *cell = [[ExploreArticlePureTitleCell alloc] initWithTableView:view reuseIdentifier:identifier];
            return cell;
        }
    }
}

+ (ExploreCellViewBase *)dequeueTableCellViewForData:(id)data {
    
    NSString * identifier = [self identifierForData:data];
    if (identifier == nil) {
        return nil;
    }
    
    ExploreCellViewBase *cellView = nil;
    
    for (ExploreCellViewBase *aCellView in s_reusableCardViews) {
        if ([aCellView.reuseIdentifier isEqualToString:identifier]) {
            cellView = aCellView;
            break;
        }
    }
    
    if (cellView) {
        //NSLog(@"reused: %@ %d", [cell class], s_reusableCardViews.count);
        [s_reusableCardViews removeObject:cellView];
        return cellView;
    }
    
    Class cellClass = NSClassFromString(identifier);
    
    Class cellViewClass = [[TTCellBridge sharedInstance] cellViewClassFromCellClass:cellClass];
    
    if (cellViewClass) {
        return [(ExploreCellViewBase *)[cellViewClass alloc] initWithFrame:CGRectZero reuseIdentifier:identifier];
    }
    
    // 默认
    return [[ExploreArticlePureTitleCellView alloc] initWithFrame:CGRectZero reuseIdentifier:identifier];
}

+ (void)recycleCellView:(ExploreCellViewBase *)cellView {
    if (cellView && [cellView isKindOfClass:[ExploreCellViewBase class]]) {
        if (!s_reusableCardViews) {
            s_reusableCardViews = [[NSMutableArray alloc] initWithCapacity:10];
        }
        if (![s_reusableCardViews containsObject:cellView]) {
            [s_reusableCardViews addObject:cellView];
        }
    }
}

+ (void)refreshFontSizeForRecycleCardViews {
    for (ExploreCellViewBase *cellView in s_reusableCardViews) {
        [cellView fontSizeChanged];
    }
}

+ (void)trackAdCellTypeException:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData * orderData = (ExploreOrderedData *)data;
        NSString* ad_id = orderData.ad_id;
        if (!isEmptyString(ad_id)&&ad_id.longLongValue>0) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setValue:orderData.log_extra forKey:@"log_extra"];
            [dict setValue:@([orderData cellType]) forKey:@"cell_type"];
            [dict setValue:ad_id forKey:@"ad_id"];
            id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
            [[adManagerInstance class] monitor_trackService:@"ad_feed_unkowntype" status:0 extra:dict];
            
        }
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    NSString * identifier = [self identifierForData:data];
    if (identifier == nil) {
        return 0; 
    }
    
    Class cellClass = NSClassFromString(identifier);
    if ([cellClass isSubclassOfClass:[ExploreCellBase class]]) {
        if (listType == ExploreOrderedDataListTypeConcernHomepageThread && [data isKindOfClass:[ExploreOrderedData class]]) {
            //关心主页的帖子，干掉dislike
            ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
            orderedData.showDislike = @(NO);
        }
        return [cellClass heightForData:data cellWidth:width listType:listType];
    }
    else if ([cellClass isSubclassOfClass:[WDBaseCell class]])
    {
        if ([data isKindOfClass:[ExploreOrderedData class]]) {
            ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
            Method class_method = class_getClassMethod(cellClass, @selector(heightForData:cellWidth:listType:));
            if (!isEmptyString(NSStringFromSelector(method_getName(class_method)))) {
                return [cellClass heightForData:orderedData.originalData cellWidth:width listType:0];
            }
        }
    }
    
    return 0;
}

+ (ExploreCellViewType)cellViewTypeForVideoStyle:(ExploreOrderedDataVideoStyle)videoStyle withData:(Article *)article
{
    
    ExploreCellViewType cellViewType;
    
    NSInteger videoType = 0;
    if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
        videoType = ((NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
    }
    switch (videoStyle) {
        case ExploreOrderedDataVideoStyle0:
            switch (videoType) {
                case 0:
                    cellViewType = ExploreCellViewTypeArticleTitleRightPic;
                    break;
                case 1:
                    cellViewType = ExploreCellViewTypeArticleTitleRightPicLive;
                    break;
                default:
                    cellViewType = ExploreCellViewTypeArticleTitleRightPic;
                    break;
            }
            break;
            
        case ExploreOrderedDataVideoStyle1:
            switch (videoType) {
                case 0:
                    cellViewType = ExploreCellViewTypeArticleTitlePlayVideo;
                    break;
                case 1:
                    cellViewType = ExploreCellViewTypeArticleTitlePlayLiveVideo;
                    break;
                default:
                    cellViewType = ExploreCellViewTypeArticleTitlePlayVideo;
                    break;
            }
            break;
            
        case ExploreOrderedDataVideoStyle2:
            switch (videoType) {
                case 0:
                    cellViewType = ExploreCellViewTypeArticleTitlePlayVideo;
                    break;
                case 1:
                    cellViewType = ExploreCellViewTypeArticleTitlePlayLiveVideo;
                    break;
                default:
                    cellViewType = ExploreCellViewTypeArticleTitlePlayVideo;
                    break;
            }
            break;
        case ExploreOrderedDataVideoStyle8:
            switch (videoType) {
                case 0:
                    cellViewType = ExploreCellViewTypeVideoTabBaseCell;
                    break;
                case 1:
                    cellViewType = ExploreCellViewTypeVideoTabLiveCell;
                    break;
                default:
                    cellViewType = ExploreCellViewTypeVideoTabBaseCell;
                    break;
            }
            break;
        default:
            cellViewType = ExploreCellViewTypeArticleTitleRightPic;
            break;
    }
    return cellViewType;
}

+ (NSString *)identifierForData:(id)data
{
    NSArray<Class<TTCellDataHelper>> *cellDataHelperArray = [[TTCellBridge sharedInstance] cellHelperClassArrayForData:data];
    
    __block NSString *cellId = nil;
    __block Class cellCls = nil;
    
    [cellDataHelperArray enumerateObjectsUsingBlock:^(Class<TTCellDataHelper>  _Nonnull cellDataHelper, NSUInteger idx, BOOL * _Nonnull stop) {
        cellCls = [cellDataHelper cellClassFromData:data];
        
        if (cellCls) {
            cellId = NSStringFromClass(cellCls);

            if (!isEmptyString(cellId)) {
                *stop = YES;
            }
        }
    }];
    
    // 如果TTCellBridge中没有找到cellCls，使用ExploreCellHelper
    if (isEmptyString(cellId)) {
        cellCls = [ExploreCellHelper cellClassFromData:data];
        if (cellCls) {
            cellId = NSStringFromClass(cellCls);
        }
    }

    return cellId;
}

#pragma mark - TTCellDataHelper

+ (Class)cellClassFromData:(id)data
{
    ExploreCellViewType cellViewType = ExploreCellViewTypeNotSupport;
    
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        
        if ([orderedData.originalData isKindOfClass:[Article class]]) {
            Article *article = (Article *)orderedData.originalData;

            if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle10){
                if (!isEmptyString(article.title) && !isEmptyString(article.abstract) &&article.middleImageDict.count > 0) {
                    //问答的cell
                    cellViewType = ExploreCellViewTypeWenDaLayOutCell;
                    return [self cellClassFromCellViewType:cellViewType data:data];
                }
            }
            
            if ([orderedData.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle201 || [orderedData.cellLayoutStyle integerValue] == TTLayoutCellLayOutStyle202) {
                //热点要闻卡片cell
                cellViewType = ExploreCellViewTypeArticleHotNews;
                return [self cellClassFromCellViewType:cellViewType data:data];
            }
            
            //根据网络状况调整cellViewType
            TTNetworkTrafficSetting settingType = [TTUserSettingsManager networkTrafficSetting];
            
            BOOL adNeedOptimum = (!isEmptyString(orderedData.ad_id) && settingType != TTNetworkTrafficSave);
            
            //最优先判断置顶样式
            if (TTNetworkWifiConnected() || settingType == TTNetworkTrafficOptimum || adNeedOptimum) {
                // 网络变化时仍保持之前的cell样式
                if (orderedData.cellTypeCached > 0) {
                    return [self cellClassFromCellViewType:orderedData.cellTypeCached data:orderedData];
                }
                    
                //优先判断图片频道cell
                if ([article.gallaryFlag integerValue] && [article.listGroupImgDicts count] > 0) {
                    if ([article.gallaryFlag integerValue] == 1) {
                        if (orderedData.gallaryStyle == 1) {
                            cellViewType = ExploreCellViewTypeArticleTitleLargePic;
                        } else {
                            cellViewType = ExploreCellViewTypeGallaryLargePic;
                        }
                    } else {
                        if (orderedData.gallaryStyle == 1) {
                            
                            cellViewType = ExploreCellViewTypeArticleTitleMultiPic;
                        } else {
                            cellViewType = ExploreCellViewTypeGallaryGroupPic;
                        }
                    }
                }
                else if ([orderedData.listLargeImageDict count] > 0) {
                    if ([[article hasVideo] boolValue]) {
                        
                        ExploreOrderedDataVideoStyle videoStyle = orderedData.videoStyle;
                        cellViewType = [self cellViewTypeForVideoStyle:videoStyle withData:article];
                        
                    }
                    else if ([article.picDisplayType integerValue] == 6) {
                        // 全景广告
                        cellViewType = ExploreCellViewTypeArticleFullView;
                    }
                    else if ([article.picDisplayType integerValue] == 9) {
                        // 3D全景广告
                        cellViewType = ExploreCellViewTypeArticle3DFullView;
                    }
                    else {
                        cellViewType = ExploreCellViewTypeArticleTitleLargePic;
                    }
                }
                else if ([article.listGroupImgDicts count] > 0) {
                    
                    if ([article articlePictureDidsplayType] == TTAdFeedDataDisplayTypeLoop) {
                        cellViewType = ExploreCellViewTypeArticleTtileLoopPic;
                    }
                    else {
                        cellViewType = ExploreCellViewTypeArticleTitleMultiPic;
                    }
                }
                else if ([article.middleImageDict count] > 0) {
                    
                    cellViewType = ExploreCellViewTypeArticleTitleRightPic;
                    
                    NSInteger videoType = 0;
                    if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
                        videoType = ((NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"]).integerValue;
                    }
                    if (videoType == 1) {
                        cellViewType = ExploreCellViewTypeArticleTitleRightPicLive;
                    }
            
                }
                else {
                    
                    cellViewType = ExploreCellViewTypeArticlePureTitle;
                }
                
                orderedData.cellTypeCached = cellViewType;
            }
            // 非wifi下图片频道cell依然显示大图
            else if ([article.gallaryFlag integerValue] && [article.listGroupImgDicts count] > 0) {
                if ([article.gallaryFlag integerValue] == 1) {
                    if (orderedData.gallaryStyle == 1) {
                        
                        cellViewType = ExploreCellViewTypeArticleTitleLargePic;
                    } else {
                        cellViewType = ExploreCellViewTypeGallaryLargePic;
                    }
                } else {
                    if (orderedData.gallaryStyle == 1) {
                        
                        cellViewType = ExploreCellViewTypeArticleTitleMultiPic;
                    } else {
                        cellViewType = ExploreCellViewTypeGallaryGroupPic;
                    }
                }
            }
            // 视频cell
            else  if ([orderedData.listLargeImageDict count] > 0 && [[article hasVideo] boolValue] && orderedData.isListShowPlayVideoButton) {
                ExploreOrderedDataVideoStyle videoStyle = orderedData.videoStyle;
                cellViewType = [self cellViewTypeForVideoStyle:videoStyle withData:article];
            }
            else if (settingType == TTNetworkTrafficMedium) {
                // 网络变化时仍保持之前的cell样式
                if (orderedData.cellTypeCached > 0) {
                    return [self cellClassFromCellViewType:orderedData.cellTypeCached data:orderedData];
                }

                if ([article.middleImageDict count] > 0) {
                    
                    cellViewType = ExploreCellViewTypeArticleTitleRightPic;
                }
                else {
                    
                    cellViewType = ExploreCellViewTypeArticlePureTitle;
                }
                orderedData.cellTypeCached = cellViewType;

            }
            else if (settingType == TTNetworkTrafficSave) {
                // 网络变化时仍保持之前的cell样式
                if (orderedData.cellTypeCached > 0) {
                    return [self cellClassFromCellViewType:orderedData.cellTypeCached data:orderedData];
                }

                if ([article.middleImageDict count] > 0) {
                    
                    cellViewType = ExploreCellViewTypeArticleTitleRightPic;
                }
                else {
                    
                    cellViewType = ExploreCellViewTypeArticlePureTitle;
                }
                orderedData.cellTypeCached = cellViewType;
                
            } else {

                cellViewType = ExploreCellViewTypeArticlePureTitle;
            }
            
        }
//        else if ([orderedData.originalData isKindOfClass:[FantasyCardData class]]) {
//
//            cellViewType = ExploreCellViewTypeFantasyCardCell;
//
//        }
//        else if ([orderedData.originalData isKindOfClass:[SurveyListData class]]) {
//
//            cellViewType = ExploreCellViewTypeSurveyListCell;
//
//        }
//        else if ([orderedData.originalData isKindOfClass:[SurveyPairData class]]) {
//
//            cellViewType = ExploreCellViewTypeSurveyPairCell;
//
//        }
        else if ([orderedData.originalData isKindOfClass:[WapData class]]) {
            cellViewType = ExploreCellViewTypeWeb;
        }
        else if ([orderedData.originalData isKindOfClass:[StockData class]]){
            cellViewType = ExploreCellViewTypeStock;
        }
//        else if ([orderedData.originalData isKindOfClass:[Live class]]) {
//            Live *live = (Live *)orderedData.originalData;
//            if ([live.type isEqual: @2]) {
//                cellViewType = ExploreCellViewTypeLiveMatch;
//            } else if ([live.type isEqual: @1]) {
//                cellViewType = ExploreCellViewTypeLiveStar;
//            } else if ([live.type isEqual: @3]) {
//                cellViewType = ExploreCellViewTypeLiveVideo;
//            } else if ([live.type isEqual: @4]) {
//                cellViewType = ExploreCellViewTypeLiveSimple;
//            }
//            else {
//                cellViewType = ExploreCellViewTypeNotSupport;
//            }
//        }
//        else if ([orderedData.originalData isKindOfClass:[HuoShan class]]) {
//            //不同频道对应不同的cell
//            if ([orderedData.categoryID isEqualToString:@"__all__"]) {
//                cellViewType = ExploreCellViewTypeArticleTitleLargePicHuoShan;
//            }
//            else if ([orderedData.categoryID isEqualToString:@"hotsoon"]) {
//                cellViewType = ExploreCellViewTypeVideoTabHuoShan;
//            }
//            else if ([orderedData.categoryID isEqualToString:@"image_ppmm"]) {
//                cellViewType = ExploreCellViewTypeMeiNvHuoShan;
//            }
//            else  {
//                cellViewType = ExploreCellViewTypeArticleTitleLargePicHuoShan;
//            }
//
//        }
        else if ([orderedData.originalData isKindOfClass:[Card class]]) {
            cellViewType = ExploreCellViewTypeCard;
        }
        else if ([orderedData.originalData isKindOfClass:[LastRead class]]) {
            cellViewType = ExploreCellViewTypeLastRead;
        }
        else if ([orderedData.originalData isKindOfClass:[LianZai class]]){
            cellViewType = ExploreCellViewTypeLianZai;
        }
        else if ([orderedData.originalData isKindOfClass:[RNData class]]){
            if (orderedData.cellType == ExploreOrderedDataCellTypeDynamicRN) {
                cellViewType = ExploreCellViewTypeDynamicRN;
            } else {
                cellViewType = ExploreCellViewTypeRN;
            }
        }
        else if ([orderedData.originalData isKindOfClass:[Book class]])
        {
            cellViewType = ExploreCellViewTypeCollectionBookCell;
        }
//        else if ([orderedData.originalData isKindOfClass:[RecommendUserCardsData class]])
//        {
//            cellViewType = ExploreCellViewTypeCardRecommendUserCardCell;
//        }
        else if ([orderedData.originalData isKindOfClass:[TTCategoryAddToFirstPageData class]]) {
            cellViewType = ExploreCellViewTypeAddToFirstPageCell;
        }
        else if ([orderedData.originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
            cellViewType = ExploreCellViewTypeShortVideoCell;
        }
        else if ([orderedData.originalData isKindOfClass:[HorizontalCard class]]) {
            cellViewType = ExploreCellViewTypeHorizontalCard;
        }
//        else if ([orderedData.originalData isKindOfClass:[TSVStoryOriginalData class]]) {
//            cellViewType =  ExploreCellViewTypeTSVStoryCell;
//        }
        else if ([orderedData.originalData isKindOfClass:[ResurfaceData class]]){
            cellViewType = ExploreCellViewTypeResurface;
        }
//        else if ([orderedData.originalData isKindOfClass:[RecommendUserLargeCardData class]])
//        {
//            cellViewType = ExploreCellViewTypeRecommendUserLargeCardCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[TTHashtagCardData class]])
//        {
//            cellViewType = ExploreCellViewTypeHashtagRightPicCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[MomentsRecommendUserData class]])
//        {
//            cellViewType = ExploreCellViewTypeMomentsRecommendUserCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[RecommendRedpacketData class]])
//        {
//            cellViewType = ExploreCellViewTypeRecommendRedPacketCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[PopularHashtagData class]])
//        {
//            cellViewType = ExploreCellViewTypePopularHashtagCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[TTXiguaLiveModel class]])
//        {
//            cellViewType = ExploreCellViewTypeXiguaLargePicCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[TTXiguaLiveCardHorizontal class]])
//        {
//            cellViewType = ExploreCellViewTypeXiguaHorizontalCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[TTXiguaLiveRecommendUser class]])
//        {
//            cellViewType = ExploreCellViewTypeXiguaRecommendCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[RecommendUserStoryCardData class]]) {
//            cellViewType = ExploreCellViewTypeRecommendUserStoryCardCell;
//        }
//        else if ([orderedData.originalData isKindOfClass:[RecommendStoryCoverCardData class]]) {
//            cellViewType = ExploreCellViewTypeRecommendStoryCoverCardCell;
//        }
        else if ([orderedData.originalData isKindOfClass:[TTHotNewsData class]])
        {
            cellViewType = ExploreCellViewTypeHotNews;
        }
        else if ([orderedData.originalData isKindOfClass:[TTExploreLoadMoreTipData class]]) {
            cellViewType = ExploreCellViewTypeLoadmoreTipCell;
        }
        // add by zjing 房源卡片
        else if ([orderedData.originalData isKindOfClass:[FHExploreHouseItemData class]]) {
            cellViewType = ExploreCellViewTypeFHHouseItemCell;
        }
        else {
            cellViewType = ExploreCellViewTypeNotSupport;
        }
    }
    
    return [self cellClassFromCellViewType:cellViewType data:data];
}

#pragma mark - helper methods

+ (void)refreshMidnightInterval
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    NSTimeInterval midnightInterval = [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
    
    [s_cellHelper setMidInterval:midnightInterval];
    //});
}

+ (CGFloat)heightForImageWidth:(CGFloat)width height:(CGFloat)height constraintWidth:(CGFloat)cWidth
{
    // 图片model的宽度为0时，按16：9宽高比计算图片高度
    if (width == 0) {
        width = cWidth;
        height = cWidth * 9 / 16.f;
        if (width == 0) {
            return 0;
        }
    }

    if ([TTDeviceHelper isPadDevice])
    {
        return  height * cWidth / width;
    }
    else if ([TTDeviceHelper isScreenWidthLarge320]) {
        return  MIN(height * cWidth / width, 286);
    }
    else {
        return  MIN(height * cWidth / width, 200);
    }
}

+ (CGFloat)heightForLoopImageWidth:(CGFloat)width height:(CGFloat)height constraintWidth:(CGFloat)cWidth
{
    // 图片model的宽度为0时，按16：9宽高比计算图片高度
    if (width == 0) {
        width = cWidth;
        height = cWidth * 9 / 16.f;
        if (width == 0) {
            return 0;
        }
    }
    
    if ([TTDeviceHelper isPadDevice])
    {
        return  height * cWidth / width;
    }
    else if ([TTDeviceHelper isScreenWidthLarge320]) {
        return  MIN(height * cWidth / width, cWidth);
    }
    else {
        return  MIN(height * cWidth / width, cWidth);
    }
}

+ (float)heightForVideoImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth {
    // 图片model的宽度为0时，按16：9宽高比计算图片高度
    if (width == 0) {
        width = cWidth;
        height = cWidth * 9 / 16.0;
        if (width == 0) {
            return 0;
        }
    }
    
    return roundf(height * cWidth / width);
}

+ (CGFloat)largeImageWidth:(CGFloat)cellWidth
{
    return cellWidth - kCellLeftPadding - kCellRightPadding;
}

+ (BOOL)shouldDisplayAbstract:(Article*)article listType:(ExploreOrderedDataListType)listType
{
    BOOL result = NO;
    
    if(listType == ExploreOrderedDataListTypeFavorite
       || listType == ExploreOrderedDataListTypeReadHistory
       || listType == ExploreOrderedDataListTypePushHistory)
    {
        if([TTDeviceHelper isPadDevice])
        {
            result = ([NewsLogicSetting userSetReadMode] == ReadModeAbstract);
        }
        else
        {
            result = NO;
        }
    }
    else if ([NewsLogicSetting userSetReadMode] == ReadModeAbstract)
    {
        result = YES;
    }
    
    return result;
}

+ (BOOL)shouldDisplayComment:(Article*)article listType:(ExploreOrderedDataListType)listType
{
    BOOL result = NO;
    if((listType == ExploreOrderedDataListTypeFavorite || listType == ExploreOrderedDataListTypeReadHistory || listType == ExploreOrderedDataListTypePushHistory) || [TTDeviceHelper isPadDevice])
    {
        result = NO;
    }
    else if([article.displayComment isKindOfClass:[NSDictionary class]])
    {
        result = YES;
    }
    
    return result;
}

+ (CGSize)updateAbstractSize:(Article*)article cellWidth:(CGFloat)cellWidth
{
    CGSize result = CGSizeZero;
    float abstractWidth = cellWidth - kCellRightPadding - kCellLeftPadding;

    if (!isEmptyString(article.abstract)) {
        NSMutableAttributedString *attributedString = [TTLabelTextHelper attributedStringWithString:article.abstract fontSize:kCellAbstractViewFontSize lineHeight:kCellAbstractViewLineHeight];
        
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString withConstraints:CGSizeMake(abstractWidth, 999) limitedToNumberOfLines:0];

        result.width = abstractWidth;
        result.height = ceil(size.height);
    }
    
    return result;
}

//static NSArray *s_constraintArray = [NSArray arrayWithObjects:@50, @60, @65, @70, nil];
//static int s_constraintArray[] = {50, 60, 65, 70};

+ (CGSize)updateCommentSize:(NSString*)commentContent cellWidth:(CGFloat)cellWidth
{
    CGSize result = CGSizeZero;
    
    if (!isEmptyString(commentContent)) {
        NSMutableAttributedString *attributedString = [TTLabelTextHelper attributedStringWithString:commentContent fontSize:kCellCommentViewFontSize lineHeight:kCellCommentViewLineHeight];

        CGFloat commentWidth = cellWidth - kCellLeftPadding - kCellRightPadding - kCellCommentViewHorizontalPadding * 2;
        
        CGSize bound = CGSizeMake(commentWidth, kCellCommentViewLineHeight * kCellCommentViewMaxLine);

        CGRect r = [attributedString boundingRectWithSize:bound options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (r.size.height > bound.height) {
            r.size.height = bound.height;
        }
        
        result.width = ceil(commentWidth + kCellCommentViewHorizontalPadding * 2);
        result.height = ceil(r.size.height + kCellCommentViewVerticalPadding *2 - kCellCommentViewCorrect);
    }
    
    return result;
}



+ (CGSize)resizablePicSizeByWidth:(CGFloat)width
{
    static float w = 0;
    static float h = 0;
    static float cellW = 0;
    if (h < 1 || cellW != width) {
        cellW = width;
        float picOffsetX = kCellGroupPicPadding;
        w = MAX(0, (width - kCellLeftPadding - kCellRightPadding - picOffsetX * 2) / 3);
        h = w * 0.6526f;
        w = ceilf(w);
        h = ceilf(h);
    }
    return CGSizeMake(w, h);
}

+ (CGSize)commentMomentCellPicSize
{
    return CGSizeMake(98.3, 98.3);
}

+ (CGSize)singlePicSize
{
    //cell单张图片尺寸
    return CGSizeMake(197, 150);
}

// 右图cell不感兴趣按钮与右图的间隔调整
+ (CGFloat)paddingBetweenInfoBarAndPic {
    static CGFloat pad = 0;
    if (pad < 1) {
        if ([TTDeviceHelper is736Screen]) {
            pad = 5;
        } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            pad = 11;
        } else {
            pad = 2;
        }
    }
    
    return pad;
}

+ (void)layoutTypeLabel:(UILabel *)typeLabel
        withOrderedData:(ExploreOrderedData *)orderedData {
    //typeLabel.backgroundColorThemeKey = kColorBackground4;
    typeLabel.textAlignment  = NSTextAlignmentCenter;
    typeLabel.font = [UIFont systemFontOfSize:cellTypeLabelFontSize()];
    typeLabel.layer.cornerRadius = kCellTypeLabelCornerRadius;
    typeLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    
    typeLabel.text = nil;
    
    if (!isEmptyString(orderedData.displayLabel)) {
        typeLabel.text = orderedData.displayLabel;
    } else if (orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        NSString *typeString = [orderedData displayLabel]?:NSLocalizedString(@"广告", nil);
        typeLabel.text = typeString;
    }
    
    if (orderedData.stickStyle > 0) {//置顶cell
        
        NSString * stickLabelStr =orderedData.stickLabel;
        if (isEmptyString(stickLabelStr)) {
            stickLabelStr = NSLocalizedString(@"置顶", nil);
        }
        typeLabel.text = stickLabelStr;
    }
    else {
        if ((orderedData.tip & 1) > 0) {
            typeLabel.text = NSLocalizedString(@"热", nil);
        } else if ((orderedData.tip & 2) > 0) {
            typeLabel.text = NSLocalizedString(@"荐", nil);
        }
    }

    [typeLabel sizeToFit];
    CGFloat w = typeLabel.width + kCellTypeLabelInnerPadding * 2;
    CGFloat h = kCellTypeLabelHeight;
    typeLabel.size = CGSizeMake(w, h);
    
    [self colorTypeLabel:typeLabel orderedData:orderedData];
}

+ (void)colorTypeLabel:(UILabel *)typeLabel orderedData:(id)orderedData {
    NSInteger labelStyle = ArticleLabelTypeUnkown;
    
    if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *data = (ExploreOrderedData *)orderedData;
     
        if (data.cellType == ExploreOrderedDataCellTypeAppDownload) {
            if (data.labelStyle == 0) {
                labelStyle = ArticleLabelTypePromote;
            } else {
                labelStyle = data.labelStyle;
            }
        } else {
            if (!isEmptyString(data.displayLabel) || data.stickStyle != 0) {
                labelStyle = data.labelStyle;
            } else {
                if ((data.tip & 3) > 0) {
                    // 热/荐
                    labelStyle = ArticleLabelTypeTopic;
                } else {
                    labelStyle = ArticleLabelTypeUnkown;
                }
            }
        }
    }
    
    UIColor *textClr = nil;
    UIColor *borderClr = nil;

    switch (labelStyle) {
        case ArticleLabelTypeTopic://专题
        case ArticleLabelTypeHeadline://要闻
            textClr = [UIColor tt_themedColorForKey:kCellTypeLabelTextRed];
            borderClr = [UIColor tt_themedColorForKey:kCellTypeLabelLineRed];
            break;
            
        case ArticleLabelTypeComics:
            //漫画
            textClr = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"e67bb2" nightColorName:@"6b4458"]];
            borderClr = textClr;
            break;
            
        case ArticleLabelTypeEssay:
            //段子
            textClr = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"47cfb7" nightColorName:@"31625a"]];
            borderClr = textClr;
            break;
            
        case ArticleLabelTypePromote:
        case ArticleLabelTypeGIF:
            //GIF
            textClr = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"2a90d7" nightColorName:@"67778b"]];

            borderClr = textClr;
            break;
            
        case ArticleLabelTypeCity:
            //地方
            textClr = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"2a90d7" nightColorName:@"274c65"]];
            borderClr = textClr;
            break;
            
        case ArticleLabelTypePicture:
            //美图
            textClr = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"ff7a7a" nightColorName:@"744444"]];
            borderClr = textClr;
            break;
            
        case ArticleLabelTypeUnkown:
        default:
            textClr = [UIColor tt_themedColorForKey:kColorText3];
            borderClr = [UIColor tt_themedColorForKey:kColorLine1];
            break;
    }

    typeLabel.textColor = textClr;
    typeLabel.layer.borderColor = borderClr.CGColor;
}

+ (BOOL)shouldDownloadImage
{
    return (TTNetworkWifiConnected() || [TTDeviceHelper isPadDevice] || [TTUserSettingsManager networkTrafficSetting] != TTNetworkTrafficSave);
}

+ (BOOL)shouldShowEssayActionButtons:(NSString *)categoryID
{
    if (!isEmptyString(categoryID)) {
        NSArray *essayCategories = [[TTArticleCategoryManager sharedManager] essayCatgegories];
        NSArray *imageCategories = [[TTArticleCategoryManager sharedManager] imageCategories];
        NSMutableArray *allArray = [NSMutableArray arrayWithArray:essayCategories];
        [allArray addObjectsFromArray:imageCategories];
        for (TTCategory *categoryModel in allArray) {
            if ([categoryModel.categoryID isEqualToString:categoryID]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - 视频频道顶踩全局控制

static NSInteger __showListDig = 1000;

+ (BOOL)isShowListDig
{
    if (__showListDig == 1000) {//默认显示
        NSInteger b = [[NSUserDefaults standardUserDefaults] integerForKey:kVideoShowListDigg];
        __showListDig = b;
    }
    return __showListDig > 0;
}

+ (void)setShowListDig:(NSInteger)bShow
{
    __showListDig = bShow;
    [[NSUserDefaults standardUserDefaults] setInteger:bShow forKey:kVideoShowListDigg];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - ABTest
+ (BOOL)userDidSetFeedUGCTest {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"MixListBaseViewABTest"]) {
        return NO;
    }
    return YES;
}

+ (BOOL)getFeedUGCTest {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"MixListBaseViewABTest"] boolValue];
}

+ (void)setFeedUGCTest:(BOOL)abTest {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:abTest] forKey:@"MixListBaseViewABTest"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"kClearCachedCellTypeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kReadModeChangeNotification" object:nil];
}

+ (BOOL)getSourceImgTest {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"ExploreArticleCellViewSourceImgTest"] boolValue];
}

+ (void)setSourceImgTest:(BOOL)abTest {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:abTest] forKey:@"ExploreArticleCellViewSourceImgTest"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
