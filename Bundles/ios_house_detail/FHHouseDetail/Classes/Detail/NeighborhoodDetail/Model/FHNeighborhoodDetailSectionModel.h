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
    FHNeighborhoodDetailSectionTypeHeader,
    FHNeighborhoodDetailSectionTypeBaseInfo,
    FHNeighborhoodDetailSectionTypeHouseSale,
};

@interface FHNeighborhoodDetailSectionModel : NSObject<IGListDiffable>

- (instancetype)initWithDetailModel:(FHDetailNeighborhoodModel *)model;

@property (nonatomic, strong) FHDetailNeighborhoodModel *detailModel;

@property (nonatomic, copy, nullable) NSArray *items;

@property (nonatomic, assign) FHNeighborhoodDetailSectionType sectionType;

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model;

@end

NS_ASSUME_NONNULL_END
