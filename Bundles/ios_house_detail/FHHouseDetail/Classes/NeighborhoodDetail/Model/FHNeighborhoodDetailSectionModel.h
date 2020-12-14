//
//  FHNeighborhoodDetailSectionModel.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import <Foundation/Foundation.h>
#import <IGListKit/IGListKit.h>
#import "FHDetailNeighborhoodModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHNeighborhoodDetailSectionType) {
    FHNeighborhoodDetailSectionTypeHeader = 10000,
    FHNeighborhoodDetailSectionTypeCoreInfo = 10100, //核心信息
    FHNeighborhoodDetailSectionTypeStrategy = 10200, //小区评测
    FHNeighborhoodDetailSectionTypeBaseInfo = 10300, //小区基本信息
    FHNeighborhoodDetailSectionTypeSurrounding = 10400, //周边配套
    FHNeighborhoodDetailSectionTypeFloorpan = 10500, //小区户型
    FHNeighborhoodDetailSectionTypeHouseSale = 10600, //在售房源
    FHNeighborhoodDetailSectionTypeCommentAndQuestion = 10700, //小区点评
    FHNeighborhoodDetailSectionTypeAgent = 10800, //小区经纪人
    FHNeighborhoodDetailSectionTypeSurroundingNeighbor = 17000, //周边小区
    FHNeighborhoodDetailSectionTypeSurroundingHouse = 18000, //周边房源
    FHNeighborhoodDetailSectionTypeRecommend = 19000, //推荐房源，猜你喜欢
    
    FHNeighborhoodDetailSectionTypeOwnerSellHouse = 20000, //业主卖房
    
    
    
};

@interface FHNeighborhoodDetailSectionModel : NSObject<IGListDiffable>

- (instancetype)initWithDetailModel:(FHDetailNeighborhoodModel *)model;

@property (nonatomic, strong) FHDetailNeighborhoodModel *detailModel;

@property (nonatomic, copy, nullable) NSArray *items;

@property (nonatomic, assign) FHNeighborhoodDetailSectionType sectionType;

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model;

@end

NS_ASSUME_NONNULL_END
