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
//#define kTTVideoCategoryID      @"video"           //视频频道
#define kTTVideoCategoryID      @"f_shipin"           //视频频道

#define kTTWeitoutiaoCategoryID @"weitoutiao"      //微头条频道
#define kTTTeMaiCategoryID      @"jinritemai"      //特卖频道

//#define kTTUGCVideoCategoryID   @"hotsoon_video" //小视频频道
#define kTTUGCVideoCategoryID   @"f_hotsoon_video" //房产小视频频道 add by zjing,记得修改时对应"hotsoon_video"也要对应替换

#define kTTFollowCategoryID     @"关注"

#define kTTMainConcernID        @"6286225228934679042"
#define kTTWeitoutiaoConcernID  @"6368255615201970690"
#define KTTFollowPageConcernID  @"6454692306795629069"

#define kNIHFindHouseCategoryID   @"f_find_house" // 找房频道 add by zjing

#define kNIHFeedHouseMixedCategoryID   @"f_find_news" // 找房频道

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
    /**
     *  小视频频道
     */
    TTCategoryModelTopTypeShortVideo = 3,
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
    TTFeedListDataTypeShortVideo        =   8, //小视频频道
};

#endif
