//
//  FHNeighborhoodDetailFlowLayout.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import "FHNeighborhoodDetailFlowLayout.h"
#import "FHBuildingDetailShadowView.h"
#import "FHNeighborhoodDetailSectionModel.h"

@implementation FHNeighborhoodDetailFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerClass:[FHBuildingDetailShadowView class] forDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class])];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newArray = array.mutableCopy;
    // 设置 Item 和 SupplementaryView

    // 设置 DecorationView
    __block NSMutableArray *sections = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * attribute, NSUInteger idx, BOOL * _Nonnull stop) {
        if (attribute.indexPath.section == 0) {
            attribute.zIndex = -2;
        }
        
        if (attribute.representedElementCategory == UICollectionElementCategorySupplementaryView) {
            CGRect frame = attribute.frame;
            frame.origin.x = 15;
            frame.size.width = CGRectGetWidth(self.collectionView.bounds) - 15 * 2;
            attribute.frame = frame;
        }

        FHNeighborhoodDetailSectionModel *model = self.sectionModels[attribute.indexPath.section];

        if (model.sectionType != FHNeighborhoodDetailSectionTypeHeader && ![sections containsObject:@(attribute.indexPath.section)]) {
            [sections addObject:@(attribute.indexPath.section)];
            UICollectionViewLayoutAttributes *newAttrs = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class]) atIndexPath:[NSIndexPath indexPathForItem:0 inSection:attribute.indexPath.section]];
            if (newAttrs && newAttrs.frame.size.height > 0) {
                [newArray addObject:newAttrs];
            }
        }
    }];

    return newArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:NSStringFromClass([FHBuildingDetailShadowView class])]) {
        UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
        UICollectionViewLayoutAttributes *newDecorationAttributes = [decorationAttributes copy];

        NSIndexPath *indexPathFirst = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:indexPath.section] - 1 inSection:indexPath.section];

        UICollectionViewLayoutAttributes *attrsFirst = [self layoutAttributesForItemAtIndexPath:indexPathFirst];
        UICollectionViewLayoutAttributes *attrsLast = [self layoutAttributesForItemAtIndexPath:indexPathLast];
        newDecorationAttributes.frame = CGRectMake(attrsFirst.frame.origin.x - 15, attrsFirst.frame.origin.y - 20, self.collectionView.frame.size.width, attrsLast.frame.origin.y+attrsLast.frame.size.height-attrsFirst.frame.origin.y + 40);
        UICollectionViewLayoutAttributes *sectionAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (sectionAttrs && sectionAttrs.frame.size.height > 0) {
            CGRect frame = newDecorationAttributes.frame;
            frame.origin.y = sectionAttrs.frame.origin.y - 20;
            frame.size.height += sectionAttrs.frame.size.height;
            newDecorationAttributes.frame = frame;
        }
        // 想要作为背景图像，就一定要将其 zIndex 设置为 -1
        newDecorationAttributes.zIndex = -1;
        return newDecorationAttributes;
    }
    return nil;
}


@end
