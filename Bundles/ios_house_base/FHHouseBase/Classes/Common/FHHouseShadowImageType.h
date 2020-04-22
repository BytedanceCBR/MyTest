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
    ///二手房房源属性模块
    FHHouseModelTypeCoreInfo,
    ///二手房房源首付及月供
    FHHouseModelTypeAdvisoryLoan,
    
    ///二手房订阅房源动态模块
    FHHouseModelTypeSubscribe,
    ///二手房房源概况
    FHHouseModelTypeOutlineInfo,
    ///二手房房源榜单
    FHHouseModelTypeBillBoard,
    ///二手房推荐经纪人
    FHHouseModelTypeAgentlist,
    ///二手房房源评价
    FHHouseModelTypeHousingEvaluation,
    ///小区信息
    FHHouseModelTypeNeighborhoodInfo,
    ///二手房位置周边
    FHHouseModelTypeLocationPeriphery,
    ///二手房购房建议
    FHHouseModelTypeTips,
    ///二手房同小区房源+小区
    FHHouseModelTypePlot,
    ///二手房周边房源
    FHHouseModelTypePeriphery,
    ///二手房免责声明
    FHHouseModelTypeDisclaimer,

    ///小区详情房源属性模块
    FHPlotHouseModelTypeCoreInfo,
    ///小区详情页位置周边
    FHPlotHouseModelTypeLocationPeriphery,
    ///小区详情页小区问答
    FHPlotHouseModelTypeNeighborhoodQA,
    ///小区详情页小区点评
    FHPlotHouseModelTypeNeighborhoodComment,
    ///小区详情页小区攻略
    FHPlotHouseModelTypeNeighborhoodStrategy,
    ///小区详情页推荐经纪人
     FHPlotHouseModelTypeAgentlist,
    ///小区详情页已售房源
    FHPlotHouseModelTypeSold,
    ///小区详情页周边小区
     FHPlotHouseModelTypePeriphery,
    
    // 新房详情页属性模块
    FHHouseModelTypeNewCoreInfo,
    // 新房详情页优惠信息模块
    FHHouseModelTypeNewSales,
    // 新房详情页户型模块
    FHHouseModelTypeNewFloorPlan,
    // 新房详情页优质顾问模块
    FHHouseModelTypeNewAgentList,
    // 新房详情页位置周边模块
    FHHouseModelTypeNewLocation,
    // UGC社区入口
    FHHouseModelTypeNewSocialInfo,
    // 周边新盘
    FHHouseModelTypeNewRelated,
    
};

//展示范围。是否进行裁剪
typedef NS_ENUM (NSInteger , FHHouseShdowImageScopeType){
    FHHouseShdowImageScopeTypeDefault = 0,
    ///上阴影展示全部
    FHHouseShdowImageScopeTypeTopAll,
    ///下阴影展示全部
     FHHouseShdowImageScopeTypeBottomAll,
    ///全部展示
     FHHouseShdowImageScopeTypeAll,
};

#endif /* FHHouseShadowImageType_h */
