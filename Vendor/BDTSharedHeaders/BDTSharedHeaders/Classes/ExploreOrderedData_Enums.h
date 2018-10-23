//
//  ExploreOrderedData_Enums.h
//  Pods
//
//  Created by pei yun on 2017/9/25.
//

#ifndef ExploreOrderedData_Enums_h
#define ExploreOrderedData_Enums_h

/**
 *  用于区分列表类型
 */
typedef NS_ENUM(NSUInteger, ExploreOrderedDataListType)
{
    /**
     *  普通列表
     */
    ExploreOrderedDataListTypeCategory = 0,
    /**
     *  搜索列表
     */
    ExploreOrderedDataListTypeSearch = 1,
    /**
     *  收藏列表
     */
    ExploreOrderedDataListTypeFavorite = 2,
    /**
     *  entry类型列表， (如pgc)
     */
    ExploreOrderedDataListTypeEntry = 3,
    /**
     *  关心主页帖子列表
     */
    ExploreOrderedDataListTypeConcernHomepageThread = 4,
    /**
     *  阅读历史列表
     */
    ExploreOrderedDataListTypeReadHistory = 5,
    /**
     *  推送历史列表
     */
    ExploreOrderedDataListTypePushHistory = 6,
    /**
     * 列表类型总数，这条必须是最后一条，其他在上边
     */
    ExploreOrderedDataListTypeTotalCount
};

typedef NS_ENUM(NSUInteger, ExploreOrderedDataCellType)
{
    ExploreOrderedDataCellTypeArticle                   = 0,//文章，                  持久存储
    ExploreOrderedDataCellTypeEssay                     = 3,//段子，                  持久存储
    ExploreOrderedDataCellTypeAppDownload               = 10,//新版本下载广告，          持久存储
    ExploreOrderedDataCellTypeCard                      = 17,//卡片                   持久存储
    ExploreOrderedDataCellTypeWeb                       = 25,//WEB
    ExploreOrderedDataCellTypeThread                    = 32,//UGC话题帖子              持久存储
    ExploreOrderedDataCellTypeLive                      = 33,//直播入口                 持久存储
    ExploreOrderedDataCellTypeStock                     = 34,//自选股入口               持久存储
    ExploreOrderedDataCellTypeHuoShan                   = 35,//火山直播                 持久存储
    ExploreOrderedWenDaCategoryBaseCell                 = 36,//问答频道基础cell          持久存储
    ExploreOrderedDataCellTypeLianZai                   = 37,//连载                     持久存储
    ExploreOrderedDataCellTypeRN                        = 38,//RN                      持久存储
    ExploreOrderedDataCellTypeInterestGuide             = 39,//兴趣引导                 持久存储
    ExploreOrderedDataCellTypeComment                   = 41,//评论文章                 持久存储
    ExploreOrderedDataCellTypeBook                      = 42,//推荐多本小说              持久存储
    ExploreOrderedWenDaInviteCellType                   = 43,//问答频道的邀请回答类型
    ExploreOrderedAddToFirstPageCellType                = 44,//将频道添加到首屏
    ExploreOrderedDataCellTypeHorizontalCard            = 48,//水平卡片                 持久存储
    ExploreOrderedDataCellTypeShortVideo                = 49,//ugc video cell
    ExploreOrderedDataCellTypeRecommendUser             = 50,//关注频道一起上线的新推人卡片             持久存储
    ExploreOrderedDataCellTypeRecommendUserLargeCard    = 51,//列表猛烈推人卡片             持久存储
    ExploreOrderedDataCellTypeResurface                 = 52,//换肤引导Celltype         持久存储
    ExploreOrderedDataCellTypeDynamicRN                 = 53,//新版RN，支持加载指定的bundle,动态获取数据 持久存储
    ExploreOrderedDataCellTypeMomentsRecommendUser      = 54,//好友动态推人卡片             持久存储
    
    ExploreOrderedDataCellTypeEssayAD                   = 55,//段子引导，                  持久存储
    ExploreOrderedDataCellTypeSurveyList                = 57,//用户调研List类型卡片，        持久存储
    ExploreOrderedDataCellTypeSurveyPair                = 58,//用户调研Pair类型卡片，        持久存储
    ExploreOrderedDataCellTypeCommentRepost             = 56,//新转发cell，model以comment为基础       持久存储
    ExploreOrderedDataCellTypeShortVideoRecommendUserCard   = 61,//小视频推人卡片
    ExploreOrderedDataCellTypeRedpacketRecommendUser    = 62,//红包推人
    
    ExploreOrderedDataCellTypeHashtag                   = 65,//话题
    ExploreOrderedDataCellTypeShortVideoStory           = 66,//小视频Story
    ExploreOrderedDataCellTypeShortVideoActivityEntrance = 67,//小视频活动入口
    ExploreOrderedDataCellTypeShortVideoActivityBanner   = 68,//小视频活动banner
    ExploreOrderedDataCellTypeShortVideo_AD             = 69,//小视频draw_ad
    ExploreOrderedDataCellTypeRecommendUserStoryCard    = 70,//推荐用户Story         持久存储
    ExploreOrderedDataCellTypeFantasyCard               = 71,//Fantasy活动入口       持久存储
    ExploreOrderedDataCellTypeRecommendStoryCoverCard   = 72, //推荐用户Story内容封面图    持久存储
    ExploreOrderedDataCellTypeTopPopularHashtag         = 73,//热门话题
    ExploreOrderedDataCellTypeHotNews              = 74,//置顶热点新闻  单条模式
    ExploreOrderedDataCellTypeLoadMoreTip               = 75, // load more 弹出的提示信息， 不持久化
    
    ExploreOrderedWenDaCategoryHeaderInfoCell           = 201,//问答频道顶部cell      持久存储
    ExploreOrderedDataCellTypeWendaAnswer               = 202, //问答cell (回答)
    ExploreOrderedDataCellTypeWendaQuestion             = 203, //问答cell (提问)
    
    ExploreOrderedDataCellTypeXiguaLive                 = 304,//西瓜直播卡片
    ExploreOrderedDataCellTypeXiguaLiveHorizontal       = 305,//西瓜直播水平
    ExploreOrderedDataCellTypeXiguaLiveRecommend        = 306,//西瓜直播推人
    ExploreOrderedDataCellTypeShortVideoPublishStatus   = 300, //小视频发布状态
    
    ExploreOrderedDataCellTypeLastRead                  = 1000,//上次看到这              持久存储
    ExploreOrderedDataCellTypeLogin                     = 1001,//登录卡片                不持久化
    
    //当检测到orderdata.nextCellType == ExploreOrderedDataCellTypeNull代表是列表中最后一个cell，当preCellType == ExploreOrderedDataCellTypeNull代表是列表中的第一个cell
    ExploreOrderedDataCellTypeNull                      = 1002,//哨兵celltype
};

typedef NS_ENUM(NSUInteger, ExploreOrderedDataThreadUIType) {
    ExploreOrderedDataThreadUITypeArticle   = 1,//帖子UI样式为文章样式
    ExploreOrderedDataThreadUITypeContent   = 2,//帖子UI样式为内容样式
};

#endif /* ExploreOrderedData_Enums_h */
