//
//  FHBuildingDetailTopImageCollectionViewCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//
//这里只响应infoLabel
#import "FHDetailBaseCell.h"
#import "FHBuildingDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBuildingDetailTopImageCollectionViewCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) FHBuildingIndexDidSelect IndexDidSelect;

- (void)updateWithIndexModel:(FHBuildingIndexModel *)indexModel;
@end

NS_ASSUME_NONNULL_END
