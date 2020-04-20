//
//  FHSuggestionListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewModel.h"
#import "FHSuggestionListViewController.h"
#import "FHSuggestionCollectionViewCell.h"

@interface FHSuggestionListViewModel ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) FHSuggestionListViewController *listController;
@property (nonatomic, weak) FHBaseCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *cellArray;
@property (nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic , assign) CGPoint beginOffSet;
@property(nonatomic , assign) CGFloat oldX;

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
        [self initDataArray];
        _isFirstLoad = YES;
    }
    return self;
}

- (void)initDataArray {
    self.cellArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        [self.cellArray addObject:[NSNull null]];
    }
}

- (void)initCollectionView:(FHBaseCollectionView *)collectionView
{
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.collectionView registerClass:[FHSuggestionCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([FHSuggestionCollectionViewCell class])];
}

- (void)setCurrentTabIndex:(NSInteger)currentTabIndex
{
    if (_currentTabIndex != currentTabIndex) {
        _currentTabIndex = currentTabIndex;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentTabIndex inSection:0];

        [self.collectionView layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}



#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _segmentControl.sectionTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = NSStringFromClass([FHSuggestionCollectionViewCell class]);
    FHSuggestionCollectionViewCell *cell = (FHSuggestionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger row = indexPath.item;
    if (row % 2 == 1) {
        cell.backgroundColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor blueColor];
    }
    self.cellArray[row] = cell;
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        
    }
    if (row == _currentTabIndex) {
        cell.tag = self.listController.houseTypeArray[row];
        [self initCell];
    }
    return cell;
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
    if (tabIndex != self.listController.segmentControl.selectedSegmentIndex) {
        self.currentTabIndex = tabIndex;
        self.listController.segmentControl.selectedSegmentIndex = tabIndex;
        self.listController.houseType = [self.listController.houseTypeArray[(int)tabIndex] integerValue];
    } else {
        CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
        [self.listController.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
    }
    _oldX = scrollView.contentOffset.x;
}

//侧滑切换tab
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

-(void)initCell
{
    if (_currentTabIndex < self.cellArray.count && self.cellArray[_currentTabIndex]) {
        
    }
}

@end
