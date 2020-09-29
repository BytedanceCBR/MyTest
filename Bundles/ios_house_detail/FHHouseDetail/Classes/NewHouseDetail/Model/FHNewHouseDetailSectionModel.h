//
//  FHNewHouseDetailSectionModel.h
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import <Foundation/Foundation.h>
#import <IGListKit/IGListKit.h>
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHNewHouseDetailSectionType) {
    FHNewHouseDetailSectionTypeHeader,
    FHNewHouseDetailSectionTypeBaseInfo,
    FHNewHouseDetailSectionTypeFloorpan,
    FHNewHouseDetailSectionTypeSales,
    FHNewHouseDetailSectionTypeAgent,
    FHNewHouseDetailSectionTypeTimeline,
    FHNewHouseDetailSectionTypeAssess,
    FHNewHouseDetailSectionTypeRGC,
    FHNewHouseDetailSectionTypeSurrounding,
    FHNewHouseDetailSectionTypeBuildings,
    FHNewHouseDetailSectionTypeRecommend,
    FHNewHouseDetailSectionTypeDisclaimer
};

@interface FHNewHouseDetailSectionModel : NSObject<IGListDiffable>

- (instancetype)initWithDetailModel:(FHDetailNewModel *)model;

@property (nonatomic, strong) FHDetailNewModel *detailModel;

@property (nonatomic, copy, nullable) NSArray *items;

@property (nonatomic, assign) FHNewHouseDetailSectionType sectionType;

- (void)updateDetailModel:(FHDetailNewModel *)model;

@end

NS_ASSUME_NONNULL_END
