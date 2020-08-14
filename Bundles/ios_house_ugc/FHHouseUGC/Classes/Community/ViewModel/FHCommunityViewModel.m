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
#import "FHEnvContext.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "FHUGCConfig.h"

#define kCellId @"cellId"
#define maxCellCount 2

@interface FHCommunityViewModel ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic , strong) NSMutableArray *cellArray;
@property(nonatomic , strong) NSArray *dataArray;

@property(nonatomic , assign) CGPoint beginOffSet;
@property(nonatomic , assign) CGFloat oldX;

@property(nonatomic , strong) FHCommunityCollectionCell *lastCell;

@end

@implementation FHCommunityViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(FHCommunityViewController *)viewController {
    self = [super initWithCollectionView:collectionView controller:viewController];
    
    if([FHEnvContext isHasVideoList]){
        self.currentTabIndex = 0;
    }else{
        self.currentTabIndex = 1;
    }
    
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
    if(self.currentTabIndex < self.cellArray.count && [self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityCollectionCell class]]){
        FHCommunityCollectionCell *cell = (FHCommunityCollectionCell *)self.cellArray[self.currentTabIndex];
        [cell cellDisappear];
    }
}

- (void)initDataArray {
    self.cellArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < maxCellCount; i++) {
        [self.cellArray addObject:[NSNull null]];
    }
    
    if([FHEnvContext isHasVideoList]){
        self.dataArray = @[
            @(FHCommunityCollectionCellTypeCustom),
            @(FHCommunityCollectionCellTypeNearby),
        ];
    }else{
        self.dataArray = @[
            @(FHCommunityCollectionCellTypeMyJoin),
            @(FHCommunityCollectionCellTypeNearby),
        ];
    }
    
}

- (NSArray *)getSegmentTitles {
    NSMutableArray *titles = [NSMutableArray array];
    
    NSDictionary *ugcTitles = [FHEnvContext ugcTabName];
    if([FHEnvContext isHasVideoList]){
        [titles addObject:@"视频"];
    }else{
        if(ugcTitles[kUGCTitleMyJoinList]){
            NSString *name = ugcTitles[kUGCTitleMyJoinList];
            if(name.length > 2){
                name = [name substringToIndex:2];
            }
            [titles addObject:name];
        }else{
            [titles addObject:@"关注"];
        }
    }
    
    if(ugcTitles[kUGCTitleNearbyList]){
        NSString *name = ugcTitles[kUGCTitleNearbyList];
        if(name.length > 2){
            name = [name substringToIndex:2];
        }
        [titles addObject:name];
    }else{
        [titles addObject:@"附近"];
    }
    
    if(titles.count == 2){
        return titles;
    }
    
    NSArray *defaultTitles = @[@"关注", @"附近"];
    if([FHEnvContext isHasVideoList]){
        defaultTitles = @[@"视频", @"附近"];
    }
    
    return defaultTitles;
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
        
        if(self.currentTabIndex == 0 && ([FHUGCConfig sharedInstance].followList.count <= 0 || [FHEnvContext isHasVideoList])){
            self.viewController.publishBtn.hidden = YES;
        }else{
            self.viewController.publishBtn.hidden = NO;
        }
    }
}

- (void)initCell:(NSString *)enterType {
    if(self.currentTabIndex < self.cellArray.count && [self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityCollectionCell class]]){
        FHCommunityCollectionCell *cell = (FHCommunityCollectionCell *)self.cellArray[self.currentTabIndex];
        cell.enterType = enterType;
        
        if(self.currentTabIndex == 0){
            cell.withTips = self.viewController.hasFocusTips;
        }else{
            cell.withTips = NO;
        }
        
        [cell setType:[self.dataArray[self.currentTabIndex] integerValue] tracerDict:self.viewController.tracerDict];
        //在进入之前报一下上一次tab的埋点
        if(_lastCell && _lastCell != cell){
            [_lastCell cellDisappear];
            _lastCell = nil;
        }
        
        [self.viewController addChildViewController:cell.contentViewController];
        
        _lastCell = cell;
        
        //切换到关注tab时候去掉红点的显示
        if(self.currentTabIndex == 0){
            [self.viewController hideRedPoint];
        }
    }
}

- (void)refreshCell:(BOOL)isHead isClick:(BOOL)isClick {
    if(self.currentTabIndex < self.cellArray.count && [self.cellArray[self.currentTabIndex] isKindOfClass:[FHCommunityCollectionCell class]]){
        FHCommunityCollectionCell *cell = (FHCommunityCollectionCell *)self.cellArray[self.currentTabIndex];
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
        self.viewController.segmentControl.selectedSegmentIndex = self.currentTabIndex;
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
    
    if(![FHEnvContext isHasVideoList]){
        //关注tab，没有关注时需要隐藏关注按钮
        if(self.currentTabIndex == 0 && [FHUGCConfig sharedInstance].followList.count <= 0){
            self.viewController.publishBtn.hidden = YES;
        }else{
            self.viewController.publishBtn.hidden = NO;
        }
    }
}

- (NSString *)pageType {
    NSString *page_type = UT_BE_NULL;
    if(self.currentTabIndex < self.dataArray.count){
        FHCommunityCollectionCellType type = [self.dataArray[self.currentTabIndex] integerValue];
        if (type == FHCommunityCollectionCellTypeMyJoin) {
            page_type = @"my_join_feed";
        } else  if (type == FHCommunityCollectionCellTypeNearby) {
            page_type = @"hot_discuss_feed";
        }
    }
    return page_type;
}

@end
