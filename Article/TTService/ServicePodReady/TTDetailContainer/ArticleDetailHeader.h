//
//  ArticleDetailHeader.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-20.
//
//

#ifndef ArticleDetailDefineHeader
#define ArticleDetailDefineHeader

typedef enum NewsGoDetailFromSource
{
    NewsGoDetailFromSourceUnknow,               //来源未知
    NewsGoDetailFromSourceHeadline,             //从推荐列表进入详情页
    NewsGoDetailFromSourceCategory,             //分类列表进入
    NewsGoDetailFromSourceAPNS,                 //推送进入
    NewsGoDetailFromSourceUpate,                //动态进入,3.5开始专门指动态列表
    NewsGoDetailFromSourceSearch,               //搜索进入
    NewsGoDetailFromSourceRelateReading,        //相关阅读进入
    NewsGoDetailFromSourceVideoAlbum,           //视频专辑进入
    NewsGoDetailFromSourceHotComment,           //热门评论进入
    NewsGoDetailFromSourceFavorite,             //收藏进入
    NewsGoDetailFromSourceClickPGCList,         //PGC进入
    NewsGoDetailFromSourceClickUpdatePGC,       //点击动态中出现的已订阅pgc媒体文章（与点击好友动态的文章区分出来）
    NewsGoDetailFromSourceSubject,              //专题
    NewsGoDetailFromSourceActivity,             //活动
    NewsGoDetailFromSourceUpdateDetail,          //动态详情进入,3.5开始
    NewsGoDetailFromSourceNotification,         //通知进入,3.5开始
    NewsGoDetailFromSourceProfile,              //个人主页进入, 3.5开始
    NewsGoDetailFromSourceOtherApp,             //从其他应用进入, 3.5支持
    NewsGoDetailFromSourceClickTodayExtenstion,          //从通知中心的“今天扩展”点击进入，版本4.1且系统为iOS8开始支持
    NewsGoDetailFromSourceClickWapSearchResult,
    NewsGoDetailFromSourceSpotlightSearchResult,
    NewsGoDetailFromSourceAPNSInAppAlert,                 //推送从app内弹窗进入
    NewsGoDetailFromSourceVideoFloat,                 //从facebook 浮层进入
    NewsGoDetailFromSourceVideoFloatRelated,          //从facebook 浮层相关视频进入
    NewsGoDetailFromSourceSplashAD,             //开屏广告
    NewsGoDetailFromSourceReadHistory,             //阅读历史
    NewsGoDetailFromSourcePushHistory,             //推送历史
}NewsGoDetailFromSource;

#define kNewsGoDetailFromSourceKey @"kNewsGoDetailFromSource"


#endif
