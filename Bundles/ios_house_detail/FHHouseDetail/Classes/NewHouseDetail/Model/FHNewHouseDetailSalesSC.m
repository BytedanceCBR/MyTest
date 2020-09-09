//
//  FHNewHouseDetailSalesSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSalesSC.h"
#import "FHNewHouseDetailSalesSM.h"
#import "FHNewHouseDetailSalesCollectionCell.h"
#import "FHNewHouseDetailViewController.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNewHouseDetailSalesSC()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailSalesSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNewHouseDetailSalesSM *model = (FHNewHouseDetailSalesSM *)self.sectionModel;
    return [FHNewHouseDetailSalesCollectionCell cellSizeWithData:model.salesCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailSalesSM *model = (FHNewHouseDetailSalesSM *)self.sectionModel;
    FHNewHouseDetailSalesCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailSalesCollectionCell class] withReuseIdentifier:NSStringFromClass([model.salesCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.salesCellModel];
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
    titleView.titleLabel.text = @"优惠信息";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 39);
    }
    return CGSizeZero;
}

@end
