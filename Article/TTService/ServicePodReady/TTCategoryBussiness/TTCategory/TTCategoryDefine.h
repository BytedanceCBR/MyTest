//
//  TTCategoryDefine.h
//  Article
//
//  Created by Zhang Leonardo on 14-12-4.
//
//
#ifndef TTCategoryDefine_h
#define TTCategoryDefine_h

#define kTTNewsLocalCategoryNoCityName NSLocalizedString(@"本地", nil) //没有选择城市之前，显示的名字

#define kTTMainCategoryID       @"__all__"         //推荐, 4.3 修改， 以前是 news， 服务端大部分需要回传的都是 __all__，所以修改
#define kTTNewsLocalCategoryID  @"news_local"      //本地
#define kTTSubscribeCategoryID  @"subscription"    //订阅频道
#define kTTVideoCategoryID      @"video"           //视频频道
#define kTTWeitoutiaoCategoryID @"weitoutiao"      //微头条频道
#define kTTTeMaiCategoryID      @"jinritemai"      //特卖频道

#define kTTUGCVideoCategoryID   @"hotsoon_video" //小视频频道

#define kTTFollowCategoryID     @"关注"

#define kTTMainConcernID        @"6286225228934679042"
#define kTTWeitoutiaoConcernID  @"6368255615201970690"

/**
 *  对应category的flags字段
 */
typedef NS_ENUM(NSUInteger, TTCategoryModelFlagType) {
    /**
     *  无作用
     */
    TTCategoryModelFlagTypeNone = 0,
    /**
     *  wap页频道支持JS
     */
    TTCategoryModelFlagTypeWapCategorySupportJS = 1,
};


/**
 *  大频道分类：目前有 1、首页的新闻频道 2、视频tab下的视频频道 3、iPad中图片tab下的图片频道
 */
typedef NS_ENUM(NSUInteger, TTCategoryModelTopType){
    /**
     *  默认频道 新闻
     */
     TTCategoryModelTopTypeNews = 0,
    /**
     *  视频频道
     */
    TTCategoryModelTopTypeVideo = 1,
    /**
     *  图片频道
     */
    TTCategoryModelTopTypePhoto = 2,
};

/**
 *  小视频频道类型：同一个category_id下区分不同小视频频道
 *  由于推荐采用同一个频道训练数据，小视频tab下的火山和抖音频道，使用同一个category_id
 *  这里添加一种枚举值，枚举了所有使用小视频频道的地方
 */
typedef NS_ENUM(NSUInteger, TTShortVideoSubCategory) {
    /**
     *  非小视频频道
     */
    TTShortVideoSubCategoryNone = 0,
    /**
     *  首页tab里的小视频频道
     */
    TTShortVideoSubCategoryNewsTab = 1,
    /**
     *  小视频tab里的混排的小视频频道
     */
    TTShortVideoSubCategoryHTSTab = 2,
    /**
     *  从卡片进详情页时，详情页自己请求的小视频频道
     */
    TTShortVideoSubCategoryDetail = 3,
    /**
     *  小视频tab里的分频道的火山小视频频道
     */
    TTShortVideoSubCategoryHTSTabHuoshan = 4,
    /**
     *  小视频tab里的分频道的抖音小视频频道
     */
    TTShortVideoSubCategoryHTSTabDouyin = 5,
};

// 频道分类
typedef NS_ENUM(NSUInteger, TTFeedListDataType)
{
    TTFeedListDataTypeNone              =   0,
    TTFeedListDataTypeImage             =   1,
    TTFeedListDataTypeVideo             =   2,
    TTFeedListDataTypeEssay             =   3,
    TTFeedListDataTypeArticle           =   4,
    TTFeedListDataTypeWeb               =   5,
    TTFeedListDataTypeSubscribeEntry    =   6, //4.3新增，为订阅频道
    TTFeedListDataTypeWenda             =   7, //问答频道
};

#endif
