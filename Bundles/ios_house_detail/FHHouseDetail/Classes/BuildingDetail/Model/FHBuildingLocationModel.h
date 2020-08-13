//
//  FHBuildingLocationModel.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/7.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@class FHImageModel,FHBuildingSaleStatusModel,FHSaleStatusModel;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, FHBuildingDetailOperatType) {
    FHBuildingDetailOperatTypeButton = 1,        //点击按钮 按钮置中，点击button 只影响楼号 按钮显示在最上层 滑动CollectionView
    FHBuildingDetailOperatTypeInfoCell,          //滑动CollectView 只影响楼号 按钮显示在最上层
    FHBuildingDetailOperatTypeSaleStatus,        //点击状态label = 切换对应的状态后点击对应的按钮 ,隐藏其他button,
    FHBuildingDetailOperatTypeFromNew            //等于点击状态label同时点击按钮
};

@interface FHBuildingIndexModel : JSONModel

@property (nonatomic, assign) NSInteger saleStatus; //销售状态 - X
@property (nonatomic, assign) NSInteger buildingIndex; //楼   - Y
+ (instancetype)indexModelWithSaleStatus:(NSInteger)saleStatus withBuildingIndex:(NSInteger)buildingIndex;
@end

@interface FHBuildingSaleStatusModel : NSObject

@property (nonatomic, strong) FHSaleStatusModel *saleStatus;
@property (nonatomic, copy) NSArray *buildingList; //FHBuildingDetailDataItemModel

@end

@protocol FHBuildingSaleStatusModel<NSObject>
@end

@interface FHBuildingLocationModel : NSObject
@property (nonatomic, strong) NSArray<FHBuildingSaleStatusModel > *saleStatusList;
@property (nonatomic, strong) NSArray *saleStatusContents;
@property (nonatomic, strong) FHImageModel *buildingImage;

@end

typedef void(^FHBuildingIndexDidSelect)(FHBuildingDetailOperatType type, FHBuildingIndexModel *index);

NS_ASSUME_NONNULL_END
