//
//  TTFriendRelation_Enums.h
//  Pods
//
//  Created by lipeilun on 2018/1/3.
//

#ifndef TTFriendRelation_Enums_h
#define TTFriendRelation_Enums_h

//新统计
//https://wiki.bytedance.net/pages/viewpage.action?pageId=72024801
typedef NS_ENUM(NSUInteger, TTFollowNewSource) {
    TTFollowNewSourceUnknown = 0,           // 默认
    TTFollowNewSourceMomentDetail = 1,  //动态详情页
    TTFollowNewSourceAddFriends = 20, //添加好友页
    TTFollowNewSourceOtherFollowingList = 21, //他人关注列表
    TTFollowNewSourceOtherFollowedList = 22, //他人的粉丝列表
    TTFollowNewSourceFollowedList = 24, //自己的粉丝列表
    TTFollowNewSourceProfile = 25,      // 个人主页
    TTFollowNewSourceProfileBar = 26,   // 个人主页上面的bar关注
    TTFollowNewSourceProfileFeed = 27,  // 个人主页推荐关注
    TTFollowNewSourceWendaDetail = 28,  // 问答详情页
    TTFollowNewSourceThreadDetail = 29, // 帖子详情页
    TTFollowNewSourceNewsDetail = 30,   // 文章详情页
    TTFollowNewSourceVideoDetail = 31,  // 视频详情页
    TTFollowNewSourceNewsDetailRecommend = 34, // 文章详情页推荐关注
    TTFollowNewSourceVideoDetailRecommend = 35, // 视频详情页推荐关注
    TTFollowNewSourceSearchResult = 38, // 搜索结果页面
    TTFollowNewSourceAddEntryList = 39, // 头条号频道推荐
    TTFollowNewSourcePersonal = 40, //个人主页
    TTFollowNewSourceFeedArticle = 41,  //feed随内容推人
    TTFollowNewSourceFeedCard = 42,     //feed随卡片推人
    TTFollowNewSourcePicsFollow = 45, // 图集最后一页关注
    TTFollowNewSourceMomentList = 46,   //好友动态列表
    TTFollowNewSourceVideoFeedFollow = 48, // 视频feed关注
    TTFollowNewSourceContactsGuide = 56, //通讯录弹窗
    TTFollowNewSourceMessageList = 58, //消息列表
    
    TTFollowNewSourceFollowCategoryColdStartFollow = 60, //关注频道冷启动批量关注
    TTFollowNewSourceRecommendUserMainFeed = 62, //新推人卡片 - feed
    TTFollowNewSourceRecommendUserFollowCategory = 63, //新推人卡片 - 关注频道
    TTFollowNewSourceRecommendUserWeitoutiaoCategory = 64, //新推人卡片 - 微头条
    TTFollowNewSourceRecommendUserOtherCategory = 65, //新推人卡片 - 其他垂直频道
    TTFollowNewSourceRecommendRelateMainFeed = 66, //相关推人 - 主feed
    TTFollowNewSourceRecommendRelateWeitoutiaoCategory = 67, //相关推人 - 微头条
    TTFollowNewSourceThreadDetailRight = 68,//帖子详情页右上角
    TTFollowNewSourceThreadDetailRecommendRelate = 69,//帖子详情页相关推荐
    TTFollowNewSourceThreadDetailTop = 70,//帖子详情页顶部
    TTFollowNewSourceWendaDetailFollow = 71,//问答详情页
    TTFollowNewSourceRecommendUserLargeCardMainFeed = 72, //列表猛烈推人 - feed
    TTFollowNewSourceRecommendUserLargeCardFollowCategory = 73, //列表猛烈推人 - 关注频道
    TTFollowNewSourceRecommendUserLargeCardWeitoutiaoCategory = 74, //列表猛烈推人 - 微头条
    TTFollowNewSourceRecommendUserLargeCardOtherCategory = 75, //列表猛烈推人 - 其他垂直频道
    TTFollowNewSourceMomentsRecommendUserFollowCategory = 81, //好友动态推人 - 关注频道
    TTFollowNewSourceMomentsRecommendUserMainCategory = 82, //好友动态推人 - 推荐频道
    TTFollowNewSourceMomentsRecommendUserOtherCategory = 83, //好友动态推人 - 其他频道
    TTFollowNewSourceAddressListInviteFriendPage = 87, //邀请好友
    TTFollowNewSourceFeedRecommendRedpacketCard = 99, //猛烈推人红包, 真实好友
    TTFollowNewSourceFeedRecommendStarsRedpacketCard = 114, //猛烈推人红包, 名人明星

    TTFollowNewSourceCommentRepostFeed = 93, //评论转发feed
    TTFollowNewSourceCommentRepostDetail = 94, //评论转发详情页
    TTFollowNewSourceCommentRepostDetailTopNavi = 98, //评论转发详情页顶部
    
    TTFollowNewSourceVideoListRecommend = 103, //视频列表页推荐关注
    TTFollowNewSourceFeedWendaCell = 77, // feed中的问答cell
    TTFollowNewSourceWeixinPersonalHome = 105, //微信跳个人主页
    TTFollowNewSourceWeixinAddFriend = 106, //微信跳添加好友页面
    TTFollowNewSourceStory = 108, //Story
    //    红包关注 相应关注+1000
    TTFollowNewSourceXiguaLive = 111, //西瓜直播

    TTFollowNewSourceProfileRedPacket = 1025,      // 个人主页 红包
    TTFollowNewSourceProfileBarRedPacket = 1026,   // 个人主页上面的bar关注 红包
    TTFollowNewSourcePersonalRedPacket = 1040, //个人主页 红包
    TTFollowNewSourceRecommendUserMainFeedRedPacket = 1062, //新推人卡片 红包 - feed
    TTFollowNewSourceRecommendUserFollowCategoryRedPacket = 1063, //新推人卡片 红包 - 关注频道
    TTFollowNewSourceRecommendUserWeitoutiaoCategoryRedPacket = 1064, //新推人卡片 红包 - 微头条
    TTFollowNewSourceRecommendUserOtherCategoryRedPacket = 1065, //新推人卡片 红包 - 其他垂直频道
#warning 需要前端添加
    TTFollowNewSourceNewsDetailRedPacket = 1030,   // 文章详情页 红包
    TTFollowNewSourceVideoDetailRedPacket = 1031,  // 视频详情页 红包
    TTFollowNewSourceVideoDetailRedRecommend = 1035,
    TTFollowNewSourceFeedArticleRedPacket = 1041,  // feed随内容推人 红包
    TTFollowNewSourceVideoFeedFollowRedPacket = 1048, // 视频feed关注红包
    TTFollowNewSourceRedpacketViewFollow = 1056, //通讯录红包
};

#endif /* TTFriendRelation_Enums_h */
