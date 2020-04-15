//
//  FHCardSliderFlowLayout.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHCardSliderFlowLayout.h"
#import "FHCardSliderView.h"
#import "FHCardSliderCell.h"

static const float minScale = 0.68;
static const float minAlpha = 0.2;
static const float spacing = 14;
@interface FHCardSliderFlowLayout()
@property (nonatomic) CGSize topItemSize;
@property (nonatomic) NSInteger itemsCount;
@property (nonatomic) CGSize collectionBounds;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) CGSize collectionViewContentSize;
@property (nonatomic , assign) NSInteger actuallyVisibleItemsCount;

@property (nonatomic , assign) CGFloat contentOffsetXY;
@property (nonatomic , assign) CGFloat collectionBoundsWH;

@end

@implementation FHCardSliderFlowLayout
{
    BOOL didInitialSetup;
}
- (void)prepareLayout
{
    [super prepareLayout];
    
    FHCardSliderView *view = (FHCardSliderView *)self.collectionView.superview;
    
    self.actuallyVisibleItemsCount = MIN(view.dataSource.count, visibleItemsCount);
    
    if(self.actuallyVisibleItemsCount > 0){
        CGFloat width = (self.type == FHCardSliderViewTypeHorizontal)  ? (self.collectionBounds.width - (self.actuallyVisibleItemsCount - 1)*spacing) : self.collectionBounds.width;
        CGFloat height = (self.type == FHCardSliderViewTypeHorizontal)  ? self.collectionBounds.height : (self.collectionBounds.height - (self.actuallyVisibleItemsCount - 1)*spacing);
        self.topItemSize = CGSizeMake(width, height);
    }
    
    if (didInitialSetup) {
        return;
    }
    didInitialSetup = YES;
    
    //添加定时器
    if (view && view.isAuto) {
        [view addTimer];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:0];
    if (itemsCount <= 0) {
        return nil;
    }
    
    NSInteger minVisibleIndex = MAX(self.currentPage, 0);
    CGFloat contentOffset = self.contentOffsetXY;
    CGFloat collectionBounds = self.collectionBoundsWH;
    CGFloat offset = self.contentOffsetXY - (int)(contentOffset / collectionBounds) * collectionBounds;
    CGFloat offsetProgress = offset / self.collectionBoundsWH*1.0f;
    NSInteger maxVisibleIndex = MAX(MIN(itemsCount - 1, self.currentPage + visibleItemsCount), minVisibleIndex);
    
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    for (NSInteger i = minVisibleIndex; i<=maxVisibleIndex; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
         UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForIndexPath:indexPath currentPage:self.currentPage offset:offset offsetProgress:offsetProgress];
        [mArr addObject:attributes];
    }
    return mArr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForIndexPath:(NSIndexPath *)indexPath
                         currentPage:(NSInteger)currentPage
                              offset:(CGFloat)offset
                      offsetProgress:(CGFloat)offsetProgress
{
    UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:indexPath] copy];
    NSInteger visibleIndex = MAX(indexPath.item - currentPage + 1, 0);
    attributes.size = self.topItemSize;
    
    CGFloat topCardMidXY = 0;
    if(self.type == FHCardSliderViewTypeHorizontal){
        topCardMidXY = self.contentOffset.x + self.topItemSize.width / 2;
        attributes.center = CGPointMake(topCardMidXY + spacing * (visibleIndex - 1), self.collectionBounds.height/2);
    }else{
        topCardMidXY = self.contentOffset.y + self.topItemSize.height / 2;
        attributes.center = CGPointMake(self.collectionBounds.width/2, topCardMidXY + spacing * (visibleIndex - 1));
    }
   
    attributes.zIndex = 1000 - visibleIndex;
    CGFloat scale = [self parallaxProgressForVisibleIndex:visibleIndex offsetProgress:offsetProgress minScale:minScale];
    attributes.transform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat alpha = [self alphaProgressForVisibleIndex:visibleIndex offsetProgress:offsetProgress minAlpha:minAlpha];
    attributes.alpha = alpha;
