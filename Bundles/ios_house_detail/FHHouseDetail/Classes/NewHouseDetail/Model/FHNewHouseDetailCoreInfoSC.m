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
//        self.inset = UIEdgeInsetsMake(-20, 15, 0, 15);
    }
    return self;
}

- (void)didUpdateToObject:(id)object {
    if (object && [object isKindOfClass:[FHNewHouseDetailCoreInfoSM class]]) {
        self.sectionModel = object;
    }
}

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
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        FHNewHouseDetailHeaderTitleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailHeaderTitleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.titleCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.titleCellModel];
        return cell;
    } else if (model.items[index] == model.propertyListCellModel) {
        FHNewHouseDetailPropertyListCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailPropertyListCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyListCellModel class]) forSectionController:self atIndex:index];
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
