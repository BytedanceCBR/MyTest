//
//  FHDetailNeighborhoodMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/14.
//

#import "FHDetailBaseCell.h"
#import "FHMultiMediaModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHFloorPanPicShowModel;

@interface FHDetailNeighborhoodMediaHeaderCell : FHDetailBaseCell

+ (CGFloat)cellHeight;

@end

@interface FHDetailNeighborhoodMediaHeaderModel : FHDetailBaseModel

@property (strong, nonatomic) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, strong) FHHouseDetailMediaInfo *albumInfo;
@property (nonatomic, strong) FHHouseDetailMediaInfo *neighborhoodTopImage;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end


NS_ASSUME_NONNULL_END
