//
//  FHDetailAveragePriceComparisonCell.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/4/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailAveragePriceComparisonCell : FHDetailBaseCell

@end

@interface FHDetailAveragePriceComparisonModel : FHDetailBaseModel

@property (nonatomic, copy , nullable) NSString *neighborhoodId;
@property (nonatomic, copy , nullable) NSString *neighborhoodName;
@property (nonatomic, strong , nullable) FHDetailOldDataPriceAnalyzeModel *analyzeModel;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodPriceRangeModel *rangeModel;

@end

NS_ASSUME_NONNULL_END
