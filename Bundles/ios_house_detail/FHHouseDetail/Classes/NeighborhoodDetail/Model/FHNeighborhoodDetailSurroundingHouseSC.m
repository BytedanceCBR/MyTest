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
#import "FHNeighborhoodDetailRecommendCell.h"
#import "FHNeighborhoodDetailRelatedHouseMoreCell.h"

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
        FHNeighborhoodDetailRecommendCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRecommendCell class] withReuseIdentifier:NSStringFromClass([SM class]) forSectionController:self atIndex:index];
        [cell refreshWithData:SM.items[index] withLast:(index == SM.items.count - 1) ? YES : NO];
        return cell;
    } else {
        FHNeighborhoodDetailRelatedHouseMoreCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailRelatedHouseMoreCell class] forSectionController:self atIndex:index];
        [cell refreshWithTitle:SM.moreTitle];
        return cell;
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    
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
    FHNeighborhoodDetailSurroundingHouseSM *SM = (FHNeighborhoodDetailSurroundingHouseSM *)self.sectionModel;
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = [NSString stringWithFormat:@"周边房源(%@)", SM.total];//@"周边房源";
    titleView.arrowsImg.hidden = YES;
    titleView.userInteractionEnabled = NO;
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 18, 42);
    }
    return CGSizeZero;
}

@end
