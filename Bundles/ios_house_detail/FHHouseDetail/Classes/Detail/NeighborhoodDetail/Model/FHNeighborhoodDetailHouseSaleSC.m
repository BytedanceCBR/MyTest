//
//  FHNeighborhoodDetailHouseSaleSC.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleSC.h"
#import "FHNeighborhoodDetailHouseSaleSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHNeighborhoodDetailHouseSaleSM.h"
#import "FHCommonDefines.h"

@interface FHNeighborhoodDetailHouseSaleSC () <IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailHouseSaleSC

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
    FHNeighborhoodDetailHouseSaleCellModel *cellModel= [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    return [FHNeighborhoodDetailHouseSaleCollectionCell cellSizeWithData:cellModel width:width];
}

-(__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleSM *model = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    FHNeighborhoodDetailHouseSaleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHouseSaleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.houseSaleCellModel class]) forSectionController:self atIndex:index];
    WeakSelf;
    cell.didSelectItem = ^(NSInteger index) {
        StrongSelf;
        if(index == model.houseSaleCellModel.neighborhoodSoldHouseData.items.count) {
            [self moreButtonClick];
        } else {
            [self collectionCellClick:index];
        }
    };
    cell.willShowItem = ^(NSInteger index) {
        StrongSelf;
        [self collectionCellShow:index];
    };
    [cell refreshWithData:model.houseSaleCellModel];
    return cell;
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    WeakSelf;
    titleView.moreActionBlock = ^{
        StrongSelf;
        [self moreButtonClick];
    };
    FHNeighborhoodDetailHouseSaleCellModel *cellModel= [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    if(cellModel.neighborhoodSoldHouseData.total.length > 0){
        titleView.titleLabel.text = [NSString stringWithFormat:@"在售房源 (%@)",cellModel.neighborhoodSoldHouseData.total];
        titleView.arrowsImg.hidden = !cellModel.neighborhoodSoldHouseData.hasMore;
        titleView.userInteractionEnabled = YES;
    } else {
        titleView.titleLabel.text = @"在售房源";
        titleView.arrowsImg.hidden = YES;
        titleView.userInteractionEnabled = NO;
    }
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

-(void)moreButtonClick {
    FHNeighborhoodDetailHouseSaleCellModel *model = [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    if (model.neighborhoodSoldHouseData  && model.neighborhoodSoldHouseData.hasMore) {
        FHDetailNeighborhoodModel *detailModel = (FHDetailNeighborhoodModel*)self.detailViewController.viewModel.detailData;
        NSString *neighborhood_id = @"be_null";
        if (detailModel && detailModel.data.neighborhoodInfo.id.length > 0) {
            neighborhood_id = detailModel.data.neighborhoodInfo.id;
        }
        NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.detailViewController.viewModel.listLogPB ?: @"be_null";
        tracerDic[@"category_name"] = @"same_neighborhood_list";
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"neighborhood_detail";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
        if (detailModel.data.neighborhoodInfo.name.length > 0) {
            if (model.neighborhoodSoldHouseData.total.length > 0) {
                userInfo[@"title"] = [NSString stringWithFormat:@"小区房源(%@)",model.neighborhoodSoldHouseData.total];
            } else {
                userInfo[@"title"] = @"小区房源";
            }
        } else {
            userInfo[@"title"] = @"小区房源";// 默认值
        }
        if (neighborhood_id.length > 0) {
            userInfo[@"neighborhood_id"] = neighborhood_id;
        }
        if (self.detailViewController.viewModel.houseId.length > 0) {
            userInfo[@"house_id"] = self.detailViewController.viewModel.houseId;
        }
        if (model.neighborhoodSoldHouseData.searchId.length > 0) {
            userInfo[@"search_id"] = model.neighborhoodSoldHouseData.searchId;
        }
        userInfo[@"list_vc_type"] = @(5);
        
        TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
        NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://house_list_in_neighborhood"];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInf];
        }
    }
}

- (void)collectionCellClick:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleCellModel *model = [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    if (model.neighborhoodSoldHouseData && model.neighborhoodSoldHouseData.items.count > 0 && index >= 0 && index < model.neighborhoodSoldHouseData.items.count) {
        // 点击cell处理
        FHSearchHouseDataItemsModel *dataItem = model.neighborhoodSoldHouseData.items[index];
        NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeSecondHandHouse];
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"neighborhood_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeSecondHandHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",dataItem.hid];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

// 不重复调用
- (void)collectionCellShow:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleCellModel *model = [(FHNeighborhoodDetailHouseSaleSM *)self.sectionModel houseSaleCellModel];
    if (model.neighborhoodSoldHouseData && model.neighborhoodSoldHouseData.items.count > 0 && index >= 0 && index < model.neighborhoodSoldHouseData.items.count) {
        // cell 显示 处理
        FHSearchHouseDataItemsModel *dataItem = model.neighborhoodSoldHouseData.items[index];
        // house_show
        NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = @"old";
        tracerDic[@"element_type"] = @"sale_same_neighborhood";
        tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
        tracerDic[@"group_id"] = dataItem.groupId.length > 0 ? dataItem.groupId : (dataItem.hid ? dataItem.hid : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}


@end
