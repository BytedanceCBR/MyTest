//
//  FHMessageCellTagsViewLayout.m
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import "FHMessageCellTagsViewLayout.h"

@implementation FHMessageCellTagsViewLayout
- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *ret = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in ret) {
        // 超出CollectionView边界的Cell不展示
        attributes.hidden = ((attributes.frame.origin.x + attributes.frame.size.width) > self.collectionView.bounds.size.width);
    }
    return ret;
}
@end
