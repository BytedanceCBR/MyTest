//
//  FHNeighborhoodDetailHouseSaleSC.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleSC.h"
#import "FHNeighborhoodDetailHouseSaleSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHNeighborhoodDetailHouseSaleSM.h"


@interface FHNeighborhoodDetailHouseSaleSC () <IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailHouseSaleSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
    }
    return self;
}


-(NSInteger)numberOfItems {
    return 1;
}

-(CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNeighborhoodDetailHouseSaleCellModel *cellModel= [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    return [FHNeighborhoodDetailHouseSaleCollectionCell cellSizeWithData:cellModel width:width];
}

-(__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleSM *model = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    FHNeighborhoodDetailHouseSaleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHouseSaleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.houseSaleCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.houseSaleCellModel];
    return cell;
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    FHNeighborhoodDetailHouseSaleCellModel *cellModel= [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    if(cellModel.neighborhoodSoldHouseData.total.length > 0){
        titleView.titleLabel.text = [NSString stringWithFormat:@"在售房源 (%@)",cellModel.neighborhoodSoldHouseData.total];
        titleView.arrowsImg.hidden = !cellModel.neighborhoodSoldHouseData.hasMore;
        titleView.userInteractionEnabled = YES;
    } else {
        titleView.titleLabel.text = @"在售房源";
        titleView.arrowsImg.hidden = YES;
        titleView.userInteractionEnabled = NO;
    }
    return titleView;
}

- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}

@end
