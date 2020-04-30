//
//  FHFloorPanDetailPropertyListCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailPropertyListCell : FHDetailBaseCell

@end

@interface FHFloorPanDetailPropertyListModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;

@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end
NS_ASSUME_NONNULL_END
