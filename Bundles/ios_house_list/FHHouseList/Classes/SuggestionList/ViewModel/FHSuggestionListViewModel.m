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
@property (nonatomic, strong) FHSuggestionCollectionViewCell *lastCell;
@property (nonatomic, strong) NSMutableDictionary *cellDict;
@property (nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic , assign) CGPoint beginOffSet;
@property(nonatomic , assign) CGFloat oldX;

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        _currentTabIndex = -1;
        self.listController = viewController;
        self.cellDict = [NSMutableDictionary new];
        _isFirstLoad = YES;
    }
    return self;
}

- (void)textFieldShouldReturn:(NSString *)text
{
    NSString *rowStr = [NSString stringWithFormat:@"%ld", _currentTabIndex];
    FHSuggestionCollectionViewCell *cell = _cellDict[rowStr];
    [cell.vc doTextFieldShouldReturn:text];
}

- (void)textFieldTextChange:(NSString *)text
{
    NSString *rowStr = [NSString stringWithFormat:@"%ld", _currentTabIndex];
    FHSuggestionCollectionViewCell *cell = _cellDict[rowStr];
    [cell.vc textFiledTextChange:text];
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //子vc segtableview去重
    if ([cell isKindOfClass: [FHSuggestionCollectionViewCell class]]) {
        
        NSInteger row = indexPath.item;
        NSString *rowStr = [NSString stringWithFormat:@"%ld", row];
        if (self.cellDict[rowStr]) {
            FHSuggestionCollectionViewCell *newCell = (FHSuggestionCollectionViewCell *)cell;
            [newCell.vc textFiledTextChange:self.listController.naviBar.searchInput.text];
        } else {
            self.cellDict[rowStr] = cell;
            [self initCellWithIndex:row];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.item;
    FHSuggestionCollectionViewCell *cell = NULL;
    if (row >= 0 && row < self.listController.houseTypeArray.count) {
        
        NSString *rowStr = [NSString stringWithFormat:@"%ld", row];
        if (self.cellDict[rowStr]) {
           cell = self.cellDict[rowStr];
        } else {
            NSString *cellIdentifier = NSStringFromClass([FHSuggestionCollectionViewCell class]);
            
            cellIdentifier = [NSString stringWithFormat:@"%@_%ld", cellIdentifier, row];
            [collectionView registerClass:[FHSuggestionCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
            cell = (FHSuggestionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
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
    if (tabIndex != self.listController.segmentControl.selectedSegmentIndex) {
        self.currentTabIndex = tabIndex;
        self.listController.segmentControl.selectedSegmentIndex = tabIndex;
        self.listController.houseType = [self.listController.houseTypeArray[(int)tabIndex] integerValue];
    } else {
        //加载数据
        CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
        [self.listController.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
    }
    _oldX = scrollView.contentOffset.x;
}

-(void)initCellWithIndex:(NSInteger)index;
{
    NSString *rowStr = [NSString stringWithFormat:@"%ld", index];
    if (index < self.listController.houseTypeArray.count && index >= 0 && self.cellDict[rowStr]) {
        FHSuggestionCollectionViewCell *cell = self.cellDict[rowStr];
        
        [cell refreshData:self.listController.paramObj andHouseType:[self.listController.houseTypeArray[index] integerValue]];
        
        if (cell.vc && ![self.listController.childViewControllers containsObject:cell.vc]) {
            [self.listController addChildViewController:cell.vc];
            cell.vc.fatherVC = self.listController;
        }
    }
}

@end
