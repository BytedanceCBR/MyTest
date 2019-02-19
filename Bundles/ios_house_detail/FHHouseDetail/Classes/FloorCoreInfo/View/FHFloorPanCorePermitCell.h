//
//  FHFloorPanCorePermitCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/19.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNewCoreDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailNewCoreDetailDataPermitListModel;

@interface FHFloorPanCorePermitCell : FHDetailBaseCell

@end

@interface FHFloorPanCorePermitCellModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHDetailNewCoreDetailDataPermitListModel *> *permitList;

@end

NS_ASSUME_NONNULL_END
