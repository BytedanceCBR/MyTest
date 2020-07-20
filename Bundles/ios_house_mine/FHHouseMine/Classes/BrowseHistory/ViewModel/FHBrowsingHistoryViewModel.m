//
//  FHBrowsingHistoryViewModel.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/12.
//

#import "FHBrowsingHistoryViewModel.h"
#import "FHBrowsingHistoryViewController.h"
#import "FHSuggestionCollectionView.h"
#import "FHBrowsingHistoryCollectionViewCell.h"
#import "FHUserTracker.h"

@interface FHBrowsingHistoryViewModel()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) FHBrowsingHistoryViewController *viewController;
@property (nonatomic, weak) FHSuggestionCollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary *cellDict;
@property (nonatomic, assign) CGPoint beginOffSet;
@property (nonatomic, assign) CGFloat oldX;

@end

@implementation FHBrowsingHistoryViewModel

- (instancetype)initWithController:(FHBrowsingHistoryViewController *)viewController andCollectionView:(FHSuggestionCollectionView *)collectionView {
    self = [super init];
    if (self) {
        self.currentTabIndex = -1;
        self.cellDict = [[NSMutableDictionary alloc] init];
        self.viewController = viewController;
        self.collectionView = collectionView;
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    return self;
}

- (void)setCurrentTabIndex:(NSInteger)currentTabIndex {
    if (_currentTabIndex != currentTabIndex) {
        _currentTabIndex = currentTabIndex;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentTabIndex inSection:0];
        [self.collectionView layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)initCellWithIndex:(NSInteger)index andRowStr:(NSString *)rowStr {
    if (index < self.viewController.houseTypeArray.count && index >= 0 && self.cellDict[rowStr]) {
        FHBrowsingHistoryCollectionViewCell *cell = self.cellDict[rowStr];
        [cell refreshData:self.viewController.paramObj andHouseType:[self.viewController.houseTypeArray[index] integerValue] andVC:self.viewController];
        
    }
}

- (void)updateSubVCTrackStatus {
    NSString *rowStr = [NSString stringWithFormat:@"%ld", _currentTabIndex];
    FHBrowsingHistoryCollectionViewCell *cell = _cellDict[rowStr];
    if (cell) {
        [cell updateTrackStatu];
    }
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewController.houseTypeArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FHBrowsingHistoryCollectionViewCell class]]) {
        NSInteger row = indexPath.item;
        NSString *rowStr = [NSString stringWithFormat:@"%ld", row];
        if (!self.cellDict[rowStr]) {
            self.cellDict[rowStr] = cell;
            [self initCellWithIndex:row andRowStr:rowStr];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.item;
    FHBrowsingHistoryCollectionViewCell *cell = NULL;
    if (row >= 0 && row < self.viewController.houseTypeArray.count) {
        NSString *rowStr = [NSString stringWithFormat:@"%ld", row];
        if (self.cellDict[rowStr]) {
            cell = self.cellDict[rowStr];
        } else {
            NSString *cellIdentifier = NSStringFromClass([FHBrowsingHistoryCollectionViewCell class]);
            
            cellIdentifier = [NSString stringWithFormat:@"%@_%ld", cellIdentifier, row];
            [collectionView registerClass:[FHBrowsingHistoryCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
            cell = (FHBrowsingHistoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        return cell;
    }
    return [[UICollectionViewCell alloc] init];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginOffSet = CGPointMake(self.currentTabIndex * [UIScreen mainScreen].bounds.size.width, scrollView.contentOffset.y);
    self.oldX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat tabIndex = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    CGFloat scrollDistance = scrollView.contentOffset.x - _oldX;
    CGFloat diff = scrollView.contentOffset.x - self.beginOffSet.x;
    if(diff >= 0){
        tabIndex = floorf(tabIndex);
    }else if (diff < 0){
        tabIndex = ceilf(tabIndex);
    }
    NSInteger index = (int)tabIndex;
    if (tabIndex != self.viewController.segmentControl.selectedSegmentIndex) {
        self.currentTabIndex = index;
        self.viewController.segmentControl.selectedSegmentIndex = index;
        self.viewController.houseType = [self.viewController.houseTypeArray[index] integerValue];
    } else {
        //加载数据
        CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
        [self.viewController.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
    }
    _oldX = scrollView.contentOffset.x;
}

#pragma mark - 埋点

- (void)addGoDetailLog {
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.viewController.tracerDict];
    params[@"page_type"] = @"history_visit";
    [FHUserTracker writeEvent:@"go_detail" params:params];
}

@end
