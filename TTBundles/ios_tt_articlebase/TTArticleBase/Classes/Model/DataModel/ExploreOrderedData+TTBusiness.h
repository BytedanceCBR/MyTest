//
//  ExploreOrderedData+TTBusiness.h
//  Article
//
//  Created by pei yun on 2017/9/25.
//

#import "ExploreOrderedData.h"
#import "ExploreCellBase.h"


//@class Live;
@class Card;
@class FRRedpackStructModel;
@class Article;
@class Thread;
@class WapData;
@class StockData;
@class HuoShan;
@class LianZai;
@class RNData;
@class LastRead;
@class WenDaInviteData;
@class WDHeaderInfoCellData;
@class TTImageInfosModel;
@class Comment;
@class Book;
//@class RecommendUserCardsData;
@class TTCategoryAddToFirstPageData;
@class TSVShortVideoOriginalData;
@class TTWenda;
@class HorizontalCard;
//@class RecommendUserLargeCardData;
//@class RecommendUserStoryCardData;
//@class RecommendStoryCoverCardData;
//@class MomentsRecommendUserData;
//@class FantasyCardData;
//@class SurveyListData;
//@class SurveyPairData;
@class WenDaBaseData;
@class ResurfaceData;
@class TSVRecUserCardOriginalData;
@class RecommendRedpacketData;
@class FRCommentRepost;
@class TTHashtagCardData;
//@class TTXiguaLiveModel;
//@class TTXiguaLiveCardHorizontal;
//@class TTXiguaLiveRecommendUser;
@class TSVActivityEntranceOriginalData;
@class TSVActivityBannerOriginalData;
@class TSVPublishStatusOriginalData;
@class TSVStoryOriginalData;
//@class PopularHashtagData;
@class TTExploreLoadMoreTipData;
@class TTLayOutCellBaseModel;
@class UGCBaseCellLayoutModel;
@class TTADTrackEventLinkModel;
@class TTHotNewsData;

@class FHExploreHouseItemData;


@interface ExploreOrderedData (TTBusiness)

// 关联对象
@property (nonatomic, retain, nullable) Thread          *thread;
@property (nonatomic, retain, nullable) WapData         *wapData;
@property (nonatomic, retain, nullable) StockData       *stockData;
//@property (nonatomic, retain, nullable) Live            *live;
@property (nonatomic, retain, nullable) HuoShan         *huoShan;
@property (nonatomic, retain, nullable) Card            *card;
@property (nonatomic, retain, nullable) LastRead        *lastRead;
@property (nonatomic, retain, nullable) LianZai         *lianZai;
@property (nonatomic, retain, nullable) RNData          *rnData;
@property (nonatomic, retain, nullable) Book            *book;
@property (nonatomic, retain, nullable) Comment         *comment;
//@property (nonatomic, retain, nullable) RecommendUserCardsData   *recommendUserCardsData;
@property (nonatomic, retain, nullable) TTCategoryAddToFirstPageData   *addToFirstPageData;
@property (nonatomic, retain, nullable) TSVShortVideoOriginalData        *shortVideoOriginalData;
@property (nonatomic, retain, nullable) TTWenda         *ttWenda;
@property (nonatomic, retain, nullable) HorizontalCard  *horizontalCard;
@property (nonatomic, retain, nullable) ResurfaceData   *resurface;
//@property (nonatomic, retain, nullable) RecommendUserLargeCardData   *recommendUserLargeCardData;
//@property (nonatomic, retain, nullable) RecommendUserStoryCardData   *recommendUserStoryCardData;
//@property (nonatomic, retain, nullable) RecommendStoryCoverCardData  *recommendUserStoryCoverCardData;
//@property (nonatomic, retain, nullable) MomentsRecommendUserData   *momentsRecommendUserData;
@property (nonatomic, retain, nullable) FRCommentRepost   *commentRepostModel;
//@property (nonatomic, retain, nullable) FantasyCardData   *fantasyCardData;
@property (nonatomic, retain, nullable) TTExploreLoadMoreTipData *loadmoreTipData;
//@property (nonatomic, retain, nullable) SurveyListData   *surveyListData;
//@property (nonatomic, retain, nullable) SurveyPairData   *surveyPairData;
@property (nonatomic, retain, nullable) TSVRecUserCardOriginalData   *tsvRecUserCardOriginalData;
@property (nonatomic, retain, nullable) RecommendRedpacketData *recommendRedpacketData;
//@property (nonatomic, retain, nullable) PopularHashtagData *popularHashtagData;
//@property (nonatomic, retain, readwrite, nullable) FRRedpackStructModel * redpacketModel;
@property (nonatomic, retain, nullable) NSDictionary *ugcRecommendDict;//推荐理由挪到最外层，该值与具体model其实无关
@property (nonatomic, retain, nullable) TTHashtagCardData *hashtagData;
//@property (nonatomic, retain, nullable) TTXiguaLiveRecommendUser *xiguaLiveRecommendUser;
//@property (nonatomic, retain, nullable) TTXiguaLiveCardHorizontal *xiguaLiveCardHorizontal;
//@property (nonatomic, retain, nullable) TTXiguaLiveModel *xiguaLiveModel;
@property (nonatomic, retain, nullable) TSVPublishStatusOriginalData *tsvPublishStatusOriginalData;
//@property (nonatomic, retain, nullable) TSVStoryOriginalData *tsvStoryOriginalData;

