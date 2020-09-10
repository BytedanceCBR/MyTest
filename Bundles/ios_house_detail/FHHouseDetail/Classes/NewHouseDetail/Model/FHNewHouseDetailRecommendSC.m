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
#import "FHNewHouseDetailViewController.h"

@interface FHNewHouseDetailRecommendSC()<IGListSupplementaryViewSource, IGListDisplayDelegate>

@end

@implementation FHNewHouseDetailRecommendSC

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
    FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 30;
    FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < model.items.count) {
        return [FHNewHouseDetailRelatedCollectionCell cellSizeWithData:model.items[index] width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
       FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    FHNewHouseDetailRelatedCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRelatedCollectionCell class] withReuseIdentifier:NSStringFromClass([model.relatedCellModel class]) forSectionController:self atIndex:index];
    if (index >= 0 && index < model.items.count) {
        [cell refreshWithData:model.items[index]];
    }
    return cell;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < model.items.count) {
        [self cellDidSelected:model.items[index] index:index];
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
    FHNewHouseDetailRecommendSM *model = (FHNewHouseDetailRecommendSM *)self.sectionModel;
    if (index >= 0 && index < model.items.count) {
        [self addHouseShowByIndex:index dataItem:model.items[index]];
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

- (void)cellDidSelected:(FHHouseListBaseItemModel *)dataItem index:(NSInteger)index {
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    tracerDic[@"rank"] = @(index);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
    FHNewHouseDetailViewController *vc = self.detailViewController;
    tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:vc.viewModel.houseType];
    tracerDic[@"element_from"] = @"search_related";
    tracerDic[@"enter_from"] = @"new_detail";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNewHouse)}];
    NSString * urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",dataItem.houseid];
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)addHouseShowByIndex:(NSInteger)index dataItem:(FHHouseListBaseItemModel *) dataItem {
    NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), index];
    if ([self.elementShowCaches valueForKey:tempKey]) {
        return;
    }
    [self.elementShowCaches setValue:@(YES) forKey:tempKey];
    // house_show
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    tracerDic[@"rank"] = @(index);
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
    FHNewHouseDetailViewController *vc = self.detailViewController;
    tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:vc.viewModel.houseType];
    tracerDic[@"element_type"] = @"search_related";
    tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
    tracerDic[@"group_id"] = dataItem.houseid ? : @"be_null";
    tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
    [tracerDic removeObjectsForKeys:@[@"element_from"]];
    [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    
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
