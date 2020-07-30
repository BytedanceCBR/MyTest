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

typedef NS_ENUM(NSUInteger, FHBuildingDetailOperatType) {
    FHBuildingDetailOperatTypeButton = 1,        //点击按钮 按钮置中，点击button 只影响楼号 按钮显示在最上层 滑动CollectionView
    FHBuildingDetailOperatTypeInfoCell,          //滑动CollectView 只影响楼号 按钮显示在最上层
    FHBuildingDetailOperatTypeSaleStatus,        //点击状态label = 切换对应的状态后点击对应的按钮 ,隐藏其他button,
    FHBuildingDetailOperatTypeFromNew            //等于点击状态label同时点击按钮
};

@interface FHBuildingIndexModel : NSObject

@property (nonatomic, assign) NSInteger saleStatus; //销售状态 - X
@property (nonatomic, assign) NSInteger buildingIndex; //楼   - Y
+ (instancetype)indexModelWithSaleStatus:(NSInteger)saleStatus withBuildingIndex:(NSInteger)buildingIndex;
@end



@protocol FHBuildingDetailRelatedFloorpanModel <NSObject>
@end

@interface FHBuildingDetailRelatedFloorpanModel : JSONModel

@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *facingDirection;
@property (nonatomic, copy, nullable) NSString *squaremeter;
@property (nonatomic, copy, nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSArray<FHImageModel> *images;
@property (nonatomic, copy , nullable) NSArray<FHHouseTagsModel> *tags;
@property (nonatomic, copy , nullable) NSDictionary *logPb;
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

///  该楼的坐标
@property (nonatomic, copy, nullable) NSString *pointX;
@property (nonatomic, copy, nullable) NSString *pointY;
@property (nonatomic, copy, nullable) NSString *beginWidth;
@property (nonatomic, copy, nullable) NSString *beginHeight;
@property (nonatomic, strong, nullable) FHBuildingIndexModel *buildingIndex;
@end


@interface FHBuildingDetailDataModel : JSONModel

@property (nonatomic, strong , nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, strong , nullable) NSArray<FHBuildingDetailDataItemModel> *buildingList;
@property (nonatomic, strong , nullable) FHDetailContactModel *highlightedRealtor;
@property (nonatomic, strong , nullable) FHImageModel *buildingImage;
@end

@interface FHBuildingDetailModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHBuildingDetailDataModel *data ;



@end



@interface FHBuildingSaleStatusModel : NSObject

@property (nonatomic, strong) FHSaleStatusModel *saleStatus;
@property (nonatomic, copy) NSArray<FHBuildingDetailDataItemModel> *buildingList;

@end

@protocol FHBuildingSaleStatusModel<NSObject>
@end

@interface FHBuildingLocationModel : NSObject
@property (nonatomic, strong) NSArray<FHBuildingSaleStatusModel > *saleStatusList;
@property (nonatomic, strong) NSArray *saleStatusContents;
@property (nonatomic, strong , nullable) FHImageModel *buildingImage;

@end

typedef void(^FHBuildingIndexDidSelect)(FHBuildingDetailOperatType type, FHBuildingIndexModel *index);
NS_ASSUME_NONNULL_END
