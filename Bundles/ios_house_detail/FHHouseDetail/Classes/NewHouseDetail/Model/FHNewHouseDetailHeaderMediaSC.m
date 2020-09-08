//
//  FHNewHouseDetailHeaderMediaSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailHeaderMediaSC.h"
#import "FHNewHouseDetailHeaderMediaSM.h"
#import "FHNewHouseDetailHeaderMediaCollectionCell.h"

@interface FHNewHouseDetailHeaderMediaSC ()

@end

@implementation FHNewHouseDetailHeaderMediaSC

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNewHouseDetailHeaderMediaSM *model = (FHNewHouseDetailHeaderMediaSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width;
    FHNewHouseDetailHeaderMediaSM *model = (FHNewHouseDetailHeaderMediaSM *)self.sectionModel;
    if (model.items[index] == model.headerCellModel) {
        return [FHNewHouseDetailHeaderMediaCollectionCell cellSizeWithData:model.headerCellModel width:width];
    }
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailHeaderMediaSM *model = (FHNewHouseDetailHeaderMediaSM *)self.sectionModel;
    if (model.items[index] == model.headerCellModel) {
        FHNewHouseDetailHeaderMediaCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailHeaderMediaCollectionCell class] withReuseIdentifier:NSStringFromClass([model.headerCellModel class]) forSectionController:self atIndex:index];
        cell.detailTracerDict = self.detailTracerDict.copy;
        cell.detailViewController = [self detailViewController];
        [cell refreshWithData:model.headerCellModel];
        return cell;
    }
    return nil;
}

#pragma mark - Action


@end
