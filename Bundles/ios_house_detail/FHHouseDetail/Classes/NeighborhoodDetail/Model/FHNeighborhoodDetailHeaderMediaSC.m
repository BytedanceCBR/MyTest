//
//  FHNeighborhoodDetailHeaderMediaSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailHeaderMediaSC.h"
#import "FHNeighborhoodDetailHeaderMediaSM.h"
#import "FHNeighborhoodDetailHeaderMediaCollectionCell.h"

@implementation FHNeighborhoodDetailHeaderMediaSC
- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNeighborhoodDetailHeaderMediaSM *model = (FHNeighborhoodDetailHeaderMediaSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width;
    FHNeighborhoodDetailHeaderMediaSM *model = (FHNeighborhoodDetailHeaderMediaSM *)self.sectionModel;
    if (model.items[index] == model.headerCellModel) {
        return [FHNeighborhoodDetailHeaderMediaCollectionCell cellSizeWithData:model.headerCellModel width:width];
    }
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailHeaderMediaSM *model = (FHNeighborhoodDetailHeaderMediaSM *)self.sectionModel;
    if (model.items[index] == model.headerCellModel) {
        FHNeighborhoodDetailHeaderMediaCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHeaderMediaCollectionCell class] withReuseIdentifier:NSStringFromClass([model.headerCellModel class]) forSectionController:self atIndex:index];
        cell.detailTracerDict = self.detailTracerDict.copy;
        [cell refreshWithData:model.headerCellModel];
        return cell;
    }
    return [super defaultCellAtIndex:index];
}

@end
