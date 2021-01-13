//
//  FHNewHouseDetailFlowLayout.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailFlowLayout.h"
#import "FHNeighborhoodDetailShadowView.h"
#import "FHNewHouseDetailSectionModel.h"
#import "FHNewHouseDetailSectionController.h"

@implementation FHNewHouseDetailFlowLayout

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
//            NSLog(@"layoutAttributesForElementsInRect attribute.indexPath %@",attribute.indexPath);
            CGRect frame = attribute.frame;
            frame.origin.x = FHNewHouseDetailSectionLeftMargin;
            frame.size.width = CGRectGetWidth(self.collectionView.bounds) - FHNewHouseDetailSectionLeftMargin * 2;
            attribute.frame = frame;
        }

        FHNewHouseDetailSectionModel *model = self.sectionModels[attribute.indexPath.section];

        if (model.sectionType != FHNewHouseDetailSectionTypeHeader && model.sectionType != FHNewHouseDetailSectionTypeDisclaimer && ![sections containsObject:@(attribute.indexPath.section)]) {
            [sections addObject:@(attribute.indexPath.section)];
            UICollectionViewLayoutAttributes *newAttrs = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([FHNeighborhoodDetailShadowView class]) atIndexPath:[NSIndexPath indexPathForItem:0 inSection:attribute.indexPath.section]];
            if (newAttrs && newAttrs.frame.size.height > 0) {
                [newArray addObject:newAttrs];
            }
        }
    }];

    return newArray;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    CGRect frame = attribute.frame;
    frame.origin.x = FHNewHouseDetailSectionLeftMargin;
    frame.size.width = CGRectGetWidth(self.collectionView.bounds) - FHNewHouseDetailSectionLeftMargin * 2;
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
        newDecorationAttributes.frame = CGRectMake(FHNewHouseDetailSectionLeftMargin, attrsFirst.frame.origin.y, self.collectionView.frame.size.width - FHNewHouseDetailSectionLeftMargin * 2, attrsLast.frame.origin.y+attrsLast.frame.size.height-attrsFirst.frame.origin.y);
        UICollectionViewLayoutAttributes *sectionAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (sectionAttrs && sectionAttrs.frame.size.height > 0) {
            CGRect frame = newDecorationAttributes.frame;
            frame.origin.x = FHNewHouseDetailSectionLeftMargin;
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
