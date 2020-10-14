//
//  FHNeighborhoodDetailFloorpanSC.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/14.
//

#import "FHNeighborhoodDetailFloorpanSC.h"
#import "FHNeighborhoodDetailFloorpanSM.h"
#import "FHNeighborhoodDetailFloorpanCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"


@interface FHNeighborhoodDetailFloorpanSC () <IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailFloorpanSC

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
    return CGSizeMake(width, 200);
}

-(__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailFloorpanSM *model = (FHNeighborhoodDetailFloorpanSM *)self.sectionModel;
    FHNeighborhoodDetailFloorpanCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailFloorpanCollectionCell class] withReuseIdentifier:NSStringFromClass([model class]) forSectionController:self atIndex:index];
//    [cell refreshWithData:model.houseSaleCellModel];
    return cell;
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"小区户型";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 46);
    }
    return CGSizeZero;
}

@end
