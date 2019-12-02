//
//  FHHouseShadowImageType.h
//  Pods
//
//  Created by liuyu on 2019/11/25.
//

#ifndef FHHouseShadowImageType_h
#define FHHouseShadowImageType_h
//用于控制阴影图片展示方向
typedef NS_ENUM (NSInteger , FHHouseShdowImageType){
    FHHouseShdowImageTypeLR = 0,
    FHHouseShdowImageTypeLTR,
    FHHouseShdowImageTypeLBR,
    FHHouseShdowImageTypeRound
};
//用于将小模块区分成大模块
typedef NS_ENUM (NSInteger , FHHouseModelType){
    FHHouseModelTypeDefault = 0,
    FHHouseModelTypeCoreInfo,//房源属性模块
    FHHouseModelTypeSubscribe,//订阅房源动态模块
    FHHouseModelTypeOutlineInfo,//房源概况
    FHHouseModelTypeBillBoard,//房源榜单
    FHHouseModelTypeAgentlist,//推荐经纪人
    FHHouseModelTypeLocationPeriphery //位置周边
    
};
#endif /* FHHouseShadowImageType_h */
