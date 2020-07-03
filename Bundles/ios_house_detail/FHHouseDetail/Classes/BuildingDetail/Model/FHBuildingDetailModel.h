//
//  FHBuildingDetailModel.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "JSONModel.h"
#import "FHDetailBaseModel.h"
#import "FHHouseNewsSocialModel.h"
#import "FHHouseBaseInfoModel.h"
#import <FHHouseBase/FHSaleStatusModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHBuildingDetailRelatedFloorpanModel <NSObject>
@end

@interface FHBuildingDetailRelatedFloorpanModel : JSONModel

@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *facingDirection;
@property (nonatomic, copy, nullable) NSString *squaremeter;
@property (nonatomic, copy, nullable) NSString *pricing;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, strong , nullable) NSArray<FHHouseTagsModel> *tags;
@end

@interface FHBuildingDetailRelatedFloorpanListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy, nullable) NSArray<FHBuildingDetailRelatedFloorpanModel> *list;
@end

@protocol FHBuildingDetailDataItemModel<NSObject>
@end

@interface FHBuildingDetailDataItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *buildingID;
@property (nonatomic, copy , nullable) NSString *name;

/// 售卖状态
@property (nonatomic, strong , nullable) FHSaleStatusModel *saleStatus ;

/// 基本信息
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;

/// 关联户型列表
@property (nonatomic, copy, nullable) FHBuildingDetailRelatedFloorpanListModel *relatedFloorplanList;
@end

@interface FHBuildingDetailDataModel : JSONModel

@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, strong , nullable) NSArray<FHBuildingDetailDataItemModel> *buildingList;
@end

@interface FHBuildingDetailModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHBuildingDetailDataModel *data ;

@end

NS_ASSUME_NONNULL_END
