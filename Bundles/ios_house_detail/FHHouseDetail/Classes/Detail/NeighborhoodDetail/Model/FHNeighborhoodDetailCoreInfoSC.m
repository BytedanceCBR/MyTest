//
//  FHNeighborhoodDetailCoreInfoSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailCoreInfoSC.h"
#import "FHNeighborhoodDetailCoreInfoSM.h"
#import "FHNeighborhoodDetailHeaderTitleCollectionCell.h"
#import "FHNeighborhoodDetailSubMessageCollectionCell.h"
#import "FHNeighborhoodDetailPropertyInfoCollectionCell.h"
#import <FHHouseBase/FHMonitor.h>
#import "FHNeighborhoodDetailViewController.h"
@implementation FHNeighborhoodDetailCoreInfoSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inset = UIEdgeInsetsMake(-50, 15, 12, 15);
    }
    return self;
}

#pragma mark - DataSource
- (NSInteger)numberOfItems {
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        return [FHNeighborhoodDetailHeaderTitleCollectionCell cellSizeWithData:model.titleCellModel width:width];
    } else if (model.items[index] == model.subMessageModel) {
        return [FHNeighborhoodDetailSubMessageCollectionCell cellSizeWithData:model.subMessageModel width:width];
    } else if (model.items[index] == model.propertyInfoModel) {
        return [FHNeighborhoodDetailPropertyInfoCollectionCell cellSizeWithData:model.propertyInfoModel width:width];
    }
    return CGSizeZero;
}
- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        FHNeighborhoodDetailHeaderTitleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHeaderTitleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.titleCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.titleCellModel];
        return cell;
    } else if (model.items[index] == model.subMessageModel) {
        FHNeighborhoodDetailSubMessageCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSubMessageCollectionCell class] withReuseIdentifier:NSStringFromClass([model.subMessageModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.subMessageModel];
        return cell;
    } else if (model.items[index] == model.propertyInfoModel) {
        FHNeighborhoodDetailPropertyInfoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPropertyInfoCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyInfoModel class]) forSectionController:self atIndex:index];
        __weak FHNeighborhoodDetailCoreInfoSM *weakModelSM = model;
        [cell setFoldButtonActionBlock:^{
            weakModelSM.isFold = !weakModelSM.isFold;
            [weakSelf.detailViewController refreshSectionModel:weakModelSM animated:YES];
        }];
        [cell refreshWithData:model.propertyInfoModel];
        
        return cell;
    }
    return nil;
}
@end
