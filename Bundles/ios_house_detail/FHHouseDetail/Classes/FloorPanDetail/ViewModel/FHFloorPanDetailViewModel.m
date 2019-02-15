//
//  FHFloorPanDetailViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailPhotoHeaderCell.h"

@implementation FHFloorPanDetailViewModel
// 注册cell类型
- (void)registerCellClasses {

    
}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)startLoadData
{
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNewDetail:@"6581052152733499652" completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        [wSelf processDetailData:model];
    }];
}


- (void)processDetailData:(FHDetailNewModel *)model {
    // 清空数据源
    [self.items removeAllObjects];
//    if (model.data.imageGroup) {
//        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
//        NSMutableArray *arrayHouseImage = [NSMutableArray new];
//        for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
//            FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
//            for (NSInteger j = 0; j < groupModel.images.count; j++) {
//                [arrayHouseImage addObject:groupModel.images[j]];
//            }
//        }
//        headerCellModel.houseImage = arrayHouseImage;
//        [self.items addObject:headerCellModel];
//    }
//
//    //楼盘户型
//    if (model.data.floorpanList) {
//        [self.items addObject:model.data.floorpanList];
//    }
//
//    if (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng) {
//        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
//        nearbyMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
//        nearbyMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
//        [self.items addObject:nearbyMapModel];
//
//        __weak typeof(self) wSelf = self;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if ((FHDetailNearbyMapCell *)nearbyMapModel.cell) {
//                ((FHDetailNearbyMapCell *)nearbyMapModel.cell).indexChangeCallBack = ^{
//                    [self reloadData];
//                };
//            }
//        });
//    }
//
    [self reloadData];
}
@end
