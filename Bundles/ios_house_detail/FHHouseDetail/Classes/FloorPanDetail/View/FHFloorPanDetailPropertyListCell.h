//
//  FHFloorPanDetailPropertyListCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHDetailBaseCell.h"
#import "FHDetailFloorPanDetailInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailPropertyListCell : FHDetailBaseCell

@end

@interface FHFloorPanDetailPropertyListModel : FHDetailBaseModel

@property (nonatomic, copy , nullable) NSString *courtId;
@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHFloorPanDetailInfoModelBaseExtraModel *baseExtra;

@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end
NS_ASSUME_NONNULL_END
