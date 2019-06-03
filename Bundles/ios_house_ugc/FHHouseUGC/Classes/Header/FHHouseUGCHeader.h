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

#endif /* FHHouseUGCHeader_h */
