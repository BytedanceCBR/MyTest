//
//  FHUGCShortVideoFlowLayout.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHUGCShortVideoFlowLayout.h"
#import "FHUGCShortVideoCell.h"

@interface FHUGCShortVideoFlowLayout ()

//存放所有cell的布局属性
@property (nonatomic, strong) NSMutableArray *attrsArray;
//内容的高度
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGSize smallItemSize;

@end

@implementation FHUGCShortVideoFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _attrsArray = [NSMutableArray array];
        _smallItemSize = CGSizeZero;
    }
    return self;
}

//方法是返回UICollectionView的可滚动范围
- (CGSize)collectionViewContentSize {
    return CGSizeMake(0, self.contentHeight + self.sectionInset.bottom);
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
//        if(i < self.dataList.count){
//            FHFeedContentRawDataHotCellListModel *model = self.dataList[i];
//            model.itemSize = attrs.bounds.size;
//        }
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
    NSInteger eachRowItemCount = 2;
    //在第几行
    NSInteger destColumn = indexPath.row / eachRowItemCount;
    //在第几列
    NSInteger destRow = indexPath.row % eachRowItemCount;
    
    x = self.sectionInset.left + destRow * (w + self.minimumInteritemSpacing);
    y = self.sectionInset.top + destColumn * (h + self.minimumLineSpacing);
    
    attrs.frame = CGRectMake(x, y, w, h);
    
    CGFloat columnHeight = CGRectGetMaxY(attrs.frame);
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    
    return attrs;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath itemCount:(NSInteger)itemCount {
    return self.smallItemSize;
}

- (CGSize)smallItemSize {
    if(_smallItemSize.width == 0 && _smallItemSize.height == 0){
        CGFloat width = ceil(([UIScreen mainScreen].bounds.size.width - self.sectionInset.left - self.sectionInset.right - self.minimumInteritemSpacing)/2);
        CGFloat height = ceil(270.0f/168 * width);
        _smallItemSize = CGSizeMake(width, height);
    }
    
    return _smallItemSize;
}

@end
