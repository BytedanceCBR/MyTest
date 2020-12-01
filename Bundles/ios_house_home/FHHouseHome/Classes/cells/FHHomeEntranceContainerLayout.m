//
//  FHHomeEntranceContainerLayout.m
//  FHHouseHome
//
//  Created by CYY RICH on 2020/12/1.
//

#import "FHHomeEntranceContainerLayout.h"
#import "FHCommonDefines.h"

@implementation FHHomeEntranceContainerLayout

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.itemSize = CGSizeMake((SCREEN_WIDTH - 30)/5, (SCREEN_WIDTH - 30)/5);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
//    [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
    //滚动结束后的布局属性
    NSArray<UICollectionViewLayoutAttributes *> *array = [super layoutAttributesForElementsInRect:CGRectMake(proposedContentOffset.x, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    
//    CGFloat offset = proposedContentOffset.x;
    CGFloat padding = SCREEN_WIDTH - 15;
    CGFloat minDetla = CGFLOAT_MAX;
    if (array.lastObject.center.x < padding) {
        minDetla = (SCREEN_WIDTH - 30)/5 - array.lastObject.center.x - padding;
    } else if (array.lastObject.center.x > padding) {
        minDetla = array.lastObject.center.x - padding;
    }
    
    proposedContentOffset.x += minDetla;
    return proposedContentOffset;
}

@end
