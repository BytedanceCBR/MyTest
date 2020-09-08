//
//  FHNewHouseDetailFloorpanSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailFloorpanSC.h"
#import "FHNewHouseDetailFloorpanSM.h"
#import "FHNewHouseDetailMultiFloorpanCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNewHouseDetailFloorpanSC ()<IGListSupplementaryViewSource>

@end


@implementation FHNewHouseDetailFloorpanSC

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(0, 15, 20, 15);
//        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;
    }
    return self;
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

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    FHNewHouseDetailMultiFloorpanCellModel *cellModel = [(FHNewHouseDetailFloorpanSM *)self.sectionModel floorpanCellModel];
    if (cellModel.floorPanList.totalNumber.length > 0) {
        titleView.titleLabel.text = [NSString stringWithFormat:@"户型介绍（%@）",cellModel.floorPanList.totalNumber];
        if (cellModel.floorPanList.totalNumber.integerValue >= 3) {
            titleView.arrowsImg.hidden = NO;
            titleView.userInteractionEnabled = YES;
        } else {
            titleView.arrowsImg.hidden = YES;
            titleView.userInteractionEnabled = NO;
        }
    } else {
        titleView.titleLabel.text = @"户型介绍";
        titleView.arrowsImg.hidden = YES;
        titleView.userInteractionEnabled = NO;
    }
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 46);
    }
    return CGSizeZero;
}

@end
