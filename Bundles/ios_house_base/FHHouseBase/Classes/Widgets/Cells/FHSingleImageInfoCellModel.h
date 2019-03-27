//
//  FHSingleImageInfoCellModel.h
//  FHHouseBase
//
//  Created by 张静 on 2018/12/25.
//

#import <Foundation/Foundation.h>
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"
#import "FHHouseRentModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSingleImageInfoCellModel : NSObject

@property (nonatomic, assign) BOOL isRecommendCell;
@property (nonatomic, assign) BOOL isSubscribCell;
@property (nonatomic, assign) FHHouseType houseType;
@property (nonatomic, copy , nullable) NSString *houseId;

@property (nonatomic, strong , nullable) FHNewHouseItemModel *houseModel;
@property (nonatomic, strong , nullable) FHSearchHouseDataItemsModel *secondModel;
@property (nonatomic, strong , nullable) FHHouseRentDataItemsModel *rentModel;
@property (nonatomic, strong , nullable) FHHouseNeighborDataItemsModel *neighborModel;

@property (nonatomic, strong , nullable) JSONModel *subscribModel;//搜索订阅数据model

@property (nonatomic, assign) CGSize titleSize;

@property (nonatomic, strong , nullable, readonly) NSAttributedString *tagsAttrStr;
@property (nonatomic, strong , nullable, readonly) NSAttributedString *originPriceAttrStr;

+(NSAttributedString *)tagsStringWithTagList:(NSArray<FHSearchHouseDataItemsTagsModel *> *)tagList;

#pragma mark log
-(NSString *)imprId;
-(NSString *)groupId;
-(nullable NSDictionary *)logPb;

+ (FHSingleImageInfoCellModel *)houseItemByModel:(id)obj;

@end

NS_ASSUME_NONNULL_END
