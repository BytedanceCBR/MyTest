//
//  FHNewHouseDetailFloorpanSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailFloorpanSM.h"

@implementation FHNewHouseDetailFloorpanSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    FHNewHouseDetailMultiFloorpanCellModel *floorPan = [[FHNewHouseDetailMultiFloorpanCellModel alloc]init];
    floorPan.floorPanList.courtId = model.data.coreInfo.id;
    floorPan.floorPanList = model.data.floorpanList;
    self.floorpanCellModel = floorPan;
}

@end
