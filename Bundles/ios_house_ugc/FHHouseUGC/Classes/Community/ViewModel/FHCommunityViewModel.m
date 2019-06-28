//
//  FHCommunityViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHCommunityViewModel.h"
#import "FHCommunityViewController.h"
#import "FHCommunityCollectionCell.h"
#import "FHHouseUGCHeader.h"

#define kCellId @"cellId"
#define maxCellCount 3

@interface FHCommunityViewModel ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , weak) FHCommunityViewController *viewController;
@property(nonatomic , strong) NSMutableArray *cellArray;
@property(nonatomic , strong) NSArray *dataArray;
@property(nonatomic , assign) NSInteger currentTabIndex;
@property(nonatomic , assign) BOOL isFirstLoad;

@property(nonatomic , assign) CGPoint beginOffSet;
@property(nonatomic , assign) CGFloat oldX;

@end

@implementation FHCommunityViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.currentTabIndex = 1;
        self.isFirstLoad = YES;
        
        self.collectionView = collectionView;
        collectionView.delegate = self;
        collectionView.dataSource = self;

        self.viewController = (FHCommunityViewController *)viewController;
        
        [self initDataArray];
        //临时版本使用，UGC上线后去掉
        [self initForTempVersion];
    }
    return self;
}

- (void)initForTempVersion {
    self.currentTabIndex = 0;
    self.dataArray = @[
                       @(FHCommunityCollectionCellTypeDiscovery)
                       ];
    [self.viewController hideSegmentControl];
}

- (void)initDataArray {
    self.cellArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < maxCellCount; i++) {
        [self.cellArray addObject:[NSNull null]];
    }
    
    self.dataArray = @[
                       @(FHCommunityCollectionCellTypeMyJoin),
                       @(FHCommunityCollectionCellTypeNearby),
                       @(FHCommunityCollectionCellTypeDiscovery)
                       ];
}

- (void)selectCurrentTabIndex {
    self.viewController.segmentControl.selectedSegmentIndex = self.currentTabIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentTabIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

//顶部tabView点击事件
- (void)segmentViewIndexChanged:(NSInteger)index {
    self.currentTabIndex = index;
    
    [self initCell];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (void)initCell {
    if([self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityCollectionCell class]]){
        FHCommunityCollectionCell *cell = (FHCommunityCollectionCell *)self.cellArray[self.currentTabIndex];
        cell.type = [self.dataArray[self.currentTabIndex] integerValue];
    }
}


#pragma mark - UICollectionViewDelegate

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%ld", [indexPath row]];
    [collectionView registerClass:[FHCommunityCollectionCell class] forCellWithReuseIdentifier:cellIdentifier];
    FHCommunityCollectionCell *cell = (FHCommunityCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    self.cellArray[row] = cell;
    
    //第一次初始化的时候
    if(self.isFirstLoad){
        self.isFirstLoad = NO;
        [self selectCurrentTabIndex];
    }
    
    if(row == self.currentTabIndex){
        [self initCell];
        [self.viewController addChildViewController:cell.contentViewController];
    }
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginOffSet = CGPointMake(self.currentTabIndex * [UIScreen mainScreen].bounds.size.width, scrollView.contentOffset.y);
    self.oldX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat scrollDistance = scrollView.contentOffset.x - _oldX;
    CGFloat diff = scrollView.contentOffset.x - self.beginOffSet.x;
    if(diff == 0){
        return;
    }

    CGFloat tabIndex = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    if(diff > 0){
        tabIndex = floorf(tabIndex);
    }else if (diff < 0){
        tabIndex = ceilf(tabIndex);
    }

    if(tabIndex != self.viewController.segmentControl.selectedSegmentIndex){
        self.currentTabIndex = tabIndex;
        self.viewController.segmentControl.selectedSegmentIndex = self.currentTabIndex;
    }
    else{
        if((tabIndex == 0 && diff < 0) || (tabIndex == maxCellCount - 1 && diff > 0)){

        }else{
            CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
            [self.viewController.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
        }
    }

    _oldX = scrollView.contentOffset.x;
}

//侧滑切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat diff = scrollView.contentOffset.x - self.beginOffSet.x;
    
    if(diff == 0){
        return;
    }
    
    [self initCell];
}

@end
