//
//  ArticleHeader.h
//  Article
//
//  Created by Zhang Leonardo on 14-4-4.
//
//

#ifndef ArticleHeade
#define ArticleHeade

typedef enum ListViewDisplayType
{
    ListViewDisplayTypeNormal = 0,
    ListViewDisplayTypeAction = 1
}ListViewDisplayType;

//articleType的类型， 0(默认)为本地html， 1为加载web类型
typedef NS_ENUM(NSUInteger, ArticleType) {
    ArticleTypeNativeContent = 0,
    ArticleTypeWebContent = 1,
    ArticleTypeTempUGCVideo = 2, //临时加ugc发布视频特殊处理，articleType=2，后续服务端会统一下发0，去掉此逻辑。加上是为了处理后端升级前的缓存数据
};

typedef NS_ENUM(NSUInteger, ArticleSubType) {
    ArticleSubTypeNormalWap = 0,            //普通网站
    ArticleSubTypeCooperationWap = 1,       //合作网站
};

//wap类型，是否预加载
typedef NS_ENUM(NSUInteger, ArticlePreloadWebType) {
    ArticlePreloadWebTypeNoLoad = 0,        //不预加载
    ArticlePreloadWebTypeAlways = 1,        //总是预加载
    ArticlePreloadWebTypeOnlyWifi = 2,       //仅wifi预加载
    ArticlePreloadWebTypeOnlyWifiAndAds = 3, // 针对建站广告，wifi预加载
    ArticlePreloadWebTypeAdsResAlways = 4,   // 针对三方广告落地页资源，全环境预加载
    ArticlePreloadWebTypeAdsResOnlyWifi = 5,  // 针对三方广告落地页资源，wifi预加载
    ArticlePreloadWebTypeAppAd = 6            //针对下载广告预加载
};

typedef enum ArticleGroupType{
    ArticleGroupTypeNormal = 0 ,            //普通文章
    ArticleGroupTypeTopic = 1,              //专题
}ArticleGroupType;

typedef enum ArticleNatantLevel{
    ArticleNatantLevelDefault = 0,           //默认， 对于广告用3， 对于其他类型用1
    ArticleNatantLevelOpen = 1,              //全开，随手滑动，可点击打开
    ArticleNatantLevelHalfClose = 2,         //半关，不可随手，可点击打开
    ArticleNatantLevelHalfOpen = 3,          //半开, 降级随手，可点击打开
    ArticleNatantLevelClose = 99             //全关，不可随手，不可点击
}ArticleNatantLevelType;

/**
 *  group flags
 */
typedef NS_ENUM(NSUInteger, ArticleGroupFlags)
{
    /**
     *  是否有视频
     */
    ArticleGroupFlagsHasVideo = 0x1,
    /**
     *
     */
    ArticleGroupFlagsOpenUseWebViewInList = 0x4,
    /**
     *
     */
    ArticleGroupFlagsClientEscape = 0x10,
    /**
     *
     */
    ArticleGroupFlagsDetailRelateReadShowImg = 0x20,
    /**
     *
     */
    ArticleGroupFlagsDetailTypeVideoSubject = 0x40,
    /**
     *  控制是否要设置UA
     *  置1时表示不要修改UA (即默认追加NewsArticle, 以便升级覆盖时缓存数据不出问题)
     *  https://wiki.bytedance.com/pages/viewpage.action?pageId=51359297
     */
    ArticleGroupFlagsNoCustomUserAgent = 0x80,
    /**
     *
     */
    ArticleGroupFlagsDetailTypeNoComment = 0x1000,
    /**
     *
     */
    ArticleGroupFlagsDetailTypeNoToolBar = 0x2000,
    /**
     *
     */
    ArticleGroupFlagsDetailTypeSimple = 0x4000,
    /**
     *  视频是否在列表页播放
     */
    ArticleGroupFlagsListPlayVideo = 0x8000,
    /**
     *  视频播放的服务商
     */
    ArticleGroupFlagsDetailSP  = 0x10000,
    
    ArticleGroupFlagsGallery   = 0x20000,
};

typedef NS_ENUM(NSUInteger, ArticleRelatedVideoType) {
    ArticleRelatedVideoTypeUnknown = 0,
    ArticleRelatedVideoTypeArticle = 1 << 0,
    ArticleRelatedVideoTypeAlbum   = 1 << 1,
    ArticleRelatedVideoTypeSubject = 1 << 2,
    ArticleRelatedVideoTypeAd      = 1 << 3
};

#define kFavoriteActionNotification             @"kFavoriteActionNotification"
#define kNotInterestActionNotification          @"kNotInterestActionNotification"
#define kRecommendChannelAutoRefresh            @"kRecommendChannelAutoRefresh"

#endif
