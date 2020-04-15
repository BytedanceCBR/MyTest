//
//  FHDetailAdvisoryLoanCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/4/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailAdvisoryLoanCell : FHDetailBaseCell

@end

@interface FHDetailAdvisoryLoanModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) FHDetailDownPaymentModel *downPayment;
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, weak)  FHHouseDetailContactViewModel *contactModel;
@property (nonatomic, weak)     FHHouseDetailBaseViewModel       *baseViewModel;
@end

NS_ASSUME_NONNULL_END
