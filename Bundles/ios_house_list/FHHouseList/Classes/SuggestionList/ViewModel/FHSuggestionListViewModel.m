//
//  FHSuggestionListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewModel.h"
#import "FHSuggestionCollectionViewCell.h"
#import "FHSuggestionCollectionView.h"

@interface FHSuggestionListViewModel ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) FHSuggestionListViewController *listController;
@property (nonatomic, weak) FHSuggestionCollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary *cellDict;
@property (nonatomic, assign) CGPoint beginOffSet;
@property (nonatomic, assign) CGFloat oldX;
//第一次进入页面
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation FHSuggestionListViewModel

-(instancetype)initWithController:(FHSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        _currentTabIndex = -1;
        self.listController = viewController;
        self.cellDict = [NSMutableDictionary new];
        [self initNotification];
        self.listController.startMonitorTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateSubVCTrackStatus
{
    NSString *rowStr = [NSString stringWithFormat:@"%zi", _currentTabIndex];
    FHSuggestionCollectionViewCell *cell = _cellDict[rowStr];
    if (cell && cell.vc) {
        cell.vc.isCanTrack = YES;
    }
}

- (void)textFieldShouldReturn:(NSString *)text
{
    NSString *rowStr = [NSString stringWithFormat:@"%zi", _currentTabIndex];
    FHSuggestionCollectionViewCell *cell = _cellDict[rowStr];
    [cell.vc doTextFieldShouldReturn:text];
}

- (void)textFieldTextChange:(NSString *)text
{
    NSString *rowStr = [NSString stringWithFormat:@"%zi", _currentTabIndex];
    FHSuggestionCollectionViewCell *cell = _cellDict[rowStr];
    [cell.vc textFiledTextChange:text andIsCanTrack:YES];
}

- (void)textFieldWillClear {
    NSString *rowStr = [NSString stringWithFormat:@"%zi", _currentTabIndex];
    FHSuggestionCollectionViewCell *cell = _cellDict[rowStr];
    [cell.vc textFieldWillClear];
}

- (void)initCollectionView:(FHSuggestionCollectionView *)collectionView
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

- (void)initNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    //获取键盘弹出的高度
    NSDictionary *dict = [notification userInfo];
    NSValue *value = [dict objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [value CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    self.isTrackerCacheDisabled = NO;
    self.keyboardHeight = keyboardHeight;
    self.listController.isTrackerCacheDisabled = self.isTrackerCacheDisabled;
    self.listController.keyboardHeight = self.keyboardHeight;
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    self.isTrackerCacheDisabled = YES;
    self.keyboardHeight = 0.0;
    self.listController.isTrackerCacheDisabled = self.isTrackerCacheDisabled;
    self.listController.keyboardHeight = self.keyboardHeight;
    
    NSInteger selectedIndex = self.segmentControl.selectedSegmentIndex;
    if (selectedIndex >= 0 && selectedIndex < self.listController.houseTypeArray.count) {
        NSNumber *value = self.listController.houseTypeArray[selectedIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionKeyboardWillHideNotification object:value];
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
    if ([cell isKindOfClass: [FHSuggestionCollectionViewCell class]]) {
        NSInteger row = indexPath.item;
        NSString *rowStr = [NSString stringWithFormat:@"%zi", row];
        if (!self.cellDict[rowStr]) {
            self.cellDict[rowStr] = cell;
            [self initCellWithIndex:row];
        }
        FHSuggestionCollectionViewCell *newCell = (FHSuggestionCollectionViewCell *)cell;
        [newCell.vc textFiledTextChange:self.listController.naviBar.searchInput.text andIsCanTrack:NO];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.item;
    FHSuggestionCollectionViewCell *cell = NULL;
    if (row >= 0 && row < self.listController.houseTypeArray.count) {
        
        NSString *rowStr = [NSString stringWithFormat:@"%zi", row];
        if (self.cellDict[rowStr]) {
           cell = self.cellDict[rowStr];
        } else {
            NSString *cellIdentifier = NSStringFromClass([FHSuggestionCollectionViewCell class]);
            
            cellIdentifier = [NSString stringWithFormat:@"%@_%zi", cellIdentifier, row];
            [collectionView registerClass:[FHSuggestionCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
            cell = (FHSuggestionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        return cell;
    }
    return [[UICollectionViewCell alloc] init];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.listController.view endEditing:YES];
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
    if (index != self.listController.segmentControl.selectedSegmentIndex) {
        if (index >= 0 && index < [self.listController.houseTypeArray count]) {
            self.currentTabIndex = index;
            self.listController.segmentControl.selectedSegmentIndex = index;
            [self.listController scrollToIndex:index];
        }
    } else {
        if(scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > [UIScreen mainScreen].bounds.size.width * (CGFloat)(self.listController.segmentControl.sectionTitles.count - 1)){
            self.listController.segmentControl.selectedSegmentIndex = self.currentTabIndex;
            if (scrollView.contentOffset.x < 0) {
                _oldX = 0;
            } else {
                _oldX = [UIScreen mainScreen].bounds.size.width * (CGFloat)(self.listController.segmentControl.sectionTitles.count - 1);
            }
            return;
        }
        //加载数据
        CGFloat value = scrollDistance/[UIScreen mainScreen].bounds.size.width;
        [self.listController.segmentControl setScrollValue:value isDirectionLeft:diff < 0];
    }
    _oldX = scrollView.contentOffset.x;
}

-(void)initCellWithIndex:(NSInteger)index;
{
    NSString *rowStr = [NSString stringWithFormat:@"%zi", index];
    if (index < self.listController.houseTypeArray.count && index >= 0 && self.cellDict[rowStr]) {
        FHSuggestionCollectionViewCell *cell = self.cellDict[rowStr];
        [cell refreshData:self.listController.paramObj andHouseType:[self.listController.houseTypeArray[index] integerValue]];
        if (cell.vc && ![self.listController.childViewControllers containsObject:cell.vc]) {
            [self.listController addChildViewController:cell.vc];
            cell.vc.fatherVC = self.listController;
        }
        cell.vc.houseType = [self.listController.houseTypeArray[index] integerValue];
    }
}

@end
