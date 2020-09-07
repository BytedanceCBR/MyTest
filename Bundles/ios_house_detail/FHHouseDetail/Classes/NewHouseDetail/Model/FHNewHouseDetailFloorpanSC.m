//
//  FHNewHouseDetailFloorpanSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailFloorpanSC.h"
#import "FHNewHouseDetailFloorpanSM.h"
#import "FHNewHouseDetailMultiFloorpanCollectionCell.h"

@implementation FHNewHouseDetailFloorpanSC

- (instancetype)init {
    if (self = [super init]) {
//        self.minimumLineSpacing = 20;
        if (!self.isFirstSection) {
            self.inset = UIEdgeInsetsMake(20, 15, 0, 15);
        }
    }
    return self;
}

- (void)didUpdateToObject:(id)object {
    if (object && [object isKindOfClass:[FHNewHouseDetailFloorpanSM class]]) {
        self.sectionModel = object;
    }
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailFloorpanSM *model = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    return [FHNewHouseDetailMultiFloorpanCollectionCell cellSizeWithData:model.floorpanCellModel width:width];
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailFloorpanSM *model = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    FHNewHouseDetailMultiFloorpanCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMultiFloorpanCollectionCell class] withReuseIdentifier:NSStringFromClass([model.floorpanCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.floorpanCellModel];
    return cell;
}

@end
