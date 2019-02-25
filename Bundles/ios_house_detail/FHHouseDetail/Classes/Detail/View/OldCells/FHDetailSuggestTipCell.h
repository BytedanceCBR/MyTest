//
//  FHDetailSuggestTipCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSuggestTipCell : FHDetailBaseCell

@end

@interface FHDetailSuggestTipModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailOldDataHousePricingRankBuySuggestionModel *buySuggestion ;

@end

NS_ASSUME_NONNULL_END
