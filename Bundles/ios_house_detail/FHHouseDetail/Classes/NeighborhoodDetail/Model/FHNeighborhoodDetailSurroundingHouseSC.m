//
//  FHNeighborhoodDetailSurroundingHouseSC.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/12/10.
//

#import "FHNeighborhoodDetailSurroundingHouseSC.h"
#import "FHNeighborhoodDetailRecommendTitleView.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHNeighborhoodDetailSurroundingHouseSM.h"
#import "FHNeighborhoodDetailSurroundingHouseCell.h"
#import "FHNeighborhoodDetailRelatedHouseMoreCell.h"
#import "FHNeighborhoodDetailViewController.h"

@interface FHNeighborhoodDetailSurroundingHouseSC()<IGListSupplementaryViewSource, IGListDisplayDelegate>

@end

@implementation FHNeighborhoodDetailSurroundingHouseSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
    }
    return self;
}

- (NSInteger)numberOfItems {
    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    if ([SM.total integerValue] <= 5) {
        return SM.items.count;
    }
    return SM.items.count + 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 18;
    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        return [FHNeighborhoodDetailRecommendCell cellSizeWithData:SM.items[index] width:width];
    } else if (index == SM.items.count) {
        return CGSizeMake(width, 56);
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        FHNeighborhoodDetailSurroundingHouseCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSurroundingHouseCell class] withReuseIdentifier:NSStringFromClass([SM class]) forSectionController:self atIndex:index];
        [cell refreshWithData:SM.items[index] withLast:(index == SM.items.count - 1) ? YES : NO];
        return cell;
    } else {
        FHNeighborhoodDetailRelatedHouseMoreCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRelatedHouseMoreCell class] forSectionController:self atIndex:index];
        [cell refreshWithTitle:SM.moreTitle];
        return cell;
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        FHHouseSecondCardViewModel *item = SM.items[index];
        if ([item.model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
            FHSearchHouseDataItemsModel *model = (FHSearchHouseDataItemsModel *)item.model;
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
            traceParam[@"log_pb"] = [model logPb] ? : UT_BE_NULL;;
            traceParam[@"element_from"] = @"related";
            traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"] ? : UT_BE_NULL;
            traceParam[@"origin_search_id"] = model.searchId ? : UT_BE_NULL;
            traceParam[@"search_id"] = model.searchId ? : UT_BE_NULL;
            traceParam[@"rank"] = @(index);
            traceParam[@"enter_from"] = @"neighborhood_detail";
            NSMutableDictionary *dict = @{
                                  @"tracer": traceParam
                                  }.mutableCopy;
            
            if (model.hid) {
                NSURL *jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@", model.hid]];
                TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
                [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
            }
        }
    } else if (index == SM.items.count) {
        FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
        if (SM.model.hasMore) {
            
            FHDetailNeighborhoodModel *detailModel = (FHDetailNeighborhoodModel*)self.detailViewController.viewModel.detailData;
            NSString *neighborhood_id = @"be_null";
            if (detailModel && detailModel.data.neighborhoodInfo.id.length > 0) {
                neighborhood_id = detailModel.data.neighborhoodInfo.id;
            }
            NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
            tracerDic[UT_ENTER_TYPE] = @"click";
            tracerDic[UT_LOG_PB] = self.detailViewController.viewModel.listLogPB;
            tracerDic[UT_CATEGORY_NAME] = @"old_list";
            tracerDic[@"element_from"] = @"related";
            tracerDic[@"enter_from"] = @"neighborhood_detail";
            [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            userInfo[@"tracer"] = tracerDic;
            userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
            userInfo[@"title"] = @"周边房源";// 默认值
//            if (detailModel.data.neighborhoodInfo.name.length > 0) {
//                userInfo[@"title"] = detailModel.data.neighborhoodInfo.name;
//            }
            if (neighborhood_id.length > 0) {
                userInfo[@"neighborhood_id"] = neighborhood_id;
            }
            if (self.detailViewController.viewModel.houseId.length > 0) {
                userInfo[@"house_id"] = self.detailViewController.viewModel.houseId;
            }
            if (SM.model.searchId.length > 0) {
                userInfo[@"search_id"] = SM.model.searchId;
            }
            userInfo[@"list_vc_type"] = @(2);
            
            TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
            NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://house_list_in_neighborhood"];
            if (urlStr.length > 0) {
                NSURL *url = [NSURL URLWithString:urlStr];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInf];
            }
        }
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
    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        FHHouseSecondCardViewModel *item = SM.items[index];
        if (![item.model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
            return;
        }
        FHSearchHouseDataItemsModel *model = (FHSearchHouseDataItemsModel *)item.model;
        NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), index];
        if ([self.elementShowCaches valueForKey:tempKey]) {
            return;
        }
        [self.elementShowCaches setValue:@(YES) forKey:tempKey];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        traceParam[@"log_pb"] = [model logPb] ? : UT_BE_NULL;;
        traceParam[@"element_type"] = @"related";
        traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"] ? : UT_BE_NULL;
        traceParam[@"page_type"] = @"neighborhood_detail";
        traceParam[@"house_type"] = @"old";
        traceParam[@"search_id"] = model.searchId ? : UT_BE_NULL;
        traceParam[@"group_id"] = model.groupId ? : UT_BE_NULL;
        traceParam[@"rank"] = @(index);
        traceParam[@"impr_id"] = model.imprId ? : UT_BE_NULL;
        traceParam[@"enter_from"] = self.detailTracerDict[@"enter_from"];
        [FHUserTracker writeEvent:@"house_show" params:traceParam];
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

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendTitleView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHNeighborhoodDetailRecommendTitleView class] atIndex:index];
//    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    titleView.titleLabel.font = [UIFont themeFontMedium:16];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"周边房源";
//    titleView.titleLabel.text = [NSString stringWithFormat:@"周边房源(%@)", SM.total];//@"周边房源";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 18, 34);
    }
    return CGSizeZero;
}

@end