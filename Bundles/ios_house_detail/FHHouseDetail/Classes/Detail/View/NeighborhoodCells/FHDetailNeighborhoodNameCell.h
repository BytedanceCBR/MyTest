//
//  FHDetailNeighborhoodNameCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodNameCell : FHDetailBaseCell

@end

//FHDetailNeighborhoodNameModel
@interface FHDetailNeighborhoodNameModel : FHDetailBaseModel

@property (nonatomic, copy)     NSString       *name;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataNeighborhoodInfoModel *neighborhoodInfo ;

@end

NS_ASSUME_NONNULL_END
