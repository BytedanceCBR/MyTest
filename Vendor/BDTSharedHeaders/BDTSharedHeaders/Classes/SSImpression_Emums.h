//
//  SSImpression_Emums.h
//  Pods
//
//  Created by 王双华 on 2017/12/21.
//

#ifndef SSImpression_Emums_h
#define SSImpression_Emums_h

/**
 *  用于区分impression类型 参考 https://wiki.bytedance.net/pages/viewpage.action?pageId=525581
 *  modelType 对应于文档中的impression的item字段说明中的type
 */
typedef NS_ENUM(NSUInteger, SSImpressionModelType)
{
    SSImpressionModelTypeGroup                  = 1,        //group item
    SSImpressionModelTypeAD                     = 2,        //ad item
    SSImpressionModelTypeComment                = 20,       //评论
    SSImpressionModelTypeMoment                 = 21,       //动态
    SSImpressionModelTypeSubject                = 99999,    //专题，目前和group发送的状态码一样，但是客户端发送逻辑不同，区分定义
    SSImpressionModelTypeExploreDetail          = 31,       //文章详情页
    SSImpressionModelTypeForumList              = 32,       //话题列表
    SSImpressionModelTypeThread                 = 33,       //话题帖子
    SSImpressionModelTypeThreadComment          = 34,       //帖子评论
    SSImpressionModelTypeMomoAD                 = 35,       //陌陌广告
    SSImpressionModelTypeVideoDetail            = 36,       //视频详情页相关视频
    SSImpressionModelTypeRelatedItem            = 37,       //详情页相关区域的item
    SSImpressionModelTypeConcernListItem        = 38,       //关心列表的cell
    SSImpressionModelTypeWendaListItem          = 39,       //问答回答列表的cell
    SSImpressionModelTypeWeitoutiaoListItem     = 41,       //微头条列表的cell
    SSImpressionModelTypeHouShanListItem        = 45,       //火山直播的cell
    SSImpressionModelTypeLianZaiListItem        = 46,       //小说连载的cell
    SSImpressionModelTypeLiveListItem           = 48,       //直播cell
    SSImpressionModelTypeU11CellListItem        = 49,       //U11cell
    SSImpressionModelTypeU11RecommendUserItem   = 51,       //u11推人
    SSImpressionModelTypeHuoShanTalentBanner    = 52,       //火山达人频道活动banner
    SSImpressionModelTypeArticleListItem        = 53,       //文章详情页订阅推荐组件Cell
    SSImpressionModelTypeVideoListItem          = 54,       //视频详情页订阅推荐组件Cell
    SSImpressionModelTypeHuoShanVideoInHTSTab   = 55,       //火山小视频tab上的火山cell
    SSImpressionModelTypeHuoShanVideoInHoriCard = 56,       //水平卡片上的火山cell
    SSImpressionModelTypeUGCVideo               = 57,       //ugc小视频 火山和抖音
    SSImpressionModelTypeVideoFloat             = 60,       //视频浮层的cell
    SSImpressionModelTypeMessageNotification    = 65,       //消息通知的cell
    SSImpressionModelTypeStory                  = 66,       //story的cell
    SSImpressionModelTypeU11MomentsRecommendUserItem    = 70,       //u11好友动态推人
    SSImpressionModelTypeCommentRepostDetail    = 71,       //转发详情页
    SSImpressionModelTypeUGCRepostCommon        = 73,       //通用转发
    SSImpressionModelTypeHashtag                = 74,       //feed话题卡片
    SSImpressionModelTypeShortVideoActivityEntrance     = 76,       //小视频活动入口
    SSImpressionModelTypeShortVideoActivityBananer      = 77,       //小视频活动banner
    SSImpressionModelTypeXiguaRecommendItem     = 81,               //西瓜直播入口
    SSImpressionModelTypeRecommendUserStory     = 82,               //推人Story
    SSImpressionModelTypeRecommendStoryCover     = 83,               //推人Story
    SSImpressionModelTypePopularHashtagItem     = 84,               //热门话题
    SSImpressionModelTypeHotNewsSingleItem       = 85,          //热点要闻 单条样式
    SSImpressionModelTypeHotNewsSMultiItem       = 86,        //热点要闻  多条样式
};

/**
 记录impression model的group，相同列表会保存到同一个group中 参考 https://wiki.bytedance.net/pages/viewpage.action?pageId=525581
 groupType 对应于 文档中的list_type
 */

typedef NS_ENUM(NSUInteger, SSImpressionGroupType)
{
    SSImpressionGroupTypeGroupList                 = 1,//频道列表
    SSImpressionGroupTypeCommentList               = 2,//评论列表
    SSImpressionGroupTypeMomentList                = 3,//动态列表
    SSImpressionGroupTypeSubjectList               = 1,//专题列表，目前和频道列表相同, 发送逻辑暂不相同，所以区分类型
    
    SSImpressionGroupTypeExploreDetail             = 4,//文章详情页
    SSImpressionGroupTypeForumList                 = 5,//话题列表页
    SSImpressionGroupTypeThreadList                = 6,//话题详情页的帖子列表
    SSImpressionGroupTypeThreadCommentList         = 7,//帖子详情页的评论列表
    SSImpressionGroupTypeVideoDetail               = 8,//视频详情页的相关视频列表
    SSImpressionGroupTypeDetailRelatedArticle      = 9,//详情页相关阅读
    SSImpressionGroupTypeDetailRelatedGallery      = 10,//详情页相关图集
    SSImpressionGroupTypeDetailRelatedVideo        = 11,//详情页相关视频
    SSImpressionGroupTypeDetailImageRecommend      = 12,// 图集详情页图集推荐
    SSImpressionGroupTypeConcernList               = 13,//关心列表
    SSImpressionGroupTypeConcernHomepageThreadList = 14,//关心主页中的话题列表
    SSImpressionGroupTypeWendaNiceList             = 15,//问答精选列表
    SSImpressionGroupTypeWendaNormalList           = 16,//问答折叠列表
    SSImpressionGroupTypeRelatedWenda              = 17,//详情页相关问答
    SSImpressionGroupTypeConcernHomepageWenDaList  = 18,//关心主页的问答列表
    SSImpressionGroupTypeRecommendUserList         = 19,//u11推荐人列表
    SSImpressionGroupTypeHuoshanTalentList         = 20,//火山短视频达人频道列表
    SSImpressionGroupTypeWeitoutiaoList            = 21,//微头条列表
    SSImpressionGroupTypeArticleRecommendList      = 22,//文章详情页订阅推荐组件列表
    SSImpressionGroupTypeVideoRecommendList        = 23,//视频详情页订阅推荐组件列表
    SSImpressionGroupTypeVideoFloat                = 24,//视频浮层
    SSImpressionGroupTypeHuoshanVideoList          = 25,//火山小视频tab列表
    SSImpressionGroupTypeMessageNotificationList   = 26,//消息通知列表
    SSImpressionGroupTypeCommentDetailList         = 27,//评论回复详情页
    SSImpressionGroupTypeXiguaLiveRecommendList    = 28,//西瓜直播入口
    SSImpressionGroupTypeRecommendUserStoryList    = 29,//推人Story
    SSImpressionGroupTypeUGCStoryList              = 30,//UGC Story 页面
    SSImpressionGroupTypePopularHashtagList        = 31,//热门话题
};

/**
 impression的状态
 */
typedef NS_ENUM(NSInteger, SSImpressionStatus)
{
    SSImpressionStatusRecording,
    SSImpressionStatusEnd,
    SSImpressionStatusSuspend,
};

#endif /* SSImpression_Emums_h */
