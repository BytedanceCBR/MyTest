//
//  FHExploreHouseItemData.h
//  Article
//
//  Created by 张静 on 2018/11/20.
//

#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSearchHouseDataItemsModel;
@class FHNewHouseItemModel;

@interface FHExploreHouseItemData : ExploreOriginalData

@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<NSDictionary *> *items; // 房源卡片
@property (nonatomic, copy , nullable) NSString *loadmoreOpenUrl;
@property (nonatomic, copy , nullable) NSString *imprType;
@property (nonatomic, copy , nullable) NSString *loadmoreButton;
@property (nonatomic, copy , nullable) NSString *houseType;


- (nullable NSArray<FHNewHouseItemModel *> *)houseList;

- (nullable NSArray<FHSearchHouseDataItemsModel *> *)secondHouseList;


@end


NS_ASSUME_NONNULL_END
