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
#import "FHNeighborhoodDetailRecommendTitleView.h"
#import "FHCommonDefines.h"
#import "FHNeighborhoodDetailHouseSaleCell.h"
#import "FHNeighborhoodDetailRelatedHouseMoreCell.h"
#import "FHHouseSecondCardViewModel.h"

@interface FHNeighborhoodDetailHouseSaleSC () <IGListSupplementaryViewSource, IGListDisplayDelegate>

@end

@implementation FHNeighborhoodDetailHouseSaleSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
    }
    return self;
}


-(NSInteger)numberOfItems {
    FHNeighborhoodDetailHouseSaleSM *model = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    if (model.total <= 3) {
        return model.items.count;
    }
    return model.items.count + 1;
}

-(CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 18;
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        return [FHNeighborhoodDetailRecommendCell cellSizeWithData:SM.items[index] width:width];
    } else if (index == SM.items.count) {
        return CGSizeMake(width, 56);
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        FHNeighborhoodDetailHouseSaleCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHouseSaleCell class] withReuseIdentifier:NSStringFromClass([SM class]) forSectionController:self atIndex:index];
        [cell refreshWithData:SM.items[index] withLast:(index == SM.items.count - 1) ? YES : NO];
        return cell;
    } else {
        FHNeighborhoodDetailRelatedHouseMoreCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRelatedHouseMoreCell class] forSectionController:self atIndex:index];
        [cell refreshWithTitle:SM.moreTitle];
        return cell;
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    if (index < [SM.items count]) {
        [self collectionCellClick:index];
    } else if (index == [SM.items count]) {
        [self moreButtonClick];
    }
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController {
    
}

/**
 Tells the delegate that the specified section controller is no longer being displayed.

 @param listAdapter       The list adapter for the section controller.
 @param sectionController The section controller that is no longer displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController {
    
}

/**
 Tells the delegate that a cell in the specified list is about to be displayed.

 @param listAdapter The list adapter in which the cell will display.
 @param sectionController The section controller that is displaying the cell.
 @param cell The cell about to be displayed.
 @param index The index of the cell in the section.
 */

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        [self collectionCellShow:index];
    }
}

/**
 Tells the delegate that a cell in the specified list is no longer being displayed.

 @param listAdapter The list adapter in which the cell was displayed.
 @param sectionController The section controller that is no longer displaying the cell.
 @param cell The cell that is no longer displayed.
 @param index The index of the cell in the section.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendTitleView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHNeighborhoodDetailRecommendTitleView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontSemibold:16];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"小区在售房源";
    return titleView;
}

- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 18, 34);
    }
    return CGSizeZero;
}

-(void)moreButtonClick {
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    if (SM.model.hasMore) {
        FHDetailNeighborhoodModel *detailModel = (FHDetailNeighborhoodModel*)self.detailViewController.viewModel.detailData;
        NSString *neighborhood_id = @"be_null";
        if (detailModel && detailModel.data.neighborhoodInfo.id.length > 0) {
            neighborhood_id = detailModel.data.neighborhoodInfo.id;
        }
        NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.detailViewController.viewModel.listLogPB;
        tracerDic[@"category_name"] = @"old_list";
        tracerDic[@"element_from"] = @"neighborhood_sale_house";
        tracerDic[@"enter_from"] = @"neighborhood_detail";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
        if (detailModel.data.neighborhoodInfo.name.length > 0) {
            userInfo[@"title"] = detailModel.data.neighborhoodInfo.name;
        } else {
            userInfo[@"title"] = @"小区房源";// 默认值
        }
        if (neighborhood_id.length > 0) {
            userInfo[@"neighborhood_id"] = neighborhood_id;
        }
        if (self.detailViewController.viewModel.houseId.length > 0) {
            userInfo[@"house_id"] = self.detailViewController.viewModel.houseId;
        }
        if (SM.model.searchId.length > 0) {
            userInfo[@"search_id"] = SM.model.searchId;
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
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    FHHouseSecondCardViewModel *cardViewModel = SM.items[index];
    if (![cardViewModel.model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        return;
    }
    FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)cardViewModel.model;
    NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
    tracerDic[@"rank"] = @(index);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = item.logPb;
    tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeSecondHandHouse];
    tracerDic[@"element_from"] = @"neighborhood_sale_house";
    tracerDic[@"enter_from"] = @"neighborhood_detail";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeSecondHandHouse)}];
    NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",item.hid];
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

// 不重复调用
- (void)collectionCellShow:(NSInteger )index {
    NSString *tempKey = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([self class]),(long)index];
    if(self.elementShowCaches[tempKey]){
        return;
    }
    self.elementShowCaches[tempKey] = @(YES);
    FHNeighborhoodDetailHouseSaleSM *SM = (FHNeighborhoodDetailHouseSaleSM *)self.sectionModel;
    FHHouseSecondCardViewModel *cardViewModel = SM.items[index];
    if (![cardViewModel.model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        return;
    }
    FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)cardViewModel.model;
    // house_show
    NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
    tracerDic[@"rank"] = @(index);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = item.logPb ? item.logPb : @"be_null";
    tracerDic[@"house_type"] = @"old";
    tracerDic[@"element_type"] = @"neighborhood_sale_house";
    tracerDic[@"search_id"] = item.searchId.length > 0 ? item.searchId : @"be_null";
    tracerDic[@"group_id"] = item.groupId.length > 0 ? item.groupId : (item.hid.length > 0 ? item.hid : @"be_null");
    tracerDic[@"impr_id"] = item.imprId.length > 0 ? item.imprId : @"be_null";
    [FHUserTracker writeEvent:@"house_show" params:tracerDic];
}

@end
