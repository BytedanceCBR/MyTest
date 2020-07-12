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

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


@interface FHBrowsingHistoryViewModel()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) FHBrowsingHistoryViewController *viewController;
@property (nonatomic, weak) FHSuggestionCollectionView *collectionView;
@property (nonatomic, assign) CGPoint beginOffSet;
@property (nonatomic, assign) CGFloat oldX;

@end

@implementation FHBrowsingHistoryViewModel

- (instancetype)initWithController:(FHBrowsingHistoryViewController *)viewController andCollectionView:(FHSuggestionCollectionView *)collectionView {
    self = [super init];
    if (self) {
        _currentTabIndex = -1;
        self.viewController = viewController;
        self.collectionView = collectionView;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.collectionView registerClass:[FHBrowsingHistoryCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBrowsingHistoryCollectionViewCell class])];
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

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass([FHBrowsingHistoryCollectionViewCell class]);
    FHBrowsingHistoryCollectionViewCell *cell = (FHBrowsingHistoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = randomColor;
    return cell;
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
@end
