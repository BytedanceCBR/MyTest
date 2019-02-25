//
//  FHFloorPanDetailPropertyCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/20.
//

#import "FHDetailBaseCell.h"
#import "FHDetailFloorPanDetailInfoModel.h"

@class FHDetailFloorPanDetailInfoDataBaseInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailPropertyCell : FHDetailBaseCell

@end


@interface FHFloorPanDetailPropertyCellModel : JSONModel

@property (nonatomic, strong) NSArray<FHDetailFloorPanDetailInfoDataBaseInfoModel> *baseInfo;

@end

NS_ASSUME_NONNULL_END
