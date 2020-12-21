//
//  FHNeighborhoodDetailFloorpanSC.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/14.
//

#import "FHNeighborhoodDetailFloorpanSC.h"
#import "FHNeighborhoodDetailFloorpanSM.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHNeighborhoodDetailViewModel.h"
#import "FHNeighborhoodDetailFloorpanCollectionCell.h"
#import "FHNeighborhoodDetailRecommendTitleView.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <FHCommonDefines.h>

@interface FHNeighborhoodDetailFloorpanSC () <IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailFloorpanSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
    }
    return self;
}

- (void)didUpdateToObject:(id)object {
    [super didUpdateToObject:object];
    FHNeighborhoodDetailFloorpanSM *model = (FHNeighborhoodDetailFloorpanSM *)self.sectionModel;
    if (model.shouldShowSaleHouse) {
        self.inset = UIEdgeInsetsMake(0, 9, 0, 9);
    } else {
        self.inset = UIEdgeInsetsMake(0, 9, 12, 9);
    }
    
}

-(NSInteger)numberOfItems {
    return 1;
}

-(CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailFloorpanSM *model = (FHNeighborhoodDetailFloorpanSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 18;
    return [FHNeighborhoodDetailFloorpanCollectionCell cellSizeWithData:model.floorpanCellModel width:width];
}

-(__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailFloorpanSM *model = (FHNeighborhoodDetailFloorpanSM *)self.sectionModel;
    FHNeighborhoodDetailFloorpanCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailFloorpanCollectionCell class] withReuseIdentifier:NSStringFromClass([model class]) forSectionController:self atIndex:index];
    WeakSelf;
    cell.didSelectItem = ^(NSInteger index) {
        StrongSelf;
        [self collectionCellClick:index];
    };
    [cell refreshWithData:model.floorpanCellModel];
    return cell;
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendTitleView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHNeighborhoodDetailRecommendTitleView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontSemibold:16];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"在售户型";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 34);
    }
    return CGSizeZero;
}


- (void)collectionCellClick:(NSInteger)index {
    FHNeighborhoodDetailFloorpanCellModel *model = [(FHNeighborhoodDetailFloorpanSM *)self.sectionModel floorpanCellModel];
    if (model.saleHouseInfoModel.neighborhoodSaleHouseList.count > 0 && index >= 0 && index < model.saleHouseInfoModel.neighborhoodSaleHouseList.count){
        FHDetailNeighborhoodSaleHouseInfoItemModel *item = model.saleHouseInfoModel.neighborhoodSaleHouseList[index];
        FHDetailNeighborhoodModel *detailModel = (FHDetailNeighborhoodModel*)self.detailViewController.viewModel.detailData;
        NSString *neighborhood_id = @"be_null";
        if (detailModel && detailModel.data.neighborhoodInfo.id.length > 0) {
            neighborhood_id = detailModel.data.neighborhoodInfo.id;
        }
        NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"element_from"] = @"neighborhood_model";
        tracerDic[@"enter_from"] = @"neighborhood_detail";
        tracerDic[@"category_name"] = @"neighborhood_house_list";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
        if(detailModel.data.neighborhoodInfo.name.length > 0) {
            if(item.count.length > 0) {
                userInfo[@"title"] = [NSString stringWithFormat:@"%@(%@)",detailModel.data.neighborhoodInfo.name,item.count];
            } else {
                userInfo[@"title"] = detailModel.data.neighborhoodInfo.name;
            }
        } else {
            userInfo[@"title"] = @"同小区房源";
        }
        if (neighborhood_id.length > 0) {
            userInfo[@"neighborhood_id"] = neighborhood_id;
        }
        if (self.detailViewController.viewModel.houseId.length > 0) {
            userInfo[@"house_id"] = self.detailViewController.viewModel.houseId;
        }
        userInfo[@"list_vc_type"] = @(5);
        
        TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
        NSString *urlStr = nil;
        if(item.queryValue.length > 0) {
            NSString *conditionParam = [[NSString stringWithFormat:@"room_num[]=%@",item.queryValue] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            urlStr = [NSString stringWithFormat:@"snssdk1370://house_list_in_neighborhood?%@",conditionParam];
        } else {
            urlStr = @"snssdk1370://house_list_in_neighborhood";
        }
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInf];
        }
    }
}

@end
