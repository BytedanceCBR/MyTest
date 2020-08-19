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
#import "FHEnvContext.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "FHHomeViewController.h"
#import "FHCommunityViewController.h"

@interface FHHomeMainViewModel()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , weak) FHHomeMainViewController *viewController;
@property(nonatomic , weak) FHHomeViewController *homeListVC;
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
        
//        if([[FHEnvContext sharedInstance] isRefreshFromCitySwitch]){
            [self resetCollectionOffset];
//        }
    }
    return self;
}

- (void)resetCollectionOffset
{
    if([[FHEnvContext sharedInstance] isRefreshFromCitySwitch]){
        self.viewController.currentTabIndex = 0;
    }
    NSInteger row = self.viewController.currentTabIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    if ([self.collectionView numberOfItemsInSection:0] > 0) {
        self.viewController.topView.segmentControl.selectedSegmentIndex = self.viewController.currentTabIndex;
        [self.viewController.topView changeBackColor:row];
        if (row == 1) {
            [self.viewController changeTopStatusShowHouse:NO];
        }
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
    
    if ([cell.contentVC isKindOfClass:[ArticleTabBarStyleNewsListViewController class]] || [cell.contentVC isKindOfClass:[FHCommunityViewController class]]) {
        self.viewController.feedListVC = cell.contentVC;
        self.viewController.feedListVC = cell.contentVC;
    }
    
    if ([cell.contentVC isKindOfClass:[FHHomeViewController class]]) {
        self.homeListVC = cell.contentVC;
    }
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginOffSet = CGPointMake(self.viewController.currentTabIndex * [UIScreen mainScreen].bounds.size.width, scrollView.contentOffset.y);
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
    
    [self.viewController.topView changeBackColor:(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width) > 0.5 ? 1 : 0];
    [self.homeListVC.topBar changeBackColor:(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width) > 0.5 ? 1 : 0];

    if(tabIndex != self.viewController.topView.segmentControl.selectedSegmentIndex){
        self.viewController.currentTabIndex = tabIndex;
        self.viewController.topView.segmentControl.selectedSegmentIndex = tabIndex;
        

        [FHEnvContext sharedInstance].isShowingHomeHouseFind = (tabIndex == 0);
        [self sendEnterCategory:tabIndex == 0 ? FHHomeMainTraceTypeHouse : FHHomeMainTraceTypeFeed enterType:FHHomeMainTraceEnterTypeFlip];
        [self sendStayCategory:tabIndex == 0 ? FHHomeMainTraceTypeFeed : FHHomeMainTraceTypeHouse enterType:FHHomeMainTraceEnterTypeFlip];
    }else{
        if(scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > [UIScreen mainScreen].bounds.size.width * (self.viewController.topView.segmentControl.sectionTitles.count - 1)){
            return;
        }
        self.viewController.currentTabIndex = tabIndex;
        
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
        //切换城市补报
        if (!self.viewController.feedListVC) {
//              NSMutableDictionary *traceDict = [NSMutableDictionary new];
//             if (enterType == FHHomeMainTraceEnterTypeClick) {
//                 [traceDict setValue:@"click" forKey:@"enter_type"];
//             }else
//             {
//                 [traceDict setValue:@"flip" forKey:@"enter_type"];
//             }
//
//             [traceDict setValue:@"maintab" forKey:@"enter_from"];
//             [traceDict setValue:@"click" forKey:@"enter_channel"];
//             [traceDict setValue:@"discover_stream" forKey:@"category_name"];
//             [FHEnvContext recordEvent:traceDict andEventKey:@"enter_category"];
//            if(![FHEnvContext isHomeNewDiscovery]){
//                [traceDict setValue:@"f_house_news"
//                                 forKey:@"category_name"];
//                [FHEnvContext recordEvent:traceDict andEventKey:@"enter_category"];
//            }
//            if ([self.viewController.feedListVC isKindOfClass:[FHCommunityViewController class]]) {
//                FHCommunityViewController *vc = (FHCommunityViewController *)self.viewController.feedListVC;
//                [vc viewAppearForEnterType:enterType needReport:NO];
//            }
        }else{
            if ([self.viewController.feedListVC isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
                ArticleTabBarStyleNewsListViewController *articleListVC = (ArticleTabBarStyleNewsListViewController *)self.viewController.feedListVC;
                [articleListVC viewAppearForEnterType:enterType needReportSubCategory:YES];
            }else if ([self.viewController.feedListVC isKindOfClass:[FHCommunityViewController class]]) {
                FHCommunityViewController *vc = (FHCommunityViewController *)self.viewController.feedListVC;
                [vc viewAppearForEnterType:enterType needReportSubCategory:YES];
            }
        }
    }
}

- (void)sendStayCategory:(FHHomeMainTraceType)traceType enterType:(FHHomeMainTraceEnterType)enterType{
    NSLog(@"%s -- %ld",__func__,enterType);
    if (traceType == FHHomeMainTraceTypeHouse) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeItemVCStayCategory" object:@(enterType)];
    }else
    {
        if ([self.viewController.feedListVC isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
            ArticleTabBarStyleNewsListViewController *articleListVC = (ArticleTabBarStyleNewsListViewController *)self.viewController.feedListVC;
            [articleListVC viewDisAppearForEnterType:enterType needReportSubCategory:YES];
        }else if ([self.viewController.feedListVC isKindOfClass:[FHCommunityViewController class]]) {
            FHCommunityViewController *vc = (FHCommunityViewController *)self.viewController.feedListVC;
            [vc viewDisAppearForEnterType:enterType needReportSubCategory:YES];
        }
    }
}


@end
