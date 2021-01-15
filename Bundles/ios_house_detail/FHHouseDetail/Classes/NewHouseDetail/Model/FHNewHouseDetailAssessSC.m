//
//  FHNewHouseDetailAssessSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAssessSC.h"
#import "FHNewHouseDetailAssessSM.h"
#import "FHNewHouseDetailAssessCollectionCell.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNewHouseDetailAssessSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailAssessSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (void)didUpdateToObject:(id)object {
    [super didUpdateToObject:object];
    
    FHNewHouseDetailAssessSM *sectionModel = (FHNewHouseDetailAssessSM *)self.sectionModel;
    
    NSMutableDictionary *paramsDict = @{}.mutableCopy;
    if (self.detailTracerDict) {
        [paramsDict addEntriesFromDictionary:self.detailTracerDict];
    }
    paramsDict[@"page_type"] = @"new_detail";
    paramsDict[@"from_gid"] = self.detailViewController.viewModel.houseId;
    paramsDict[@"element_type"] = @"guide";
    NSString *searchId = self.detailViewController.viewModel.listLogPB[@"search_id"];
    NSString *imprId = self.detailViewController.viewModel.listLogPB[@"impr_id"];
    paramsDict[@"search_id"] = searchId.length > 0 ? searchId : @"be_null";
    paramsDict[@"impr_id"] = imprId.length > 0 ? imprId : @"be_null";
    sectionModel.assessCellModel.tracerDic = paramsDict;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - FHNewHouseDetailSectionLeftMargin * 2;
    FHNewHouseDetailAssessSM *sectionModel = (FHNewHouseDetailAssessSM *)self.sectionModel;
    return [FHNewHouseDetailAssessCollectionCell cellSizeWithData:sectionModel.assessCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailAssessSM *sectionModel = (FHNewHouseDetailAssessSM *)self.sectionModel;
    FHNewHouseDetailAssessCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailAssessCollectionCell class] withReuseIdentifier:NSStringFromClass([sectionModel.assessCellModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:sectionModel.assessCellModel];
    __weak typeof(self) weakSelf = self;

    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNewHouseDetailStyle];
//    __weak typeof(self) weakSelf = self;
    [titleView setMoreActionBlock:^{
//        [weakSelf moreButtonAction];
    }];
    FHNewHouseDetailAssessSM *sectionModel = (FHNewHouseDetailAssessSM *)self.sectionModel;

    FHDetailNeighborhoodDataStrategyModel *strategy = sectionModel.assessCellModel.strategy;
    titleView.titleLabel.text = strategy.title.length > 0 ? strategy.title : @"小区攻略";
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - FHNewHouseDetailSectionLeftMargin * 2, 46);
    }
    return CGSizeZero;
}
@end
