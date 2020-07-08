//
//  FHBuildingDetailCollectionViewFlowLayout.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/3.
//

#import "FHBuildingDetailCollectionViewFlowLayout.h"
#import "FHBuildingDetailShadowView.h"
#import "FHBuildingDetailModel.h"

@implementation FHBuildingDetailCollectionViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerClass:[FHBuildingDetailShadowView class] forDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class])];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newArray = array.mutableCopy;
    // 设置 Item 和 SupplementaryView
      
    // 设置 DecorationView
    if (self.model && self.model.relatedFloorplanList.list.count) {
        UICollectionViewLayoutAttributes *newAttrs = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([FHBuildingDetailShadowView class]) atIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.collectionView.numberOfSections - 1]];
        [newArray addObject:newAttrs];
    }
    
    return newArray;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
//
//    if ([elementKind isEqualToString:NSStringFromClass([FHBuildingDetailShadowView class])] && [self.collectionView numberOfSections] - 1 == indexPath.section) {
//        DecorationLayoutAttributes * attributes = [DecorationLayoutAttributes layoutAttributesForDecorationViewOfKind: FDRFrontDecorationReusableView withIndexPath: indexPath];
//        // 通过属性，外部设置装饰视图的实际图片 ( 后有介绍 )
//        attributes.imgUrlStr = self.imgUrlString;
//       // 这里，装饰视图的位置是固定的
//        CGFloat heightOffset = 16;
//        attributes.frame = CGRectMake(0, KScreenWidth * 0.5 - heightOffset, KScreenWidth, 102 + heightOffset);
//        attributes.zIndex -= 1;
//        return attributes;
//    }
//    return nil;
//}

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
