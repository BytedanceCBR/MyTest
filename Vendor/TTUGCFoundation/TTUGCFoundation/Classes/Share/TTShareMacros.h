//
//  TTShareMacros.h
//  Article
//
//  Created by lipeilun on 2018/1/26.
//

#ifndef TTShareMacros_h
#define TTShareMacros_h

typedef NS_ENUM(NSInteger, TTShareSourceObjectType)
{
    TTShareSourceObjectTypeArticle,         //详情页底部分享按钮（文章或段子）
    TTShareSourceObjectTypeEssay,           //信息流页面的段子
    TTShareSourceObjectTypeMoment,
    TTShareSourceObjectTypeForum,
    TTShareSourceObjectTypeForumPost,
    TTShareSourceObjectTypeWendaAnswer,     //问答回答分享
    TTShareSourceObjectTypeWendaQuestion,   //问答问题列表分享
    TTShareSourceObjectTypePGC,
    TTShareSourceObjectTypeVideoList,
    TTShareSourceObjectTypeVideoDetail,     //added 622: 视频详情页内的分享
    TTShareSourceObjectTypeVideoListLargePic, //视频列表大图广告
    TTShareSourceObjectTypeVideoFloat,      //facebook 浮层
    TTShareSourceObjectTypeComment,
    TTShareSourceObjectTypeArticleNatant,   //详情页浮层分享按钮
    TTShareSourceObjectTypeArticleTop,      //详情页顶部...按钮
    TTShareSourceObjectTypeSingleGallery,   //added 5.4：图集单张图片分享
    TTShareSourceObjectTypeScreenshot,
    TTShareSourceObjectTypeUGCFeed,         //added 5.4: 主feed流分享
    TTShareSourceObjectTypeFeedForumPost,   //added 5.4: 主feed帖子分享
    TTShareSourceObjectTypeLiveChatRoom,    //added 5.4.2: 直播室的分享
    TTShareSourceObjectTypeVideoSubject,    //added 5.5: 视频专题的分享
    TTShareSourceObjectTypeHTSLive,         //added 5.6: 火山直播的分享
    TTShareSourceObjectTypeWap,             //added 5.7: WAP页面顶部...分享按钮
    TTShareSourceObjectTypeProfile,         //个人主页右上角的分享按钮
    TTShareSourceObjectTypeHTSVideo,       //added 5.8: 火山短视频的分享
};

/**
 *  分享来自的平台
 */
typedef NS_ENUM(NSInteger, TTSharePlatformType) {
    /**
     *  分享来自头条平台
     */
    TTSharePlatformTypeOfMain = 0,
    /**
     *  分享来自话题插件
     */
    TTSharePlatformTypeOfForumPlugin,
    /**
     *  分享来自火山直播插件
     */
    TTSharePlatformTypeOfHTSLivePlugin
};

#endif /* TTShareMacros_h */
