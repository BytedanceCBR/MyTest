//
//  TTLeftCollectionViewFlowLayout.m
//  Article
//
//  Created by fengyadong on 16/5/25.
//
//

#import "TTLeftCollectionViewFlowLayout.h"

@interface TTLeftCollectionViewFlowLayout ()
@property (nonatomic) NSMutableDictionary *attrCache;
@end

@implementation TTLeftCollectionViewFlowLayout

- (void)prepareLayout {
    self.attrCache = [NSMutableDictionary dictionary];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *updatedAttributes = [NSMutableArray new];
    
    NSInteger sections = [self.collectionView numberOfSections];
    NSInteger s = 0;
    while (s < sections) {
        NSInteger rows = [self.collectionView numberOfItemsInSection:s];
        NSInteger r = 0;
        while (r < rows) {
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:r
                                                                                                                  inSection:s]];
            if (CGRectIntersectsRect(attrs.frame, rect)) {
                [updatedAttributes addObject:attrs];
            }
            r++;
        }
        s++;
    }
    
    return updatedAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.attrCache[indexPath]) {
        return self.attrCache[indexPath];
    }
    
    UICollectionViewLayoutAttributes * currentLayoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes * previousLayoutAttributes = nil;
    if (indexPath.row > 0) {
        previousLayoutAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
    }
    
    CGFloat maximumInteritemSpacing = self.minimumInteritemSpacing;
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        maximumInteritemSpacing = [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:indexPath.section];
    }
    
    CGFloat previousOriginX = CGRectGetMaxX(previousLayoutAttributes.frame);
    
    UIEdgeInsets sectionInset = self.sectionInset;
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
        sectionInset = [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
    }
    
    if (previousOriginX + maximumInteritemSpacing + currentLayoutAttributes.frame.size.width + sectionInset.right <= self.collectionViewContentSize.width && previousLayoutAttributes) {
        CGRect frame = currentLayoutAttributes.frame;
        frame.origin.x = previousOriginX + maximumInteritemSpacing;
        currentLayoutAttributes.frame = frame;
    }else {
        CGRect frame = currentLayoutAttributes.frame;
        frame.origin.x = sectionInset.left;
        currentLayoutAttributes.frame = frame;
    }
    self.attrCache[indexPath] = currentLayoutAttributes;
    return currentLayoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
