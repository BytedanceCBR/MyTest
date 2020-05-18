//
//  FHFloorPanCorePermitCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/4/23.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewCoreDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanCorePermitCell : FHDetailBaseCell

@end

@interface FHFloorPanCorePermitCellItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *permitName;
@property (nonatomic, copy , nullable) NSString *permitValue;
@property (nonatomic, strong , nullable) FHDetailNewCoreDetailDataPermitListImageModel *image ;

@end

@interface FHFloorPanCorePermitCellModel : JSONModel

@property (nonatomic, strong) NSArray <FHFloorPanCorePermitCellItemModel *>* list;

@end

NS_ASSUME_NONNULL_END
