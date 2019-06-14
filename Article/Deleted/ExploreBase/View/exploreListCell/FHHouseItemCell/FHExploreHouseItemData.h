//
//  FHExploreHouseItemData.h
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "ExploreOriginalData.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSearchHouseDataItemsModel;
@class FHNewHouseItemModel;
@class FHHouseRentDataItemsModel;


@interface FHExploreHouseItemData : ExploreOriginalData

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<NSDictionary *> *items; // 房源卡片
@property (nonatomic, copy , nullable) NSString *loadmoreOpenUrl;
@property (nonatomic, copy , nullable) NSString *imprType;
@property (nonatomic, copy , nullable) NSString *loadmoreButton;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *searchId;

- (nullable NSArray<FHNewHouseItemModel *> *)houseList;

- (nullable NSArray<FHSearchHouseDataItemsModel *> *)secondHouseList;

- (nullable NSArray<FHHouseRentDataItemsModel *> *)rentHouseList;

@end


NS_ASSUME_NONNULL_END