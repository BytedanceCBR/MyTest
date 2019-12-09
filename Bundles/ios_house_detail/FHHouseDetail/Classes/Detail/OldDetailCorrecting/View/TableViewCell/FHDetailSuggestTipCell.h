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
#import "FHHouseDetailPhoneCallViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSuggestTipCell : FHDetailBaseCell

@end

@interface FHDetailSuggestTipModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailOldDataHousePricingRankBuySuggestionModel *buySuggestion ;
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@end

NS_ASSUME_NONNULL_END
