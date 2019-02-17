//
//  FHHouseNewDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseNewDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewModel.h"
#import "FHDetailBaseCell.h"
#import "FHDetailNearbyMapCell.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailHouseModelCell.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailNewHouseCoreInfoCell.h"
#import "FHDetailNewHouseNewsCell.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHDetailGrayLineCell.h"

@implementation FHHouseNewDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];

    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];

    [self.tableView registerClass:[FHDetailNewHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseCoreInfoCell class])];

    [self.tableView registerClass:[FHDetailHouseModelCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseModelCell class])];
    
    [self.tableView registerClass:[FHDetailNewHouseNewsCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseNewsCell class])];
    
      [self.tableView registerClass:[FHDetailNewTimeLineItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];

    [self.tableView registerClass:[FHDetailNearbyMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapCell class])];

}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    
    // 标题
    if ([model isKindOfClass:[FHDetailHouseNameModel class]]) {
        return [FHDetailHouseNameCell class];
    }
    
    // 核心信息
    if ([model isKindOfClass:[FHDetailNewHouseCoreInfoModel class]]) {
        return [FHDetailNewHouseCoreInfoCell class];
    }
    
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }
    
    //楼盘户型
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        return [FHDetailHouseModelCell class];
    }
    
    //楼盘动态标题
    if ([model isKindOfClass:[FHDetailNewHouseNewsCellModel class]]) {
        return [FHDetailNewHouseNewsCell class];
    }
    
    //楼盘动态标题
    if ([model isKindOfClass:[FHDetailNewTimeLineItemModel class]]) {
        return [FHDetailNewTimeLineItemCell class];
    }
    
    if ([model isKindOfClass:[FHDetailNearbyMapModel class]]) {
        return [FHDetailNearbyMapCell class];
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
    [FHHouseDetailAPI requestNewDetail:self.houseId completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        [wSelf processDetailData:model];
    }];
}


- (void)processDetailData:(FHDetailNewModel *)model {
    // 清空数据源
    [self.items removeAllObjects];
    if (model.data.imageGroup) {
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        NSMutableArray *arrayHouseImage = [NSMutableArray new];
        for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
            FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
            for (NSInteger j = 0; j < groupModel.images.count; j++) {
                [arrayHouseImage addObject:groupModel.images[j]];
            }
        }
        headerCellModel.houseImage = arrayHouseImage;
        [self.items addObject:headerCellModel];
    }
    
    // 添加标题
    if (model.data) {
        FHDetailHouseNameModel *houseName = [[FHDetailHouseNameModel alloc] init];
        houseName.type = 1;
        houseName.name = model.data.coreInfo.name;
        houseName.aliasName = model.data.coreInfo.aliasName;
        houseName.type = 2;
        houseName.tags = model.data.tags;
        [self.items addObject:houseName];
    }
    
    //核心信息
    if (model.data.coreInfo) {
        FHDetailNewHouseCoreInfoModel *houseName = [[FHDetailNewHouseCoreInfoModel alloc] init];
        houseName.pricingPerSqm = model.data.coreInfo.pricingPerSqm;
        houseName.constructionOpendate = model.data.coreInfo.constructionOpendate;
        houseName.courtAddress = model.data.coreInfo.courtAddress;
        houseName.pricingSubStauts = model.data.userStatus.pricingSubStatus;
        houseName.gaodeLat = model.data.coreInfo.gaodeLat;
        houseName.gaodeLng = model.data.coreInfo.gaodeLng;
        [self.items addObject:houseName];
    }
    
    //楼盘户型
    if (model.data.floorpanList) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        
        [self.items addObject:model.data.floorpanList];
    }
    
    //楼盘动态
    if (model.data.timeline.list.count != 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        
        FHDetailNewHouseNewsCellModel *newsCellModel = [[FHDetailNewHouseNewsCellModel alloc] init];
        newsCellModel.hasMore = model.data.timeline.hasMore;
        [self.items addObject:newsCellModel];
        
        for (NSInteger i = 0; i < model.data.timeline.list.count; i++) {
            FHDetailNewDataTimelineListModel *itemModel = model.data.timeline.list[i];
            FHDetailNewTimeLineItemModel *item = [[FHDetailNewTimeLineItemModel alloc] init];
            item.desc = itemModel.desc;
            item.title = itemModel.title;
            item.createdTime = itemModel.createdTime;
            item.isFirstCell = (i == 0);
            item.isLastCell = (i == model.data.timeline.list.count - 1);

            [self.items addObject:item];
        }
    }
    
    if (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng) {
        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
        nearbyMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
        nearbyMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
//        nearbyMapModel.tableView = self.tableView;
        [self.items addObject:nearbyMapModel];
        
        __weak typeof(self) wSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((FHDetailNearbyMapCell *)nearbyMapModel.cell) {
                ((FHDetailNearbyMapCell *)nearbyMapModel.cell).indexChangeCallBack = ^{
                    [self reloadData];
                };
            }
        });
        
        if (model.data.imageGroup) {
            FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
            NSMutableArray *arrayHouseImage = [NSMutableArray new];
            for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
                FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
                for (NSInteger j = 0; j < groupModel.images.count; j++) {
                    [arrayHouseImage addObject:groupModel.images[j]];
                }
            }
            headerCellModel.houseImage = arrayHouseImage;
            [self.items addObject:headerCellModel];
        }
    }
    
    [self reloadData];
}

@end
