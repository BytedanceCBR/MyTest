//
//  FHNewHouseDetailDisclaimerCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/9.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailDisclaimerCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^clickFeedback)(void);

@end

@interface FHNewHouseDetailDisclaimerModel: NSObject

@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer ;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;

@end

NS_ASSUME_NONNULL_END
