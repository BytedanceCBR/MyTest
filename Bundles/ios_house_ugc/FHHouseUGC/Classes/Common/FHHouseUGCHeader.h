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
};

typedef NS_ENUM(NSInteger, FHUGCFeedListCellType)
{
    FHUGCFeedListCellTypeArticle = 0,                        //文章
    FHUGCFeedListCellTypeUGC = 32,                           //帖子
    FHUGCFeedListCellTypeUGCRecommend = 60,                           //小区推荐
};

#endif /* FHHouseUGCHeader_h */
