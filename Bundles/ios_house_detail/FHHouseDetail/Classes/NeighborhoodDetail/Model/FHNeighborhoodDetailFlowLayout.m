//
//  FHNeighborhoodDetailFlowLayout.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import "FHNeighborhoodDetailFlowLayout.h"
#import "FHNeighborhoodDetailShadowView.h"
#import "FHNeighborhoodDetailSectionModel.h"

@implementation FHNeighborhoodDetailFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerClass:[FHNeighborhoodDetailShadowView class] forDecorationViewOfKind:NSStringFromClass([FHNeighborhoodDetailShadowView class])];
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
            frame.origin.x = 9;
            frame.size.width = CGRectGetWidth(self.collectionView.bounds) - 9 * 2;
            attribute.frame = frame;
        }

        FHNeighborhoodDetailSectionModel *model = self.sectionModels[attribute.indexPath.section];

        if (model.sectionType != FHNeighborhoodDetailSectionTypeHeader &&
            model.sectionType != FHNeighborhoodDetailSectionTypeOwnerSellHouse &&
            ![sections containsObject:@(model.sectionType)]) {
            [sections addObject:@(model.sectionType)];
            UICollectionViewLayoutAttributes *newAttrs = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([FHNeighborhoodDetailShadowView class]) atIndexPath:[NSIndexPath indexPathForItem:0 inSection:attribute.indexPath.section]];
            if (newAttrs && newAttrs.frame.size.height > 0) {
                [newArray addObject:newAttrs];
            }
        }
    }];
    
    //小区详情页 如果同时出现 FHNeighborhoodDetailSectionTypeFloorpan FHNeighborhoodDetailSectionTypeHouseSale
    //则需要合并2个decoration的attrs
    if ([sections containsObject:@(FHNeighborhoodDetailSectionTypeFloorpan)] && [sections containsObject:@(FHNeighborhoodDetailSectionTypeHouseSale)]) {
        
    }

    return newArray;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    CGRect frame = attribute.frame;
    frame.origin.x = 9;
    frame.size.width = CGRectGetWidth(self.collectionView.bounds) - 9 * 2;
    attribute.frame = frame;
    return attribute;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:NSStringFromClass([FHNeighborhoodDetailShadowView class])]) {
        UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
        UICollectionViewLayoutAttributes *newDecorationAttributes = [decorationAttributes copy];

        NSIndexPath *indexPathFirst = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:indexPath.section] - 1 inSection:indexPath.section];

        UICollectionViewLayoutAttributes *attrsFirst = [self layoutAttributesForItemAtIndexPath:indexPathFirst];
        UICollectionViewLayoutAttributes *attrsLast = [self layoutAttributesForItemAtIndexPath:indexPathLast];
        newDecorationAttributes.frame = CGRectMake(9, attrsFirst.frame.origin.y, self.collectionView.frame.size.width - 9 * 2, attrsLast.frame.origin.y+attrsLast.frame.size.height-attrsFirst.frame.origin.y);
        UICollectionViewLayoutAttributes *sectionAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (sectionAttrs && sectionAttrs.frame.size.height > 0) {
            CGRect frame = newDecorationAttributes.frame;
            frame.origin.x = 9;
            frame.origin.y = sectionAttrs.frame.origin.y;
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
