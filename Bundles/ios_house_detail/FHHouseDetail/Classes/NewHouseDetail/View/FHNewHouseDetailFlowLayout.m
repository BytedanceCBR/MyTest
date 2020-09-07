//
//  FHNewHouseDetailFlowLayout.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailFlowLayout.h"
#import "FHBuildingDetailShadowView.h"

@implementation FHNewHouseDetailFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerClass:[FHBuildingDetailShadowView class] forDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class])];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:NSStringFromClass([FHBuildingDetailShadowView class])] && [self.collectionView numberOfSections] - 1 == indexPath.section) {
        UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
        UICollectionViewLayoutAttributes *newDecorationAttributes = [decorationAttributes copy];
        
        NSIndexPath *indexPathFirst = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:indexPath.section] inSection:indexPath.section];
        
        UICollectionViewLayoutAttributes *attrsFirst = [self layoutAttributesForItemAtIndexPath:indexPathFirst];
        UICollectionViewLayoutAttributes *attrsLast = [self layoutAttributesForItemAtIndexPath:indexPathLast];
        newDecorationAttributes.frame = CGRectMake(attrsFirst.frame.origin.x - 15, attrsFirst.frame.origin.y - 20, self.collectionView.frame.size.width, attrsLast.frame.origin.y-attrsFirst.frame.origin.y + 40);
        // 想要作为背景图像，就一定要将其 zIndex 设置为 -1
        newDecorationAttributes.zIndex = -1;
        return newDecorationAttributes;
    }
    return nil;
    
}
@end
