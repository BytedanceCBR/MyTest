//
//  FHHomeMainViewModel.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainViewModel.h"
#import "FHHomeMainViewController.h"
#import "FHHomeMainHouseCollectionCell.h"
#import "FHHomeMainFeedCollectionCell.h"
#import <FHEnvContext.h>
#import <ArticleTabbarStyleNewsListViewController.h>

@interface FHHomeMainViewModel()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , weak) FHHomeMainViewController *viewController;
@property(nonatomic , weak) ArticleTabBarStyleNewsListViewController *articleListVC;
@property(nonatomic , strong) NSMutableArray *dataArray;
@property(nonatomic , assign) CGPoint beginOffSet;
@property(nonatomic , assign) CGFloat oldX;
@property(nonatomic , strong) NSMutableDictionary *traceDict;

@end

@implementation FHHomeMainViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
        [self registerCollectionCells];
        [self resetDataArray];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        self.viewController = (FHHomeMainViewController *)viewController;
        
        [self resetCollectionOffset];
    }
    return self;
}

- (void)resetCollectionOffset
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.collectionView numberOfItemsInSection:0] > 0) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)resetDataArray
{
    if ([FHEnvContext isCurrentCityNormalOpen]) {
        self.dataArray = @[@(kFHHomeMainCellTypeHouse),@(kFHHomeMainCellTypeFeed)];
    }else
    {
        self.dataArray = @[@(kFHHomeMainCellTypeFeed)];
    }
    
    [self.collectionView reloadData];
}

- (void)registerCollectionCells
{
    [self.collectionView registerClass:[FHHomeMainHouseCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHHomeMainHouseCollectionCell class])];
    [self.collectionView registerClass:[FHHomeMainFeedCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHHomeMainFeedCollectionCell class])];
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
    NSString *cellIdentifier = NSStringFromClass([FHHomeMainBaseCollectionCell class]);

    if (self.dataArray.count > indexPath.row) {
        if ([self.dataArray[indexPath.row] integerValue] == kFHHomeMainCellTypeHouse) {
            cellIdentifier = NSStringFromClass([FHHomeMainHouseCollectionCell class]);
        }else
        {
            cellIdentifier = NSStringFromClass([FHHomeMainFeedCollectionCell class]);
        }
    }

    FHHomeMainBaseCollectionCell *cell = (FHHomeMainBaseCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (cell.contentVC && ![self.viewController.childViewControllers containsObject:cell.contentVC]) {
        [self.viewController addChildViewController:cell.contentVC];
    }
    
    if ([cell.contentVC isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
        self.articleListVC = cell.contentVC;
    }
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginOffSet = CGPointMake(self.currentIndex * [UIScreen mainScreen].bounds.size.width, scrollView.contentOffset.y);
    self.oldX = scrollView.contentOffset.x;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSInteger resultIndex = (NSInteger)((scrollView.contentOffset.x + [UIScreen mainScreen].bounds.size.width/2)/[UIScreen mainScreen].bounds.size.width);
//    self.currentIndex = resultIndex;
//    self.viewController.topView.segmentControl.selectedSegmentIndex = resultIndex;
//
//    if (resultIndex == 1) {
//        [self.viewController changeTopStatusShowHouse:NO];
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scrollDistance = scrollView.contentOffset.x - _oldX;
    CGFloat diff = scrollView.contentOffset.x - self.beginOffSet.x;
    
    CGFloat tabIndex = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    if(diff >= 0){
        tabIndex = floorf(tabIndex);
    }else if (diff < 0){
        tabIndex = ceilf(tabIndex);
    }
    
    if(tabIndex != self.viewController.topView.segmentControl.selectedSegmentIndex){
        self.currentIndex = tabIndex;
        self.viewController.topView.segmentControl.selectedSegmentIndex = self.currentIndex;
        
        [self sendEnterCategory:tabIndex == 0 ? FHHomeMainTraceTypeHouse : FHHomeMainTraceTypeFeed enterType:FHHomeMainTraceEnterTypeFlip];
        [self sendStayCategory:tabIndex == 0 ? FHHomeMainTraceTypeFeed : FHHomeMainTraceTypeHouse enterType:FHHomeMainTraceEnterTypeFlip];
    }else{
        if(scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > [UIScreen mainScreen].bounds.size.width * (self.viewController.topView.segmentControl.sectionTitles.count - 1)){
            return;
        }
        self.currentIndex = tabIndex;
        
        CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
        [self.viewController.topView.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
    }
    
    if (tabIndex == 1) {
        [self.viewController changeTopStatusShowHouse:NO];
    }
    _oldX = scrollView.contentOffset.x;
}

//侧滑切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)sendEnterCategory:(FHHomeMainTraceType)traceType enterType:(FHHomeMainTraceEnterType)enterType{
    NSLog(@"%s -- %ld",__func__,enterType);
    if (traceType == FHHomeMainTraceTypeHouse) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeItemVCEnterCategory" object:@(enterType)];
    }else
    {
        [self.articleListVC viewAppearForEnterType:enterType];
    }
}

- (void)sendStayCategory:(FHHomeMainTraceType)traceType enterType:(FHHomeMainTraceEnterType)enterType{
    NSLog(@"%s -- %ld",__func__,enterType);
    if (traceType == FHHomeMainTraceTypeHouse) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeItemVCStayCategory" object:@(enterType)];
    }else
    {
        [self.articleListVC viewDisAppearForEnterType:enterType];
    }
}


@end
