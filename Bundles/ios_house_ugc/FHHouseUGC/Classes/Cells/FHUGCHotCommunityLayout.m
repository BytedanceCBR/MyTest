//
//  FHUGCHotCommunityLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/8.
//

#import "FHUGCHotCommunityLayout.h"

@interface FHUGCHotCommunityLayout ()

//存放所有cell的布局属性
@property (nonatomic, strong) NSMutableArray *attrsArray;
//内容的高度
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGSize firstItemSize;
@property (nonatomic, assign) CGSize smallItemSize;

@end

@implementation FHUGCHotCommunityLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _attrsArray = [NSMutableArray array];
        _firstItemSize = CGSizeMake(100, 188);
        _smallItemSize = CGSizeMake(90, 90);
    }
    return self;
}

//方法是返回UICollectionView的可滚动范围
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.contentHeight + self.sectionInset.right, 0);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    if(itemCount <= 0){
        return;
    }
    
    [self.attrsArray removeAllObjects];
    self.contentHeight = 0;
    
    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

//方法返回indexPath位置的UICollectionViewLayoutAttributes
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:indexPath.section];
    CGSize itemSize = [self sizeForItemAtIndexPath:indexPath itemCount:itemCount];
    CGFloat w = itemSize.width;
    CGFloat h = itemSize.height;
    CGFloat x = 0;
    CGFloat y = 0;
    NSInteger eachRowItemCount = 0;
    //在第几行
    NSInteger destColumn = 0;
    //在第几列
    NSInteger destRow = 0;
    //最后一个item的row，偶数时候用
    NSInteger lastOneDestRow = 0;
    
    if([self isFirstItemLarge]){
        if(itemCount % 2 == 0){
            //偶数个
            eachRowItemCount = (itemCount - 2) / 2;
            if(eachRowItemCount > 0){
                destColumn = (indexPath.row - 1) / eachRowItemCount;
                destRow = (indexPath.row - 1) % eachRowItemCount + 1;
                lastOneDestRow = (indexPath.row - 2) % eachRowItemCount + 1;
            }
        }else{
            //奇数个
            eachRowItemCount = (itemCount - 1) / 2;
            if(eachRowItemCount > 0){
                destColumn = (indexPath.row - 1) / eachRowItemCount;
                destRow = (indexPath.row - 1) % eachRowItemCount + 1;
            }
        }
        
        if(indexPath.row == 0){
            x = self.sectionInset.left;
            y = self.sectionInset.top;
        }else if((indexPath.row == itemCount - 1) && itemCount % 2 == 0){
            x = self.sectionInset.left + lastOneDestRow  * (w + self.minimumLineSpacing) + self.firstItemSize.width + self.minimumLineSpacing;
            y = self.sectionInset.top;
        }else{
            x = self.sectionInset.left + (destRow - 1) * (w + self.minimumLineSpacing) + self.firstItemSize.width + self.minimumLineSpacing;
            y = self.sectionInset.top + destColumn * (h + self.minimumLineSpacing);
        }
    }else{
        if(itemCount % 2 == 0){
            //偶数个
            eachRowItemCount = itemCount / 2;
            if(eachRowItemCount > 0){
                destColumn = indexPath.row / eachRowItemCount;
                destRow = indexPath.row % eachRowItemCount;
            }
        }else{
            //奇数个
            eachRowItemCount = (itemCount - 1) / 2;
            if(eachRowItemCount > 0){
                destColumn = indexPath.row / eachRowItemCount;
                destRow = indexPath.row % eachRowItemCount;
                lastOneDestRow = (indexPath.row - 1) % eachRowItemCount;
            }
        }
        
        if(indexPath.row == 0){
            x = self.sectionInset.left;
            y = self.sectionInset.top;
        }else if((indexPath.row == itemCount - 1) && itemCount % 2 != 0){
            x = self.sectionInset.left + (lastOneDestRow + 1)  * (w + self.minimumLineSpacing);
            y = self.sectionInset.top;
        }else{
            x = self.sectionInset.left + destRow * (w + self.minimumLineSpacing);
            y = self.sectionInset.top + destColumn * (h + self.minimumLineSpacing);
        }
    }
    
    attrs.frame = CGRectMake(x, y, w, h);
    
    CGFloat columnHeight = CGRectGetMaxX(attrs.frame);
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    
    return attrs;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath itemCount:(NSInteger)itemCount {
    if(indexPath.row == 0 && [self isFirstItemLarge]){
        return self.firstItemSize;
    }
//    else if((indexPath.row == itemCount - 1) && itemCount % 2 == 0){
//        return CGSizeMake(90, 180);
//    }
    else{
        return self.smallItemSize;
    }
}

- (BOOL)isFirstItemLarge {
    return NO;
}

@end
