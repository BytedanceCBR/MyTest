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
    ///房源属性模块
    FHHouseModelTypeCoreInfo,
    ///订阅房源动态模块
    FHHouseModelTypeSubscribe,
    ///房源概况
    FHHouseModelTypeOutlineInfo,
    ///房源榜单
    FHHouseModelTypeBillBoard,
    ///推荐经纪人
    FHHouseModelTypeAgentlist,
    ///位置周边
    FHHouseModelTypeLocationPeriphery,
    ///购房建议
    FHHouseModelTypeTips,
    ///同小区房源+小区
    FHHouseModelTypePlot,
    ///周边房源
    FHHouseModelTypePeriphery
};
#endif /* FHHouseShadowImageType_h */
