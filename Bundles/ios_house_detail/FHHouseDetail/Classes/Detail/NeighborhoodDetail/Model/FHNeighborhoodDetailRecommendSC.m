//
//  FHNeighborhoodDetailRecommendSC.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendSC.h"
#import "FHNeighborhoodDetailRecommendSM.h"
#import "FHNeighborhoodDetailRecommendCell.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNeighborhoodDetailRecommendSC()<IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailRecommendSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    return SM.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        return [FHNeighborhoodDetailRecommendCell cellSizeWithData:SM.items[index] width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    FHNeighborhoodDetailRecommendCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRecommendCell class] withReuseIdentifier:NSStringFromClass([SM.recommendCellModel class]) forSectionController:self atIndex:index];
    if (index >= 0 && index < SM.items.count) {
        [cell refreshWithData:SM.items[index]];
    }
    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    //FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"推荐房源";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}

@end
