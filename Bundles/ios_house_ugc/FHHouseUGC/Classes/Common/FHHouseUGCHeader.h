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
};

typedef NS_ENUM(NSInteger, FHCommunityCollectionCellType)
{
    FHCommunityCollectionCellTypeNone = -1,
    FHCommunityCollectionCellTypeMyJoin = 0,
    FHCommunityCollectionCellTypeNearby,
    FHCommunityCollectionCellTypeDiscovery,
};

typedef NS_ENUM(NSInteger, FHUGCFeedListCellSubType)
{
    FHUGCFeedListCellSubTypePureTitle = 0,                         //纯文本
    FHUGCFeedListCellSubTypeSingleImage,                           //单图
    FHUGCFeedListCellSubTypeTwoImage,                              //两图
    FHUGCFeedListCellSubTypeMultiImage,                            //多图
    FHUGCFeedListCellSubTypeArticlePureTitle,                      //文章纯文本
    FHUGCFeedListCellSubTypeArticleSingleImage,                    //文章单图
    FHUGCFeedListCellSubTypeArticleMultiImage,                     //文章多图
    FHUGCFeedListCellSubTypeUGCRecommend,                          //小区推荐
    FHUGCFeedListCellSubTypeUGCBanner,                             //运营位
    FHUGCFeedListCellSubTypeUGCGuide,                              //初次进入引导页
};

typedef NS_ENUM(NSInteger, FHUGCFeedListCellType)
{
    FHUGCFeedListCellTypeArticle = 0,                      //文章
    FHUGCFeedListCellTypeAnswer = 202,                     //问答答案
    FHUGCFeedListCellTypeQuestion = 203,                   //问答问题
    FHUGCFeedListCellTypeArticleComment = 41,              //文章评论
    FHUGCFeedListCellTypeUGC = 32,                         //帖子
    FHUGCFeedListCellTypeUGCRecommend = 2001,              //小区推荐
    FHUGCFeedListCellTypeUGCBanner = 2002,                 //运营位
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



#endif /* FHHouseUGCHeader_h */
