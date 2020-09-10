//
//  FHNewHouseDetailRecommendSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailRecommendSC.h"
#import "FHNewHouseDetailRecommendSM.h"
#import "FHNewHouseDetailRelatedCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNewHouseDetailRecommendSC()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailRecommendSC

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
    FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    return [FHNewHouseDetailRelatedCollectionCell cellSizeWithData:model.relatedCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
       FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    FHNewHouseDetailRelatedCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRelatedCollectionCell class] withReuseIdentifier:NSStringFromClass([model.relatedCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:model.relatedCellModel];
    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"猜你喜欢";
    titleView.arrowsImg.hidden = YES;
    [titleView.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(0);
    }];
    titleView.userInteractionEnabled = NO;
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
