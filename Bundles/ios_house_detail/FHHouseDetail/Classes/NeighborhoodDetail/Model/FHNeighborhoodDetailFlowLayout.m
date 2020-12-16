//
//  FHNeighborhoodDetailFlowLayout.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import "FHNeighborhoodDetailFlowLayout.h"
#import "FHNeighborhoodDetailShadowView.h"
#import "FHNeighborhoodDetailSectionModel.h"
#import <objc/runtime.h>
@interface UICollectionViewLayoutAttributes (FHNeighborhoodDetail)

@property (nonatomic, assign) FHNeighborhoodDetailSectionType sectionType;

@end

@implementation UICollectionViewLayoutAttributes (FHNeighborhoodDetail)

- (void)setSectionType:(FHNeighborhoodDetailSectionType)sectionType {
    objc_setAssociatedObject(self, @selector(sectionType), @(sectionType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FHNeighborhoodDetailSectionType)sectionType {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    return value.unsignedIntegerValue;
}

@end

@implementation FHNeighborhoodDetailFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerClass:[FHNeighborhoodDetailShadowView class] forDecorationViewOfKind:NSStringFromClass([FHNeighborhoodDetailShadowView class])];
}

- (void)setSectionModels:(NSArray<FHNeighborhoodDetailSectionModel *> *)sectionModels {
    _sectionModels = sectionModels;
    self.hasShowFloorpanInfo = NO;
    for (FHNeighborhoodDetailSectionModel *model in sectionModels) {
        if (model.sectionType == FHNeighborhoodDetailSectionTypeFloorpan) {
            self.hasShowFloorpanInfo = YES;
            break;
        }
    }
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
        FHNeighborhoodDetailSectionType sectionType = model.sectionType;
        if (sectionType != FHNeighborhoodDetailSectionTypeHeader &&
            sectionType != FHNeighborhoodDetailSectionTypeOwnerSellHouse &&
            ![sections containsObject:@(sectionType)]) {
            [sections addObject:@(sectionType)];
            UICollectionViewLayoutAttributes *newAttrs = [self layoutAttributesForDecorationViewOfKind:NSStringFromClass([FHNeighborhoodDetailShadowView class]) atIndexPath:[NSIndexPath indexPathForItem:0 inSection:attribute.indexPath.section]];
            newAttrs.sectionType = sectionType;
            if (newAttrs && newAttrs.frame.size.height > 0) {
                [newArray addObject:newAttrs];
            }
        }
    }];
    
    //小区详情页 如果同时出现 FHNeighborhoodDetailSectionTypeFloorpan FHNeighborhoodDetailSectionTypeHouseSale
    //则需要合并2个decoration的attrs
    if (self.hasShowFloorpanInfo) {
        UICollectionViewLayoutAttributes *houseSaleAttributes = nil;
        for (UICollectionViewLayoutAttributes * attribute in newArray) {
            if (attribute.sectionType == FHNeighborhoodDetailSectionTypeHouseSale) {
                houseSaleAttributes = attribute;
            }
        }

        if (houseSaleAttributes) {
            UICollectionViewLayoutAttributes *newAttributes = houseSaleAttributes.copy;
            CGRect houseSaleFrame = houseSaleAttributes.frame;
            houseSaleFrame.origin.y -= 40;
            houseSaleFrame.size.height += 40;
            newAttributes.frame = houseSaleFrame;
            [newArray removeObject:houseSaleAttributes];
            [newArray addObject:newAttributes];
        }
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
