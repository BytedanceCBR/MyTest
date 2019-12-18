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

#pragma mark endpoint
typedef enum : NSUInteger {
    FHClueEndPointTypeC = 1, // C端
    FHClueEndPointTypeB = 4, // B端
} FHClueEndPointType;

#pragma mark - page

// 表单线索
typedef enum : NSUInteger {
    FHClueFormPageTypeCNeighborhood = 2, // app_neighbourhood： 1.2 二手房小区详情页底通表单
    
} FHClueFormPageTypeC;

// 电话线索
typedef enum : NSUInteger {
    FHClueCallPageTypeCNeighborhood = 5, // app_neighborhood: 1.5小区详情页底通电话
    FHClueCallPageTypeCNeighborhoodMulrealtor = 51,// app_neighborhood_mulrealtor: 1.51小区详情页经纪人多展位电话
    FHClueCallPageTypeCNeighborhoodAladdin = 52//  app_neighborhood_aladdin: 1.52小区阿拉丁电话
} FHClueCallPageTypeC;

// IM线索
typedef enum : NSUInteger {
    
    FHClueIMPageTypeCOldSchool = 23, // app_oldhouse_school 1.23小端二手房详情页的咨询学区
    FHClueIMPageTypeCOldFloor = 24, // app_oldhouse_floor：1.24小端二手房详情页的咨询楼层
    FHClueIMPageTypeCQuickQuestion = 25, // app_oldhouse_question：1.25小端二手房详情页的快速提问
    FHClueIMPageTypeCExpertDetail = 26, // app_oldhouse_expert_detail 26小端二手房详情页专家展位进经纪人主页后的在线联系

    FHClueIMPageTypeCNeighborhood = 4, // app_neighborhood: 1.4小区详情页
    FHClueIMPageTypeCNeighborhoodMulrealtor = 41,// app_neighborhood_mulrealtor: 1.41小区详情页经纪人多展位
    FHClueIMPageTypeCNeighborhoodAladdin = 42,// app_neighborhood_aladdin: 1.42小区阿拉丁微聊
    FHClueIMPageTypePresentation = 27,//二手房详情页购房小建议
    
} FHClueIMPageTypeC;

#endif /* FHHouseContactDefines_h */