//    FHCardSliderCell *cell = (FHCardSliderCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//    [cell refreshBgColor:scale];
    
    switch (visibleIndex) {
        case 1:
            if(self.type == FHCardSliderViewTypeHorizontal){
                if (self.contentOffsetXY >= 0) {
                    attributes.center = CGPointMake(attributes.center.x - offset, attributes.center.y);
                }else{
                    attributes.center = CGPointMake(attributes.center.x + attributes.size.width * (1 - scale)/2 - spacing * offsetProgress, attributes.center.y);
                }
            }else{
                if (self.contentOffsetXY >= 0) {
                    attributes.center = CGPointMake(attributes.center.x, attributes.center.y - offset);
                }else{
                    attributes.center = CGPointMake(attributes.center.x, attributes.center.y + attributes.size.height * (1 - scale)/2 - spacing * offsetProgress);
                }
            }
            break;
        case visibleItemsCount+1:
            if(self.type == FHCardSliderViewTypeHorizontal){
                attributes.center = CGPointMake(attributes.center.x + attributes.size.width * (1 - scale)/2 - spacing, attributes.center.y);
            }else{
                attributes.center = CGPointMake(attributes.center.x, attributes.center.y + attributes.size.height * (1 - scale)/2 - spacing);
            }
        break;
        default:
            if(self.type == FHCardSliderViewTypeHorizontal){
                attributes.center = CGPointMake(attributes.center.x + attributes.size.width * (1 - scale)/2 - spacing * offsetProgress, attributes.center.y);
            }else{
                attributes.center = CGPointMake(attributes.center.x, attributes.center.y + attributes.size.height * (1 - scale)/2 - spacing * offsetProgress);
            }
            break;
    }
    return attributes;
}

- (CGFloat)parallaxProgressForVisibleIndex:(NSInteger)visibleIndex
                         offsetProgress:(CGFloat)offsetProgress
                               minScale:(CGFloat)minScale
{
    CGFloat step = (1.0 - minScale) / (visibleItemsCount - 1)*1.0;
    return (1.0 - (visibleIndex - 1) * step + step * offsetProgress);
}

- (CGFloat)alphaProgressForVisibleIndex:(NSInteger)visibleIndex
                         offsetProgress:(CGFloat)offsetProgress
                               minAlpha:(CGFloat)minAlpha
{
    //只要一移动卡片，下方的卡片透明度立马变成1
    if(visibleIndex == 2 && offsetProgress > 0){
        return 1;
    }
    CGFloat step = (1.0 - minAlpha) / (visibleItemsCount - 1)*1.0;
//    NSLog(@"alpha_____%i___%f___%f",visibleIndex,(1.0 - (visibleIndex - 1) * step + step * offsetProgress),offsetProgress);
    return (1.0 - (visibleIndex - 1) * step + step * offsetProgress);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSInteger)itemsCount
{
    return [self.collectionView numberOfItemsInSection:0];
}

- (CGSize)collectionBounds
{
    return self.collectionView.bounds.size;
}

- (CGFloat)collectionBoundsWH
{
    if(self.type == FHCardSliderViewTypeHorizontal){
        return self.collectionView.bounds.size.width;
    }else{
        return self.collectionView.bounds.size.height;
    }
}

- (CGPoint)contentOffset
{
    return self.collectionView.contentOffset;
}

- (CGFloat)contentOffsetXY
{
    if(self.type == FHCardSliderViewTypeHorizontal){
        return self.collectionView.contentOffset.x;
    }else{
        return self.collectionView.contentOffset.y;
    }
}

- (NSInteger)currentPage
{
    if(self.type == FHCardSliderViewTypeHorizontal){
        return MAX(floor(self.contentOffset.x / self.collectionBounds.width), 0);
    }else{
        return MAX(floor(self.contentOffset.y / self.collectionBounds.height), 0);
    }
}

- (CGSize)collectionViewContentSize
{
    if(self.type == FHCardSliderViewTypeHorizontal){
        return CGSizeMake(self.collectionBounds.width * self.itemsCount, self.collectionBounds.height);
    }else{
        return CGSizeMake(self.collectionBounds.width, self.collectionBounds.height * self.itemsCount);
    }
}
@end