@property (nonatomic, retain, nullable) TSVActivityEntranceOriginalData *tsvActivityEntranceOriginalData;
@property (nonatomic, retain, nullable) TSVActivityBannerOriginalData *tsvActivityBannerOriginalData;
@property (nonatomic, retain, nullable) TTHotNewsData *hotNewsData;

@property (nonatomic, retain, nullable) FHExploreHouseItemData *houseItemsData;

/**
 *  cell的Layout层
 */
@property (nonatomic, strong, nullable) TTLayOutCellBaseModel *cellLayOut;

/**
 *  cell在列表里的展示顺序
 */
@property (nonatomic) long long itemIndex;

@property (nonatomic, copy, nullable) NSString *debugInfo;

/**
 *  帖子cell的layout
 */
@property (nonatomic, strong, nullable) UGCBaseCellLayoutModel * ugcCellLayout;

- (ExploreOriginalData *_Nullable)originalData;

/// 这个方法是犹豫 要优先使用adLabel, 然后使用Label，该方法会根据adLabel和Label返回有效的label
- (nullable NSString *) displayLabel;

/**
 获得ordereddata的key
 
 @param dictionary 拼取key需要的值
 @return 返回key
 */
+ (nonnull NSString *)primaryIDFromDictionary:(nonnull NSDictionary *)dictionary;


/**
 *  缓存的高度
 *
 *  @param cellType cell的类型
 *
 *  @return 如果返回小于等于0的数，说明没有缓存。大于0的数有效
 */
- (CGFloat)cacheHeightForListType:(ExploreOrderedDataListType)listType;
- (void)saveCacheHeight:(CGFloat)height forListType:(ExploreOrderedDataListType)listType;

- (CGFloat)cacheHeightForListType:(ExploreOrderedDataListType)listType cellType:(NSUInteger)cellType;
- (void)saveCacheHeight:(CGFloat)height forListType:(ExploreOrderedDataListType)listType cellType:(NSUInteger)cellType;

- (CGFloat)cellItemCacheHeightForlistType:(ExploreOrderedDataListType)listType cacheKey:(nullable NSString *)cacheKey;
- (void)saveCellItemCacheHeight:(CGFloat)height listType:(ExploreOrderedDataListType)listType cacheKey:(nullable NSString *)cacheKey;

- (void)clearCacheHeight;

- (void)clearCachedCellType;

/**
 *  用于搜索判断在标题没有命中关键词的情况下是否需要显示摘要
 */
- (BOOL)needShowAbstractWhenNotSet;

/**
 *  是否显示列表页播放视频按钮
 */
- (BOOL)isListShowPlayVideoButton;

/*
 *  视频要进入详情页播放
 */
- (BOOL)isPlayInDetailView;

/**
 *  是否显示推荐理由
 */
- (BOOL)isShowRecommendReasonLabel;
- (BOOL)isShowCommentCountLabel;
- (BOOL)isShowSourceImage;
- (BOOL)isShowSourceLabel;
- (BOOL)isShowTimeLabel;
- (BOOL)isShowDigButton;
- (BOOL)isShowComment;
- (BOOL)isFeedUGC;
- (BOOL)isShowAbstract;

- (nullable NSString *)ugcRecommendReason;
- (nullable NSString *)ugcRecommendAction;

//是否为视频PGC卡片定制UI
- (BOOL)isVideoPGCCard;
- (BOOL)couldAutoPlay;
- (BOOL)couldContinueAutoPlay;
- (BOOL)autoPlayServerEnabled;

//直播是否显示
- (BOOL)isShowMediaLiveTitle;
- (BOOL)isShowMediaLiveViewCount;
- (BOOL)isShowMediaLiveUserInfo;
- (BOOL)isShowHuoShanTitle;
- (BOOL)isShowHuoShanViewCount;
- (BOOL)isShowHuoShanUserInfo;

//是否来源是Feed频道。如果是卡片，则判断卡片内的categoryID是否为Feed
- (BOOL)isFeedCategory;

/**
 * u11 cell的cell_flag控制
 */
- (BOOL)isU11ShowPadding;//是否有上下10pi的padding
- (BOOL)isU11ShowFollowItem;//是否展示关注信息
- (BOOL)isU11ShowRecommendReason;//是否展示推荐理由
- (BOOL)isU11ShowTimeItem;//是否在头部展示时间信息
- (BOOL)isU11ShowFollowButton;//是否显示关注按钮

//使用layout布局时，用来判断是否是哪种类型的cell
- (BOOL)isPlainCell;
- (BOOL)isUGCCell;
- (BOOL)isUnifyADCell;

- (BOOL)isU13CellInStoryMode; // 是否是U13样式cell, 并处于 Story 模式
- (BOOL)isU13Cell; // 是否是U13样式cell
- (BOOL)isU11Cell;
- (BOOL)isU11HasActionButtonCell;
//列表大图model
- (nullable TTImageInfosModel *)listLargeImageModel;

//列表大图dict，兼容旧版本数据，orderedData中的largeImageDict为空时使用article的
- (nullable NSDictionary *)listLargeImageDict;

//是否已读
- (BOOL)hasRead;

/**
 *  清空红包
 */
- (void)clearRedpacket;

/**
 * 热点要闻适配
 * 头像/小红点控制位
 */
- (BOOL)isHotNewsCellWithAvatar;
- (BOOL)isHotNewsCellWithRedDot;

@end
