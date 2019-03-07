//
//  FHDetailListEntranceCell.h
//  Pods
//
//  Created by 张静 on 2019/3/7.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailDataListEntranceItemModel;
@interface FHDetailListEntranceItemView : UIControl

@property (nonatomic, strong)   UIImageView       *rightArrow;
@property (nonatomic, strong)   UIImageView       *icon;
@property (nonatomic, strong)   UILabel       *nameLabel;

@end

@interface FHDetailListEntranceCell : FHDetailBaseCell

@end

@interface FHDetailListEntranceModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailDataListEntranceItemModel *> *listEntrance;

@end

NS_ASSUME_NONNULL_END
