//
//  FHCommunityDiscoveryViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import "FHCommunityDiscoveryViewModel.h"
#import "FHCommunityViewController.h"
#import "FHCommunityDiscoveryCell.h"
#import "FHHouseUGCHeader.h"
#import "FHEnvContext.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "FHUGCCategoryManager.h"
#import "FHCommunityDiscoveryCellModel.h"
#import "FHUGCConfig.h"

#define kCellId @"cellId"

@interface FHCommunityDiscoveryViewModel ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic , strong) NSMutableArray *cellArray;
@property(nonatomic , strong) NSArray *dataArray;

@property(nonatomic , assign) CGPoint beginOffSet;
@property(nonatomic , assign) CGFloat oldX;

@property(nonatomic , strong) FHCommunityDiscoveryCell *lastCell;

@end

@implementation FHCommunityDiscoveryViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(FHCommunityViewController *)viewController {
    self = [super initWithCollectionView:collectionView controller:viewController];
    
    self.currentTabIndex = 0;
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self initDataArray];
    
    return self;
}

- (void)viewWillAppear {
    if(!self.isFirstLoad){
        [self initCell:@"default"];
    }
}

- (void)viewWillDisappear {
    if(self.currentTabIndex < self.cellArray.count && [self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityDiscoveryCell class]]){
        FHCommunityDiscoveryCell *cell = (FHCommunityDiscoveryCell *)self.cellArray[self.currentTabIndex];
        [cell cellDisappear];
    }
}

- (void)initDataArray {
    self.cellArray = [NSMutableArray array];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSArray *categories = [[FHUGCCategoryManager sharedManager] allCategories];
    self.viewController.categorys = [categories copy];
    for (NSInteger i = 0; i < categories.count; i++) {
        FHUGCCategoryDataDataModel *category = categories[i];
        if(category && category.name.length > 0 && category.category.length > 0){
            [self.cellArray addObject:[NSNull null]];
            FHCommunityDiscoveryCellModel *cellModel = [FHCommunityDiscoveryCellModel cellModelForCategory:category];
            [dataArray addObject:cellModel];
        }
    }
    self.dataArray = dataArray;
}

- (NSArray *)getSegmentTitles {
    NSMutableArray *titles = [NSMutableArray array];
    NSArray *categories = [[FHUGCCategoryManager sharedManager] allCategories];
    for (FHUGCCategoryDataDataModel *category in categories) {
        if(category.name.length > 0){
            [titles addObject:category.name];
        }
    }
    
    return titles;
}

- (void)selectCurrentTabIndex {
    self.viewController.segmentControl.selectedSegmentIndex = self.currentTabIndex;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentTabIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

//顶部tabView点击事件
- (void)segmentViewIndexChanged:(NSInteger)index {
    if(self.currentTabIndex == index){
        [self refreshCell:NO isClick:YES];
    }else{
        self.currentTabIndex = index;
        
        [self initCell:@"click"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)initCell:(NSString *)enterType {
    if(self.currentTabIndex < self.cellArray.count && [self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityDiscoveryCell class]]){
        
        FHCommunityDiscoveryCell *cell = (FHCommunityDiscoveryCell *)self.cellArray[self.currentTabIndex];
        cell.enterType = enterType;
        
        NSInteger index = [[FHUGCCategoryManager sharedManager] getCategoryIndex:@"f_ugc_neighbor"];
        if(self.currentTabIndex == index){
            cell.withTips = self.viewController.hasFocusTips;
        }else{
            cell.withTips = NO;
        }
        
        FHCommunityDiscoveryCellModel *cellModel = self.dataArray[self.currentTabIndex];
        cell.cellModel = cellModel;
        
        //在进入之前报一下上一次tab的埋点
        if(_lastCell && _lastCell != cell){
            [_lastCell cellDisappear];
            _lastCell = nil;
        }
        
        [self.viewController addChildViewController:cell.contentViewController];
        
        _lastCell = cell;
        
        [self.viewController hideRedPoint];
    }
}

- (void)refreshCell:(BOOL)isHead isClick:(BOOL)isClick {
    if(self.currentTabIndex < self.cellArray.count && [self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityDiscoveryCell class]]){
        FHCommunityDiscoveryCell *cell = (FHCommunityDiscoveryCell *)self.cellArray[self.currentTabIndex];
        [cell refreshData:isHead isClick:isClick];
    }
}

- (void)changeTab:(NSInteger)index {
    if(index < self.dataArray.count){
        self.currentTabIndex = index;
        [self initCell:@"default"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentTabIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
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
    [collectionView registerClass:[FHCommunityDiscoveryCell class] forCellWithReuseIdentifier:cellIdentifier];
    FHCommunityDiscoveryCell *cell = (FHCommunityDiscoveryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    self.cellArray[row] = cell;
    
    //第一次初始化的时候
    if(self.isFirstLoad){
        self.isFirstLoad = NO;
        if(self.currentTabIndex != row){
            [self selectCurrentTabIndex];
        }
    }
    
    if(row == self.currentTabIndex){
        [self initCell:@"default"];
    }
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat bottom = 49;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    CGFloat top = 0;
    CGFloat safeTop = 0;
    if (@available(iOS 11.0, *)) {
        safeTop = self.viewController.view.tt_safeAreaInsets.top;
    }
    if (safeTop > 0) {
        top += safeTop;
    } else {
        if([[UIApplication sharedApplication] statusBarFrame].size.height > 0){
            top += [[UIApplication sharedApplication] statusBarFrame].size.height;
        }else{
            if([TTDeviceHelper isIPhoneXSeries]){
                top += 44;
            }else{
                top += 20;
            }
        }
    }
    
    if(self.viewController.isUgcOpen){
        top += 44;
    }
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - top - bottom);
    
    return size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginOffSet = CGPointMake(self.currentTabIndex * [UIScreen mainScreen].bounds.size.width, scrollView.contentOffset.y);
    self.oldX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollDistance = scrollView.contentOffset.x - _oldX;
    CGFloat diff = scrollView.contentOffset.x - self.beginOffSet.x;

    CGFloat tabIndex = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    if(diff >= 0){
        tabIndex = floorf(tabIndex);
    }else if (diff < 0){
        tabIndex = ceilf(tabIndex);
    }

    if(tabIndex != self.viewController.segmentControl.selectedSegmentIndex){
        self.currentTabIndex = tabIndex;
//        self.viewController.segmentControl.selectedSegmentIndex = self.currentTabIndex;
        [self.viewController.segmentControl setSelectedSegmentIndex:self.currentTabIndex animated:YES];
    }
    else{
        if(scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > [UIScreen mainScreen].bounds.size.width * (self.viewController.segmentControl.sectionTitles.count - 1)){
            return;
        }
        
        CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
        [self.viewController.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
    }

    _oldX = scrollView.contentOffset.x;
}

//侧滑切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat diff = scrollView.contentOffset.x - self.beginOffSet.x;
    
    if(diff == 0){
        return;
    }
    
    [self initCell:@"flip"];
}

- (NSString *)pageType {
    NSString *page_type = UT_BE_NULL;
    if(self.currentTabIndex < self.dataArray.count){
        FHCommunityDiscoveryCellModel *cellModel = self.dataArray[self.currentTabIndex];
        if (cellModel.type == FHCommunityCollectionCellTypeMyJoin) {
            page_type = @"my_join_feed";
        } else if (cellModel.type == FHCommunityCollectionCellTypeNearby) {
            page_type = @"hot_discuss_feed";
        }else if (cellModel.type == FHCommunityCollectionCellTypeCustom) {
            page_type = cellModel.category;
        }
    }
    return page_type;
}

@end

