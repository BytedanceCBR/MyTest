//
//  FHNeighborhoodDetailHeaderMediaCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHDetailBaseCell.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHMultiMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailHeaderMediaCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong, nullable) NSDictionary *detailTracerDict;

@end

@interface FHNeighborhoodDetailHeaderMediaModel : FHDetailBaseModel

@property (nonatomic, strong) FHHouseDetailMediaInfo *albumInfo;
@property (nonatomic, strong) FHHouseDetailMediaInfo *neighborhoodTopImage;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@end

NS_ASSUME_NONNULL_END
