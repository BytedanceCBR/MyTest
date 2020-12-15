//
//  FHNeighborhoodDetailBaseInfoSC.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/10.
//

#import "FHNeighborhoodDetailBaseInfoSC.h"
#import "FHNeighborhoodDetailPropertyInfoCollectionCell.h"
#import "FHNeighborhoodDetailBaseInfoSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import <TTRoute/TTRoute.h>
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNeighborhoodDetailBaseInfoSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailBaseInfoSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (void)pushBaseInfo {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    userInfo[@"route"] = @"/neighbor_info_list_page";
    
    FHNeighborhoodDetailBaseInfoSM *model = (FHNeighborhoodDetailBaseInfoSM *)self.sectionModel;
    
    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    tracerDict[@"element_from"] = @"neighborhood_info";
    tracerDict[@"enter_from"] = @"neighborhood_detail";
    params[@"report_params"] = [tracerDict btd_jsonStringEncoded];
    
    if (model.neighborhoodDetailModules) {
        params[@"neighbor_info_page"] = [@{@"neighborhood_detail_modules" : model.neighborhoodDetailModules} btd_jsonStringEncoded];
    }
    
    userInfo[@"params"] = [params btd_jsonStringEncoded];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://flutter"]] userInfo:TTRouteUserInfoWithDict(userInfo)];

}

-(NSInteger)numberOfItems {
    return 1;
}

-(CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 9 * 2;
    FHNeighborhoodDetailBaseInfoSM *model= (FHNeighborhoodDetailBaseInfoSM *)self.sectionModel;
    return [FHNeighborhoodDetailPropertyInfoCollectionCell cellSizeWithData:model.propertyInfoModel width:width];
}

-(__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailBaseInfoSM *model= (FHNeighborhoodDetailBaseInfoSM *)self.sectionModel;
    FHNeighborhoodDetailPropertyInfoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPropertyInfoCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyInfoModel class]) forSectionController:self atIndex:index];
    __weak typeof(self) weakSelf = self;
    [cell setAllButtonActionBlock:^{
        [weakSelf pushBaseInfo];
    }];
    [cell refreshWithData:model.propertyInfoModel];
    
    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
//    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNeighborhoodDetailStyle];
    titleView.titleLabel.text = @"小区信息";
    // 设置下发标题
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 9 * 2, 46);
    }
    return CGSizeZero;
}

@end
