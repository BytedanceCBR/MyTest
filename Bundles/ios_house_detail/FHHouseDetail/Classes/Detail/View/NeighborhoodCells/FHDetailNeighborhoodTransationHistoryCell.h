//
//  FHDetailNeighborhoodTransationHistoryCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/2/20.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNeighborhoodTransationHistoryCell : FHDetailBaseCell

@end

@interface FHDetailNeighborhoodTransationHistoryModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataTotalSalesModel *totalSales ;
@property (nonatomic, copy , nullable) NSString *totalSalesCount;
@property (nonatomic, copy) NSString *neighborhoodId;

@end

NS_ASSUME_NONNULL_END
