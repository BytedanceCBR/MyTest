//
//  FHHouseUGCHeader.h
//  Pods
//
//  Created by 谢思铭 on 2019/6/3.
//

#ifndef FHHouseUGCHeader_h
#define FHHouseUGCHeader_h

typedef NS_ENUM(NSInteger, FHCommunityFeedListType)
{
    FHCommunityFeedListTypeNearby = 0,
    FHCommunityFeedListTypeMyJoin,
    FHCommunityFeedListTypePostDetail,
    FHCommunityFeedListTypeSpecialTopic,
    FHCommunityFeedListTypeVideoList,
    FHCommunityFeedListTypeCustom,
};

typedef NS_ENUM(NSInteger, FHCommunityCollectionCellType)
{
    FHCommunityCollectionCellTypeNone = -1,
    FHCommunityCollectionCellTypeMyJoin = 0,
    FHCommunityCollectionCellTypeNearby,
    FHCommunityCollectionCellTypeCustom,
    FHCommunityCollectionCellTypeVideo,
    FHCommunityCollectionCellTypeSmallVideo,
    FHCommunityCollectionCellTypeHouseComfortFind,
};

typedef NS_ENUM(NSInteger, FHUGCFeedListCellSubType)
{
    FHUGCFeedListCellSubTypePost = 0,                              //帖子
    FHUGCFeedListCellSubTypeArticle,                               //文章
    FHUGCFeedListCellSubTypeUGCRecommend,                          //小区推荐
    FHUGCFeedListCellSubTypeUGCBanner,                             //运营位
    FHUGCFeedListCellSubTypeUGCGuide,                              //初次进入引导页
    FHUGCFeedListCellSubTypeUGCHotTopic,                           //热门话题
    FHUGCFeedListCellSubTypeUGCVote,                               //投票pk
    FHUGCFeedListCellSubTypeUGCVideo,                              //视频
    FHUGCFeedListCellSubTypeUGCSmallVideo,                         //小视频
    FHUGCFeedListCellSubTypeUGCVoteDetail,                         //新投票类型
    FHUGCFeedListCellSubTypeUGCHotCommunity,                       //UGC附近顶部 主推圈子
    FHUGCFeedListCellSubTypeUGCNeighbourhoodQuestion,              //小区问答
    FHUGCFeedListCellSubTypeUGCNeighbourhoodComments,              //小区点评
    FHUGCFeedListCellSubTypeUGCRecommendCircle,                    //推荐圈子
    FHUGCFeedListCellSubTypeUGCEncyclopedias,                      //百科
    FHUGCFeedListCellSubTypeUGCLynx,                               //Lynx卡片
    //1.0.1j详情页经纪人评测
    FHUGCFeedListCellSubTypeUGCBrokerImage,                        //详情页经纪人评测t图片
    FHUGCFeedListCellSubTypeUGCBrokerVideo,                        //详情页经纪人评测视频
    
    FHUGCFeedListCellSubTypeAnswer ,                               //问题回答
    FHUGCFeedListCellSubTypeQuestion ,                             //问题回答
    FHUGCFeedListCellSubTypeFullVideo,                             //全屏视频
};

typedef NS_ENUM(NSInteger, FHUGCFeedListCellType)
{
    FHUGCFeedListCellTypeArticle = 0,                      //文章
    FHUGCFeedListCellTypeAnswer = 202,                     //问答答案
    FHUGCFeedListCellTypeQuestion = 203,                   //问答问题
    FHUGCFeedListCellTypeArticleComment = 41,              //文章评论
    FHUGCFeedListCellTypeArticleComment2 = 56,             //文章评论
    FHUGCFeedListCellTypeUGC = 32,                         //帖子
    FHUGCFeedListCellTypeUGCRecommend = 1101,              //小区推荐
    FHUGCFeedListCellTypeUGCBanner = 2002,                 //运营位
    FHUGCFeedListCellTypeUGCBanner2 = 1102,                //运营位
    FHUGCFeedListCellTypeUGCHotTopic = 1104,               //热门话题
    FHUGCFeedListCellTypeUGCVote = 1103,                   //投票pk
    FHUGCFeedListCellTypeUGCSmallVideo = 333,              //小视频
    FHUGCFeedListCellTypeUGCSmallVideo2 = 49,              //抖音火山小视频
    FHUGCFeedListCellTypeUGCVoteInfo = 1107,               //UGC投票，新投票类型
    FHUGCFeedListCellTypeUGCRecommendCircle = 1108,        //推荐圈子
    FHUGCFeedListCellTypeUGCEncyclopedias = 1109,          //百科
    FHUGCFeedListCellTypeUGCCommonLynx = 1200,             //Lynx卡片 1200 - 1300 这个之间不要在定义其他类型
};

typedef NS_ENUM(NSInteger, FHUGCMyInterestedType)
{
    FHUGCMyInterestedTypeMore = 0,                            //更多
    FHUGCMyInterestedTypeEmpty,                               //空页面
};

typedef NS_ENUM(NSInteger, FHUGCMyJoinType)
{
    FHUGCMyJoinTypeFeed = 1,                            //信息流列表
    FHUGCMyJoinTypeEmpty,                               //空页面
};

typedef NS_ENUM(NSUInteger, FHUGCLoginFrom) {
    FHUGCLoginFrom_POST = 0,
    FHUGCLoginFrom_GROUPCHAT = 1,
    FHUGCLoginFrom_VOTE = 2,
    FHUGCLoginFrom_WENDA = 3,
};

typedef NS_ENUM(NSUInteger, FHUGCPublishType) {
    FHUGCPublishTypePost,       // 发图文贴
    FHUGCPublishTypeVote,       // 发投票
    FHUGCPublishTypeQuestion,   // 发提问
};

typedef enum : NSUInteger {
    FHUGCPostEditStateNone,
    FHUGCPostEditStateSending,
    FHUGCPostEditStateDone,
} FHUGCPostEditState; // 帖子编辑状态

//feed中分类的key值
#define tabAll @"all"                       //全部
#define tabEssence @"essence"               //加精

#define screenWidth (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define screenHeight (([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

NSString *const FHUGCFullScreenVideoCellMutedStateChangeNotification = @"FHUGCFullScreenVideoCellMutedStateChangeNotification";

#endif /* FHHouseUGCHeader_h */

