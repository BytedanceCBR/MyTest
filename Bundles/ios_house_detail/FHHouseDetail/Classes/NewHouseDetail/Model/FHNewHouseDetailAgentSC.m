//
//  FHNewHouseDetailAgentSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAgentSC.h"
#import "FHNewHouseDetailAgentSM.h"
#import "FHNewHouseDetailReleatorMoreCell.h"
#import "FHNewHouseDetailReleatorCollectionCell.h"
#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHDetailSectionTitleCollectionView.h"

@interface FHNewHouseDetailAgentSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNewHouseDetailAgentSC

- (instancetype)init {
    if (self = [super init]) {
//        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    if (agentSM.recommendedRealtors.count <= 3) {
        return agentSM.recommendedRealtors.count;
    }
    if (!agentSM.isFold) {
        return 4;
    } else {
        return agentSM.recommendedRealtors.count + 1;
    }
    return 0;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    CGFloat height = 65;
    if (index == agentSM.recommendedRealtors.count) {
        height = 55;
    }
    return CGSizeMake(width, height);
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    if ((!agentSM.isFold && agentSM.recommendedRealtors.count > 3 && index == 3) || (agentSM.isFold && agentSM.recommendedRealtors.count > 3 && index == agentSM.recommendedRealtors.count)) {
        //展开，收起
        FHNewHouseDetailReleatorMoreCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailReleatorMoreCell class] forSectionController:self atIndex:index];
        __weak FHNewHouseDetailAgentSM *weakAgentSM = agentSM;
        [cell setFoldButtonActionBlock:^{
            weakAgentSM.isFold = !weakAgentSM.isFold;
            [weakSelf.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext>  _Nonnull batchContext) {
//                [batchContext reloadInSectionController:weakAgentSM atIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(3, <#NSUInteger len#>)]
                [batchContext reloadSectionController:weakSelf];
            } completion:^(BOOL finished) {
                
            }];
//            weakSelf.collectionContext relo
        }];
        return cell;
    } else {
        FHDetailContactModel *model = agentSM.recommendedRealtors[index];
        FHNewHouseDetailReleatorCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailReleatorCollectionCell class] forSectionController:self atIndex:index];
        [cell refreshWithData:model];
        [cell setImClickBlock:^(FHDetailContactModel * _Nonnull model) {
            
        }];
        [cell setPhoneClickBlock:^(FHDetailContactModel * _Nonnull model) {
            
        }];
        [cell setLicenseClickBlock:^(FHDetailContactModel * _Nonnull model) {
            
        }];
        return cell;
    }
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
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;

    // 设置下发标题
    if(agentSM.recommendedRealtorsTitle.length > 0) {
        titleView.titleLabel.text = agentSM.recommendedRealtorsTitle;
    }else {
        titleView.titleLabel.text = @"优选顾问";
    }
    [titleView setSubTitleWithTitle:agentSM.recommendedRealtorsSubTitle];

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
