//
//  FHOldDetailDisclaimerCell.h
//  Pods
//
//  Created by liuyu on 2019/12/5.
//


#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHHouseDetailBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// 免责声明
@interface FHOldDetailDisclaimerCell : FHDetailBaseCell

@end

// FHDetailDisclaimerModel
@interface FHOldDetailDisclaimerModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer ;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;

@end

NS_ASSUME_NONNULL_END                   
