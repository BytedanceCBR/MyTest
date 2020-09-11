//
//  FHNewHouseDetailSurroundingSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSurroundingSC.h"
#import "FHNewHouseDetailSurroundingSM.h"
#import "FHNewHouseDetailSurroundingCollectionCell.h"
#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHNewHouseDetailMapResultCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"



@interface FHNewHouseDetailSurroundingSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailSurroundingSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
//        self.displayDelegate = self;
    }
    return self;
}

#pragma mark - Action
- (void)imAction
{
    FHNewHouseDetailSurroundingCellModel *model = [(FHNewHouseDetailSurroundingSM *)self.sectionModel surroundingCellModel];
    FHNewHouseDetailSurroundingSM *sectionModel = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    if (model.surroundingInfo.surrounding.chatOpenurl.length > 0) {

        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"source_from"] = @"education_type";
        imExtra[@"im_open_url"] = model.surroundingInfo.surrounding.chatOpenurl;
        if(sectionModel.detailModel.data.surroundingInfo.associateInfo) {
            imExtra[kFHAssociateInfo] = sectionModel.detailModel.data.surroundingInfo.associateInfo;
        }

        [self.detailViewController.viewModel.contactViewModel onlineActionWithExtraDict:imExtra];
        
        [self.detailViewController.viewModel addClickOptionLog:@"education_type"];
    }
}

- (NSInteger)numberOfItems {
    return self.sectionModel.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    if (model.items[index] == model.surroundingCellModel) {
        return [FHNewHouseDetailSurroundingCollectionCell cellSizeWithData:model.surroundingCellModel width:width];
    } else if (model.items[index] == model.mapCellModel) {
        return [FHNewHouseDetailMapCollectionCell cellSizeWithData:model.mapCellModel width:width];
    }
    
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    if (model.items[index] == model.surroundingCellModel) {
        FHNewHouseDetailSurroundingCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailSurroundingCollectionCell class] withReuseIdentifier:NSStringFromClass([model.surroundingCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.surroundingCellModel];
        return cell;
    } else if (model.items[index] == model.mapCellModel) {
        FHNewHouseDetailMapCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapCollectionCell class] withReuseIdentifier:NSStringFromClass([model.mapCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.mapCellModel];
        return cell;
    }
    return nil;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    //新房暂时不需要跳转
//    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
//    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"位置及周边配套";
    // 设置下发标题
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
