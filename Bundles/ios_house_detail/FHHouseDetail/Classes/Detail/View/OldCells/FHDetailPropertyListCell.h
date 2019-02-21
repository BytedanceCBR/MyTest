//
//  FHDetailPropertyListCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

// 用于二手房属性列表
@interface FHDetailPropertyListCell : FHDetailBaseCell

@end

@interface FHPropertyListRowView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;

@end

// FHDetailPropertyListModel
@interface FHDetailPropertyListModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailDataBaseInfoModel> *baseInfo;

@end

NS_ASSUME_NONNULL_END
