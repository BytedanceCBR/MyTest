//
//  FHNeighborhoodDetailSurroundingNeighborSC.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/11.
//

#import "FHNeighborhoodDetailSurroundingNeighborSC.h"
#import "FHNeighborhoodDetailSurroundingNeighborSM.h"
#import "FHNeighborhoodDetailSurroundingNeighborCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNeighborhoodDetailSurroundingNeighborSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailSurroundingNeighborSC

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
    CGFloat width = self.collectionContext.containerSize.width - 18;
    return CGSizeMake(width, 208);
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    FHNeighborhoodDetailSurroundingNeighborCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSurroundingNeighborCollectionCell class] withReuseIdentifier:NSStringFromClass([sectionModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:sectionModel.model];
    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNeighborhoodDetailStyle];
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    titleView.titleLabel.text = sectionModel.titleName;
    titleView.subTitleLabel.text = sectionModel.moreTitle;
    titleView.arrowsImg.hidden = NO;
    titleView.subTitleLabel.hidden = NO;
    [titleView.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(titleView.arrowsImg.mas_left).mas_offset(-2);
        make.centerY.mas_equalTo(titleView.titleLabel);
    }];
    [titleView setMoreActionBlock:^{
        //小区列表
    }];
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 30, 46);
    }
    return CGSizeZero;
}

@end
