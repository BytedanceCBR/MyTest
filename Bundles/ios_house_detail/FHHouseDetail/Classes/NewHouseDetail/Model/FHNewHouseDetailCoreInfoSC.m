//
//  FHNewHouseDetailCoreInfoSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailCoreInfoSC.h"
#import "FHNewHouseDetailCoreInfoSM.h"
#import "FHNewHouseDetailHeaderTitleCollectionCell.h"
#import "FHNewHouseDetailPropertyListCollectionCell.h"
#import "FHNewHouseDetailAddressInfoCollectionCell.h"
#import "FHNewHouseDetailPriceNotifyCollectionCell.h"

#import "FHDetailSectionTitleCollectionView.h"
@implementation FHNewHouseDetailCoreInfoSC

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(-20, 15, 20, 15);
//        self.minimumLineSpacing = 20;
    }
    return self;
}

#pragma mark - Action
- (void)goToInfoDetail {
    FHNewHouseDetailPropertyListCellModel *model = [(FHNewHouseDetailCoreInfoSM *)self.sectionModel propertyListCellModel];

    NSString *courtId = model.courtId;
    if (courtId.length) {
        NSDictionary *dictTrace = self.detailTracerDict.copy;

        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
        [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
        [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
        [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
        [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];

        [FHUserTracker writeEvent:@"click_house_info" params:mutableDict];

        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        [infoDict addEntriesFromDictionary:self.subPageParams];
        [infoDict setValue:model.houseName forKey:@"courtInfo"];
        if (model.disclaimerModel) {
            [infoDict setValue:model.disclaimerModel forKey:@"disclaimerInfo"];
        }

        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_coreinfo_detail?court_id=%@",courtId]] userInfo:info];
    }
}

#pragma mark - DataSource
- (NSInteger)numberOfItems {
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        return [FHNewHouseDetailHeaderTitleCollectionCell cellSizeWithData:model.titleCellModel width:width];
    } else if (model.items[index] == model.propertyListCellModel) {
        return [FHNewHouseDetailPropertyListCollectionCell cellSizeWithData:model.propertyListCellModel width:width];
    } else if (model.items[index] == model.addressInfoCellModel) {
        return [FHNewHouseDetailAddressInfoCollectionCell cellSizeWithData:model.addressInfoCellModel width:width];
    } else if (model.items[index] == model.priceNotifyCellModel) {
        return [FHNewHouseDetailPriceNotifyCollectionCell cellSizeWithData:model.priceNotifyCellModel width:width];
    }
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        FHNewHouseDetailHeaderTitleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailHeaderTitleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.titleCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.titleCellModel];
        return cell;
    } else if (model.items[index] == model.propertyListCellModel) {
        FHNewHouseDetailPropertyListCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailPropertyListCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyListCellModel class]) forSectionController:self atIndex:index];
        [cell setDetailActionBlock:^{
            [weakSelf goToInfoDetail];
        }];
        [cell refreshWithData:model.propertyListCellModel];
        return cell;
    } else if (model.items[index] == model.addressInfoCellModel) {
        FHNewHouseDetailAddressInfoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailAddressInfoCollectionCell class] withReuseIdentifier:NSStringFromClass([model.addressInfoCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.addressInfoCellModel];
        return cell;

    } else if (model.items[index] == model.priceNotifyCellModel) {
        FHNewHouseDetailPriceNotifyCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailPriceNotifyCollectionCell class] withReuseIdentifier:NSStringFromClass([model.priceNotifyCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.priceNotifyCellModel];
        return cell;
    }
    return nil;
}

@end
