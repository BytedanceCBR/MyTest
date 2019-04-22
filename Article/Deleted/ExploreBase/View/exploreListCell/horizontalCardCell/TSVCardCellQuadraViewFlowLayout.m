//
//  TSVCardCellQuadraViewFlowLayout.m
//  Article
//
//  Created by dingjinlu on 2017/12/4.
//

#define kCellGap    1
#define kLeft       15

#import "TSVCardCellQuadraViewFlowLayout.h"

@interface TSVCardCellQuadraViewFlowLayout()
@property (nonatomic, strong) NSMutableArray *attributedsArray;
@end
@implementation TSVCardCellQuadraViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = kCellGap;
        self.minimumLineSpacing = kCellGap;
        self.headerReferenceSize = CGSizeMake(kLeft, 0);
        self.footerReferenceSize = CGSizeMake(kLeft, 0);
        self.collectionView.scrollEnabled = NO;

    }
    return self;
}
- (NSMutableArray *)attributedsArray
{
    if (!_attributedsArray) {
        _attributedsArray = [NSMutableArray arrayWithCapacity:4];
    }
    return _attributedsArray;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    [self.attributedsArray removeAllObjects];
    NSInteger count =[self.collectionView   numberOfItemsInSection:0];
    
    for (int i=0; i < count; i++) {
        NSIndexPath *  indexPath =[NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes * attrs=[self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attributedsArray addObject:attrs];
    }
}

- (CGSize)collectionViewContentSize
{
    CGFloat cellWidth = (self.collectionView.frame.size.width - kLeft * 2 - kCellGap)/2;
 
    CGFloat contentWidth = [self.attributedsArray count] *(cellWidth + kCellGap)*0.5+2*kLeft -kCellGap;
    return CGSizeMake(contentWidth, self.collectionView.bounds.size.height);
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.attributedsArray copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = (self.collectionView.frame.size.width - kLeft * 2 - kCellGap)/2;
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGFloat cellHeight = cellWidth;
    NSInteger i=indexPath.item;
    if (i == 0) {
        attributes.frame = CGRectMake(kLeft, 0, cellWidth, cellHeight);
    } else if (i == 1) {
        attributes.frame = CGRectMake(kLeft + cellWidth + kCellGap, 0, cellWidth, cellHeight);
    } else if (i == 2) {
        attributes.frame = CGRectMake(kLeft, cellHeight + kCellGap, cellWidth, cellHeight);
    } else if (i == 3) {
        attributes.frame = CGRectMake(kLeft + cellWidth + kCellGap, cellHeight + kCellGap, cellWidth, cellHeight);
    } else {
        UICollectionViewLayoutAttributes *lastAttrs = self.attributedsArray[i-4];
        CGRect frame  = lastAttrs.frame;
        frame.origin.x += 2 * cellWidth+ 2 * kCellGap;
        attributes.frame = frame;
    }
    
    return attributes;
}

@end
