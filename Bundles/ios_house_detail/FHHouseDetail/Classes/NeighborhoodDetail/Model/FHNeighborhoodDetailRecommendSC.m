//
//  FHNeighborhoodDetailRecommendSC.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendSC.h"
#import "FHNeighborhoodDetailRecommendSM.h"
#import "FHNeighborhoodDetailRecommendCell.h"
#import "FHNeighborhoodDetailRecommendTitleView.h"
#import "FHHouseSecondCardViewModel.h"

@interface FHNeighborhoodDetailRecommendSC()<IGListSupplementaryViewSource, IGListDisplayDelegate>

@end

@implementation FHNeighborhoodDetailRecommendSC

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
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    return SM.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 18;
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        return [FHNeighborhoodDetailRecommendCell cellSizeWithData:SM.items[index] width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    FHNeighborhoodDetailRecommendCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRecommendCell class] withReuseIdentifier:NSStringFromClass([SM.recommendCellModel class]) forSectionController:self atIndex:index];
    if (index >= 0 && index < SM.items.count) {
        [cell refreshWithData:SM.items[index] withLast:(index == SM.items.count - 1) ? YES : NO];
        [cell refreshIndexCorner:NO andLast:(index == SM.items.count - 1) ? YES : NO];
    }
    return cell;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        FHHouseSecondCardViewModel *item = SM.items[index];
        if ([item.model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
            FHSearchHouseDataItemsModel *model = (FHSearchHouseDataItemsModel *)item.model;
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
            traceParam[@"log_pb"] = [model logPb] ? : UT_BE_NULL;;
            traceParam[@"element_from"] = @"search_related";
            traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"] ? : UT_BE_NULL;
            traceParam[@"origin_search_id"] = model.searchId ? : UT_BE_NULL;
            traceParam[@"search_id"] = model.searchId ? : UT_BE_NULL;
            traceParam[@"rank"] = @(index);
            traceParam[@"enter_from"] = @"neighborhood_detail";
            NSMutableDictionary *dict = @{@"house_type":@(2),
                                  @"tracer": traceParam
                                  }.mutableCopy;
            
            if (model.hid) {
                NSURL *jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@", model.hid]];
                TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
                [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
            }
        }
    }
}

- (void)addHouseShowByIndex:(NSInteger)index dataItem:(FHHouseSecondCardViewModel *)item {
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
    traceParam[@"element_type"] = @"search_related";
    traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"] ? : UT_BE_NULL;
    traceParam[@"page_type"] = @"neighborhood_detail";
    //traceParam[@"house_type"] = @"old";
    traceParam[@"search_id"] = model.searchId ? : UT_BE_NULL;
    traceParam[@"group_id"] = model.groupId ? : UT_BE_NULL;
    traceParam[@"rank"] = @(index);
    traceParam[@"impr_id"] = model.imprId ? : UT_BE_NULL;
    traceParam[@"enter_from"] = self.detailTracerDict[@"enter_from"];
    [FHUserTracker writeEvent:@"house_show" params:traceParam];
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
    FHNeighborhoodDetailRecommendSM *SM = (FHNeighborhoodDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < SM.items.count) {
        [self addHouseShowByIndex:index dataItem:SM.items[index]];
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
    titleView.titleLabel.font = [UIFont themeFontSemibold:16];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"猜你喜欢";
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
