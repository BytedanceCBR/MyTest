//
//  FHHouseContactDefines.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#ifndef FHHouseContactDefines_h
#define FHHouseContactDefines_h

#define kFHCluePage @"clue_page"
#define kFHClueEndpoint @"clue_endpoint"

typedef enum : NSUInteger {
    FHFollowActionTypeNew = 1,
    FHFollowActionTypeOld = 2,
    FHFollowActionTypeRent = 3,
    FHFollowActionTypeNeighborhood = 4,
    FHFollowActionTypePriceChanged = 5,
    FHFollowActionTypeFloorPan = 6,
} FHFollowActionType;

typedef enum : NSUInteger {
    FHClueEndPointTypeC = 1, // C端
    FHClueEndPointTypeB = 4, // B端
} FHClueEndPointType;

typedef enum : NSUInteger {
    FHCluePageTypeCOldSchool = 23, // app_oldhouse_school 1.23小端二手房详情页的咨询学区
    FHCluePageTypeCOldFloor = 24, // app_oldhouse_floor：1.24小端二手房详情页的咨询楼层
} FHCluePageTypeC;


#endif /* FHHouseContactDefines_h */
