//
//  FHDetailMediaHeaderCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailMediaHeaderCell : FHDetailBaseCell

@end

NS_ASSUME_NONNULL_END

@interface FHDetailMediaHeaderModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHDetailOldDataHouseImageDictListModel> *houseImageDictList;
@end
