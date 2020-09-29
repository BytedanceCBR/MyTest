//
//  FHNewHouseDetailHeaderMediaCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/8.
//

#import "FHDetailBaseCell.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"
#import "FHDetailNewModel.h"
@class FHNewHouseDetailViewController;
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailHeaderMediaCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, strong, nullable) NSDictionary *detailTracerDict;
@end

@interface FHNewHouseDetailHeaderMediaModel : FHDetailBaseModel

@property (nonatomic, strong) FHHouseDetailMediaInfo *albumInfo;
@property (nonatomic, strong) FHHouseDetailMediaInfo *courtTopImage;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@end

NS_ASSUME_NONNULL_END
