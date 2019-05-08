//
//  FHDetailDisclaimerCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/17.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// 免责声明
@interface FHDetailDisclaimerCell : FHDetailBaseCell

@end

// FHDetailDisclaimerModel
@interface FHDetailDisclaimerModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer ;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;

@end

NS_ASSUME_NONNULL_END
